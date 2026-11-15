// lib/services/customer_support_helpdesk_service.dart
// Phase 14: Enterprise Customer Support, Helpdesk & Service Management Engine Service

import 'dart:math';
import '../models/customer_support_helpdesk_model.dart';

class CustomerSupportHelpdeskService {
  static final CustomerSupportHelpdeskService _instance = CustomerSupportHelpdeskService._internal();
  factory CustomerSupportHelpdeskService() => _instance;

  CustomerSupportHelpdeskService._internal() {
    _seedInitialData();
  }

  SuperAdminHelpdeskMasterConfig _masterConfig = const SuperAdminHelpdeskMasterConfig();
  final List<SupportDepartmentModel> _departments = [];
  final List<SupportAgentModel> _agents = [];
  final List<SupportTicketModel> _tickets = [];
  final List<SupportTicketMessageModel> _messages = [];
  final List<SlaPolicyModel> _slaPolicies = [];
  final List<GrievanceComplaintModel> _complaints = [];
  final List<KnowledgeArticleModel> _articles = [];
  final List<CustomerFeedbackModel> _feedbacks = [];

  // Getters
  SuperAdminHelpdeskMasterConfig get masterConfig => _masterConfig;
  List<SupportDepartmentModel> get departments => List.unmodifiable(_departments);
  List<SupportAgentModel> get agents => List.unmodifiable(_agents);
  List<SupportTicketModel> get tickets => List.unmodifiable(_tickets);
  List<SupportTicketMessageModel> get messages => List.unmodifiable(_messages);
  List<SlaPolicyModel> get slaPolicies => List.unmodifiable(_slaPolicies);
  List<GrievanceComplaintModel> get complaints => List.unmodifiable(_complaints);
  List<KnowledgeArticleModel> get articles => List.unmodifiable(_articles);
  List<CustomerFeedbackModel> get feedbacks => List.unmodifiable(_feedbacks);

