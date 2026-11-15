// lib/models/ai_analytics_model.dart
// Enterprise AI, Advanced Analytics, Business Intelligence & Risk Models
// Strict multi-tenant data isolation, integer Poisha arithmetic, and explainable AI metrics

import 'dart:convert';

/// Supported Foundation AI Providers
enum AiProviderType {
  gemini,
  claude,
  openai,
  localFallback;

  String get labelBn {
    switch (this) {
      case AiProviderType.gemini: return 'Google Gemini (1.5 Flash / Pro)';
      case AiProviderType.claude: return 'Anthropic Claude (3.5 Sonnet)';
      case AiProviderType.openai: return 'OpenAI Azure (GPT-4o)';
      case AiProviderType.localFallback: return 'অন-প্রিমিসেস সিকিউরড লোকাল ইঞ্জিন';
    }
  }

  static AiProviderType fromString(String val) {
    return AiProviderType.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => AiProviderType.gemini,
    );
  }
}

/// AI Provider Configuration Model
class AiProviderConfigModel {
  final String providerId;
  final AiProviderType providerType;
  final String name;
  final String defaultModelId;
  final bool isEnabled;
  final bool isDefault;
  final int monthlyRequestQuota;
  final int usedRequestsThisMonth;
  final int monthlyTokenQuota;
  final int usedTokensThisMonth;
  final int latencyMs;

  const AiProviderConfigModel({
    required this.providerId,
    required this.providerType,
    required this.name,
    required this.defaultModelId,
    this.isEnabled = true,
    this.isDefault = false,
    this.monthlyRequestQuota = 5000,
    this.usedRequestsThisMonth = 0,
    this.monthlyTokenQuota = 2000000,
    this.usedTokensThisMonth = 0,
    this.latencyMs = 45,
  });

  bool get isQuotaExceeded => usedRequestsThisMonth >= monthlyRequestQuota;

  Map<String, dynamic> toMap() => {
    'providerId': providerId,
    'providerType': providerType.name,
    'name': name,
    'defaultModelId': defaultModelId,
    'isEnabled': isEnabled,
    'isDefault': isDefault,
    'monthlyRequestQuota': monthlyRequestQuota,
    'usedRequestsThisMonth': usedRequestsThisMonth,
    'monthlyTokenQuota': monthlyTokenQuota,
    'usedTokensThisMonth': usedTokensThisMonth,
    'latencyMs': latencyMs,
  };

  factory AiProviderConfigModel.fromMap(Map<String, dynamic> map, String id) {
    return AiProviderConfigModel(
      providerId: id,
      providerType: AiProviderType.fromString(map['providerType'] as String? ?? 'gemini'),
      name: map['name'] as String? ?? '',
      defaultModelId: map['defaultModelId'] as String? ?? 'gemini-1.5-flash',
      isEnabled: map['isEnabled'] as bool? ?? true,
      isDefault: map['isDefault'] as bool? ?? false,
      monthlyRequestQuota: (map['monthlyRequestQuota'] as num?)?.toInt() ?? 5000,
      usedRequestsThisMonth: (map['usedRequestsThisMonth'] as num?)?.toInt() ?? 0,
      monthlyTokenQuota: (map['monthlyTokenQuota'] as num?)?.toInt() ?? 2000000,
      usedTokensThisMonth: (map['usedTokensThisMonth'] as num?)?.toInt() ?? 0,
      latencyMs: (map['latencyMs'] as num?)?.toInt() ?? 45,
    );
  }
}

/// AI Assistant Chat Conversation Message
class AiConversationMessageModel {
  final String id;
  final String conversationId;
  final String societyId;
  final String userId;
  final String role; // 'user', 'assistant', 'system'
  final String content;
  final String? sourceCitation;
  final DateTime timestamp;

