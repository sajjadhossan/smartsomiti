// lib/services/cooperative_governance_service.dart
// Phase 19: Enterprise Cooperative Governance, Audit & Regulatory Compliance Service

import '../models/cooperative_governance_model.dart';

class CooperativeGovernanceService {
  static final CooperativeGovernanceService _instance = CooperativeGovernanceService._internal();
  factory CooperativeGovernanceService() => _instance;
  CooperativeGovernanceService._internal() {
    _initSeededData();
  }

  SuperAdminGovernanceMasterConfig _config = const SuperAdminGovernanceMasterConfig();

  final List<GovernanceCommitteeModel> _committees = [];
  final List<GovernanceMeetingModel> _meetings = [];
  final List<GovernanceResolutionModel> _resolutions = [];
  final List<GovernanceElectionModel> _elections = [];
  final List<InternalAuditRecordModel> _audits = [];
  final List<RegulatoryComplianceItemModel> _complianceItems = [];

  void _initSeededData() {
    const sid = 'SOMITI-001';

    // 1. Managing Committee (Board of Directors - 3 Year Statutory Term)
    _committees.add(
      GovernanceCommitteeModel(
        committeeId: 'COM-BOD-2026',
        societyId: sid,
        name: 'কার্যনির্বাহী ব্যবস্থাপনা কমিটি (২০২৬-২০২৯)',
        roleType: CommitteeRoleType.boardOfDirectors,
        description: 'সমবায় সমিতি আইন ২০০১ অনুযায়ী ৩ বছর মেয়াদি নির্বাচিত পরিচালনা পর্ষদ।',
        termYears: 3,
        termStartDate: DateTime(2026, 1, 1),
        termEndDate: DateTime(2029, 1, 1),
        memberDesignations: {
          'MEM-001': 'সভাপতি (President)',
          'MEM-002': 'সহ-সভাপতি (Vice President)',
          'MEM-101': 'সাধারণ সম্পাদক (General Secretary)',
          'MEM-102': 'কোষাধ্যক্ষ (Treasurer)',
          'MEM-103': 'নির্বাহী সদস্য (Executive Member)',
          'MEM-104': 'নির্বাহী সদস্য (Executive Member)',
        },
        isActive: true,
      ),
    );

    // 2. Internal Audit Committee
    _committees.add(
      GovernanceCommitteeModel(
        committeeId: 'COM-AUD-2026',
        societyId: sid,
        name: 'অভ্যন্তরীণ নিরীক্ষা কমিটি (Audit Committee)',
        roleType: CommitteeRoleType.auditCommittee,
        description: 'সাধারণ সভার নিকট দায়বদ্ধ স্বাধীন অভ্যন্তরীণ নিরীক্ষা পর্ষদ।',
        termYears: 3,
        termStartDate: DateTime(2026, 1, 1),
        termEndDate: DateTime(2029, 1, 1),
        memberDesignations: {
          'MEM-105': 'আহ্বায়ক (Convener)',
          'MEM-106': 'সদস্য সচিব (Member Secretary)',
        },
        isActive: true,
      ),
    );

    // 3. AGM & Board Meetings
    _meetings.add(
      GovernanceMeetingModel(
        meetingId: 'MTG-AGM-2026',
        societyId: sid,
        meetingType: GovernanceMeetingType.annualGeneralMeeting,
        title: 'প্রথম বার্ষিক সাধারণ সভা ও বার্ষিক অডিট রিপোর্ট অনুমোদন (AGM)',
        scheduledAt: DateTime(2026, 12, 15, 10, 0),
        venue: 'সমিতির কেন্দ্রীয় কার্যালয়, মিরপুর-১০, ঢাকা',
        isOnline: false,
        attendeeIds: ['MEM-001', 'MEM-002', 'MEM-101', 'MEM-102', 'MEM-103', 'MEM-104'],
        agendaItems: [
          '১. বিগত সাধারণ সভার কার্যবিবরণী নিশ্চিতকরণ',
          '২. পরিচালনা পর্ষদের বার্ষিক কার্যবিবরণী পর্যালোচনা ও গ্রহণ',
          '৩. নিরীক্ষিত ব্যালেন্স শিট ও লাভ-লোকসান হিসাব অনুমোদন',
          '৪. সমবায় আইন অনুযায়ী ১৫% সংবিধিবদ্ধ সংরক্ষিত তহবিল বরাদ্দ',
          '৫. পরবর্তী অর্থবছর ২০২৭-এর প্রস্তাবিত বাজেট অনুমোদন',
        ],
        quorumRequired: 25,
        quorumPresent: 38,
        minutes: 'সভায় উপস্থিতি কোরাম অতিক্রম করায় বৈধভাবে সভা পরিচালিত হয় এবং সর্বসম্মতভাবে সকল প্রস্তাব গৃহীত হয়।',
        status: 'scheduled',
        resolutionIds: ['RES-2026-001', 'RES-2026-002'],
      ),
    );

    // 4. Board Resolutions
    _resolutions.add(
      GovernanceResolutionModel(
        resolutionId: 'RES-2026-001',
        societyId: sid,
        meetingId: 'MTG-AGM-2026',
        resolutionNumber: 'রেজুলেশন নং ০১/২০২৬',
        title: 'ডিজিটাল সেলফ-সার্ভিস মেম্বার সুপার অ্যাপ অনুমোদন ও বাস্তবায়ন',
        description: 'সাধারণ সদস্যদের স্বচ্ছতা নিশ্চিতকরণে ডিজিটাল পাসবুক ও কিউআর মেম্বারশিপ কার্ড অনুমোদন করা হলো।',
        proposedByMemberId: 'MEM-101',
        secondedByMemberId: 'MEM-102',
        votesFor: 38,
        votesAgainst: 0,
        votesAbstain: 0,
        status: 'passed',
        effectiveDate: DateTime(2026, 11, 15),
        responsibleDepartment: 'আইটি ও অপারেশনস বিভাগ',
        actionItems: ['মোবাইল অ্যাপ ডেপ্লয়মেন্ট সম্পন্ন করা', 'সদস্যদের ওরিয়েন্টেশন প্রদান'],
      ),
    );

    _resolutions.add(
      GovernanceResolutionModel(
        resolutionId: 'RES-2026-002',
        societyId: sid,
        meetingId: 'MTG-AGM-2026',
        resolutionNumber: 'রেজুলেশন নং ০২/২০২৬',
        title: 'বাংলাদেশ সমবায় সমিতি আইন ২০০১ ধারা ৩৪ মোতাবেক ১৫% রিজার্ভ ফান্ড নিশ্চিতকরণ',
        description: 'সমিতির নিট উদ্বৃত্ত ১৮,৬৫০ টাকার ১৫% অর্থ সংবিধিবদ্ধ রিজার্ভ ফান্ডে (GL-3001) ট্রান্সফারের সিদ্ধান্ত গৃহীত হলো।',
        proposedByMemberId: 'MEM-102',
        secondedByMemberId: 'MEM-001',
        votesFor: 38,
        votesAgainst: 0,
        votesAbstain: 0,
        status: 'passed',
        effectiveDate: DateTime(2026, 11, 15),
        responsibleDepartment: 'অর্থ ও হিসাব বিভাগ',
        actionItems: ['জেনারেল লেজার জার্নাল ভাউচার পোস্টিং', 'অডিট ফাইলে সংরক্ষণ'],
      ),
    );

    // 5. Internal Audit Records
    _audits.add(
      InternalAuditRecordModel(
        auditId: 'AUD-2026-01',
        societyId: sid,
        title: 'ক্যাশ বুক ও ব্যাংক রিকনসিলিয়েশন ৩য় প্রান্তিক নিরীক্ষা',
        auditScope: 'দৈনন্দিন ক্যাশ লেনদেন, ভাউচার ও ব্যাংক ব্যালেন্স মিলকরণ',
        auditArea: 'Cashbook & Bank',
        plannedDate: DateTime(2026, 10, 1),
        completedDate: DateTime(2026, 10, 5),
        auditorName: 'ডাঃ রফিকুল ইসলাম (আহ্বায়ক, অডিট কমিটি)',
        riskLevel: AuditRiskLevel.low,
        findingsCount: 0,
        findingsSummary: 'ক্যাশ ব্যালেন্স ও ব্যাংক হিসাবে কোনো অসঙ্গতি নেই (Zero Discrepancy)।',
        correctiveActionPlan: 'নিয়মিত দৈনিক ক্যাশ ভেরিফিকেশন বজায় রাখা।',
        status: 'closed',
        verifiedBy: 'মোঃ নজরুল ইসলাম (সভাপতি)',
      ),
    );

    _audits.add(
      InternalAuditRecordModel(
        auditId: 'AUD-2026-02',
        societyId: sid,
        title: 'সদস্য ঋণ বিতরণ ও জামিনদার নথি পূর্ণাঙ্গতা নিরীক্ষা',
        auditScope: 'সকল চলমান ঋণ হিসাবের জামিনদার এনআইডি ও অঙ্গীকারনামা যাচাই',
        auditArea: 'Loans & Securities',
        plannedDate: DateTime(2026, 11, 1),
        completedDate: null,
        auditorName: 'মাহমুদুল হাসান (সদস্য সচিব, অডিট কমিটি)',
        riskLevel: AuditRiskLevel.medium,
        findingsCount: 1,
        findingsSummary: '২টি ঋণ ফাইলে জামিনদারের হালনাগাদ ছবি সংযুক্তি পেন্ডিং রয়েছে।',
        correctiveActionPlan: 'সংশ্লিষ্ট মাঠ কর্মকর্তাকে আগামী ১৫ কার্যদিবসের মধ্যে ছবি সংগ্রহের নির্দেশ।',
        status: 'in_progress',
        verifiedBy: 'মোঃ সাজ্জাদ হোসেন (সাধারণ সম্পাদক)',
      ),
    );

    // 6. Bangladesh Co-operative Societies Act 2001 Regulatory Compliance Items
    _complianceItems.add(
      RegulatoryComplianceItemModel(
        complianceId: 'COMP-01',
        societyId: sid,
        legalReference: 'Co-op Act 2001 Sec 23',
        title: 'বার্ষিক সাধারণ সভা (AGM) অনুষ্ঠান ও অনুমোদন',
        statutoryFrequency: 'বার্ষিক (অর্থবছর সমাপ্তির ৯ মাসের মধ্যে)',
        dueDate: DateTime(2026, 12, 31),
        responsibleOfficer: 'সাধারণ সম্পাদক',
        filingStatus: 'compliant',
        penaltyRisk: 'কমিটি বিলুপ্তির ঝুঁকি / বিশেষ সাধারণ সভার নির্দেশ',
      ),
    );

    _complianceItems.add(
      RegulatoryComplianceItemModel(
        complianceId: 'COMP-02',
        societyId: sid,
        legalReference: 'Co-op Act 2001 Sec 34',
        title: '১৫% সংবিধিবদ্ধ সংরক্ষিত তহবিল (Statutory Reserve Fund) সংরক্ষণ',
        statutoryFrequency: 'বার্ষিক লাভ বণ্টনের পূর্বে',
        dueDate: DateTime(2026, 12, 31),
        responsibleOfficer: 'কোষাধ্যক্ষ',
        filingStatus: 'compliant',
        penaltyRisk: 'লভ্যাংশ বণ্টনে নিষেধাজ্ঞা ও আইনি নোটিশ',
      ),
    );

    _complianceItems.add(
      RegulatoryComplianceItemModel(
        complianceId: 'COMP-03',
        societyId: sid,
        legalReference: 'Co-op Act 2001 Sec 34(2)',
        title: '৩% সমবায় উন্নয়ন তহবিল (CDF) সরকারি ট্রেজারিতে জমাদান',
        statutoryFrequency: 'বার্ষিক অডিটের পর',
        dueDate: DateTime(2026, 12, 31),
        responsibleOfficer: 'কোষাধ্যক্ষ',
        filingStatus: 'compliant',
        penaltyRisk: 'জরিমানা ও সার্টিফিকেট মামলা',
      ),
    );

    _complianceItems.add(
      RegulatoryComplianceItemModel(
        complianceId: 'COMP-04',
        societyId: sid,
        legalReference: 'Co-op Act 2001 Sec 37',
        title: 'জেলা সমবায় অফিসারের নিকট বার্ষিক নিরীক্ষা প্রতিবেদন দাখিল',
        statutoryFrequency: 'বার্ষিক সাধারণ সভার ৩০ দিনের মধ্যে',
        dueDate: DateTime(2027, 1, 30),
        responsibleOfficer: 'সাধারণ সম্পাদক',
        filingStatus: 'compliant',
        penaltyRisk: 'আইনি কারণ দর্শানোর নোটিশ',
      ),
    );
  }

