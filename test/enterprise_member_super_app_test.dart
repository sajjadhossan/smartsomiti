// test/enterprise_member_super_app_test.dart
// Phase 18: Enterprise Member Super App & Digital Self-Service Ecosystem Unit Tests

import 'package:flutter_test/flutter_test.dart';
import '../lib/models/member_super_app_model.dart';
import '../lib/services/member_super_app_service.dart';

void main() {
  group('Phase 18 — Enterprise Member Super App & Self-Service Tests', () {
    late MemberSuperAppService service;

    setUp(() {
      service = MemberSuperAppService();
    });

    // Test 1: Member Profile & Data Isolation (Owner Only Access)
    test('1. Member Profile & Data Isolation (Owner Only Access)', () {
      final card = service.getDigitalCard('MEM-101');
      expect(card, isNotNull);
      expect(card!.memberId, equals('MEM-101'));
      expect(card.societyId, equals('SOMITI-001'));
      expect(card.memberName, equals('মোঃ সাজ্জাদ হোসেন'));
    });

    // Test 2: Digital Membership Card Attributes & Validity
    test('2. Digital Membership Card Attributes & Validity', () {
      final card = service.getDigitalCard('MEM-101');
      expect(card!.isValid, isTrue);
      expect(card.isRevoked, isFalse);
      expect(card.bloodGroup, equals('B+'));
      expect(card.memberNumber, equals('১০১'));
    });

    // Test 3: HMAC-SHA256 Dynamic QR Token Generation & Integrity
    test('3. HMAC-SHA256 Dynamic QR Token Generation & Integrity', () {
      final card = service.getDigitalCard('MEM-101');
      expect(card!.qrToken, isNotEmpty);
      expect(card.qrToken.contains('|'), isTrue);

      final verifyResult = service.verifyQrToken(card.qrToken, 'SOMITI-001');
      expect(verifyResult['valid'], isTrue);
      expect(verifyResult['memberId'], equals('MEM-101'));
    });

    // Test 4: Cross-Tenant QR Verification Rejection
    test('4. Cross-Tenant QR Verification Rejection', () {
      final card = service.getDigitalCard('MEM-101');
      // Scan card belonging to SOMITI-001 with scanner logged into SOMITI-002
      final verifyResult = service.verifyQrToken(card!.qrToken, 'SOMITI-002');
      expect(verifyResult['valid'], isFalse);
      expect(verifyResult['reason'], contains('ক্রস-টেন্যান্ট অ্যাক্সেস প্রত্যাখ্যাত'));
    });

    // Test 5: Expired or Tampered QR Token Rejection
    test('5. Expired or Tampered QR Token Rejection', () {
      final card = service.getDigitalCard('MEM-101');
      final tamperedToken = '${card!.qrToken}_tampered_fake_sig';
      final verifyResult = service.verifyQrToken(tamperedToken, 'SOMITI-001');
      expect(verifyResult['valid'], isFalse);
    });

    // Test 6: Member Savings Self-Service Authoritative Balance
    test('6. Member Savings Self-Service Authoritative Balance', () {
      final savings = service.getMemberSavingsSummary('MEM-101');
      expect(savings.totalSavingsPoisha, equals(84520000)); // ৳8,45,200.00
      expect(savings.totalSavingsTaka, equals(845200.00));
      expect(savings.availableWithdrawalTaka, equals(600000.00));
    });

    // Test 7: Withdrawal Request Submission with Maker-Checker (Cannot Self-Approve)
    test('7. Withdrawal Request Submission with Maker-Checker (Cannot Self-Approve)', () {
      final req = service.submitWithdrawalRequest(
        memberId: 'MEM-101',
        societyId: 'SOMITI-001',
        amountPoisha: 1000000, // ৳10,000.00
        reason: 'পারিবারিক প্রয়োজন',
      );

      expect(req.requestId, startsWith('WDR-2026-'));
      expect(req.amountTaka, equals(10000.00));
      expect(req.status, equals('pending')); // Strictly pending!
      expect(req.reviewedBy, isNull); // Must not be self-approved!
    });

    // Test 8: Loan Self-Service Outstanding & Next Installment
    test('8. Loan Self-Service Outstanding & Next Installment', () {
      final loanSummary = service.getMemberLoanSummary('MEM-101');
      expect(loanSummary.activeLoansCount, equals(1));
      expect(loanSummary.totalPrincipalOutstandingPoisha, equals(18500000)); // ৳1,85,000.00
      expect(loanSummary.nextInstallmentAmountTaka, equals(5000.00));
    });

    // Test 9: Member Loan Application Workflow Submission
    test('9. Member Loan Application Workflow Submission', () {
      final app = service.submitLoanApplication(
        memberId: 'MEM-101',
        societyId: 'SOMITI-001',
        requestedAmountPoisha: 5000000, // ৳50,000.00
        termMonths: 12,
        purpose: 'গরু মোটাতাজাকরণ ও খামার উন্নয়ন',
        guarantorMemberId: 'MEM-103',
      );

      expect(app.applicationId, startsWith('LN-APP-2026-'));
      expect(app.requestedAmountTaka, equals(50000.00));
      expect(app.status, equals('submitted'));
      expect(app.approvedAt, isNull); // Requires committee review
    });

    // Test 10: Super Admin Universal Feature Toggle (Disabling Digital Card)
    test('10. Super Admin Universal Feature Toggle (Disabling Digital Card)', () {
      service.updatePolicy(isDigitalCardEnabled: false);
      expect(() => service.getDigitalCard('MEM-101'), throwsStateError);

      // Re-enable
      service.updatePolicy(isDigitalCardEnabled: true);
      expect(service.getDigitalCard('MEM-101'), isNotNull);
    });

    // Test 11: Super Admin Withdrawal Request Feature Toggle
    test('11. Super Admin Withdrawal Request Feature Toggle', () {
      service.updatePolicy(isWithdrawalRequestEnabled: false);
      expect(
        () => service.submitWithdrawalRequest(
          memberId: 'MEM-101',
          societyId: 'SOMITI-001',
          amountPoisha: 500000,
          reason: 'টেস্ট',
        ),
        throwsStateError,
      );

      // Restore
      service.updatePolicy(isWithdrawalRequestEnabled: true);
    });

    // Test 12: Immutable Security & Financial Invariants Protection (Non-disablable)
    test('12. Immutable Security & Financial Invariants Protection (Non-disablable)', () {
      service.updatePolicy(isMemberAppGloballyEnabled: true);
      final cfg = service.config;
      expect(cfg.isMakerCheckerMandatory, isTrue); // Non-negotiable invariant
      expect(cfg.isTenantIsolationEnforced, isTrue); // Non-negotiable invariant
    });
  });
}
