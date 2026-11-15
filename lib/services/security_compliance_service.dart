import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/role_permission_model.dart';
import '../models/security_compliance_model.dart';

class SecurityComplianceService {
  static final SecurityComplianceService _instance = SecurityComplianceService._internal();
  factory SecurityComplianceService() => _instance;
  SecurityComplianceService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Master Admin Email constant
  static const String masterAdminEmail = 'hossansajjad1994@gmail.com';

  // In-Memory Policy & Permission Cache
  SecurityPolicyModel _policy = const SecurityPolicyModel();
  final Map<String, bool> _globalPermissions = {};
  final Map<String, Map<String, bool>> _societyPermissions = {};
  final Map<String, Map<String, bool>> _userOverrides = {};

  // Session & Brute-Force Tracking Cache
  final Map<String, UserSessionModel> _activeSessions = {};
  final Map<String, int> _failedLoginAttempts = {};
  final Map<String, DateTime> _lockedUntil = {};

  // Cryptographic Audit Hash Head
  String _latestAuditHash = 'GENESIS_SOMITI_SECURITY_CHAIN_2026';

  // Alert Notifications
  final List<SecurityAlertModel> _alerts = [];
  final StreamController<List<SecurityAlertModel>> _alertsController = StreamController<List<SecurityAlertModel>>.broadcast();

  Stream<List<SecurityAlertModel>> get alertsStream => _alertsController.stream;
  List<SecurityAlertModel> get currentAlerts => List.unmodifiable(_alerts);
  SecurityPolicyModel get currentPolicy => _policy;

  bool isMasterAdmin(String? email) {
    if (email == null) return false;
    return email.trim().toLowerCase() == masterAdminEmail;
  }

  // =========================================================================
  // 1. DETERMINISTIC 6-TIER AUTHORIZATION ENGINE
  // =========================================================================
  bool isActionPermitted({
    required String permissionKey,
    String? societyId,
    String? userEmail,
    UserRole? role,
    Map<String, bool>? userOverrides,
  }) {
    // TIER 1: Non-bypassable Platform Security Baseline
    // Master Admin always has access to administrative and audit oversight
    if (isMasterAdmin(userEmail)) {
      return true;
    }

    // TIER 2: Master Admin Global Permission Switchboard
    if (_globalPermissions.containsKey(permissionKey) && _globalPermissions[permissionKey] == false) {
      return false; // Globally turned OFF by Master Admin
    }

    // TIER 3: Society-Level Policy Override
    if (societyId != null && _societyPermissions.containsKey(societyId)) {
      final socPerms = _societyPermissions[societyId]!;
      if (socPerms.containsKey(permissionKey) && socPerms[permissionKey] == false) {
        return false; // Turned OFF for this specific society
      }
    }

    // TIER 4 & 5: Role-Based Preset Permissions (RBAC)
    final effectiveRole = role ?? UserRole.member;
    bool roleGranted = false;

    if (effectiveRole == UserRole.superAdmin || effectiveRole == UserRole.societyOwner) {
      roleGranted = true;
    } else {
      // Check role capability mappings
      final rolePreset = AppPermissions.getPreset(effectiveRole);
      roleGranted = _isPermissionInRolePreset(permissionKey, rolePreset);
    }

    // TIER 6: User-Specific Granular Overrides (ABAC)
    if (userOverrides != null && userOverrides.containsKey(permissionKey)) {
      return userOverrides[permissionKey]!;
    }
    if (userEmail != null && _userOverrides.containsKey(userEmail)) {
      final userSpecific = _userOverrides[userEmail]!;
      if (userSpecific.containsKey(permissionKey)) {
        return userSpecific[permissionKey]!;
      }
    }

    return roleGranted;
  }