  SuperAdminGovernanceMasterConfig get config => _config;

  void updatePolicy({
    bool? isGovernanceGloballyEnabled,
    bool? isBoardMeetingEnabled,
    bool? isAgmSchedulingEnabled,
    bool? isResolutionRegisterEnabled,
    bool? isElectionModuleEnabled,
    bool? isInternalAuditEnabled,
    bool? isRegulatoryFilingEnabled,
    bool? isComplianceCalendarEnabled,
  }) {
    _config = SuperAdminGovernanceMasterConfig(
      isGovernanceGloballyEnabled: isGovernanceGloballyEnabled ?? _config.isGovernanceGloballyEnabled,
      isBoardMeetingEnabled: isBoardMeetingEnabled ?? _config.isBoardMeetingEnabled,
      isAgmSchedulingEnabled: isAgmSchedulingEnabled ?? _config.isAgmSchedulingEnabled,
      isResolutionRegisterEnabled: isResolutionRegisterEnabled ?? _config.isResolutionRegisterEnabled,
      isElectionModuleEnabled: isElectionModuleEnabled ?? _config.isElectionModuleEnabled,
      isInternalAuditEnabled: isInternalAuditEnabled ?? _config.isInternalAuditEnabled,
      isRegulatoryFilingEnabled: isRegulatoryFilingEnabled ?? _config.isRegulatoryFilingEnabled,
      isComplianceCalendarEnabled: isComplianceCalendarEnabled ?? _config.isComplianceCalendarEnabled,
      isResolutionImmutabilityEnforced: true, // Immutable invariant
      isTenantIsolationEnforced: true, // Immutable invariant
    );
  }

