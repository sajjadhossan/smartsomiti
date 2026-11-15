// lib/models/saas_subscription_model.dart
// Enterprise SaaS Subscription, Plan Entitlement, Invoicing & Billing Models

import 'dart:convert';

/// Supported billing cycles for SaaS subscriptions
enum SaasBillingCycle {
  monthly,
  quarterly,
  semiAnnual,
  annual,
  lifetime;

  String get key => name;

  String get labelBn {
    switch (this) {
      case SaasBillingCycle.monthly:
        return 'মাসিক';
      case SaasBillingCycle.quarterly:
        return 'ত্রৈমাসিক';
      case SaasBillingCycle.semiAnnual:
        return 'ষাণ্মাসিক';
      case SaasBillingCycle.annual:
        return 'বার্ষিক';
      case SaasBillingCycle.lifetime:
        return 'আজীবন';
    }
  }

  static SaasBillingCycle fromString(String val) {
    return SaasBillingCycle.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => SaasBillingCycle.monthly,
    );
  }
}

/// 13 Strict Lifecycle States for SaaS Subscriptions
enum SaasSubscriptionStatus {
  trialing,
  active,
  pendingPayment,
  pendingActivation,
  upcomingRenewal,
  renewalDue,
  paymentOverdue,
  gracePeriod,
  suspended,
  cancelled,
  expired,
  reactivated,
  upgradedDowngraded;

  String get key => name;

  String get labelBn {
    switch (this) {
      case SaasSubscriptionStatus.trialing:
        return 'ট্রায়াল চলমান';
      case SaasSubscriptionStatus.active:
        return 'সক্রিয়';
      case SaasSubscriptionStatus.pendingPayment:
        return 'পেমেন্ট অপেক্ষমান';
      case SaasSubscriptionStatus.pendingActivation:
        return 'অ্যাক্টিভেশন বাকি';
      case SaasSubscriptionStatus.upcomingRenewal:
        return 'নবায়ন আসন্ন';
      case SaasSubscriptionStatus.renewalDue:
        return 'নবায়নের তারিখ উপস্থিত';
      case SaasSubscriptionStatus.paymentOverdue:
        return 'বিল বকেয়া';
      case SaasSubscriptionStatus.gracePeriod:
        return 'গ্রেস পিরিয়ড';
      case SaasSubscriptionStatus.suspended:
        return 'স্থগিত (Suspended)';
      case SaasSubscriptionStatus.cancelled:
        return 'বাতিলকৃত';
      case SaasSubscriptionStatus.expired:
        return 'মেয়াদোত্তীর্ণ';
      case SaasSubscriptionStatus.reactivated:
        return 'পুনঃসক্রিয়কৃত';
      case SaasSubscriptionStatus.upgradedDowngraded:
        return 'প্ল্যান পরিবর্তিত';
    }
  }

  static SaasSubscriptionStatus fromString(String val) {
    return SaasSubscriptionStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => SaasSubscriptionStatus.pendingPayment,
    );
  }
}

/// Commercial SaaS Tier Plan
class SaasPlanModel {
  final String id;
  final String tier; // starter, standard, premium, enterprise
  final String nameEn;
  final String nameBn;
  final String descriptionBn;
  final int monthlyFeePoisha; // 1 BDT = 100 Poisha
  final int quarterlyFeePoisha;
  final int annualFeePoisha;
  final int maxMembers; // -1 for unlimited
  final int maxStaffUsers;
  final int storageMb;
  final List<String> allowedModules;
  final Map<String, bool> featureToggles;
  final bool isActive;
  final bool isPublic;
  final int trialDays;

  const SaasPlanModel({
    required this.id,
    required this.tier,
    required this.nameEn,
    required this.nameBn,
    required this.descriptionBn,
    required this.monthlyFeePoisha,
    required this.quarterlyFeePoisha,
    required this.annualFeePoisha,
    required this.maxMembers,
    required this.maxStaffUsers,
    required this.storageMb,
    required this.allowedModules,
    this.featureToggles = const {},
    this.isActive = true,
    this.isPublic = true,
    this.trialDays = 14,
  });

  double get monthlyFeeBdt => monthlyFeePoisha / 100.0;
  double get quarterlyFeeBdt => quarterlyFeePoisha / 100.0;
  double get annualFeeBdt => annualFeePoisha / 100.0;

