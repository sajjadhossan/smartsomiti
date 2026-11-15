import 'package:cloud_firestore/cloud_firestore.dart';

enum ApprovalStatus {
  draft,                    // খসড়া
  submitted,                // দাখিলকৃত
  pendingReview,            // পর্যালোচনার অপেক্ষায়
  underReview,              // পর্যালোচনায় রয়েছে
  approved,                 // অনুমোদিত
  rejected,                 // প্রত্যাখ্যাত
  returnedForCorrection,    // সংশোধনের জন্য ফেরত
  resubmitted,              // পুনঃদাখিলকৃত
  escalated,                // উচ্চতর স্তরে হস্তান্তরিত
  cancelled,                // প্রত্যাহারকৃত
  processing,               // আর্থিক লেনদেন কার্যকর হচ্ছে
  completed,                // সম্পন্ন ও পোস্টকৃত
  failed,                   // ব্যর্থ / ত্রুটিপূর্ণ
}

enum ApprovalAction {
  submit,
  approve,
  reject,
  returnForCorrection,
  resubmit,
  delegate,
  cancel,
  escalate,
}

/// Definition of an individual stage in a multi-level workflow
class ApprovalStageDefinition {
  final int stageIndex;
  final String stageName;
  final String assignedRole;       // e.g. "field_officer", "manager", "owner", "accountant"
  final List<String> assignedUserUids;
  final bool isFinalStage;
  final int slaHours;              // Maximum hours before escalation

  ApprovalStageDefinition({
    required this.stageIndex,
    required this.stageName,
    required this.assignedRole,
    this.assignedUserUids = const [],
    this.isFinalStage = false,
    this.slaHours = 48,
  });

  Map<String, dynamic> toMap() {
    return {
      'stageIndex': stageIndex,
      'stageName': stageName,
      'assignedRole': assignedRole,
      'assignedUserUids': assignedUserUids,
      'isFinalStage': isFinalStage,
      'slaHours': slaHours,
    };
  }

  factory ApprovalStageDefinition.fromMap(Map<String, dynamic> map) {
    return ApprovalStageDefinition(
      stageIndex: (map['stageIndex'] as num?)?.toInt() ?? 0,
      stageName: map['stageName'] ?? '',
      assignedRole: map['assignedRole'] ?? 'manager',
      assignedUserUids: List<String>.from(map['assignedUserUids'] ?? []),
      isFinalStage: map['isFinalStage'] == true,
      slaHours: (map['slaHours'] as num?)?.toInt() ?? 48,
    );
  }
}

/// Reusable, configurable Workflow Template
class WorkflowDefinitionModel {
  final String id;
  final String somitiId;
  final String name;
  final String moduleKey;          // "loan_approval", "expense_approval", "savings_withdrawal"
  final String description;
  final String triggerEvent;
  final int minAmountInPoisha;
  final int maxAmountInPoisha;     // -1 for unlimited
  final List<ApprovalStageDefinition> stages;
  final bool isActive;
  final bool enforceMakerChecker;
  final bool allowDelegation;
  final String createdBy;
  final DateTime updatedAt;

