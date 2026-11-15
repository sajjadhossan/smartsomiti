// lib/models/qa_security_audit_model.dart
// Phase 13: Enterprise Advanced QA, Security Audit & Continuous Testing Engine Models

enum TestExecutionStatus {
  pass,
  fail,
  partial,
  blocked,
  notVerified;

  String get labelBn {
    switch (this) {
      case TestExecutionStatus.pass: return 'উত্তীর্ণ (PASS)';
      case TestExecutionStatus.fail: return 'ব্যর্থ (FAIL)';
      case TestExecutionStatus.partial: return 'আংশিক (PARTIAL)';
      case TestExecutionStatus.blocked: return 'ব্লকড (BLOCKED)';
      case TestExecutionStatus.notVerified: return 'অযাচাইকৃত (NOT VERIFIED)';
    }
  }

  String get badgeColorHex {
    switch (this) {
      case TestExecutionStatus.pass: return '#059669'; // Emerald
      case TestExecutionStatus.fail: return '#DC2626'; // Crimson
      case TestExecutionStatus.partial: return '#D97706'; // Amber
      case TestExecutionStatus.blocked: return '#6B7280'; // Gray
      case TestExecutionStatus.notVerified: return '#9333EA'; // Purple
    }
  }
}

enum DefectSeverity {
  critical,
  high,
  medium,
  low,
  informational;

  String get labelBn {
    switch (this) {
      case DefectSeverity.critical: return 'চরম ঝুঁকি (Critical)';
      case DefectSeverity.high: return 'উচ্চ ঝুঁকি (High)';
      case DefectSeverity.medium: return 'মাঝারি ঝুঁকি (Medium)';
      case DefectSeverity.low: return 'নিম্ন ঝুঁকি (Low)';
      case DefectSeverity.informational: return 'তথ্যমূলক (Informational)';
    }
  }
}

enum DefectStatus {
  open,
  investigating,
  confirmed,
  inProgress,
  fixed,
  retesting,
  resolved,
  blocked;

  String get labelBn {
    switch (this) {
      case DefectStatus.open: return 'উন্মুক্ত (Open)';
      case DefectStatus.investigating: return 'তদন্তাধীন (Investigating)';
      case DefectStatus.confirmed: return 'নিশ্চিতকৃত (Confirmed)';
      case DefectStatus.inProgress: return 'চলমান কাজ (In Progress)';
      case DefectStatus.fixed: return 'সমাধানকৃত (Fixed)';
      case DefectStatus.retesting: return 'পুনঃযাচাই (Retesting)';
      case DefectStatus.resolved: return 'সম্পূর্ণ নিষ্পন্ন (Resolved)';
      case DefectStatus.blocked: return 'স্থগিত (Blocked)';
    }
  }
}

enum VulnerabilityRisk {
  critical,
  high,
  medium,
  low;

  String get labelBn {
    switch (this) {
      case VulnerabilityRisk.critical: return 'চরম ঝুঁকি (Critical)';
      case VulnerabilityRisk.high: return 'উচ্চ ঝুঁকি (High)';
      case VulnerabilityRisk.medium: return 'মাঝারি (Medium)';
      case VulnerabilityRisk.low: return 'নিম্ন (Low)';
    }
  }
}

/// Representation of an Individual QA Test Case
class QaTestCaseModel {
  final String testId;
  final String suiteId;
  final String titleBn;
  final String titleEn;
  final String layer; // financial, multi_tenant, security, concurrency, e2e, ui_ux
  final TestExecutionStatus status;
  final Duration executionDuration;
  final String? assertionDetails;
  final DateTime executedAt;

  const QaTestCaseModel({
    required this.testId,
    required this.suiteId,
    required this.titleBn,
    required this.titleEn,
    required this.layer,
    required this.status,
    required this.executionDuration,
    this.assertionDetails,
    required this.executedAt,
  });

  Map<String, dynamic> toMap() => {
    'testId': testId,
    'suiteId': suiteId,
    'titleBn': titleBn,
    'titleEn': titleEn,
    'layer': layer,
    'status': status.name,
    'durationMs': executionDuration.inMilliseconds,
    'assertionDetails': assertionDetails,
    'executedAt': executedAt.toIso8601String(),
  };
}

/// Representation of a QA Test Suite
class QaTestSuiteModel {
  final String suiteId;
  final String titleBn;
  final String titleEn;
  final String phaseTarget;
  final bool isEnabled;
  final List<QaTestCaseModel> testCases;

  const QaTestSuiteModel({
    required this.suiteId,
    required this.titleBn,
    required this.titleEn,
    required this.phaseTarget,
    this.isEnabled = true,
    required this.testCases,
  });

  int get totalCount => testCases.length;
  int get passedCount => testCases.where((t) => t.status == TestExecutionStatus.pass).length;
  int get failedCount => testCases.where((t) => t.status == TestExecutionStatus.fail).length;
  int get blockedCount => testCases.where((t) => t.status == TestExecutionStatus.blocked).length;

  double get successRate => totalCount == 0 ? 100.0 : ((passedCount / totalCount) * 100);