  Map<String, dynamic> toMap() => {
    'id': id,
    'tier': tier,
    'nameEn': nameEn,
    'nameBn': nameBn,
    'descriptionBn': descriptionBn,
    'monthlyFeePoisha': monthlyFeePoisha,
    'quarterlyFeePoisha': quarterlyFeePoisha,
    'annualFeePoisha': annualFeePoisha,
    'maxMembers': maxMembers,
    'maxStaffUsers': maxStaffUsers,
    'storageMb': storageMb,
    'allowedModules': allowedModules,
    'featureToggles': featureToggles,
    'isActive': isActive,
    'isPublic': isPublic,
    'trialDays': trialDays,
  };

  factory SaasPlanModel.fromMap(Map<String, dynamic> map, String id) {
    return SaasPlanModel(
      id: id,
      tier: map['tier'] as String? ?? 'starter',
      nameEn: map['nameEn'] as String? ?? '',
      nameBn: map['nameBn'] as String? ?? '',
      descriptionBn: map['descriptionBn'] as String? ?? '',
      monthlyFeePoisha: (map['monthlyFeePoisha'] as num?)?.toInt() ?? 0,
      quarterlyFeePoisha: (map['quarterlyFeePoisha'] as num?)?.toInt() ?? 0,
      annualFeePoisha: (map['annualFeePoisha'] as num?)?.toInt() ?? 0,
      maxMembers: (map['maxMembers'] as num?)?.toInt() ?? 100,
      maxStaffUsers: (map['maxStaffUsers'] as num?)?.toInt() ?? 3,
      storageMb: (map['storageMb'] as num?)?.toInt() ?? 1024,
      allowedModules: List<String>.from(map['allowedModules'] ?? []),
      featureToggles: Map<String, bool>.from(map['featureToggles'] ?? {}),
      isActive: map['isActive'] as bool? ?? true,
      isPublic: map['isPublic'] as bool? ?? true,
      trialDays: (map['trialDays'] as num?)?.toInt() ?? 14,
    );
  }

  /// Default Bangladeshi Tier Catalog
  static List<SaasPlanModel> defaultPlans() => [
    const SaasPlanModel(
      id: 'plan_starter',
      tier: 'starter',
      nameEn: 'Starter',
      nameBn: 'স্টার্টার',
      descriptionBn: 'ছোট ও নতুন সমবায় সমিতির জন্য উপযুক্ত সাশ্রয়ী প্যাকেজ',
      monthlyFeePoisha: 99900, // ৳999
      quarterlyFeePoisha: 279900, // ৳2,799
      annualFeePoisha: 999900, // ৳9,999
      maxMembers: 150,
      maxStaffUsers: 3,
      storageMb: 2048,
      allowedModules: ['members', 'savings', 'loans', 'cashbook', 'sms_basic'],
      featureToggles: {'double_entry': false, 'multi_level_approval': false},
      trialDays: 14,
    ),
    const SaasPlanModel(
      id: 'plan_standard',
      tier: 'standard',
      nameEn: 'Standard',
      nameBn: 'স্ট্যান্ডার্ড',
      descriptionBn: 'মাঝারি সমবায় সমিতির জন্য সম্পূর্ণ ফিচারসমৃদ্ধ প্যাকেজ',
      monthlyFeePoisha: 199900, // ৳1,999
      quarterlyFeePoisha: 549900, // ৳5,499
      annualFeePoisha: 1999900, // ৳19,999
      maxMembers: 500,
      maxStaffUsers: 7,
      storageMb: 5120,
      allowedModules: ['members', 'savings', 'loans', 'cashbook', 'double_entry_accounting', 'reports', 'sms_gateway'],
      featureToggles: {'double_entry': true, 'multi_level_approval': true},
      trialDays: 14,
    ),
    const SaasPlanModel(
      id: 'plan_premium',
      tier: 'premium',
      nameEn: 'Premium',
      nameBn: 'প্রিমিয়াম',
      descriptionBn: 'বড় ও বহু-শাখা সমবায় সমিতির জন্য উন্নত অটোমেশন ও সিকিউরিটি',
      monthlyFeePoisha: 399900, // ৳3,999
      quarterlyFeePoisha: 1099900, // ৳10,999
      annualFeePoisha: 3999900, // ৳39,999
      maxMembers: 2000,
      maxStaffUsers: 20,
      storageMb: 15360,
      allowedModules: ['members', 'savings', 'loans', 'cashbook', 'double_entry_accounting', 'approvals_workflow', 'security_compliance', 'sms_gateway', 'audit_vault'],
      featureToggles: {'double_entry': true, 'multi_level_approval': true, 'audit_vault': true},
      trialDays: 14,
    ),
    const SaasPlanModel(
      id: 'plan_enterprise',
      tier: 'enterprise',
      nameEn: 'Enterprise',
      nameBn: 'এন্টারপ্রাইজ',
      descriptionBn: 'সর্বোচ্চ স্কেল, আনলিমিটেড মেম্বার, কাস্টম ব্যাকআপ ও ডেডিকেটেড সাপোর্ট',
      monthlyFeePoisha: 799900, // ৳7,999
      quarterlyFeePoisha: 2199900, // ৳21,999
      annualFeePoisha: 7999900, // ৳79,999
      maxMembers: -1, // Unlimited
      maxStaffUsers: -1,
      storageMb: 51200,
      allowedModules: ['members', 'savings', 'loans', 'cashbook', 'double_entry_accounting', 'approvals_workflow', 'security_compliance', 'sms_gateway', 'audit_vault', 'custom_reports', 'api_access'],
      featureToggles: {'double_entry': true, 'multi_level_approval': true, 'audit_vault': true, 'api_access': true},
      trialDays: 30,
    ),
  ];
}

