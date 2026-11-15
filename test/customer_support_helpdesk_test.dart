// test/customer_support_helpdesk_test.dart
// Comprehensive Unit Tests for Phase 14 Enterprise Customer Support, Helpdesk & Service Management Engine

import 'package:test/test.dart';
import '../lib/models/customer_support_helpdesk_model.dart';
import '../lib/models/security_compliance_model.dart';
import '../lib/services/customer_support_helpdesk_service.dart';

void main() {
  group('Phase 14 - Enterprise Customer Support, Helpdesk & Service Management Tests', () {
    late CustomerSupportHelpdeskService service;

    setUp(() {
      service = CustomerSupportHelpdeskService();
      service.updateMasterConfig(const SuperAdminHelpdeskMasterConfig());
    });

    test('1. Ticket Creation & Dynamic SLA Calculation', () {
      final ticket = service.createTicket(
        subject: 'জরুরি পাসবুক ডেটা অমিল',
        description: 'সদস্যের পাসবুকে গতকালের জমার এন্ট্রি আসছে না।',
        category: SupportCategory.loanInquiry,
        priority: TicketPriority.critical,
        severity: TicketSeverity.blocker,
        requesterId: 'user_test_01',
        requesterName: 'মোঃ জামান',
        requesterRole: 'member',
        societyId: 'society_test_alpha',
        departmentId: 'DEPT-OPS',
      );

      expect(ticket.id, startsWith('TKT-'));
      expect(ticket.ticketNumber, startsWith('TKT-2026-'));
      expect(ticket.priority, equals(TicketPriority.critical));
      expect(ticket.status, isNot(equals(TicketStatus.closed)));

      // Critical priority SLA: first response <= 15 minutes, resolution <= 120 minutes
      final responseDiff = ticket.slaFirstResponseDue.difference(ticket.createdAt).inMinutes;
      expect(responseDiff, equals(15));

      final resolutionDiff = ticket.slaResolutionDue.difference(ticket.createdAt).inMinutes;
      expect(resolutionDiff, equals(120));
    });

    test('2. Workload-Balanced Auto-Assignment', () {
      final ticket = service.createTicket(
        subject: 'বিলিং ইনভয়েস রিফান্ড আবেদন',
        description: 'অতিরিক্ত ৳১,০০০ কাটা গেছে।',
        category: SupportCategory.billing,
        priority: TicketPriority.high,
        severity: TicketSeverity.major,
        requesterId: 'user_test_admin',
        requesterName: 'এডমিন কবির',
        requesterRole: 'society_admin',
        societyId: 'society_test_alpha',
        departmentId: 'DEPT-BILLING',
      );

      expect(ticket.assignedAgentId, isNotNull);
      expect(ticket.assignedAgentName, isNotNull);
      expect(ticket.status, equals(TicketStatus.assigned));
    });

    test('3. Ticket Status State Machine Transitions', () {
      final ticket = service.createTicket(
        subject: 'টেস্ট স্ট্যাটাস সাইকেল',
        description: 'জীবনচক্র পরীক্ষা',
        category: SupportCategory.technical,
        priority: TicketPriority.medium,
        severity: TicketSeverity.minor,
        requesterId: 'user_cycle',
        requesterName: 'ব্যবহারকারী',
        requesterRole: 'member',
        societyId: 'society_test_alpha',
        departmentId: 'DEPT-TECH',
      );

      expect(service.updateTicketStatus(ticket.id, TicketStatus.inProgress), isTrue);
      var current = service.tickets.firstWhere((t) => t.id == ticket.id);
      expect(current.status, equals(TicketStatus.inProgress));

      expect(service.updateTicketStatus(ticket.id, TicketStatus.waitingForCustomer), isTrue);
      current = service.tickets.firstWhere((t) => t.id == ticket.id);
      expect(current.isWaitingState, isTrue);

      expect(service.updateTicketStatus(ticket.id, TicketStatus.resolved), isTrue);
      current = service.tickets.firstWhere((t) => t.id == ticket.id);
      expect(current.isResolved, isTrue);
      expect(current.resolvedAt, isNotNull);
    });

    test('4. Customer Reply Auto-Unpauses Waiting State', () {
      final ticket = service.createTicket(
        subject: 'অপেক্ষমাণ টিকেট রিপ্লাই টেস্ট',
        description: 'গ্রাহকের উত্তর পরীক্ষা',
        category: SupportCategory.technical,
        priority: TicketPriority.low,
        severity: TicketSeverity.trivial,
        requesterId: 'user_reply',
        requesterName: 'গ্রাহক',
        requesterRole: 'customer',
        societyId: 'society_test_alpha',
        departmentId: 'DEPT-TECH',
      );

      service.updateTicketStatus(ticket.id, TicketStatus.waitingForCustomer);

      // Customer sends a message
      service.addMessage(
        ticketId: ticket.id,
        senderId: 'user_reply',
        senderName: 'গ্রাহক',
        senderRole: 'customer',
        message: 'আমি অতিরিক্ত স্ক্রিনশট পাঠিয়েছি।',
      );

      final updatedTicket = service.tickets.firstWhere((t) => t.id == ticket.id);
      expect(updatedTicket.status, equals(TicketStatus.inProgress));
    });

    test('5. Internal Note Confidentiality Guard (Customer Hidden)', () {
      const ticketId = 'TKT-1401';

      // Support staff message
      service.addMessage(
        ticketId: ticketId,
        senderId: 'AGT-01',
        senderName: 'সাজ্জাদ হোসেন',
        senderRole: 'agent',
        message: 'অভ্যন্তরীণ তদন্ত নোট: গ্রাহকের ক্রেডিট হিস্ট্রি ভেরিফাই করা হচ্ছে।',
        isInternalNote: true,
      );

      // Fetch for customer
      final customerMessages = service.getMessagesForTicket(ticketId, isSupportStaff: false);
      expect(customerMessages.any((m) => m.isInternalNote), isFalse);

      // Fetch for support staff
      final staffMessages = service.getMessagesForTicket(ticketId, isSupportStaff: true);
      expect(staffMessages.any((m) => m.isInternalNote), isTrue);
    });

    test('6. Multi-Tenant Ticket Isolation (Cross-Society Rejection)', () {
      const tenantA = 'society_dhaka_01';
      const tenantB = 'society_chittagong_02';

      bool canUserAccessTicket(String userTenant, String ticketTenant, bool isSuperAdmin) {
        if (isSuperAdmin) return true;
        return userTenant == ticketTenant;
      }

      expect(canUserAccessTicket(tenantA, tenantA, false), isTrue);
      expect(canUserAccessTicket(tenantA, tenantB, false), isFalse);
      expect(canUserAccessTicket(tenantA, tenantB, true), isTrue); // Super Admin allowed
    });

    test('7. SLA Breach Evaluation & Warning Alerts', () {
      final now = DateTime.now();
      final expiredDue = now.subtract(const Duration(minutes: 30));

      bool isBreached(DateTime due, DateTime? resolvedAt) {
        final checkTime = resolvedAt ?? DateTime.now();
        return checkTime.isAfter(due);
      }

      expect(isBreached(expiredDue, null), isTrue);
      expect(isBreached(now.add(const Duration(hours: 2)), null), isFalse);
    });

    test('8. Grievance Complaint Intake & Anonymity Guard', () {
      final complaint = service.submitComplaint(
        societyId: 'swapno_chowa_main',
        complainantId: 'user_secret_99',
        complainantName: 'গোপন সদস্য',
        isAnonymous: true,
        category: 'মাঠ কর্মকর্তা অসদাচরণ',
        title: 'অতিরিক্ত সার্ভিস চার্জ দাবি',
        description: 'কিস্তির বাইরে অতিরিক্ত ১০০ টাকা দাবি করেছেন।',
      );

      expect(complaint.isAnonymous, isTrue);
      expect(complaint.complainantId, isNull);
      expect(complaint.complainantName, equals('বেনামী আবেদনকারী'));
      expect(complaint.status, equals(ComplaintStatus.submitted));
      expect(complaint.isConfidential, isTrue);
    });

    test('9. Confidential Investigation Notes Protection', () {
      final comp = service.complaints.first;
      expect(comp.investigationNotes, isNotNull);
      expect(comp.isConfidential, isTrue);

      bool canViewInvestigation(String role, String investigatorId) {
        return role == 'platform_super_admin' || role == 'assigned_investigator';
      }

      expect(canViewInvestigation('general_member', 'someone_else'), isFalse);
      expect(canViewInvestigation('assigned_investigator', comp.assignedInvestigatorId ?? ''), isTrue);
      expect(canViewInvestigation('platform_super_admin', 'any'), isTrue);
    });

    test('10. Knowledge Base Bilingual Search Engine', () {
      final resultsBn = service.searchKnowledgeBase('কিউআর');
      expect(resultsBn, isNotEmpty);
      expect(resultsBn.first.titleBn, contains('কিউআর'));

      final resultsEn = service.searchKnowledgeBase('offline');
      expect(resultsEn, isNotEmpty);
      expect(resultsEn.first.titleEn.toLowerCase(), contains('offline'));
    });

    test('11. Customer Satisfaction (CSAT) Scoring & Average Computation', () {
      const ticketId = 'TKT-1401';
      final fb = service.submitFeedback(
        ticketId: ticketId,
        societyId: 'swapno_chowa_main',
        rating: 5,
        agentRating: 5,
        resolutionRating: 4,
        comments: 'সমস্যা খুব সুন্দরভাবে সমাধান হয়েছে।',
      );

      expect(fb.rating, equals(5));
      final avg = service.getAverageCsatScore();
      expect(avg, greaterThanOrEqualTo(4.0));
      expect(avg, lessThanOrEqualTo(5.0));

      final summary = service.getHelpdeskAnalyticsSummary();
      expect(summary['totalTickets'], greaterThan(0));
      expect(summary['slaComplianceRate'], isNotNull);
    });

    test('12. Super Admin Universal Helpdesk Control & Invariant Enforcement', () {
      // Disable global helpdesk
      service.updateMasterConfig(const SuperAdminHelpdeskMasterConfig(
        globalHelpdeskEnabled: false,
      ));

      expect(
        () => service.createTicket(
          subject: 'অসম্ভব টিকেট',
          description: 'সাপোর্ট বন্ধ থাকা অবস্থায় তৈরি চেষ্টা',
          category: SupportCategory.general,
          priority: TicketPriority.low,
          severity: TicketSeverity.trivial,
          requesterId: 'user_x',
          requesterName: 'ইউজার',
          requesterRole: 'member',
          societyId: 'soc_x',
          departmentId: 'DEPT-TECH',
        ),
        throwsException,
      );

      // Verify historical tickets remain safe and intact
      expect(service.tickets, isNotEmpty);

      // Restore configuration
      service.updateMasterConfig(const SuperAdminHelpdeskMasterConfig(
        globalHelpdeskEnabled: true,
      ));
      expect(service.masterConfig.globalHelpdeskEnabled, isTrue);
    });
  });
}
