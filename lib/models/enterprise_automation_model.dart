import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';

/// Supported Workflow Trigger Types
enum WorkflowTriggerType {
  eventDriven,
  scheduledCron,
  metricThreshold,
  manualWebhook,
}

/// Supported Action Types in the Automation Library
enum WorkflowActionType {
  sendSms,
  sendPushNotification,
  sendEmail,
  createTask,
  updateStatus,
  generateReport,
  requestApproval,
  reconcileLedger,
  customWebhook,
}

/// Execution Lifecycle Statuses
enum ExecutionStatus {
  queued,
  evaluating,
  pendingApproval,
  approved,
  rejected,
  running,
  success,
  skippedDuplicate,
  failedRetryable,
  failedDlq,
}

/// Functional Automation Categories
enum WorkflowCategory {
  loanOperations,
  savingsOperations,
  memberOnboarding,
  complianceGovernance,
  accountingAudit,
  saasSubscription,
  custom,
}

/// Single Condition Evaluator Model
class WorkflowConditionModel {
  final String field;
  final String operator; // '==', '!=', '>', '<', '>=', '<=', 'contains', 'in'
  final dynamic expectedValue;

  const WorkflowConditionModel({
    required this.field,
    required this.operator,
    required this.expectedValue,
  });

  bool evaluate(Map<String, dynamic> data) {
    final actual = data[field];
    if (actual == null && operator != '==' && operator != '!=') return false;

    switch (operator) {
      case '==':
        return actual.toString() == expectedValue.toString();
      case '!=':
        return actual.toString() != expectedValue.toString();
      case '>':
        final num? a = num.tryParse(actual.toString());
        final num? e = num.tryParse(expectedValue.toString());
        if (a != null && e != null) return a > e;
        return false;
      case '<':
        final num? a = num.tryParse(actual.toString());
        final num? e = num.tryParse(expectedValue.toString());
        if (a != null && e != null) return a < e;
        return false;
      case '>=':
        final num? a = num.tryParse(actual.toString());
        final num? e = num.tryParse(expectedValue.toString());
        if (a != null && e != null) return a >= e;
        return false;
      case '<=':
        final num? a = num.tryParse(actual.toString());
        final num? e = num.tryParse(expectedValue.toString());
        if (a != null && e != null) return a <= e;
        return false;
      case 'contains':
        return actual.toString().contains(expectedValue.toString());
      case 'in':
        if (expectedValue is List) {
          return (expectedValue as List).map((x) => x.toString()).contains(actual.toString());
        }
        return false;
      default:
        return false;
    }
  }

  Map<String, dynamic> toMap() => {
    'field': field,
    'operator': operator,
    'expectedValue': expectedValue,
  };

  factory WorkflowConditionModel.fromMap(Map<String, dynamic> map) {
    return WorkflowConditionModel(
      field: map['field'] ?? '',
      operator: map['operator'] ?? '==',
      expectedValue: map['expectedValue'],
    );
  }
}

/// Trigger Definition Model
class WorkflowTriggerModel {
  final WorkflowTriggerType type;
  final String eventType; // e.g. 'loan.installment.due', 'member.created'
  final String cronExpression; // e.g. '0 9 * * *'
  final String timezone; // default 'Asia/Dhaka'
  final Map<String, dynamic> params;

  const WorkflowTriggerModel({
    required this.type,
    this.eventType = '',
    this.cronExpression = '',
    this.timezone = 'Asia/Dhaka',
    this.params = const {},
  });

  Map<String, dynamic> toMap() => {
    'type': type.name,
    'eventType': eventType,
    'cronExpression': cronExpression,
    'timezone': timezone,
    'params': params,
  };

  factory WorkflowTriggerModel.fromMap(Map<String, dynamic> map) {
    return WorkflowTriggerModel(
      type: WorkflowTriggerType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => WorkflowTriggerType.eventDriven,
      ),
      eventType: map['eventType'] ?? '',
      cronExpression: map['cronExpression'] ?? '',
      timezone: map['timezone'] ?? 'Asia/Dhaka',
      params: Map<String, dynamic>.from(map['params'] ?? {}),
    );
  }
}

