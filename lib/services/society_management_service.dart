// lib/services/society_management_service.dart
// Enterprise Society Operations Service: CRM, KYC, EDMS, HR, Attendance, Payroll, Inventory, Assets, Procurement, Operations

import 'dart:math';
import '../models/society_management_model.dart';

class SocietyManagementService {
  static final SocietyManagementService _instance = SocietyManagementService._internal();
  factory SocietyManagementService() => _instance;
  SocietyManagementService._internal() {
    _initializeDefaults();
  }

  final Map<String, CrmLeadModel> _leads = {};
  final Map<String, KycRecordModel> _kycRecords = {};
  final Map<String, SocietyDocumentModel> _documents = {};
  final Map<String, HrEmployeeModel> _employees = {};
  final Map<String, AttendanceRecordModel> _attendance = {};
  final Map<String, LeaveApplicationModel> _leaves = {};
  final Map<String, PayrollRunModel> _payrolls = {};
  final Map<String, InventoryItemModel> _inventory = {};
  final Map<String, InventoryMovementModel> _movements = {};
  final Map<String, AssetRegisterModel> _assets = {};
  final Map<String, VendorModel> _vendors = {};
  final Map<String, PurchaseRequestModel> _purchases = {};
  final Map<String, OperationsTaskModel> _tasks = {};

  void _initializeDefaults() {
    // Seed Sample CRM Lead
    const lead1 = CrmLeadModel(
      id: 'lead_001',
      societyId: 'swapno_chowa_main',
      fullName: 'মোঃ রফিকুল ইসলাম',
      phone: '01711223344',
      status: CrmLeadStatus.newLead,
      source: 'field_visit',
      notes: 'মাসিক সঞ্চয় ও কৃষি ঋণে আগ্রহী',
      createdAt: null ?? DateTime(2026, 11, 1),
    );
    _leads[lead1.id] = lead1;

    // Seed Sample Inventory Item
    const item1 = InventoryItemModel(
      id: 'inv_passbook_01',
      societyId: 'swapno_chowa_main',
      sku: 'SKU-PB-2026',
      name: 'অফিসিয়াল সঞ্চয় ও ঋণ পাসবুক বই',
      category: 'স্টেশনারি',
      unit: 'বই',
      currentStock: 450,
      reorderLevel: 100,
      unitCostPoisha: 3500, // ৳৩৫.০০
    );
    _inventory[item1.id] = item1;
  }

  // ==========================================
  // 1. CRM & LEADS
  // ==========================================

  CrmLeadModel createLead({
    required String societyId,
    required String fullName,
    required String phone,
    String? email,
    String? address,
    String source = 'inbound',
    String? notes,
    DateTime? followUpDate,
  }) {
    // Duplicate phone check for this society
    final isDuplicate = _leads.values.any((l) => l.societyId == societyId && l.phone == phone && l.status != CrmLeadStatus.closed);
    if (isDuplicate) {
      throw ArgumentError('Lead with phone number $phone already exists in this society.');
    }

    final id = 'lead_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999)}';
    final lead = CrmLeadModel(
      id: id,
      societyId: societyId,
      fullName: fullName,
      phone: phone,
      email: email,
      address: address,
      status: CrmLeadStatus.newLead,
      source: source,
      notes: notes,
      createdAt: DateTime.now(),
      followUpDate: followUpDate,
    );
    _leads[id] = lead;
    return lead;
  }

  CrmLeadModel updateLeadStatus(String leadId, CrmLeadStatus newStatus) {
    final existing = _leads[leadId];
    if (existing == null) throw ArgumentError('Lead not found: $leadId');

    final updated = CrmLeadModel(
      id: existing.id,
      societyId: existing.societyId,
      fullName: existing.fullName,
      phone: existing.phone,
      email: existing.email,
      address: existing.address,
      status: newStatus,
      assignedTo: existing.assignedTo,
      source: existing.source,
      notes: existing.notes,
      createdAt: existing.createdAt,
      followUpDate: existing.followUpDate,
    );
    _leads[leadId] = updated;
    return updated;
  }

  List<CrmLeadModel> getLeadsForSociety(String societyId) {
    return _leads.values.where((l) => l.societyId == societyId).toList();
  }

  // ==========================================
  // 2. KYC & IDENTITY VERIFICATION
  // ==========================================

