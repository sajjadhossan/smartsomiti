// lib/services/saas_subscription_service.dart
// Enterprise SaaS Subscription, Plan Entitlement, Invoicing & Billing Service

import 'dart:math';
import '../models/saas_subscription_model.dart';
import '../models/feature_flag_model.dart';
import '../models/security_compliance_model.dart';

class SaasSubscriptionService {
  static final SaasSubscriptionService _instance = SaasSubscriptionService._internal();
  factory SaasSubscriptionService() => _instance;
  SaasSubscriptionService._internal() {
    _initializeDefaults();
  }

  final Map<String, SaasPlanModel> _plans = {};
  final Map<String, SocietySubscriptionModel> _subscriptions = {}; // societyId -> Subscription
  final Map<String, SaasInvoiceModel> _invoices = {}; // invoiceId -> Invoice
  final Map<String, SaasPaymentModel> _payments = {}; // paymentId -> Payment
  final Map<String, SaasCouponModel> _coupons = {}; // code -> Coupon
  final Set<String> _processedIdempotencyKeys = {};

  int _invoiceSequence = 1;

  void _initializeDefaults() {
    // Seed Bangladeshi SaaS Tier Catalog
    for (final plan in SaasPlanModel.defaultPlans()) {
      _plans[plan.id] = plan;
    }

    // Seed default discount coupons
    _coupons['EID2026'] = SaasCouponModel(
      code: 'EID2026',
      discountPercent: 15.0,
      validFrom: DateTime.now().subtract(const Duration(days: 10)),
      validUntil: DateTime.now().add(const Duration(days: 90)),
      maxUses: 500,
    );
    _coupons['LAUNCH500'] = SaasCouponModel(
      code: 'LAUNCH500',
      fixedDiscountPoisha: 50000, // ৳500 discount
      validFrom: DateTime.now().subtract(const Duration(days: 5)),
      validUntil: DateTime.now().add(const Duration(days: 60)),
      maxUses: 100,
    );
  }

  // ==========================================
  // 1. PLAN MANAGEMENT
  // ==========================================

  List<SaasPlanModel> getAllPlans() => _plans.values.toList();

  SaasPlanModel? getPlanById(String planId) => _plans[planId];

  void savePlan(SaasPlanModel plan) {
    _plans[plan.id] = plan;
  }

  // ==========================================
  // 2. SUBSCRIPTION LIFECYCLE MANAGEMENT
  // ==========================================

  SocietySubscriptionModel? getSocietySubscription(String societyId) {
    return _subscriptions[societyId];
  }

  /// Start a 14-day or 30-day Free Trial
  SocietySubscriptionModel createTrialSubscription({
    required String societyId,
    String planId = 'plan_starter',
  }) {
    final plan = _plans[planId] ?? _plans['plan_starter']!;
    final now = DateTime.now();
    final trialDays = plan.trialDays > 0 ? plan.trialDays : 14;
    final trialEnd = now.add(Duration(days: trialDays));

    final sub = SocietySubscriptionModel(
      id: 'sub_${societyId}_${now.millisecondsSinceEpoch}',
      societyId: societyId,
      planId: plan.id,
      status: SaasSubscriptionStatus.trialing,
      billingCycle: SaasBillingCycle.monthly,
      currentPeriodStart: now,
      currentPeriodEnd: trialEnd,
      trialEndsAt: trialEnd,
      isAutoRenew: false,
    );

    _subscriptions[societyId] = sub;
    return sub;
  }

