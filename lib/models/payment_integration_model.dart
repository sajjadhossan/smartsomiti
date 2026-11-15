// lib/models/payment_integration_model.dart
// Enterprise Payment, Banking & Financial Integration Models

import 'dart:convert';

/// Supported Payment Providers & MFS
enum PaymentProviderType {
  sslcommerz,
  bkash,
  nagad,
  bankTransfer,
  cashCollection;

  String get labelBn {
    switch (this) {
      case PaymentProviderType.sslcommerz: return 'SSLCOMMERZ (কার্ড/ইন্টারনেট ব্যাংকিং)';
      case PaymentProviderType.bkash: return 'bKash মার্চেন্ট পেমেন্ট';
      case PaymentProviderType.nagad: return 'Nagad মার্চেন্ট পেমেন্ট';
      case PaymentProviderType.bankTransfer: return 'ব্যাংক ডিপোজিট / ওয়্যার ট্রান্সফার';
      case PaymentProviderType.cashCollection: return 'মাঠ পর্যায় নগদ ক্যাশ কালেকশন';
    }
  }

  static PaymentProviderType fromString(String val) {
    return PaymentProviderType.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => PaymentProviderType.bkash,
    );
  }
}

/// 12 Authoritative Payment Lifecycle States
enum PaymentLifecycleStatus {
  created,
  initiated,
  pending,
  processing,
  success,
  failed,
  cancelled,
  expired,
  refundPending,
  partiallyRefunded,
  refunded,
  disputed;

  String get labelBn {
    switch (this) {
      case PaymentLifecycleStatus.created: return 'সৃষ্ট (Created)';
      case PaymentLifecycleStatus.initiated: return 'সূচিত (Initiated)';
      case PaymentLifecycleStatus.pending: return 'অপেক্ষমান (Pending)';
      case PaymentLifecycleStatus.processing: return 'প্রক্রিয়াধীন (Processing)';
      case PaymentLifecycleStatus.success: return 'সফল (Success)';
      case PaymentLifecycleStatus.failed: return 'ব্যর্থ (Failed)';
      case PaymentLifecycleStatus.cancelled: return 'বাতিল (Cancelled)';
      case PaymentLifecycleStatus.expired: return 'মেয়াদোত্তীর্ণ (Expired)';
      case PaymentLifecycleStatus.refundPending: return 'রিফান্ড অপেক্ষমান';
      case PaymentLifecycleStatus.partiallyRefunded: return 'আংশিক রিফান্ডকৃত';
      case PaymentLifecycleStatus.refunded: return 'সম্পূর্ণ রিফান্ডকৃত';
      case PaymentLifecycleStatus.disputed: return 'বিরোধপূর্ণ (Disputed)';
    }
  }

  static PaymentLifecycleStatus fromString(String val) {
    return PaymentLifecycleStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => PaymentLifecycleStatus.pending,
    );
  }
}

/// Purpose of Financial Transaction
enum PaymentPurposeType {
  memberSavingsDeposit,
  loanInstallmentRepayment,
  membershipFee,
  shareCapital,
  saasSubscriptionFee,
  generalIncome;

  String get labelBn {
    switch (this) {
      case PaymentPurposeType.memberSavingsDeposit: return 'সদস্য সঞ্চয় জমা';
      case PaymentPurposeType.loanInstallmentRepayment: return 'ঋণের কিস্তি পরিশোধ';
      case PaymentPurposeType.membershipFee: return 'ভর্তি ও সদস্য ফি';
      case PaymentPurposeType.shareCapital: return 'শেয়ার মূলধন ক্রয়';
      case PaymentPurposeType.saasSubscriptionFee: return 'SaaS সফটওয়্যার ফি';
      case PaymentPurposeType.generalIncome: return 'বিবিধ সাধারণ আয়';
    }
  }

  static PaymentPurposeType fromString(String val) {
    return PaymentPurposeType.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => PaymentPurposeType.memberSavingsDeposit,
    );
  }
}

/// Gateway Configuration Model
class PaymentProviderConfigModel {
  final String providerId;
  final PaymentProviderType providerType;
  final String titleBn;
  final String merchantIdMasked;
  final bool isEnabled;
  final bool isSandbox;
  final int minAmountPoisha;
  final int maxAmountPoisha;
  final int feeBps; // Basis Points, e.g. 150 = 1.5%

  const PaymentProviderConfigModel({
    required this.providerId,
    required this.providerType,
    required this.titleBn,
    required this.merchantIdMasked,
    this.isEnabled = true,
    this.isSandbox = true,
    this.minAmountPoisha = 1000, // ৳10
    this.maxAmountPoisha = 10000000, // ৳100,000
    this.feeBps = 150,
  });

