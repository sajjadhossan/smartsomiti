// lib/models/cooperative_governance_model.dart
// Phase 19: Enterprise Cooperative Governance, Audit & Regulatory Compliance Models

import 'package:cloud_firestore/cloud_firestore.dart';

enum CommitteeRoleType {
  boardOfDirectors,
  auditCommittee,
  electionCommittee,
  advisoryCommittee,
  generalBody,
}

enum GovernanceMeetingType {
  boardMeeting,
  committeeMeeting,
  annualGeneralMeeting, // AGM per Section 23
  specialGeneralMeeting, // SGM per Section 24
  emergencyMeeting,
}

enum AuditRiskLevel {
  low,
  medium,
  high,
  critical,
}

/// Committee / Board Structure Model
class GovernanceCommitteeModel {
  final String committeeId;
  final String societyId;
  final String name;
  final CommitteeRoleType roleType;
  final String description;
  final int termYears;
  final DateTime termStartDate;
  final DateTime termEndDate;
  final Map<String, String> memberDesignations; // memberId -> 'সভাপতি', 'সাধারণ সম্পাদক', etc.
  final bool isActive;

  const GovernanceCommitteeModel({
    required this.committeeId,
    required this.societyId,
    required this.name,
    required this.roleType,
    required this.description,
    this.termYears = 3,
    required this.termStartDate,
    required this.termEndDate,
    required this.memberDesignations,
    this.isActive = true,
  });

  bool get isExpired => DateTime.now().isAfter(termEndDate);

  Map<String, dynamic> toMap() {
    return {
      'committeeId': committeeId,
      'societyId': societyId,
      'name': name,
      'roleType': roleType.name,
      'description': description,
      'termYears': termYears,
      'termStartDate': Timestamp.fromDate(termStartDate),
      'termEndDate': Timestamp.fromDate(termEndDate),
      'memberDesignations': memberDesignations,
      'isActive': isActive,
    };
  }

  factory GovernanceCommitteeModel.fromMap(Map<String, dynamic> map, String id) {
    return GovernanceCommitteeModel(
      committeeId: map['committeeId'] ?? id,
      societyId: map['societyId'] ?? '',
      name: map['name'] ?? '',
      roleType: CommitteeRoleType.values.firstWhere(
        (e) => e.name == map['roleType'],
        orElse: () => CommitteeRoleType.boardOfDirectors,
      ),
      description: map['description'] ?? '',
      termYears: map['termYears'] ?? 3,
      termStartDate: (map['termStartDate'] is Timestamp) ? (map['termStartDate'] as Timestamp).toDate() : DateTime.now(),
      termEndDate: (map['termEndDate'] is Timestamp) ? (map['termEndDate'] as Timestamp).toDate() : DateTime.now().add(const Duration(days: 1095)),
      memberDesignations: Map<String, String>.from(map['memberDesignations'] ?? {}),
      isActive: map['isActive'] ?? true,
    );
  }
}

/// Meeting & AGM Model
class GovernanceMeetingModel {
  final String meetingId;
  final String societyId;
  final GovernanceMeetingType meetingType;
  final String title;
  final DateTime scheduledAt;
  final String venue;
  final bool isOnline;
  final String? meetingLink;
  final List<String> attendeeIds;
  final List<String> agendaItems;
  final int quorumRequired;
  final int quorumPresent;
  final String minutes;
  final String status; // 'scheduled', 'completed', 'cancelled'
  final List<String> resolutionIds;

  const GovernanceMeetingModel({
    required this.meetingId,
    required this.societyId,
    required this.meetingType,
    required this.title,
    required this.scheduledAt,
    required this.venue,
    this.isOnline = false,
    this.meetingLink,
    required this.attendeeIds,
    required this.agendaItems,
    required this.quorumRequired,
    required this.quorumPresent,
    this.minutes = '',
    this.status = 'scheduled',
    this.resolutionIds = const [],
  });

  bool get isQuorumMet => quorumPresent >= quorumRequired;

  Map<String, dynamic> toMap() {
    return {
      'meetingId': meetingId,
      'societyId': societyId,
      'meetingType': meetingType.name,
      'title': title,
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'venue': venue,
      'isOnline': isOnline,
      'meetingLink': meetingLink,
      'attendeeIds': attendeeIds,
      'agendaItems': agendaItems,
      'quorumRequired': quorumRequired,
      'quorumPresent': quorumPresent,
      'minutes': minutes,
      'status': status,
      'resolutionIds': resolutionIds,
    };
  }

