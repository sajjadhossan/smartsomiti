import 'package:cloud_firestore/cloud_firestore.dart';

/// Standard user roles in the platform
enum UserRole {
  superAdmin,    // প্ল্যাটফর্ম সুপার এডমিন
  societyOwner,  // সমিতির মালিক / প্রতিষ্ঠাতা
  societyAdmin,  // সমিতির এডমিন
  manager,       // শাখা বা সমিতির ম্যানেজার
  accountant,    // হিসাবরক্ষক / ক্যাশিয়ার
  fieldOfficer,  // মাঠকর্মী / কালেকশন অফিসার
  member,        // সাধারণ সদস্য
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.superAdmin:
        return 'সুপার এডমিন (প্ল্যাটফর্ম)';
      case UserRole.societyOwner:
        return 'সমিতির মালিক / প্রতিষ্ঠাতা';
      case UserRole.societyAdmin:
        return 'সমিতির এডমিন';
      case UserRole.manager:
        return 'ম্যানেজার';
      case UserRole.accountant:
        return 'হিসাবরক্ষক (ক্যাশিয়ার)';
      case UserRole.fieldOfficer:
        return 'মাঠকর্মী (কালেক্টর)';
      case UserRole.member:
        return 'সাধারণ সদস্য';
    }
  }

  String get code => name;
}

/// Granular permission definitions across all domains
class AppPermissions {
  // সদস্য ব্যবস্থাপনা (Member Management)
  static const String memberView = 'member.view';
  static const String memberCreate = 'member.create';
  static const String memberEdit = 'member.edit';
  static const String memberDelete = 'member.delete';

  // সঞ্চয় ব্যবস্থাপনা (Savings Management)
  static const String savingsView = 'savings.view';
  static const String savingsDeposit = 'savings.deposit';
  static const String savingsWithdraw = 'savings.withdraw';
  static const String savingsStatement = 'savings.statement';

  // ঋণ ব্যবস্থাপনা (Loan Management)
  static const String loanView = 'loan.view';
  static const String loanApply = 'loan.apply';
  static const String loanApprove = 'loan.approve';
  static const String loanDisburse = 'loan.disburse';
  static const String loanRepay = 'loan.repay';
  static const String loanSettle = 'loan.settle';

  // হিসাববিজ্ঞান ও ক্যাশ (Accounting & Cash)
  static const String accountView = 'account.view';
  static const String cashbookView = 'cashbook.view';
  static const String expenseRecord = 'expense.record';
  static const String incomeRecord = 'income.record';
  static const String fundTransfer = 'fund.transfer';
  static const String ledgerView = 'ledger.view';

  // কর্মী ও ভূমিকা (Employees & Roles)
  static const String employeeView = 'employee.view';
  static const String employeeManage = 'employee.manage';
  static const String roleAssign = 'role.assign';

  // নোটিশ ও রিপোর্ট (Notices & Reports)
  static const String noticeCreate = 'notice.create';
  static const String reportView = 'report.view';
  static const String reportExport = 'report.export';

  // সেটিংস (Settings)
  static const String settingsManage = 'settings.manage';
  static const String auditLogView = 'audit.view';

  /// All registered system permissions
  static const List<String> allPermissions = [
    memberView, memberCreate, memberEdit, memberDelete,
    savingsView, savingsDeposit, savingsWithdraw, savingsStatement,
    loanView, loanApply, loanApprove, loanDisburse, loanRepay, loanSettle,
    accountView, cashbookView, expenseRecord, incomeRecord, fundTransfer, ledgerView,
    employeeView, employeeManage, roleAssign,
    noticeCreate, reportView, reportExport,
    settingsManage, auditLogView,
  ];

  /// Bangla human-readable title for permission
  static String getPermissionTitle(String key) {
    switch (key) {
      case memberView: return 'সদস্য তালিকা ও তথ্য দেখা';
      case memberCreate: return 'নতুন সদস্য যোগ করা';
      case memberEdit: return 'সদস্য তথ্য সংশোধন করা';
      case memberDelete: return 'সদস্য অপসারণ করা';

      case savingsView: return 'সঞ্চয় হিসাব দেখা';
      case savingsDeposit: return 'সঞ্চয় কিস্তি জমা নেওয়া';
      case savingsWithdraw: return 'সঞ্চয় ফেরত / উত্তোলন অনুমোদন';
      case savingsStatement: return 'সঞ্চয় স্টেটমেন্ট ও পাসবুক প্রিন্ট';

      case loanView: return 'ঋণ তালিকা ও বিস্তারিত দেখা';
      case loanApply: return 'নতুন ঋণের আবেদন জমা দেওয়া';
      case loanApprove: return 'ঋণের আবেদন অনুমোদন বা বাতিল করা';
      case loanDisburse: return 'ঋণ বিতরণ (ক্যাশ আউট)';
      case loanRepay: return 'ঋণের কিস্তি আদায় ও রসিদ প্রদান';
      case loanSettle: return 'ঋণ ক্লোজ / ফাইনাল সেটেলমেন্ট';

      case accountView: return 'আর্থিক হিসাব ও ব্যাংক ব্যালেন্স দেখা';
      case cashbookView: return 'দৈনিক ক্যাশ বহি ও রেজিস্টার দেখা';
      case expenseRecord: return 'সমিতির খরচ এন্ট্রি ও ভাউচার তৈরি';
      case incomeRecord: return 'বিবিধ আয় এন্ট্রি করা';
      case fundTransfer: return 'হিসাব স্থানান্তর (ক্যাশ/ব্যাংক/বিকাশ)';
      case ledgerView: return 'খতিয়ান ও লাভ-ক্ষতির হিসাব দেখা';

      case employeeView: return 'কর্মী তালিকা ও বিবরণ দেখা';
      case employeeManage: return 'নতুন কর্মী নিয়োগ ও তথ্য পরিবর্তন';
      case roleAssign: return 'কর্মীর দায়িত্ব ও পারমিশন নির্ধারণ';

      case noticeCreate: return 'অফিসিয়াল নোটিশ জারি ও সিল-স্বাক্ষর';
      case reportView: return 'রিপোর্ট ও বিশ্লেষণ দেখা';
      case reportExport: return 'PDF ও এক্সেল রিপোর্ট ডাউনলোড';

      case settingsManage: return 'সমিতির প্যাড, ব্যানার ও সেটিংস পরিবর্তন';
      case auditLogView: return 'অডিট লগ ও সিস্টেম ইতিহাস পর্যবেক্ষণ';
      default: return key;
    }
  }

