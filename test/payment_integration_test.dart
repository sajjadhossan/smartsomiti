// test/payment_integration_test.dart
// Comprehensive Unit Tests for Phase 7 Enterprise Payment, Banking & Financial Integration Ecosystem

import 'package:test/test.dart';
import '../lib/models/payment_integration_model.dart';
import '../lib/services/payment_integration_service.dart';

void main() {
  group('Phase 7 - Enterprise Payment & Banking Integration Tests', () {
    late PaymentIntegrationService service;
    const testSocietyId = 'swapno_chowa_main';

    setUp(() {
      service = PaymentIntegrationService();
    });

    test('1. Default Payment Gateways and Super Admin Configs', () {
      final configs = service.getProviderConfigs();
      expect(configs.isNotEmpty, isTrue);
      expect(configs.any((c) => c.providerType == PaymentProviderType.bkash), isTrue);
      expect(configs.any((c) => c.providerType == PaymentProviderType.nagad), isTrue);
      expect(configs.any((c) => c.providerType == PaymentProviderType.sslcommerz), isTrue);
      expect(configs.any((c) => c.providerType == PaymentProviderType.bankTransfer), isTrue);
      expect(configs.any((c) => c.providerType == PaymentProviderType.cashCollection), isTrue);

      // Verify Super Admin Toggle
      final bkashCfg = configs.firstWhere((c) => c.providerType == PaymentProviderType.bkash);
      expect(bkashCfg.isEnabled, isTrue);

      service.updateProviderStatus(providerId: bkashCfg.providerId, isEnabled: false);
      final updated = service.getProviderConfig(bkashCfg.providerId);
      expect(updated?.isEnabled, isFalse);

      // Restore
      service.updateProviderStatus(providerId: bkashCfg.providerId, isEnabled: true);
    });

    test('2. Integer Poisha Payment Initiation & MDR Fee Calculation', () {
      const amountPoisha = 100000; // ৳1,000.00
      const idempotencyKey = 'test_idemp_bkash_001';

      final tx = service.initiatePaymentTransaction(
        providerType: PaymentProviderType.bkash,
        societyId: testSocietyId,
        memberId: 'mem_test_01',
        purpose: PaymentPurposeType.memberSavingsDeposit,
        amountPoisha: amountPoisha,
        idempotencyKey: idempotencyKey,
      );

      expect(tx.id, startsWith('tx_bkash_'));
      expect(tx.amountPoisha, equals(100000));
      expect(tx.feePoisha, equals(1500)); // 1.5% of 100,000 = 1,500 Poisha (৳15.00)
      expect(tx.netAmountPoisha, equals(98500)); // ৳985.00
      expect(tx.status, equals(PaymentLifecycleStatus.processing));
      expect(tx.isSuccess, isFalse);
    });

    test('3. Strict Idempotency & Replay Defense (No Double Charge)', () {
      const idempotencyKey = 'test_idemp_replay_defense_key';

      final tx1 = service.initiatePaymentTransaction(
        providerType: PaymentProviderType.bkash,
        societyId: testSocietyId,
        purpose: PaymentPurposeType.membershipFee,
        amountPoisha: 50000,
        idempotencyKey: idempotencyKey,
      );

      // Replay attempt with same idempotency key
      final tx2 = service.initiatePaymentTransaction(
        providerType: PaymentProviderType.bkash,
        societyId: testSocietyId,
        purpose: PaymentPurposeType.membershipFee,
        amountPoisha: 50000,
        idempotencyKey: idempotencyKey,
      );

      expect(tx1.id, equals(tx2.id));
      expect(tx1.createdAt, equals(tx2.createdAt));
    });

    test('4. Server-Authoritative Payment Verification & State Transition', () {
      final tx = service.initiatePaymentTransaction(
        providerType: PaymentProviderType.nagad,
        societyId: testSocietyId,
        memberId: 'mem_test_02',
        purpose: PaymentPurposeType.loanInstallmentRepayment,
        amountPoisha: 200000,
        idempotencyKey: 'test_nagad_verify_001',
      );

      expect(tx.status, equals(PaymentLifecycleStatus.processing));

      final confirmed = service.verifyAndConfirmPayment(
        txId: tx.id,
        providerTxnId: 'NAGAD_TXN_888999',
        linkedVoucherId: 'jv_rec_nagad_001',
        verifiedBy: 'BACKEND_WEBHOOK_HANDLER',
      );

      expect(confirmed.status, equals(PaymentLifecycleStatus.success));
      expect(confirmed.isSuccess, isTrue);
      expect(confirmed.providerTxnId, equals('NAGAD_TXN_888999'));
      expect(confirmed.linkedVoucherId, equals('jv_rec_nagad_001'));
      expect(confirmed.verifiedAt, isNotNull);
    });

    test('5. Field Cash Collection & Maker-Checker Separation of Duties', () {
      final tx = service.initiatePaymentTransaction(
        providerType: PaymentProviderType.cashCollection,
        societyId: testSocietyId,
        memberId: 'mem_test_03',
        purpose: PaymentPurposeType.memberSavingsDeposit,
        amountPoisha: 80000,
        idempotencyKey: 'test_cash_col_001',
        collectorId: 'field_officer_sazzad',
      );

      expect(tx.status, equals(PaymentLifecycleStatus.pending));

      // Collector cannot self-verify as cashier (Separation of Duties violation)
      expect(
        () => service.verifyFieldCashierCollection(
          txId: tx.id,
          cashierUserId: 'field_officer_sazzad',
          linkedVoucherId: 'jv_cash_col_001',
        ),
        throwsA(isA<Exception>()),
      );

      // Legitimate Cashier verifies
      final verified = service.verifyFieldCashierCollection(
        txId: tx.id,
        cashierUserId: 'head_cashier_faruk',
        linkedVoucherId: 'jv_cash_col_001',
      );

      expect(verified.status, equals(PaymentLifecycleStatus.success));
      expect(verified.verifiedBy, equals('head_cashier_faruk'));
    });

    test('6. Dynamic Bangla QR Code Generation & Single-Use Replay Invalidation', () {
      final qr = service.generateBanglaQrToken(
        societyId: testSocietyId,
        memberId: 'mem_test_qr',
        purpose: PaymentPurposeType.memberSavingsDeposit,
        amountPoisha: 150000, // ৳1,500.00
      );

      expect(qr.tokenUuid, startsWith('qr_'));
      expect(qr.isValid, isTrue);
      expect(qr.isUsed, isFalse);
      expect(qr.qrPayload, contains('bd.gov.bb'));
      expect(qr.qrPayload, contains('1500.00'));

      // Validate & Consume
      final successFirst = service.validateAndConsumeQrToken(qr.tokenUuid);
      expect(successFirst, isTrue);

      // Replay attempt must be blocked
      final successReplay = service.validateAndConsumeQrToken(qr.tokenUuid);
      expect(successReplay, isFalse);
    });

    test('7. Commercial Bank Accounts & Automated 3-Way Reconciliation', () {
      final bankAccounts = service.getBankAccounts(societyId: testSocietyId);
      expect(bankAccounts.isNotEmpty, isTrue);

      final bankAcc = bankAccounts.first;
      final reconResult = service.runAutomatedBankReconciliation(bankAcc.id);

      expect(reconResult['bankAccountId'], equals(bankAcc.id));
      expect(reconResult['matchedCount'], greaterThan(0));
      expect(reconResult['matchedPoisha'], greaterThan(0));
    });

    test('8. Refund Workflow with Zero Silent Deletion & Original State Preservation', () {
      // Initiate and verify a transaction
      final tx = service.initiatePaymentTransaction(
        providerType: PaymentProviderType.bkash,
        societyId: testSocietyId,
        purpose: PaymentPurposeType.memberSavingsDeposit,
        amountPoisha: 120000,
        idempotencyKey: 'test_refund_tx_001',
      );

      service.verifyAndConfirmPayment(
        txId: tx.id,
        providerTxnId: 'BKS_REF_TXN_01',
        linkedVoucherId: 'jv_orig_001',
      );

      // Request refund
      final refund = service.requestRefund(
        originalTxnId: tx.id,
        societyId: testSocietyId,
        amountPoisha: 120000,
        reason: 'ভুল নম্বরে টাকা পাঠানো হয়েছিল',
        requestedBy: 'operator_01',
      );

      expect(refund.status, equals('pendingApproval'));

      // Approve and execute refund
      final executed = service.approveAndExecuteRefund(
        refundId: refund.id,
        approvedBy: 'master_admin_sajjad',
        reversalVoucherId: 'jv_rev_orig_001',
      );

      expect(executed.status, equals('refunded'));

      // Verify original transaction is marked refunded, NOT deleted
      final originalTxAfter = service.getTransactionById(tx.id);
      expect(originalTxAfter, isNotNull);
      expect(originalTxAfter?.status, equals(PaymentLifecycleStatus.refunded));
    });

    test('9. Gateway Settlement Tracking & MDR Fee Accounting', () {
      final settlement = service.recordGatewaySettlement(
        providerType: PaymentProviderType.bkash,
        societyId: testSocietyId,
        grossPoisha: 500000, // ৳৫,০০০.০০
        mdrFeePoisha: 7500, // ৳৭৫.০০ (1.5%)
        bankDepositRef: 'stmt_dep_bkash_551',
      );

      expect(settlement.grossPoisha, equals(500000));
      expect(settlement.mdrFeePoisha, equals(7500));
      expect(settlement.netSettledPoisha, equals(492500)); // ৳৪,৯২৫.০০
      expect(settlement.netSettledBdt, equals(4925.0));
      expect(settlement.status, equals('settledToBank'));
    });

    test('10. Payment Hub Overview Metrics', () {
      final metrics = service.getPaymentHubMetrics(testSocietyId);
      expect(metrics['activeGatewaysCount'], greaterThan(0));
      expect(metrics['totalTransactionsCount'], greaterThan(0));
      expect(metrics['totalBankBalanceBdt'], greaterThan(0));
    });
  });
}