  factory GovernanceMeetingModel.fromMap(Map<String, dynamic> map, String id) {
    return GovernanceMeetingModel(
      meetingId: map['meetingId'] ?? id,
      societyId: map['societyId'] ?? '',
      meetingType: GovernanceMeetingType.values.firstWhere(
        (e) => e.name == map['meetingType'],
        orElse: () => GovernanceMeetingType.boardMeeting,
      ),
      title: map['title'] ?? '',
      scheduledAt: (map['scheduledAt'] is Timestamp) ? (map['scheduledAt'] as Timestamp).toDate() : DateTime.now(),
      venue: map['venue'] ?? '',
      isOnline: map['isOnline'] ?? false,
      meetingLink: map['meetingLink'],
      attendeeIds: List<String>.from(map['attendeeIds'] ?? []),
      agendaItems: List<String>.from(map['agendaItems'] ?? []),
      quorumRequired: map['quorumRequired'] ?? 1,
      quorumPresent: map['quorumPresent'] ?? 0,
      minutes: map['minutes'] ?? '',
      status: map['status'] ?? 'scheduled',
      resolutionIds: List<String>.from(map['resolutionIds'] ?? []),
    );
  }
}

/// Structured Board & AGM Resolution Model
class GovernanceResolutionModel {
  final String resolutionId;
  final String societyId;
  final String meetingId;
  final String resolutionNumber;
  final String title;
  final String description;
  final String proposedByMemberId;
  final String secondedByMemberId;
  final int votesFor;
  final int votesAgainst;
  final int votesAbstain;
  final String status; // 'passed', 'rejected', 'superseded'
  final DateTime effectiveDate;
  final String responsibleDepartment;
  final List<String> actionItems;
  final String? supersedingResolutionId;

  const GovernanceResolutionModel({
    required this.resolutionId,
    required this.societyId,
    required this.meetingId,
    required this.resolutionNumber,
    required this.title,
    required this.description,
    required this.proposedByMemberId,
    required this.secondedByMemberId,
    required this.votesFor,
    this.votesAgainst = 0,
    this.votesAbstain = 0,
    this.status = 'passed',
    required this.effectiveDate,
    required this.responsibleDepartment,
    required this.actionItems,
    this.supersedingResolutionId,
  });

  Map<String, dynamic> toMap() {
    return {
      'resolutionId': resolutionId,
      'societyId': societyId,
      'meetingId': meetingId,
      'resolutionNumber': resolutionNumber,
      'title': title,
      'description': description,
      'proposedByMemberId': proposedByMemberId,
      'secondedByMemberId': secondedByMemberId,
      'votesFor': votesFor,
      'votesAgainst': votesAgainst,
      'votesAbstain': votesAbstain,
      'status': status,
      'effectiveDate': Timestamp.fromDate(effectiveDate),
      'responsibleDepartment': responsibleDepartment,
      'actionItems': actionItems,
      'supersedingResolutionId': supersedingResolutionId,
    };
  }

  factory GovernanceResolutionModel.fromMap(Map<String, dynamic> map, String id) {
    return GovernanceResolutionModel(
      resolutionId: map['resolutionId'] ?? id,
      societyId: map['societyId'] ?? '',
      meetingId: map['meetingId'] ?? '',
      resolutionNumber: map['resolutionNumber'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      proposedByMemberId: map['proposedByMemberId'] ?? '',
      secondedByMemberId: map['secondedByMemberId'] ?? '',
      votesFor: map['votesFor'] ?? 0,
      votesAgainst: map['votesAgainst'] ?? 0,
      votesAbstain: map['votesAbstain'] ?? 0,
      status: map['status'] ?? 'passed',
      effectiveDate: (map['effectiveDate'] is Timestamp) ? (map['effectiveDate'] as Timestamp).toDate() : DateTime.now(),
      responsibleDepartment: map['responsibleDepartment'] ?? '',
      actionItems: List<String>.from(map['actionItems'] ?? []),
      supersedingResolutionId: map['supersedingResolutionId'],
    );
  }
}

/// Committee Election Management Model
class GovernanceElectionModel {
  final String electionId;
  final String societyId;
  final String title;
  final int termYears;
  final DateTime announcementDate;
  final DateTime nominationDeadline;
  final DateTime votingDate;
  final String electionOfficerName;
  final int eligibleVotersCount;
  final int totalVotesCast;
  final List<Map<String, dynamic>> candidateProfiles;
  final String status; // 'scheduled', 'nominations_open', 'voting', 'completed'
  final bool isCertified;