/// Action Step Model
class WorkflowActionModel {
  final String id;
  final String nameBn;
  final WorkflowActionType actionType;
  final Map<String, dynamic> parameters;
  final bool isHighImpact;
  final String requiredRoleForApproval;

  const WorkflowActionModel({
    required this.id,
    required this.nameBn,
    required this.actionType,
    this.parameters = const {},
    this.isHighImpact = false,
    this.requiredRoleForApproval = 'society_admin',
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'nameBn': nameBn,
    'actionType': actionType.name,
    'parameters': parameters,
    'isHighImpact': isHighImpact,
    'requiredRoleForApproval': requiredRoleForApproval,
  };

  factory WorkflowActionModel.fromMap(Map<String, dynamic> map) {
    return WorkflowActionModel(
      id: map['id'] ?? '',
      nameBn: map['nameBn'] ?? '',
      actionType: WorkflowActionType.values.firstWhere(
        (e) => e.name == map['actionType'],
        orElse: () => WorkflowActionType.sendPushNotification,
      ),
      parameters: Map<String, dynamic>.from(map['parameters'] ?? {}),
      isHighImpact: map['isHighImpact'] == true,
      requiredRoleForApproval: map['requiredRoleForApproval'] ?? 'society_admin',
    );
  }
}

/// Authoritative Workflow Definition Model
class AutomationWorkflowModel {
  final String id;
  final String societyId;
  final String nameBn;
  final String descriptionBn;
  final WorkflowCategory category;
  final bool isActive;
  final int priority; // 1 (lowest) to 10 (critical)
  final WorkflowTriggerModel trigger;
  final List<WorkflowConditionModel> conditions;
  final List<WorkflowActionModel> actions;
  final DateTime? lastRunAt;
  final int executionCount;
  final int successCount;
  final int failureCount;
  final String createdBy;
  final DateTime createdAt;

  const AutomationWorkflowModel({
    required this.id,
    required this.societyId,
    required this.nameBn,
    required this.descriptionBn,
    required this.category,
    this.isActive = true,
    this.priority = 5,
    required this.trigger,
    this.conditions = const [],
    this.actions = const [],
    this.lastRunAt,
    this.executionCount = 0,
    this.successCount = 0,
    this.failureCount = 0,
    required this.createdBy,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'societyId': societyId,
    'nameBn': nameBn,
    'descriptionBn': descriptionBn,
    'category': category.name,
    'isActive': isActive,
    'priority': priority,
    'trigger': trigger.toMap(),
    'conditions': conditions.map((c) => c.toMap()).toList(),
    'actions': actions.map((a) => a.toMap()).toList(),
    'lastRunAt': lastRunAt != null ? Timestamp.fromDate(lastRunAt!) : null,
    'executionCount': executionCount,
    'successCount': successCount,
    'failureCount': failureCount,
    'createdBy': createdBy,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory AutomationWorkflowModel.fromMap(Map<String, dynamic> map, String id) {
    return AutomationWorkflowModel(
      id: map['id'] ?? id,
      societyId: map['societyId'] ?? '',
      nameBn: map['nameBn'] ?? '',
      descriptionBn: map['descriptionBn'] ?? '',
      category: WorkflowCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => WorkflowCategory.custom,
      ),
      isActive: map['isActive'] != false,
      priority: map['priority'] ?? 5,
      trigger: WorkflowTriggerModel.fromMap(Map<String, dynamic>.from(map['trigger'] ?? {})),
      conditions: (map['conditions'] as List<dynamic>? ?? [])
          .map((c) => WorkflowConditionModel.fromMap(Map<String, dynamic>.from(c)))
          .toList(),
      actions: (map['actions'] as List<dynamic>? ?? [])
          .map((a) => WorkflowActionModel.fromMap(Map<String, dynamic>.from(a)))
          .toList(),
      lastRunAt: (map['lastRunAt'] is Timestamp) ? (map['lastRunAt'] as Timestamp).toDate() : null,
      executionCount: map['executionCount'] ?? 0,
      successCount: map['successCount'] ?? 0,
      failureCount: map['failureCount'] ?? 0,
      createdBy: map['createdBy'] ?? 'system',
      createdAt: (map['createdAt'] is Timestamp) ? (map['createdAt'] as Timestamp).toDate() : DateTime.now(),
    );
  }
}

/// Execution Audit & Telemetry Log Model
class WorkflowExecutionLogModel {
  final String id;
  final String societyId;
  final String workflowId;
  final String workflowNameBn;
  final String idempotencyKey;
  final String triggerType;
  final ExecutionStatus status;
  final String triggeredBy;
  final Map<String, dynamic> inputPayload;
  final Map<String, dynamic> executionDetails;
  final int executionDepth;
  final int retryCount;
  final String? errorDetails;
  final DateTime startedAt;
  final DateTime? completedAt;