  const AiConversationMessageModel({
    required this.id,
    required this.conversationId,
    required this.societyId,
    required this.userId,
    required this.role,
    required this.content,
    this.sourceCitation,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'conversationId': conversationId,
    'societyId': societyId,
    'userId': userId,
    'role': role,
    'content': content,
    'sourceCitation': sourceCitation,
    'timestamp': timestamp.toIso8601String(),
  };

  factory AiConversationMessageModel.fromMap(Map<String, dynamic> map, String id) {
    return AiConversationMessageModel(
      id: id,
      conversationId: map['conversationId'] as String? ?? '',
      societyId: map['societyId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      role: map['role'] as String? ?? 'user',
      content: map['content'] as String? ?? '',
      sourceCitation: map['sourceCitation'] as String?,
      timestamp: DateTime.tryParse(map['timestamp'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

/// Ledger-Reconciled Financial KPI Snapshot
class FinancialKpiSnapshotModel {
  final String id;
  final String societyId;
  final DateTime snapshotDate;
  final int totalAssetsPoisha;
  final int totalLiabilitiesPoisha;
  final int memberSavingsPoisha;
  final int outstandingLoanPrincipalPoisha;
  final int cashInDrawerPoisha;
  final int bankBalancePoisha;
  final int monthlyRevenuePoisha;
  final int monthlyExpensePoisha;
  final int netSurplusPoisha;
  final double liquidityRatio;

  const FinancialKpiSnapshotModel({
    required this.id,
    required this.societyId,
    required this.snapshotDate,
    required this.totalAssetsPoisha,
    required this.totalLiabilitiesPoisha,
    required this.memberSavingsPoisha,
    required this.outstandingLoanPrincipalPoisha,
    required this.cashInDrawerPoisha,
    required this.bankBalancePoisha,
    required this.monthlyRevenuePoisha,
    required this.monthlyExpensePoisha,
    required this.netSurplusPoisha,
    required this.liquidityRatio,
  });

  double get totalAssetsBdt => totalAssetsPoisha / 100.0;
  double get totalLiabilitiesBdt => totalLiabilitiesPoisha / 100.0;
  double get memberSavingsBdt => memberSavingsPoisha / 100.0;
  double get outstandingLoanPrincipalBdt => outstandingLoanPrincipalPoisha / 100.0;
  double get cashInDrawerBdt => cashInDrawerPoisha / 100.0;
  double get bankBalanceBdt => bankBalancePoisha / 100.0;
  double get monthlyRevenueBdt => monthlyRevenuePoisha / 100.0;
  double get monthlyExpenseBdt => monthlyExpensePoisha / 100.0;
  double get netSurplusBdt => netSurplusPoisha / 100.0;

  Map<String, dynamic> toMap() => {
    'id': id,
    'societyId': societyId,
    'snapshotDate': snapshotDate.toIso8601String(),
    'totalAssetsPoisha': totalAssetsPoisha,
    'totalLiabilitiesPoisha': totalLiabilitiesPoisha,
    'memberSavingsPoisha': memberSavingsPoisha,
    'outstandingLoanPrincipalPoisha': outstandingLoanPrincipalPoisha,
    'cashInDrawerPoisha': cashInDrawerPoisha,
    'bankBalancePoisha': bankBalancePoisha,
    'monthlyRevenuePoisha': monthlyRevenuePoisha,
    'monthlyExpensePoisha': monthlyExpensePoisha,
    'netSurplusPoisha': netSurplusPoisha,
    'liquidityRatio': liquidityRatio,
  };

  factory FinancialKpiSnapshotModel.fromMap(Map<String, dynamic> map, String id) {
    return FinancialKpiSnapshotModel(
      id: id,
      societyId: map['societyId'] as String? ?? '',
      snapshotDate: DateTime.tryParse(map['snapshotDate'] as String? ?? '') ?? DateTime.now(),
      totalAssetsPoisha: (map['totalAssetsPoisha'] as num?)?.toInt() ?? 0,
      totalLiabilitiesPoisha: (map['totalLiabilitiesPoisha'] as num?)?.toInt() ?? 0,
      memberSavingsPoisha: (map['memberSavingsPoisha'] as num?)?.toInt() ?? 0,
      outstandingLoanPrincipalPoisha: (map['outstandingLoanPrincipalPoisha'] as num?)?.toInt() ?? 0,
      cashInDrawerPoisha: (map['cashInDrawerPoisha'] as num?)?.toInt() ?? 0,
      bankBalancePoisha: (map['bankBalancePoisha'] as num?)?.toInt() ?? 0,
      monthlyRevenuePoisha: (map['monthlyRevenuePoisha'] as num?)?.toInt() ?? 0,
      monthlyExpensePoisha: (map['monthlyExpensePoisha'] as num?)?.toInt() ?? 0,
      netSurplusPoisha: (map['netSurplusPoisha'] as num?)?.toInt() ?? 0,
      liquidityRatio: (map['liquidityRatio'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Member Segment Intelligence Insight
class MemberSegmentInsightModel {
  final String segmentCode;
  final String titleBn;
  final int memberCount;
  final double percentage;
  final String recommendedActionBn;

  const MemberSegmentInsightModel({
    required this.segmentCode,
    required this.titleBn,
    required this.memberCount,
    required this.percentage,
    required this.recommendedActionBn,
  });

  Map<String, dynamic> toMap() => {
    'segmentCode': segmentCode,
    'titleBn': titleBn,
    'memberCount': memberCount,
    'percentage': percentage,
    'recommendedActionBn': recommendedActionBn,
  };

  factory MemberSegmentInsightModel.fromMap(Map<String, dynamic> map) {
    return MemberSegmentInsightModel(
      segmentCode: map['segmentCode'] as String? ?? '',
      titleBn: map['titleBn'] as String? ?? '',
      memberCount: (map['memberCount'] as num?)?.toInt() ?? 0,
      percentage: (map['percentage'] as num?)?.toDouble() ?? 0.0,
      recommendedActionBn: map['recommendedActionBn'] as String? ?? '',
    );
  }
}

/// Loan & Credit Risk Indicators
class LoanRiskIndicatorModel {
  final String indicatorId;
  final String titleBn;
  final double par30Percent;
  final double par60Percent;
  final double par90Percent;
  final int highRiskLoansCount;
  final String criteriaExplanationBn;

  const LoanRiskIndicatorModel({
    required this.indicatorId,
    required this.titleBn,
    required this.par30Percent,
    required this.par60Percent,
    required this.par90Percent,
    required this.highRiskLoansCount,
    required this.criteriaExplanationBn,
  });

  Map<String, dynamic> toMap() => {
    'indicatorId': indicatorId,
    'titleBn': titleBn,
    'par30Percent': par30Percent,
    'par60Percent': par60Percent,
    'par90Percent': par90Percent,
    'highRiskLoansCount': highRiskLoansCount,
    'criteriaExplanationBn': criteriaExplanationBn,
  };

  factory LoanRiskIndicatorModel.fromMap(Map<String, dynamic> map, String id) {
    return LoanRiskIndicatorModel(
      indicatorId: id,
      titleBn: map['titleBn'] as String? ?? '',
      par30Percent: (map['par30Percent'] as num?)?.toDouble() ?? 0.0,
      par60Percent: (map['par60Percent'] as num?)?.toDouble() ?? 0.0,
      par90Percent: (map['par90Percent'] as num?)?.toDouble() ?? 0.0,
      highRiskLoansCount: (map['highRiskLoansCount'] as num?)?.toInt() ?? 0,
      criteriaExplanationBn: map['criteriaExplanationBn'] as String? ?? '',
    );
  }
}

/// Fraud & Anomaly Risk Alert
class RiskAlertModel {
  final String id;
  final String societyId;
  final String ruleId;
  final String severity; // 'LOW', 'MEDIUM', 'HIGH', 'CRITICAL'
  final String categoryBn;
  final String descriptionBn;
  final String evidenceRef;
  final String status; // 'detected', 'underInvestigation', 'falsePositive', 'resolved'
  final DateTime detectedAt;
  final DateTime? resolvedAt;
  final String? assignedTo;
  final String? resolutionNotes;

  const RiskAlertModel({
    required this.id,
    required this.societyId,
    required this.ruleId,
    required this.severity,
    required this.categoryBn,
    required this.descriptionBn,
    required this.evidenceRef,
    this.status = 'detected',
    required this.detectedAt,
    this.resolvedAt,
    this.assignedTo,
    this.resolutionNotes,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'societyId': societyId,
    'ruleId': ruleId,
    'severity': severity,
    'categoryBn': categoryBn,
    'descriptionBn': descriptionBn,
    'evidenceRef': evidenceRef,
    'status': status,
    'detectedAt': detectedAt.toIso8601String(),
    'resolvedAt': resolvedAt?.toIso8601String(),
    'assignedTo': assignedTo,
    'resolutionNotes': resolutionNotes,
  };

  factory RiskAlertModel.fromMap(Map<String, dynamic> map, String id) {
    return RiskAlertModel(
      id: id,
      societyId: map['societyId'] as String? ?? '',
      ruleId: map['ruleId'] as String? ?? '',
      severity: map['severity'] as String? ?? 'MEDIUM',
      categoryBn: map['categoryBn'] as String? ?? '',
      descriptionBn: map['descriptionBn'] as String? ?? '',
      evidenceRef: map['evidenceRef'] as String? ?? '',
      status: map['status'] as String? ?? 'detected',
      detectedAt: DateTime.tryParse(map['detectedAt'] as String? ?? '') ?? DateTime.now(),
      resolvedAt: map['resolvedAt'] != null ? DateTime.tryParse(map['resolvedAt'] as String) : null,
      assignedTo: map['assignedTo'] as String?,
      resolutionNotes: map['resolutionNotes'] as String?,
    );
  }
}

/// Predictive Forecast Result
class ForecastResultModel {
  final String targetKey;
  final String titleBn;
  final int horizonDays;
  final int historicalDataPointsCount;
  final int forecastedValuePoisha;
  final int confidenceLowerPoisha;
  final int confidenceUpperPoisha;
  final double confidencePercent;
  final double mapeScore;
  final bool isReliable;
  final String? modelMethod;

  const ForecastResultModel({
    required this.targetKey,
    required this.titleBn,
    required this.horizonDays,
    required this.historicalDataPointsCount,
    required this.forecastedValuePoisha,
    required this.confidenceLowerPoisha,
    required this.confidenceUpperPoisha,
    this.confidencePercent = 95.0,
    this.mapeScore = 4.2,
    this.isReliable = true,
    this.modelMethod = 'Holt-Winters Seasonal Smoothing',
  });

  double get forecastedValueBdt => forecastedValuePoisha / 100.0;
  double get confidenceLowerBdt => confidenceLowerPoisha / 100.0;
  double get confidenceUpperBdt => confidenceUpperPoisha / 100.0;

  Map<String, dynamic> toMap() => {
    'targetKey': targetKey,
    'titleBn': titleBn,
    'horizonDays': horizonDays,
    'historicalDataPointsCount': historicalDataPointsCount,
    'forecastedValuePoisha': forecastedValuePoisha,
    'confidenceLowerPoisha': confidenceLowerPoisha,
    'confidenceUpperPoisha': confidenceUpperPoisha,
    'confidencePercent': confidencePercent,
    'mapeScore': mapeScore,
    'isReliable': isReliable,
    'modelMethod': modelMethod,
  };

  factory ForecastResultModel.fromMap(Map<String, dynamic> map) {
    return ForecastResultModel(
      targetKey: map['targetKey'] as String? ?? '',
      titleBn: map['titleBn'] as String? ?? '',
      horizonDays: (map['horizonDays'] as num?)?.toInt() ?? 30,
      historicalDataPointsCount: (map['historicalDataPointsCount'] as num?)?.toInt() ?? 0,
      forecastedValuePoisha: (map['forecastedValuePoisha'] as num?)?.toInt() ?? 0,
      confidenceLowerPoisha: (map['confidenceLowerPoisha'] as num?)?.toInt() ?? 0,
      confidenceUpperPoisha: (map['confidenceUpperPoisha'] as num?)?.toInt() ?? 0,
      confidencePercent: (map['confidencePercent'] as num?)?.toDouble() ?? 95.0,
      mapeScore: (map['mapeScore'] as num?)?.toDouble() ?? 4.2,
      isReliable: map['isReliable'] as bool? ?? true,
      modelMethod: map['modelMethod'] as String? ?? 'Holt-Winters Seasonal Smoothing',
    );
  }
}

/// Custom Report Template Specification
class CustomReportTemplateModel {
  final String id;
  final String title;
  final String dataset;
  final List<String> selectedFields;
  final Map<String, dynamic> filters;
  final String sortBy;
  final String? groupBy;
  final String createdByUser;
  final DateTime createdAt;

  const CustomReportTemplateModel({
    required this.id,
    required this.title,
    required this.dataset,
    required this.selectedFields,
    this.filters = const {},
    this.sortBy = 'createdAt_desc',
    this.groupBy,
    required this.createdByUser,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'dataset': dataset,
    'selectedFields': selectedFields,
    'filters': filters,
    'sortBy': sortBy,
    'groupBy': groupBy,
    'createdByUser': createdByUser,
    'createdAt': createdAt.toIso8601String(),
  };

  factory CustomReportTemplateModel.fromMap(Map<String, dynamic> map, String id) {
    return CustomReportTemplateModel(
      id: id,
      title: map['title'] as String? ?? '',
      dataset: map['dataset'] as String? ?? '',
      selectedFields: (map['selectedFields'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      filters: map['filters'] as Map<String, dynamic>? ?? {},
      sortBy: map['sortBy'] as String? ?? 'createdAt_desc',
      groupBy: map['groupBy'] as String?,
      createdByUser: map['createdByUser'] as String? ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
