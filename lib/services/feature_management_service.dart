import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/feature_flag_model.dart';

class FeatureManagementService {
  static final FeatureManagementService _instance = FeatureManagementService._internal();
  factory FeatureManagementService() => _instance;
  FeatureManagementService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // In-memory cache for zero-latency synchronous evaluation across the app
  FeatureOverrideSettings? _globalSettings;
  final Map<String, FeatureOverrideSettings> _societySettingsCache = {};

  StreamSubscription? _globalSub;
  final Map<String, StreamSubscription> _societySubs = {};

  final ValueNotifier<int> changeNotifier = ValueNotifier<int>(0);

  // Default Master Admin Email
  static const String masterAdminEmail = 'hossansajjad1994@gmail.com';

  bool isPlatformMasterAdmin(String? userEmail) {
    if (userEmail == null) return false;
    return userEmail.trim().toLowerCase() == masterAdminEmail;
  }

  /// Initialize real-time listeners for global settings
  void initialize() {
    if (_globalSub != null) return;

    _globalSub = _firestore
        .collection('platform_feature_settings')
        .doc('global')
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        _globalSettings = FeatureOverrideSettings.fromSnapshot(doc);
      } else {
        // Safe default: everything enabled
        _globalSettings = FeatureOverrideSettings(
          id: 'global',
          moduleToggles: {},
          featureToggles: {},
          updatedBy: 'system',
          updatedAt: DateTime.now(),
        );
      }
      changeNotifier.value++;
    }, onError: (err) {
      debugPrint('Global feature flag sync error: $err');
    });
  }

  /// Subscribe to a specific society's feature configuration
  void watchSocietyFeatures(String societyId) {
    if (_societySubs.containsKey(societyId)) return;

    final sub = _firestore
        .collection('somitis')
        .doc(societyId)
        .collection('society_feature_settings')
        .doc('settings')
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        _societySettingsCache[societyId] = FeatureOverrideSettings.fromSnapshot(doc);
      } else {
        _societySettingsCache[societyId] = FeatureOverrideSettings(
          id: societyId,
          moduleToggles: {},
          featureToggles: {},
          updatedBy: 'system',
          updatedAt: DateTime.now(),
        );
      }
      changeNotifier.value++;
    }, onError: (err) {
      debugPrint('Society feature flag sync error ($societyId): $err');
    });

    _societySubs[societyId] = sub;
  }

  /// Determine if a given feature or module can be accessed
  /// Deterministic precedence hierarchy:
  /// 1. Platform-wide Master Admin global availability
  /// 2. Society-specific configuration availability
  /// 3. Role-level permission availability
  bool canAccess({
    required String featureKey,
    String? societyId,
    String? userEmail,
    String? userRole,
  }) {
    // 0. Super Admin always retains access to administrative tools
    if (isPlatformMasterAdmin(userEmail)) {
      return true;
    }

    // 1. Check Global Platform Toggle
    if (_globalSettings != null) {
      if (_globalSettings!.featureToggles.containsKey(featureKey)) {
        if (_globalSettings!.featureToggles[featureKey] == false) {
          return false; // Disabled globally by Master Admin
        }
      }

      // Check if parent module is disabled globally
      final parentModule = _findParentModuleKey(featureKey);
      if (parentModule != null && _globalSettings!.moduleToggles.containsKey(parentModule)) {
        if (_globalSettings!.moduleToggles[parentModule] == false) {
          return false; // Parent module disabled globally
        }
      }
    }

    // 2. Check Society-Specific Override
    if (societyId != null && _societySettingsCache.containsKey(societyId)) {
      final sSettings = _societySettingsCache[societyId]!;
      if (sSettings.featureToggles.containsKey(featureKey)) {
        if (sSettings.featureToggles[featureKey] == false) {
          return false; // Disabled for this specific society
        }
      }

      final parentModule = _findParentModuleKey(featureKey);
      if (parentModule != null && sSettings.moduleToggles.containsKey(parentModule)) {
        if (sSettings.moduleToggles[parentModule] == false) {
          return false; // Parent module disabled for this society
        }
      }
    }

    // 3. Fallback to Registry Default
    final item = _findFeatureItem(featureKey);
    return item?.defaultEnabled ?? true;
  }

  /// Helper to find parent module for a feature
  String? _findParentModuleKey(String featureKey) {
    for (final mod in MasterFeatureRegistry.allModules) {
      if (mod.key == featureKey) return mod.key;
      for (final sub in mod.subFeatures) {
        if (sub.key == featureKey) return mod.key;
      }
    }
    return null;
  }

  FeatureItem? _findFeatureItem(String featureKey) {
    for (final mod in MasterFeatureRegistry.allModules) {
      for (final sub in mod.subFeatures) {
        if (sub.key == featureKey) return sub;
      }
    }
    return null;
  }

  /// Master Admin API: Toggle Global Module Status
  Future<void> toggleGlobalModule({
    required String moduleKey,
    required bool isEnabled,
    required String adminEmail,
  }) async {
    final docRef = _firestore.collection('platform_feature_settings').doc('global');
    await docRef.set({
      'moduleToggles': {
        moduleKey: isEnabled,
      },
      'updatedBy': adminEmail,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Audit log
    await _recordAuditLog(
      action: 'GLOBAL_MODULE_TOGGLED',
      details: 'Module [$moduleKey] set to ${isEnabled ? "ENABLED" : "DISABLED"}',
      userEmail: adminEmail,
    );
  }

  /// Master Admin API: Toggle Global Sub-Feature Status
  Future<void> toggleGlobalFeature({
    required String featureKey,
    required bool isEnabled,
    required String adminEmail,
  }) async {
    final docRef = _firestore.collection('platform_feature_settings').doc('global');
    await docRef.set({
      'featureToggles': {
        featureKey: isEnabled,
      },
      'updatedBy': adminEmail,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await _recordAuditLog(
      action: 'GLOBAL_FEATURE_TOGGLED',
      details: 'Feature [$featureKey] set to ${isEnabled ? "ENABLED" : "DISABLED"}',
      userEmail: adminEmail,
    );
  }

  /// Master Admin API: Toggle Society-Specific Feature Status
  Future<void> toggleSocietyFeature({
    required String societyId,
    required String featureKey,
    required bool isEnabled,
    required String adminEmail,
  }) async {
    final docRef = _firestore
        .collection('somitis')
        .doc(societyId)
        .collection('society_feature_settings')
        .doc('settings');

    await docRef.set({
      'featureToggles': {
        featureKey: isEnabled,
      },
      'updatedBy': adminEmail,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await _recordAuditLog(
      action: 'SOCIETY_FEATURE_TOGGLED',
      details: 'Society [$societyId] feature [$featureKey] set to ${isEnabled ? "ENABLED" : "DISABLED"}',
      userEmail: adminEmail,
      societyId: societyId,
    );
  }

  /// Record an immutable audit log
  Future<void> _recordAuditLog({
    required String action,
    required String details,
    required String userEmail,
    String? societyId,
  }) async {
    try {
      await _firestore.collection('audit_logs').add({
        'action': action,
        'details': details,
        'userEmail': userEmail,
        'societyId': societyId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Audit log write error: $e');
    }
  }

  void dispose() {
    _globalSub?.cancel();
    for (final s in _societySubs.values) {
      s.cancel();
    }
    _societySubs.clear();
  }
}
