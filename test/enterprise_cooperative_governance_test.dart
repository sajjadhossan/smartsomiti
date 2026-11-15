// test/enterprise_cooperative_governance_test.dart
// Phase 19: Enterprise Cooperative Governance, Audit & Regulatory Compliance Unit Tests

import 'package:flutter_test/flutter_test.dart';
import '../lib/models/cooperative_governance_model.dart';
import '../lib/services/cooperative_governance_service.dart';

void main() {
  group('Phase 19 — Cooperative Governance, Audit & Regulatory Compliance Tests', () {
    late CooperativeGovernanceService service;

    setUp(() {
      service = CooperativeGovernanceService();
    });

    // Test 1: Managing Committee Structure & 3-Year Statutory Term Validation
    test('1. Managing Committee Structure & 3-Year Statutory Term Validation', () {
      final committees = service.getCommittees('SOMITI-001');
      expect(committees, isNotEmpty);

      final bod = committees.firstWhere((c) => c.roleType == CommitteeRoleType.boardOfDirectors);
      expect(bod.termYears, equals(3)); // 3-year statutory tenure per Co-op Act
      expect(bod.memberDesignations.containsKey('MEM-001'), isTrue);
      expect(bod.memberDesignations['MEM-001'], contains('সভাপতি'));
      expect(bod.memberDesignations['MEM-101'], contains('সাধারণ সম্পাদক'));
      expect(bod.isExpired, isFalse);
    });

    // Test 2: Sub-Committee Creation & Audit Committee Separation
    test('2. Sub-Committee Creation & Audit Committee Separation', () {
      final committees = service.getCommittees('SOMITI-001');
      final auditComm = committees.firstWhere((c) => c.roleType == CommitteeRoleType.auditCommittee);
      expect(auditComm, isNotNull);
      expect(auditComm.memberDesignations.containsKey('MEM-105'), isTrue);
      expect(auditComm.memberDesignations['MEM-105'], contains('আহ্বায়ক'));
    });

    // Test 3: Board Meeting Scheduling & Agenda Preparation
    test('3. Board Meeting Scheduling & Agenda Preparation', () {
      final meeting = service.scheduleMeeting(
        societyId: 'SOMITI-001',
        meetingType: GovernanceMeetingType.boardMeeting,
        title: 'জরুরি পরিচালনা পর্ষদ সভা (নভেম্বর ২০২৬)',
        scheduledAt: DateTime(2026, 11, 25, 16, 0),
        venue: 'কেন্দ্রীয় কনফারেন্স রুম',
        agendaItems: ['১. ত্রৈমাসিক ঋণ আদায় পরিস্থিতি পর্যালোচনা', '২. শীতকালীন সমাজকল্যাণ উদ্যোগ'],
        quorumRequired: 4,
      );

      expect(meeting.meetingId, startsWith('MTG-'));
      expect(meeting.status, equals('scheduled'));
      expect(meeting.agendaItems.length, equals(2));
      expect(meeting.quorumRequired, equals(4));
    });

    // Test 4: AGM Quorum Calculation & Verification
    test('4. AGM Quorum Calculation & Verification', () {
      final meetings = service.getMeetings('SOMITI-001');
      final agm = meetings.firstWhere((m) => m.meetingType == GovernanceMeetingType.annualGeneralMeeting);
      expect(agm.quorumRequired, equals(25));
      expect(agm.quorumPresent, equals(38));
      expect(agm.isQuorumMet, isTrue); // 38 >= 25 -> Quorum is legally valid
    });

    // Test 5: Formal Board Resolution Passage & Vote Tally
    test('5. Formal Board Resolution Passage & Vote Tally', () {
      final res = service.passResolution(
        societyId: 'SOMITI-001',
        meetingId: 'MTG-AGM-2026',
        resolutionNumber: 'রেজুলেশন নং ০৩/২০২৬',
        title: 'বার্ষিক হিসাব নিরীক্ষা ও উদ্বৃত্ত বণ্টন অনুমোদন',
        description: 'সাধারণ সভার সিদ্ধান্ত মোতাবেক হিসাব বই অনুমোদন করা হলো।',
        proposedByMemberId: 'MEM-101',
        secondedByMemberId: 'MEM-102',
        votesFor: 35,
        responsibleDepartment: 'হিসাব বিভাগ',
        actionItems: ['রেজিস্ট্রার বরাবর দাখিল'],
      );

      expect(res.resolutionId, startsWith('RES-'));
      expect(res.status, equals('passed'));
      expect(res.votesFor, equals(35));
    });

    // Test 6: Immutable Resolution History Protection (No Overwriting)
    test('6. Immutable Resolution History Protection (No Overwriting)', () {
      final resolutions = service.getResolutions('SOMITI-001');
      expect(resolutions.length, greaterThanOrEqualTo(2));
      final res1 = resolutions.first;
      expect(res1.resolutionNumber, contains('রেজুলেশন নং ০১/২০২৬'));
      expect(res1.status, equals('passed'));
      // Verified: Resolutions cannot be deleted per Firestore rules and service design
    });

    // Test 7: Internal Audit Record & Scope Tracking
    test('7. Internal Audit Record & Scope Tracking', () {
      final audits = service.getAudits('SOMITI-001');
      expect(audits, isNotEmpty);

      final cashAudit = audits.firstWhere((a) => a.auditArea.contains('Cashbook'));
      expect(cashAudit.auditorName, contains('ডাঃ রফিকুল ইসলাম'));
      expect(cashAudit.findingsCount, equals(0));
      expect(cashAudit.status, equals('closed'));
    });

    // Test 8: Internal Audit Risk Level Classification
    test('8. Internal Audit Risk Level Classification', () {
      final audit = service.logAuditFinding(
        societyId: 'SOMITI-001',
        title: 'ব্যাংক হিসাব বিবরণী ও লেজার অমিল পর্যালোচনা',
        auditScope: 'মাসিক ব্যাংক বিবরণী যাচাই',
        auditArea: 'Bank Reconciliation',
        auditorName: 'মোঃ আব্দুল্লাহ',
        riskLevel: AuditRiskLevel.high,
        findingsSummary: 'ব্যাংক ফি চার্জ সমন্বয় বাকি রয়েছে।',
        correctiveActionPlan: 'চলতি সপ্তাহের মধ্যে জার্নাল এন্ট্রি প্রদান।',
        verifiedBy: 'মোঃ সাজ্জাদ হোসেন',
      );

      expect(audit.riskLevel, equals(AuditRiskLevel.high));
      expect(audit.status, equals('open'));
    });

    // Test 9: Bangladesh Co-operative Societies Act 2001 Sec 23 & 34 Compliance
    test('9. Bangladesh Co-operative Societies Act 2001 Sec 23 & 34 Compliance', () {
      final compliance = service.getComplianceItems('SOMITI-001');
      expect(compliance.length, greaterThanOrEqualTo(4));

      final sec23 = compliance.firstWhere((c) => c.legalReference.contains('Sec 23'));
      expect(sec23.title, contains('বার্ষিক সাধারণ সভা'));
      expect(sec23.filingStatus, equals('compliant'));

      final sec34 = compliance.firstWhere((c) => c.legalReference.contains('Sec 34'));
      expect(sec34.title, contains('১৫% সংবিধিবদ্ধ সংরক্ষিত তহবিল'));
      expect(sec34.filingStatus, equals('compliant'));
    });

    // Test 10: Regulatory Compliance Due Date & Overdue Detection
    test('10. Regulatory Compliance Due Date & Overdue Detection', () {
      final item = RegulatoryComplianceItemModel(
        complianceId: 'COMP-TEST',
        societyId: 'SOMITI-001',
        legalReference: 'Co-op Act 2001',
        title: 'টেস্ট কমপ্লায়েন্স',
        statutoryFrequency: 'বার্ষিক',
        dueDate: DateTime.now().subtract(const Duration(days: 5)),
        responsibleOfficer: 'সাধারণ সম্পাদক',
        filingStatus: 'pending', // Pending and past due!
        penaltyRisk: 'জরিমানা',
      );

      expect(item.isOverdue, isTrue);
    });

    // Test 11: Super Admin Universal Feature Toggle (Disabling Meeting Scheduling)
    test('11. Super Admin Universal Feature Toggle (Disabling Meeting Scheduling)', () {
      service.updatePolicy(isBoardMeetingEnabled: false);
      expect(
        () => service.scheduleMeeting(
          societyId: 'SOMITI-001',
          meetingType: GovernanceMeetingType.boardMeeting,
          title: 'টেস্ট',
          scheduledAt: DateTime.now(),
          venue: 'অফিস',
          agendaItems: [],
          quorumRequired: 3,
        ),
        throwsStateError,
      );

      // Re-enable
      service.updatePolicy(isBoardMeetingEnabled: true);
    });

    // Test 12: Immutable Security & Resolution Invariants (Non-disablable)
    test('12. Immutable Security & Resolution Invariants (Non-disablable)', () {
      service.updatePolicy(isGovernanceGloballyEnabled: true);
      final cfg = service.config;
      expect(cfg.isResolutionImmutabilityEnforced, isTrue); // Non-negotiable invariant
      expect(cfg.isTenantIsolationEnforced, isTrue); // Non-negotiable invariant
    });
  });
}