  WorkflowDefinitionModel({
    required this.id,
    required this.somitiId,
    required this.name,
    required this.moduleKey,
    this.description = '',
    required this.triggerEvent,
    this.minAmountInPoisha = 0,
    this.maxAmountInPoisha = -1,
    required this.stages,
    this.isActive = true,
    this.enforceMakerChecker = true,
    this.allowDelegation = true,
    required this.createdBy,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'somitiId': somitiId,
      'name': name,
      'moduleKey': moduleKey,
      'description': description,
      'triggerEvent': triggerEvent,
      'minAmountInPoisha': minAmountInPoisha,
      'maxAmountInPoisha': maxAmountInPoisha,
      'stages': stages.map((s) => s.toMap()).toList(),
      'isActive': isActive,
      'enforceMakerChecker': enforceMakerChecker,
      'allowDelegation': allowDelegation,
      'createdBy': createdBy,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory WorkflowDefinitionModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final rawStages = (data['stages'] as List<dynamic>?) ?? [];
    final stageList = rawStages.map((s) => ApprovalStageDefinition.fromMap(Map<String, dynamic>.from(s))).toList();

    DateTime upd = DateTime.now();
    final ts = data['updatedAt'];
    if (ts is Timestamp) upd = ts.toDate();

    return WorkflowDefinitionModel(
      id: doc.id,
      somitiId: data['somitiId'] ?? '',
      name: data['name'] ?? '',
      moduleKey: data['moduleKey'] ?? '',
      description: data['description'] ?? '',
      triggerEvent: data['triggerEvent'] ?? '',
      minAmountInPoisha: (data['minAmountInPoisha'] as num?)?.toInt() ?? 0,
      maxAmountInPoisha: (data['maxAmountInPoisha'] as num?)?.toInt() ?? -1,
      stages: stageList,
      isActive: data['isActive'] != false,
      enforceMakerChecker: data['enforceMakerChecker'] != false,
      allowDelegation: data['allowDelegation'] != false,
      createdBy: data['createdBy'] ?? '',
      updatedAt: upd,
    );
  }
}

/// Immutable audit record of an individual stage action
class StageHistoryRecord {
  final int stageIndex;
  final String stageName;
  final String assignedRole;
  final String action;             // "APPROVED", "REJECTED", "CORRECTION", "RESUBMITTED", "ESCALATED"
  final String actorUid;
  final String actorName;
  final String comment;
  final DateTime timestamp;

