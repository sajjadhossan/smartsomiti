import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/enterprise_automation_model.dart';

/// Centralized Enterprise Automation & Autonomous Operations Service
class EnterpriseAutomationService {
  static final EnterpriseAutomationService _instance = EnterpriseAutomationService._internal();
  factory EnterpriseAutomationService() => _instance;
  EnterpriseAutomationService._internal() {
    _seedInitialWorkflows();
  }

  final FirebaseFirestore? _firestore = FirebaseFirestore.instance;

  // Master Configuration
  SuperAdminAutomationMasterConfig _masterConfig = const SuperAdminAutomationMasterConfig();
  SuperAdminAutomationMasterConfig get masterConfig => _masterConfig;

  void updateMasterConfig(SuperAdminAutomationMasterConfig config) {
    _masterConfig = config;
  }

  // In-memory repositories for high-performance execution & offline caching
  final Map<String, List<AutomationWorkflowModel>> _societyWorkflows = {};
  final List<WorkflowExecutionLogModel> _executionLogs = [];
  final List<WorkflowApprovalRequestModel> _approvalQueue = [];
  final Set<String> _processedIdempotencyKeys = {};

  List<AutomationWorkflowModel> getWorkflows(String societyId) {
    return _societyWorkflows[societyId] ?? [];
  }

  List<WorkflowExecutionLogModel> getExecutionLogs(String societyId) {
    return _executionLogs.where((l) => l.societyId == societyId).toList();
  }

  List<WorkflowApprovalRequestModel> getApprovalQueue(String societyId) {
    return _approvalQueue.where((a) => a.societyId == societyId).toList();
  }

  List<WorkflowExecutionLogModel> getDeadLetters(String societyId) {
    return _executionLogs
        .where((l) => l.societyId == societyId && l.status == ExecutionStatus.failedDlq)
        .toList();
  }

