// lib/models/data_warehouse_analytics_model.dart
// Phase 17: Enterprise Data Warehouse & Advanced Intelligence Platform
// Analytical Star Schema Fact & Dimension Models, ETL Pipelines, and Data Quality Assurance

import 'dart:convert';

/// Status of an ETL/ELT pipeline execution
enum PipelineJobStatus {
  pending,
  running,
  completed,
  failed,
  retrying;

  String get labelBn {
    switch (this) {
      case PipelineJobStatus.pending: return 'অপেক্ষমাণ';
      case PipelineJobStatus.running: return 'চলমান (Processing)';
      case PipelineJobStatus.completed: return 'সফলভাবে সম্পন্ন';
      case PipelineJobStatus.failed: return 'ব্যর্থ (Failed)';
      case PipelineJobStatus.retrying: return 'পুনরায় চেষ্টা চলছে...';
    }
  }

  static PipelineJobStatus fromString(String val) {
    return PipelineJobStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => PipelineJobStatus.completed,
    );
  }
}

/// Portfolio-at-Risk (PAR) aging buckets
enum ParCategory {
  currentNormal, // নিয়মিত
  par30,         // ১ - ৩০ দিন বকেয়া
  par60,         // ৩১ - ৬০ দিন বকেয়া
  par90,         // ৬১ - ৯০ দিন বকেয়া
  parOver90;     // ৯০+ দিন বকেয়া (মন্দ ঋণ)

  String get labelBn {
    switch (this) {
      case ParCategory.currentNormal: return 'নিয়মিত কিস্তি';
      case ParCategory.par30: return 'PAR 30 (১-৩০ দিন বকেয়া)';
      case ParCategory.par60: return 'PAR 60 (৩১-৬০ দিন বকেয়া)';
      case ParCategory.par90: return 'PAR 90 (৬১-৯০ দিন বকেয়া)';
      case ParCategory.parOver90: return 'PAR 90+ (মন্দ ও খেলাপি ঋণ)';
    }
  }
}

/// Data Storage Lifecycle Tiers
enum DataArchivalTier {
  hotOltp,    // ০ - ১ বছর (Firestore Operational DB)
  warmDw,     // ১ - ৫ বছর (Analytical EDW OLAP)
  coldArchive; // ৫ - ১০+ বছর (আইনি সংরক্ষণ ও ক্লাউড কোল্ডলাইন)

  String get labelBn {
    switch (this) {
      case DataArchivalTier.hotOltp: return 'হট টায়ার (সরাসরি লেনদেন)';
      case DataArchivalTier.warmDw: return 'ওয়ার্ম টায়ার (বিশ্লেষণাত্মক ওয়্যারহাউজ)';
      case DataArchivalTier.coldArchive: return 'কোল্ড টায়ার (১০ বছর বিধিবদ্ধ সংরক্ষণ)';
    }
  }
}

/// 1. Fact: Savings Transactions Analytical Model
class FactSavingsTransactionModel {
  final String factId;
  final String societyId;
  final String memberId;
  final String transactionId;
  final String dateKey; // YYYYMMDD
  final int amountInPoisha;
  final int balanceAfterInPoisha;
  final String transactionType; // DEPOSIT, WITHDRAWAL, PROFIT
  final String paymentChannel; // CASH, BKASH, BANK
  final DateTime timestamp;

  const FactSavingsTransactionModel({
    required this.factId,
    required this.societyId,
    required this.memberId,
    required this.transactionId,
    required this.dateKey,
    required this.amountInPoisha,
    required this.balanceAfterInPoisha,
    required this.transactionType,
    required this.paymentChannel,
    required this.timestamp,
  });

  double get amountInTaka => amountInPoisha / 100.0;
  double get balanceAfterInTaka => balanceAfterInPoisha / 100.0;

  Map<String, dynamic> toMap() => {
    'factId': factId,
    'societyId': societyId,
    'memberId': memberId,
    'transactionId': transactionId,
    'dateKey': dateKey,
    'amountInPoisha': amountInPoisha,
    'balanceAfterInPoisha': balanceAfterInPoisha,
    'transactionType': transactionType,
    'paymentChannel': paymentChannel,
    'timestamp': timestamp.toIso8601String(),
  };
}

