import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_sync_drive/models/role_permission_model.dart';
import 'package:cloud_sync_drive/models/security_compliance_model.dart';
import 'package:cloud_sync_drive/services/security_compliance_service.dart';

void main() {
  group('Enterprise Security, Access Control & Compliance Tests', () {
    late SecurityComplianceService securityService;

    setUp(() {
      securityService = SecurityComplianceService();
    });

    test('All 32 Granular Permissions have non-empty Bengali titles', () {
      expect(SecurityPermissions.all.length, equals(36));
      for (final key in SecurityPermissions.all) {
        final title = SecurityPermissions.getTitleBn(key);
        expect(title.isNotEmpty, isTrue);
        expect(title != key, isTrue); // Must be translated
      }
    });

    test('Tier 1: Master Admin has non-bypassable administrative sovereignty', () {
      final isPermitted = securityService.isActionPermitted(
        permissionKey: SecurityPermissions.accountingClosePeriod,
        userEmail: 'hossansajjad1994@gmail.com',
        role: UserRole.superAdmin,
      );
      expect(isPermitted, isTrue);
    });

    test('Tier 2: Global Master Admin toggle OFF overrides role permission', () {
      // Regular manager tries to post journal
      const perm = SecurityPermissions.accountingPostJournal;

      // Disable globally
      securityService.setGlobalPermissionToggle(perm, false, 'hossansajjad1994@gmail.com');

      final managerPermitted = securityService.isActionPermitted(
        permissionKey: perm,
        userEmail: 'manager_rahim@somiti.org',
        role: UserRole.manager,
      );
      // Denied because Tier 2 Global Denial takes precedence
      expect(managerPermitted, isFalse);

      // Re-enable
      securityService.setGlobalPermissionToggle(perm, true, 'hossansajjad1994@gmail.com');
    });

    test('Tier 6: User-specific granular override grants or restricts action', () {
      const perm = SecurityPermissions.loansApprove;

      // Field officer does not have loan approval in standard preset
      final defaultOfficerPermitted = securityService.isActionPermitted(
        permissionKey: perm,
        userEmail: 'senior_officer@somiti.org',
        role: UserRole.fieldOfficer,
      );
      expect(defaultOfficerPermitted, isFalse);

      // Explicit user-specific override grants approval
      final overriddenOfficerPermitted = securityService.isActionPermitted(
        permissionKey: perm,
        userEmail: 'senior_officer@somiti.org',
        role: UserRole.fieldOfficer,
        userOverrides: {perm: true},
      );
      expect(overriddenOfficerPermitted, isTrue);
    });

    test('Active Session Registry: Registration, validity and revocation', () {
      final session = securityService.registerSession(
        userId: 'usr_1001',
        userEmail: 'kamal@somiti.org',
        societyId: 'somiti_001',
        deviceName: 'Samsung Galaxy A54 (Android 14)',
        ipAddress: '103.145.118.22',
      );

      expect(session.sessionId.isNotEmpty, isTrue);
      expect(session.isValid, isTrue);
      expect(securityService.isSessionValid(session.sessionId), isTrue);

      // Administrator revokes the session
      securityService.revokeSession(
        session.sessionId,
        'hossansajjad1994@gmail.com',
        'সন্দেহভাজন ডিভাইস লগইন',
      );

      expect(securityService.isSessionValid(session.sessionId), isFalse);
    });

    test('Brute-force protection: 5 failed logins triggers account lockout', () {
      const email = 'victim_staff@somiti.org';

      // Record 4 failed attempts -> not locked yet
      for (int i = 0; i < 4; i++) {
        securityService.recordLoginAttempt(
          email: email,
          isSuccess: false,
          ipAddress: '192.168.1.50',
        );
        expect(securityService.isAccountLocked(email), isFalse);
      }

      // 5th failed attempt -> locked!
      securityService.recordLoginAttempt(
        email: email,
        isSuccess: false,
        ipAddress: '192.168.1.50',
      );
      expect(securityService.isAccountLocked(email), isTrue);

      // Successful login resets lockout
      securityService.recordLoginAttempt(
        email: email,
        isSuccess: true,
        ipAddress: '192.168.1.50',
      );
      expect(securityService.isAccountLocked(email), isFalse);
    });

    test('Cryptographic Audit Log Chaining: Integrity and tamper detection', () {
      final logChain = <SecurityAuditRecordModel>[];

      // Record 3 sequential events
      final log1 = securityService.logAuditEvent(
        actorUid: 'admin_1',
        actorEmail: 'admin@somiti.org',
        actorRole: 'admin',
        societyId: 'somiti_001',
        actionType: 'login',
        resourceType: 'auth',
        resourceId: 'session_1',
        detailsBn: 'সফল লগইন সম্পন্ন',
      );
      logChain.add(log1);

      final log2 = securityService.logAuditEvent(
        actorUid: 'manager_1',
        actorEmail: 'manager@somiti.org',
        actorRole: 'manager',
        societyId: 'somiti_001',
        actionType: 'loan_approve',
        resourceType: 'loan',
        resourceId: 'LN-001',
        detailsBn: 'ঋণ অনুমোদন প্রদান',
      );
      logChain.add(log2);

      final log3 = securityService.logAuditEvent(
        actorUid: 'cashier_1',
        actorEmail: 'cashier@somiti.org',
        actorRole: 'cashier',
        societyId: 'somiti_001',
        actionType: 'cash_disburse',
        resourceType: 'cash',
        resourceId: 'TX-902',
        detailsBn: 'ক্যাশ বিতরণ সম্পন্ন',
      );
      logChain.add(log3);

      // Verify intact chain passes
      expect(securityService.verifyAuditLogChain(logChain), isTrue);

      // Simulate malicious tampering of log2 payload
      final tamperedLog2 = SecurityAuditRecordModel(
        id: log2.id,
        timestamp: log2.timestamp,
        actorUid: log2.actorUid,
        actorEmail: log2.actorEmail,
        actorRole: log2.actorRole,
        societyId: log2.societyId,
        actionType: log2.actionType,
        resourceType: log2.resourceType,
        resourceId: log2.resourceId,
        detailsBn: 'ভুয়া ও অননুমোদিত তথ্য পরিবর্তন!', // Tampered text
        previousHash: log2.previousHash,
        currentHash: log2.currentHash, // Out-of-sync hash!
      );

      final corruptedChain = [log1, tamperedLog2, log3];
      // Cryptographic verification MUST detect the tampering!
      expect(securityService.verifyAuditLogChain(corruptedChain), isFalse);
    });
  });
}
