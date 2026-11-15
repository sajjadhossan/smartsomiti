// test/saas_subscription_test.dart
// Enterprise SaaS Subscription, Invoicing & Billing Verification Tests

import 'package:test/test.dart';
import '../lib/models/saas_subscription_model.dart';
import '../lib/services/saas_subscription_service.dart';

void main() {
  group('Enterprise SaaS Tier & Catalog Tests', () {
    test('Default tier plans load correctly with Integer Poisha pricing', () {
      final plans = SaasPlanModel.defaultPlans();
      expect(plans.length, equals(4));

      final starter = plans.firstWhere((p) => p.tier == 'starter');
      expect(starter.monthlyFeePoisha, equals(99900)); // ৳999.00
      expect(starter.monthlyFeeBdt, equals(999.0));
      expect(starter.maxMembers, equals(150));

      final enterprise = plans.firstWhere((p) => p.tier == 'enterprise');
      expect(enterprise.monthlyFeePoisha, equals(799900)); // ৳7,999.00
      expect(enterprise.maxMembers, equals(-1)); // Unlimited
      expect(enterprise.allowedModules.contains('api_access'), isTrue);
    });

    test('Coupon calculates accurate discount in Poisha', () {
      final coupon15 = SaasCouponModel(
        code: 'TEST15',
        discountPercent: 15.0,
        validFrom: DateTime.now().subtract(const Duration(days: 1)),
        validUntil: DateTime.now().add(const Duration(days: 30)),
      );

      final discount = coupon15.calculateDiscount(100000); // ৳1,000 -> 15% = 15000 poisha (৳150)
      expect(discount, equals(15000));
    });
  });

  group('SaaS Lifecycle & Entitlement Service Tests', () {
    late SaasSubscriptionService service;
    const testSocietyId = 'society_test_mirpur_001';

    setUp(() {
      service = SaasSubscriptionService();
    });

    test('Create 14-day trial subscription for new society', () {
      final trialSub = service.createTrialSubscription(
        societyId: testSocietyId,
        planId: 'plan_starter',
      );

      expect(trialSub.societyId, equals(testSocietyId));
      expect(trialSub.status, equals(SaasSubscriptionStatus.trialing));
      expect(trialSub.isActiveOrTrial, isTrue);
      expect(trialSub.isSuspendedOrExpired, isFalse);
    });

    test('Entitlement and Member Quota Enforcement', () {
      // Starter plan has 150 member limit
      expect(service.isMemberQuotaAvailable(testSocietyId, 100), isTrue);
      expect(service.isMemberQuotaAvailable(testSocietyId, 150), isFalse);
      expect(service.isMemberQuotaAvailable(testSocietyId, 200), isFalse);

      // Feature entitlement
      expect(service.isFeatureEntitled(testSocietyId, 'savings'), isTrue);
      expect(service.isFeatureEntitled(testSocietyId, 'api_access'), isFalse);
    });

    test('Invoice Generation with Integer Poisha and 5% VAT', () {
      final invoice = service.generateInvoice(
        societyId: testSocietyId,
        planId: 'plan_standard', // ৳1,999 = 199,900 poisha
        billingCycle: SaasBillingCycle.monthly,
        couponCode: 'EID2026', // 15% discount
        taxRateBps: 500, // 5% VAT
      );

      expect(invoice.societyId, equals(testSocietyId));
      expect(invoice.subtotalPoisha, equals(199900));
      // 15% discount on 199,900 = 29,985
      expect(invoice.discountPoisha, equals(29985));
      // Base payable = 199,900 - 29,985 = 169,915
      // VAT 5% of 169,915 = 8,495 poisha
      expect(invoice.taxPoisha, equals(8495));
      // Total = 169,915 + 8,495 = 178,410 poisha (৳1,784.10)
      expect(invoice.totalPoisha, equals(178410));
      expect(invoice.status, equals('pending_payment'));
    });

    test('Payment Verification activates subscription with Idempotency Protection', () {
      final invoice = service.generateInvoice(
        societyId: testSocietyId,
        planId: 'plan_premium',
        billingCycle: SaasBillingCycle.monthly,
      );

      const idempotencyKey = 'bkash_trx_unique_998877';

      final payment = service.verifyPayment(
        invoiceId: invoice.id,
        societyId: testSocietyId,
        amountPoisha: invoice.totalPoisha,
        gateway: 'bkash',
        transactionRef: 'TRX-BKASH-998877',
        idempotencyKey: idempotencyKey,
      );

      expect(payment.status, equals('verified'));
      expect(payment.amountPoisha, equals(invoice.totalPoisha));

      // Invoice is now marked paid
      final updatedInvoice = service.getInvoiceById(invoice.id);
      expect(updatedInvoice?.isPaid, isTrue);

      // Society subscription is active
      final sub = service.getSocietySubscription(testSocietyId);
      expect(sub?.status, equals(SaasSubscriptionStatus.active));
      expect(sub?.planId, equals('plan_premium'));

      // Replay attack with same idempotency key should throw StateError
      expect(
        () => service.verifyPayment(
          invoiceId: invoice.id,
          societyId: testSocietyId,
          amountPoisha: invoice.totalPoisha,
          gateway: 'bkash',
          transactionRef: 'TRX-BKASH-998877',
          idempotencyKey: idempotencyKey,
        ),
        throwsStateError,
      );
    });

    test('MRR & ARR Platform Revenue Aggregation', () {
      final metrics = service.getPlatformSaaSMetrics();
      expect(metrics['mrrPoisha'], isNonNegative);
      expect(metrics['arrPoisha'], equals(metrics['mrrPoisha'] * 12));
      expect(metrics['totalPlans'], equals(4));
    });
  });
}