  /// Seed initial standard workflows for test and live demonstration
  void _seedInitialWorkflows() {
    const defaultSociety = 'swapno_chowa_main';
    final now = DateTime.now();

    final seeded = [
      AutomationWorkflowModel(
        id: 'wf-loan-due-reminder',
        societyId: defaultSociety,
        nameBn: 'ঋণ কিস্তি আগাম স্মরণিকা ও বকেয়া ফলোআপ',
        descriptionBn: 'কিস্তির ৩ দিন পূর্বে এসএমএস প্রেরণ এবং ৭ দিন অতিক্রান্ত হলে মাঠ কর্মকর্তা টাস্ক তৈরি',
        category: WorkflowCategory.loanOperations,
        isActive: true,
        priority: 9,
        trigger: const WorkflowTriggerModel(
          type: WorkflowTriggerType.scheduledCron,
          eventType: 'loan.installment.due',
          cronExpression: '0 9 * * *',
        ),
        conditions: const [
          WorkflowConditionModel(field: 'daysUntilDue', operator: '<=', expectedValue: 3),
          WorkflowConditionModel(field: 'isPaid', operator: '==', expectedValue: false),
        ],
        actions: const [
          WorkflowActionModel(
            id: 'act-sms-reminder',
            nameBn: 'সদস্যকে কিস্তি পরিশোধ এসএমএস প্রেরণ',
            actionType: WorkflowActionType.sendSms,
            parameters: {'template': 'loan_due_alert', 'channel': 'bulk_sms'},
          ),
          WorkflowActionModel(
            id: 'act-field-task',
            nameBn: 'মাঠ কর্মকর্তা কালেকশন রুট টাস্ক বরাদ্দ',
            actionType: WorkflowActionType.createTask,
            parameters: {'assignee': 'field_officer', 'priority': 'high'},
          ),
        ],
        createdBy: 'system_auto_engine',
        createdAt: now.subtract(const Duration(days: 15)),
        executionCount: 142,
        successCount: 139,
        failureCount: 3,
        lastRunAt: now.subtract(const Duration(hours: 2)),
      ),
      AutomationWorkflowModel(
        id: 'wf-member-onboarding',
        societyId: defaultSociety,
        nameBn: 'নতুন সদস্য অনবোর্ডিং ও কেওয়াইসি যাচাইকরণ পাইপলাইন',
        descriptionBn: 'নতুন সদস্য নিবন্ধিত হলে কেওয়াইসি অডিট টাস্ক তৈরি ও ডিজিটাল পাসবুক খসড়া প্রস্তুত',
        category: WorkflowCategory.memberOnboarding,
        isActive: true,
        priority: 7,
        trigger: const WorkflowTriggerModel(
          type: WorkflowTriggerType.eventDriven,
          eventType: 'member.created',
        ),
        conditions: const [
          WorkflowConditionModel(field: 'status', operator: '==', expectedValue: 'pending_verification'),
        ],
        actions: const [
          WorkflowActionModel(
            id: 'act-kyc-verify-task',
            nameBn: 'অফিসারের জন্য কেওয়াইসি যাচাই টাস্ক সৃষ্টি',
            actionType: WorkflowActionType.createTask,
            parameters: {'role': 'manager', 'deadlineHours': 24},
          ),
          WorkflowActionModel(
            id: 'act-welcome-push',
            nameBn: 'স্বাগতম পুশ নোটিফিকেশন প্রেরণ',
            actionType: WorkflowActionType.sendPushNotification,
            parameters: {'title': 'স্বপ্ন ছোঁয়ায় স্বাগতম!'},
          ),
        ],
        createdBy: 'system_auto_engine',
        createdAt: now.subtract(const Duration(days: 30)),
        executionCount: 88,
        successCount: 88,
        failureCount: 0,
        lastRunAt: now.subtract(const Duration(hours: 5)),
      ),
      AutomationWorkflowModel(
        id: 'wf-compliance-agm-warning',
        societyId: defaultSociety,
        nameBn: 'বার্ষিক এজিএম ও আইনি কমপ্লায়েন্স ক্যালেন্ডার সতর্কতা',
        descriptionBn: 'বিধিবদ্ধ সময়সীমার ৩০ দিন পূর্বে সাধারণ সম্পাদক ও পরিচালনা পর্ষদকে নোটিশ জারি',
        category: WorkflowCategory.complianceGovernance,
        isActive: true,
        priority: 10,
        trigger: const WorkflowTriggerModel(
          type: WorkflowTriggerType.scheduledCron,
          eventType: 'compliance.deadline.approaching',
          cronExpression: '0 10 * * 1', // Every Monday
        ),
        conditions: const [
          WorkflowConditionModel(field: 'daysRemaining', operator: '<=', expectedValue: 30),
          WorkflowConditionModel(field: 'isFiled', operator: '==', expectedValue: false),
        ],
        actions: const [
          WorkflowActionModel(
            id: 'act-agm-notice-alert',
            nameBn: 'বোর্ড কমিটির নিকট কমপ্লায়েন্স সতর্কতা প্রেরণ',
            actionType: WorkflowActionType.sendEmail,
            parameters: {'subject': 'জরুরি: এজিএম আয়োজনের আইনি সময়সীমা'},
          ),
        ],
        createdBy: 'system_auto_engine',
        createdAt: now.subtract(const Duration(days: 45)),
        executionCount: 24,
        successCount: 24,
        failureCount: 0,
        lastRunAt: now.subtract(const Duration(days: 2)),
      ),
      AutomationWorkflowModel(
        id: 'wf-daily-ledger-audit',
        societyId: defaultSociety,
        nameBn: 'দৈনিক ডে-এন্ড খতিয়ান ও ক্যাশ ব্যালেন্স অডিট',
        descriptionBn: 'ডেবিট-ক্রেডিট অমিল অথবা অস্বাভাবিক ভেরিয়েন্স থাকলে অডিট ফ্ল্যাগ তৈরি',
        category: WorkflowCategory.accountingAudit,
        isActive: true,
        priority: 10,
        trigger: const WorkflowTriggerModel(
          type: WorkflowTriggerType.scheduledCron,
          eventType: 'accounting.day_end.audit',
          cronExpression: '30 23 * * *',
        ),
        conditions: const [
          WorkflowConditionModel(field: 'unreconciledCashVariance', operator: '>', expectedValue: 0),
        ],
        actions: const [
          WorkflowActionModel(
            id: 'act-audit-reconcile-flag',
            nameBn: 'অ্যাকাউন্টিং মিসম্যাচ অনুমোদন রিকোয়েস্ট সৃষ্টি (মেকার-চেকার)',
            actionType: WorkflowActionType.requestApproval,
            parameters: {'target': 'chief_accountant'},
            isHighImpact: true,
            requiredRoleForApproval: 'accountant',
          ),
        ],
        createdBy: 'system_auto_engine',
        createdAt: now.subtract(const Duration(days: 60)),
        executionCount: 60,
        successCount: 58,
        failureCount: 2,
        lastRunAt: now.subtract(const Duration(days: 1)),
      ),
      AutomationWorkflowModel(
        id: 'wf-loan-high-impact-disburse',
        societyId: defaultSociety,
        nameBn: 'ঋণ অনুমোদন পরবর্তী স্বয়ংক্রিয় ভাউচার প্রস্তুতি (সুরক্ষিত)',
        descriptionBn: 'ঋণ অনুমোদন সাপেক্ষে ব্যাংক ভাউচার প্রস্তুত কিন্তু ক্যাশ বা একাউন্ট রিলিজের জন্য মানবিক অনুমোদন বাধ্যতামূলক',
        category: WorkflowCategory.loanOperations,
        isActive: true,
        priority: 10,
        trigger: const WorkflowTriggerModel(
          type: WorkflowTriggerType.eventDriven,
          eventType: 'loan.approved',
        ),
        conditions: const [
          WorkflowConditionModel(field: 'approvedAmount', operator: '>', expectedValue: 50000),
        ],
        actions: const [
          WorkflowActionModel(
            id: 'act-disburse-approval',
            nameBn: 'ঋণ অর্থ বিতরণের চূড়ান্ত ট্রেজারি অনুমোদন আবেদন',
            actionType: WorkflowActionType.requestApproval,
            parameters: {'policy': 'maker_checker_financial'},
            isHighImpact: true,
            requiredRoleForApproval: 'society_admin',
          ),
        ],
        createdBy: 'system_auto_engine',
        createdAt: now.subtract(const Duration(days: 10)),
        executionCount: 15,
        successCount: 15,
        failureCount: 0,
        lastRunAt: now.subtract(const Duration(hours: 12)),
      ),
    ];

    _societyWorkflows[defaultSociety] = seeded;

    // Seed sample execution logs
    _executionLogs.addAll([
      WorkflowExecutionLogModel(
        id: 'exec-seed-101',
        societyId: defaultSociety,
        workflowId: 'wf-loan-due-reminder',
        workflowNameBn: 'ঋণ কিস্তি আগাম স্মরণিকা ও বকেয়া ফলোআপ',
        idempotencyKey: 'seed_key_loan_due_20261114_01',
        triggerType: 'scheduledCron',
        status: ExecutionStatus.success,
        triggeredBy: 'cron_scheduler',
        inputPayload: {'daysUntilDue': 2, 'isPaid': false, 'memberId': 'M-1004'},
        executionDetails: {'smsSent': true, 'taskId': 'task-field-882'},
        startedAt: now.subtract(const Duration(hours: 3)),
        completedAt: now.subtract(const Duration(hours: 3, seconds: -2)),
      ),
      WorkflowExecutionLogModel(
        id: 'exec-seed-102',
        societyId: defaultSociety,
        workflowId: 'wf-member-onboarding',
        workflowNameBn: 'নতুন সদস্য অনবোর্ডিং ও কেওয়াইসি যাচাইকরণ পাইপলাইন',
        idempotencyKey: 'seed_key_onboard_20261114_02',
        triggerType: 'eventDriven',
        status: ExecutionStatus.success,
        triggeredBy: 'member_registration_service',
        inputPayload: {'status': 'pending_verification', 'memberId': 'M-1099'},
        executionDetails: {'taskAssigned': 'manager', 'pushSent': true},
        startedAt: now.subtract(const Duration(hours: 5)),
        completedAt: now.subtract(const Duration(hours: 5, seconds: -1)),
      ),
      WorkflowExecutionLogModel(
        id: 'exec-seed-103',
        societyId: defaultSociety,
        workflowId: 'wf-loan-due-reminder',
        workflowNameBn: 'ঋণ কিস্তি আগাম স্মরণিকা ও বকেয়া ফলোআপ',
        idempotencyKey: 'seed_key_loan_due_failed_03',
        triggerType: 'scheduledCron',
        status: ExecutionStatus.failedDlq,
        triggeredBy: 'cron_scheduler',
        inputPayload: {'daysUntilDue': 1, 'isPaid': false, 'memberId': 'M-1012'},
        executionDetails: {'attempts': 3, 'backoffDelays': [30, 60, 120]},
        retryCount: 3,
        errorDetails: 'টেলকো গেটওয়ে সংযোগ বিচ্ছিন্ন: HTTP 504 Gateway Timeout',
        startedAt: now.subtract(const Duration(hours: 8)),
        completedAt: now.subtract(const Duration(hours: 8, minutes: -4)),
      ),
    ]);

    // Seed sample approval request (Maker-Checker Queue)
    _approvalQueue.add(
      WorkflowApprovalRequestModel(
        id: 'appr-req-901',
        societyId: defaultSociety,
        workflowId: 'wf-loan-high-impact-disburse',
        executionId: 'exec-seed-pending-901',
        titleBn: 'সদস্য মোঃ হাবিবুর রহমানের ৳ ১,৫০,০০০ ক্ষুদ্র ব্যবসা ঋণ চূড়ান্ত বিতরণ অনুমোদন',
        actionType: 'loan.disburse',
        payload: {
          'memberId': 'M-1004',
          'memberName': 'মোঃ হাবিবুর রহমান',
          'loanId': 'L-2026-08',
          'amount': 150000,
          'approvedByCommittee': true,
        },
        requestedBy: 'automation_engine',
        status: 'pending',
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
    );
  }

  /// Central Event Trigger & Execution Method
  Future<Map<String, dynamic>> triggerEvent({
    required String societyId,
    required String eventType,
    required Map<String, dynamic> payload,
    int executionDepth = 1,
    String triggeredBy = 'system',
  }) async {
    final startTime = DateTime.now();

    // 1. Check Super Admin Global Switch
    if (!_masterConfig.globalAutomationEnabled) {
      return {
        'status': 'BLOCKED_BY_SUPER_ADMIN',
        'messageBn': 'সুপার এডমিন কর্তৃক প্ল্যাটফর্মের কেন্দ্রীয় অটোমেশন ইঞ্জিন নিষ্ক্রিয় রয়েছে।',
      };
    }

    // 2. Prevent Circular Trigger Recursion Loop
    if (executionDepth > _masterConfig.maxExecutionDepth) {
      return {
        'status': 'CIRCULAR_LOOP_DETECTED',
        'messageBn': 'সার্কুলার লুপ প্রতিরোধ: সর্বোচ্চ এক্সেকিউশন গভীরতা (${_masterConfig.maxExecutionDepth}) অতিক্রান্ত হয়েছে।',
      };
    }

    // 3. Find matching active workflows for this society and event
    final workflows = (_societyWorkflows[societyId] ?? [])
        .where((w) => w.isActive && w.trigger.eventType == eventType)
        .toList();

    if (workflows.isEmpty) {
      return {
        'status': 'NO_MATCHING_WORKFLOW',
        'messageBn': 'উক্ত ইভেন্টের জন্য কোনো সক্রিয় ওয়ার্কফ্লো পাওয়া যায়নি।',
      };
    }

    final results = <Map<String, dynamic>>[];

    for (final wf in workflows) {
      // 4. Evaluate Conditions
      bool conditionsMet = true;
      for (final cond in wf.conditions) {
        if (!cond.evaluate(payload)) {
          conditionsMet = false;
          break;
        }
      }

      if (!conditionsMet) {
        results.add({
          'workflowId': wf.id,
          'workflowNameBn': wf.nameBn,
          'status': 'CONDITIONS_NOT_MET',
        });
        continue;
      }

      // 5. Idempotency Key Validation
      final entityId = payload['memberId'] ?? payload['loanId'] ?? payload['id'] ?? 'general';
      final dateWindow = DateTime.now().toIso8601String().substring(0, 10); // Daily window
      final idempotencyKey = WorkflowExecutionLogModel.generateIdempotencyKey(
        societyId: societyId,
        workflowId: wf.id,
        entityId: entityId.toString(),
        dateOrWindow: dateWindow,
      );

      if (_processedIdempotencyKeys.contains(idempotencyKey)) {
        final duplicateLog = WorkflowExecutionLogModel(
          id: 'exec-${DateTime.now().millisecondsSinceEpoch}',
          societyId: societyId,
          workflowId: wf.id,
          workflowNameBn: wf.nameBn,
          idempotencyKey: idempotencyKey,
          triggerType: wf.trigger.type.name,
          status: ExecutionStatus.skippedDuplicate,
          triggeredBy: triggeredBy,
          inputPayload: payload,
          executionDepth: executionDepth,
          startedAt: startTime,
          completedAt: DateTime.now(),
        );
        _executionLogs.insert(0, duplicateLog);

        results.add({
          'workflowId': wf.id,
          'workflowNameBn': wf.nameBn,
          'status': 'SKIPPED_DUPLICATE',
          'idempotencyKey': idempotencyKey,
        });
        continue;
      }

      // Mark Idempotency key as processed
      _processedIdempotencyKeys.add(idempotencyKey);

      // 6. High-Impact & Maker-Checker Check
      bool hasHighImpactAction = wf.actions.any((a) =>
          a.isHighImpact ||
          a.actionType == WorkflowActionType.requestApproval ||
          _masterConfig.restrictedHighImpactActions.contains(a.nameBn));

      final execId = 'exec-${DateTime.now().millisecondsSinceEpoch}';

      if (hasHighImpactAction) {
        // High impact action: Route to Human-in-the-Loop Approval Queue
        final approvalRequest = WorkflowApprovalRequestModel(
          id: 'appr-$execId',
          societyId: societyId,
          workflowId: wf.id,
          executionId: execId,
          titleBn: '${wf.nameBn} - অনুমোদনের জন্য অপেক্ষারত',
          actionType: wf.actions.first.actionType.name,
          payload: payload,
          requestedBy: triggeredBy,
          status: 'pending',
          createdAt: startTime,
        );
        _approvalQueue.insert(0, approvalRequest);

        final pendingLog = WorkflowExecutionLogModel(
          id: execId,
          societyId: societyId,
          workflowId: wf.id,
          workflowNameBn: wf.nameBn,
          idempotencyKey: idempotencyKey,
          triggerType: wf.trigger.type.name,
          status: ExecutionStatus.pendingApproval,
          triggeredBy: triggeredBy,
          inputPayload: payload,
          executionDetails: {'approvalRequestId': approvalRequest.id},
          executionDepth: executionDepth,
          startedAt: startTime,
        );
        _executionLogs.insert(0, pendingLog);

        results.add({
          'workflowId': wf.id,
          'workflowNameBn': wf.nameBn,
          'status': 'PENDING_MAKER_CHECKER_APPROVAL',
          'approvalId': approvalRequest.id,
        });
        continue;
      }

      // 7. Safe Non-Impact Actions: Execute immediately
      final executedActions = <String>[];
      for (final act in wf.actions) {
        executedActions.add('${act.actionType.name}: ${act.nameBn}');
      }

      final successLog = WorkflowExecutionLogModel(
        id: execId,
        societyId: societyId,
        workflowId: wf.id,
        workflowNameBn: wf.nameBn,
        idempotencyKey: idempotencyKey,
        triggerType: wf.trigger.type.name,
        status: ExecutionStatus.success,
        triggeredBy: triggeredBy,
        inputPayload: payload,
        executionDetails: {'executedActions': executedActions},
        executionDepth: executionDepth,
        startedAt: startTime,
        completedAt: DateTime.now(),
      );
      _executionLogs.insert(0, successLog);

      results.add({
        'workflowId': wf.id,
        'workflowNameBn': wf.nameBn,
        'status': 'SUCCESS',
        'executionId': execId,
      });
    }

    return {
      'status': 'COMPLETED',
      'societyId': societyId,
      'eventType': eventType,
      'results': results,
    };
  }

  /// Maker-Checker Approval Processing
  Future<bool> processApproval({
    required String approvalId,
    required bool approve,
    required String reviewerUid,
    required String remarksBn,
  }) async {
    final index = _approvalQueue.indexWhere((a) => a.id == approvalId);
    if (index == -1) return false;

    final existing = _approvalQueue[index];
    _approvalQueue[index] = WorkflowApprovalRequestModel(
      id: existing.id,
      societyId: existing.societyId,
      workflowId: existing.workflowId,
      executionId: existing.executionId,
      titleBn: existing.titleBn,
      actionType: existing.actionType,
      payload: existing.payload,
      requestedBy: existing.requestedBy,
      status: approve ? 'approved' : 'rejected',
      reviewedBy: reviewerUid,
      reviewRemarksBn: remarksBn,
      createdAt: existing.createdAt,
      decidedAt: DateTime.now(),
    );

    // Update corresponding execution log
    final logIndex = _executionLogs.indexWhere((l) => l.id == existing.executionId);
    if (logIndex != -1) {
      final oldLog = _executionLogs[logIndex];
      _executionLogs[logIndex] = WorkflowExecutionLogModel(
        id: oldLog.id,
        societyId: oldLog.societyId,
        workflowId: oldLog.workflowId,
        workflowNameBn: oldLog.workflowNameBn,
        idempotencyKey: oldLog.idempotencyKey,
        triggerType: oldLog.triggerType,
        status: approve ? ExecutionStatus.success : ExecutionStatus.rejected,
        triggeredBy: oldLog.triggeredBy,
        inputPayload: oldLog.inputPayload,
        executionDetails: {
          ...oldLog.executionDetails,
          'approvedBy': reviewerUid,
          'remarksBn': remarksBn,
        },
        executionDepth: oldLog.executionDepth,
        startedAt: oldLog.startedAt,
        completedAt: DateTime.now(),
      );
    }

    return true;
  }

  /// Dead-Letter Queue Manual Replay
  Future<bool> replayDeadLetter({
    required String executionId,
    required String adminUid,
  }) async {
    final index = _executionLogs.indexWhere((l) => l.id == executionId);
    if (index == -1) return false;

    final oldLog = _executionLogs[index];
    _executionLogs[index] = WorkflowExecutionLogModel(
      id: oldLog.id,
      societyId: oldLog.societyId,
      workflowId: oldLog.workflowId,
      workflowNameBn: oldLog.workflowNameBn,
      idempotencyKey: oldLog.idempotencyKey,
      triggerType: oldLog.triggerType,
      status: ExecutionStatus.success,
      triggeredBy: 'replayed_by_$adminUid',
      inputPayload: oldLog.inputPayload,
      executionDetails: {
        ...oldLog.executionDetails,
        'replayedBy': adminUid,
        'replayedAt': DateTime.now().toIso8601String(),
      },
      retryCount: oldLog.retryCount + 1,
      startedAt: oldLog.startedAt,
      completedAt: DateTime.now(),
    );
    return true;
  }

  /// Toggle Workflow active status
  bool toggleWorkflow(String societyId, String workflowId, bool isActive) {
    final list = _societyWorkflows[societyId];
    if (list == null) return false;
    final index = list.indexWhere((w) => w.id == workflowId);
    if (index == -1) return false;

    final current = list[index];
    list[index] = AutomationWorkflowModel(
      id: current.id,
      societyId: current.societyId,
      nameBn: current.nameBn,
      descriptionBn: current.descriptionBn,
      category: current.category,
      isActive: isActive,
      priority: current.priority,
      trigger: current.trigger,
      conditions: current.conditions,
      actions: current.actions,
      lastRunAt: current.lastRunAt,
      executionCount: current.executionCount,
      successCount: current.successCount,
      failureCount: current.failureCount,
      createdBy: current.createdBy,
      createdAt: current.createdAt,
    );
    return true;
  }
}
