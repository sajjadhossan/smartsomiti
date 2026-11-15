// lib/models/customer_support_helpdesk_model.dart
// Phase 14: Enterprise Customer Support, Helpdesk & Service Management Engine Models

enum TicketPriority {
  critical,
  high,
  medium,
  low;

  String get labelBn {
    switch (this) {
      case TicketPriority.critical: return 'জরুরি (Critical)';
      case TicketPriority.high: return 'উচ্চ (High)';
      case TicketPriority.medium: return 'মাঝারি (Medium)';
      case TicketPriority.low: return 'সাধারণ (Low)';
    }
  }

  String get colorHex {
    switch (this) {
      case TicketPriority.critical: return '#DC2626';
      case TicketPriority.high: return '#EA580C';
      case TicketPriority.medium: return '#D97706';
      case TicketPriority.low: return '#2563EB';
    }
  }
}

enum TicketSeverity {
  blocker,
  major,
  minor,
  trivial;

  String get labelBn {
    switch (this) {
      case TicketSeverity.blocker: return 'সিস্টেম ব্লকার';
      case TicketSeverity.major: return 'গুরুতর সমস্যা';
      case TicketSeverity.minor: return 'ছোটখাটো ত্রুটি';
      case TicketSeverity.trivial: return 'সাধারণ পরমার্শ';
    }
  }
}

enum TicketStatus {
  newTicket,
  open,
  assigned,
  inProgress,
  waitingForCustomer,
  waitingForInternal,
  escalated,
  resolved,
  closed,
  reopened,
  cancelled;

  String get labelBn {
    switch (this) {
      case TicketStatus.newTicket: return 'নতুন';
      case TicketStatus.open: return 'উন্মুক্ত';
      case TicketStatus.assigned: return 'অ্যাসাইনকৃত';
      case TicketStatus.inProgress: return 'চলমান';
      case TicketStatus.waitingForCustomer: return 'গ্রাহকের অপেক্ষায়';
      case TicketStatus.waitingForInternal: return 'অভ্যন্তরীণ তদন্তাধীন';
      case TicketStatus.escalated: return 'এস্কেলেটেড';
      case TicketStatus.resolved: return 'সমাধানকৃত';
      case TicketStatus.closed: return 'বন্ধ';
      case TicketStatus.reopened: return 'পুনরায় খোলা';
      case TicketStatus.cancelled: return 'বাতিলকৃত';
    }
  }

  bool get isClosedOrResolved => this == TicketStatus.resolved || this == TicketStatus.closed || this == TicketStatus.cancelled;
  bool get isWaitingState => this == TicketStatus.waitingForCustomer || this == TicketStatus.waitingForInternal;
}

enum SupportCategory {
  technical,
  billing,
  payment,
  account,
  bugReport,
  featureRequest,
  loanInquiry,
  savingsInquiry,
  complaint,
  general;

  String get labelBn {
    switch (this) {
      case SupportCategory.technical: return 'কারিগরি সহায়তা';
      case SupportCategory.billing: return 'সাবস্ক্রিপশন ও বিলিং';
      case SupportCategory.payment: return 'পেমেন্ট গেটওয়ে ও লেনদেন';
      case SupportCategory.account: return 'অ্যাকাউন্ট ও লগইন';
      case SupportCategory.bugReport: return 'সফটওয়্যার বাগ রিপোর্ট';
      case SupportCategory.featureRequest: return 'নতুন ফিচারের আবেদন';
      case SupportCategory.loanInquiry: return 'ঋণ ও কিস্তি সংক্রান্ত';
      case SupportCategory.savingsInquiry: return 'সঞ্চয় ও এফডিআর সংক্রান্ত';
      case SupportCategory.complaint: return 'আনুষ্ঠানিক অভিযোগ ও গ্রিভেন্স';
      case SupportCategory.general: return 'সাধারণ অনুসন্ধান';
    }
  }
}

enum ComplaintStatus {
  submitted,
  underInvestigation,
  actionTaken,
  resolved,
  dismissed,
  appealed;

