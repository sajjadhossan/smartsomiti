// test/enterprise_automation_test.dart
// Phase 20: Enterprise Automation & Autonomous Operations Engine Unit Tests

import 'package:flutter_test/flutter_test.dart';
import '../lib/models/enterprise_automation_model.dart';
import '../lib/services/enterprise_automation_service.dart';

void main() {
  group('Phase 20 — Enterprise Automation & Autonomous Operations Engine Tests', () {
    late EnterpriseAutomationService service;
    const testSociety = 'swapno_chowa_main';

    setUp(() {
      service = EnterpriseAutomationService();
      // Ensure global automation is enabled before each test
      service.updateMasterConfig(const SuperAdminAutomationMasterConfig(
        globalAutomationEnabled: true,
        maxExecutionDepth: 3,
        maxRetries: 3,
      ));
    });

    // Test 1: Trigger Registry & Pre-Seeded Workflows Verification
    test('1. Trigger Registry & Pre-Seeded Workflows Verification', () {
      final workflows = service.getWorkflows(testSociety);
      expect(workflows, isNotEmpty);
      expect(workflows.length, greaterThanOrEqualTo(5));

      final loanReminder = workflows.firstWhere((w) => w.id == 'wf-loan-due-reminder');
      expect(loanReminder.trigger.type, equals(WorkflowTriggerType.scheduledCron));
      expect(loanReminder.trigger.eventType, equals('loan.installment.due'));
      expect(loanReminder.trigger.cronExpression, equals('0 9 * * *'));
      expect(loanReminder.priority, equals(9));
      expect(loanReminder.isActive, isTrue);
    });

    // Test 2: Condition Evaluator Operators (==, <=, >, in, contains)
    test('2. Condition Evaluator Operators (==, <=, >, in, contains)', () {
      final condNum = const WorkflowConditionModel(field: 'daysUntilDue', operator: '<=', expectedValue: 3);
      expect(condNum.evaluate({'daysUntilDue': 2}), isTrue);
      expect(condNum.evaluate({'daysUntilDue': 4}), isFalse);

      final condBool = const WorkflowConditionModel(field: 'isPaid', operator: '==', expectedValue: false);
      expect(condBool.evaluate({'isPaid': false}), isTrue);
      expect(condBool.evaluate({'isPaid': true}), isFalse);

      final condGt = const WorkflowConditionModel(field: 'unreconciledCashVariance', operator: '>', expectedValue: 0);
      expect(condGt.evaluate({'unreconciledCashVariance': 500}), isTrue);
      expect(condGt.evaluate({'unreconciledCashVariance': 0}), isFalse);

      final condIn = const WorkflowConditionModel(field: 'tier', operator: 'in', expectedValue: ['gold', 'platinum']);
      expect(condIn.evaluate({'tier': 'gold'}), isTrue);
      expect(condIn.evaluate({'tier': 'silver'}), isFalse);
    });

    // Test 3: Event-Driven Workflow Execution with Safe Actions
    test('3. Event-Driven Workflow Execution with Safe Actions', () async {
      final result = await service.triggerEvent(
        societyId: testSociety,
        eventType: 'member.created',
        payload: {
          'id': 'M-TEST-001',
          'memberId': 'M-TEST-001',
          'status': 'pending_verification',
          'nameBn': 'মোঃ শফিকুল ইসলাম',
        },
        triggeredBy: 'unit_test_suite',
      );

      expect(result['status'], equals('COMPLETED'));
      final resultsList = result['results'] as List<Map<String, dynamic>>;
      expect(resultsList, isNotEmpty);

      final onboardRes = resultsList.firstWhere((r) => r['workflowId'] == 'wf-member-onboarding');
      expect(onboardRes['status'], equals('SUCCESS'));
      expect(onboardRes['executionId'], startsWith('exec-'));
    });

    // Test 4: Idempotency Key Generation & Duplicate Execution Prevention
    test('4. Idempotency Key Generation & Duplicate Execution Prevention', () async {
      final payload = {
        'id': 'M-IDEMP-001',
        'memberId': 'M-IDEMP-001',
        'status': 'pending_verification',
      };

      // First run: Should succeed
      final res1 = await service.triggerEvent(
        societyId: testSociety,
        eventType: 'member.created',
        payload: payload,
      );
      final r1 = (res1['results'] as List)[0];
      expect(r1['status'], equals('SUCCESS'));

      // Second run with identical payload in same daily window: Should skip as duplicate
      final res2 = await service.triggerEvent(
        societyId: testSociety,
        eventType: 'member.created',
        payload: payload,
      );
      final r2 = (res2['results'] as List)[0];
      expect(r2['status'], equals('SKIPPED_DUPLICATE'));
      expect(r2['idempotencyKey'], isNotNull);
    });

    // Test 5: Circular Trigger & Recursion Loop Circuit Breaker
    test('5. Circular Trigger & Recursion Loop Circuit Breaker', () async {
      final result = await service.triggerEvent(
        societyId: testSociety,
        eventType: 'member.created',
        payload: {'status': 'pending_verification', 'id': 'M-LOOP-01'},
        executionDepth: 4, // Exceeds default limit of 3
      );

      expect(result['status'], equals('CIRCULAR_LOOP_DETECTED'));
      expect(result['messageBn'], contains('সর্বোচ্চ এক্সেকিউশন গভীরতা'));
    });

    // Test 6: High-Impact Action Safety: Maker-Checker Approval Required
    test('6. High-Impact Action Safety: Maker-Checker Approval Required', () async {
      final result = await service.triggerEvent(
        societyId: testSociety,
        eventType: 'loan.approved',
        payload: {
          'loanId': 'L-SAFE-001',
          'approvedAmount': 75000,
          'memberId': 'M-TEST-002',
        },
      );

      final resultsList = result['results'] as List<Map<String, dynamic>>;
      final disburseRes = resultsList.firstWhere((r) => r['workflowId'] == 'wf-loan-high-impact-disburse');
      expect(disburseRes['status'], equals('PENDING_MAKER_CHECKER_APPROVAL'));
      expect(disburseRes['approvalId'], startsWith('appr-'));

      // Ensure approval is in queue
      final queue = service.getApprovalQueue(testSociety);
      final item = queue.firstWhere((a) => a.id == disburseRes['approvalId']);
      expect(item.status, equals('pending'));
      expect(item.actionType, equals('requestApproval'));
    });

    // Test 7: Human Approval Decision (Approve -> Success State)
    test('7. Human Approval Decision (Approve -> Success State)', () async {
      final success = await service.processApproval(
        approvalId: 'appr-req-901',
        approve: true,
        reviewerUid: 'admin-treasurer-01',
        remarksBn: 'যথাযথ জামানত যাচাই সাপেক্ষে ঋণ অনুমোদন করা হলো।',
      );

      expect(success, isTrue);
      final queue = service.getApprovalQueue(testSociety);
      final item = queue.firstWhere((a) => a.id == 'appr-req-901');
      expect(item.status, equals('approved'));
      expect(item.reviewedBy, equals('admin-treasurer-01'));
    });

    // Test 8: Human Rejection Decision (Reject -> Rejected State)
    test('8. Human Rejection Decision (Reject -> Rejected State)', () async {
      // Create a pending request
      final result = await service.triggerEvent(
        societyId: testSociety,
        eventType: 'loan.approved',
        payload: {
          'loanId': 'L-REJECT-001',
          'approvedAmount': 90000,
          'memberId': 'M-REJECT-001',
        },
      );
      final apprId = (result['results'] as List)[0]['approvalId'];

      final rejected = await service.processApproval(
        approvalId: apprId,
        approve: false,
        reviewerUid: 'admin-president-01',
        remarksBn: 'ক্রেডিট হিস্ট্রি সন্তোষজনক নয়, আবেদন বাতিল।',
      );

      expect(rejected, isTrue);
      final queue = service.getApprovalQueue(testSociety);
      final item = queue.firstWhere((a) => a.id == apprId);
      expect(item.status, equals('rejected'));
    });

    // Test 9: Dead-Letter Queue (DLQ) & 1-Click Manual Replay
    test('9. Dead-Letter Queue (DLQ) & 1-Click Manual Replay', () async {
      final dlq = service.getDeadLetters(testSociety);
      expect(dlq, isNotEmpty);
      final failedTask = dlq.firstWhere((d) => d.id == 'exec-seed-103');
      expect(failedTask.status, equals(ExecutionStatus.failedDlq));
      expect(failedTask.retryCount, equals(3));
      expect(failedTask.errorDetails, contains('টেলকো গেটওয়ে সংযোগ বিচ্ছিন্ন'));

      // 1-Click Manual Replay
      final replayed = await service.replayDeadLetter(
        executionId: 'exec-seed-103',
        adminUid: 'super_admin_sajjad',
      );
      expect(replayed, isTrue);

      final logs = service.getExecutionLogs(testSociety);
      final updatedTask = logs.firstWhere((l) => l.id == 'exec-seed-103');
      expect(updatedTask.status, equals(ExecutionStatus.success));
      expect(updatedTask.triggeredBy, contains('replayed_by_super_admin_sajjad'));
    });

    // Test 10: Super Admin Universal Global Automation Kill Switch
    test('10. Super Admin Universal Global Automation Kill Switch', () async {
      // Turn off master automation switch
      service.updateMasterConfig(const SuperAdminAutomationMasterConfig(
        globalAutomationEnabled: false,
      ));

      final result = await service.triggerEvent(
        societyId: testSociety,
        eventType: 'member.created',
        payload: {'status': 'pending_verification'},
      );

      expect(result['status'], equals('BLOCKED_BY_SUPER_ADMIN'));
      expect(result['messageBn'], contains('সুপার এডমিন কর্তৃক প্ল্যাটফর্মের কেন্দ্রীয় অটোমেশন ইঞ্জিন নিষ্ক্রিয়'));
    });

    // Test 11: Multi-Tenant Society Workflow Isolation
    test('11. Multi-Tenant Society Workflow Isolation', () {
      final mainSocietyWorkflows = service.getWorkflows('swapno_chowa_main');
      expect(mainSocietyWorkflows, isNotEmpty);

      // Other society should not bleed into another
      final otherSocietyWorkflows = service.getWorkflows('random_other_society');
      expect(otherSocietyWorkflows, isEmpty);
    });

    // Test 12: Workflow Enable / Disable Toggle State Validation
    test('12. Workflow Enable / Disable Toggle State Validation', () {
      final toggleSuccess = service.toggleWorkflow(testSociety, 'wf-loan-due-reminder', false);
      expect(toggleSuccess, isTrue);

      var workflows = service.getWorkflows(testSociety);
      var wf = workflows.firstWhere((w) => w.id == 'wf-loan-due-reminder');
      expect(wf.isActive, isFalse);

      // Re-enable
      service.toggleWorkflow(testSociety, 'wf-loan-due-reminder', true);
      workflows = service.getWorkflows(testSociety);
      wf = workflows.firstWhere((w) => w.id == 'wf-loan-due-reminder');
      expect(wf.isActive, isTrue);
    });
  });
}