  List<GovernanceCommitteeModel> getCommittees(String societyId) {
    if (!_config.isGovernanceGloballyEnabled) {
      throw StateError('গভর্ন্যান্স মডিউলটি বর্তমানে প্ল্যাটফর্ম এডমিন কর্তৃক স্থগিত রয়েছে।');
    }
    return _committees.where((c) => c.societyId == societyId).toList();
  }

  List<GovernanceMeetingModel> getMeetings(String societyId) {
    if (!_config.isBoardMeetingEnabled) {
      throw StateError('সভা ব্যবস্থাপনা বর্তমানে নিষ্ক্রিয় রয়েছে।');
    }
    return _meetings.where((m) => m.societyId == societyId).toList();
  }

  List<GovernanceResolutionModel> getResolutions(String societyId) {
    if (!_config.isResolutionRegisterEnabled) {
      throw StateError('রেজুলেশন রেজিস্টার বর্তমানে নিষ্ক্রিয় রয়েছে।');
    }
    return _resolutions.where((r) => r.societyId == societyId).toList();
  }

  List<InternalAuditRecordModel> getAudits(String societyId) {
    if (!_config.isInternalAuditEnabled) {
      throw StateError('অভ্যন্তরীণ অডিট মডিউল বর্তমানে নিষ্ক্রিয় রয়েছে।');
    }
    return _audits.where((a) => a.societyId == societyId).toList();
  }