  Map<String, dynamic> toMap() => {
    'providerId': providerId,
    'providerType': providerType.name,
    'titleBn': titleBn,
    'merchantIdMasked': merchantIdMasked,
    'isEnabled': isEnabled,
    'isSandbox': isSandbox,
    'minAmountPoisha': minAmountPoisha,
    'maxAmountPoisha': maxAmountPoisha,
    'feeBps': feeBps,
  };

  factory PaymentProviderConfigModel.fromMap(Map<String, dynamic> map, String id) {
    return PaymentProviderConfigModel(
      providerId: id,
      providerType: PaymentProviderType.fromString(map['providerType'] as String? ?? 'bkash'),
      titleBn: map['titleBn'] as String? ?? '',
      merchantIdMasked: map['merchantIdMasked'] as String? ?? '',
      isEnabled: map['isEnabled'] as bool? ?? true,
      isSandbox: map['isSandbox'] as bool? ?? true,
      minAmountPoisha: (map['minAmountPoisha'] as num?)?.toInt() ?? 1000,
      maxAmountPoisha: (map['maxAmountPoisha'] as num?)?.toInt() ?? 10000000,
      feeBps: (map['feeBps'] as num?)?.toInt() ?? 150,
    );
  }
}

/// Core Payment Transaction Model
class PaymentTransactionModel {
  final String id;
  final PaymentProviderType providerType;
  final String? providerTxnId;
  final String societyId;
  final String? memberId;
  final PaymentPurposeType purpose;
  final int amountPoisha;
  final int feePoisha;
  final int netAmountPoisha;
  final PaymentLifecycleStatus status;
  final String idempotencyKey;
  final String? qrTokenUuid;
  final String? linkedVoucherId;
  final String? collectorId;
  final String? verifiedBy;
  final DateTime createdAt;
  final DateTime? verifiedAt;

  const PaymentTransactionModel({
    required this.id,
    required this.providerType,
    this.providerTxnId,
    required this.societyId,
    this.memberId,
    required this.purpose,
    required this.amountPoisha,
    this.feePoisha = 0,
    required this.netAmountPoisha,
    required this.status,
    required this.idempotencyKey,
    this.qrTokenUuid,
    this.linkedVoucherId,
    this.collectorId,
    this.verifiedBy,
    required this.createdAt,
    this.verifiedAt,
  });

  double get amountBdt => amountPoisha / 100.0;
  double get feeBdt => feePoisha / 100.0;
  double get netAmountBdt => netAmountPoisha / 100.0;
  bool get isSuccess => status == PaymentLifecycleStatus.success;

  Map<String, dynamic> toMap() => {
    'id': id,
    'providerType': providerType.name,
    'providerTxnId': providerTxnId,
    'societyId': societyId,
    'memberId': memberId,
    'purpose': purpose.name,
    'amountPoisha': amountPoisha,
    'feePoisha': feePoisha,
    'netAmountPoisha': netAmountPoisha,
    'status': status.name,
    'idempotencyKey': idempotencyKey,
    'qrTokenUuid': qrTokenUuid,
    'linkedVoucherId': linkedVoucherId,
    'collectorId': collectorId,
    'verifiedBy': verifiedBy,
    'createdAt': createdAt.toIso8601String(),
    'verifiedAt': verifiedAt?.toIso8601String(),
  };

  factory PaymentTransactionModel.fromMap(Map<String, dynamic> map, String id) {
    return PaymentTransactionModel(
      id: id,
      providerType: PaymentProviderType.fromString(map['providerType'] as String? ?? 'bkash'),
      providerTxnId: map['providerTxnId'] as String?,
      societyId: map['societyId'] as String? ?? '',
      memberId: map['memberId'] as String?,
      purpose: PaymentPurposeType.fromString(map['purpose'] as String? ?? 'memberSavingsDeposit'),
      amountPoisha: (map['amountPoisha'] as num?)?.toInt() ?? 0,
      feePoisha: (map['feePoisha'] as num?)?.toInt() ?? 0,
      netAmountPoisha: (map['netAmountPoisha'] as num?)?.toInt() ?? 0,
      status: PaymentLifecycleStatus.fromString(map['status'] as String? ?? 'pending'),
      idempotencyKey: map['idempotencyKey'] as String? ?? '',
      qrTokenUuid: map['qrTokenUuid'] as String?,
      linkedVoucherId: map['linkedVoucherId'] as String?,
      collectorId: map['collectorId'] as String?,
      verifiedBy: map['verifiedBy'] as String?,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
      verifiedAt: map['verifiedAt'] != null ? DateTime.tryParse(map['verifiedAt'] as String) : null,
    );
  }
}

