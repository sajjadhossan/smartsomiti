// lib/models/offline_field_model.dart
// Enterprise Offline-First Architecture, Field Operations & Mobile Experience Models
// Strict multi-tenant data isolation, integer Poisha arithmetic, and resilient synchronization

import 'dart:convert';

/// Connectivity and Synchronization States
enum ConnectivityState {
  online,
  offline,
  connecting,
  syncing,
  syncPending,
  syncFailed,
  syncConflict,
  partiallySynced;

  String get labelBn {
    switch (this) {
      case ConnectivityState.online: return '🟢 অনলাইন (সরাসরি সংযোগ)';
      case ConnectivityState.offline: return '🔴 অফলাইন (লোকাল মোড)';
      case ConnectivityState.connecting: return '🟡 নেটওয়ার্ক সন্ধানরত...';
      case ConnectivityState.syncing: return '🔄 সিঙ্ক হচ্ছে...';
      case ConnectivityState.syncPending: return '⏳ সিঙ্ক অপেক্ষমান';
      case ConnectivityState.syncFailed: return '⚠️ সিঙ্ক ব্যর্থ (পুনঃচেষ্টা)';
      case ConnectivityState.syncConflict: return '❗ সিঙ্ক কনফ্লিক্ট (রিভিউ)';
      case ConnectivityState.partiallySynced: return '🟨 আংশিক সম্পন্ন';
    }
  }

  static ConnectivityState fromString(String val) {
    return ConnectivityState.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => ConnectivityState.online,
    );
  }
}

/// Persistent Sync Queue Lifecycle States
enum SyncQueueStatus {
  pending,
  processing,
  synced,
  failed,
  conflict,
  requiresReview,
  cancelled;

  String get labelBn {
    switch (this) {
      case SyncQueueStatus.pending: return 'অপেক্ষমান (Pending)';
      case SyncQueueStatus.processing: return 'প্রক্রিয়াধীন (Processing)';
      case SyncQueueStatus.synced: return 'সম্পন্ন (Synced)';
      case SyncQueueStatus.failed: return 'ব্যর্থ (Failed)';
      case SyncQueueStatus.conflict: return 'কনফ্লিক্ট (Conflict)';
      case SyncQueueStatus.requiresReview: return 'পর্যালোচনা আবশ্যক';
      case SyncQueueStatus.cancelled: return 'বাতিলকৃত (Cancelled)';
    }
  }

  static SyncQueueStatus fromString(String val) {
    return SyncQueueStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => SyncQueueStatus.pending,
    );
  }
}

/// Persistent Sync Queue Item Model
class SyncQueueItemModel {
  final String operationId;
  final String societyId;
  final String userId;
  final String deviceId;
  final String operationType; // 'FIELD_COLLECTION', 'PROFILE_NOTE', 'DOCUMENT_UPLOAD'
  final Map<String, dynamic> payload;
  final SyncQueueStatus status;
  final int retryCount;
  final String? errorDetails;
  final DateTime createdAt;
  final DateTime? lastAttemptAt;
  final DateTime? syncedAt;

  const SyncQueueItemModel({
    required this.operationId,
    required this.societyId,
    required this.userId,
    required this.deviceId,
    required this.operationType,
    required this.payload,
    this.status = SyncQueueStatus.pending,
    this.retryCount = 0,
    this.errorDetails,
    required this.createdAt,
    this.lastAttemptAt,
    this.syncedAt,
  });

  Map<String, dynamic> toMap() => {
    'operationId': operationId,
    'societyId': societyId,
    'userId': userId,
    'deviceId': deviceId,
    'operationType': operationType,
    'payload': payload,
    'status': status.name,
    'retryCount': retryCount,
    'errorDetails': errorDetails,
    'createdAt': createdAt.toIso8601String(),
    'lastAttemptAt': lastAttemptAt?.toIso8601String(),
    'syncedAt': syncedAt?.toIso8601String(),
  };