  const WorkflowExecutionLogModel({
    required this.id,
    required this.societyId,
    required this.workflowId,
    required this.workflowNameBn,
    required this.idempotencyKey,
    required this.triggerType,
    required this.status,
    required this.triggeredBy,
    this.inputPayload = const {},
    this.executionDetails = const {},
    this.executionDepth = 1,
    this.retryCount = 0,
    this.errorDetails,
    required this.startedAt,
    this.completedAt,
  });

  static String generateIdempotencyKey({
    required String societyId,
    required String workflowId,
    required String entityId,
    required String dateOrWindow,
  }) {
    final payload = '$societyId:$workflowId:$entityId:$dateOrWindow';
    return sha256.convert(utf8.encode(payload)).toString().substring(0, 32);
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'societyId': societyId,
    'workflowId': workflowId,
    'workflowNameBn': workflowNameBn,
    'idempotencyKey': idempotencyKey,
    'triggerType': triggerType,
    'status': status.name,
    'triggeredBy': triggeredBy,
    'inputPayload': inputPayload,
    'executionDetails': executionDetails,
    'executionDepth': executionDepth,
    'retryCount': retryCount,
    'errorDetails': errorDetails,
    'startedAt': Timestamp.fromDate(startedAt),
    'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
  };

  factory WorkflowExecutionLogModel.fromMap(Map<String, dynamic> map, String id) {
    return WorkflowExecutionLogModel(
      id: map['id'] ?? id,
      societyId: map['societyId'] ?? '',
      workflowId: map['workflowId'] ?? '',
      workflowNameBn: map['workflowNameBn'] ?? '',
      idempotencyKey: map['idempotencyKey'] ?? '',
      triggerType: map['triggerType'] ?? '',
      status: ExecutionStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ExecutionStatus.queued,
      ),
      triggeredBy: map['triggeredBy'] ?? 'system',
      inputPayload: Map<String, dynamic>.from(map['inputPayload'] ?? {}),
      executionDetails: Map<String, dynamic>.from(map['executionDetails'] ?? {}),
      executionDepth: map['executionDepth'] ?? 1,
      retryCount: map['retryCount'] ?? 0,
      errorDetails: map['errorDetails'],
      startedAt: (map['startedAt'] is Timestamp) ? (map['startedAt'] as Timestamp).toDate() : DateTime.now(),
      completedAt: (map['completedAt'] is Timestamp) ? (map['completedAt'] as Timestamp).toDate() : null,
    );
  }
}

/// Human Approval Request (Maker-Checker Queue)
class WorkflowApprovalRequestModel {
  final String id;
  final String societyId;
  final String workflowId;
  final String executionId;
  final String titleBn;
  final String actionType;
  final Map<String, dynamic> payload;
  final String requestedBy;
  final String status; // 'pending', 'approved', 'rejected'
  final String? reviewedBy;
  final String? reviewRemarksBn;
  final DateTime createdAt;
  final DateTime? decidedAt;