  KycRecordModel submitKyc({
    required String societyId,
    required String memberId,
    required KycDocType docType,
    required String rawDocNumber,
    String? frontUrl,
    String? backUrl,
  }) {
    // Mask doc number: show only last 4 digits
    final clean = rawDocNumber.trim();
    final masked = clean.length > 4
        ? '*' * (clean.length - 4) + clean.substring(clean.length - 4)
        : clean;

    final id = 'kyc_${memberId}_${DateTime.now().millisecondsSinceEpoch}';
    final record = KycRecordModel(
      id: id,
      memberId: memberId,
      societyId: societyId,
      docType: docType,
      docNumberMasked: masked,
      frontUrl: frontUrl,
      backUrl: backUrl,
      status: KycStatus.submitted,
      submittedAt: DateTime.now(),
    );
    _kycRecords[id] = record;
    return record;
  }

  KycRecordModel verifyKyc({
    required String kycId,
    required bool isApproved,
    required String verifiedBy,
    String? rejectionReason,
  }) {
    final existing = _kycRecords[kycId];
    if (existing == null) throw ArgumentError('KYC record not found: $kycId');

    final updated = KycRecordModel(
      id: existing.id,
      memberId: existing.memberId,
      societyId: existing.societyId,
      docType: existing.docType,
      docNumberMasked: existing.docNumberMasked,
      frontUrl: existing.frontUrl,
      backUrl: existing.backUrl,
      status: isApproved ? KycStatus.approved : KycStatus.rejected,
      rejectionReason: isApproved ? null : (rejectionReason ?? 'তথ্য অস্পষ্ট বা অসম্পূর্ণ'),
      verifiedBy: verifiedBy,
      verifiedAt: DateTime.now(),
      submittedAt: existing.submittedAt,
    );
    _kycRecords[kycId] = updated;
    return updated;
  }

  List<KycRecordModel> getKycRecordsForSociety(String societyId) {
    return _kycRecords.values.where((k) => k.societyId == societyId).toList();
  }

  // ==========================================
  // 3. ENTERPRISE DOCUMENT MANAGEMENT (EDMS)
  // ==========================================

  SocietyDocumentModel uploadDocument({
    required String societyId,
    required DocumentCategory category,
    required String title,
    required String storagePath,
    required int fileSizeBytes,
    required String mimeType,
    required String uploadedBy,
    List<String> tags = const [],
  }) {
    // Enforce 10MB file limit
    if (fileSizeBytes > 10 * 1024 * 1024) {
      throw ArgumentError('File size exceeds 10MB limit: $fileSizeBytes bytes.');
    }

    final id = 'doc_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999)}';
    final doc = SocietyDocumentModel(
      id: id,
      societyId: societyId,
      category: category,
      title: title,
      storagePath: storagePath,
      fileSizeBytes: fileSizeBytes,
      mimeType: mimeType,
      uploadedBy: uploadedBy,
      uploadedAt: DateTime.now(),
      tags: tags,
    );
    _documents[id] = doc;
    return doc;
  }

  List<SocietyDocumentModel> getDocumentsForSociety(String societyId, {DocumentCategory? category}) {
    return _documents.values.where((d) {
      return d.societyId == societyId && !d.isArchived && (category == null || d.category == category);
    }).toList();
  }

  // ==========================================
  // 4. HR, ATTENDANCE & LEAVE
  // ==========================================

  HrEmployeeModel onboardEmployee({
    required String societyId,
    required String employeeCode,
    required String fullName,
    required String phone,
    String? email,
    required String designation,
    required String department,
    required int baseSalaryPoisha,
    String? reportingManagerId,
  }) {
    final id = 'emp_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999)}';
    final emp = HrEmployeeModel(
      id: id,
      societyId: societyId,
      employeeCode: employeeCode,
      fullName: fullName,
      phone: phone,
      email: email,
      designation: designation,
      department: department,
      joiningDate: DateTime.now(),
      baseSalaryPoisha: baseSalaryPoisha,
      reportingManagerId: reportingManagerId,
    );
    _employees[id] = emp;
    return emp;
  }

  AttendanceRecordModel recordAttendance({
    required String societyId,
    required String employeeId,
    required DateTime date,
    required DateTime checkInTime,
    DateTime? checkOutTime,
    String status = 'present',
  }) {
    final id = 'att_${employeeId}_${date.year}${date.month}${date.day}';
    final record = AttendanceRecordModel(
      id: id,
      societyId: societyId,
      employeeId: employeeId,
      date: date,
      checkInTime: checkInTime,
      checkOutTime: checkOutTime,
      status: status,
    );
    _attendance[id] = record;
    return record;
  }

  LeaveApplicationModel applyLeave({
    required String societyId,
    required String employeeId,
    required LeaveType leaveType,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  }) {
    final totalDays = max(1, endDate.difference(startDate).inDays + 1);
    final id = 'leave_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999)}';
    final app = LeaveApplicationModel(
      id: id,
      societyId: societyId,
      employeeId: employeeId,
      leaveType: leaveType,
      startDate: startDate,
      endDate: endDate,
      totalDays: totalDays,
      reason: reason,
      status: 'pending',
    );
    _leaves[id] = app;
    return app;
  }

