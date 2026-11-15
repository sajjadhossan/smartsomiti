// test/society_management_test.dart
// Enterprise Society Management Ecosystem Tests: CRM, KYC, Documents, HR, Attendance, Payroll, Inventory, Assets, Procurement, Operations

import 'package:test/test.dart';
import '../lib/models/society_management_model.dart';
import '../lib/services/society_management_service.dart';

void main() {
  group('Enterprise Society CRM & Leads Tests', () {
    late SocietyManagementService service;
    const testSocietyId = 'society_test_mirpur_001';

    setUp(() {
      service = SocietyManagementService();
    });

    test('Create CRM Lead and prevent duplicate phone numbers', () {
      final lead = service.createLead(
        societyId: testSocietyId,
        fullName: 'তানভীর আহমেদ',
        phone: '01899112233',
        source: 'referral',
        notes: 'সদস্য হতে ইচ্ছুক',
      );

      expect(lead.fullName, equals('তানভীর আহমেদ'));
      expect(lead.status, equals(CrmLeadStatus.newLead));

      // Attempt duplicate phone creation in same society
      expect(
        () => service.createLead(
          societyId: testSocietyId,
          fullName: 'অন্য নাম',
          phone: '01899112233',
        ),
        throwsArgumentError,
      );
    });

    test('Update Lead status to converted', () {
      final lead = service.createLead(
        societyId: testSocietyId,
        fullName: 'কামরুল হাসান',
        phone: '01911445566',
      );

      final updated = service.updateLeadStatus(lead.id, CrmLeadStatus.converted);
      expect(updated.status, equals(CrmLeadStatus.converted));
      expect(updated.status.labelBn, equals('সদস্যে রূপান্তরিত'));
    });
  });

  group('KYC & Identity Verification Tests', () {
    late SocietyManagementService service;
    const testSocietyId = 'society_test_mirpur_001';

    setUp(() {
      service = SocietyManagementService();
    });

    test('Submit KYC with masked document number and verify', () {
      final kyc = service.submitKyc(
        societyId: testSocietyId,
        memberId: 'mem_101',
        docType: KycDocType.nid,
        rawDocNumber: '19902692512345678',
      );

      expect(kyc.status, equals(KycStatus.submitted));
      // Masked number: shows last 4 digits
      expect(kyc.docNumberMasked.endsWith('5678'), isTrue);
      expect(kyc.docNumberMasked.startsWith('*'), isTrue);

      // Verify approval
      final approved = service.verifyKyc(
        kycId: kyc.id,
        isApproved: true,
        verifiedBy: 'admin_officer_01',
      );

      expect(approved.status, equals(KycStatus.approved));
      expect(approved.verifiedBy, equals('admin_officer_01'));
    });
  });

  group('Enterprise Document Management (EDMS) Tests', () {
    late SocietyManagementService service;
    const testSocietyId = 'society_test_mirpur_001';

    setUp(() {
      service = SocietyManagementService();
    });

    test('Upload document under 10MB limit and reject oversized files', () {
      final doc = service.uploadDocument(
        societyId: testSocietyId,
        category: DocumentCategory.societyLegal,
        title: 'সমিতি উপবিধি ২০২৬',
        storagePath: 'somiti_documents/$testSocietyId/legal/bylaws.pdf',
        fileSizeBytes: 2 * 1024 * 1024, // 2MB
        mimeType: 'application/pdf',
        uploadedBy: 'secretary_01',
      );

      expect(doc.title, equals('সমিতি উপবিধি ২০২৬'));
      expect(doc.category, equals(DocumentCategory.societyLegal));

      // File > 10MB should be rejected
      expect(
        () => service.uploadDocument(
          societyId: testSocietyId,
          category: DocumentCategory.general,
          title: 'Heavy Video.mp4',
          storagePath: 'heavy.mp4',
          fileSizeBytes: 15 * 1024 * 1024, // 15MB
          mimeType: 'video/mp4',
          uploadedBy: 'secretary_01',
        ),
        throwsArgumentError,
      );
    });
  });

  group('HR, Attendance & Leave Tests', () {
    late SocietyManagementService service;
    const testSocietyId = 'society_test_mirpur_001';

    setUp(() {
      service = SocietyManagementService();
    });

    test('Employee onboarding, attendance, and leave application', () {
      final emp = service.onboardEmployee(
        societyId: testSocietyId,
        employeeCode: 'EMP-042',
        fullName: 'মোঃ জাহিদ হাসান',
        phone: '01511223344',
        designation: 'ফিল্ড অফিসার',
        department: 'মাঠ পর্যায় ও ঋণ আদায়',
        baseSalaryPoisha: 2500000, // ৳২৫,০০০.০০
      );

      expect(emp.baseSalaryBdt, equals(25000.0));
      expect(emp.status, equals('active'));

      // Daily attendance
      final att = service.recordAttendance(
        societyId: testSocietyId,
        employeeId: emp.id,
        date: DateTime.now(),
        checkInTime: DateTime.now(),
      );
      expect(att.status, equals('present'));

      // Leave application
      final leave = service.applyLeave(
        societyId: testSocietyId,
        employeeId: emp.id,
        leaveType: LeaveType.casualLeave,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 2)),
        reason: 'পারিবারিক জরুরি কাজ',
      );

      expect(leave.totalDays, equals(3));

      // Self-approval rejection
      expect(
        () => service.reviewLeave(
          leaveId: leave.id,
          isApproved: true,
          reviewerId: emp.id, // Self-approval attempt!
        ),
        throwsStateError,
      );

      // Manager approval
      final approvedLeave = service.reviewLeave(
        leaveId: leave.id,
        isApproved: true,
        reviewerId: 'manager_branch_01',
      );
      expect(approvedLeave.status, equals('approved'));
    });
  });

  group('Payroll Integer Poisha Arithmetic Tests', () {
    late SocietyManagementService service;
    const testSocietyId = 'society_test_mirpur_001';

    setUp(() {
      service = SocietyManagementService();
    });

    test('Payroll calculation and duplicate disbursement protection', () {
      final emp = service.onboardEmployee(
        societyId: testSocietyId,
        employeeCode: 'EMP-099',
        fullName: 'শামীমা আক্তার',
        phone: '01611002233',
        designation: 'হিসাবরক্ষক (Accountant)',
        department: 'হিসাব ও অর্থ',
        baseSalaryPoisha: 3000000, // ৳৩০,০০০.০০
      );

      final payroll = service.calculatePayroll(
        societyId: testSocietyId,
        employeeId: emp.id,
        periodMonth: 11,
        year: 2026,
        allowancePoisha: 500000, // ৳৫,০০০ বাড়ি ভাড়া
        bonusPoisha: 0,
        deductionsPoisha: 150000, // ৳১,৫০০ পিএফ
        taxPoisha: 50000, // ৳৫০০ ট্যাক্স
      );

      // Net = 30,000 + 5,000 - 1,500 - 500 = 33,000 BDT = 3,300,000 Poisha
      expect(payroll.netSalaryPoisha, equals(3300000));
      expect(payroll.netSalaryBdt, equals(33000.0));
      expect(payroll.status, equals('reviewed'));

      // Disburse
      final disbursed = service.disbursePayroll(
        payrollId: payroll.id,
        voucherId: 'JV-PAY-202611-001',
      );
      expect(disbursed.status, equals('disbursed'));

      // Attempt duplicate disbursement
      expect(
        () => service.disbursePayroll(
          payrollId: payroll.id,
          voucherId: 'JV-PAY-202611-001',
        ),
        throwsStateError,
      );
    });
  });

  group('Inventory Management & Concurrency Tests', () {
    late SocietyManagementService service;
    const testSocietyId = 'society_test_mirpur_001';

    setUp(() {
      service = SocietyManagementService();
    });

    test('Stock receiving, issuing, and negative stock restriction', () {
      final item = service.registerInventoryItem(
        societyId: testSocietyId,
        sku: 'SKU-RECEIPT-BOOK',
        name: 'সঞ্চয় মানি রসিদ বই',
        category: 'স্টেশনারি',
        unit: 'বই',
        currentStock: 50,
        reorderLevel: 20,
        unitCostPoisha: 12000, // ৳১২০.০০
      );

      // Inward receiving +30
      final movement1 = service.recordStockMovement(
        societyId: testSocietyId,
        itemId: item.id,
        movementType: InventoryMovementType.stockReceiving,
        quantity: 30,
        actorId: 'admin_01',
        reason: 'নতুন চালান গ্রহণ',
      );
      expect(movement1.balanceAfter, equals(80));

      // Outward issue -25
      final movement2 = service.recordStockMovement(
        societyId: testSocietyId,
        itemId: item.id,
        movementType: InventoryMovementType.stockIssue,
        quantity: 25,
        actorId: 'admin_01',
        reason: 'শাখায় প্রেরণ',
      );
      expect(movement2.balanceAfter, equals(55));

      // Attempt to issue 100 (exceeds 55) -> Throws StateError
      expect(
        () => service.recordStockMovement(
          societyId: testSocietyId,
          itemId: item.id,
          movementType: InventoryMovementType.stockIssue,
          quantity: 100,
          actorId: 'admin_01',
          reason: 'অবৈধ চাহিদা',
        ),
        throwsStateError,
      );
    });
  });

  group('Operations & Tasks Tests', () {
    late SocietyManagementService service;
    const testSocietyId = 'society_test_mirpur_001';

    setUp(() {
      service = SocietyManagementService();
    });

    test('Task creation and completion', () {
      final task = service.createTask(
        societyId: testSocietyId,
        title: 'মাসিক সঞ্চয় অডিট সম্পন্নকরণ',
        description: 'সকল সদস্যের পাসবুক ও লেজার সমন্বয় করতে হবে',
        assignedEmployeeId: 'emp_auditor_01',
        priority: 'urgent',
        dueDate: DateTime.now().add(const Duration(days: 2)),
      );

      expect(task.priority, equals('urgent'));
      expect(task.status, equals('open'));

      final completed = service.completeTask(task.id);
      expect(completed.status, equals('completed'));
    });
  });
}
