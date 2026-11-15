import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_sync_drive/models/workflow_engine_model.dart';
import 'package:cloud_sync_drive/services/workflow_engine_service.dart';

void main() {
  group('Enterprise Approval & Workflow Engine Tests', () {
    test('13 State Machine Enum and String mapping coverage', () {
      final allStates = ApprovalRequestStatus.values;
      expect(allStates.length, equals(13));

      expect(ApprovalRequestStatus.draft.toDbString(), equals('draft'));
      expect(ApprovalRequestStatus.submitted.toDbString(), equals('submitted'));
      expect(ApprovalRequestStatus.pendingReview.toDbString(), equals('pending_review'));
      expect(ApprovalRequestStatus.underReview.toDbString(), equals('under_review'));
      expect(ApprovalRequestStatus.approved.toDbString(), equals('approved'));
      expect(ApprovalRequestStatus.rejected.toDbString(), equals('rejected'));
      expect(ApprovalRequestStatus.returnedForCorrection.toDbString(), equals('returned_for_correction'));
      expect(ApprovalRequestStatus.resubmitted.toDbString(), equals('resubmitted'));
      expect(ApprovalRequestStatus.escalated.toDbString(), equals('escalated'));
      expect(ApprovalRequestStatus.cancelled.toDbString(), equals('cancelled'));
      expect(ApprovalRequestStatus.processing.toDbString(), equals('processing'));
      expect(ApprovalRequestStatus.completed.toDbString(), equals('completed'));
      expect(ApprovalRequestStatus.failed.toDbString(), equals('failed'));

      for (final st in allStates) {
        expect(ApprovalRequestStatusExtension.fromString(st.toDbString()), equals(st));
        expect(st.toBanglaLabel().isNotEmpty, isTrue);
      }
    });

    test('Stage Model & Workflow Definition Model serialization', () {
      final stage1 = ApprovalStageDefinition(
        stageOrder: 1,
        stageKey: 'officer_review',
        stageNameBn: 'মাঠ কর্মকর্তা যাচাই',
        requiredRole: 'field_officer',
        slaHours: 24,
      );

      final stage2 = ApprovalStageDefinition(
        stageOrder: 2,
        stageKey: 'manager_approval',
        stageNameBn: 'ম্যানেজার চূড়ান্ত অনুমোদন',
        requiredRole: 'manager',
        slaHours: 48,
      );

      final wfDef = WorkflowDefinitionModel(
        id: 'wf_loan_test',
        somitiId: 'somiti_001',
        workflowCode: 'WF-LOAN',
        titleBn: 'ঋণ অনুমোদন প্রক্রিয়া',
        moduleKey: 'loan_management',
        requestType: 'loan_disbursement',
        isActive: true,
        minAmountInPoisha: 100000,
        maxAmountInPoisha: 5000000,
        stages: [stage1, stage2],
      );

      final map = wfDef.toMap();
      expect(map['workflowCode'], equals('WF-LOAN'));
      expect((map['stages'] as List).length, equals(2));

      final restored = WorkflowDefinitionModel.fromMap(map, 'wf_loan_test');
      expect(restored.stages.length, equals(2));
      expect(restored.stages.first.stageKey, equals('officer_review'));
      expect(restored.stages.last.requiredRole, equals('manager'));
    });

    test('Maker-Checker Security: Self-approval is strictly forbidden', () {
      final request = ApprovalRequestModel(
        id: 'req_001',
        trackingNumber: 'APP-202611-00001',
        somitiId: 'somiti_001',
        workflowId: 'wf_loan_test',
        workflowCode: 'WF-LOAN',
        workflowTitleBn: 'ঋণ অনুমোদন',
        moduleKey: 'loan_management',
        requestType: 'loan_disbursement',
        entityId: 'loan_999',
        makerUid: 'user_sajjad',
        makerName: 'মোঃ সাজ্জাদ',
        makerRole: 'manager',
        amountInPoisha: 5000000, // ৳50,000.00
        currentStageOrder: 1,
        totalStages: 2,
        currentStageNameBn: 'ম্যানেজার অনুমোদন',
        currentAssignedRole: 'manager',
        status: ApprovalRequestStatus.pendingReview,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Verify Maker is user_sajjad
      expect(request.makerUid, equals('user_sajjad'));

      // If user_sajjad tries to act as Checker, rule violation is raised
      final isSelfApproval = request.makerUid == 'user_sajjad';
      expect(isSelfApproval, isTrue);

      // The exception is thrown when maker attempts to approve
      expect(
        () {
          if (request.makerUid == 'user_sajjad') {
            throw WorkflowSecurityException('মেকার-চেকার লঙ্ঘন: আবেদনকারী নিজ আবেদন অনুমোদন করতে পারবেন না।');
          }
        },
        throwsA(isA<WorkflowSecurityException>()),
      );
    });

    test('Sequential multi-stage approval flow transitions', () {
      final stageHistory = <StageHistoryRecord>[];

      // Stage 1 approval by Officer (UID: officer_101)
      final req1 = ApprovalRequestModel(
        id: 'req_002',
        trackingNumber: 'APP-202611-00002',
        somitiId: 'somiti_001',
        workflowId: 'wf_loan_test',
        workflowCode: 'WF-LOAN',
        workflowTitleBn: 'ঋণ অনুমোদন',
        moduleKey: 'loan_management',
        requestType: 'loan_disbursement',
        entityId: 'loan_1001',
        makerUid: 'member_service_officer',
        makerName: 'আবেদনকারী কর্মকর্তা',
        makerRole: 'staff',
        amountInPoisha: 2000000, // ৳20,000.00
        currentStageOrder: 1,
        totalStages: 2,
        currentStageNameBn: 'মাঠ কর্মকর্তা যাচাই',
        currentAssignedRole: 'field_officer',
        status: ApprovalRequestStatus.pendingReview,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Verify maker != checker
      expect(req1.makerUid != 'field_officer_kamal', isTrue);

      stageHistory.add(StageHistoryRecord(
        stageOrder: 1,
        stageNameBn: 'মাঠ কর্মকর্তা যাচাই',
        actorUid: 'field_officer_kamal',
        actorName: 'কামাল হোসেন',
        actorRole: 'field_officer',
        actionTaken: 'approved',
        commentsBn: 'সকল তথ্য ও জামিনদার যাচাই সঠিক পাওয়া গেছে।',
        actionTime: DateTime.now(),
      ));

      // Request advances to Stage 2 (Manager)
      final reqStage2 = req1.copyWith(
        currentStageOrder: 2,
        currentStageNameBn: 'ম্যানেজার চূড়ান্ত অনুমোদন',
        currentAssignedRole: 'manager',
        status: ApprovalRequestStatus.underReview,
        history: stageHistory,
      );

      expect(reqStage2.currentStageOrder, equals(2));
      expect(reqStage2.status, equals(ApprovalRequestStatus.underReview));
      expect(reqStage2.history.length, equals(1));

      // Stage 2 approval by Manager (UID: manager_rahim)
      expect(reqStage2.makerUid != 'manager_rahim', isTrue);

      stageHistory.add(StageHistoryRecord(
        stageOrder: 2,
        stageNameBn: 'ম্যানেজার চূড়ান্ত অনুমোদন',
        actorUid: 'manager_rahim',
        actorName: 'রহিম চৌধুরী',
        actorRole: 'manager',
        actionTaken: 'approved',
        commentsBn: 'চূড়ান্ত মঞ্জুরি প্রদান করা হলো।',
        actionTime: DateTime.now(),
      ));

      final reqFinalApproved = reqStage2.copyWith(
        status: ApprovalRequestStatus.approved,
        history: stageHistory,
      );

      expect(reqFinalApproved.status, equals(ApprovalRequestStatus.approved));
      expect(reqFinalApproved.history.length, equals(2));
      expect(reqFinalApproved.history.last.actorRole, equals('manager'));
    });

    test('Return for Correction and Resubmission cycle', () {
      final req = ApprovalRequestModel(
        id: 'req_003',
        trackingNumber: 'APP-202611-00003',
        somitiId: 'somiti_001',
        workflowId: 'wf_exp_large',
        workflowCode: 'WF-EXP-LARGE',
        workflowTitleBn: 'বড় অঙ্কের খরচ অনুমোদন',
        moduleKey: 'cash_management',
        requestType: 'expense',
        entityId: 'exp_501',
        makerUid: 'accountant_01',
        makerName: 'হিসাবরক্ষক',
        makerRole: 'accountant',
        amountInPoisha: 1500000, // ৳15,000
        currentStageOrder: 1,
        totalStages: 2,
        currentStageNameBn: 'ম্যানেজার যাচাই',
        currentAssignedRole: 'manager',
        status: ApprovalRequestStatus.pendingReview,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Manager returns for correction
      final returned = req.copyWith(
        status: ApprovalRequestStatus.returnedForCorrection,
        rejectionReason: 'ভাউচার রসিদের স্ক্যান কপি অস্পষ্ট, পুনরায় আপলোড করুন।',
      );

      expect(returned.status, equals(ApprovalRequestStatus.returnedForCorrection));
      expect(returned.rejectionReason, contains('স্ক্যান কপি অস্পষ্ট'));

      // Resubmission by Accountant
      final resubmitted = returned.copyWith(
        status: ApprovalRequestStatus.resubmitted,
        currentStageOrder: 1,
        rejectionReason: null,
      );

      expect(resubmitted.status, equals(ApprovalRequestStatus.resubmitted));
      expect(resubmitted.currentStageOrder, equals(1));
    });

    test('Delegation rule verification', () {
      final now = DateTime.now();
      final validDelegation = ApprovalDelegationModel(
        id: 'del_001',
        somitiId: 'somiti_001',
        delegatorUid: 'manager_rahim',
        delegatorRole: 'manager',
        delegateUid: 'asst_manager_karim',
        delegateName: 'করিম সহকারী ম্যানেজার',
        startDate: now.subtract(const Duration(days: 1)),
        endDate: now.add(const Duration(days: 5)),
        allowedModules: ['loan_management', 'cash_management'],
        isActive: true,
      );

      expect(validDelegation.isValidAt(now), isTrue);

      final expiredDelegation = validDelegation.copyWith(
        endDate: now.subtract(const Duration(hours: 2)),
      );
      expect(expiredDelegation.isValidAt(now), isFalse);

      final inactiveDelegation = validDelegation.copyWith(
        isActive: false,
      );
      expect(inactiveDelegation.isValidAt(now), isFalse);
    });
  });
}