  const GovernanceElectionModel({
    required this.electionId,
    required this.societyId,
    required this.title,
    this.termYears = 3,
    required this.announcementDate,
    required this.nominationDeadline,
    required this.votingDate,
    required this.electionOfficerName,
    required this.eligibleVotersCount,
    this.totalVotesCast = 0,
    required this.candidateProfiles,
    this.status = 'scheduled',
    this.isCertified = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'electionId': electionId,
      'societyId': societyId,
      'title': title,
      'termYears': termYears,
      'announcementDate': Timestamp.fromDate(announcementDate),
      'nominationDeadline': Timestamp.fromDate(nominationDeadline),
      'votingDate': Timestamp.fromDate(votingDate),
      'electionOfficerName': electionOfficerName,
      'eligibleVotersCount': eligibleVotersCount,
      'totalVotesCast': totalVotesCast,
      'candidateProfiles': candidateProfiles,
      'status': status,
      'isCertified': isCertified,
    };
  }

  factory GovernanceElectionModel.fromMap(Map<String, dynamic> map, String id) {
    return GovernanceElectionModel(
      electionId: map['electionId'] ?? id,
      societyId: map['societyId'] ?? '',
      title: map['title'] ?? '',
      termYears: map['termYears'] ?? 3,
      announcementDate: (map['announcementDate'] is Timestamp) ? (map['announcementDate'] as Timestamp).toDate() : DateTime.now(),
      nominationDeadline: (map['nominationDeadline'] is Timestamp) ? (map['nominationDeadline'] as Timestamp).toDate() : DateTime.now(),
      votingDate: (map['votingDate'] is Timestamp) ? (map['votingDate'] as Timestamp).toDate() : DateTime.now(),
      electionOfficerName: map['electionOfficerName'] ?? '',
      eligibleVotersCount: map['eligibleVotersCount'] ?? 0,
      totalVotesCast: map['totalVotesCast'] ?? 0,
      candidateProfiles: List<Map<String, dynamic>>.from(map['candidateProfiles'] ?? []),
      status: map['status'] ?? 'scheduled',
      isCertified: map['isCertified'] ?? false,
    );
  }
}

/// Internal Audit Record Model
class InternalAuditRecordModel {
  final String auditId;
  final String societyId;
  final String title;
  final String auditScope;
  final String auditArea; // 'Cashbook', 'Savings', 'Loans', 'Bank', 'Statutory Reserve'
  final DateTime plannedDate;
  final DateTime? completedDate;
  final String auditorName;
  final AuditRiskLevel riskLevel;
  final int findingsCount;
  final String findingsSummary;
  final String correctiveActionPlan;
  final String status; // 'open', 'in_progress', 'resolved', 'closed'
  final String verifiedBy;

  const InternalAuditRecordModel({
    required this.auditId,
    required this.societyId,
    required this.title,
    required this.auditScope,
    required this.auditArea,
    required this.plannedDate,
    this.completedDate,
    required this.auditorName,
    required this.riskLevel,
    this.findingsCount = 0,
    required this.findingsSummary,
    required this.correctiveActionPlan,
    this.status = 'open',
    required this.verifiedBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'auditId': auditId,
      'societyId': societyId,
      'title': title,
      'auditScope': auditScope,
      'auditArea': auditArea,
      'plannedDate': Timestamp.fromDate(plannedDate),
      'completedDate': completedDate != null ? Timestamp.fromDate(completedDate!) : null,
      'auditorName': auditorName,
      'riskLevel': riskLevel.name,
      'findingsCount': findingsCount,
      'findingsSummary': findingsSummary,
      'correctiveActionPlan': correctiveActionPlan,
      'status': status,
      'verifiedBy': verifiedBy,
    };
  }

  factory InternalAuditRecordModel.fromMap(Map<String, dynamic> map, String id) {
    return InternalAuditRecordModel(
      auditId: map['auditId'] ?? id,
      societyId: map['societyId'] ?? '',
      title: map['title'] ?? '',
      auditScope: map['auditScope'] ?? '',
      auditArea: map['auditArea'] ?? 'Cashbook',
      plannedDate: (map['plannedDate'] is Timestamp) ? (map['plannedDate'] as Timestamp).toDate() : DateTime.now(),
      completedDate: (map['completedDate'] is Timestamp) ? (map['completedDate'] as Timestamp).toDate() : null,
      auditorName: map['auditorName'] ?? '',
      riskLevel: AuditRiskLevel.values.firstWhere(
        (e) => e.name == map['riskLevel'],
        orElse: () => AuditRiskLevel.low,
      ),
      findingsCount: map['findingsCount'] ?? 0,
      findingsSummary: map['findingsSummary'] ?? '',
      correctiveActionPlan: map['correctiveActionPlan'] ?? '',
      status: map['status'] ?? 'open',
      verifiedBy: map['verifiedBy'] ?? '',
    );
  }
}

/// Bangladesh Co-operative Societies Act 2001 Regulatory Compliance Item Model
class RegulatoryComplianceItemModel {
  final String complianceId;
  final String societyId;
  final String legalReference; // e.g. 'Co-op Act 2001 Sec 23', 'Sec 34'
  final String title;
  final String statutoryFrequency; // 'Annual', 'Monthly', 'Triennial'
  final DateTime dueDate;
  final String responsibleOfficer;
  final String filingStatus; // 'compliant', 'pending', 'overdue'
  final String evidenceDocUrl;
  final String penaltyRisk;