/// 2. Fact: Loan Installments & Recovery Analytical Model
class FactLoanInstallmentModel {
  final String factId;
  final String societyId;
  final String loanId;
  final String memberId;
  final String dateKey;
  final int principalPoisha;
  final int interestPoisha;
  final int penaltyPoisha;
  final int remainingPrincipalPoisha;
  final bool isOverdue;
  final int daysPastDue;
  final ParCategory parCategory;
  final DateTime dueDate;
  final DateTime? paidDate;

  const FactLoanInstallmentModel({
    required this.factId,
    required this.societyId,
    required this.loanId,
    required this.memberId,
    required this.dateKey,
    required this.principalPoisha,
    required this.interestPoisha,
    this.penaltyPoisha = 0,
    required this.remainingPrincipalPoisha,
    required this.isOverdue,
    required this.daysPastDue,
    required this.parCategory,
    required this.dueDate,
    this.paidDate,
  });

  double get principalInTaka => principalPoisha / 100.0;
  double get interestInTaka => interestPoisha / 100.0;
  double get remainingPrincipalInTaka => remainingPrincipalPoisha / 100.0;

  Map<String, dynamic> toMap() => {
    'factId': factId,
    'societyId': societyId,
    'loanId': loanId,
    'memberId': memberId,
    'dateKey': dateKey,
    'principalPoisha': principalPoisha,
    'interestPoisha': interestPoisha,
    'penaltyPoisha': penaltyPoisha,
    'remainingPrincipalPoisha': remainingPrincipalPoisha,
    'isOverdue': isOverdue,
    'daysPastDue': daysPastDue,
    'parCategory': parCategory.name,
    'dueDate': dueDate.toIso8601String(),
    'paidDate': paidDate?.toIso8601String(),
  };
}

/// 3. Fact: General Ledger Journal Analytical Model
class FactJournalEntryModel {
  final String factId;
  final String societyId;
  final String journalId;
  final String coaCode;
  final String coaName;
  final String dateKey;
  final int debitPoisha;
  final int creditPoisha;
  final String fiscalYear;
  final String voucherType;
  final String status;

  const FactJournalEntryModel({
    required this.factId,
    required this.societyId,
    required this.journalId,
    required this.coaCode,
    required this.coaName,
    required this.dateKey,
    required this.debitPoisha,
    required this.creditPoisha,
    required this.fiscalYear,
    required this.voucherType,
    required this.status,
  });

  double get debitInTaka => debitPoisha / 100.0;
  double get creditInTaka => creditPoisha / 100.0;

  Map<String, dynamic> toMap() => {
    'factId': factId,
    'societyId': societyId,
    'journalId': journalId,
    'coaCode': coaCode,
    'coaName': coaName,
    'dateKey': dateKey,
    'debitPoisha': debitPoisha,
    'creditPoisha': creditPoisha,
    'fiscalYear': fiscalYear,
    'voucherType': voucherType,
    'status': status,
  };
}

/// 4. Fact: Daily Cashbook Rollup Analytical Model
class FactDailyCashbookModel {
  final String factId;
  final String societyId;
  final String dateKey;
  final int openingBalancePoisha;
  final int totalReceiptsPoisha;
  final int totalPaymentsPoisha;
  final int closingBalancePoisha;
  final DateTime date;

  const FactDailyCashbookModel({
    required this.factId,
    required this.societyId,
    required this.dateKey,
    required this.openingBalancePoisha,
    required this.totalReceiptsPoisha,
    required this.totalPaymentsPoisha,
    required this.closingBalancePoisha,
    required this.date,
  });

  double get openingBalanceInTaka => openingBalancePoisha / 100.0;
  double get totalReceiptsInTaka => totalReceiptsPoisha / 100.0;
  double get totalPaymentsInTaka => totalPaymentsPoisha / 100.0;
  double get closingBalanceInTaka => closingBalancePoisha / 100.0;

  Map<String, dynamic> toMap() => {
    'factId': factId,
    'societyId': societyId,
    'dateKey': dateKey,
    'openingBalancePoisha': openingBalancePoisha,
    'totalReceiptsPoisha': totalReceiptsPoisha,
    'totalPaymentsPoisha': totalPaymentsPoisha,
    'closingBalancePoisha': closingBalancePoisha,
    'date': date.toIso8601String(),
  };
}