  /// Upgrade or Downgrade Subscription
  SocietySubscriptionModel changePlan({
    required String societyId,
    required String newPlanId,
    required SaasBillingCycle billingCycle,
  }) {
    final existing = _subscriptions[societyId];
    final plan = _plans[newPlanId];
    if (plan == null) {
      throw ArgumentError('Invalid SaaS Plan ID: $newPlanId');
    }

    final now = DateTime.now();
    DateTime newEnd;
    switch (billingCycle) {
      case SaasBillingCycle.monthly:
        newEnd = now.add(const Duration(days: 30));
        break;
      case SaasBillingCycle.quarterly:
        newEnd = now.add(const Duration(days: 90));
        break;
      case SaasBillingCycle.semiAnnual:
        newEnd = now.add(const Duration(days: 180));
        break;
      case SaasBillingCycle.annual:
        newEnd = now.add(const Duration(days: 365));
        break;
      case SaasBillingCycle.lifetime:
        newEnd = now.add(const Duration(days: 36500));
        break;
    }

    final updated = SocietySubscriptionModel(
      id: existing?.id ?? 'sub_${societyId}_${now.millisecondsSinceEpoch}',
      societyId: societyId,
      planId: newPlanId,
      status: SaasSubscriptionStatus.active,
      billingCycle: billingCycle,
      currentPeriodStart: now,
      currentPeriodEnd: newEnd,
      trialEndsAt: null,
      isAutoRenew: true,
      customLimits: existing?.customLimits ?? {},
    );

    _subscriptions[societyId] = updated;
    return updated;
  }

  /// Transition lifecycle state (e.g. grace period, suspended, reactivated)
  SocietySubscriptionModel setSubscriptionStatus(String societyId, SaasSubscriptionStatus newStatus) {
    final existing = _subscriptions[societyId];
    if (existing == null) {
      throw StateError('No subscription found for society: $societyId');
    }

    DateTime? graceEnds;
    if (newStatus == SaasSubscriptionStatus.gracePeriod) {
      graceEnds = DateTime.now().add(const Duration(days: 7));
    }

    final updated = SocietySubscriptionModel(
      id: existing.id,
      societyId: existing.societyId,
      planId: existing.planId,
      status: newStatus,
      billingCycle: existing.billingCycle,
      currentPeriodStart: existing.currentPeriodStart,
      currentPeriodEnd: existing.currentPeriodEnd,
      trialEndsAt: existing.trialEndsAt,
      gracePeriodEndsAt: graceEnds ?? existing.gracePeriodEndsAt,
      isAutoRenew: existing.isAutoRenew,
      customLimits: existing.customLimits,
      metadata: existing.metadata,
    );

    _subscriptions[societyId] = updated;
    return updated;
  }

  // ==========================================
  // 3. ENTITLEMENT & QUOTA GATES
  // ==========================================

  bool isFeatureEntitled(String societyId, String moduleKey) {
    final sub = _subscriptions[societyId];
    if (sub == null || !sub.isActiveOrTrial) {
      return false; // Inactive or suspended subscription
    }

    final plan = _plans[sub.planId];
    if (plan == null) return false;

    // Check allowed modules
    return plan.allowedModules.contains(moduleKey);
  }

  bool isMemberQuotaAvailable(String societyId, int currentMemberCount) {
    final sub = _subscriptions[societyId];
    if (sub == null || !sub.isActiveOrTrial) return false;

    final plan = _plans[sub.planId];
    if (plan == null) return false;

    if (plan.maxMembers < 0) return true; // Unlimited
    return currentMemberCount < plan.maxMembers;
  }

  // ==========================================
  // 4. INVOICING & BILLING ENGINE
  // ==========================================

  /// Generate deterministic invoice with Integer Poisha arithmetic
  SaasInvoiceModel generateInvoice({
    required String societyId,
    required String planId,
    required SaasBillingCycle billingCycle,
    String? couponCode,
    int taxRateBps = 500, // 5% standard VAT = 500 basis points
  }) {
    final plan = _plans[planId];
    if (plan == null) {
      throw ArgumentError('Plan not found: $planId');
    }

    int basePoisha = plan.monthlyFeePoisha;
    if (billingCycle == SaasBillingCycle.quarterly) {
      basePoisha = plan.quarterlyFeePoisha;
    } else if (billingCycle == SaasBillingCycle.annual) {
      basePoisha = plan.annualFeePoisha;
    }

    // Apply Coupon
    int discountPoisha = 0;
    if (couponCode != null && _coupons.containsKey(couponCode)) {
      final coupon = _coupons[couponCode]!;
      discountPoisha = coupon.calculateDiscount(basePoisha);
    }

    final subtotalPoisha = max(0, basePoisha - discountPoisha);
    // Tax calculation via integer basis points: (subtotal * bps) ~/ 10000
    final taxPoisha = (subtotalPoisha * taxRateBps) ~/ 10000;
    final totalPoisha = subtotalPoisha + taxPoisha;

    final now = DateTime.now();
    final invoiceNumber = 'INV-${now.year}${now.month.toString().padLeft(2, '0')}-${(_invoiceSequence++).toString().padLeft(5, '0')}';
    final invoiceId = 'inv_${now.millisecondsSinceEpoch}_${Random().nextInt(9999)}';

    final invoice = SaasInvoiceModel(
      id: invoiceId,
      invoiceNumber: invoiceNumber,
      societyId: societyId,
      subscriptionId: _subscriptions[societyId]?.id,
      planId: planId,
      billingCycle: billingCycle,
      subtotalPoisha: basePoisha,
      discountPoisha: discountPoisha,
      taxPoisha: taxPoisha,
      totalPoisha: totalPoisha,
      status: 'pending_payment',
      issuedAt: now,
      dueAt: now.add(const Duration(days: 7)),
    );

    _invoices[invoiceId] = invoice;
    return invoice;
  }