  factory SyncQueueItemModel.fromMap(Map<String, dynamic> map, String id) {
    return SyncQueueItemModel(
      operationId: id,
      societyId: map['societyId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      deviceId: map['deviceId'] as String? ?? '',
      operationType: map['operationType'] as String? ?? 'FIELD_COLLECTION',
      payload: (map['payload'] as Map<String, dynamic>?) ?? {},
      status: SyncQueueStatus.fromString(map['status'] as String? ?? 'pending'),
      retryCount: (map['retryCount'] as num?)?.toInt() ?? 0,
      errorDetails: map['errorDetails'] as String?,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
      lastAttemptAt: map['lastAttemptAt'] != null ? DateTime.tryParse(map['lastAttemptAt'] as String) : null,
      syncedAt: map['syncedAt'] != null ? DateTime.tryParse(map['syncedAt'] as String) : null,
    );
  }
}

/// Locally Cached Member Record for Offline Field Navigation
class OfflineMemberCacheModel {
  final String memberId;
  final String societyId;
  final String assignedOfficerId;
  final String fullName;
  final String phone;
  final String village;
  final int savingsBalancePoisha;
  final String? activeLoanId;
  final int installmentDuePoisha;
  final int overdueDays;
  final DateTime lastCachedAt;

  const OfflineMemberCacheModel({
    required this.memberId,
    required this.societyId,
    required this.assignedOfficerId,
    required this.fullName,
    required this.phone,
    required this.village,
    required this.savingsBalancePoisha,
    this.activeLoanId,
    this.installmentDuePoisha = 0,
    this.overdueDays = 0,
    required this.lastCachedAt,
  });

  double get savingsBalanceBdt => savingsBalancePoisha / 100.0;
  double get installmentDueBdt => installmentDuePoisha / 100.0;

  Map<String, dynamic> toMap() => {
    'memberId': memberId,
    'societyId': societyId,
    'assignedOfficerId': assignedOfficerId,
    'fullName': fullName,
    'phone': phone,
    'village': village,
    'savingsBalancePoisha': savingsBalancePoisha,
    'activeLoanId': activeLoanId,
    'installmentDuePoisha': installmentDuePoisha,
    'overdueDays': overdueDays,
    'lastCachedAt': lastCachedAt.toIso8601String(),
  };