  bool _isPermissionInRolePreset(String permKey, Set<String> preset) {
    // Map granular keys to domain presets
    if (permKey.startsWith('members.') && preset.contains(AppPermissions.memberView)) return true;
    if (permKey == SecurityPermissions.membersCreate && preset.contains(AppPermissions.memberCreate)) return true;
    if (permKey == SecurityPermissions.membersUpdate && preset.contains(AppPermissions.memberEdit)) return true;
    if (permKey == SecurityPermissions.membersDelete && preset.contains(AppPermissions.memberDelete)) return true;

    if (permKey.startsWith('savings.') && preset.contains(AppPermissions.savingsView)) return true;
    if (permKey == SecurityPermissions.savingsDeposit && preset.contains(AppPermissions.savingsDeposit)) return true;
    if (permKey == SecurityPermissions.savingsWithdraw && preset.contains(AppPermissions.savingsWithdraw)) return true;
    if (permKey == SecurityPermissions.savingsApproveWithdrawal && preset.contains(AppPermissions.savingsWithdraw)) return true;

    if (permKey.startsWith('loans.') && preset.contains(AppPermissions.loanView)) return true;
    if (permKey == SecurityPermissions.loansCreate && preset.contains(AppPermissions.loanApply)) return true;
    if (permKey == SecurityPermissions.loansApprove && preset.contains(AppPermissions.loanApprove)) return true;
    if (permKey == SecurityPermissions.loansDisburse && preset.contains(AppPermissions.loanDisburse)) return true;
    if (permKey == SecurityPermissions.loansRepay && preset.contains(AppPermissions.loanRepay)) return true;

    if (permKey.startsWith('accounting.') && preset.contains(AppPermissions.accountView)) return true;
    if (permKey == SecurityPermissions.accountingCreateJournal && preset.contains(AppPermissions.expenseRecord)) return true;
    if (permKey == SecurityPermissions.accountingPostJournal && preset.contains(AppPermissions.fundTransfer)) return true;

    return false;
  }

  void setGlobalPermissionToggle(String permissionKey, bool isEnabled, String updatedByUid) {
    _globalPermissions[permissionKey] = isEnabled;
    logAuditEvent(
      actorUid: updatedByUid,
      actorEmail: updatedByUid,
      actorRole: 'masterAdmin',
      societyId: 'global',
      actionType: 'permission_toggle',
      resourceType: 'permission',
      resourceId: permissionKey,
      detailsBn: 'সার্বজনীন পারমিশন "$permissionKey" ${isEnabled ? "সক্রিয়" : "নিষ্ক্রিয়"} করা হয়েছে।',
    );
  }

  // =========================================================================
  // 2. ACTIVE SESSION & DEVICE MANAGEMENT
  // =========================================================================
  UserSessionModel registerSession({
    required String userId,
    required String userEmail,
    required String societyId,
    required String deviceName,
    required String ipAddress,
  }) {
    final now = DateTime.now();
    final sessionId = 'sess_${now.millisecondsSinceEpoch}_${_activeSessions.length + 1}';
    final session = UserSessionModel(
      sessionId: sessionId,
      userId: userId,
      userEmail: userEmail,
      societyId: societyId,
      deviceName: deviceName,
      ipAddress: ipAddress,
      loginAt: now,
      lastActiveAt: now,
      expiresAt: now.add(Duration(minutes: _policy.sessionTimeoutMinutes)),
      isRevoked: false,
    );

    _activeSessions[sessionId] = session;
    return session;
  }

  bool isSessionValid(String sessionId) {
    final session = _activeSessions[sessionId];
    if (session == null) return false;
    return session.isValid;
  }

  void revokeSession(String sessionId, String revokedByUid, String reason) {
    final session = _activeSessions[sessionId];
    if (session != null) {
      _activeSessions[sessionId] = session.copyWith(
        isRevoked: true,
        revokedBy: revokedByUid,
        revocationReason: reason,
      );

      logAuditEvent(
        actorUid: revokedByUid,
        actorEmail: revokedByUid,
        actorRole: 'admin',
        societyId: session.societyId,
        actionType: 'session_revoke',
        resourceType: 'session',
        resourceId: sessionId,
        detailsBn: 'ডিভাইস সেশন ($sessionId) তাৎক্ষণিক বাতিল করা হয়েছে। কারণ: $reason',
      );
    }
  }

  void revokeAllUserSessions(String userId, String revokedByUid) {
    for (final entry in _activeSessions.entries) {
      if (entry.value.userId == userId && !entry.value.isRevoked) {
        revokeSession(entry.key, revokedByUid, 'প্রশাসনিক নির্দেশে সকল সেশন প্রত্যাহার');
      }
    }
  }