  List<SaasInvoiceModel> getInvoicesForSociety(String societyId) {
    return _invoices.values.where((inv) => inv.societyId == societyId).toList();
  }

  SaasInvoiceModel? getInvoiceById(String invoiceId) => _invoices[invoiceId];

  // ==========================================
  // 5. PAYMENT VERIFICATION & IDEMPOTENCY
  // ==========================================

  /// Verified Payment Processing with Idempotency and Anti-Replay Defense
  SaasPaymentModel verifyPayment({
    required String invoiceId,
    required String societyId,
    required int amountPoisha,
    required String gateway,
    required String transactionRef,
    required String idempotencyKey,
    String? verifiedBy,
  }) {
    // 1. Idempotency Check
    if (_processedIdempotencyKeys.contains(idempotencyKey)) {
      throw StateError('Duplicate payment transaction: Idempotency Key $idempotencyKey already processed.');
    }

    // 2. Validate Invoice
    final invoice = _invoices[invoiceId];
    if (invoice == null) {
      throw ArgumentError('Invoice not found: $invoiceId');
    }

    if (invoice.isPaid) {
      throw StateError('Invoice $invoiceId is already marked as paid.');
    }

    // 3. Amount Matching
    if (amountPoisha < invoice.totalPoisha) {
      throw ArgumentError(
        'Underpayment error: expected ${invoice.totalPoisha} poisha, received $amountPoisha poisha.',
      );
    }

    // 4. Record Payment
    final now = DateTime.now();
    final paymentId = 'pay_${now.millisecondsSinceEpoch}_${Random().nextInt(9999)}';

    final payment = SaasPaymentModel(
      id: paymentId,
      invoiceId: invoiceId,
      societyId: societyId,
      amountPoisha: amountPoisha,
      gateway: gateway,
      transactionRef: transactionRef,
      idempotencyKey: idempotencyKey,
      status: 'verified',
      createdAt: now,
      verifiedAt: now,
      verifiedBy: verifiedBy ?? 'system_auto',
    );

    _payments[paymentId] = payment;
    _processedIdempotencyKeys.add(idempotencyKey);

    // 5. Update Invoice State to Paid
    final paidInvoice = SaasInvoiceModel(
      id: invoice.id,
      invoiceNumber: invoice.invoiceNumber,
      societyId: invoice.societyId,
      subscriptionId: invoice.subscriptionId,
      planId: invoice.planId,
      billingCycle: invoice.billingCycle,
      subtotalPoisha: invoice.subtotalPoisha,
      discountPoisha: invoice.discountPoisha,
      taxPoisha: invoice.taxPoisha,
      totalPoisha: invoice.totalPoisha,
      status: 'paid',
      issuedAt: invoice.issuedAt,
      dueAt: invoice.dueAt,
      paidAt: now,
      paymentMethod: gateway,
      transactionRef: transactionRef,
      notes: 'Paid via $gateway ($transactionRef)',
    );
    _invoices[invoiceId] = paidInvoice;

    // 6. Activate/Extend Society Subscription
    final existingSub = _subscriptions[societyId];
    int addDays = 30;
    if (invoice.billingCycle == SaasBillingCycle.quarterly) addDays = 90;
    if (invoice.billingCycle == SaasBillingCycle.annual) addDays = 365;

    final periodStart = (existingSub != null && existingSub.currentPeriodEnd.isAfter(now))
        ? existingSub.currentPeriodEnd
        : now;
    final periodEnd = periodStart.add(Duration(days: addDays));

    final updatedSub = SocietySubscriptionModel(
      id: existingSub?.id ?? 'sub_${societyId}_${now.millisecondsSinceEpoch}',
      societyId: societyId,
      planId: invoice.planId,
      status: SaasSubscriptionStatus.active,
      billingCycle: invoice.billingCycle,
      currentPeriodStart: periodStart,
      currentPeriodEnd: periodEnd,
      trialEndsAt: null,
      isAutoRenew: true,
      customLimits: existingSub?.customLimits ?? {},
    );
    _subscriptions[societyId] = updatedSub;

    return payment;
  }