  LeaveApplicationModel reviewLeave({
    required String leaveId,
    required bool isApproved,
    required String reviewerId,
  }) {
    final existing = _leaves[leaveId];
    if (existing == null) throw ArgumentError('Leave application not found: $leaveId');

    // Self-approval protection
    if (existing.employeeId == reviewerId) {
      throw StateError('Separation of duties violation: An employee cannot approve their own leave.');
    }

    final updated = LeaveApplicationModel(
      id: existing.id,
      societyId: existing.societyId,
      employeeId: existing.employeeId,
      leaveType: existing.leaveType,
      startDate: existing.startDate,
      endDate: existing.endDate,
      totalDays: existing.totalDays,
      reason: existing.reason,
      status: isApproved ? 'approved' : 'rejected',
      approvedBy: reviewerId,
      reviewedAt: DateTime.now(),
    );
    _leaves[leaveId] = updated;
    return updated;
  }

  // ==========================================
  // 5. PAYROLL (INTEGER POISHA PRECISION)
  // ==========================================

  PayrollRunModel calculatePayroll({
    required String societyId,
    required String employeeId,
    required int periodMonth,
    required int year,
    int allowancePoisha = 0,
    int bonusPoisha = 0,
    int deductionsPoisha = 0,
    int taxPoisha = 0,
  }) {
    final emp = _employees[employeeId];
    if (emp == null) throw ArgumentError('Employee not found: $employeeId');

    final basicPoisha = emp.baseSalaryPoisha;
    final grossPoisha = basicPoisha + allowancePoisha + bonusPoisha;
    final totalDeductionsPoisha = deductionsPoisha + taxPoisha;
    final netSalaryPoisha = max(0, grossPoisha - totalDeductionsPoisha);

    final id = 'pay_${employeeId}_${year}_$periodMonth';
    final payroll = PayrollRunModel(
      id: id,
      societyId: societyId,
      periodMonth: periodMonth,
      year: year,
      employeeId: employeeId,
      basicPoisha: basicPoisha,
      allowancePoisha: allowancePoisha,
      bonusPoisha: bonusPoisha,
      deductionsPoisha: deductionsPoisha,
      taxPoisha: taxPoisha,
      netSalaryPoisha: netSalaryPoisha,
      status: 'reviewed',
    );
    _payrolls[id] = payroll;
    return payroll;
  }

  PayrollRunModel disbursePayroll({
    required String payrollId,
    required String voucherId,
  }) {
    final existing = _payrolls[payrollId];
    if (existing == null) throw ArgumentError('Payroll run not found: $payrollId');
    if (existing.status == 'disbursed') {
      throw StateError('Duplicate disbursement error: Payroll $payrollId is already disbursed.');
    }

    final updated = PayrollRunModel(
      id: existing.id,
      societyId: existing.societyId,
      periodMonth: existing.periodMonth,
      year: existing.year,
      employeeId: existing.employeeId,
      basicPoisha: existing.basicPoisha,
      allowancePoisha: existing.allowancePoisha,
      bonusPoisha: existing.bonusPoisha,
      deductionsPoisha: existing.deductionsPoisha,
      taxPoisha: existing.taxPoisha,
      netSalaryPoisha: existing.netSalaryPoisha,
      status: 'disbursed',
      voucherId: voucherId,
      disbursedAt: DateTime.now(),
    );
    _payrolls[payrollId] = updated;
    return updated;
  }

  // ==========================================
  // 6. INVENTORY & STOCK MOVEMENTS
  // ==========================================

  InventoryItemModel registerInventoryItem({
    required String societyId,
    required String sku,
    required String name,
    required String category,
    required String unit,
    required int currentStock,
    required int reorderLevel,
    required int unitCostPoisha,
  }) {
    final id = 'inv_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999)}';
    final item = InventoryItemModel(
      id: id,
      societyId: societyId,
      sku: sku,
      name: name,
      category: category,
      unit: unit,
      currentStock: currentStock,
      reorderLevel: reorderLevel,
      unitCostPoisha: unitCostPoisha,
    );
    _inventory[id] = item;
    return item;
  }