  List<RegulatoryComplianceItemModel> getComplianceItems(String societyId) {
    if (!_config.isRegulatoryFilingEnabled) {
      throw StateError('রেগুলেটরি কমপ্লায়েন্স মডিউল বর্তমানে নিষ্ক্রিয় রয়েছে।');
    }
    return _complianceItems.where((c) => c.societyId == societyId).toList();
  }

  /// Schedule a new Board or General Body Meeting
  GovernanceMeetingModel scheduleMeeting({
    required String societyId,
    required GovernanceMeetingType meetingType,
    required String title,
    required DateTime scheduledAt,
    required String venue,
    required List<String> agendaItems,
    required int quorumRequired,
  }) {
    if (!_config.isBoardMeetingEnabled) {
      throw StateError('সভা শিডিউলিং ফিচারটি বন্ধ রয়েছে।');
    }

    final newMeeting = GovernanceMeetingModel(
      meetingId: 'MTG-${DateTime.now().millisecondsSinceEpoch}',
      societyId: societyId,
      meetingType: meetingType,
      title: title,
      scheduledAt: scheduledAt,
      venue: venue,
      attendeeIds: [],
      agendaItems: agendaItems,
      quorumRequired: quorumRequired,
      quorumPresent: 0,
      status: 'scheduled',
    );

    _meetings.add(newMeeting);
    return newMeeting;
  }