/// Data Pipeline Execution Tracking Model
class DataPipelineJobModel {
  final String jobId;
  final String pipelineName;
  final String societyId;
  final PipelineJobStatus status;
  final int processedRecords;
  final int quarantinedRecords;
  final int durationMs;
  final DateTime checkpointTimestamp;
  final DateTime executedAt;
  final String? errorMessage;

  const DataPipelineJobModel({
    required this.jobId,
    required this.pipelineName,
    required this.societyId,
    required this.status,
    required this.processedRecords,
    this.quarantinedRecords = 0,
    required this.durationMs,
    required this.checkpointTimestamp,
    required this.executedAt,
    this.errorMessage,
  });

  Map<String, dynamic> toMap() => {
    'jobId': jobId,
    'pipelineName': pipelineName,
    'societyId': societyId,
    'status': status.name,
    'processedRecords': processedRecords,
    'quarantinedRecords': quarantinedRecords,
    'durationMs': durationMs,
    'checkpointTimestamp': checkpointTimestamp.toIso8601String(),
    'executedAt': executedAt.toIso8601String(),
    'errorMessage': errorMessage,
  };
}

/// Data Quality Audit & Scorecard Model
class DataQualityReportModel {
  final String reportId;
  final String societyId;
  final double completenessScore; // 0.0 - 100.0
  final double accuracyScore;
  final double consistencyScore;
  final int totalAuditedRows;
  final int duplicateCount;
  final int nullKeyCount;
  final int outlierCount;
  final DateTime generatedAt;

  const DataQualityReportModel({
    required this.reportId,
    required this.societyId,
    required this.completenessScore,
    required this.accuracyScore,
    required this.consistencyScore,
    required this.totalAuditedRows,
    required this.duplicateCount,
    required this.nullKeyCount,
    required this.outlierCount,
    required this.generatedAt,
  });

  double get overallQualityScore => ((completenessScore + accuracyScore + consistencyScore) / 3.0);

  Map<String, dynamic> toMap() => {
    'reportId': reportId,
    'societyId': societyId,
    'completenessScore': completenessScore,
    'accuracyScore': accuracyScore,
    'consistencyScore': consistencyScore,
    'totalAuditedRows': totalAuditedRows,
    'duplicateCount': duplicateCount,
    'nullKeyCount': nullKeyCount,
    'outlierCount': outlierCount,
    'overallQualityScore': overallQualityScore,
    'generatedAt': generatedAt.toIso8601String(),
  };
}

/// Privacy-Preserving Cross-Society Benchmark Model
class CrossSocietyBenchmarkMetricModel {
  final String metricKey;
  final String metricNameBn;
  final String category; // SAVINGS, LOANS, EFFICIENCY
  final double societyScore;
  final double peerGroupMedian;
  final double peerGroupP75;
  final int kAnonymityCount; // Must be >= 5
  final String percentileRank; // e.g. "শীর্ষ ১০%"
  final bool isAuthorized;

  const CrossSocietyBenchmarkMetricModel({
    required this.metricKey,
    required this.metricNameBn,
    required this.category,
    required this.societyScore,
    required this.peerGroupMedian,
    required this.peerGroupP75,
    required this.kAnonymityCount,
    required this.percentileRank,
    this.isAuthorized = true,
  });

  Map<String, dynamic> toMap() => {
    'metricKey': metricKey,
    'metricNameBn': metricNameBn,
    'category': category,
    'societyScore': societyScore,
    'peerGroupMedian': peerGroupMedian,
    'peerGroupP75': peerGroupP75,
    'kAnonymityCount': kAnonymityCount,
    'percentileRank': percentileRank,
    'isAuthorized': isAuthorized,
  };
}

/// Financial Reconciliation Result Model
class FinancialReconciliationResult {
  final String societyId;
  final int factSavingsTotalPoisha;
  final int glSavingsLiabilityPoisha;
  final int factLoanPrincipalPoisha;
  final int glLoanAssetPoisha;
  final int factCashBalancePoisha;
  final int glCashBalancePoisha;
  final bool isBalanced;
  final int discrepancyPoisha;
  final DateTime reconciledAt;