  InventoryMovementModel recordStockMovement({
    required String societyId,
    required String itemId,
    required InventoryMovementType movementType,
    required int quantity,
    required String actorId,
    required String reason,
  }) {
    final item = _inventory[itemId];
    if (item == null) throw ArgumentError('Inventory item not found: $itemId');

    int newBalance = item.currentStock;
    if (movementType == InventoryMovementType.stockReceiving ||
        movementType == InventoryMovementType.stockOpening ||
        movementType == InventoryMovementType.stockReturn) {
      newBalance += quantity;
    } else if (movementType == InventoryMovementType.stockIssue ||
               movementType == InventoryMovementType.stockAdjustment) {
      if (newBalance < quantity) {
        throw StateError('Negative stock violation: Available $newBalance, requested $quantity');
      }
      newBalance -= quantity;
    }

    // Update item stock
    _inventory[itemId] = InventoryItemModel(
      id: item.id,
      societyId: item.societyId,
      sku: item.sku,
      name: item.name,
      category: item.category,
      unit: item.unit,
      currentStock: newBalance,
      reorderLevel: item.reorderLevel,
      unitCostPoisha: item.unitCostPoisha,
    );

    // Record movement
    final movementId = 'mvt_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999)}';
    final movement = InventoryMovementModel(
      id: movementId,
      societyId: societyId,
      itemId: itemId,
      movementType: movementType,
      quantity: quantity,
      balanceAfter: newBalance,
      actorId: actorId,
      reason: reason,
      timestamp: DateTime.now(),
    );
    _movements[movementId] = movement;
    return movement;
  }

  List<InventoryItemModel> getInventoryForSociety(String societyId) {
    return _inventory.values.where((i) => i.societyId == societyId).toList();
  }

  // ==========================================
  // 7. FIXED ASSETS
  // ==========================================

  AssetRegisterModel registerAsset({
    required String societyId,
    required String assetTag,
    required String name,
    required String category,
    required int purchaseCostPoisha,
    String location = 'প্রধান কার্যালয়',
    String? assignedEmployeeId,
  }) {
    final id = 'ast_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999)}';
    final asset = AssetRegisterModel(
      id: id,
      societyId: societyId,
      assetTag: assetTag,
      name: name,
      category: category,
      purchaseDate: DateTime.now(),
      purchaseCostPoisha: purchaseCostPoisha,
      currentValuationPoisha: purchaseCostPoisha,
      location: location,
      assignedEmployeeId: assignedEmployeeId,
      status: AssetStatus.registered,
    );
    _assets[id] = asset;
    return asset;
  }

  List<AssetRegisterModel> getAssetsForSociety(String societyId) {
    return _assets.values.where((a) => a.societyId == societyId).toList();
  }

  // ==========================================
  // 8. PROCUREMENT & VENDORS
  // ==========================================

  VendorModel registerVendor({
    required String societyId,
    required String name,
    required String contactPerson,
    required String phone,
    String? email,
    required String address,
    String? taxId,
  }) {
    final id = 'vnd_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999)}';
    final vendor = VendorModel(
      id: id,
      societyId: societyId,
      name: name,
      contactPerson: contactPerson,
      phone: phone,
      email: email,
      address: address,
      taxId: taxId,
    );
    _vendors[id] = vendor;
    return vendor;
  }

  PurchaseRequestModel createPurchaseRequest({
    required String societyId,
    required String vendorId,
    required String title,
    required String itemsDescription,
    required int quantity,
    required int estimatedCostPoisha,
  }) {
    final id = 'pr_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999)}';
    final req = PurchaseRequestModel(
      id: id,
      societyId: societyId,
      vendorId: vendorId,
      title: title,
      itemsDescription: itemsDescription,
      quantity: quantity,
      estimatedCostPoisha: estimatedCostPoisha,
      status: 'pendingApproval',
    );
    _purchases[id] = req;
    return req;
  }

  // ==========================================
  // 9. INTERNAL OPERATIONS & TASKS
  // ==========================================

  OperationsTaskModel createTask({
    required String societyId,
    required String title,
    required String description,
    required String assignedEmployeeId,
    String priority = 'medium',
    required DateTime dueDate,
  }) {
    final id = 'tsk_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999)}';
    final task = OperationsTaskModel(
      id: id,
      societyId: societyId,
      title: title,
      description: description,
      assignedEmployeeId: assignedEmployeeId,
      priority: priority,
      dueDate: dueDate,
      status: 'open',
      createdAt: DateTime.now(),
    );
    _tasks[id] = task;
    return task;
  }

  OperationsTaskModel completeTask(String taskId) {
    final existing = _tasks[taskId];
    if (existing == null) throw ArgumentError('Task not found: $taskId');

    final updated = OperationsTaskModel(
      id: existing.id,
      societyId: existing.societyId,
      title: existing.title,
      description: existing.description,
      assignedEmployeeId: existing.assignedEmployeeId,
      priority: existing.priority,
      dueDate: existing.dueDate,
      status: 'completed',
      createdAt: existing.createdAt,
    );
    _tasks[taskId] = updated;
    return updated;
  }

  List<OperationsTaskModel> getTasksForSociety(String societyId) {
    return _tasks.values.where((t) => t.societyId == societyId).toList();
  }
}
