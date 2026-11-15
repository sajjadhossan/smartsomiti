// lib/models/society_management_model.dart
// Enterprise Society Operations: CRM, Member Lifecycle, KYC, EDMS, HR, Attendance, Payroll, Inventory, Assets, Procurement, Operations

import 'dart:convert';

// ==========================================
// 1. CRM & RELATIONSHIP MANAGEMENT
// ==========================================

enum CrmLeadStatus {
  newLead,
  contacted,
  interested,
  followupRequired,
  applicationStarted,
  converted,
  rejected,
  closed;

  String get labelBn {
    switch (this) {
      case CrmLeadStatus.newLead: return 'নতুন প্রসপেক্ট';
      case CrmLeadStatus.contacted: return 'যোগাযোগ সম্পন্ন';
      case CrmLeadStatus.interested: return 'আগ্রহী';
      case CrmLeadStatus.followupRequired: return 'ফলো-আপ প্রয়োজন';
      case CrmLeadStatus.applicationStarted: return 'আবেদন শুরু হয়েছে';
      case CrmLeadStatus.converted: return 'সদস্যে রূপান্তরিত';
      case CrmLeadStatus.rejected: return 'অনুপযুক্ত / বাতিল';
      case CrmLeadStatus.closed: return 'বন্ধকৃত';
    }
  }

  static CrmLeadStatus fromString(String val) {
    return CrmLeadStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => CrmLeadStatus.newLead,
    );
  }
}

class CrmLeadModel {
  final String id;
  final String societyId;
  final String fullName;
  final String phone;
  final String? email;
  final String? address;
  final CrmLeadStatus status;
  final String? assignedTo;
  final String source; // inbound, field_visit, referral
  final String? notes;
  final DateTime createdAt;
  final DateTime? followUpDate;

  const CrmLeadModel({
    required this.id,
    required this.societyId,
    required this.fullName,
    required this.phone,
    this.email,
    this.address,
    required this.status,
    this.assignedTo,
    this.source = 'inbound',
    this.notes,
    required this.createdAt,
    this.followUpDate,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'societyId': societyId,
    'fullName': fullName,
    'phone': phone,
    'email': email,
    'address': address,
    'status': status.name,
    'assignedTo': assignedTo,
    'source': source,
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
    'followUpDate': followUpDate?.toIso8601String(),
  };

  factory CrmLeadModel.fromMap(Map<String, dynamic> map, String id) {
    return CrmLeadModel(
      id: id,
      societyId: map['societyId'] as String? ?? '',
      fullName: map['fullName'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      email: map['email'] as String?,
      address: map['address'] as String?,
      status: CrmLeadStatus.fromString(map['status'] as String? ?? 'newLead'),
      assignedTo: map['assignedTo'] as String?,
      source: map['source'] as String? ?? 'inbound',
      notes: map['notes'] as String?,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
      followUpDate: map['followUpDate'] != null ? DateTime.tryParse(map['followUpDate'] as String) : null,
    );
  }
}

// ==========================================
// 2. MEMBER LIFECYCLE
// ==========================================

enum MemberLifecycleStatus {
  prospect,
  applicationSubmitted,
  underReview,
  approved,
  active,
  suspended,
  inactive,
  resigned,
  archived;

  String get labelBn {
    switch (this) {
      case MemberLifecycleStatus.prospect: return 'প্রসপেক্ট';
      case MemberLifecycleStatus.applicationSubmitted: return 'আবেদন দাখিল';
      case MemberLifecycleStatus.underReview: return 'পর্যালোচনাধীন';
      case MemberLifecycleStatus.approved: return 'অনুমোদিত';
      case MemberLifecycleStatus.active: return 'সক্রিয় সদস্য';
      case MemberLifecycleStatus.suspended: return 'স্থগিত';
      case MemberLifecycleStatus.inactive: return 'নিষ্ক্রিয়';
      case MemberLifecycleStatus.resigned: return 'সদস্যপদ প্রত্যাহার';
      case MemberLifecycleStatus.archived: return 'আর্কাইভকৃত';
    }
  }

  static MemberLifecycleStatus fromString(String val) {
    return MemberLifecycleStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => MemberLifecycleStatus.active,
    );
  }
}

class MemberLifecycleEventModel {
  final String id;
  final String memberId;
  final String societyId;
  final MemberLifecycleStatus fromStatus;
  final MemberLifecycleStatus toStatus;
  final String reason;
  final String authorizedBy;
  final DateTime timestamp;

