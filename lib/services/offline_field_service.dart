// lib/services/offline_field_service.dart
// Enterprise Offline-First Architecture, Field Operations & Mobile Experience Service
// Supporting Resilient Local Queue, Deterministic Idempotency, Provisional Receipts,
// Conflict Detection, Maker-Checker Cash Reconciliation, and Device Fleet Governance

import 'dart:convert';
import 'dart:math';
import '../models/offline_field_model.dart';

class OfflineFieldService {
  static final OfflineFieldService _instance = OfflineFieldService._internal();
  factory OfflineFieldService() => _instance;
  OfflineFieldService._internal() {
    _initializeDefaults();
  }

  // Super Admin Governance Configurations
  bool _isGlobalOfflineEnabled = true;
  bool _isGpsLocationRequired = true;
  int _maxOfflineCacheHours = 48;

  // Connectivity State Machine
  ConnectivityState _connectivityState = ConnectivityState.online;

  // In-Memory Persistent Stores
  final Map<String, OfflineMemberCacheModel> _membersCache = {};
  final Map<String, SyncQueueItemModel> _syncQueue = {};
  final Map<String, ProvisionalReceiptModel> _provisionalReceipts = {};
  final Map<String, FieldCashReconciliationModel> _cashReconciliations = {};
  final Map<String, CollectionRoutePointModel> _routePoints = {};
  final Map<String, RegisteredDeviceModel> _registeredDevices = {};