/// Society Active Subscription Record
class SocietySubscriptionModel {
  final String id;
  final String societyId;
  final String planId;
  final SaasSubscriptionStatus status;
  final SaasBillingCycle billingCycle;
  final DateTime currentPeriodStart;
  final DateTime currentPeriodEnd;
  final DateTime? trialEndsAt;
  final DateTime? gracePeriodEndsAt;
  final bool isAutoRenew;
  final Map<String, dynamic> customLimits;
  final Map<String, dynamic> metadata;

  const SocietySubscriptionModel({
    required this.id,
    required this.societyId,
    required this.planId,
    required this.status,
    required this.billingCycle,
    required this.currentPeriodStart,
    required this.currentPeriodEnd,
    this.trialEndsAt,
    this.gracePeriodEndsAt,
    this.isAutoRenew = true,
    this.customLimits = const {},
    this.metadata = const {},
  });

  bool get isActiveOrTrial =>
      status == SaasSubscriptionStatus.active ||
      status == SaasSubscriptionStatus.trialing ||
      status == SaasSubscriptionStatus.upcomingRenewal ||
      status == SaasSubscriptionStatus.gracePeriod;

  bool get isSuspendedOrExpired =>
      status == SaasSubscriptionStatus.suspended ||
      status == SaasSubscriptionStatus.expired ||
      status == SaasSubscriptionStatus.cancelled;

  int get daysUntilExpiry {
    final now = DateTime.now();
    return currentPeriodEnd.difference(now).inDays;
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'societyId': societyId,
    'planId': planId,
    'status': status.name,
    'billingCycle': billingCycle.name,
    'currentPeriodStart': currentPeriodStart.toIso8601String(),
    'currentPeriodEnd': currentPeriodEnd.toIso8601String(),
    'trialEndsAt': trialEndsAt?.toIso8601String(),
    'gracePeriodEndsAt': gracePeriodEndsAt?.toIso8601String(),
    'isAutoRenew': isAutoRenew,
    'customLimits': customLimits,
    'metadata': metadata,
  };

