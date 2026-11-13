import 'package:cloud_firestore/cloud_firestore.dart';

/// Representation of an individual configurable feature or sub-feature
class FeatureItem {
  final String key;
  final String title;
  final String description;
  final String moduleKey;
  final bool defaultEnabled;
  final bool isCore; // If true, cannot be disabled for critical platform stability

  const FeatureItem({
    required this.key,
    required this.title,
    required this.description,
    required this.moduleKey,
    this.defaultEnabled = true,
    this.isCore = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'title': title,
      'description': description,
      'moduleKey': moduleKey,
      'defaultEnabled': defaultEnabled,
      'isCore': isCore,
    };
  }

  factory FeatureItem.fromMap(Map<String, dynamic> map) {
    return FeatureItem(
      key: map['key'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      moduleKey: map['moduleKey'] ?? '',
      defaultEnabled: map['defaultEnabled'] ?? true,
      isCore: map['isCore'] ?? false,
    );
  }
}

/// Representation of a parent module containing hierarchical sub-features
class ModuleDefinition {
  final String key;
  final String title;
  final String icon;
  final String description;
  final bool defaultEnabled;
  final List<FeatureItem> subFeatures;

  const ModuleDefinition({
    required this.key,
    required this.title,
    required this.icon,
    required this.description,
    this.defaultEnabled = true,
    this.subFeatures = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'title': title,
      'icon': icon,
      'description': description,
      'defaultEnabled': defaultEnabled,
      'subFeatures': subFeatures.map((f) => f.toMap()).toList(),
    };
  }
}

/// Stored settings for Platform Global or Society-Specific overrides
class FeatureOverrideSettings {
  final String id; // 'global' or societyId
  final Map<String, bool> moduleToggles; // moduleKey -> bool
  final Map<String, bool> featureToggles; // featureKey -> bool
  final String updatedBy;
  final DateTime updatedAt;