  // =========================================================================
  // 3. BRUTE-FORCE THROTTLING & SECURITY ANOMALY WATCHDOG
  // =========================================================================
  bool isAccountLocked(String email) {
    final lockExpiry = _lockedUntil[email.toLowerCase()];
    if (lockExpiry == null) return false;
    if (DateTime.now().isAfter(lockExpiry)) {
      _lockedUntil.remove(email.toLowerCase());
      _failedLoginAttempts.remove(email.toLowerCase());
      return false;
    }
    return true;
  }

  void recordLoginAttempt({
    required String email,
    required bool isSuccess,
    required String ipAddress,
    String societyId = 'global',
  }) {
    final key = email.toLowerCase();
    if (isSuccess) {
      _failedLoginAttempts.remove(key);
      _lockedUntil.remove(key);
    } else {
      final current = (_failedLoginAttempts[key] ?? 0) + 1;
      _failedLoginAttempts[key] = current;

      if (current >= _policy.maxFailedLoginAttempts) {
        final lockExpiry = DateTime.now().add(Duration(minutes: _policy.lockoutDurationMinutes));
        _lockedUntil[key] = lockExpiry;

        triggerSecurityAlert(
          category: 'brute_force_attack',
          severity: SecurityAlertSeverity.high,
          affectedUid: email,
          affectedSocietyId: societyId,
          messageBn: 'অ্যাকাউন্টে ক্রমাগত $current বার ভুল পাসওয়ার্ড দিয়ে প্রবেশের চেষ্টা করায় ৩০ মিনিটের জন্য অ্যাকাউন্ট সাময়িক লক করা হয়েছে (আইপি: $ipAddress)।',
        );
      }
    }
  }

  void triggerSecurityAlert({
    required String category,
    required SecurityAlertSeverity severity,
    required String affectedUid,
    required String affectedSocietyId,
    required String messageBn,
  }) {
    final alert = SecurityAlertModel(
      alertId: 'alt_${DateTime.now().millisecondsSinceEpoch}_${_alerts.length + 1}',
      timestamp: DateTime.now(),
      severity: severity,
      category: category,
      affectedUid: affectedUid,
      affectedSocietyId: affectedSocietyId,
      messageBn: messageBn,
    );
    _alerts.insert(0, alert);
    _alertsController.add(List.unmodifiable(_alerts));
  }

  // =========================================================================
  // 4. CRYPTOGRAPHICALLY HASH-CHAINED IMMUTABLE AUDIT LOGGING
  // =========================================================================
  SecurityAuditRecordModel logAuditEvent({
    required String actorUid,
    required String actorEmail,
    required String actorRole,
    required String societyId,
    required String actionType,
    required String resourceType,
    required String resourceId,
    required String detailsBn,
  }) {
    final now = DateTime.now();
    final logId = 'audit_${now.millisecondsSinceEpoch}_${now.microsecond}';
    final previousHash = _latestAuditHash;

    final currentHash = SecurityAuditRecordModel.calculateHash(
      id: logId,
      timestamp: now,
      actorUid: actorUid,
      actionType: actionType,
      resourceId: resourceId,
      previousHash: previousHash,
    );

    final record = SecurityAuditRecordModel(
      id: logId,
      timestamp: now,
      actorUid: actorUid,
      actorEmail: actorEmail,
      actorRole: actorRole,
      societyId: societyId,
      actionType: actionType,
      resourceType: resourceType,
      resourceId: resourceId,
      detailsBn: detailsBn,
      previousHash: previousHash,
      currentHash: currentHash,
    );

    _latestAuditHash = currentHash; // Advance chain head
    return record;
  }

  bool verifyAuditLogChain(List<SecurityAuditRecordModel> logs) {
    if (logs.isEmpty) return true;
    for (int i = 0; i < logs.length; i++) {
      final current = logs[i];
      if (!current.verifyIntegrity()) {
        return false; // Record tampered
      }
      if (i > 0) {
        final previous = logs[i - 1];
        if (current.previousHash != previous.currentHash) {
          return false; // Broken link in hash chain
        }
      }
    }
    return true;
  }
}