  factory SocietySubscriptionModel.fromMap(Map<String, dynamic> map, String id) {
    return SocietySubscriptionModel(
      id: id,
      societyId: map['societyId'] as String? ?? '',
      planId: map['planId'] as String? ?? 'plan_starter',
      status: SaasSubscriptionStatus.fromString(map['status'] as String? ?? 'active'),
      billingCycle: SaasBillingCycle.fromString(map['billingCycle'] as String? ?? 'monthly'),
      currentPeriodStart: DateTime.tryParse(map['currentPeriodStart'] as String? ?? '') ?? DateTime.now(),
      currentPeriodEnd: DateTime.tryParse(map['currentPeriodEnd'] as String? ?? '') ?? DateTime.now().add(const Duration(days: 30)),
      trialEndsAt: map['trialEndsAt'] != null ? DateTime.tryParse(map['trialEndsAt'] as String) : null,
      gracePeriodEndsAt: map['gracePeriodEndsAt'] != null ? DateTime.tryParse(map['gracePeriodEndsAt'] as String) : null,
      isAutoRenew: map['isAutoRenew'] as bool? ?? true,
      customLimits: Map<String, dynamic>.from(map['customLimits'] ?? {}),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }
}

/// SaaS Commercial Invoicing Model
class SaasInvoiceModel {
  final String id;
  final String invoiceNumber; // INV-202611-00001
  final String societyId;
  final String? subscriptionId;
  final String planId;
  final SaasBillingCycle billingCycle;
  final int subtotalPoisha;
  final int discountPoisha;
  final int taxPoisha;
  final int totalPoisha;
  final String status; // draft, pending_payment, paid, void, refunded
  final DateTime issuedAt;
  final DateTime dueAt;
  final DateTime? paidAt;
  final String? paymentMethod;
  final String? transactionRef;
  final String? notes;

  const SaasInvoiceModel({
    required this.id,
    required this.invoiceNumber,
    required this.societyId,
    this.subscriptionId,
    required this.planId,
    required this.billingCycle,
    required this.subtotalPoisha,
    required this.discountPoisha,
    required this.taxPoisha,
    required this.totalPoisha,
    required this.status,
    required this.issuedAt,
    required this.dueAt,
    this.paidAt,
    this.paymentMethod,
    this.transactionRef,
    this.notes,
  });

  double get subtotalBdt => subtotalPoisha / 100.0;
  double get discountBdt => discountPoisha / 100.0;
  double get taxBdt => taxPoisha / 100.0;
  double get totalBdt => totalPoisha / 100.0;

  bool get isPaid => status == 'paid';

  Map<String, dynamic> toMap() => {
    'id': id,
    'invoiceNumber': invoiceNumber,
    'societyId': societyId,
    'subscriptionId': subscriptionId,
    'planId': planId,
    'billingCycle': billingCycle.name,
    'subtotalPoisha': subtotalPoisha,
    'discountPoisha': discountPoisha,
    'taxPoisha': taxPoisha,
    'totalPoisha': totalPoisha,
    'status': status,
    'issuedAt': issuedAt.toIso8601String(),
    'dueAt': dueAt.toIso8601String(),
    'paidAt': paidAt?.toIso8601String(),
    'paymentMethod': paymentMethod,
    'transactionRef': transactionRef,
    'notes': notes,
  };

  factory SaasInvoiceModel.fromMap(Map<String, dynamic> map, String id) {
    return SaasInvoiceModel(
      id: id,
      invoiceNumber: map['invoiceNumber'] as String? ?? id,
      societyId: map['societyId'] as String? ?? '',
      subscriptionId: map['subscriptionId'] as String?,
      planId: map['planId'] as String? ?? '',
      billingCycle: SaasBillingCycle.fromString(map['billingCycle'] as String? ?? 'monthly'),
      subtotalPoisha: (map['subtotalPoisha'] as num?)?.toInt() ?? 0,
      discountPoisha: (map['discountPoisha'] as num?)?.toInt() ?? 0,
      taxPoisha: (map['taxPoisha'] as num?)?.toInt() ?? 0,
      totalPoisha: (map['totalPoisha'] as num?)?.toInt() ?? 0,
      status: map['status'] as String? ?? 'pending_payment',
      issuedAt: DateTime.tryParse(map['issuedAt'] as String? ?? '') ?? DateTime.now(),
      dueAt: DateTime.tryParse(map['dueAt'] as String? ?? '') ?? DateTime.now(),
      paidAt: map['paidAt'] != null ? DateTime.tryParse(map['paidAt'] as String) : null,
      paymentMethod: map['paymentMethod'] as String?,
      transactionRef: map['transactionRef'] as String?,
      notes: map['notes'] as String?,
    );
  }
}

/// SaaS Gateway Payment Verification Model
class SaasPaymentModel {
  final String id;
  final String invoiceId;
  final String societyId;
  final int amountPoisha;
  final String gateway; // bkash, nagad, sslcommerz, bank_transfer, cash
  final String transactionRef;
  final String idempotencyKey;
  final String status; // pending, verified, failed, refunded
  final DateTime createdAt;
  final DateTime? verifiedAt;
  final String? verifiedBy;
  final Map<String, dynamic>? rawResponse;