  void _initializeDefaults() {
    final now = DateTime.now();

    // 1. Registered Field Devices
    final defaultDevices = [
      RegisteredDeviceModel(
        deviceId: 'dev_tab_mirpur_01',
        societyId: 'swapno_chowa_main',
        assignedOfficerId: 'emp_field_01',
        officerName: 'অফিসার মোঃ রফিকুল ইসলাম',
        deviceName: 'Samsung Galaxy Tab A9+ (Fleet-01)',
        status: 'active',
        lastSyncAt: now.subtract(const Duration(minutes: 15)),
        registeredAt: now.subtract(const Duration(days: 30)),
        appVersion: '2.4.0',
      ),
      RegisteredDeviceModel(
        deviceId: 'dev_phone_mirpur_02',
        societyId: 'swapno_chowa_main',
        assignedOfficerId: 'emp_field_02',
        officerName: 'অফিসার তানভীর আহমেদ',
        deviceName: 'Xiaomi Redmi Note 13 (Fleet-02)',
        status: 'active',
        lastSyncAt: now.subtract(const Duration(hours: 2)),
        registeredAt: now.subtract(const Duration(days: 20)),
        appVersion: '2.4.0',
      ),
    ];

    for (final d in defaultDevices) {
      _registeredDevices[d.deviceId] = d;
    }

    // 2. Offline Cached Members
    final defaultMembers = [
      OfflineMemberCacheModel(
        memberId: 'mem_001',
        societyId: 'swapno_chowa_main',
        assignedOfficerId: 'emp_field_01',
        fullName: 'মোঃ রফিকুল ইসলাম',
        phone: '01711223344',
        village: 'মিরপুর-১০, রোড-২',
        savingsBalancePoisha: 2450000, // ৳২৪,৫০০.০০
        activeLoanId: 'loan_micro_101',
        installmentDuePoisha: 150000, // ৳১,৫০০.০০
        overdueDays: 0,
        lastCachedAt: now.subtract(const Duration(hours: 1)),
      ),
      OfflineMemberCacheModel(
        memberId: 'mem_002',
        societyId: 'swapno_chowa_main',
        assignedOfficerId: 'emp_field_01',
        fullName: 'মোসাঃ মরিয়ম বেগম',
        phone: '01822334455',
        village: 'মিরপুর-১০, ব্লক-সি',
        savingsBalancePoisha: 1820000, // ৳১৮,২০০.০০
        activeLoanId: 'loan_micro_102',
        installmentDuePoisha: 200000, // ৳২,০০০.০০
        overdueDays: 14,
        lastCachedAt: now.subtract(const Duration(hours: 1)),
      ),
      OfflineMemberCacheModel(
        memberId: 'mem_003',
        societyId: 'swapno_chowa_main',
        assignedOfficerId: 'emp_field_01',
        fullName: 'আব্দুল করিম',
        phone: '01933445566',
        village: 'মিরপুর-১০, বাজার লেন',
        savingsBalancePoisha: 3100000, // ৳৩১,০০০.০০
        activeLoanId: null,
        installmentDuePoisha: 0,
        overdueDays: 0,
        lastCachedAt: now.subtract(const Duration(hours: 1)),
      ),
    ];

    for (final m in defaultMembers) {
      _membersCache[m.memberId] = m;
    }

    // 3. Collection Route Points
    final defaultRoute = [
      const CollectionRoutePointModel(
        pointId: 'point_rt_01',
        routeId: 'route_mirpur_morning',
        societyId: 'swapno_chowa_main',
        memberId: 'mem_001',
        memberName: 'মোঃ রফিকুল ইসলাম',
        address: 'বাড়ি নং-১২, লেন-২, মিরপুর-১০',
        expectedAmountPoisha: 150000, // ৳১,৫০০.০০
        sequenceOrder: 1,
        visitStatus: 'visitedCollected',
        gpsLat: 23.8041,
        gpsLng: 90.3667,
      ),
      const CollectionRoutePointModel(
        pointId: 'point_rt_02',
        routeId: 'route_mirpur_morning',
        societyId: 'swapno_chowa_main',
        memberId: 'mem_002',
        memberName: 'মোসাঃ মরিয়ম বেগম',
        address: 'দোকান নং-৪, ব্লক-সি, মিরপুর-১০',
        expectedAmountPoisha: 200000, // ৳২,০০০.০০
        sequenceOrder: 2,
        visitStatus: 'scheduled',
        gpsLat: 23.8055,
        gpsLng: 90.3680,
      ),
      const CollectionRoutePointModel(
        pointId: 'point_rt_03',
        routeId: 'route_mirpur_morning',
        societyId: 'swapno_chowa_main',
        memberId: 'mem_003',
        memberName: 'আব্দুল করিম',
        address: 'বাজার সংলগ্ন, মিরপুর-১০',
        expectedAmountPoisha: 100000, // ৳১,০০০.০০
        sequenceOrder: 3,
        visitStatus: 'scheduled',
        gpsLat: 23.8068,
        gpsLng: 90.3695,
      ),
    ];

    for (final p in defaultRoute) {
      _routePoints[p.pointId] = p;
    }

    // 4. Sample Cash Reconciliation
    final sampleRecon = FieldCashReconciliationModel(
      reconciliationId: 'recon_20261114_01',
      societyId: 'swapno_chowa_main',
      officerId: 'emp_field_01',
      officerName: 'অফিসার মোঃ রফিকুল ইসলাম',
      shiftDate: now,
      openingFloatPoisha: 200000, // ৳২,০০০.০০
      totalCollectedPoisha: 450000, // ৳৪,৫০০.০০
      physicalCashSubmittedPoisha: 650000, // ৳৬,৫০০.০০ (Opening Float + Collections)
      discrepancyPoisha: 0,
      status: 'submitted',
      submittedAt: now.subtract(const Duration(minutes: 30)),
    );
    _cashReconciliations[sampleRecon.reconciliationId] = sampleRecon;
  }

  // ==========================================
  // 1. SUPER ADMIN GOVERNANCE & CONFIGURATION
  // ==========================================

  bool get isGlobalOfflineEnabled => _isGlobalOfflineEnabled;
  bool get isGpsLocationRequired => _isGpsLocationRequired;
  int get maxOfflineCacheHours => _maxOfflineCacheHours;

  void setGlobalOfflineEnabled(bool enabled) {
    _isGlobalOfflineEnabled = enabled;
  }

  void setGpsLocationRequired(bool required) {
    _isGpsLocationRequired = required;
  }

  void setMaxOfflineCacheHours(int hours) {
    _maxOfflineCacheHours = hours;
  }

  // ==========================================
  // 2. CONNECTIVITY & STATE MACHINE
  // ==========================================

  ConnectivityState get connectivityState => _connectivityState;