  const FinancialReconciliationResult({
    required this.societyId,
    required this.factSavingsTotalPoisha,
    required this.glSavingsLiabilityPoisha,
    required this.factLoanPrincipalPoisha,
    required this.glLoanAssetPoisha,
    required this.factCashBalancePoisha,
    required this.glCashBalancePoisha,
    required this.isBalanced,
    required this.discrepancyPoisha,
    required this.reconciledAt,
  });

  double get discrepancyInTaka => discrepancyPoisha / 100.0;

  Map<String, dynamic> toMap() => {
    'societyId': societyId,
    'factSavingsTotalTaka': factSavingsTotalPoisha / 100.0,
    'glSavingsLiabilityTaka': glSavingsLiabilityPoisha / 100.0,
    'factLoanPrincipalTaka': factLoanPrincipalPoisha / 100.0,
    'glLoanAssetTaka': glLoanAssetPoisha / 100.0,
    'factCashBalanceTaka': factCashBalancePoisha / 100.0,
    'glCashBalanceTaka': glCashBalancePoisha / 100.0,
    'isBalanced': isBalanced,
    'discrepancyInTaka': discrepancyInTaka,
    'reconciledAt': reconciledAt.toIso8601String(),
  };
}

/// Data Retention and Archiving Policy Model
class DataRetentionPolicyModel {
  final String policyId;
  final String societyId;
  final DataArchivalTier tier;
  final int retentionPeriodYears;
  final bool isLegalHoldActive;
  final String storageLocation;
  final bool isStatutoryCompliant; // 10 Years Co-operative Law
  final DateTime lastArchivedAt;

  const DataRetentionPolicyModel({
    required this.policyId,
    required this.societyId,
    required this.tier,
    this.retentionPeriodYears = 10,
    this.isLegalHoldActive = false,
    required this.storageLocation,
    this.isStatutoryCompliant = true,
    required this.lastArchivedAt,
  });

  Map<String, dynamic> toMap() => {
    'policyId': policyId,
    'societyId': societyId,
    'tier': tier.name,
    'retentionPeriodYears': retentionPeriodYears,
    'isLegalHoldActive': isLegalHoldActive,
    'storageLocation': storageLocation,
    'isStatutoryCompliant': isStatutoryCompliant,
    'lastArchivedAt': lastArchivedAt.toIso8601String(),
  };
}

/// Super Admin Centralized Data Warehouse Master Configuration
class SuperAdminDataWarehouseMasterConfig {
  final bool isGlobalWarehouseEnabled;
  final bool isTenantIsolationEnforced; // Invariant: Cannot be disabled
  final bool isFinancialLedgerReconciliationLocked; // Invariant: Cannot be disabled
  final bool isCrossSocietyBenchmarkingEnabled;
  final bool isEtlPipelinesAutomated;
  final bool isDataQualityGateActive;
  final bool isDataExportEnabled;
  final bool isStatutory10YearRetentionEnforced; // Invariant: Co-op Law 2001
  final int minBenchmarkingGroupSize; // Default 5 (k-anonymity)

  const SuperAdminDataWarehouseMasterConfig({
    this.isGlobalWarehouseEnabled = true,
    this.isTenantIsolationEnforced = true,
    this.isFinancialLedgerReconciliationLocked = true,
    this.isCrossSocietyBenchmarkingEnabled = true,
    this.isEtlPipelinesAutomated = true,
    this.isDataQualityGateActive = true,
    this.isDataExportEnabled = true,
    this.isStatutory10YearRetentionEnforced = true,
    this.minBenchmarkingGroupSize = 5,
  });

  Map<String, dynamic> toMap() => {
    'isGlobalWarehouseEnabled': isGlobalWarehouseEnabled,
    'isTenantIsolationEnforced': isTenantIsolationEnforced,
    'isFinancialLedgerReconciliationLocked': isFinancialLedgerReconciliationLocked,
    'isCrossSocietyBenchmarkingEnabled': isCrossSocietyBenchmarkingEnabled,
    'isEtlPipelinesAutomated': isEtlPipelinesAutomated,
    'isDataQualityGateActive': isDataQualityGateActive,
    'isDataExportEnabled': isDataExportEnabled,
    'isStatutory10YearRetentionEnforced': isStatutory10YearRetentionEnforced,
    'minBenchmarkingGroupSize': minBenchmarkingGroupSize,
  };
}