  const SaasPaymentModel({
    required this.id,
    required this.invoiceId,
    required this.societyId,
    required this.amountPoisha,
    required this.gateway,
    required this.transactionRef,
    required this.idempotencyKey,
    required this.status,
    required this.createdAt,
    this.verifiedAt,
    this.verifiedBy,
    this.rawResponse,
  });

  double get amountBdt => amountPoisha / 100.0;

  Map<String, dynamic> toMap() => {
    'id': id,
    'invoiceId': invoiceId,
    'societyId': societyId,
    'amountPoisha': amountPoisha,
    'gateway': gateway,
    'transactionRef': transactionRef,
    'idempotencyKey': idempotencyKey,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
    'verifiedAt': verifiedAt?.toIso8601String(),
    'verifiedBy': verifiedBy,
    'rawResponse': rawResponse,
  };

  factory SaasPaymentModel.fromMap(Map<String, dynamic> map, String id) {
    return SaasPaymentModel(
      id: id,
      invoiceId: map['invoiceId'] as String? ?? '',
      societyId: map['societyId'] as String? ?? '',
      amountPoisha: (map['amountPoisha'] as num?)?.toInt() ?? 0,
      gateway: map['gateway'] as String? ?? 'bkash',
      transactionRef: map['transactionRef'] as String? ?? '',
      idempotencyKey: map['idempotencyKey'] as String? ?? '',
      status: map['status'] as String? ?? 'pending',
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
      verifiedAt: map['verifiedAt'] != null ? DateTime.tryParse(map['verifiedAt'] as String) : null,
      verifiedBy: map['verifiedBy'] as String?,
      rawResponse: map['rawResponse'] != null ? Map<String, dynamic>.from(map['rawResponse'] as Map) : null,
    );
  }
}

/// Promotional & Discount Coupon Model
class SaasCouponModel {
  final String code;
  final double discountPercent; // e.g. 10.0 for 10%
  final int fixedDiscountPoisha; // or fixed amount
  final DateTime validFrom;
  final DateTime validUntil;
  final int maxUses;
  final int usedCount;
  final bool isActive;

  const SaasCouponModel({
    required this.code,
    this.discountPercent = 0.0,
    this.fixedDiscountPoisha = 0,
    required this.validFrom,
    required this.validUntil,
    this.maxUses = 100,
    this.usedCount = 0,
    this.isActive = true,
  });

  bool get isValid {
    final now = DateTime.now();
    return isActive && now.isAfter(validFrom) && now.isBefore(validUntil) && (maxUses < 0 || usedCount < maxUses);
  }

  int calculateDiscount(int baseAmountPoisha) {
    if (!isValid) return 0;
    if (fixedDiscountPoisha > 0) {
      return fixedDiscountPoisha > baseAmountPoisha ? baseAmountPoisha : fixedDiscountPoisha;
    }
    if (discountPercent > 0) {
      final discount = (baseAmountPoisha * (discountPercent / 100.0)).round();
      return discount > baseAmountPoisha ? baseAmountPoisha : discount;
    }
    return 0;
  }

  Map<String, dynamic> toMap() => {
    'code': code,
    'discountPercent': discountPercent,
    'fixedDiscountPoisha': fixedDiscountPoisha,
    'validFrom': validFrom.toIso8601String(),
    'validUntil': validUntil.toIso8601String(),
    'maxUses': maxUses,
    'usedCount': usedCount,
    'isActive': isActive,
  };

  factory SaasCouponModel.fromMap(Map<String, dynamic> map, String code) {
    return SaasCouponModel(
      code: code,
      discountPercent: (map['discountPercent'] as num?)?.toDouble() ?? 0.0,
      fixedDiscountPoisha: (map['fixedDiscountPoisha'] as num?)?.toInt() ?? 0,
      validFrom: DateTime.tryParse(map['validFrom'] as String? ?? '') ?? DateTime.now(),
      validUntil: DateTime.tryParse(map['validUntil'] as String? ?? '') ?? DateTime.now().add(const Duration(days: 365)),
      maxUses: (map['maxUses'] as num?)?.toInt() ?? 100,
      usedCount: (map['usedCount'] as num?)?.toInt() ?? 0,
      isActive: map['isActive'] as bool? ?? true,
    );
  }
}