  void setConnectivityState(ConnectivityState state) {
    _connectivityState = state;
  }

  // ==========================================
  // 3. OFFLINE CACHE & MEMBER LOOKUP
  // ==========================================

  List<OfflineMemberCacheModel> getAssignedMembers({String? societyId, String? officerId}) {
    return _membersCache.values.where((m) {
      if (societyId != null && m.societyId != societyId) return false;
      if (officerId != null && m.assignedOfficerId != officerId) return false;
      return true;
    }).toList();
  }

  OfflineMemberCacheModel? getMemberById(String memberId) {
    return _membersCache[memberId];
  }

  void cacheMember(OfflineMemberCacheModel member) {
    _membersCache[member.memberId] = member;
  }

  // ==========================================
  // 4. OFFLINE FIELD COLLECTION & IDEMPOTENCY
  // ==========================================

  Map<String, dynamic> recordOfflineCollection({
    required String societyId,
    required String officerId,
    required String officerName,
    required String memberId,
    required String memberName,
    required String purpose,
    required int amountPoisha,
    required String deviceId,
    double? gpsLat,
    double? gpsLng,
    String? clientOpId,
  }) {
    // 1. Super Admin Global Offline Policy Check
    if (!_isGlobalOfflineEnabled) {
      throw Exception('সুপার এডমিন দ্বারা প্ল্যাটফর্মের অফলাইন কালেকশন মোড সাময়িকভাবে নিষ্ক্রিয় রয়েছে!');
    }

    // 2. Device Fleet Authorization Check
    final device = _registeredDevices[deviceId];
    if (device == null || !device.isActive) {
      throw Exception('অননুমোদিত ডিভাইস: এই ডিভাইসে অফলাইন কালেকশন রেকর্ড করার অনুমতি নেই!');
    }

    // 3. Location Policy Check
    if (_isGpsLocationRequired && (gpsLat == null || gpsLng == null)) {
      throw Exception('লোকেশন পলিসি ত্রুটি: রসিদের সাথে জিপিএস লোকেশন স্থানাঙ্ক সংযুক্ত থাকা বাধ্যতামূলক!');
    }

    final opId = clientOpId ?? 'op_col_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999)}';

    // 4. Strict Idempotency & Replay Defense
    if (_syncQueue.containsKey(opId)) {
      final existingItem = _syncQueue[opId]!;
      final existingReceipt = _provisionalReceipts.values.firstWhere(
        (r) => r.operationId == opId,
        orElse: () => throw Exception('পূর্ববর্তী রসিদ তথ্য পাওয়া যায়নি!'),
      );
      return {
        'queueItem': existingItem,
        'provisionalReceipt': existingReceipt,
        'isReplay': true,
      };
    }

    // 5. Generate Provisional Receipt (Explicitly Unposted)
    final receiptNumber = 'PROV-REC-${DateTime.now().millisecondsSinceEpoch.toString().slice(-6)}';
    final provisionalReceipt = ProvisionalReceiptModel(
      receiptNumber: receiptNumber,
      operationId: opId,
      memberId: memberId,
      memberName: memberName,
      societyId: societyId,
      collectorId: officerId,
      collectorName: officerName,
      purpose: purpose,
      amountPoisha: amountPoisha,
      isServerConfirmed: false,
      provisionalNoticeBn: '*** সাময়িক রসিদ (অনলাইন সার্ভার যাচাই অপেক্ষমান) ***',
      collectedAt: DateTime.now(),
      gpsLat: gpsLat,
      gpsLng: gpsLng,
    );
    _provisionalReceipts[receiptNumber] = provisionalReceipt;

    // 6. Create Persistent Sync Queue Item
    final queueItem = SyncQueueItemModel(
      operationId: opId,
      societyId: societyId,
      userId: officerId,
      deviceId: deviceId,
      operationType: 'FIELD_COLLECTION',
      payload: {
        'memberId': memberId,
        'memberName': memberName,
        'purpose': purpose,
        'amountPoisha': amountPoisha,
        'provisionalReceiptNumber': receiptNumber,
        'gpsLat': gpsLat,
        'gpsLng': gpsLng,
      },
      status: SyncQueueStatus.pending,
      retryCount: 0,
      createdAt: DateTime.now(),
    );
    _syncQueue[opId] = queueItem;

    // Update Local Member Cache locally for UI responsiveness
    final cached = _membersCache[memberId];
    if (cached != null) {
      if (purpose == 'memberSavingsDeposit') {
        _membersCache[memberId] = OfflineMemberCacheModel(
          memberId: cached.memberId,
          societyId: cached.societyId,
          assignedOfficerId: cached.assignedOfficerId,
          fullName: cached.fullName,
          phone: cached.phone,
          village: cached.village,
          savingsBalancePoisha: cached.savingsBalancePoisha + amountPoisha,
          activeLoanId: cached.activeLoanId,
          installmentDuePoisha: cached.installmentDuePoisha,
          overdueDays: cached.overdueDays,
          lastCachedAt: DateTime.now(),
        );
      } else if (purpose == 'loanInstallmentRepayment') {
        final remainingDue = max(0, cached.installmentDuePoisha - amountPoisha);
        _membersCache[memberId] = OfflineMemberCacheModel(
          memberId: cached.memberId,
          societyId: cached.societyId,
          assignedOfficerId: cached.assignedOfficerId,
          fullName: cached.fullName,
          phone: cached.phone,
          village: cached.village,
          savingsBalancePoisha: cached.savingsBalancePoisha,
          activeLoanId: cached.activeLoanId,
          installmentDuePoisha: remainingDue,
          overdueDays: remainingDue == 0 ? 0 : cached.overdueDays,
          lastCachedAt: DateTime.now(),
        );
      }
    }

    return {
      'queueItem': queueItem,
      'provisionalReceipt': provisionalReceipt,
      'isReplay': false,
    };
  }