  String get labelBn {
    switch (this) {
      case ComplaintStatus.submitted: return 'দাখিলকৃত';
      case ComplaintStatus.underInvestigation: return 'তদন্তাধীন';
      case ComplaintStatus.actionTaken: return 'পদক্ষেপ গৃহীত';
      case ComplaintStatus.resolved: return 'নিষ্পত্তিকৃত';
      case ComplaintStatus.dismissed: return 'খারিজকৃত';
      case ComplaintStatus.appealed: return 'আপিলকৃত';
    }
  }
}

enum AssignmentMethod {
  manual,
  roundRobin,
  workloadBalanced;

  String get labelBn {
    switch (this) {
      case AssignmentMethod.manual: return 'ম্যানুয়াল অ্যাসাইনমেন্ট';
      case AssignmentMethod.roundRobin: return 'রাউন্ড-রবিন ডিস্ট্রিবিউশন';
      case AssignmentMethod.workloadBalanced: return 'ওয়ার্কলোড ব্যালেন্সড অটো-অ্যাসাইন';
    }
  }
}

/// Support Department Model
class SupportDepartmentModel {
  final String id;
  final String name;
  final String nameBn;
  final String descriptionBn;
  final String? headAgentId;
  final bool isActive;
  final int agentCount;

  const SupportDepartmentModel({
    required this.id,
    required this.name,
    required this.nameBn,
    required this.descriptionBn,
    this.headAgentId,
    this.isActive = true,
    this.agentCount = 0,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'nameBn': nameBn,
    'descriptionBn': descriptionBn,
    'headAgentId': headAgentId,
    'isActive': isActive,
    'agentCount': agentCount,
  };

  factory SupportDepartmentModel.fromMap(Map<String, dynamic> map) => SupportDepartmentModel(
    id: map['id'] ?? '',
    name: map['name'] ?? '',
    nameBn: map['nameBn'] ?? '',
    descriptionBn: map['descriptionBn'] ?? '',
    headAgentId: map['headAgentId'],
    isActive: map['isActive'] ?? true,
    agentCount: map['agentCount'] ?? 0,
  );
}

/// Support Agent Model
class SupportAgentModel {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String departmentId;
  final String departmentNameBn;
  final String role; // 'lead', 'specialist', 'agent'
  final bool isAvailable;
  final int activeTicketCount;
  final int maxWorkload;
  final double ratingAvg;

  const SupportAgentModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.departmentId,
    required this.departmentNameBn,
    required this.role,
    this.isAvailable = true,
    this.activeTicketCount = 0,
    this.maxWorkload = 10,
    this.ratingAvg = 5.0,
  });

  bool get canAcceptTicket => isAvailable && activeTicketCount < maxWorkload;

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'name': name,
    'email': email,
    'departmentId': departmentId,
    'departmentNameBn': departmentNameBn,
    'role': role,
    'isAvailable': isAvailable,
    'activeTicketCount': activeTicketCount,
    'maxWorkload': maxWorkload,
    'ratingAvg': ratingAvg,
  };

  factory SupportAgentModel.fromMap(Map<String, dynamic> map) => SupportAgentModel(
    id: map['id'] ?? '',
    userId: map['userId'] ?? '',
    name: map['name'] ?? '',
    email: map['email'] ?? '',
    departmentId: map['departmentId'] ?? '',
    departmentNameBn: map['departmentNameBn'] ?? '',
    role: map['role'] ?? 'agent',
    isAvailable: map['isAvailable'] ?? true,
    activeTicketCount: map['activeTicketCount'] ?? 0,
    maxWorkload: map['maxWorkload'] ?? 10,
    ratingAvg: (map['ratingAvg'] as num?)?.toDouble() ?? 5.0,
  );
}

/// Support Ticket Message / Thread Model
class SupportTicketMessageModel {
  final String id;
  final String ticketId;
  final String senderId;
  final String senderName;
  final String senderRole; // 'customer', 'agent', 'supervisor', 'system'
  final String message;
  final bool isInternalNote; // Strictly confidential, hidden from customer
  final List<String> attachmentUrls;
  final DateTime createdAt;
  final bool isRead;