  Map<String, dynamic> toMap() => {
    'suiteId': suiteId,
    'titleBn': titleBn,
    'titleEn': titleEn,
    'phaseTarget': phaseTarget,
    'isEnabled': isEnabled,
    'totalCount': totalCount,
    'passedCount': passedCount,
    'failedCount': failedCount,
    'successRate': successRate,
    'testCases': testCases.map((t) => t.toMap()).toList(),
  };
}

/// QA Defect / Bug Model
class QaDefectModel {
  final String defectId;
  final String title;
  final String description;
  final String affectedModule;
  final String platform; // android, ios, web, backend
  final DefectSeverity severity;
  final DefectStatus status;
  final String assignedTo;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  const QaDefectModel({
    required this.defectId,
    required this.title,
    required this.description,
    required this.affectedModule,
    required this.platform,
    required this.severity,
    required this.status,
    required this.assignedTo,
    required this.createdAt,
    this.resolvedAt,
  });

  Map<String, dynamic> toMap() => {
    'defectId': defectId,
    'title': title,
    'description': description,
    'affectedModule': affectedModule,
    'platform': platform,
    'severity': severity.name,
    'status': status.name,
    'assignedTo': assignedTo,
    'createdAt': createdAt.toIso8601String(),
    'resolvedAt': resolvedAt?.toIso8601String(),
  };
}

/// Security Audit Finding Model
class SecurityFindingModel {
  final String findingId;
  final String owaspCategory;
  final String titleBn;
  final String descriptionBn;
  final VulnerabilityRisk riskLevel;
  final bool isRemediated;
  final String remediationEvidence;

  const SecurityFindingModel({
    required this.findingId,
    required this.owaspCategory,
    required this.titleBn,
    required this.descriptionBn,
    required this.riskLevel,
    required this.isRemediated,
    required this.remediationEvidence,
  });

  Map<String, dynamic> toMap() => {
    'findingId': findingId,
    'owaspCategory': owaspCategory,
    'titleBn': titleBn,
    'descriptionBn': descriptionBn,
    'riskLevel': riskLevel.name,
    'isRemediated': isRemediated,
    'remediationEvidence': remediationEvidence,
  };
}

/// Financial Reconciliation Verification Result
class FinancialReconciliationResultModel {
  final String reconciliationId;
  final int totalDebitsPoisha;
  final int totalCreditsPoisha;
  final bool isEquilibriumBalanced;
  final bool isLiabilityModelCompliant;
  final int variancePoisha;
  final DateTime verifiedAt;

  const FinancialReconciliationResultModel({
    required this.reconciliationId,
    required this.totalDebitsPoisha,
    required this.totalCreditsPoisha,
    required this.isEquilibriumBalanced,
    required this.isLiabilityModelCompliant,
    required this.variancePoisha,
    required this.verifiedAt,
  });

  Map<String, dynamic> toMap() => {
    'reconciliationId': reconciliationId,
    'totalDebitsPoisha': totalDebitsPoisha,
    'totalCreditsPoisha': totalCreditsPoisha,
    'isEquilibriumBalanced': isEquilibriumBalanced,
    'isLiabilityModelCompliant': isLiabilityModelCompliant,
    'variancePoisha': variancePoisha,
    'verifiedAt': verifiedAt.toIso8601String(),
  };
}

/// CI/CD Quality Gate Policy Model
class QualityGatePolicyModel {
  final bool requireZeroCriticalDefects;
  final double minimumPassRatePercent;
  final bool requireMultiTenantIsolationVerified;
  final bool requireFinancialEquilibriumVerified;
  final bool requireSecurityAuditClean;

  const QualityGatePolicyModel({
    this.requireZeroCriticalDefects = true,
    this.minimumPassRatePercent = 95.0,
    this.requireMultiTenantIsolationVerified = true,
    this.requireFinancialEquilibriumVerified = true,
    this.requireSecurityAuditClean = true,
  });

  Map<String, dynamic> toMap() => {
    'requireZeroCriticalDefects': requireZeroCriticalDefects,
    'minimumPassRatePercent': minimumPassRatePercent,
    'requireMultiTenantIsolationVerified': requireMultiTenantIsolationVerified,
    'requireFinancialEquilibriumVerified': requireFinancialEquilibriumVerified,
    'requireSecurityAuditClean': requireSecurityAuditClean,
  };
}

/// Super Admin QA Master Configuration
class SuperAdminQaMasterConfig {
  final bool continuousTestingEnabled;
  final bool automatedSecurityAuditEnabled;
  final bool qualityGateStrictEnforcement;
  final int automatedRunIntervalHours;

  const SuperAdminQaMasterConfig({
    this.continuousTestingEnabled = true,
    this.automatedSecurityAuditEnabled = true,
    this.qualityGateStrictEnforcement = true,
    this.automatedRunIntervalHours = 6,
  });

  Map<String, dynamic> toMap() => {
    'continuousTestingEnabled': continuousTestingEnabled,
    'automatedSecurityAuditEnabled': automatedSecurityAuditEnabled,
    'qualityGateStrictEnforcement': qualityGateStrictEnforcement,
    'automatedRunIntervalHours': automatedRunIntervalHours,
  };
}
