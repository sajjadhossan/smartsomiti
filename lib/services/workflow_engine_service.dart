import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/workflow_engine_model.dart';

class WorkflowEngineService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _defsRef(String somitiId) {
    return _firestore.collection('somitis').doc(somitiId).collection('workflow_definitions');
  }

  CollectionReference<Map<String, dynamic>> _requestsRef(String somitiId) {
    return _firestore.collection('somitis').doc(somitiId).collection('approval_requests');
  }

  CollectionReference<Map<String, dynamic>> _delegationsRef(String somitiId) {
    return _firestore.collection('somitis').doc(somitiId).collection('approval_delegations');
  }

  /// Ensure default standard workflows exist for society
  Future<void> ensureDefaultWorkflows(String somitiId) async {
    final snap = await _defsRef(somitiId).limit(1).get();
    if (snap.docs.isNotEmpty) return;

    final batch = _firestore.batch();
    final now = DateTime.now();

    // 1. Standard Multi-Tier Loan Approval
    final loanWf = WorkflowDefinitionModel(
      id: 'wf_loan_default',
      somitiId: somitiId,
      name: 'সাধারণ ঋণ অনুমোদন কর্মপ্রবাহ (৩-স্তর)',
      moduleKey: 'loan_approval',
      description: 'মাঠ কর্মকর্তা যাচাইকরণ -> ম্যানেজার পর্যালোচনা -> মালিকের চূড়ান্ত অনুমোদন',
      triggerEvent: 'loan_application_submitted',
      minAmountInPoisha: 0,
      maxAmountInPoisha: -1,
      stages: [
        ApprovalStageDefinition(stageIndex: 0, stageName: 'মাঠ কর্মকর্তা যাচাই ও সুপারিশ', assignedRole: 'field_officer', slaHours: 24),
        ApprovalStageDefinition(stageIndex: 1, stageName: 'ম্যানেজার ঝুঁকি পর্যালোচনা', assignedRole: 'manager', slaHours: 24),
        ApprovalStageDefinition(stageIndex: 2, stageName: 'সমিতি মালিকের চূড়ান্ত মঞ্জুরি', assignedRole: 'owner', isFinalStage: true, slaHours: 48),
      ],
      createdBy: 'system',
      updatedAt: now,
    );
    batch.set(_defsRef(somitiId).doc(loanWf.id), loanWf.toMap());

    // 2. Amount-Based Expense Approval (< ৳5,000 Manager; >= ৳5,000 Owner)
    final expSmall = WorkflowDefinitionModel(
      id: 'wf_exp_small',
      somitiId: somitiId,
      name: 'ছোট খরচ অনুমোদন (< ৳৫,০০০)',
      moduleKey: 'expense_approval',
      description: '৫,০০০ টাকার নিচের খরচ ম্যানেজার কর্তৃক অনুমোদন',
      triggerEvent: 'expense_voucher_created',
      minAmountInPoisha: 0,
      maxAmountInPoisha: 500000, // ৳5,000.00
      stages: [
        ApprovalStageDefinition(stageIndex: 0, stageName: 'ম্যানেজার অনুমোদন', assignedRole: 'manager', isFinalStage: true, slaHours: 24),
      ],
      createdBy: 'system',
      updatedAt: now,
    );
    batch.set(_defsRef(somitiId).doc(expSmall.id), expSmall.toMap());

    final expLarge = WorkflowDefinitionModel(
      id: 'wf_exp_large',
      somitiId: somitiId,
      name: 'বড় খরচ অনুমোদন (>= ৳৫,০০০)',
      moduleKey: 'expense_approval',
      description: '৫,০০০ টাকার ঊর্ধ্বের খরচ ম্যানেজার যাচাই + মালিকের চূড়ান্ত অনুমোদন',
      triggerEvent: 'expense_voucher_created',
      minAmountInPoisha: 500001,
      maxAmountInPoisha: -1,
      stages: [
        ApprovalStageDefinition(stageIndex: 0, stageName: 'ম্যানেজার যাচাই ও সুপারিশ', assignedRole: 'manager', slaHours: 24),
        ApprovalStageDefinition(stageIndex: 1, stageName: 'সমিতি মালিকের চূড়ান্ত অনুমোদন', assignedRole: 'owner', isFinalStage: true, slaHours: 48),
      ],
      createdBy: 'system',
      updatedAt: now,
    );
    batch.set(_defsRef(somitiId).doc(expLarge.id), expLarge.toMap());

    await batch.commit();
  }

  /// Submit a new request into the Workflow Engine
  Future<String> submitRequest(
    String somitiId, {
    required String moduleKey,
    required String sourceDocumentId,
    required String title,
    required int amountInPoisha,
    required String makerUid,
    required String makerName,
  }) async {
    // 1. Resolve matching workflow definition
    final defsSnap = await _defsRef(somitiId)
        .where('moduleKey', isEqualTo: moduleKey)
        .where('isActive', isEqualTo: true)
        .get();

    WorkflowDefinitionModel? selectedWf;
    for (final doc in defsSnap.docs) {
      final wf = WorkflowDefinitionModel.fromSnapshot(doc);
      if (amountInPoisha >= wf.minAmountInPoisha &&
          (wf.maxAmountInPoisha == -1 || amountInPoisha <= wf.maxAmountInPoisha)) {
        selectedWf = wf;
        break;
      }
    }

    if (selectedWf == null || selectedWf.stages.isEmpty) {
      // Fallback single-stage owner workflow
      selectedWf = WorkflowDefinitionModel(
        id: 'wf_default_fallback',
        somitiId: somitiId,
        name: 'স্ট্যান্ডার্ড অনুমোদন',
        moduleKey: moduleKey,
        triggerEvent: 'direct_submit',
        stages: [ApprovalStageDefinition(stageIndex: 0, stageName: 'অনুমোদন', assignedRole: 'owner', isFinalStage: true)],
        createdBy: 'system',
        updatedAt: DateTime.now(),
      );
    }

    final firstStage = selectedWf.stages.first;
    final now = DateTime.now();
    final reqDocRef = _requestsRef(somitiId).doc();

    final req = ApprovalRequestModel(
      id: reqDocRef.id,
      somitiId: somitiId,
      workflowId: selectedWf.id,
      moduleKey: moduleKey,
      sourceDocumentId: sourceDocumentId,
      title: title,
      amountInPoisha: amountInPoisha,
      makerUid: makerUid,
      makerName: makerName,
      currentStageIndex: 0,
      currentStageName: firstStage.stageName,
      assignedRole: firstStage.assignedRole,
      assignedUserUids: firstStage.assignedUserUids,
      status: ApprovalStatus.pendingReview,
      stageHistory: [
        StageHistoryRecord(
          stageIndex: -1,
          stageName: 'দাখিল',
          assignedRole: 'maker',
          action: 'SUBMITTED',
          actorUid: makerUid,
          actorName: makerName,
          comment: 'আবেদনপত্র দাখিল করা হয়েছে।',
          timestamp: now,
        )
      ],
      createdAt: now,
      updatedAt: now,
    );

    await reqDocRef.set(req.toMap());
    return reqDocRef.id;
  }

  /// Approve current stage with strict Maker-Checker enforcement
  Future<ApprovalStatus> approveStage(
    String somitiId, {
    required String requestId,
    required String actorUid,
    required String actorName,
    required String actorRole,
    required String comment,
  }) async {
    final reqRef = _requestsRef(somitiId).doc(requestId);
    final now = DateTime.now();

    return await _firestore.runTransaction<ApprovalStatus>((transaction) async {
      final reqSnap = await transaction.get(reqRef);
      if (!reqSnap.exists) throw Exception('অনুমোদন আবেদনটি পাওয়া যায়নি');

      final req = ApprovalRequestModel.fromSnapshot(reqSnap);

      // --- CRITICAL MAKER-CHECKER SECURITY INVARIANT ---
      if (req.makerUid == actorUid) {
        throw Exception('নিরাপত্তা সতর্কতা: আপনি নিজের তৈরিকৃত আবেদন নিজেই অনুমোদন করতে পারবেন না! (Maker-Checker Policy Violation)');
      }

      // Verify active workflow definition
      final wfDoc = await transaction.get(_defsRef(somitiId).doc(req.workflowId));
      List<ApprovalStageDefinition> stages = [];
      if (wfDoc.exists) {
        final wf = WorkflowDefinitionModel.fromSnapshot(wfDoc);
        stages = wf.stages;
      }

      final isLastStage = stages.isEmpty || req.currentStageIndex >= stages.length - 1 || (stages[req.currentStageIndex].isFinalStage);

      final newHistory = List<StageHistoryRecord>.from(req.stageHistory);
      newHistory.add(StageHistoryRecord(
        stageIndex: req.currentStageIndex,
        stageName: req.currentStageName,
        assignedRole: req.assignedRole,
        action: isLastStage ? 'FINAL_APPROVED' : 'STAGE_APPROVED',
        actorUid: actorUid,
        actorName: actorName,
        comment: comment.isNotEmpty ? comment : 'যাচাই ও অনুমোদন সম্পন্ন।',
        timestamp: now,
      ));

      if (isLastStage) {
        // Complete final approval
        transaction.update(reqRef, {
          'status': ApprovalStatus.approved.name,
          'stageHistory': newHistory.map((h) => h.toMap()).toList(),
          'updatedAt': Timestamp.fromDate(now),
          'completedAt': Timestamp.fromDate(now),
        });
        return ApprovalStatus.approved;
      } else {
        // Advance to next stage
        final nextIdx = req.currentStageIndex + 1;
        final nextStage = stages[nextIdx];

        transaction.update(reqRef, {
          'currentStageIndex': nextIdx,
          'currentStageName': nextStage.stageName,
          'assignedRole': nextStage.assignedRole,
          'assignedUserUids': nextStage.assignedUserUids,
          'status': ApprovalStatus.pendingReview.name,
          'stageHistory': newHistory.map((h) => h.toMap()).toList(),
          'updatedAt': Timestamp.fromDate(now),
        });
        return ApprovalStatus.pendingReview;
      }
    });
  }

  /// Reject an approval request
  Future<void> rejectRequest(
    String somitiId, {
    required String requestId,
    required String actorUid,
    required String actorName,
    required String reason,
  }) async {
    if (reason.trim().isEmpty) throw Exception('বাতিল করার কারণ উল্লেখ করা আবশ্যক');

    final reqRef = _requestsRef(somitiId).doc(requestId);
    final now = DateTime.now();

    final reqSnap = await reqRef.get();
    if (!reqSnap.exists) throw Exception('অনুমোদন আবেদনটি পাওয়া যায়নি');

    final req = ApprovalRequestModel.fromSnapshot(reqSnap);
    final newHistory = List<StageHistoryRecord>.from(req.stageHistory);
    newHistory.add(StageHistoryRecord(
      stageIndex: req.currentStageIndex,
      stageName: req.currentStageName,
      assignedRole: req.assignedRole,
      action: 'REJECTED',
      actorUid: actorUid,
      actorName: actorName,
      comment: reason,
      timestamp: now,
    ));

    await reqRef.update({
      'status': ApprovalStatus.rejected.name,
      'stageHistory': newHistory.map((h) => h.toMap()).toList(),
      'updatedAt': Timestamp.fromDate(now),
      'completedAt': Timestamp.fromDate(now),
    });
  }

  /// Return request for correction
  Future<void> returnForCorrection(
    String somitiId, {
    required String requestId,
    required String actorUid,
    required String actorName,
    required String instructions,
  }) async {
    if (instructions.trim().isEmpty) throw Exception('সংশোধনের বিবরণ উল্লেখ করা আবশ্যক');

    final reqRef = _requestsRef(somitiId).doc(requestId);
    final now = DateTime.now();

    final reqSnap = await reqRef.get();
    if (!reqSnap.exists) throw Exception('অনুমোদন আবেদনটি পাওয়া যায়নি');

    final req = ApprovalRequestModel.fromSnapshot(reqSnap);
    final newHistory = List<StageHistoryRecord>.from(req.stageHistory);
    newHistory.add(StageHistoryRecord(
      stageIndex: req.currentStageIndex,
      stageName: req.currentStageName,
      assignedRole: req.assignedRole,
      action: 'RETURNED_FOR_CORRECTION',
      actorUid: actorUid,
      actorName: actorName,
      comment: instructions,
      timestamp: now,
    ));

    await reqRef.update({
      'status': ApprovalStatus.returnedForCorrection.name,
      'stageHistory': newHistory.map((h) => h.toMap()).toList(),
      'updatedAt': Timestamp.fromDate(now),
    });
  }

  /// Real-time stream of pending approvals for a user/role
  Stream<List<ApprovalRequestModel>> getPendingApprovalsStream(String somitiId, {String? role, String? userUid}) {
    Query<Map<String, dynamic>> q = _requestsRef(somitiId)
        .where('status', isEqualTo: ApprovalStatus.pendingReview.name)
        .orderBy('createdAt', descending: true);

    if (role != null && role != 'owner' && role != 'super_admin') {
      q = q.where('assignedRole', isEqualTo: role);
    }

    return q.snapshots().map((s) => s.docs.map((d) => ApprovalRequestModel.fromSnapshot(d)).toList());
  }
}
