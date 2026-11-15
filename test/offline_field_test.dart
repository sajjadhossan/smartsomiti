// test/offline_field_test.dart
// Comprehensive Unit Tests for Phase 9 Enterprise Offline-First Architecture & Field Operations Engine

import 'package:test/test.dart';
import '../lib/models/offline_field_model.dart';
import '../lib/services/offline_field_service.dart';

void main() {
  group('Phase 9 - Enterprise Offline-First Architecture & Field Operations Tests', () {
    late OfflineFieldService service;
    const testSocietyId = 'swapno_chowa_main';
    const testOfficerId = 'usr_officer_kamal';
    const testDeviceId = 'TAB-SAM-X200-092';

    setUp(() {
      service = OfflineFieldService();
    });

    test('1. Super Admin Master Offline Switch & Policy Configuration', () {
      final config = service.getSocietyConfig(testSocietyId);
      expect(config.isOfflineModeAllowed, isTrue);
      expect(config.cacheValidityHours, equals(24));
      expect(config.isGpsTrackingMandatory, isTrue);
      expect(config.deviceHeartbeatMinutes, equals(15));

      // Test updating Super Admin master offline policy
      final updated = service.updateSocietyConfig(
        societyId: testSocietyId,
        isOfflineModeAllowed: false,
        cacheValidityHours: 12,
        isGpsTrackingMandatory: false,
        deviceHeartbeatMinutes: 30,
      );

      expect(updated.isOfflineModeAllowed, isFalse);
      expect(updated.cacheValidityHours, equals(12));
      expect(updated.isGpsTrackingMandatory, isFalse);

      // Restore configuration
      service.updateSocietyConfig(
        societyId: testSocietyId,
        isOfflineModeAllowed: true,
        cacheValidityHours: 24,
        isGpsTrackingMandatory: true,
        deviceHeartbeatMinutes: 15,
      );
    });

    test('2. Offline Collection Queueing & Integer Poisha Calculation', () {
      final queueItem = service.queueOfflineOperation(
        societyId: testSocietyId,
        officerId: testOfficerId,
        deviceId: testDeviceId,
        type: 'COLLECTION_SAVINGS',
        payload: {
          'memberId': 'MEM-001',
          'memberName': 'মোঃ আব্দুর রহমান',
          'amountPoisha': 250000, // 2,500.00 BDT
          'accountCode': '2110', // Member Savings
        },
      );

      expect(queueItem.opId, isNotEmpty);
      expect(queueItem.societyId, equals(testSocietyId));
      expect(queueItem.officerId, equals(testOfficerId));
      expect(queueItem.status, equals(SyncQueueStatus.pending));
      expect(queueItem.payload['amountPoisha'], equals(250000));
    });

    test('3. Provisional Receipt Invariant & Notice Banner', () {
      final receipt = service.generateProvisionalReceipt(
        societyId: testSocietyId,
        officerId: testOfficerId,
        deviceId: testDeviceId,
        memberId: 'MEM-001',
        memberName': 'মোঃ আব্দুর রহমান',
        amountPoisha: 250000,
        collectionType: 'সাপ্তাহিক সঞ্চয়',
        accountCode: '2110',
      );

      expect(receipt.receiptNumber, startsWith('PROV-REC-'));
      expect(receipt.isVerifiedOnServer, isFalse);
      expect(receipt.provisionalNotice, contains('*** সাময়িক রসিদ (অনলাইন সার্ভার যাচাই অপেক্ষমান) ***'));
      expect(receipt.provisionalNotice, contains('হিসাবরক্ষক কর্তৃক যাচাই ও সার্ভারে অনুমোদিত না হওয়া পর্যন্ত'));
      expect(receipt.amountPoisha, equals(250000));
    });

    test('4. Idempotency & Replay Defense on Duplicate Operation ID', () {
      final customOpId = 'OP-OFFLINE-IDEMP-001';

      // First submission
      service.queueOfflineOperation(
        societyId: testSocietyId,
        officerId: testOfficerId,
        deviceId: testDeviceId,
        type: 'COLLECTION_LOAN_INSTALLMENT',
        payload: {'memberId': 'MEM-002', 'amountPoisha': 500000},
        explicitOpId: customOpId,
      );

      // Attempt duplicate submission with exact same opId
      expect(
        () => service.queueOfflineOperation(
          societyId: testSocietyId,
          officerId: testOfficerId,
          deviceId: testDeviceId,
          type: 'COLLECTION_LOAN_INSTALLMENT',
          payload: {'memberId': 'MEM-002', 'amountPoisha': 500000},
          explicitOpId: customOpId,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('5. Connectivity State Transitions', () {
      expect(service.connectivityState, equals(ConnectivityState.online));

      service.setConnectivityState(ConnectivityState.offline);
      expect(service.connectivityState, equals(ConnectivityState.offline));

      service.setConnectivityState(ConnectivityState.syncing);
      expect(service.connectivityState, equals(ConnectivityState.syncing));

      service.setConnectivityState(ConnectivityState.online);
      expect(service.connectivityState, equals(ConnectivityState.online));
    });

    test('6. Sync Engine Batch Processing & Status Update to SYNCED', () async {
      final item = service.queueOfflineOperation(
        societyId: testSocietyId,
        officerId: testOfficerId,
        deviceId: testDeviceId,
        type: 'COLLECTION_SAVINGS',
        payload: {'memberId': 'MEM-003', 'amountPoisha': 100000},
      );

      expect(item.status, equals(SyncQueueStatus.pending));

      final syncResults = await service.processPendingSyncQueue(testSocietyId);
      expect(syncResults.isNotEmpty, isTrue);

      final processed = service.getQueueItem(item.opId);
      expect(processed, isNotNull);
      expect(processed!.status, equals(SyncQueueStatus.synced));
      expect(processed.syncedAt, isNotNull);
    });

    test('7. Financial Conflict Hold Policy (REQUIRES_REVIEW - Zero Silent Overwrites)', () async {
      // Create an operation with conflict flag payload
      final conflictingItem = service.queueOfflineOperation(
        societyId: testSocietyId,
        officerId: testOfficerId,
        deviceId: testDeviceId,
        type: 'COLLECTION_LOAN_INSTALLMENT',
        payload: {
          'memberId': 'MEM-CONFLICT-99',
          'amountPoisha': 300000,
          'simulateConflict': true,
          'conflictReason': 'অনলাইন সার্ভারে কিস্তি ইতোমধ্যে পরিশোধিত হয়েছে',
        },
      );

      await service.processPendingSyncQueue(testSocietyId);

      final reviewed = service.getQueueItem(conflictingItem.opId);
      expect(reviewed, isNotNull);
      expect(reviewed!.status, equals(SyncQueueStatus.requiresReview));
      expect(reviewed.errorMessage, contains('অনলাইন সার্ভারে কিস্তি ইতোমধ্যে পরিশোধিত হয়েছে'));
    });

    test('8. Field Cash Reconciliation Maker-Checker Separation of Duties', () {
      final reconciliation = service.createCashReconciliation(
        societyId: testSocietyId,
        officerId: testOfficerId,
        officerName: 'কামাল হোসেন (ফিল্ড অফিসার)',
        totalCollectionsPoisha: 1250000, // 12,500.00 BDT
        receiptCount: 5,
        physicalCashHandedOverPoisha: 1250000,
      );

      expect(reconciliation.status, equals('SUBMITTED'));
      expect(reconciliation.variancePoisha, equals(0));

      // Maker cannot approve own cash batch (separation of duties violation)
      expect(
        () => service.verifyCashReconciliation(
          reconciliationId: reconciliation.reconciliationId,
          cashierId: testOfficerId, // Same user attempting checker role
          cashierName: 'কামাল হোসেন',
          isApproved: true,
        ),
        throwsA(isA<Exception>()),
      );

      // Independent cashier verification
      final verified = service.verifyCashReconciliation(
        reconciliationId: reconciliation.reconciliationId,
        cashierId: 'usr_cashier_nasir',
        cashierName: 'নাসির উদ্দিন (প্রধান ক্যাশিয়ার)',
        isApproved: true,
      );

      expect(verified.status, equals('VERIFIED'));
      expect(verified.verifiedByCashierId, equals('usr_cashier_nasir'));
    });

    test('9. Route Planning Waypoint Visit Status Updates', () {
      final routes = service.getAssignedRoutePoints(testSocietyId, testOfficerId);
      expect(routes.isNotEmpty, isTrue);

      final targetPoint = routes.first;
      expect(targetPoint.status, equals(RoutePointStatus.pending));

      final updatedPoint = service.updateRoutePointStatus(
        pointId: targetPoint.pointId,
        status: RoutePointStatus.visited,
        collectedAmountPoisha: 250000,
        remarks: 'সদস্য উপস্থিত ছিলেন ও নগদ টাকা জমা দিয়েছেন',
      );

      expect(updatedPoint.status, equals(RoutePointStatus.visited));
      expect(updatedPoint.collectedAmountPoisha, equals(250000));
      expect(updatedPoint.visitedAt, isNotNull);
    });

    test('10. Device Registration, Heartbeat & Remote Revocation Enforcement', () {
      final device = service.registerDevice(
        societyId: testSocietyId,
        assignedOfficerId: testOfficerId,
        deviceModel: 'Samsung Galaxy Tab A8',
        macAddress: 'BC:D1:19:FA:82:11',
        imei: '862910048192841',
      );

      expect(device.isAuthorized, isTrue);
      expect(device.status, equals('ACTIVE'));

      // Update heartbeat
      service.updateDeviceHeartbeat(device.deviceId);
      final refreshed = service.getDevice(device.deviceId);
      expect(refreshed!.lastHeartbeatAt, isNotNull);

      // Revoke device by Super Admin
      service.revokeDevice(
        deviceId: device.deviceId,
        revocationReason: 'ডিভাইস হারিয়ে গেছে বলে রিপোর্ট করা হয়েছে',
      );

      final revoked = service.getDevice(device.deviceId);
      expect(revoked!.isAuthorized, isFalse);
      expect(revoked.status, equals('REVOKED'));
      expect(revoked.isWipePending, isTrue);

      // Attempting offline queue operation with revoked device should be rejected
      expect(
        () => service.queueOfflineOperation(
          societyId: testSocietyId,
          officerId: testOfficerId,
          deviceId: device.deviceId,
          type: 'COLLECTION_SAVINGS',
          payload: {'memberId': 'MEM-005', 'amountPoisha': 50000},
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