  // ==========================================
  // 5. SYNCHRONIZATION ENGINE & CONFLICT MANAGEMENT
  // ==========================================

  List<SyncQueueItemModel> getSyncQueue({String? societyId}) {
    return _syncQueue.values.where((item) {
      if (societyId != null && item.societyId != societyId) return false;
      return true;
    }).toList()..sort((a, b) => a.createdAt.compareTo(b.createdAt)); // Strict FIFO
  }

  List<ProvisionalReceiptModel> getProvisionalReceipts({String? societyId}) {
    return _provisionalReceipts.values.where((r) {
      if (societyId != null && r.societyId != societyId) return false;
      return true;
    }).toList()..sort((a, b) => b.collectedAt.compareTo(a.collectedAt));
  }

  Map<String, dynamic> triggerSyncBatch(String societyId) {
    if (_connectivityState == ConnectivityState.offline) {
      throw Exception('ডিভাইস বর্তমানে অফলাইনে রয়েছে! ইন্টারনেট সংযোগ নিশ্চিত করুন।');
    }

    _connectivityState = ConnectivityState.syncing;
    int syncedCount = 0;
    int conflictCount = 0;
    int failedCount = 0;

    final pendingItems = _syncQueue.values.where((i) =>
      i.societyId == societyId &&
      (i.status == SyncQueueStatus.pending || i.status == SyncQueueStatus.failed)
    ).toList();

    for (final item in pendingItems) {
      // Simulate conflict condition: if member has negative balance or conflict payload
      final memberId = item.payload['memberId'] as String? ?? '';
      if (memberId == 'mem_conflict_test') {
        _syncQueue[item.operationId] = SyncQueueItemModel(
          operationId: item.operationId,
          societyId: item.societyId,
          userId: item.userId,
          deviceId: item.deviceId,
          operationType: item.operationType,
          payload: item.payload,
          status: SyncQueueStatus.requiresReview,
          retryCount: item.retryCount + 1,
          errorDetails: 'সার্ভার কনফ্লিক্ট: মূল শাখায় এই ঋণ হিসাবটি ইতিমধ্যে পুনঃতফসিল করা হয়েছে।',
          createdAt: item.createdAt,
          lastAttemptAt: DateTime.now(),
        );
        conflictCount++;
        continue;
      }

      // Successful sync
      _syncQueue[item.operationId] = SyncQueueItemModel(
        operationId: item.operationId,
        societyId: item.societyId,
        userId: item.userId,
        deviceId: item.deviceId,
        operationType: item.operationType,
        payload: item.payload,
        status: SyncQueueStatus.synced,
        retryCount: item.retryCount + 1,
        createdAt: item.createdAt,
        lastAttemptAt: DateTime.now(),
        syncedAt: DateTime.now(),
      );

      // Confirm provisional receipt to server confirmed
      final provRecNo = item.payload['provisionalReceiptNumber'] as String?;
      if (provRecNo != null && _provisionalReceipts.containsKey(provRecNo)) {
        final rec = _provisionalReceipts[provRecNo]!;
        _provisionalReceipts[provRecNo] = ProvisionalReceiptModel(
          receiptNumber: rec.receiptNumber,
          operationId: rec.operationId,
          memberId: rec.memberId,
          memberName: rec.memberName,
          societyId: rec.societyId,
          collectorId: rec.collectorId,
          collectorName: rec.collectorName,
          purpose: rec.purpose,
          amountPoisha: rec.amountPoisha,
          isServerConfirmed: true,
          provisionalNoticeBn: '✓ সার্ভার যাচাইকৃত অফিসিয়াল মানি রিসিট (Verified Post)',
          collectedAt: rec.collectedAt,
          gpsLat: rec.gpsLat,
          gpsLng: rec.gpsLng,
        );
      }

      syncedCount++;
    }

    _connectivityState = conflictCount > 0
        ? ConnectivityState.syncConflict
        : ConnectivityState.online;

    return {
      'societyId': societyId,
      'totalProcessed': pendingItems.length,
      'syncedCount': syncedCount,
      'conflictCount': conflictCount,
      'failedCount': failedCount,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  void resolveConflict({
    required String operationId,
    required String resolutionAction, // 'FORCE_SYNC', 'CREDIT_SAVINGS', 'CANCEL_REFUND'
    required String resolvedBy,
  }) {
    final item = _syncQueue[operationId];
    if (item == null) throw Exception('কনফ্লিক্ট অপারেশন পাওয়া যায়নি: $operationId');

    _syncQueue[operationId] = SyncQueueItemModel(
      operationId: item.operationId,
      societyId: item.societyId,
      userId: item.userId,
      deviceId: item.deviceId,
      operationType: item.operationType,
      payload: {
        ...item.payload,
        'resolutionAction': resolutionAction,
        'resolvedBy': resolvedBy,
      },
      status: resolutionAction == 'CANCEL_REFUND' ? SyncQueueStatus.cancelled : SyncQueueStatus.synced,
      retryCount: item.retryCount,
      errorDetails: null,
      createdAt: item.createdAt,
      lastAttemptAt: DateTime.now(),
      syncedAt: DateTime.now(),
    );
  }

  // ==========================================
  // 6. CASH RECONCILIATION & MAKER-CHECKER
  // ==========================================

  List<FieldCashReconciliationModel> getCashReconciliations({String? societyId}) {
    return _cashReconciliations.values.where((c) {
      if (societyId != null && c.societyId != societyId) return false;
      return true;
    }).toList()..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
  }

  FieldCashReconciliationModel submitDailyCashReconciliation({
    required String societyId,
    required String officerId,
    required String officerName,
    required int openingFloatPoisha,
    required int totalCollectedPoisha,
    required int physicalCashSubmittedPoisha,
    String? discrepancyNotes,
  }) {
    final id = 'recon_${DateTime.now().millisecondsSinceEpoch}';
    final discrepancy = physicalCashSubmittedPoisha - (openingFloatPoisha + totalCollectedPoisha);

    final model = FieldCashReconciliationModel(
      reconciliationId: id,
      societyId: societyId,
      officerId: officerId,
      officerName: officerName,
      shiftDate: DateTime.now(),
      openingFloatPoisha: openingFloatPoisha,
      totalCollectedPoisha: totalCollectedPoisha,
      physicalCashSubmittedPoisha: physicalCashSubmittedPoisha,
      discrepancyPoisha: discrepancy,
      status: 'submitted',
      submittedAt: DateTime.now(),
      discrepancyNotes: discrepancyNotes,
    );

    _cashReconciliations[id] = model;
    return model;
  }

  FieldCashReconciliationModel verifyAndApproveCashReconciliation({
    required String reconciliationId,
    required String cashierUserId,
    String? notes,
  }) {
    final recon = _cashReconciliations[reconciliationId];
    if (recon == null) throw Exception('ক্যাশ রিকনসিলিয়েশন রেকর্ড পাওয়া যায়নি: $reconciliationId');

    // Separation of Duties Invariant
    if (recon.officerId == cashierUserId) {
      throw Exception('দায়িত্বের পৃথকীকরণ লঙ্ঘন: সংগ্রাহক কর্মকর্তা নিজে ক্যাশিয়ার হিসেবে অনুমোদন করতে পারবেন না!');
    }

    final approved = FieldCashReconciliationModel(
      reconciliationId: recon.reconciliationId,
      societyId: recon.societyId,
      officerId: recon.officerId,
      officerName: recon.officerName,
      shiftDate: recon.shiftDate,
      openingFloatPoisha: recon.openingFloatPoisha,
      totalCollectedPoisha: recon.totalCollectedPoisha,
      physicalCashSubmittedPoisha: recon.physicalCashSubmittedPoisha,
      discrepancyPoisha: recon.discrepancyPoisha,
      status: 'approved',
      verifiedByCashierId: cashierUserId,
      submittedAt: recon.submittedAt,
      verifiedAt: DateTime.now(),
      discrepancyNotes: notes ?? recon.discrepancyNotes,
    );

    _cashReconciliations[reconciliationId] = approved;
    return approved;
  }

  // ==========================================
  // 7. ROUTE PLANNING & WAYPOINTS
  // ==========================================

  List<CollectionRoutePointModel> getRoutePoints({String? societyId, String? routeId}) {
    return _routePoints.values.where((p) {
      if (societyId != null && p.societyId != societyId) return false;
      if (routeId != null && p.routeId != routeId) return false;
      return true;
    }).toList()..sort((a, b) => a.sequenceOrder.compareTo(b.sequenceOrder));
  }

  void updateRoutePointVisitStatus(String pointId, String status, {double? gpsLat, double? gpsLng}) {
    final point = _routePoints[pointId];
    if (point == null) return;

    _routePoints[pointId] = CollectionRoutePointModel(
      pointId: point.pointId,
      routeId: point.routeId,
      societyId: point.societyId,
      memberId: point.memberId,
      memberName: point.memberName,
      address: point.address,
      expectedAmountPoisha: point.expectedAmountPoisha,
      sequenceOrder: point.sequenceOrder,
      visitStatus: status,
      visitedAt: DateTime.now(),
      gpsLat: gpsLat ?? point.gpsLat,
      gpsLng: gpsLng ?? point.gpsLng,
    );
  }

  // ==========================================
  // 8. DEVICE FLEET GOVERNANCE
  // ==========================================

  List<RegisteredDeviceModel> getRegisteredDevices({String? societyId}) {
    return _registeredDevices.values.where((d) {
      if (societyId != null && d.societyId != societyId) return false;
      return true;
    }).toList();
  }

  RegisteredDeviceModel registerDevice(RegisteredDeviceModel device) {
    _registeredDevices[device.deviceId] = device;
    return device;
  }

  void updateDeviceStatus(String deviceId, String status) {
    final d = _registeredDevices[deviceId];
    if (d == null) throw Exception('ডিভাইস পাওয়া যায়নি: $deviceId');

    _registeredDevices[deviceId] = RegisteredDeviceModel(
      deviceId: d.deviceId,
      societyId: d.societyId,
      assignedOfficerId: d.assignedOfficerId,
      officerName: d.officerName,
      deviceName: d.deviceName,
      status: status,
      lastSyncAt: d.lastSyncAt,
      registeredAt: d.registeredAt,
      appVersion: d.appVersion,
    );
  }
}

extension on String {
  String slice(int start) {
    if (start < 0) {
      start = length + start;
      if (start < 0) start = 0;
    }
    return substring(start);
  }
}