  StageHistoryRecord({
    required this.stageIndex,
    required this.stageName,
    required this.assignedRole,
    required this.action,
    required this.actorUid,
    required this.actorName,
    required this.comment,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'stageIndex': stageIndex,
      'stageName': stageName,
      'assignedRole': assignedRole,
      'action': action,
      'actorUid': actorUid,
      'actorName': actorName,
      'comment': comment,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory StageHistoryRecord.fromMap(Map<String, dynamic> map) {
    DateTime ts = DateTime.now();
    final rawTs = map['timestamp'];
    if (rawTs is Timestamp) ts = rawTs.toDate();

    return StageHistoryRecord(
      stageIndex: (map['stageIndex'] as num?)?.toInt() ?? 0,
      stageName: map['stageName'] ?? '',
      assignedRole: map['assignedRole'] ?? '',
      action: map['action'] ?? '',
      actorUid: map['actorUid'] ?? '',
      actorName: map['actorName'] ?? '',
      comment: map['comment'] ?? '',
      timestamp: ts,
    );
  }
}

/// Represents an active or historical Approval Request instance
class ApprovalRequestModel {
  final String id;
  final String somitiId;
  final String workflowId;
  final String moduleKey;
  final String sourceDocumentId;
  final String title;
  final int amountInPoisha;
  final String makerUid;
  final String makerName;
  final int currentStageIndex;
  final String currentStageName;
  final String assignedRole;
  final List<String> assignedUserUids;
  final ApprovalStatus status;
  final List<StageHistoryRecord> stageHistory;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  ApprovalRequestModel({
    required this.id,
    required this.somitiId,
    required this.workflowId,
    required this.moduleKey,
    required this.sourceDocumentId,
    required this.title,
    this.amountInPoisha = 0,
    required this.makerUid,
    required this.makerName,
    this.currentStageIndex = 0,
    this.currentStageName = '',
    required this.assignedRole,
    this.assignedUserUids = const [],
    this.status = ApprovalStatus.pendingReview,
    this.stageHistory = const [],
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });

  double get amountInTaka => amountInPoisha / 100.0;

  Map<String, dynamic> toMap() {
    return {
      'somitiId': somitiId,
      'workflowId': workflowId,
      'moduleKey': moduleKey,
      'sourceDocumentId': sourceDocumentId,
      'title': title,
      'amountInPoisha': amountInPoisha,
      'makerUid': makerUid,
      'makerName': makerName,
      'currentStageIndex': currentStageIndex,
      'currentStageName': currentStageName,
      'assignedRole': assignedRole,
      'assignedUserUids': assignedUserUids,
      'status': status.name,
      'stageHistory': stageHistory.map((h) => h.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  factory ApprovalRequestModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    ApprovalStatus st = ApprovalStatus.pendingReview;
    try {
      st = ApprovalStatus.values.byName(data['status'] ?? 'pendingReview');
    } catch (_) {}

    DateTime created = DateTime.now();
    final tsC = data['createdAt'];
    if (tsC is Timestamp) created = tsC.toDate();

    DateTime updated = DateTime.now();
    final tsU = data['updatedAt'];
    if (tsU is Timestamp) updated = tsU.toDate();

    DateTime? comp;
    final tsComp = data['completedAt'];
    if (tsComp is Timestamp) comp = tsComp.toDate();

    final rawHistory = (data['stageHistory'] as List<dynamic>?) ?? [];
    final histList = rawHistory.map((h) => StageHistoryRecord.fromMap(Map<String, dynamic>.from(h))).toList();

    return ApprovalRequestModel(
      id: doc.id,
      somitiId: data['somitiId'] ?? '',
      workflowId: data['workflowId'] ?? '',
      moduleKey: data['moduleKey'] ?? '',
      sourceDocumentId: data['sourceDocumentId'] ?? '',
      title: data['title'] ?? '',
      amountInPoisha: (data['amountInPoisha'] as num?)?.toInt() ?? 0,
      makerUid: data['makerUid'] ?? '',
      makerName: data['makerName'] ?? '',
      currentStageIndex: (data['currentStageIndex'] as num?)?.toInt() ?? 0,
      currentStageName: data['currentStageName'] ?? '',
      assignedRole: data['assignedRole'] ?? 'manager',
      assignedUserUids: List<String>.from(data['assignedUserUids'] ?? []),
      status: st,
      stageHistory: histList,
      createdAt: created,
      updatedAt: updated,
      completedAt: comp,
    );
  }
}

/// Temporary approval delegation record
class ApprovalDelegationModel {
  final String id;
  final String somitiId;
  final String ownerUid;
  final String delegateUid;
  final String delegateName;
  final String scopeModule;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final String reason;

  ApprovalDelegationModel({
    required this.id,
    required this.somitiId,
    required this.ownerUid,
    required this.delegateUid,
    required this.delegateName,
    this.scopeModule = 'ALL',
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.reason = '',
  });

  bool get isCurrentlyValid {
    final now = DateTime.now();
    return isActive && now.isAfter(startDate) && now.isBefore(endDate);
  }

  Map<String, dynamic> toMap() {
    return {
      'somitiId': somitiId,
      'ownerUid': ownerUid,
      'delegateUid': delegateUid,
      'delegateName': delegateName,
      'scopeModule': scopeModule,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'isActive': isActive,
      'reason': reason,
    };
  }

  factory ApprovalDelegationModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    DateTime sDate = DateTime.now();
    final tsS = data['startDate'];
    if (tsS is Timestamp) sDate = tsS.toDate();

    DateTime eDate = DateTime.now();
    final tsE = data['endDate'];
    if (tsE is Timestamp) eDate = tsE.toDate();

    return ApprovalDelegationModel(
      id: doc.id,
      somitiId: data['somitiId'] ?? '',
      ownerUid: data['ownerUid'] ?? '',
      delegateUid: data['delegateUid'] ?? '',
      delegateName: data['delegateName'] ?? '',
      scopeModule: data['scopeModule'] ?? 'ALL',
      startDate: sDate,
      endDate: eDate,
      isActive: data['isActive'] != false,
      reason: data['reason'] ?? '',
    );
  }
}