/// Society Commercial Bank Account
class SocietyBankAccountModel {
  final String id;
  final String societyId;
  final String bankName;
  final String branchName;
  final String accountName;
  final String accountNumberMasked;
  final String? routingNumber;
  final String linkedGlAccountId; // e.g. 1120
  final int currentBalancePoisha;
  final bool isActive;

  const SocietyBankAccountModel({
    required this.id,
    required this.societyId,
    required this.bankName,
    required this.branchName,
    required this.accountName,
    required this.accountNumberMasked,
    this.routingNumber,
    required this.linkedGlAccountId,
    this.currentBalancePoisha = 0,
    this.isActive = true,
  });

  double get currentBalanceBdt => currentBalancePoisha / 100.0;

  Map<String, dynamic> toMap() => {
    'id': id,
    'societyId': societyId,
    'bankName': bankName,
    'branchName': branchName,
    'accountName': accountName,
    'accountNumberMasked': accountNumberMasked,
    'routingNumber': routingNumber,
    'linkedGlAccountId': linkedGlAccountId,
    'currentBalancePoisha': currentBalancePoisha,
    'isActive': isActive,
  };

  factory SocietyBankAccountModel.fromMap(Map<String, dynamic> map, String id) {
    return SocietyBankAccountModel(
      id: id,
      societyId: map['societyId'] as String? ?? '',
      bankName: map['bankName'] as String? ?? '',
      branchName: map['branchName'] as String? ?? '',
      accountName: map['accountName'] as String? ?? '',
      accountNumberMasked: map['accountNumberMasked'] as String? ?? '',
      routingNumber: map['routingNumber'] as String?,
      linkedGlAccountId: map['linkedGlAccountId'] as String? ?? '1120',
      currentBalancePoisha: (map['currentBalancePoisha'] as num?)?.toInt() ?? 0,
      isActive: map['isActive'] as bool? ?? true,
    );
  }
}

/// Bank Statement Line Item for Reconciliation
class BankStatementItemModel {
  final String id;
  final String bankAccountId;
  final String societyId;
  final DateTime txnDate;
  final String description;
  final int debitPoisha;
  final int creditPoisha;
  final int balancePoisha;
  final String matchStatus; // matched, probableMatch, unmatchedException
  final String? matchedVoucherId;

  const BankStatementItemModel({
    required this.id,
    required this.bankAccountId,
    required this.societyId,
    required this.txnDate,
    required this.description,
    this.debitPoisha = 0,
    this.creditPoisha = 0,
    required this.balancePoisha,
    this.matchStatus = 'unmatchedException',
    this.matchedVoucherId,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'bankAccountId': bankAccountId,
    'societyId': societyId,
    'txnDate': txnDate.toIso8601String(),
    'description': description,
    'debitPoisha': debitPoisha,
    'creditPoisha': creditPoisha,
    'balancePoisha': balancePoisha,
    'matchStatus': matchStatus,
    'matchedVoucherId': matchedVoucherId,
  };

  factory BankStatementItemModel.fromMap(Map<String, dynamic> map, String id) {
    return BankStatementItemModel(
      id: id,
      bankAccountId: map['bankAccountId'] as String? ?? '',
      societyId: map['societyId'] as String? ?? '',
      txnDate: DateTime.tryParse(map['txnDate'] as String? ?? '') ?? DateTime.now(),
      description: map['description'] as String? ?? '',
      debitPoisha: (map['debitPoisha'] as num?)?.toInt() ?? 0,
      creditPoisha: (map['creditPoisha'] as num?)?.toInt() ?? 0,
      balancePoisha: (map['balancePoisha'] as num?)?.toInt() ?? 0,
      matchStatus: map['matchStatus'] as String? ?? 'unmatchedException',
      matchedVoucherId: map['matchedVoucherId'] as String?,
    );
  }
}

/// Dynamic Bangla QR Token Model
class DynamicQrPaymentModel {
  final String tokenUuid;
  final String societyId;
  final String memberId;
  final PaymentPurposeType purpose;
  final int amountPoisha;
  final String qrPayload;
  final DateTime expiresAt;
  final bool isUsed;
  final DateTime? usedAt;

