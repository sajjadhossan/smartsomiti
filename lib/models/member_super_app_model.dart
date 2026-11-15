// lib/models/member_super_app_model.dart
// Phase 18: Enterprise Member Super App & Digital Self-Service Ecosystem Models

import 'package:cloud_firestore/cloud_firestore.dart';

enum MemberAccountStatus {
  pendingVerification,
  active,
  suspended,
  closed,
}

enum MemberKycStatus {
  notSubmitted,
  pendingReview,
  verified,
  rejected,
}

/// Digital Membership Card Model with Signed Token
class DigitalMemberCardModel {
  final String cardId;
  final String memberId;
  final String memberName;
  final String memberNumber;
  final String societyId;
  final String societyName;
  final String photoUrl;
  final DateTime issueDate;
  final DateTime expiryDate;
  final String qrToken;
  final bool isRevoked;
  final String bloodGroup;
  final String emergencyPhone;

  const DigitalMemberCardModel({
    required this.cardId,
    required this.memberId,
    required this.memberName,
    required this.memberNumber,
    required this.societyId,
    required this.societyName,
    this.photoUrl = '',
    required this.issueDate,
    required this.expiryDate,
    required this.qrToken,
    this.isRevoked = false,
    this.bloodGroup = 'O+',
    this.emergencyPhone = '',
  });

  bool get isValid => !isRevoked && DateTime.now().isBefore(expiryDate);

  Map<String, dynamic> toMap() {
    return {
      'cardId': cardId,
      'memberId': memberId,
      'memberName': memberName,
      'memberNumber': memberNumber,
      'societyId': societyId,
      'societyName': societyName,
      'photoUrl': photoUrl,
      'issueDate': Timestamp.fromDate(issueDate),
      'expiryDate': Timestamp.fromDate(expiryDate),
      'qrToken': qrToken,
      'isRevoked': isRevoked,
      'bloodGroup': bloodGroup,
      'emergencyPhone': emergencyPhone,
    };
  }

  factory DigitalMemberCardModel.fromMap(Map<String, dynamic> map, String id) {
    return DigitalMemberCardModel(
      cardId: map['cardId'] ?? id,
      memberId: map['memberId'] ?? '',
      memberName: map['memberName'] ?? '',
      memberNumber: map['memberNumber'] ?? '',
      societyId: map['societyId'] ?? '',
      societyName: map['societyName'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      issueDate: (map['issueDate'] is Timestamp) ? (map['issueDate'] as Timestamp).toDate() : DateTime.now(),
      expiryDate: (map['expiryDate'] is Timestamp) ? (map['expiryDate'] as Timestamp).toDate() : DateTime.now().add(const Duration(days: 365)),
      qrToken: map['qrToken'] ?? '',
      isRevoked: map['isRevoked'] ?? false,
      bloodGroup: map['bloodGroup'] ?? 'O+',
      emergencyPhone: map['emergencyPhone'] ?? '',
    );
  }
}

/// Member Savings Summary Model
class MemberSavingsSummaryModel {
  final int totalSavingsPoisha;
  final int regularSavingsPoisha;
  final int dpsSavingsPoisha;
  final int shareCapitalPoisha;
  final int availableWithdrawalPoisha;

  const MemberSavingsSummaryModel({
    required this.totalSavingsPoisha,
    required this.regularSavingsPoisha,
    required this.dpsSavingsPoisha,
    required this.shareCapitalPoisha,
    required this.availableWithdrawalPoisha,
  });

  double get totalSavingsTaka => totalSavingsPoisha / 100.0;
  double get availableWithdrawalTaka => availableWithdrawalPoisha / 100.0;

  Map<String, dynamic> toMap() {
    return {
      'totalSavingsPoisha': totalSavingsPoisha,
      'regularSavingsPoisha': regularSavingsPoisha,
      'dpsSavingsPoisha': dpsSavingsPoisha,
      'shareCapitalPoisha': shareCapitalPoisha,
      'availableWithdrawalPoisha': availableWithdrawalPoisha,
    };
  }
}

/// Member Loan Summary Model
class MemberLoanSummaryModel {
  final int activeLoansCount;
  final int totalPrincipalOutstandingPoisha;
  final int totalInterestOutstandingPoisha;
  final DateTime? nextInstallmentDate;
  final int nextInstallmentAmountPoisha;

  const MemberLoanSummaryModel({
    required this.activeLoansCount,
    required this.totalPrincipalOutstandingPoisha,
    required this.totalInterestOutstandingPoisha,
    this.nextInstallmentDate,
    required this.nextInstallmentAmountPoisha,
  });

  double get totalOutstandingTaka => (totalPrincipalOutstandingPoisha + totalInterestOutstandingPoisha) / 100.0;
  double get nextInstallmentAmountTaka => nextInstallmentAmountPoisha / 100.0;

  Map<String, dynamic> toMap() {
    return {
      'activeLoansCount': activeLoansCount,
      'totalPrincipalOutstandingPoisha': totalPrincipalOutstandingPoisha,
      'totalInterestOutstandingPoisha': totalInterestOutstandingPoisha,
      'nextInstallmentDate': nextInstallmentDate != null ? Timestamp.fromDate(nextInstallmentDate!) : null,
      'nextInstallmentAmountPoisha': nextInstallmentAmountPoisha,
    };
  }
}

/// Member Withdrawal Request Model (Maker-Checker Enforced)
class MemberWithdrawalRequestModel {
  final String requestId;
  final String memberId;
  final String societyId;
  final int amountPoisha;
  final String reason;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime submittedAt;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? rejectionReason;

  const MemberWithdrawalRequestModel({
    required this.requestId,
    required this.memberId,
    required this.societyId,
    required this.amountPoisha,
    required this.reason,
    this.status = 'pending',
    required this.submittedAt,
    this.reviewedBy,
    this.reviewedAt,
    this.rejectionReason,
  });