  const WorkflowApprovalRequestModel({
    required this.id,
    required this.societyId,
    required this.workflowId,
    required this.executionId,
    required this.titleBn,
    required this.actionType,
    required this.payload,
    required this.requestedBy,
    this.status = 'pending',
    this.reviewedBy,
    this.reviewRemarksBn,
    required this.createdAt,
    this.decidedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'societyId': societyId,
    'workflowId': workflowId,
    'executionId': executionId,
    'titleBn': titleBn,
    'actionType': actionType,
    'payload': payload,
    'requestedBy': requestedBy,
    'status': status,
    'reviewedBy': reviewedBy,
    'reviewRemarksBn': reviewRemarksBn,
    'createdAt': Timestamp.fromDate(createdAt),
    'decidedAt': decidedAt != null ? Timestamp.fromDate(decidedAt!) : null,
  };

  factory WorkflowApprovalRequestModel.fromMap(Map<String, dynamic> map, String id) {
    return WorkflowApprovalRequestModel(
      id: map['id'] ?? id,
      societyId: map['societyId'] ?? '',
      workflowId: map['workflowId'] ?? '',
      executionId: map['executionId'] ?? '',
      titleBn: map['titleBn'] ?? '',
      actionType: map['actionType'] ?? '',
      payload: Map<String, dynamic>.from(map['payload'] ?? {}),
      requestedBy: map['requestedBy'] ?? 'automation_engine',
      status: map['status'] ?? 'pending',
      reviewedBy: map['reviewedBy'],
      reviewRemarksBn: map['reviewRemarksBn'],
      createdAt: (map['createdAt'] is Timestamp) ? (map['createdAt'] as Timestamp).toDate() : DateTime.now(),
      decidedAt: (map['decidedAt'] is Timestamp) ? (map['decidedAt'] as Timestamp).toDate() : null,
    );
  }
}

/// Super Admin Universal Automation Master Control Configuration
class SuperAdminAutomationMasterConfig {
  final bool globalAutomationEnabled;
  final bool allowSocietyCustomWorkflows;
  final int maxExecutionDepth; // Circuit breaker limit (default 3)
  final int maxRetries; // Exponential backoff retries (default 3)
  final int defaultRetryDelaySeconds; // Base delay in seconds (default 30)
  final List<String> restrictedHighImpactActions;

  const SuperAdminAutomationMasterConfig({
    this.globalAutomationEnabled = true,
    this.allowSocietyCustomWorkflows = true,
    this.maxExecutionDepth = 3,
    this.maxRetries = 3,
    this.defaultRetryDelaySeconds = 30,
    this.restrictedHighImpactActions = const [
      'loan.disburse',
      'savings.withdraw',
      'ledger.post',
      'member.suspend',
      'society.archive',
    ],
  });

  Map<String, dynamic> toMap() => {
    'globalAutomationEnabled': globalAutomationEnabled,
    'allowSocietyCustomWorkflows': allowSocietyCustomWorkflows,
    'maxExecutionDepth': maxExecutionDepth,
    'maxRetries': maxRetries,
    'defaultRetryDelaySeconds': defaultRetryDelaySeconds,
    'restrictedHighImpactActions': restrictedHighImpactActions,
  };

  factory SuperAdminAutomationMasterConfig.fromMap(Map<String, dynamic> map) {
    return SuperAdminAutomationMasterConfig(
      globalAutomationEnabled: map['globalAutomationEnabled'] ?? true,
      allowSocietyCustomWorkflows: map['allowSocietyCustomWorkflows'] ?? true,
      maxExecutionDepth: map['maxExecutionDepth'] ?? 3,
      maxRetries: map['maxRetries'] ?? 3,
      defaultRetryDelaySeconds: map['defaultRetryDelaySeconds'] ?? 30,
      restrictedHighImpactActions: List<String>.from(map['restrictedHighImpactActions'] ?? [
        'loan.disburse',
        'savings.withdraw',
        'ledger.post',
        'member.suspend',
        'society.archive',
      ]),
    );
  }
}