  const MemberLifecycleEventModel({
    required this.id,
    required this.memberId,
    required this.societyId,
    required this.fromStatus,
    required this.toStatus,
    required this.reason,
    required this.authorizedBy,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'memberId': memberId,
    'societyId': societyId,
    'fromStatus': fromStatus.name,
    'toStatus': toStatus.name,
    'reason': reason,
    'authorizedBy': authorizedBy,
    'timestamp': timestamp.toIso8601String(),
  };

  factory MemberLifecycleEventModel.fromMap(Map<String, dynamic> map, String id) {
    return MemberLifecycleEventModel(
      id: id,
      memberId: map['memberId'] as String? ?? '',
      societyId: map['societyId'] as String? ?? '',
      fromStatus: MemberLifecycleStatus.fromString(map['fromStatus'] as String? ?? 'active'),
      toStatus: MemberLifecycleStatus.fromString(map['toStatus'] as String? ?? 'active'),
      reason: map['reason'] as String? ?? '',
      authorizedBy: map['authorizedBy'] as String? ?? '',
      timestamp: DateTime.tryParse(map['timestamp'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

// ==========================================
// 3. KYC & IDENTITY VERIFICATION
// ==========================================

enum KycDocType {
  nid,
  passport,
  birthCertificate,
  tradeLicense;

  String get labelBn {
    switch (this) {
      case KycDocType.nid: return 'জাতীয় পরিচয়পত্র (NID)';
      case KycDocType.passport: return 'আন্তর্জাতিক পাসপোর্ট';
      case KycDocType.birthCertificate: return 'ডিজিটাল জন্ম নিবন্ধন';
      case KycDocType.tradeLicense: return 'ট্রেড লাইসেন্স';
    }
  }

  static KycDocType fromString(String val) {
    return KycDocType.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => KycDocType.nid,
    );
  }
}

enum KycStatus {
  notSubmitted,
  submitted,
  underReview,
  approved,
  rejected,
  resubmitted,
  expired;

  String get labelBn {
    switch (this) {
      case KycStatus.notSubmitted: return 'জমা দেওয়া হয়নি';
      case KycStatus.submitted: return 'দাখিলকৃত';
      case KycStatus.underReview: return 'যাচাই চলছে';
      case KycStatus.approved: return 'ভেরিফাইড ও অনুমোদিত';
      case KycStatus.rejected: return 'বাতিলকৃত';
      case KycStatus.resubmitted: return 'পুনরায় দাখিলকৃত';
      case KycStatus.expired: return 'মেয়াদোত্তীর্ণ';
    }
  }

  static KycStatus fromString(String val) {
    return KycStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => KycStatus.notSubmitted,
    );
  }
}

class KycRecordModel {
  final String id;
  final String memberId;
  final String societyId;
  final KycDocType docType;
  final String docNumberMasked; // e.g. "******1234"
  final String? frontUrl;
  final String? backUrl;
  final KycStatus status;
  final String? rejectionReason;
  final String? verifiedBy;
  final DateTime? verifiedAt;
  final DateTime submittedAt;

  const KycRecordModel({
    required this.id,
    required this.memberId,
    required this.societyId,
    required this.docType,
    required this.docNumberMasked,
    this.frontUrl,
    this.backUrl,
    required this.status,
    this.rejectionReason,
    this.verifiedBy,
    this.verifiedAt,
    required this.submittedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'memberId': memberId,
    'societyId': societyId,
    'docType': docType.name,
    'docNumberMasked': docNumberMasked,
    'frontUrl': frontUrl,
    'backUrl': backUrl,
    'status': status.name,
    'rejectionReason': rejectionReason,
    'verifiedBy': verifiedBy,
    'verifiedAt': verifiedAt?.toIso8601String(),
    'submittedAt': submittedAt.toIso8601String(),
  };

  factory KycRecordModel.fromMap(Map<String, dynamic> map, String id) {
    return KycRecordModel(
      id: id,
      memberId: map['memberId'] as String? ?? '',
      societyId: map['societyId'] as String? ?? '',
      docType: KycDocType.fromString(map['docType'] as String? ?? 'nid'),
      docNumberMasked: map['docNumberMasked'] as String? ?? '',
      frontUrl: map['frontUrl'] as String?,
      backUrl: map['backUrl'] as String?,
      status: KycStatus.fromString(map['status'] as String? ?? 'notSubmitted'),
      rejectionReason: map['rejectionReason'] as String?,
      verifiedBy: map['verifiedBy'] as String?,
      verifiedAt: map['verifiedAt'] != null ? DateTime.tryParse(map['verifiedAt'] as String) : null,
      submittedAt: DateTime.tryParse(map['submittedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

// ==========================================
// 4. ENTERPRISE DOCUMENT MANAGEMENT (EDMS)
// ==========================================

enum DocumentCategory {
  memberKyc,
  loansGuarantor,
  societyLegal,
  hrPayroll,
  procurementAssets,
  general;

  String get labelBn {
    switch (this) {
      case DocumentCategory.memberKyc: return 'সদস্য KYC ও ছবি';
      case DocumentCategory.loansGuarantor: return 'ঋণ ও জামিনদার চুক্তিপত্র';
      case DocumentCategory.societyLegal: return 'সমিতি রেজুলেশন ও উপবিধি';
      case DocumentCategory.hrPayroll: return 'মানবসম্পদ ও নিয়োগপত্র';
      case DocumentCategory.procurementAssets: return 'ক্রয় চালান ও ওয়ারেন্টি';
      case DocumentCategory.general: return 'সাধারণ দাপ্তরিক নথি';
    }
  }

  static DocumentCategory fromString(String val) {
    return DocumentCategory.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => DocumentCategory.general,
    );
  }
}

class SocietyDocumentModel {
  final String id;
  final String societyId;
  final DocumentCategory category;
  final String title;
  final String storagePath;
  final int fileSizeBytes;
  final String mimeType;
  final String uploadedBy;
  final DateTime uploadedAt;
  final List<String> tags;
  final bool isArchived;

  const SocietyDocumentModel({
    required this.id,
    required this.societyId,
    required this.category,
    required this.title,
    required this.storagePath,
    required this.fileSizeBytes,
    required this.mimeType,
    required this.uploadedBy,
    required this.uploadedAt,
    this.tags = const [],
    this.isArchived = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'societyId': societyId,
    'category': category.name,
    'title': title,
    'storagePath': storagePath,
    'fileSizeBytes': fileSizeBytes,
    'mimeType': mimeType,
    'uploadedBy': uploadedBy,
    'uploadedAt': uploadedAt.toIso8601String(),
    'tags': tags,
    'isArchived': isArchived,
  };

  factory SocietyDocumentModel.fromMap(Map<String, dynamic> map, String id) {
    return SocietyDocumentModel(
      id: id,
      societyId: map['societyId'] as String? ?? '',
      category: DocumentCategory.fromString(map['category'] as String? ?? 'general'),
      title: map['title'] as String? ?? '',
      storagePath: map['storagePath'] as String? ?? '',
      fileSizeBytes: (map['fileSizeBytes'] as num?)?.toInt() ?? 0,
      mimeType: map['mimeType'] as String? ?? 'application/octet-stream',
      uploadedBy: map['uploadedBy'] as String? ?? '',
      uploadedAt: DateTime.tryParse(map['uploadedAt'] as String? ?? '') ?? DateTime.now(),
      tags: List<String>.from(map['tags'] ?? []),
      isArchived: map['isArchived'] as bool? ?? false,
    );
  }
}

// ==========================================
// 5. HR & EMPLOYEE MANAGEMENT
// ==========================================

class HrEmployeeModel {
  final String id;
  final String societyId;
  final String employeeCode; // e.g. EMP-001
  final String fullName;
  final String phone;
  final String? email;
  final String designation;
  final String department;
  final DateTime joiningDate;
  final String status; // active, onLeave, resigned, terminated
  final int baseSalaryPoisha; // 1 BDT = 100 Poisha
  final String? reportingManagerId;

  const HrEmployeeModel({
    required this.id,
    required this.societyId,
    required this.employeeCode,
    required this.fullName,
    required this.phone,
    this.email,
    required this.designation,
    required this.department,
    required this.joiningDate,
    this.status = 'active',
    required this.baseSalaryPoisha,
    this.reportingManagerId,
  });

  double get baseSalaryBdt => baseSalaryPoisha / 100.0;

  Map<String, dynamic> toMap() => {
    'id': id,
    'societyId': societyId,
    'employeeCode': employeeCode,
    'fullName': fullName,
    'phone': phone,
    'email': email,
    'designation': designation,
    'department': department,
    'joiningDate': joiningDate.toIso8601String(),
    'status': status,
    'baseSalaryPoisha': baseSalaryPoisha,
    'reportingManagerId': reportingManagerId,
  };

  factory HrEmployeeModel.fromMap(Map<String, dynamic> map, String id) {
    return HrEmployeeModel(
      id: id,
      societyId: map['societyId'] as String? ?? '',
      employeeCode: map['employeeCode'] as String? ?? id,
      fullName: map['fullName'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      email: map['email'] as String?,
      designation: map['designation'] as String? ?? 'কর্মকর্তা',
      department: map['department'] as String? ?? 'সাধারণ প্রশাসন',
      joiningDate: DateTime.tryParse(map['joiningDate'] as String? ?? '') ?? DateTime.now(),
      status: map['status'] as String? ?? 'active',
      baseSalaryPoisha: (map['baseSalaryPoisha'] as num?)?.toInt() ?? 0,
      reportingManagerId: map['reportingManagerId'] as String?,
    );
  }
}

// ==========================================
// 6. ATTENDANCE & LEAVE MANAGEMENT
// ==========================================

class AttendanceRecordModel {
  final String id;
  final String societyId;
  final String employeeId;
  final DateTime date;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final String status; // present, late, absent, onLeave
  final bool isCorrected;

  const AttendanceRecordModel({
    required this.id,
    required this.societyId,
    required this.employeeId,
    required this.date,
    required this.checkInTime,
    this.checkOutTime,
    this.status = 'present',
    this.isCorrected = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'societyId': societyId,
    'employeeId': employeeId,
    'date': date.toIso8601String(),
    'checkInTime': checkInTime.toIso8601String(),
    'checkOutTime': checkOutTime?.toIso8601String(),
    'status': status,
    'isCorrected': isCorrected,
  };

  factory AttendanceRecordModel.fromMap(Map<String, dynamic> map, String id) {
    return AttendanceRecordModel(
      id: id,
      societyId: map['societyId'] as String? ?? '',
      employeeId: map['employeeId'] as String? ?? '',
      date: DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now(),
      checkInTime: DateTime.tryParse(map['checkInTime'] as String? ?? '') ?? DateTime.now(),
      checkOutTime: map['checkOutTime'] != null ? DateTime.tryParse(map['checkOutTime'] as String) : null,
      status: map['status'] as String? ?? 'present',
      isCorrected: map['isCorrected'] as bool? ?? false,
    );
  }
}

enum LeaveType {
  casualLeave,
  sickLeave,
  earnedLeave,
  maternityLeave,
  unpaidLeave;

  String get labelBn {
    switch (this) {
      case LeaveType.casualLeave: return 'নৈমিত্তিক ছুটি (CL)';
      case LeaveType.sickLeave: return 'অসুস্থতাজনিত ছুটি (SL)';
      case LeaveType.earnedLeave: return 'অর্জিত ছুটি (EL)';
      case LeaveType.maternityLeave: return 'মাতৃত্বকালীন ছুটি';
      case LeaveType.unpaidLeave: return 'বিনা বেতনে ছুটি (LWP)';
    }
  }

  static LeaveType fromString(String val) {
    return LeaveType.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => LeaveType.casualLeave,
    );
  }
}

class LeaveApplicationModel {
  final String id;
  final String societyId;
  final String employeeId;
  final LeaveType leaveType;
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  final String reason;
  final String status; // pending, approved, rejected
  final String? approvedBy;
  final DateTime? reviewedAt;

  const LeaveApplicationModel({
    required this.id,
    required this.societyId,
    required this.employeeId,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.reason,
    this.status = 'pending',
    this.approvedBy,
    this.reviewedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'societyId': societyId,
    'employeeId': employeeId,
    'leaveType': leaveType.name,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'totalDays': totalDays,
    'reason': reason,
    'status': status,
    'approvedBy': approvedBy,
    'reviewedAt': reviewedAt?.toIso8601String(),
  };

  factory LeaveApplicationModel.fromMap(Map<String, dynamic> map, String id) {
    return LeaveApplicationModel(
      id: id,
      societyId: map['societyId'] as String? ?? '',
      employeeId: map['employeeId'] as String? ?? '',
      leaveType: LeaveType.fromString(map['leaveType'] as String? ?? 'casualLeave'),
      startDate: DateTime.tryParse(map['startDate'] as String? ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(map['endDate'] as String? ?? '') ?? DateTime.now(),
      totalDays: (map['totalDays'] as num?)?.toInt() ?? 1,
      reason: map['reason'] as String? ?? '',
      status: map['status'] as String? ?? 'pending',
      approvedBy: map['approvedBy'] as String?,
      reviewedAt: map['reviewedAt'] != null ? DateTime.tryParse(map['reviewedAt'] as String) : null,
    );
  }
}

// ==========================================
// 7. PAYROLL MANAGEMENT (POISHA PRECISION)
// ==========================================

class PayrollRunModel {
  final String id;
  final String societyId;
  final int periodMonth;
  final int year;
  final String employeeId;
  final int basicPoisha;
  final int allowancePoisha;
  final int bonusPoisha;
  final int deductionsPoisha;
  final int taxPoisha;
  final int netSalaryPoisha;
  final String status; // draft, reviewed, approved, disbursed
  final String? voucherId; // Linked Phase 2 Journal Voucher ID
  final DateTime? disbursedAt;

  const PayrollRunModel({
    required this.id,
    required this.societyId,
    required this.periodMonth,
    required this.year,
    required this.employeeId,
    required this.basicPoisha,
    required this.allowancePoisha,
    this.bonusPoisha = 0,
    this.deductionsPoisha = 0,
    this.taxPoisha = 0,
    required this.netSalaryPoisha,
    this.status = 'draft',
    this.voucherId,
    this.disbursedAt,
  });

  double get netSalaryBdt => netSalaryPoisha / 100.0;
  double get grossSalaryBdt => (basicPoisha + allowancePoisha + bonusPoisha) / 100.0;

  Map<String, dynamic> toMap() => {
    'id': id,
    'societyId': societyId,
    'periodMonth': periodMonth,
    'year': year,
    'employeeId': employeeId,
    'basicPoisha': basicPoisha,
    'allowancePoisha': allowancePoisha,
    'bonusPoisha': bonusPoisha,
    'deductionsPoisha': deductionsPoisha,
    'taxPoisha': taxPoisha,
    'netSalaryPoisha': netSalaryPoisha,
    'status': status,
    'voucherId': voucherId,
    'disbursedAt': disbursedAt?.toIso8601String(),
  };

  factory PayrollRunModel.fromMap(Map<String, dynamic> map, String id) {
    return PayrollRunModel(
      id: id,
      societyId: map['societyId'] as String? ?? '',
      periodMonth: (map['periodMonth'] as num?)?.toInt() ?? 1,
      year: (map['year'] as num?)?.toInt() ?? 2026,
      employeeId: map['employeeId'] as String? ?? '',
      basicPoisha: (map['basicPoisha'] as num?)?.toInt() ?? 0,
      allowancePoisha: (map['allowancePoisha'] as num?)?.toInt() ?? 0,
      bonusPoisha: (map['bonusPoisha'] as num?)?.toInt() ?? 0,
      deductionsPoisha: (map['deductionsPoisha'] as num?)?.toInt() ?? 0,
      taxPoisha: (map['taxPoisha'] as num?)?.toInt() ?? 0,
      netSalaryPoisha: (map['netSalaryPoisha'] as num?)?.toInt() ?? 0,
      status: map['status'] as String? ?? 'draft',
      voucherId: map['voucherId'] as String?,
      disbursedAt: map['disbursedAt'] != null ? DateTime.tryParse(map['disbursedAt'] as String) : null,
    );
  }
}

// ==========================================
// 8. INVENTORY MANAGEMENT
// ==========================================

enum InventoryMovementType {
  stockOpening,
  stockReceiving,
  stockIssue,
  stockReturn,
  stockAdjustment;

  String get labelBn {
    switch (this) {
      case InventoryMovementType.stockOpening: return 'প্রারম্ভিক স্টক';
      case InventoryMovementType.stockReceiving: return 'মালামাল গ্রহণ (Inward)';
      case InventoryMovementType.stockIssue: return 'মালামাল প্রদান (Outward)';
      case InventoryMovementType.stockReturn: return 'ফেরত গ্রহণ (Return)';
      case InventoryMovementType.stockAdjustment: return 'স্টক সমন্বয় (Adjustment)';
    }
  }

  static InventoryMovementType fromString(String val) {
    return InventoryMovementType.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => InventoryMovementType.stockReceiving,
    );
  }
}

class InventoryItemModel {
  final String id;
  final String societyId;
  final String sku;
  final String name;
  final String category;
  final String unit; // pcs, box, ream
  final int currentStock;
  final int reorderLevel;
  final int unitCostPoisha;

  const InventoryItemModel({
    required this.id,
    required this.societyId,
    required this.sku,
    required this.name,
    required this.category,
    required this.unit,
    required this.currentStock,
    required this.reorderLevel,
    required this.unitCostPoisha,
  });

  bool get isLowStock => currentStock <= reorderLevel;
  double get unitCostBdt => unitCostPoisha / 100.0;

  Map<String, dynamic> toMap() => {
    'id': id,
    'societyId': societyId,
    'sku': sku,
    'name': name,
    'category': category,
    'unit': unit,
    'currentStock': currentStock,
    'reorderLevel': reorderLevel,
    'unitCostPoisha': unitCostPoisha,
  };

  factory InventoryItemModel.fromMap(Map<String, dynamic> map, String id) {
    return InventoryItemModel(
      id: id,
      societyId: map['societyId'] as String? ?? '',
      sku: map['sku'] as String? ?? '',
      name: map['name'] as String? ?? '',
      category: map['category'] as String? ?? 'সাধারণ',
      unit: map['unit'] as String? ?? 'pcs',
      currentStock: (map['currentStock'] as num?)?.toInt() ?? 0,
      reorderLevel: (map['reorderLevel'] as num?)?.toInt() ?? 10,
      unitCostPoisha: (map['unitCostPoisha'] as num?)?.toInt() ?? 0,
    );
  }
}

class InventoryMovementModel {
  final String id;
  final String societyId;
  final String itemId;
  final InventoryMovementType movementType;
  final int quantity;
  final int balanceAfter;
  final String actorId;
  final String reason;
  final DateTime timestamp;

  const InventoryMovementModel({
    required this.id,
    required this.societyId,
    required this.itemId,
    required this.movementType,
    required this.quantity,
    required this.balanceAfter,
    required this.actorId,
    required this.reason,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'societyId': societyId,
    'itemId': itemId,
    'movementType': movementType.name,
    'quantity': quantity,
    'balanceAfter': balanceAfter,
    'actorId': actorId,
    'reason': reason,
    'timestamp': timestamp.toIso8601String(),
  };

  factory InventoryMovementModel.fromMap(Map<String, dynamic> map, String id) {
    return InventoryMovementModel(
      id: id,
      societyId: map['societyId'] as String? ?? '',
      itemId: map['itemId'] as String? ?? '',
      movementType: InventoryMovementType.fromString(map['movementType'] as String? ?? 'stockReceiving'),
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,
      balanceAfter: (map['balanceAfter'] as num?)?.toInt() ?? 0,
      actorId: map['actorId'] as String? ?? '',
      reason: map['reason'] as String? ?? '',
      timestamp: DateTime.tryParse(map['timestamp'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

// ==========================================
// 9. ASSET MANAGEMENT
// ==========================================

enum AssetStatus {
  requested,
  purchased,
  registered,
  assigned,
  inUse,
  underMaintenance,
  retired,
  disposed;

  String get labelBn {
    switch (this) {
      case AssetStatus.requested: return 'অনুরোধকৃত';
      case AssetStatus.purchased: return 'ক্রয়কৃত';
      case AssetStatus.registered: return 'নিবন্ধিত';
      case AssetStatus.assigned: return 'দায়িত্বপ্রাপ্ত';
      case AssetStatus.inUse: return 'ব্যবহারাধীন';
      case AssetStatus.underMaintenance: return 'মেরামতাধীন';
      case AssetStatus.retired: return 'অবসরপ্রাপ্ত';
      case AssetStatus.disposed: return 'নিষ্পত্তিকৃত (Disposed)';
    }
  }

  static AssetStatus fromString(String val) {
    return AssetStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => AssetStatus.registered,
    );
  }
}

class AssetRegisterModel {
  final String id;
  final String societyId;
  final String assetTag; // e.g. AST-LAPTOP-01
  final String name;
  final String category; // Electronics, Furniture, Vehicle
  final DateTime purchaseDate;
  final int purchaseCostPoisha;
  final int currentValuationPoisha;
  final String? assignedEmployeeId;
  final AssetStatus status;
  final String location;

  const AssetRegisterModel({
    required this.id,
    required this.societyId,
    required this.assetTag,
    required this.name,
    required this.category,
    required this.purchaseDate,
    required this.purchaseCostPoisha,
    required this.currentValuationPoisha,
    this.assignedEmployeeId,
    this.status = AssetStatus.registered,
    this.location = 'প্রধান কার্যালয়',
  });

  double get purchaseCostBdt => purchaseCostPoisha / 100.0;
  double get currentValuationBdt => currentValuationPoisha / 100.0;

  Map<String, dynamic> toMap() => {
    'id': id,
    'societyId': societyId,
    'assetTag': assetTag,
    'name': name,
    'category': category,
    'purchaseDate': purchaseDate.toIso8601String(),
    'purchaseCostPoisha': purchaseCostPoisha,
    'currentValuationPoisha': currentValuationPoisha,
    'assignedEmployeeId': assignedEmployeeId,
    'status': status.name,
    'location': location,
  };

  factory AssetRegisterModel.fromMap(Map<String, dynamic> map, String id) {
    return AssetRegisterModel(
      id: id,
      societyId: map['societyId'] as String? ?? '',
      assetTag: map['assetTag'] as String? ?? id,
      name: map['name'] as String? ?? '',
      category: map['category'] as String? ?? 'আসবাবপত্র',
      purchaseDate: DateTime.tryParse(map['purchaseDate'] as String? ?? '') ?? DateTime.now(),
      purchaseCostPoisha: (map['purchaseCostPoisha'] as num?)?.toInt() ?? 0,
      currentValuationPoisha: (map['currentValuationPoisha'] as num?)?.toInt() ?? 0,
      assignedEmployeeId: map['assignedEmployeeId'] as String?,
      status: AssetStatus.fromString(map['status'] as String? ?? 'registered'),
      location: map['location'] as String? ?? 'প্রধান কার্যালয়',
    );
  }
}

// ==========================================
// 10. PROCUREMENT & VENDOR MANAGEMENT
// ==========================================

class VendorModel {
  final String id;
  final String societyId;
  final String name;
  final String contactPerson;
  final String phone;
  final String? email;
  final String address;
  final String? taxId; // BIN or TIN
  final double rating;

  const VendorModel({
    required this.id,
    required this.societyId,
    required this.name,
    required this.contactPerson,
    required this.phone,
    this.email,
    required this.address,
    this.taxId,
    this.rating = 5.0,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'societyId': societyId,
    'name': name,
    'contactPerson': contactPerson,
    'phone': phone,
    'email': email,
    'address': address,
    'taxId': taxId,
    'rating': rating,
  };

  factory VendorModel.fromMap(Map<String, dynamic> map, String id) {
    return VendorModel(
      id: id,
      societyId: map['societyId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      contactPerson: map['contactPerson'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      email: map['email'] as String?,
      address: map['address'] as String? ?? '',
      taxId: map['taxId'] as String?,
      rating: (map['rating'] as num?)?.toDouble() ?? 5.0,
    );
  }
}

class PurchaseRequestModel {
  final String id;
  final String societyId;
  final String vendorId;
  final String title;
  final String itemsDescription;
  final int quantity;
  final int estimatedCostPoisha;
  final String status; // draft, pendingApproval, approved, poIssued, goodsReceived, rejected
  final String? approvedBy;
  final String? poNumber;

  const PurchaseRequestModel({
    required this.id,
    required this.societyId,
    required this.vendorId,
    required this.title,
    required this.itemsDescription,
    required this.quantity,
    required this.estimatedCostPoisha,
    this.status = 'draft',
    this.approvedBy,
    this.poNumber,
  });

  double get estimatedCostBdt => estimatedCostPoisha / 100.0;

  Map<String, dynamic> toMap() => {
    'id': id,
    'societyId': societyId,
    'vendorId': vendorId,
    'title': title,
    'itemsDescription': itemsDescription,
    'quantity': quantity,
    'estimatedCostPoisha': estimatedCostPoisha,
    'status': status,
    'approvedBy': approvedBy,
    'poNumber': poNumber,
  };

  factory PurchaseRequestModel.fromMap(Map<String, dynamic> map, String id) {
    return PurchaseRequestModel(
      id: id,
      societyId: map['societyId'] as String? ?? '',
      vendorId: map['vendorId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      itemsDescription: map['itemsDescription'] as String? ?? '',
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      estimatedCostPoisha: (map['estimatedCostPoisha'] as num?)?.toInt() ?? 0,
      status: map['status'] as String? ?? 'draft',
      approvedBy: map['approvedBy'] as String?,
      poNumber: map['poNumber'] as String?,
    );
  }
}

// ==========================================
// 11. INTERNAL OPERATIONS & TASKS
// ==========================================

class OperationsTaskModel {
  final String id;
  final String societyId;
  final String title;
  final String description;
  final String assignedEmployeeId;
  final String priority; // low, medium, high, urgent
  final DateTime dueDate;
  final String status; // open, inProgress, completed, overdue, cancelled
  final DateTime createdAt;

  const OperationsTaskModel({
    required this.id,
    required this.societyId,
    required this.title,
    required this.description,
    required this.assignedEmployeeId,
    this.priority = 'medium',
    required this.dueDate,
    this.status = 'open',
    required this.createdAt,
  });

  bool get isOverdue => status != 'completed' && DateTime.now().isAfter(dueDate);

  Map<String, dynamic> toMap() => {
    'id': id,
    'societyId': societyId,
    'title': title,
    'description': description,
    'assignedEmployeeId': assignedEmployeeId,
    'priority': priority,
    'dueDate': dueDate.toIso8601String(),
    'status': status,
    'createdAt': createdAt.toIso8601String(),
  };

  factory OperationsTaskModel.fromMap(Map<String, dynamic> map, String id) {
    return OperationsTaskModel(
      id: id,
      societyId: map['societyId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      assignedEmployeeId: map['assignedEmployeeId'] as String? ?? '',
      priority: map['priority'] as String? ?? 'medium',
      dueDate: DateTime.tryParse(map['dueDate'] as String? ?? '') ?? DateTime.now().add(const Duration(days: 3)),
      status: map['status'] as String? ?? 'open',
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