  const SupportTicketMessageModel({
    required this.id,
    required this.ticketId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.message,
    this.isInternalNote = false,
    this.attachmentUrls = const [],
    required this.createdAt,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'ticketId': ticketId,
    'senderId': senderId,
    'senderName': senderName,
    'senderRole': senderRole,
    'message': message,
    'isInternalNote': isInternalNote,
    'attachmentUrls': attachmentUrls,
    'createdAt': createdAt.toIso8601String(),
    'isRead': isRead,
  };

  factory SupportTicketMessageModel.fromMap(Map<String, dynamic> map) => SupportTicketMessageModel(
    id: map['id'] ?? '',
    ticketId: map['ticketId'] ?? '',
    senderId: map['senderId'] ?? '',
    senderName: map['senderName'] ?? '',
    senderRole: map['senderRole'] ?? 'customer',
    message: map['message'] ?? '',
    isInternalNote: map['isInternalNote'] ?? false,
    attachmentUrls: List<String>.from(map['attachmentUrls'] ?? []),
    createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    isRead: map['isRead'] ?? false,
  );
}

/// Comprehensive Support Ticket Model
class SupportTicketModel {
  final String id;
  final String ticketNumber; // e.g. TKT-2026-1001
  final String subject;
  final String description;
  final SupportCategory category;
  final TicketPriority priority;
  final TicketSeverity severity;
  final TicketStatus status;
  final String requesterId;
  final String requesterName;
  final String requesterRole;
  final String societyId; // empty string for platform-wide tickets
  final String departmentId;
  final String? assignedAgentId;
  final String? assignedAgentName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime slaFirstResponseDue;
  final DateTime slaResolutionDue;
  final DateTime? firstRespondedAt;
  final DateTime? resolvedAt;
  final DateTime? closedAt;
  final bool isSlaBreached;
  final int? satisfactionRating; // 1 to 5
  final String? satisfactionFeedback;
  final int internalNotesCount;
  final int messageCount;
  final List<String> tags;

  const SupportTicketModel({
    required this.id,
    required this.ticketNumber,
    required this.subject,
    required this.description,
    required this.category,
    required this.priority,
    required this.severity,
    required this.status,
    required this.requesterId,
    required this.requesterName,
    required this.requesterRole,
    required this.societyId,
    required this.departmentId,
    this.assignedAgentId,
    this.assignedAgentName,
    required this.createdAt,
    required this.updatedAt,
    required this.slaFirstResponseDue,
    required this.slaResolutionDue,
    this.firstRespondedAt,
    this.resolvedAt,
    this.closedAt,
    this.isSlaBreached = false,
    this.satisfactionRating,
    this.satisfactionFeedback,
    this.internalNotesCount = 0,
    this.messageCount = 1,
    this.tags = const [],
  });

  bool get isCustomerWaiting => status == TicketStatus.waitingForCustomer;
  bool get isResolved => status == TicketStatus.resolved || status == TicketStatus.closed;

  Map<String, dynamic> toMap() => {
    'id': id,
    'ticketNumber': ticketNumber,
    'subject': subject,
    'description': description,
    'category': category.name,
    'priority': priority.name,
    'severity': severity.name,
    'status': status.name,
    'requesterId': requesterId,
    'requesterName': requesterName,
    'requesterRole': requesterRole,
    'societyId': societyId,
    'departmentId': departmentId,
    'assignedAgentId': assignedAgentId,
    'assignedAgentName': assignedAgentName,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'slaFirstResponseDue': slaFirstResponseDue.toIso8601String(),
    'slaResolutionDue': slaResolutionDue.toIso8601String(),
    'firstRespondedAt': firstRespondedAt?.toIso8601String(),
    'resolvedAt': resolvedAt?.toIso8601String(),
    'closedAt': closedAt?.toIso8601String(),
    'isSlaBreached': isSlaBreached,
    'satisfactionRating': satisfactionRating,
    'satisfactionFeedback': satisfactionFeedback,
    'internalNotesCount': internalNotesCount,
    'messageCount': messageCount,
    'tags': tags,
  };