  const RegulatoryComplianceItemModel({
    required this.complianceId,
    required this.societyId,
    required this.legalReference,
    required this.title,
    required this.statutoryFrequency,
    required this.dueDate,
    required this.responsibleOfficer,
    this.filingStatus = 'compliant',
    this.evidenceDocUrl = '',
    required this.penaltyRisk,
  });

  bool get isOverdue => filingStatus != 'compliant' && DateTime.now().isAfter(dueDate);

  Map<String, dynamic> toMap() {
    return {
      'complianceId': complianceId,
      'societyId': societyId,
      'legalReference': legalReference,
      'title': title,
      'statutoryFrequency': statutoryFrequency,
      'dueDate': Timestamp.fromDate(dueDate),
      'responsibleOfficer': responsibleOfficer,
      'filingStatus': filingStatus,
      'evidenceDocUrl': evidenceDocUrl,
      'penaltyRisk': penaltyRisk,
    };
  }

  factory RegulatoryComplianceItemModel.fromMap(Map<String, dynamic> map, String id) {
    return RegulatoryComplianceItemModel(
      complianceId: map['complianceId'] ?? id,
      societyId: map['societyId'] ?? '',
      legalReference: map['legalReference'] ?? '',
      title: map['title'] ?? '',
      statutoryFrequency: map['statutoryFrequency'] ?? 'Annual',
      dueDate: (map['dueDate'] is Timestamp) ? (map['dueDate'] as Timestamp).toDate() : DateTime.now(),
      responsibleOfficer: map['responsibleOfficer'] ?? '',
      filingStatus: map['filingStatus'] ?? 'compliant',
      evidenceDocUrl: map['evidenceDocUrl'] ?? '',
      penaltyRisk: map['penaltyRisk'] ?? '',
    );
  }
}

/// Super Admin Governance & Regulatory Master Config
class SuperAdminGovernanceMasterConfig {
  final bool isGovernanceGloballyEnabled;
  final bool isBoardMeetingEnabled;
  final bool isAgmSchedulingEnabled;
  final bool isResolutionRegisterEnabled;
  final bool isElectionModuleEnabled;
  final bool isInternalAuditEnabled;
  final bool isRegulatoryFilingEnabled;
  final bool isComplianceCalendarEnabled;
  final bool isResolutionImmutabilityEnforced; // INVARIANT: Non-disablable
  final bool isTenantIsolationEnforced; // INVARIANT: Non-disablable

  const SuperAdminGovernanceMasterConfig({
    this.isGovernanceGloballyEnabled = true,
    this.isBoardMeetingEnabled = true,
    this.isAgmSchedulingEnabled = true,
    this.isResolutionRegisterEnabled = true,
    this.isElectionModuleEnabled = true,
    this.isInternalAuditEnabled = true,
    this.isRegulatoryFilingEnabled = true,
    this.isComplianceCalendarEnabled = true,
    this.isResolutionImmutabilityEnforced = true,
    this.isTenantIsolationEnforced = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'isGovernanceGloballyEnabled': isGovernanceGloballyEnabled,
      'isBoardMeetingEnabled': isBoardMeetingEnabled,
      'isAgmSchedulingEnabled': isAgmSchedulingEnabled,
      'isResolutionRegisterEnabled': isResolutionRegisterEnabled,
      'isElectionModuleEnabled': isElectionModuleEnabled,
      'isInternalAuditEnabled': isInternalAuditEnabled,
      'isRegulatoryFilingEnabled': isRegulatoryFilingEnabled,
      'isComplianceCalendarEnabled': isComplianceCalendarEnabled,
      'isResolutionImmutabilityEnforced': isResolutionImmutabilityEnforced,
      'isTenantIsolationEnforced': isTenantIsolationEnforced,
    };
  }
}