  factory OfflineMemberCacheModel.fromMap(Map<String, dynamic> map, String id) {
    return OfflineMemberCacheModel(
      memberId: id,
      societyId: map['societyId'] as String? ?? '',
      assignedOfficerId: map['assignedOfficerId'] as String? ?? '',
      fullName: map['fullName'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      village: map['village'] as String? ?? '',
      savingsBalancePoisha: (map['savingsBalancePoisha'] as num?)?.toInt() ?? 0,
      activeLoanId: map['activeLoanId'] as String?,
      installmentDuePoisha: (map['installmentDuePoisha'] as num?)?.toInt() ?? 0,
      overdueDays: (map['overdueDays'] as num?)?.toInt() ?? 0,
      lastCachedAt: DateTime.tryParse(map['lastCachedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

/// Provisional Offline Receipt Model (Strict Server Verification Warning)
class ProvisionalReceiptModel {
  final String receiptNumber; // e.g. PROV-REC-2026-8801
  final String operationId;
  final String memberId;
  final String memberName;
  final String societyId;
  final String collectorId;
  final String collectorName;
  final String purpose;
  final int amountPoisha;
  final bool isServerConfirmed;
  final String provisionalNoticeBn;
  final DateTime collectedAt;
  final double? gpsLat;
  final double? gpsLng;

  const ProvisionalReceiptModel({
    required this.receiptNumber,
    required this.operationId,
    required this.memberId,
    required this.memberName,
    required this.societyId,
    required this.collectorId,
    required this.collectorName,
    required this.purpose,
    required this.amountPoisha,
    this.isServerConfirmed = false,
    this.provisionalNoticeBn = '*** সাময়িক রসিদ (অনলাইন সার্ভার যাচাই অপেক্ষমান) ***',
    required this.collectedAt,
    this.gpsLat,
    this.gpsLng,
  });

  double get amountBdt => amountPoisha / 100.0;

  Map<String, dynamic> toMap() => {
    'receiptNumber': receiptNumber,
    'operationId': operationId,
    'memberId': memberId,
    'memberName': memberName,
    'societyId': societyId,
    'collectorId': collectorId,
    'collectorName': collectorName,
    'purpose': purpose,
    'amountPoisha': amountPoisha,
    'isServerConfirmed': isServerConfirmed,
    'provisionalNoticeBn': provisionalNoticeBn,
    'collectedAt': collectedAt.toIso8601String(),
    'gpsLat': gpsLat,
    'gpsLng': gpsLng,
  };

  factory ProvisionalReceiptModel.fromMap(Map<String, dynamic> map, String id) {
    return ProvisionalReceiptModel(
      receiptNumber: id,
      operationId: map['operationId'] as String? ?? '',
      memberId: map['memberId'] as String? ?? '',
      memberName: map['memberName'] as String? ?? '',
      societyId: map['societyId'] as String? ?? '',
      collectorId: map['collectorId'] as String? ?? '',
      collectorName: map['collectorName'] as String? ?? '',
      purpose: map['purpose'] as String? ?? '',
      amountPoisha: (map['amountPoisha'] as num?)?.toInt() ?? 0,
      isServerConfirmed: map['isServerConfirmed'] as bool? ?? false,
      provisionalNoticeBn: map['provisionalNoticeBn'] as String? ?? '*** সাময়িক রসিদ (অনলাইন সার্ভার যাচাই অপেক্ষমান) ***',
      collectedAt: DateTime.tryParse(map['collectedAt'] as String? ?? '') ?? DateTime.now(),
      gpsLat: (map['gpsLat'] as num?)?.toDouble(),
      gpsLng: (map['gpsLng'] as num?)?.toDouble(),
    );
  }
}

/// Field Officer Daily Cash Reconciliation Batch
class FieldCashReconciliationModel {
  final String reconciliationId;
  final String societyId;
  final String officerId;
  final String officerName;
  final DateTime shiftDate;
  final int openingFloatPoisha;
  final int totalCollectedPoisha;
  final int physicalCashSubmittedPoisha;
  final int discrepancyPoisha; // positive = excess, negative = shortage
  final String status; // 'draft', 'submitted', 'underReview', 'approved', 'rejected'
  final String? verifiedByCashierId;
  final DateTime submittedAt;
  final DateTime? verifiedAt;
  final String? discrepancyNotes;

  const FieldCashReconciliationModel({
    required this.reconciliationId,
    required this.societyId,
    required this.officerId,
    required this.officerName,
    required this.shiftDate,
    this.openingFloatPoisha = 0,
    required this.totalCollectedPoisha,
    required this.physicalCashSubmittedPoisha,
    this.discrepancyPoisha = 0,
    this.status = 'submitted',
    this.verifiedByCashierId,
    required this.submittedAt,
    this.verifiedAt,
    this.discrepancyNotes,
  });

  double get openingFloatBdt => openingFloatPoisha / 100.0;
  double get totalCollectedBdt => totalCollectedPoisha / 100.0;
  double get physicalCashSubmittedBdt => physicalCashSubmittedPoisha / 100.0;
  double get discrepancyBdt => discrepancyPoisha / 100.0;
  bool get isBalanced => discrepancyPoisha == 0;

  Map<String, dynamic> toMap() => {
    'reconciliationId': reconciliationId,
    'societyId': societyId,
    'officerId': officerId,
    'officerName': officerName,
    'shiftDate': shiftDate.toIso8601String(),
    'openingFloatPoisha': openingFloatPoisha,
    'totalCollectedPoisha': totalCollectedPoisha,
    'physicalCashSubmittedPoisha': physicalCashSubmittedPoisha,
    'discrepancyPoisha': discrepancyPoisha,
    'status': status,
    'verifiedByCashierId': verifiedByCashierId,
    'submittedAt': submittedAt.toIso8601String(),
    'verifiedAt': verifiedAt?.toIso8601String(),
    'discrepancyNotes': discrepancyNotes,
  };

  factory FieldCashReconciliationModel.fromMap(Map<String, dynamic> map, String id) {
    return FieldCashReconciliationModel(
      reconciliationId: id,
      societyId: map['societyId'] as String? ?? '',
      officerId: map['officerId'] as String? ?? '',
      officerName: map['officerName'] as String? ?? '',
      shiftDate: DateTime.tryParse(map['shiftDate'] as String? ?? '') ?? DateTime.now(),
      openingFloatPoisha: (map['openingFloatPoisha'] as num?)?.toInt() ?? 0,
      totalCollectedPoisha: (map['totalCollectedPoisha'] as num?)?.toInt() ?? 0,
      physicalCashSubmittedPoisha: (map['physicalCashSubmittedPoisha'] as num?)?.toInt() ?? 0,
      discrepancyPoisha: (map['discrepancyPoisha'] as num?)?.toInt() ?? 0,
      status: map['status'] as String? ?? 'submitted',
      verifiedByCashierId: map['verifiedByCashierId'] as String?,
      submittedAt: DateTime.tryParse(map['submittedAt'] as String? ?? '') ?? DateTime.now(),
      verifiedAt: map['verifiedAt'] != null ? DateTime.tryParse(map['verifiedAt'] as String) : null,
      discrepancyNotes: map['discrepancyNotes'] as String?,
    );
  }
}

/// Collection Route Waypoint Model
class CollectionRoutePointModel {
  final String pointId;
  final String routeId;
  final String societyId;
  final String memberId;
  final String memberName;
  final String address;
  final int expectedAmountPoisha;
  final int sequenceOrder;
  final String visitStatus; // 'scheduled', 'visitedCollected', 'absentFollowup', 'missed'
  final DateTime? visitedAt;
  final double? gpsLat;
  final double? gpsLng;

  const CollectionRoutePointModel({
    required this.pointId,
    required this.routeId,
    required this.societyId,
    required this.memberId,
    required this.memberName,
    required this.address,
    required this.expectedAmountPoisha,
    required this.sequenceOrder,
    this.visitStatus = 'scheduled',
    this.visitedAt,
    this.gpsLat,
    this.gpsLng,
  });

  double get expectedAmountBdt => expectedAmountPoisha / 100.0;

  Map<String, dynamic> toMap() => {
    'pointId': pointId,
    'routeId': routeId,
    'societyId': societyId,
    'memberId': memberId,
    'memberName': memberName,
    'address': address,
    'expectedAmountPoisha': expectedAmountPoisha,
    'sequenceOrder': sequenceOrder,
    'visitStatus': visitStatus,
    'visitedAt': visitedAt?.toIso8601String(),
    'gpsLat': gpsLat,
    'gpsLng': gpsLng,
  };

  factory CollectionRoutePointModel.fromMap(Map<String, dynamic> map, String id) {
    return CollectionRoutePointModel(
      pointId: id,
      routeId: map['routeId'] as String? ?? '',
      societyId: map['societyId'] as String? ?? '',
      memberId: map['memberId'] as String? ?? '',
      memberName: map['memberName'] as String? ?? '',
      address: map['address'] as String? ?? '',
      expectedAmountPoisha: (map['expectedAmountPoisha'] as num?)?.toInt() ?? 0,
      sequenceOrder: (map['sequenceOrder'] as num?)?.toInt() ?? 1,
      visitStatus: map['visitStatus'] as String? ?? 'scheduled',
      visitedAt: map['visitedAt'] != null ? DateTime.tryParse(map['visitedAt'] as String) : null,
      gpsLat: (map['gpsLat'] as num?)?.toDouble(),
      gpsLng: (map['gpsLng'] as num?)?.toDouble(),
    );
  }
}

/// Authorized Device Registration Model
class RegisteredDeviceModel {
  final String deviceId;
  final String societyId;
  final String assignedOfficerId;
  final String officerName;
  final String deviceName;
  final String status; // 'pendingApproval', 'active', 'suspended', 'revoked'
  final DateTime lastSyncAt;
  final DateTime registeredAt;
  final String appVersion;

  const RegisteredDeviceModel({
    required this.deviceId,
    required this.societyId,
    required this.assignedOfficerId,
    required this.officerName,
    required this.deviceName,
    this.status = 'active',
    required this.lastSyncAt,
    required this.registeredAt,
    this.appVersion = '2.4.0',
  });

  bool get isActive => status == 'active';

  Map<String, dynamic> toMap() => {
    'deviceId': deviceId,
    'societyId': societyId,
    'assignedOfficerId': assignedOfficerId,
    'officerName': officerName,
    'deviceName': deviceName,
    'status': status,
    'lastSyncAt': lastSyncAt.toIso8601String(),
    'registeredAt': registeredAt.toIso8601String(),
    'appVersion': appVersion,
  };

  factory RegisteredDeviceModel.fromMap(Map<String, dynamic> map, String id) {
    return RegisteredDeviceModel(
      deviceId: id,
      societyId: map['societyId'] as String? ?? '',
      assignedOfficerId: map['assignedOfficerId'] as String? ?? '',
      officerName: map['officerName'] as String? ?? '',
      deviceName: map['deviceName'] as String? ?? '',
      status: map['status'] as String? ?? 'active',
      lastSyncAt: DateTime.tryParse(map['lastSyncAt'] as String? ?? '') ?? DateTime.now(),
      registeredAt: DateTime.tryParse(map['registeredAt'] as String? ?? '') ?? DateTime.now(),
      appVersion: map['appVersion'] as String? ?? '2.4.0',
    );
  }
}