  factory SupportTicketModel.fromMap(Map<String, dynamic> map) => SupportTicketModel(
    id: map['id'] ?? '',
    ticketNumber: map['ticketNumber'] ?? '',
    subject: map['subject'] ?? '',
    description: map['description'] ?? '',
    category: SupportCategory.values.firstWhere((c) => c.name == map['category'], orElse: () => SupportCategory.general),
    priority: TicketPriority.values.firstWhere((p) => p.name == map['priority'], orElse: () => TicketPriority.medium),
    severity: TicketSeverity.values.firstWhere((s) => s.name == map['severity'], orElse: () => TicketSeverity.minor),
    status: TicketStatus.values.firstWhere((st) => st.name == map['status'], orElse: () => TicketStatus.newTicket),
    requesterId: map['requesterId'] ?? '',
    requesterName: map['requesterName'] ?? '',
    requesterRole: map['requesterRole'] ?? 'member',
    societyId: map['societyId'] ?? '',
    departmentId: map['departmentId'] ?? '',
    assignedAgentId: map['assignedAgentId'],
    assignedAgentName: map['assignedAgentName'],
    createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
    slaFirstResponseDue: DateTime.tryParse(map['slaFirstResponseDue'] ?? '') ?? DateTime.now().add(const Duration(hours: 4)),
    slaResolutionDue: DateTime.tryParse(map['slaResolutionDue'] ?? '') ?? DateTime.now().add(const Duration(hours: 24)),
    firstRespondedAt: map['firstRespondedAt'] != null ? DateTime.tryParse(map['firstRespondedAt']) : null,
    resolvedAt: map['resolvedAt'] != null ? DateTime.tryParse(map['resolvedAt']) : null,
    closedAt: map['closedAt'] != null ? DateTime.tryParse(map['closedAt']) : null,
    isSlaBreached: map['isSlaBreached'] ?? false,
    satisfactionRating: map['satisfactionRating'],
    satisfactionFeedback: map['satisfactionFeedback'],
    internalNotesCount: map['internalNotesCount'] ?? 0,
    messageCount: map['messageCount'] ?? 1,
    tags: List<String>.from(map['tags'] ?? []),
  );
}

/// SLA Policy Model
class SlaPolicyModel {
  final String id;
  final TicketPriority priority;
  final String nameBn;
  final int firstResponseMinutes;
  final int resolutionMinutes;
  final bool isBusinessHoursOnly;
  final String? escalationSupervisorId;