  /// Pass a formal Resolution (Immutable History Preserved)
  GovernanceResolutionModel passResolution({
    required String societyId,
    required String meetingId,
    required String resolutionNumber,
    required String title,
    required String description,
    required String proposedByMemberId,
    required String secondedByMemberId,
    required int votesFor,
    required String responsibleDepartment,
    required List<String> actionItems,
  }) {
    if (!_config.isResolutionRegisterEnabled) {
      throw StateError('রেজুলেশন পাসিং পলিসি নিষ্ক্রিয় রয়েছে।');
    }

    final resolution = GovernanceResolutionModel(
      resolutionId: 'RES-${DateTime.now().millisecondsSinceEpoch}',
      societyId: societyId,
      meetingId: meetingId,
      resolutionNumber: resolutionNumber,
      title: title,
      description: description,
      proposedByMemberId: proposedByMemberId,
      secondedByMemberId: secondedByMemberId,
      votesFor: votesFor,
      status: 'passed',
      effectiveDate: DateTime.now(),
      responsibleDepartment: responsibleDepartment,
      actionItems: actionItems,
    );

    _resolutions.add(resolution);
    return resolution;
  }

  /// Log an Internal Audit Finding
  InternalAuditRecordModel logAuditFinding({
    required String societyId,
    required String title,
    required String auditScope,
    required String auditArea,
    required String auditorName,
    required AuditRiskLevel riskLevel,
    required String findingsSummary,
    required String correctiveActionPlan,
    required String verifiedBy,
  }) {
    if (!_config.isInternalAuditEnabled) {
      throw StateError('অভ্যন্তরীণ অডিট লগিং ফিচার বন্ধ রয়েছে।');
    }

    final audit = InternalAuditRecordModel(
      auditId: 'AUD-${DateTime.now().millisecondsSinceEpoch}',
      societyId: societyId,
      title: title,
      auditScope: auditScope,
      auditArea: auditArea,
      plannedDate: DateTime.now(),
      completedDate: DateTime.now(),
      auditorName: auditorName,
      riskLevel: riskLevel,
      findingsCount: 1,
      findingsSummary: findingsSummary,
      correctiveActionPlan: correctiveActionPlan,
      status: 'open',
      verifiedBy: verifiedBy,
    );

    _audits.add(audit);
    return audit;
  }
}