  FeatureOverrideSettings({
    required this.id,
    required this.moduleToggles,
    required this.featureToggles,
    required this.updatedBy,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'moduleToggles': moduleToggles,
      'featureToggles': featureToggles,
      'updatedBy': updatedBy,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory FeatureOverrideSettings.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final rawModules = data['moduleToggles'] as Map<String, dynamic>? ?? {};
    final rawFeatures = data['featureToggles'] as Map<String, dynamic>? ?? {};

    DateTime dt;
    final ts = data['updatedAt'];
    if (ts is Timestamp) {
      dt = ts.toDate();
    } else {
      dt = DateTime.now();
    }

    return FeatureOverrideSettings(
      id: doc.id,
      moduleToggles: rawModules.map((k, v) => MapEntry(k, v == true)),
      featureToggles: rawFeatures.map((k, v) => MapEntry(k, v == true)),
      updatedBy: data['updatedBy'] ?? 'system',
      updatedAt: dt,
    );
  }
}

/// Master Registry containing all 24 Modules and their granular Sub-features
class MasterFeatureRegistry {
  static const List<ModuleDefinition> allModules = [
    ModuleDefinition(
      key: 'society_management',
      title: 'সমিতি ব্যবস্থাপনা (Society Management)',
      icon: '🏛️',
      description: 'মাল্টি-সমিতি তৈরি, কোড জেনারেশন ও সমিতি ব্র্যান্ডিং',
      subFeatures: [
        FeatureItem(key: 'society_create', title: 'নতুন সমিতি তৈরি', description: 'নতুন সমিতি খোলার অনুমতি', moduleKey: 'society_management', isCore: true),
        FeatureItem(key: 'society_branding', title: 'প্যাড ও লেটারহেড ব্যানার', description: 'কাস্টম লেটারহেড ব্যানার আপলোড', moduleKey: 'society_management'),
        FeatureItem(key: 'society_seal_signature', title: 'কর্মকর্তা সিল ও স্বাক্ষর', description: 'সভাপতি, সম্পাদক ও কোষাধ্যক্ষের সিল-সাইন', moduleKey: 'society_management'),
        FeatureItem(key: 'society_archive', title: 'সমিতি নিষ্ক্রিয় ও আর্কাইভ', description: 'সমিতি সাময়িক বা স্থায়ীভাবে বন্ধ করা', moduleKey: 'society_management'),
      ],
    ),
    ModuleDefinition(
      key: 'authentication',
      title: 'অথেনটিকেশন ও নিরাপত্তা (Authentication)',
      icon: '🔐',
      description: 'গুগল সাইন-ইন, ইমেইল লগইন ও সেশন নিরাপত্তা',
      subFeatures: [
        FeatureItem(key: 'auth_google', title: 'গুগল সাইন-ইন', description: 'Google একাউন্ট দিয়ে ১-ট্যাপে সাইন-ইন', moduleKey: 'authentication', isCore: true),
        FeatureItem(key: 'auth_email', title: 'ইমেইল ও পাসওয়ার্ড', description: 'ঐতিহ্যবাহী ইমেইল পাসওয়ার্ড লগইন', moduleKey: 'authentication', isCore: true),
        FeatureItem(key: 'auth_forgot_pass', title: 'পাসওয়ার্ড পুনরুদ্ধার', description: 'পাসওয়ার্ড রিসেট ইমেইল লিংক', moduleKey: 'authentication'),
      ],
    ),
    ModuleDefinition(
      key: 'user_management',
      title: 'ব্যবহারকারী ব্যবস্থাপনা (User Management)',
      icon: '👥',
      description: 'ব্যবহারকারী প্রোফাইল ও একাউন্ট অনুমোদন',
      subFeatures: [
        FeatureItem(key: 'user_approval_pool', title: 'নতুন সাইন-আপ অনুমোদন পুল', description: 'অনুমোদন ছাড়া একাউন্ট লক রাখা', moduleKey: 'user_management'),
        FeatureItem(key: 'user_society_assign', title: 'সমিতিতে সদস্য পদায়ন', description: 'ব্যবহারকারীকে নির্দিষ্ট সমিতিতে বরাদ্দ করা', moduleKey: 'user_management'),
      ],
    ),
    ModuleDefinition(
      key: 'role_management',
      title: 'রোল ও পদবি ব্যবস্থাপনা (Role Management)',
      icon: '🎖️',
      description: '৭টি স্ট্যান্ডার্ড সাংগঠনিক রোলের নিয়ন্ত্রণ',
      subFeatures: [
        FeatureItem(key: 'role_super_admin', title: 'প্ল্যাটফর্ম সুপার এডমিন', description: 'সর্বোচ্চ নিয়ন্ত্রক রোল', moduleKey: 'role_management', isCore: true),
        FeatureItem(key: 'role_society_owner', title: 'সমিতি মালিক / প্রোপাইটার', description: 'সমিতির প্রধান স্বত্বাধিকারী', moduleKey: 'role_management'),
        FeatureItem(key: 'role_society_admin', title: 'সমিতি এডমিন ও কোষাধ্যক্ষ', description: 'দৈনন্দিন আর্থিক কার্যনির্বাহী', moduleKey: 'role_management'),
        FeatureItem(key: 'role_manager', title: 'ম্যানেজার ও সুপারভাইজার', description: 'মাঠ পর্যায়ের তদারককারী', moduleKey: 'role_management'),
        FeatureItem(key: 'role_accountant', title: 'হিসাবরক্ষক', description: 'ক্যাশ বুক ও অডিট খাতা নিয়ন্ত্রণ', moduleKey: 'role_management'),
        FeatureItem(key: 'role_field_officer', title: 'মাঠ কর্মকর্তা ও কালেকশন এজেন্ট', description: 'কিস্তি আদায়কারী কর্মকর্তা', moduleKey: 'role_management'),
        FeatureItem(key: 'role_member', title: 'সাধারণ সদস্য', description: 'লাইভ পাসবুক ও রসিদ দর্শনকারী', moduleKey: 'role_management'),
      ],
    ),
    ModuleDefinition(
      key: 'permission_management',
      title: 'অনুমতি ম্যাট্রিক্স (Permission Management)',
      icon: '🛡️',
      description: 'গ্র্যানুলার পারমিশন ও এক্সেস লেভেল কন্ট্রোল',
      subFeatures: [
        FeatureItem(key: 'perm_owner_delegation', title: 'মালিক কর্তৃক পারমিশন প্রদান', description: 'কর্মচারীদের জন্য সীমিত ক্ষমতা নির্ধারণ', moduleKey: 'permission_management'),
        FeatureItem(key: 'perm_audit_view', title: 'অডিট লগ দেখার অনুমতি', description: 'সিস্টেমের গুরুত্বপূর্ণ পরিবর্তন ইতিহাস', moduleKey: 'permission_management'),
      ],
    ),
    ModuleDefinition(
      key: 'member_management',
      title: 'সদস্য ব্যবস্থাপনা (Member Management)',
      icon: '👤',
      description: 'সদস্য যোগ, আইডি নম্বর ও ব্যক্তিগত প্রোফাইল',
      subFeatures: [
        FeatureItem(key: 'member_add', title: 'নতুন সদস্য যুক্ত করা', description: 'নাম, মোবাইল ও সদস্য নম্বর বরাদ্দ', moduleKey: 'member_management', isCore: true),
        FeatureItem(key: 'member_passbook', title: 'সদস্য ডিজিটাল পাসবুক', description: 'সদস্যের নিজস্ব সঞ্চয় ও জমার খাতা', moduleKey: 'member_management'),
        FeatureItem(key: 'member_id_card', title: 'ডিজিটাল সদস্য পরিচয়পত্র', description: 'ছবি ও কিউআর কোডসহ মেম্বার আইডি কার্ড', moduleKey: 'member_management'),
        FeatureItem(key: 'member_delete', title: 'সদস্য বাতিল বা বন্ধ করা', description: 'সদস্যপদ সমাপ্তি কার্যক্রম', moduleKey: 'member_management'),
      ],
    ),
    ModuleDefinition(
      key: 'savings_management',
      title: 'সঞ্চয় ব্যবস্থাপনা (Savings Management)',
      icon: '📥',
      description: 'দৈনিক, সাপ্তাহিক ও মাসিক সঞ্চয় কিস্তি আদায়',
      subFeatures: [
        FeatureItem(key: 'savings_daily', title: 'দৈনিক সঞ্চয় কিস্তি', description: 'প্রতিদিন কিস্তি জমা গ্রহণ', moduleKey: 'savings_management'),
        FeatureItem(key: 'savings_weekly', title: 'সাপ্তাহিক সঞ্চয় কিস্তি', description: 'প্রতি সপ্তাহে নির্দিষ্ট দিনে জমা', moduleKey: 'savings_management'),
        FeatureItem(key: 'savings_monthly', title: 'মাসিক সঞ্চয় কিস্তি', description: 'মাসের শুরুতে নির্ধারিত সঞ্চয় কিস্তি', moduleKey: 'savings_management'),
        FeatureItem(key: 'savings_advance', title: 'অগ্রিম সঞ্চয় জমা', description: 'ভবিষ্যত মাসের কিস্তি আগে জমা দেওয়া', moduleKey: 'savings_management'),
        FeatureItem(key: 'savings_withdrawal', title: 'সঞ্চয় উত্তোলন / ফেরত', description: 'সদস্যের জমানো টাকা থেকে উত্তোলন', moduleKey: 'savings_management'),
        FeatureItem(key: 'savings_receipt_generate', title: 'ডিজিটাল মানি রিসিট', description: 'অফিসিয়াল লেটারহেড জমার রসিদ', moduleKey: 'savings_management'),
        FeatureItem(key: 'savings_slip_attachment', title: 'ব্যাংক জমা স্লিপ ও প্রমাণক', description: 'ব্যাংক ট্র্যান্সফার স্লিপ ফটো যুক্ত করা', moduleKey: 'savings_management'),
      ],
    ),
    ModuleDefinition(
      key: 'loan_management',
      title: 'ঋণ ব্যবস্থাপনা (Loan Management)',
      icon: '🤝',
      description: 'ঋণ আবেদন, অনুমোদন, ফ্ল্যাট ও রিডিউসিং ব্যালেন্স সুদ',
      subFeatures: [
        FeatureItem(key: 'loan_application', title: 'ঋণের আবেদন তৈরি', description: 'সদস্যদের জন্য ঋণ আবেদন প্রক্রিয়া', moduleKey: 'loan_management'),
        FeatureItem(key: 'loan_approval', title: 'ঋণ অনুমোদন ও বাতিল', description: 'কার্যনির্বাহী কমিটি কর্তৃক ঋণ মঞ্জুর', moduleKey: 'loan_management'),
        FeatureItem(key: 'loan_disbursement', title: 'ঋণ বিতরণ (Disbursement)', description: 'ক্যাশ বা ব্যাংকের মাধ্যমে ঋণ প্রদান', moduleKey: 'loan_management'),
        FeatureItem(key: 'loan_interest_flat', title: 'ফ্ল্যাট রেট সুদ (Flat Rate)', description: 'মূল টাকার ওপর নির্দিষ্ট হার সুদ', moduleKey: 'loan_management'),
        FeatureItem(key: 'loan_interest_reducing', title: 'হ্রাসমান ব্যালেন্স সুদ (Reducing EMI)', description: 'আসল কমার সাথে সাথে সুদের হিসাব', moduleKey: 'loan_management'),
        FeatureItem(key: 'loan_partial_repay', title: 'আংশিক কিস্তি পরিশোধ', description: 'কিস্তির টাকার ভগ্নাংশ জমা গ্রহণ', moduleKey: 'loan_management'),
        FeatureItem(key: 'loan_penalty_overdue', title: 'বকেয়া জরিমানা নির্ধারণ', description: 'সময়মতো কিস্তি না দিলে পেনাল্টি আরোপ', moduleKey: 'loan_management'),
      ],
    ),
    ModuleDefinition(
      key: 'financial_accounting',
      title: 'আর্থিক হিসাববিজ্ঞান (Financial Accounting)',
      icon: '📊',
      description: 'ডাবল-এন্ট্রি ব্যালেন্স শিট, প্রফিট-লস ও হিসাব খাতা',
      subFeatures: [
        FeatureItem(key: 'acc_balance_sheet', title: 'আর্থিক উদ্বৃত্তপত্র (Balance Sheet)', description: 'মোট সম্পত্তি ও দায়ের চিত্র', moduleKey: 'financial_accounting'),
        FeatureItem(key: 'acc_profit_loss', title: 'লাভ-ক্ষতি বিবরণী (P&L Statement)', description: 'আয় ও ব্যয়ের ভিত্তিতে লাভ/ক্ষতি নির্ধারণ', moduleKey: 'financial_accounting'),
        FeatureItem(key: 'acc_running_balance', title: 'চলমান ক্যাশ স্থিতি (Running Balance)', description: 'প্রতিটি লেনদেনের পর স্বয়ংক্রিয় স্থিতি', moduleKey: 'financial_accounting'),
      ],
    ),
    ModuleDefinition(
      key: 'cash_management',
      title: 'ক্যাশ ও ক্যাশ বুক (Cash Management)',
      icon: '📒',
      description: 'দৈনিক ক্যাশ বুক, আয়-ব্যয় ভাউচার ও ক্যাশ হিসাব',
      subFeatures: [
        FeatureItem(key: 'cash_daily_book', title: 'দৈনিক ক্যাশ বুক', description: 'তারিখভিত্তিক সকল আয় ও ব্যয়ের তালিকা', moduleKey: 'cash_management'),
        FeatureItem(key: 'cash_monthly_summary', title: 'মাসওয়ারি ক্যাশ সারসংক্ষেপ', description: '১২ মাসের মোট সঞ্চয় ও খরচের তুলনামূলক বিবরণী', moduleKey: 'cash_management'),
        FeatureItem(key: 'cash_drawer_reconcile', title: 'ক্যাশ ড্রয়ার মিলকরণ', description: 'হাতের নগদ টাকার সাথে লেজার মিলকরণ', moduleKey: 'cash_management'),
      ],
    ),
    ModuleDefinition(
      key: 'bank_management',
      title: 'ব্যাংক হিসাব খাতা (Bank Management)',
      icon: '🏦',
      description: 'সমিতির ব্যাংক একাউন্ট ও ব্যালেন্স ট্র্যাকিং',
      subFeatures: [
        FeatureItem(key: 'bank_account_tracker', title: 'একাধিক ব্যাংক হিসাব ট্র্যাকিং', description: 'সিটি ব্যাংক, সোনালী ব্যাংক ইত্যাদি একাউন্ট', moduleKey: 'bank_management'),
        FeatureItem(key: 'bank_to_cash_transfer', title: 'ব্যাংক-ক্যাশ ফান্ড ট্রান্সফার', description: 'ব্যাংক থেকে উত্তোলন বা ব্যাংকে জমা', moduleKey: 'bank_management'),
      ],
    ),
    ModuleDefinition(
      key: 'payment_management',
      title: 'পেমেন্ট ও মাধ্যম ব্যবস্থাপনা (Payment Management)',
      icon: '💳',
      description: 'বিকাশ, নগদ, ব্যাংক ট্রান্সফার ও ক্যাশ সংগ্রহ',
      subFeatures: [
        FeatureItem(key: 'pay_cash', title: 'নগদ ক্যাশ গ্রহণ', description: 'অফিসে সরাসরি ক্যাশ টাকা জমা', moduleKey: 'payment_management', isCore: true),
        FeatureItem(key: 'pay_bkash_nagad', title: 'বিকাশ / নগদ মোবাইল লেনদেন', description: 'এমএফএস ওয়ালেটের মাধ্যমে কিস্তি জমা', moduleKey: 'payment_management'),
        FeatureItem(key: 'pay_bank_transfer', title: 'ব্যাংক ডিপোজিট / BEFTN', description: 'সরাসরি ব্যাংক হিসাবে ট্রান্সফার', moduleKey: 'payment_management'),
      ],
    ),
    ModuleDefinition(
      key: 'employee_management',
      title: 'কর্মকর্তা ও কর্মচারী (Employee Management)',
      icon: '👔',
      description: 'সমিতির স্টাফ, ফিল্ড অফিসার ও বেতন-ভাতা',
      subFeatures: [
        FeatureItem(key: 'emp_field_officer_assign', title: 'সদস্যভিত্তিক মাঠকর্মী নিয়োগ', description: 'নির্দিষ্ট সদস্যের কিস্তি আদায়ের দায়িত্ব', moduleKey: 'employee_management'),
        FeatureItem(key: 'emp_activity_log', title: 'কর্মকর্তার কালেকশন রেকর্ড', description: 'কোন কর্মকর্তা কত টাকা সংগ্রহ করেছেন', moduleKey: 'employee_management'),
      ],
    ),
    ModuleDefinition(
      key: 'collection_management',
      title: 'আদায় ও বকেয়া ট্র্যাকার (Collection Management)',
      icon: '⚠️',
      description: 'মাসিক বকেয়া তালিকা, আদায় হার (%) ও তাগাদা',
      subFeatures: [
        FeatureItem(key: 'coll_due_tracker', title: 'মাসিক বকেয়া ডিউ ট্র্যাকার', description: 'কোন সদস্য কিস্তি পরিশোধ করেননি তার তালিকা', moduleKey: 'collection_management'),
        FeatureItem(key: 'coll_recovery_rate', title: 'কালেকশন আদায়ের শতকরা হার', description: 'শতকরা কতভাগ আদায় সম্পন্ন হয়েছে', moduleKey: 'collection_management'),
        FeatureItem(key: 'coll_whatsapp_reminder', title: 'সরাসরি WhatsApp তাগাদা', description: '১-ক্লিকে বকেয়া সদস্যদের মেসেজ পাঠানো', moduleKey: 'collection_management'),
      ],
    ),
    ModuleDefinition(
      key: 'reports',
      title: 'প্রতিবেদন ও অ্যানালিটিক্স (Reports)',
      icon: '📈',
      description: 'সদস্য প্রতিবেদন, অডিট রিপোর্ট ও মাসিক রিটার্ন',
      subFeatures: [
        FeatureItem(key: 'rep_member_wise', title: 'সদস্যওয়ারি পূর্ণাঙ্গ প্রতিবেদন', description: 'এক নজরে সদস্যের আজীবন লেনদেন', moduleKey: 'reports'),
        FeatureItem(key: 'rep_monthly_audit', title: 'মাসিক অডিট প্রতিবেদন', description: 'সমিতির আনুষ্ঠানিক নিরীক্ষা বিবরণী', moduleKey: 'reports'),
      ],
    ),
    ModuleDefinition(
      key: 'pdf_export',
      title: 'পিডিএফ ও প্রিন্ট (PDF Export)',
      icon: '📄',
      description: 'A4 অফিসিয়াল প্যাডে প্রিন্ট ও পিডিএফ জেনারেশন',
      subFeatures: [
        FeatureItem(key: 'pdf_receipt_print', title: 'মানি রিসিট প্রিন্ট', description: 'কিউআর কোডসহ রসিদ প্রিন্ট', moduleKey: 'pdf_export'),
        FeatureItem(key: 'pdf_notice_print', title: 'অফিসিয়াল নোটিশ প্যাড প্রিন্ট', description: 'সিল-স্বাক্ষরসহ চিঠি প্রিন্ট', moduleKey: 'pdf_export'),
        FeatureItem(key: 'pdf_a4_sheet', title: 'A4 সাইজ শিট প্রিভিউ', description: 'মানসম্মত A4 পেজে ডকুমেন্ট প্রিন্ট', moduleKey: 'pdf_export'),
      ],
    ),
    ModuleDefinition(
      key: 'excel_export',
      title: 'এক্সেল ও সিএসভি রপ্তানি (Excel Export)',
      icon: '📗',
      description: 'সকল লেনদেন ও সদস্য তালিকা CSV/Excel এ ডাউনলোড',
      subFeatures: [
        FeatureItem(key: 'export_csv_utf8', title: 'বাংলা ফন্ট সমর্থিত UTF-8 CSV', description: 'এক্সেল সফটওয়্যারে সরাসরি খোলা যায়', moduleKey: 'excel_export'),
        FeatureItem(key: 'export_due_csv', title: 'বকেয়া তালিকা CSV এক্সপোর্ট', description: 'সকল বকেয়া সদস্যের ডেটা নামানো', moduleKey: 'excel_export'),
      ],
    ),
    ModuleDefinition(
      key: 'notifications',
      title: 'পুশ নোটিফিকেশন (Notifications)',
      icon: '🔔',
      description: 'কিস্তি জমা ও বকেয়া নোটিফিকেশন সতর্কতা',
      subFeatures: [
        FeatureItem(key: 'notif_payment_confirm', title: 'জমা নিশ্চিতকরণ নোটিফিকেশন', description: 'টাকা জমা হওয়ামাত্র সদস্যের ফোনে বার্তা', moduleKey: 'notifications'),
        FeatureItem(key: 'notif_due_alert', title: 'কিস্তির তারিখের পূর্বে সতর্কবার্তা', description: 'মাসের নির্ধারিত তারিখের আগে রিমাইন্ডার', moduleKey: 'notifications'),
      ],
    ),
    ModuleDefinition(
      key: 'announcements',
      title: 'নোটিশ ও রেজুলেশন প্যাড (Announcements)',
      icon: '📜',
      description: 'বার্ষিক সাধারণ সভা (AGM) ও জরুরি সভার নোটিশ',
      subFeatures: [
        FeatureItem(key: 'notice_preset_templates', title: '৬টি অফিসিয়াল প্রিসেট টেমপ্লেট', description: 'AGM, রেজুলেশন ও প্রত্যয়নপত্র প্রিসেট', moduleKey: 'announcements'),
        FeatureItem(key: 'notice_drive_publish', title: 'Google Drive-এ নোটিশ আপলোড', description: 'অনলাইনে নোটিশ শেয়ার ও লিংক তৈরি', moduleKey: 'announcements'),
      ],
    ),
    ModuleDefinition(
      key: 'document_management',
      title: 'ডকুমেন্ট ও ফাইল আর্কাইভ (Document Management)',
      icon: '📁',
      description: 'সদস্যের জাতীয় পরিচয়পত্র ও ছবির ডিজিটাল আর্কাইভ',
      subFeatures: [
        FeatureItem(key: 'doc_kyc_storage', title: 'সদস্য NID ও ছবি স্টোরেজ', description: 'নিরাপদ ক্লাউডে ছবি সংরক্ষণ', moduleKey: 'document_management'),
      ],
    ),
    ModuleDefinition(
      key: 'audit_logs',
      title: 'অডিট লগ ও পরিবর্তন ট্র্যাকার (Audit Logs)',
      icon: '🕵️',
      description: 'কে কখন কোন লেনদেন বা সেটিং পরিবর্তন করেছেন তার অপরিবর্তনযোগ্য রেকর্ড',
      subFeatures: [
        FeatureItem(key: 'audit_immutable_trail', title: 'অপরিবর্তনযোগ্য অডিট হিস্ট্রি', description: 'ডিলিট বা এডিট করার সময় লগ রাখা', moduleKey: 'audit_logs', isCore: true),
      ],
    ),
    ModuleDefinition(
      key: 'dashboard_analytics',
      title: 'ড্যাশবোর্ড অ্যানালিটিক্স (Dashboard Analytics)',
      icon: '📊',
      description: 'রোলভিত্তিক আলাদা ড্যাশবোর্ড ও মেট্রিক কার্ড',
      subFeatures: [
        FeatureItem(key: 'dash_admin_metrics', title: 'এডমিন কেন্দ্রীয় সামারি', description: 'মোট কালেকশন, ক্যাশ ও ব্যাংক স্ট্যাটাস', moduleKey: 'dashboard_analytics'),
        FeatureItem(key: 'dash_member_view', title: 'সদস্যের নিজস্ব ড্যাশবোর্ড', description: 'সদস্য শুধু নিজের সঞ্চয় ও কিস্তি দেখতে পারবেন', moduleKey: 'dashboard_analytics'),
      ],
    ),
    ModuleDefinition(
      key: 'advanced_settings',
      title: 'অ্যাডভান্সড কনফিগারেশন (Advanced Settings)',
      icon: '⚙️',
      description: 'মুদ্রা, বাংলা/ইংরেজি ভাষা, তারিখ ফরম্যাট ও টাইমজোন',
      subFeatures: [
        FeatureItem(key: 'set_currency_bdt', title: 'টাকা (৳) কারেন্সি ফরম্যাটিং', description: 'বাংলাদেশি সংখ্যা ও কথায় লেখার কনভার্টার', moduleKey: 'advanced_settings', isCore: true),
        FeatureItem(key: 'set_multi_theme', title: 'একাধিক থিম কালার (সবুজ/নীল/বেগুনি)', description: 'ব্যবহারকারীর পছন্দের ইন্টারফেস থিম', moduleKey: 'advanced_settings'),
      ],
    ),
    ModuleDefinition(
      key: 'payment_gateways',
      title: 'পেমেন্ট গেটওয়ে ইন্টিগ্রেশন (Payment Gateways)',
      icon: '🌐',
      description: 'ভবিষ্যত অনলাইন গেটওয়ে (bKash PGW, SSLCommerz, Shurjopay)',
      subFeatures: [
        FeatureItem(key: 'pgw_online_checkout', title: 'অনলাইন স্বয়ংক্রিয় জমা', description: 'পেমেন্ট গেটওয়ের মাধ্যমে সরাসরি পরিশোধ', moduleKey: 'payment_gateways'),
      ],
    ),
  ];
}