  const SlaPolicyModel({
    required this.id,
    required this.priority,
    required this.nameBn,
    required this.firstResponseMinutes,
    required this.resolutionMinutes,
    this.isBusinessHoursOnly = true,
    this.escalationSupervisorId,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'priority': priority.name,
    'nameBn': nameBn,
    'firstResponseMinutes': firstResponseMinutes,
    'resolutionMinutes': resolutionMinutes,
    'isBusinessHoursOnly': isBusinessHoursOnly,
    'escalationSupervisorId': escalationSupervisorId,
  };

  factory SlaPolicyModel.fromMap(Map<String, dynamic> map) => SlaPolicyModel(
    id: map['id'] ?? '',
    priority: TicketPriority.values.firstWhere((p) => p.name == map['priority'], orElse: () => TicketPriority.medium),
    nameBn: map['nameBn'] ?? '',
    firstResponseMinutes: map['firstResponseMinutes'] ?? 240,
    resolutionMinutes: map['resolutionMinutes'] ?? 1440,
    isBusinessHoursOnly: map['isBusinessHoursOnly'] ?? true,
    escalationSupervisorId: map['escalationSupervisorId'],
  );
}

/// Grievance & Complaint Model
class GrievanceComplaintModel {
  final String id;
  final String complaintNumber; // e.g. CMP-2026-0501
  final String societyId;
  final String? complainantId;
  final String complainantName;
  final bool isAnonymous;
  final String category;
  final String title;
  final String description;
  final List<String> evidenceUrls;
  final ComplaintStatus status;
  final String? assignedInvestigatorId;
  final String? assignedInvestigatorName;
  final String? investigationNotes;
  final bool isConfidential;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  const GrievanceComplaintModel({
    required this.id,
    required this.complaintNumber,
    required this.societyId,
    this.complainantId,
    required this.complainantName,
    this.isAnonymous = false,
    required this.category,
    required this.title,
    required this.description,
    this.evidenceUrls = const [],
    this.status = ComplaintStatus.submitted,
    this.assignedInvestigatorId,
    this.assignedInvestigatorName,
    this.investigationNotes,
    this.isConfidential = true,
    required this.createdAt,
    this.resolvedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'complaintNumber': complaintNumber,
    'societyId': societyId,
    'complainantId': complainantId,
    'complainantName': complainantName,
    'isAnonymous': isAnonymous,
    'category': category,
    'title': title,
    'description': description,
    'evidenceUrls': evidenceUrls,
    'status': status.name,
    'assignedInvestigatorId': assignedInvestigatorId,
    'assignedInvestigatorName': assignedInvestigatorName,
    'investigationNotes': investigationNotes,
    'isConfidential': isConfidential,
    'createdAt': createdAt.toIso8601String(),
    'resolvedAt': resolvedAt?.toIso8601String(),
  };

  factory GrievanceComplaintModel.fromMap(Map<String, dynamic> map) => GrievanceComplaintModel(
    id: map['id'] ?? '',
    complaintNumber: map['complaintNumber'] ?? '',
    societyId: map['societyId'] ?? '',
    complainantId: map['complainantId'],
    complainantName: map['complainantName'] ?? 'বেনামী আবেদনকারী',
    isAnonymous: map['isAnonymous'] ?? false,
    category: map['category'] ?? 'সাধারণ',
    title: map['title'] ?? '',
    description: map['description'] ?? '',
    evidenceUrls: List<String>.from(map['evidenceUrls'] ?? []),
    status: ComplaintStatus.values.firstWhere((s) => s.name == map['status'], orElse: () => ComplaintStatus.submitted),
    assignedInvestigatorId: map['assignedInvestigatorId'],
    assignedInvestigatorName: map['assignedInvestigatorName'],
    investigationNotes: map['investigationNotes'],
    isConfidential: map['isConfidential'] ?? true,
    createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    resolvedAt: map['resolvedAt'] != null ? DateTime.tryParse(map['resolvedAt']) : null,
  );
}

/// Knowledge Base Article Model
class KnowledgeArticleModel {
  final String id;
  final String? societyId; // null = platform-wide
  final String titleBn;
  final String titleEn;
  final String contentBn;
  final String contentEn;
  final String category;
  final List<String> tags;
  final bool isPublished;
  final int viewCount;
  final int helpfulCount;
  final int notHelpfulCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const KnowledgeArticleModel({
    required this.id,
    this.societyId,
    required this.titleBn,
    required this.titleEn,
    required this.contentBn,
    required this.contentEn,
    required this.category,
    this.tags = const [],
    this.isPublished = true,
    this.viewCount = 0,
    this.helpfulCount = 0,
    this.notHelpfulCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'societyId': societyId,
    'titleBn': titleBn,
    'titleEn': titleEn,
    'contentBn': contentBn,
    'contentEn': contentEn,
    'category': category,
    'tags': tags,
    'isPublished': isPublished,
    'viewCount': viewCount,
    'helpfulCount': helpfulCount,
    'notHelpfulCount': notHelpfulCount,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory KnowledgeArticleModel.fromMap(Map<String, dynamic> map) => KnowledgeArticleModel(
    id: map['id'] ?? '',
    societyId: map['societyId'],
    titleBn: map['titleBn'] ?? '',
    titleEn: map['titleEn'] ?? '',
    contentBn: map['contentBn'] ?? '',
    contentEn: map['contentEn'] ?? '',
    category: map['category'] ?? 'সাধারণ',
    tags: List<String>.from(map['tags'] ?? []),
    isPublished: map['isPublished'] ?? true,
    viewCount: map['viewCount'] ?? 0,
    helpfulCount: map['helpfulCount'] ?? 0,
    notHelpfulCount: map['notHelpfulCount'] ?? 0,
    createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
  );
}

/// Customer Feedback & CSAT Model
class CustomerFeedbackModel {
  final String id;
  final String ticketId;
  final String societyId;
  final int rating; // 1 to 5
  final int agentRating; // 1 to 5
  final int resolutionRating; // 1 to 5
  final String? comments;
  final DateTime createdAt;

  const CustomerFeedbackModel({
    required this.id,
    required this.ticketId,
    required this.societyId,
    required this.rating,
    required this.agentRating,
    required this.resolutionRating,
    this.comments,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'ticketId': ticketId,
    'societyId': societyId,
    'rating': rating,
    'agentRating': agentRating,
    'resolutionRating': resolutionRating,
    'comments': comments,
    'createdAt': createdAt.toIso8601String(),
  };

  factory CustomerFeedbackModel.fromMap(Map<String, dynamic> map) => CustomerFeedbackModel(
    id: map['id'] ?? '',
    ticketId: map['ticketId'] ?? '',
    societyId: map['societyId'] ?? '',
    rating: map['rating'] ?? 5,
    agentRating: map['agentRating'] ?? 5,
    resolutionRating: map['resolutionRating'] ?? 5,
    comments: map['comments'],
    createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
  );
}

/// Super Admin Universal Helpdesk Master Configuration
class SuperAdminHelpdeskMasterConfig {
  final bool globalHelpdeskEnabled;
  final bool tenantOverridesAllowed;
  final bool liveChatEnabled;
  final bool complaintsEnabled;
  final bool knowledgeBaseEnabled;
  final bool csatRatingEnabled;
  final AssignmentMethod assignmentMethod;
  final bool strictSlaEnforcement;
  final bool anonymousReportingAllowed;
  final bool requireInternalNoteForClosure;

  const SuperAdminHelpdeskMasterConfig({
    this.globalHelpdeskEnabled = true,
    this.tenantOverridesAllowed = true,
    this.liveChatEnabled = true,
    this.complaintsEnabled = true,
    this.knowledgeBaseEnabled = true,
    this.csatRatingEnabled = true,
    this.assignmentMethod = AssignmentMethod.workloadBalanced,
    this.strictSlaEnforcement = true,
    this.anonymousReportingAllowed = true,
    this.requireInternalNoteForClosure = true,
  });

  Map<String, dynamic> toMap() => {
    'globalHelpdeskEnabled': globalHelpdeskEnabled,
    'tenantOverridesAllowed': tenantOverridesAllowed,
    'liveChatEnabled': liveChatEnabled,
    'complaintsEnabled': complaintsEnabled,
    'knowledgeBaseEnabled': knowledgeBaseEnabled,
    'csatRatingEnabled': csatRatingEnabled,
    'assignmentMethod': assignmentMethod.name,
    'strictSlaEnforcement': strictSlaEnforcement,
    'anonymousReportingAllowed': anonymousReportingAllowed,
    'requireInternalNoteForClosure': requireInternalNoteForClosure,
  };

  factory SuperAdminHelpdeskMasterConfig.fromMap(Map<String, dynamic> map) => SuperAdminHelpdeskMasterConfig(
    globalHelpdeskEnabled: map['globalHelpdeskEnabled'] ?? true,
    tenantOverridesAllowed: map['tenantOverridesAllowed'] ?? true,
    liveChatEnabled: map['liveChatEnabled'] ?? true,
    complaintsEnabled: map['complaintsEnabled'] ?? true,
    knowledgeBaseEnabled: map['knowledgeBaseEnabled'] ?? true,
    csatRatingEnabled: map['csatRatingEnabled'] ?? true,
    assignmentMethod: AssignmentMethod.values.firstWhere((a) => a.name == map['assignmentMethod'], orElse: () => AssignmentMethod.workloadBalanced),
    strictSlaEnforcement: map['strictSlaEnforcement'] ?? true,
    anonymousReportingAllowed: map['anonymousReportingAllowed'] ?? true,
    requireInternalNoteForClosure: map['requireInternalNoteForClosure'] ?? true,
  );
}