  /// Preset permission sets by role
  static Set<String> getPreset(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return Set.from(allPermissions);

      case UserRole.societyOwner:
        return Set.from(allPermissions);

      case UserRole.societyAdmin:
        return {
          memberView, memberCreate, memberEdit,
          savingsView, savingsDeposit, savingsWithdraw, savingsStatement,
          loanView, loanApply, loanApprove, loanDisburse, loanRepay, loanSettle,
          accountView, cashbookView, expenseRecord, incomeRecord, fundTransfer, ledgerView,
          employeeView, employeeManage,
          noticeCreate, reportView, reportExport,
          settingsManage, auditLogView,
        };

      case UserRole.manager:
        return {
          memberView, memberCreate, memberEdit,
          savingsView, savingsDeposit, savingsWithdraw, savingsStatement,
          loanView, loanApply, loanApprove, loanDisburse, loanRepay,
          accountView, cashbookView, expenseRecord, incomeRecord, fundTransfer, ledgerView,
          employeeView,
          noticeCreate, reportView, reportExport,
        };

      case UserRole.accountant:
        return {
          memberView,
          savingsView, savingsDeposit, savingsStatement,
          loanView, loanRepay,
          accountView, cashbookView, expenseRecord, incomeRecord, ledgerView,
          reportView, reportExport,
        };

      case UserRole.fieldOfficer:
        return {
          memberView, memberCreate,
          savingsView, savingsDeposit,
          loanView, loanApply, loanRepay,
        };

      case UserRole.member:
        return {
          savingsView,
          loanView,
        };
    }
  }
}

/// User's specific permission assignment model for a society
class SocietyUserPermissionModel {
  final String userId;
  final String somitiId;
  final UserRole role;
  final Set<String> grantedPermissions;
  final Set<String> deniedPermissions;
  final DateTime updatedAt;
  final String updatedBy;

  SocietyUserPermissionModel({
    required this.userId,
    required this.somitiId,
    required this.role,
    Set<String>? grantedPermissions,
    Set<String>? deniedPermissions,
    required this.updatedAt,
    this.updatedBy = '',
  })  : grantedPermissions = grantedPermissions ?? {},
        deniedPermissions = deniedPermissions ?? {};

  /// Check whether this user has permission for an action
  bool hasPermission(String permissionKey) {
    if (role == UserRole.superAdmin || role == UserRole.societyOwner) {
      return true;
    }
    // Explicit denial overrides
    if (deniedPermissions.contains(permissionKey)) {
      return false;
    }
    // Explicit grant overrides
    if (grantedPermissions.contains(permissionKey)) {
      return true;
    }
    // Fallback to role presets
    return AppPermissions.getPreset(role).contains(permissionKey);
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'somitiId': somitiId,
      'role': role.name,
      'grantedPermissions': grantedPermissions.toList(),
      'deniedPermissions': deniedPermissions.toList(),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'updatedBy': updatedBy,
    };
  }

  factory SocietyUserPermissionModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    UserRole r = UserRole.member;
    try {
      r = UserRole.values.byName(data['role'] ?? 'member');
    } catch (_) {}

    final granted = Set<String>.from(data['grantedPermissions'] ?? []);
    final denied = Set<String>.from(data['deniedPermissions'] ?? []);

    DateTime dt = DateTime.now();
    final ts = data['updatedAt'];
    if (ts is Timestamp) dt = ts.toDate();

    return SocietyUserPermissionModel(
      userId: data['userId'] ?? doc.id,
      somitiId: data['somitiId'] ?? '',
      role: r,
      grantedPermissions: granted,
      deniedPermissions: denied,
      updatedAt: dt,
      updatedBy: data['updatedBy'] ?? '',
    );
  }
}