  double get amountTaka => amountPoisha / 100.0;

  Map<String, dynamic> toMap() {
    return {
      'requestId': requestId,
      'memberId': memberId,
      'societyId': societyId,
      'amountPoisha': amountPoisha,
      'reason': reason,
      'status': status,
      'submittedAt': Timestamp.fromDate(submittedAt),
      'reviewedBy': reviewedBy,
      'reviewedAt': reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
      'rejectionReason': rejectionReason,
    };
  }

  factory MemberWithdrawalRequestModel.fromMap(Map<String, dynamic> map, String id) {
    return MemberWithdrawalRequestModel(
      requestId: map['requestId'] ?? id,
      memberId: map['memberId'] ?? '',
      societyId: map['societyId'] ?? '',
      amountPoisha: map['amountPoisha'] ?? 0,
      reason: map['reason'] ?? '',
      status: map['status'] ?? 'pending',
      submittedAt: (map['submittedAt'] is Timestamp) ? (map['submittedAt'] as Timestamp).toDate() : DateTime.now(),
      reviewedBy: map['reviewedBy'],
      reviewedAt: (map['reviewedAt'] is Timestamp) ? (map['reviewedAt'] as Timestamp).toDate() : null,
      rejectionReason: map['rejectionReason'],
    );
  }
}

/// Member Loan Application Model
class MemberLoanApplicationModel {
  final String applicationId;
  final String memberId;
  final String societyId;
  final int requestedAmountPoisha;
  final int termMonths;
  final String purpose;
  final String guarantorMemberId;
  final String status; // 'draft', 'submitted', 'under_review', 'approved', 'rejected'
  final DateTime submittedAt;
  final DateTime? approvedAt;
  final String? notes;

  const MemberLoanApplicationModel({
    required this.applicationId,
    required this.memberId,
    required this.societyId,
    required this.requestedAmountPoisha,
    required this.termMonths,
    required this.purpose,
    required this.guarantorMemberId,
    this.status = 'submitted',
    required this.submittedAt,
    this.approvedAt,
    this.notes,
  });

  double get requestedAmountTaka => requestedAmountPoisha / 100.0;

  Map<String, dynamic> toMap() {
    return {
      'applicationId': applicationId,
      'memberId': memberId,
      'societyId': societyId,
      'requestedAmountPoisha': requestedAmountPoisha,
      'termMonths': termMonths,
      'purpose': purpose,
      'guarantorMemberId': guarantorMemberId,
      'status': status,
      'submittedAt': Timestamp.fromDate(submittedAt),
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
      'notes': notes,
    };
  }

  factory MemberLoanApplicationModel.fromMap(Map<String, dynamic> map, String id) {
    return MemberLoanApplicationModel(
      applicationId: map['applicationId'] ?? id,
      memberId: map['memberId'] ?? '',
      societyId: map['societyId'] ?? '',
      requestedAmountPoisha: map['requestedAmountPoisha'] ?? 0,
      termMonths: map['termMonths'] ?? 12,
      purpose: map['purpose'] ?? '',
      guarantorMemberId: map['guarantorMemberId'] ?? '',
      status: map['status'] ?? 'submitted',
      submittedAt: (map['submittedAt'] is Timestamp) ? (map['submittedAt'] as Timestamp).toDate() : DateTime.now(),
      approvedAt: (map['approvedAt'] is Timestamp) ? (map['approvedAt'] as Timestamp).toDate() : null,
      notes: map['notes'],
    );
  }
}

/// Super Admin Centralized Member App Control Configuration
class SuperAdminMemberAppMasterConfig {
  final bool isMemberAppGloballyEnabled;
  final bool isSelfRegistrationEnabled;
  final bool isKycSubmissionEnabled;
  final bool isDigitalCardEnabled;
  final bool isQrValidationEnabled;
  final bool isWithdrawalRequestEnabled;
  final bool isLoanApplicationEnabled;
  final bool isOnlinePaymentEnabled;
  final bool isOfflineReadSafeModeEnabled;
  final bool isMakerCheckerMandatory; // INVARIANT: Non-disablable
  final bool isTenantIsolationEnforced; // INVARIANT: Non-disablable

  const SuperAdminMemberAppMasterConfig({
    this.isMemberAppGloballyEnabled = true,
    this.isSelfRegistrationEnabled = true,
    this.isKycSubmissionEnabled = true,
    this.isDigitalCardEnabled = true,
    this.isQrValidationEnabled = true,
    this.isWithdrawalRequestEnabled = true,
    this.isLoanApplicationEnabled = true,
    this.isOnlinePaymentEnabled = true,
    this.isOfflineReadSafeModeEnabled = true,
    this.isMakerCheckerMandatory = true,
    this.isTenantIsolationEnforced = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'isMemberAppGloballyEnabled': isMemberAppGloballyEnabled,
      'isSelfRegistrationEnabled': isSelfRegistrationEnabled,
      'isKycSubmissionEnabled': isKycSubmissionEnabled,
      'isDigitalCardEnabled': isDigitalCardEnabled,
      'isQrValidationEnabled': isQrValidationEnabled,
      'isWithdrawalRequestEnabled': isWithdrawalRequestEnabled,
      'isLoanApplicationEnabled': isLoanApplicationEnabled,
      'isOnlinePaymentEnabled': isOnlinePaymentEnabled,
      'isOfflineReadSafeModeEnabled': isOfflineReadSafeModeEnabled,
      'isMakerCheckerMandatory': isMakerCheckerMandatory,
      'isTenantIsolationEnforced': isTenantIsolationEnforced,
    };
  }
}