  void _seedInitialData() {
    // 1. Pre-seed Departments
    _departments.addAll([
      const SupportDepartmentModel(
        id: 'DEPT-TECH',
        name: 'Technical Support',
        nameBn: 'কারিগরি ও সিস্টেম সাপোর্ট',
        descriptionBn: 'সফটওয়্যার বাগ, মোবাইল অ্যাপ ত্রুটি, ড্রাইভ ব্যাকআপ ও এপিআই সমস্যা।',
        isActive: true,
        agentCount: 2,
      ),
      const SupportDepartmentModel(
        id: 'DEPT-BILLING',
        name: 'Billing & Commercial',
        nameBn: 'সাবস্ক্রিপশন, বিলিং ও পেমেন্ট গেটওয়ে',
        descriptionBn: 'SaaS ইনভয়েস, বিকাশ/নগদ পেমেন্ট রিকনসিলিয়েশন ও রসিদ সংক্রান্ত।',
        isActive: true,
        agentCount: 2,
      ),
      const SupportDepartmentModel(
        id: 'DEPT-OPS',
        name: 'Cooperative Operations',
        nameBn: 'সমিতি অপারেশনস ও কিস্তি সহায়তা',
        descriptionBn: 'ঋণ অনুমোদন, ডাবল-এন্ট্রি খতিয়ান ও সাধারণ সদস্য পাসবুক সহায়তা।',
        isActive: true,
        agentCount: 2,
      ),
      const SupportDepartmentModel(
        id: 'DEPT-GRIEVANCE',
        name: 'Grievance Redressal Cell',
        nameBn: 'অভিযোগ ও প্রতিকার সেল (গোপনীয়)',
        descriptionBn: 'মাঠ কর্মকর্তা অসদাচরণ, আর্থিক গরমিল ও নির্বাহী কমিটির বিরোধ নিষ্পত্তি।',
        isActive: true,
        agentCount: 1,
      ),
    ]);

    // 2. Pre-seed Support Agents
    _agents.addAll([
      const SupportAgentModel(
        id: 'AGT-01',
        userId: 'agent_sazzad_lead',
        name: 'সাজ্জাদ হোসেন (টেক লিড)',
        email: 'sazzad.lead@somiti.cloud',
        departmentId: 'DEPT-TECH',
        departmentNameBn: 'কারিগরি ও সিস্টেম সাপোর্ট',
        role: 'lead',
        isAvailable: true,
        activeTicketCount: 1,
        maxWorkload: 12,
        ratingAvg: 4.95,
      ),
      const SupportAgentModel(
        id: 'AGT-02',
        userId: 'agent_farhana_billing',
        name: 'ফারহানা আহমেদ',
        email: 'farhana.billing@somiti.cloud',
        departmentId: 'DEPT-BILLING',
        departmentNameBn: 'সাবস্ক্রিপশন, বিলিং ও পেমেন্ট গেটওয়ে',
        role: 'specialist',
        isAvailable: true,
        activeTicketCount: 2,
        maxWorkload: 10,
        ratingAvg: 4.90,
      ),
      const SupportAgentModel(
        id: 'AGT-03',
        userId: 'agent_tanvir_ops',
        name: 'তানভীর আহমেদ',
        email: 'tanvir.ops@somiti.cloud',
        departmentId: 'DEPT-OPS',
        departmentNameBn: 'সমিতি অপারেশনস ও কিস্তি সহায়তা',
        role: 'agent',
        isAvailable: true,
        activeTicketCount: 2,
        maxWorkload: 10,
        ratingAvg: 4.80,
      ),
      const SupportAgentModel(
        id: 'AGT-04',
        userId: 'investigator_rashid',
        name: 'অ্যাডভোকেট আব্দুর রশিদ (তদন্ত কর্মকর্তা)',
        email: 'rashid.grievance@somiti.cloud',
        departmentId: 'DEPT-GRIEVANCE',
        departmentNameBn: 'অভিযোগ ও প্রতিকার সেল (গোপনীয়)',
        role: 'lead',
        isAvailable: true,
        activeTicketCount: 1,
        maxWorkload: 5,
        ratingAvg: 5.0,
      ),
    ]);

    // 3. Pre-seed SLA Policies
    _slaPolicies.addAll([
      const SlaPolicyModel(
        id: 'SLA-CRITICAL',
        priority: TicketPriority.critical,
        nameBn: 'ক্রিটিক্যাল এসএলএ (জরুরি সিস্টেম ব্লকার)',
        firstResponseMinutes: 15,
        resolutionMinutes: 120, // 2 hours
        isBusinessHoursOnly: false, // 24/7
        escalationSupervisorId: 'agent_sazzad_lead',
      ),
      const SlaPolicyModel(
        id: 'SLA-HIGH',
        priority: TicketPriority.high,
        nameBn: 'হাই প্রায়োরিটি এসএলএ (পেমেন্ট ও হিসাব ত্রুটি)',
        firstResponseMinutes: 60, // 1 hour
        resolutionMinutes: 360, // 6 hours
        isBusinessHoursOnly: true,
        escalationSupervisorId: 'agent_farhana_billing',
      ),
      const SlaPolicyModel(
        id: 'SLA-MEDIUM',
        priority: TicketPriority.medium,
        nameBn: 'মিডিয়াম এসএলএ (সাধারণ কনফিগারেশন ও সেটিংস)',
        firstResponseMinutes: 240, // 4 hours
        resolutionMinutes: 1440, // 24 hours
        isBusinessHoursOnly: true,
      ),
      const SlaPolicyModel(
        id: 'SLA-LOW',
        priority: TicketPriority.low,
        nameBn: 'লো এসএলএ (ফিচার আবেদন ও তথ্য অনুসন্ধান)',
        firstResponseMinutes: 480, // 8 hours
        resolutionMinutes: 2880, // 48 hours
        isBusinessHoursOnly: true,
      ),
    ]);

    // 4. Pre-seed Support Tickets
    final now = DateTime.now();
    _tickets.addAll([
      SupportTicketModel(
        id: 'TKT-1401',
        ticketNumber: 'TKT-2026-1401',
        subject: 'বিকাশ পেমেন্ট গেটওয়েতে টাকা কেটে নিলেও ট্রানজেকশন পেন্ডিং দেখাচ্ছে',
        description: 'সদস্য আইডি MEM-0042 এর সঞ্চয় কিস্তি ৳১,৫০০ জমা দেওয়ার সময় বিকাশ ওটিপি সফল হয়েছে, কিন্তু পাসবুকে জমা হয়নি।',
        category: SupportCategory.payment,
        priority: TicketPriority.high,
        severity: TicketSeverity.major,
        status: TicketStatus.inProgress,
        requesterId: 'user_mamun_admin',
        requesterName: 'মোঃ মামুনুর রশীদ (ম্যানেজার)',
        requesterRole: 'society_admin',
        societyId: 'swapno_chowa_main',
        departmentId: 'DEPT-BILLING',
        assignedAgentId: 'AGT-02',
        assignedAgentName: 'ফারহানা আহমেদ',
        createdAt: now.subtract(const Duration(minutes: 45)),
        updatedAt: now.subtract(const Duration(minutes: 10)),
        slaFirstResponseDue: now.add(const Duration(minutes: 15)),
        slaResolutionDue: now.add(const Duration(hours: 5)),
        firstRespondedAt: now.subtract(const Duration(minutes: 25)),
        isSlaBreached: false,
        internalNotesCount: 1,
        messageCount: 3,
        tags: ['bKash', 'PendingPayment', 'Deposit'],
      ),
      SupportTicketModel(
        id: 'TKT-1402',
        ticketNumber: 'TKT-2026-1402',
        subject: 'লোন শিডিউলে রিডিউসিং ব্যালেন্স ক্যালকুলেটরে ১ পয়সা অমিল প্রদর্শন',
        description: '৫০,০০০ টাকার ১২ কিস্তির ঋণে ৩য় কিস্তিতে দশমিক রাউন্ডিংয়ের কারণে ১ পয়সা সামঞ্জস্য প্রয়োজন।',
        category: SupportCategory.technical,
        priority: TicketPriority.medium,
        severity: TicketSeverity.minor,
        status: TicketStatus.resolved,
        requesterId: 'user_tariq_cashier',
        requesterName: 'তারিকুল ইসলাম (ক্যাশিয়ার)',
        requesterRole: 'employee',
        societyId: 'swapno_chowa_main',
        departmentId: 'DEPT-TECH',
        assignedAgentId: 'AGT-01',
        assignedAgentName: 'সাজ্জাদ হোসেন (টেক লিড)',
        createdAt: now.subtract(const Duration(hours: 4)),
        updatedAt: now.subtract(const Duration(minutes: 30)),
        slaFirstResponseDue: now.subtract(const Duration(hours: 3)),
        slaResolutionDue: now.add(const Duration(hours: 20)),
        firstRespondedAt: now.subtract(const Duration(hours: 3, minutes: 40)),
        resolvedAt: now.subtract(const Duration(minutes: 30)),
        isSlaBreached: false,
        satisfactionRating: 5,
        satisfactionFeedback: 'খুব দ্রুত পয়সা রাউন্ডিং অ্যালগরিদম ঠিক করে দিয়েছেন। অসংখ্য ধন্যবাদ!',
        internalNotesCount: 1,
        messageCount: 4,
        tags: ['LoanSchedule', 'PoishaMath', 'Resolved'],
      ),
      SupportTicketModel(
        id: 'TKT-1403',
        ticketNumber: 'TKT-2026-1403',
        subject: 'অফলাইন ফিল্ড মোডে সিঙ্ক করার সময় ডাটা কনফ্লিক্ট দেখা দিচ্ছে',
        description: 'মিরপুর-১০ রুটে ফিল্ড কালেকশনের তিনটি রসিদ ব্যাকগ্রাউন্ড সিঙ্কে পেন্ডিং রয়েছে।',
        category: SupportCategory.technical,
        priority: TicketPriority.high,
        severity: TicketSeverity.major,
        status: TicketStatus.assigned,
        requesterId: 'user_rakib_field',
        requesterName: 'রাকিব হাসান (মাঠ কর্মকর্তা)',
        requesterRole: 'field_officer',
        societyId: 'swapno_chowa_main',
        departmentId: 'DEPT-TECH',
        assignedAgentId: 'AGT-01',
        assignedAgentName: 'সাজ্জাদ হোসেন (টেক লিড)',
        createdAt: now.subtract(const Duration(minutes: 20)),
        updatedAt: now.subtract(const Duration(minutes: 20)),
        slaFirstResponseDue: now.add(const Duration(minutes: 40)),
        slaResolutionDue: now.add(const Duration(hours: 5, minutes: 40)),
        isSlaBreached: false,
        internalNotesCount: 0,
        messageCount: 1,
        tags: ['OfflineSync', 'FieldCollector'],
      ),
    ]);

    // 5. Pre-seed Ticket Messages
    _messages.addAll([
      SupportTicketMessageModel(
        id: 'MSG-01',
        ticketId: 'TKT-1401',
        senderId: 'user_mamun_admin',
        senderName: 'মোঃ মামুনুর রশীদ (ম্যানেজার)',
        senderRole: 'customer',
        message: 'বিকাশ ট্রানজেকশন আইডি: TRX-BK-99214। ব্যাংক থেকে ব্যালেন্স কেটেছে কিন্তু সমিতিতে রিফ্লেক্ট করেনি।',
        isInternalNote: false,
        createdAt: now.subtract(const Duration(minutes: 45)),
        isRead: true,
      ),
      SupportTicketMessageModel(
        id: 'MSG-02',
        ticketId: 'TKT-1401',
        senderId: 'AGT-02',
        senderName: 'ফারহানা আহমেদ',
        senderRole: 'agent',
        message: 'ইন্টারনাল নোট: বিকাশ গেটওয়ে ওয়েবহুক রিসিভ হয়েছে কিন্তু ডাবল-এন্ট্রি জার্নাল ট্রানজেকশন লকে আটকে ছিল। ম্যানুয়াল রি-ভেরিফাই রিকোয়েস্ট ইনিশিয়েট করা হচ্ছে।',
        isInternalNote: true, // Confidential
        createdAt: now.subtract(const Duration(minutes: 30)),
        isRead: true,
      ),
      SupportTicketMessageModel(
        id: 'MSG-03',
        ticketId: 'TKT-1401',
        senderId: 'AGT-02',
        senderName: 'ফারহানা আহমেদ',
        senderRole: 'agent',
        message: 'ধন্যবাদ জনাব মামুনুর রশীদ। বিকাশ সার্ভারের সাথে রিকনসাইল সম্পন্ন হয়েছে। আগামী ১৫ মিনিটের মধ্যে সদস্যের পাসবুকে টাকা ক্রেডিট প্রদর্শিত হবে।',
        isInternalNote: false,
        createdAt: now.subtract(const Duration(minutes: 25)),
        isRead: true,
      ),
    ]);

    // 6. Pre-seed Grievance Complaints
    _complaints.addAll([
      GrievanceComplaintModel(
        id: 'CMP-1401',
        complaintNumber: 'CMP-2026-0501',
        societyId: 'swapno_chowa_main',
        complainantId: null, // Anonymous
        complainantName: 'নাম প্রকাশে অনিচ্ছুক সাধারণ সদস্য',
        isAnonymous: true,
        category: 'মাঠ কর্মকর্তা অসদাচরণ',
        title: 'রসিদ না দিয়ে মৌখিক কিস্তি জমা গ্রহণ',
        description: 'গত মঙ্গলবার মাঠ কর্মকর্তা কিস্তির ৫০০ টাকা নিয়ে ডিজিটাল রসিদ বা এসএমএস দেননি। অনুরোধ সত্ত্বেও কোনো কাগজ দেননি।',
        status: ComplaintStatus.underInvestigation,
        assignedInvestigatorId: 'AGT-04',
        assignedInvestigatorName: 'অ্যাডভোকেট আব্দুর রশিদ',
        investigationNotes: 'সংশ্লিষ্ট মাঠ কর্মকর্তার সংগ্রহ রেজিস্টার ও ক্যাশ বহি নিরীক্ষা করা হচ্ছে।',
        isConfidential: true,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ]);

    // 7. Pre-seed Knowledge Base Articles
    _articles.addAll([
      KnowledgeArticleModel(
        id: 'KB-01',
        titleBn: 'কীভাবে ডিজিটাল মানি রিসিট ও কিউআর কোড যাচাই করবেন?',
        titleEn: 'How to verify digital money receipts and QR codes?',
        contentBn: 'সমিতির প্রতিটি কিস্তি জমা দেওয়ার সাথে সাথে স্বয়ংক্রিয়ভাবে একটি কিউআর কোড সহ মানি রিসিট জেনারেট হয়। মোবাইলের ক্যামেরা দিয়ে স্ক্যান করলেই আসল ভাউচার দেখা যাবে।',
        contentEn: 'Every installment collection generates a verifiable digital money receipt with QR code tamper-proof watermark.',
        category: 'রসিদ ও যাচাইকরণ',
        tags: ['রসিদ', 'কিউআর', 'ভাউচার', 'ভেরিফিকেশন'],
        isPublished: true,
        viewCount: 142,
        helpfulCount: 48,
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      KnowledgeArticleModel(
        id: 'KB-02',
        titleBn: 'অফলাইন মোডে কিস্তি গ্রহণ ও পরবর্তীতে ক্লাউড সিঙ্ক করার নিয়ম',
        titleEn: 'How to collect installments offline and sync to cloud?',
        contentBn: 'নেটওয়ার্ক না থাকলেও ফিল্ড কালেকশন চলবে। লোকাল ডাটাবেজে কিস্তি সংরক্ষিত থাকবে এবং নেটওয়ার্ক পেলেই আইডেমপোটেন্ট কি সহ স্বয়ংক্রিয়ভাবে সিঙ্ক সম্পন্ন হবে।',
        contentEn: 'Field collections can proceed without internet. Transactions are queued locally and synced with idempotency once online.',
        category: 'মাঠ অপারেশন',
        tags: ['অফলাইন', 'সিঙ্ক', 'মাঠ কর্মকর্তা'],
        isPublished: true,
        viewCount: 96,
        helpfulCount: 35,
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
    ]);

    // 8. Pre-seed Customer Feedbacks
    _feedbacks.addAll([
      CustomerFeedbackModel(
        id: 'FB-01',
        ticketId: 'TKT-1402',
        societyId: 'swapno_chowa_main',
        rating: 5,
        agentRating: 5,
        resolutionRating: 5,
        comments: 'অসাধারণ দ্রুত সাপোর্ট পেয়েছি।',
        createdAt: now.subtract(const Duration(minutes: 20)),
      ),
    ]);
  }

  // ============================================================================
  // TICKET CRUD & LIFECYCLE MANAGEMENT
  // ============================================================================

  /// Create a new Support Ticket with SLA calculation and auto-assignment
  SupportTicketModel createTicket({
    required String subject,
    required String description,
    required SupportCategory category,
    required TicketPriority priority,
    required TicketSeverity severity,
    required String requesterId,
    required String requesterName,
    required String requesterRole,
    required String societyId,
    required String departmentId,
    List<String> tags = const [],
  }) {
    if (!_masterConfig.globalHelpdeskEnabled) {
      throw Exception('কাস্টমার সাপোর্ট সিস্টেম প্ল্যাটফর্মে সাময়িকভাবে নিষ্ক্রিয় রয়েছে।');
    }

    final now = DateTime.now();
    final ticketId = 'TKT-${Random().nextInt(9000) + 1000}';
    final ticketNumber = 'TKT-2026-${Random().nextInt(9000) + 1000}';

    // Calculate SLA due dates
    final sla = _slaPolicies.firstWhere(
      (s) => s.priority == priority,
      orElse: () => _slaPolicies.first,
    );
    final firstResponseDue = now.add(Duration(minutes: sla.firstResponseMinutes));
    final resolutionDue = now.add(Duration(minutes: sla.resolutionMinutes));

    // Auto-assignment
    SupportAgentModel? assignedAgent;
    if (_masterConfig.assignmentMethod == AssignmentMethod.workloadBalanced) {
      final deptAgents = _agents.where((a) => a.departmentId == departmentId && a.canAcceptTicket).toList();
      if (deptAgents.isNotEmpty) {
        deptAgents.sort((a, b) => a.activeTicketCount.compareTo(b.activeTicketCount));
        assignedAgent = deptAgents.first;
      }
    } else if (_masterConfig.assignmentMethod == AssignmentMethod.roundRobin) {
      final availableAgents = _agents.where((a) => a.canAcceptTicket).toList();
      if (availableAgents.isNotEmpty) {
        assignedAgent = availableAgents[Random().nextInt(availableAgents.length)];
      }
    }

    final ticket = SupportTicketModel(
      id: ticketId,
      ticketNumber: ticketNumber,
      subject: subject,
      description: description,
      category: category,
      priority: priority,
      severity: severity,
      status: assignedAgent != null ? TicketStatus.assigned : TicketStatus.newTicket,
      requesterId: requesterId,
      requesterName: requesterName,
      requesterRole: requesterRole,
      societyId: societyId,
      departmentId: departmentId,
      assignedAgentId: assignedAgent?.id,
      assignedAgentName: assignedAgent?.name,
      createdAt: now,
      updatedAt: now,
      slaFirstResponseDue: firstResponseDue,
      slaResolutionDue: resolutionDue,
      tags: tags,
    );

    _tickets.insert(0, ticket);

    // Initial message
    _messages.add(SupportTicketMessageModel(
      id: 'MSG-${Random().nextInt(90000)}',
      ticketId: ticketId,
      senderId: requesterId,
      senderName: requesterName,
      senderRole: requesterRole,
      message: description,
      createdAt: now,
    ));

    return ticket;
  }

  /// Assign a ticket to a specific agent
  bool assignTicket(String ticketId, String agentId) {
    final tIdx = _tickets.indexWhere((t) => t.id == ticketId);
    if (tIdx == -1) return false;

    final agent = _agents.firstWhere((a) => a.id == agentId, orElse: () => throw Exception('এজেন্ট পাওয়া যায়নি।'));
    final oldTicket = _tickets[tIdx];

    _tickets[tIdx] = SupportTicketModel(
      id: oldTicket.id,
      ticketNumber: oldTicket.ticketNumber,
      subject: oldTicket.subject,
      description: oldTicket.description,
      category: oldTicket.category,
      priority: oldTicket.priority,
      severity: oldTicket.severity,
      status: TicketStatus.assigned,
      requesterId: oldTicket.requesterId,
      requesterName: oldTicket.requesterName,
      requesterRole: oldTicket.requesterRole,
      societyId: oldTicket.societyId,
      departmentId: agent.departmentId,
      assignedAgentId: agent.id,
      assignedAgentName: agent.name,
      createdAt: oldTicket.createdAt,
      updatedAt: DateTime.now(),
      slaFirstResponseDue: oldTicket.slaFirstResponseDue,
      slaResolutionDue: oldTicket.slaResolutionDue,
      firstRespondedAt: oldTicket.firstRespondedAt,
      resolvedAt: oldTicket.resolvedAt,
      closedAt: oldTicket.closedAt,
      isSlaBreached: oldTicket.isSlaBreached,
      satisfactionRating: oldTicket.satisfactionRating,
      satisfactionFeedback: oldTicket.satisfactionFeedback,
      internalNotesCount: oldTicket.internalNotesCount,
      messageCount: oldTicket.messageCount,
      tags: oldTicket.tags,
    );

    return true;
  }

  /// Add message or internal note to a ticket
  SupportTicketMessageModel addMessage({
    required String ticketId,
    required String senderId,
    required String senderName,
    required String senderRole,
    required String message,
    bool isInternalNote = false,
    List<String> attachmentUrls = const [],
  }) {
    final tIdx = _tickets.indexWhere((t) => t.id == ticketId);
    if (tIdx == -1) throw Exception('টিকেট পাওয়া যায়নি।');

    final oldTicket = _tickets[tIdx];
    final now = DateTime.now();

    final msg = SupportTicketMessageModel(
      id: 'MSG-${Random().nextInt(90000)}',
      ticketId: ticketId,
      senderId: senderId,
      senderName: senderName,
      senderRole: senderRole,
      message: message,
      isInternalNote: isInternalNote,
      attachmentUrls: attachmentUrls,
      createdAt: now,
    );

    _messages.add(msg);

    // If first response by agent/support
    DateTime? firstResponded = oldTicket.firstRespondedAt;
    if (firstResponded == null && (senderRole == 'agent' || senderRole == 'supervisor')) {
      firstResponded = now;
    }

    // Auto-update ticket status if customer replies
    TicketStatus newStatus = oldTicket.status;
    if (senderRole == 'customer' && oldTicket.status == TicketStatus.waitingForCustomer) {
      newStatus = TicketStatus.inProgress;
    }

    _tickets[tIdx] = SupportTicketModel(
      id: oldTicket.id,
      ticketNumber: oldTicket.ticketNumber,
      subject: oldTicket.subject,
      description: oldTicket.description,
      category: oldTicket.category,
      priority: oldTicket.priority,
      severity: oldTicket.severity,
      status: newStatus,
      requesterId: oldTicket.requesterId,
      requesterName: oldTicket.requesterName,
      requesterRole: oldTicket.requesterRole,
      societyId: oldTicket.societyId,
      departmentId: oldTicket.departmentId,
      assignedAgentId: oldTicket.assignedAgentId,
      assignedAgentName: oldTicket.assignedAgentName,
      createdAt: oldTicket.createdAt,
      updatedAt: now,
      slaFirstResponseDue: oldTicket.slaFirstResponseDue,
      slaResolutionDue: oldTicket.slaResolutionDue,
      firstRespondedAt: firstResponded,
      resolvedAt: oldTicket.resolvedAt,
      closedAt: oldTicket.closedAt,
      isSlaBreached: oldTicket.isSlaBreached,
      satisfactionRating: oldTicket.satisfactionRating,
      satisfactionFeedback: oldTicket.satisfactionFeedback,
      internalNotesCount: isInternalNote ? oldTicket.internalNotesCount + 1 : oldTicket.internalNotesCount,
      messageCount: oldTicket.messageCount + 1,
      tags: oldTicket.tags,
    );

    return msg;
  }

  /// Change Ticket Status with lifecycle validation
  bool updateTicketStatus(String ticketId, TicketStatus newStatus) {
    final tIdx = _tickets.indexWhere((t) => t.id == ticketId);
    if (tIdx == -1) return false;

    final oldTicket = _tickets[tIdx];
    final now = DateTime.now();

    DateTime? resolvedAt = oldTicket.resolvedAt;
    DateTime? closedAt = oldTicket.closedAt;

    if (newStatus == TicketStatus.resolved && resolvedAt == null) {
      resolvedAt = now;
    } else if (newStatus == TicketStatus.closed && closedAt == null) {
      closedAt = now;
    } else if (newStatus == TicketStatus.reopened) {
      resolvedAt = null;
      closedAt = null;
    }

    _tickets[tIdx] = SupportTicketModel(
      id: oldTicket.id,
      ticketNumber: oldTicket.ticketNumber,
      subject: oldTicket.subject,
      description: oldTicket.description,
      category: oldTicket.category,
      priority: oldTicket.priority,
      severity: oldTicket.severity,
      status: newStatus,
      requesterId: oldTicket.requesterId,
      requesterName: oldTicket.requesterName,
      requesterRole: oldTicket.requesterRole,
      societyId: oldTicket.societyId,
      departmentId: oldTicket.departmentId,
      assignedAgentId: oldTicket.assignedAgentId,
      assignedAgentName: oldTicket.assignedAgentName,
      createdAt: oldTicket.createdAt,
      updatedAt: now,
      slaFirstResponseDue: oldTicket.slaFirstResponseDue,
      slaResolutionDue: oldTicket.slaResolutionDue,
      firstRespondedAt: oldTicket.firstRespondedAt,
      resolvedAt: resolvedAt,
      closedAt: closedAt,
      isSlaBreached: oldTicket.isSlaBreached,
      satisfactionRating: oldTicket.satisfactionRating,
      satisfactionFeedback: oldTicket.satisfactionFeedback,
      internalNotesCount: oldTicket.internalNotesCount,
      messageCount: oldTicket.messageCount,
      tags: oldTicket.tags,
    );

    return true;
  }

  /// Filter messages for a given user ensuring confidential internal notes are excluded for normal customers
  List<SupportTicketMessageModel> getMessagesForTicket(String ticketId, {required bool isSupportStaff}) {
    return _messages.where((m) {
      if (m.ticketId != ticketId) return false;
      if (m.isInternalNote && !isSupportStaff) return false;
      return true;
    }).toList();
  }

  // ============================================================================
  // GRIEVANCE & COMPLAINT MANAGEMENT
  // ============================================================================

  /// Submit a grievance complaint
  GrievanceComplaintModel submitComplaint({
    required String societyId,
    String? complainantId,
    required String complainantName,
    bool isAnonymous = false,
    required String category,
    required String title,
    required String description,
    List<String> evidenceUrls = const [],
  }) {
    if (!_masterConfig.complaintsEnabled) {
      throw Exception('অভিযোগ ও গ্রিভেন্স সেল বর্তমানে স্থগিত রয়েছে।');
    }

    final complaint = GrievanceComplaintModel(
      id: 'CMP-${Random().nextInt(9000) + 1000}',
      complaintNumber: 'CMP-2026-${Random().nextInt(9000) + 1000}',
      societyId: societyId,
      complainantId: isAnonymous ? null : complainantId,
      complainantName: isAnonymous ? 'বেনামী আবেদনকারী' : complainantName,
      isAnonymous: isAnonymous,
      category: category,
      title: title,
      description: description,
      evidenceUrls: evidenceUrls,
      status: ComplaintStatus.submitted,
      isConfidential: true,
      createdAt: DateTime.now(),
    );

    _complaints.insert(0, complaint);
    return complaint;
  }

  // ============================================================================
  // KNOWLEDGE BASE & SEARCH
  // ============================================================================

  /// Search Knowledge Base articles
  List<KnowledgeArticleModel> searchKnowledgeBase(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return _articles.where((a) => a.isPublished).toList();

    return _articles.where((a) {
      if (!a.isPublished) return false;
      return a.titleBn.toLowerCase().contains(q) ||
             a.titleEn.toLowerCase().contains(q) ||
             a.contentBn.toLowerCase().contains(q) ||
             a.tags.any((t) => t.toLowerCase().contains(q));
    }).toList();
  }

  // ============================================================================
  // CUSTOMER SATISFACTION (CSAT) & FEEDBACK
  // ============================================================================

  /// Submit CSAT feedback
  CustomerFeedbackModel submitFeedback({
    required String ticketId,
    required String societyId,
    required int rating,
    required int agentRating,
    required int resolutionRating,
    String? comments,
  }) {
    final feedback = CustomerFeedbackModel(
      id: 'FB-${Random().nextInt(90000)}',
      ticketId: ticketId,
      societyId: societyId,
      rating: rating.clamp(1, 5),
      agentRating: agentRating.clamp(1, 5),
      resolutionRating: resolutionRating.clamp(1, 5),
      comments: comments,
      createdAt: DateTime.now(),
    );

    _feedbacks.insert(0, feedback);

    // Link to ticket
    final tIdx = _tickets.indexWhere((t) => t.id == ticketId);
    if (tIdx != -1) {
      final oldTicket = _tickets[tIdx];
      _tickets[tIdx] = SupportTicketModel(
        id: oldTicket.id,
        ticketNumber: oldTicket.ticketNumber,
        subject: oldTicket.subject,
        description: oldTicket.description,
        category: oldTicket.category,
        priority: oldTicket.priority,
        severity: oldTicket.severity,
        status: oldTicket.status,
        requesterId: oldTicket.requesterId,
        requesterName: oldTicket.requesterName,
        requesterRole: oldTicket.requesterRole,
        societyId: oldTicket.societyId,
        departmentId: oldTicket.departmentId,
        assignedAgentId: oldTicket.assignedAgentId,
        assignedAgentName: oldTicket.assignedAgentName,
        createdAt: oldTicket.createdAt,
        updatedAt: DateTime.now(),
        slaFirstResponseDue: oldTicket.slaFirstResponseDue,
        slaResolutionDue: oldTicket.slaResolutionDue,
        firstRespondedAt: oldTicket.firstRespondedAt,
        resolvedAt: oldTicket.resolvedAt,
        closedAt: oldTicket.closedAt,
        isSlaBreached: oldTicket.isSlaBreached,
        satisfactionRating: rating,
        satisfactionFeedback: comments,
        internalNotesCount: oldTicket.internalNotesCount,
        messageCount: oldTicket.messageCount,
        tags: oldTicket.tags,
      );
    }

    return feedback;
  }

  /// Calculate CSAT average score
  double getAverageCsatScore() {
    if (_feedbacks.isEmpty) return 5.0;
    final total = _feedbacks.fold<int>(0, (sum, f) => sum + f.rating);
    return total / _feedbacks.length;
  }

  // ============================================================================
  // ANALYTICS & EXECUTIVE REPORTING
  // ============================================================================

  /// Returns real-time helpdesk metrics
  Map<String, dynamic> getHelpdeskAnalyticsSummary() {
    final total = _tickets.length;
    final openCount = _tickets.where((t) => !t.isResolved).length;
    final resolvedCount = _tickets.where((t) => t.isResolved).length;
    final breachedCount = _tickets.where((t) => t.isSlaBreached).length;
    final slaCompliance = total > 0 ? (((total - breachedCount) / total) * 100).toStringAsFixed(1) : '100.0';

    return {
      'totalTickets': total,
      'openTickets': openCount,
      'resolvedTickets': resolvedCount,
      'slaBreachedTickets': breachedCount,
      'slaComplianceRate': '$slaCompliance%',
      'averageCsat': getAverageCsatScore().toStringAsFixed(2),
      'activeAgents': _agents.where((a) => a.isAvailable).length,
      'activeComplaints': _complaints.where((c) => c.status != ComplaintStatus.resolved).length,
    };
  }

  /// Update Super Admin Master Configuration
  void updateMasterConfig(SuperAdminHelpdeskMasterConfig newConfig) {
    _masterConfig = newConfig;
  }
}