  const DynamicQrPaymentModel({
    required this.tokenUuid,
    required this.societyId,
    required this.memberId,
    required this.purpose,
    required this.amountPoisha,
    required this.qrPayload,
    required this.expiresAt,
    this.isUsed = false,
    this.usedAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isValid => !isUsed && !isExpired;

  Map<String, dynamic> toMap() => {
    'tokenUuid': tokenUuid,
    'societyId': societyId,
    'memberId': memberId,
    'purpose': purpose.name,
    'amountPoisha': amountPoisha,
    'qrPayload': qrPayload,
    'expiresAt': expiresAt.toIso8601String(),
    'isUsed': isUsed,
    'usedAt': usedAt?.toIso8601String(),
  };

  factory DynamicQrPaymentModel.fromMap(Map<String, dynamic> map, String tokenUuid) {
    return DynamicQrPaymentModel(
      tokenUuid: tokenUuid,
      societyId: map['societyId'] as String? ?? '',
      memberId: map['memberId'] as String? ?? '',
      purpose: PaymentPurposeType.fromString(map['purpose'] as String? ?? 'memberSavingsDeposit'),
      amountPoisha: (map['amountPoisha'] as num?)?.toInt() ?? 0,
      qrPayload: map['qrPayload'] as String? ?? '',
      expiresAt: DateTime.tryParse(map['expiresAt'] as String? ?? '') ?? DateTime.now().add(const Duration(minutes: 15)),
      isUsed: map['isUsed'] as bool? ?? false,
      usedAt: map['usedAt'] != null ? DateTime.tryParse(map['usedAt'] as String) : null,
    );
  }
}

/// Refund & Reversal Model
class PaymentRefundModel {
  final String id;
  final String originalTxnId;
  final String societyId;
  final int amountPoisha;
  final String reason;
  final String status; // pendingApproval, approved, refunded, rejected
  final String requestedBy;
  final String? approvedBy;
  final String? reversalVoucherId;
  final DateTime createdAt;

  const PaymentRefundModel({
    required this.id,
    required this.originalTxnId,
    required this.societyId,
    required this.amountPoisha,
    required this.reason,
    this.status = 'pendingApproval',
    required this.requestedBy,
    this.approvedBy,
    this.reversalVoucherId,
    required this.createdAt,
  });

  double get amountBdt => amountPoisha / 100.0;

  Map<String, dynamic> toMap() => {
    'id': id,
    'originalTxnId': originalTxnId,
    'societyId': societyId,
    'amountPoisha': amountPoisha,
    'reason': reason,
    'status': status,
    'requestedBy': requestedBy,
    'approvedBy': approvedBy,
    'reversalVoucherId': reversalVoucherId,
    'createdAt': createdAt.toIso8601String(),
  };

  factory PaymentRefundModel.fromMap(Map<String, dynamic> map, String id) {
    return PaymentRefundModel(
      id: id,
      originalTxnId: map['originalTxnId'] as String? ?? '',
      societyId: map['societyId'] as String? ?? '',
      amountPoisha: (map['amountPoisha'] as num?)?.toInt() ?? 0,
      reason: map['reason'] as String? ?? '',
      status: map['status'] as String? ?? 'pendingApproval',
      requestedBy: map['requestedBy'] as String? ?? '',
      approvedBy: map['approvedBy'] as String?,
      reversalVoucherId: map['reversalVoucherId'] as String?,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

/// Gateway Settlement Report
class GatewaySettlementModel {
  final String id;
  final PaymentProviderType providerType;
  final String societyId;
  final DateTime settlementDate;
  final int grossPoisha;
  final int mdrFeePoisha;
  final int netSettledPoisha;
  final String status; // pending, settledToBank, reconciled
  final String? bankDepositRef;

  const GatewaySettlementModel({
    required this.id,
    required this.providerType,
    required this.societyId,
    required this.settlementDate,
    required this.grossPoisha,
    required this.mdrFeePoisha,
    required this.netSettledPoisha,
    this.status = 'settledToBank',
    this.bankDepositRef,
  });

  double get grossBdt => grossPoisha / 100.0;
  double get mdrFeeBdt => mdrFeePoisha / 100.0;
  double get netSettledBdt => netSettledPoisha / 100.0;

  Map<String, dynamic> toMap() => {
    'id': id,
    'providerType': providerType.name,
    'societyId': societyId,
    'settlementDate': settlementDate.toIso8601String(),
    'grossPoisha': grossPoisha,
    'mdrFeePoisha': mdrFeePoisha,
    'netSettledPoisha': netSettledPoisha,
    'status': status,
    'bankDepositRef': bankDepositRef,
  };

  factory GatewaySettlementModel.fromMap(Map<String, dynamic> map, String id) {
    return GatewaySettlementModel(
      id: id,
      providerType: PaymentProviderType.fromString(map['providerType'] as String? ?? 'bkash'),
      societyId: map['societyId'] as String? ?? '',
      settlementDate: DateTime.tryParse(map['settlementDate'] as String? ?? '') ?? DateTime.now(),
      grossPoisha: (map['grossPoisha'] as num?)?.toInt() ?? 0,
      mdrFeePoisha: (map['mdrFeePoisha'] as num?)?.toInt() ?? 0,
      netSettledPoisha: (map['netSettledPoisha'] as num?)?.toInt() ?? 0,
      status: map['status'] as String? ?? 'settledToBank',
      bankDepositRef: map['bankDepositRef'] as String?,
    );
  }
}