  // ==========================================
  // 6. COMMERCIAL REVENUE ANALYTICS & METRICS
  // ==========================================

  /// Calculate Platform Monthly Recurring Revenue (MRR) in Poisha
  int calculateMrrPoisha() {
    int mrr = 0;
    for (final sub in _subscriptions.values) {
      if (sub.status == SaasSubscriptionStatus.active ||
          sub.status == SaasSubscriptionStatus.upcomingRenewal ||
          sub.status == SaasSubscriptionStatus.gracePeriod) {
        final plan = _plans[sub.planId];
        if (plan != null) {
          switch (sub.billingCycle) {
            case SaasBillingCycle.monthly:
              mrr += plan.monthlyFeePoisha;
              break;
            case SaasBillingCycle.quarterly:
              mrr += (plan.quarterlyFeePoisha ~/ 3);
              break;
            case SaasBillingCycle.semiAnnual:
              mrr += (plan.quarterlyFeePoisha * 2 ~/ 6);
              break;
            case SaasBillingCycle.annual:
              mrr += (plan.annualFeePoisha ~/ 12);
              break;
            case SaasBillingCycle.lifetime:
              break;
          }
        }
      }
    }
    return mrr;
  }

  Map<String, dynamic> getPlatformSaaSMetrics() {
    int activeCount = 0;
    int trialCount = 0;
    int overdueCount = 0;
    int suspendedCount = 0;

    for (final sub in _subscriptions.values) {
      switch (sub.status) {
        case SaasSubscriptionStatus.active:
        case SaasSubscriptionStatus.upcomingRenewal:
          activeCount++;
          break;
        case SaasSubscriptionStatus.trialing:
          trialCount++;
          break;
        case SaasSubscriptionStatus.renewalDue:
        case SaasSubscriptionStatus.paymentOverdue:
        case SaasSubscriptionStatus.gracePeriod:
          overdueCount++;
          break;
        case SaasSubscriptionStatus.suspended:
        case SaasSubscriptionStatus.expired:
        case SaasSubscriptionStatus.cancelled:
          suspendedCount++;
          break;
        default:
          break;
      }
    }

    final mrrPoisha = calculateMrrPoisha();
    final arrPoisha = mrrPoisha * 12;

    int totalCollectedPoisha = 0;
    for (final payment in _payments.values) {
      if (payment.status == 'verified') {
        totalCollectedPoisha += payment.amountPoisha;
      }
    }

    return {
      'mrrPoisha': mrrPoisha,
      'mrrBdt': mrrPoisha / 100.0,
      'arrPoisha': arrPoisha,
      'arrBdt': arrPoisha / 100.0,
      'totalCollectedPoisha': totalCollectedPoisha,
      'totalCollectedBdt': totalCollectedPoisha / 100.0,
      'activeSubscriptions': activeCount,
      'trialSubscriptions': trialCount,
      'overdueSubscriptions': overdueCount,
      'suspendedSubscriptions': suspendedCount,
      'totalPlans': _plans.length,
      'totalInvoices': _invoices.length,
      'totalPayments': _payments.length,
    };
  }
}
