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
    ModuleDefinition(
      key: 'workflow_approval',
      title: 'অনুমোদন ও ওয়ার্কফ্লো অটোমেশন (Workflow & Approval)',
      icon: '🔄',
      description: 'মাল্টি-লেভেল অনুমোদন, মেকার-চেকার পলিসি, প্রতিনিধি অর্পণ ও অটোমেশন',
      subFeatures: [
        FeatureItem(key: 'workflow_engine', title: 'ওয়ার্কফ্লো অটোমেশন ইঞ্জিন', description: 'অনুমোদন পাইপলাইন ও স্বয়ংক্রিয় রাউটিং', moduleKey: 'workflow_approval', isCore: true),
        FeatureItem(key: 'workflow_multi_level', title: 'বহুস্তরীয় অনুমোদন', description: 'পদ ও টাকার পরিমাণের ভিত্তিতে বহুস্তরীয় অনুমোদন চেইন', moduleKey: 'workflow_approval'),
        FeatureItem(key: 'workflow_maker_checker', title: 'মেকার-চেকার নিরাপত্তা', description: 'আবেদনকারী কর্তৃক নিজ আবেদন অনুমোদন কঠোরভাবে নিষিদ্ধ', moduleKey: 'workflow_approval'),
        FeatureItem(key: 'workflow_delegation', title: 'অনুমোদন প্রতিনিধি অর্পণ', description: 'অনুপস্থিতিতে অস্থায়ীভাবে অনুমোদন ক্ষমতা হস্তান্তর', moduleKey: 'workflow_approval'),
        FeatureItem(key: 'workflow_escalation', title: 'স্বয়ংক্রিয় এস্কেলেশন ও তাগিদ', description: 'সময়সীমা অতিক্রান্ত হলে উচ্চতর পর্যায়ে অটো-ফরওয়ার্ড', moduleKey: 'workflow_approval'),
      ],
    ),
    ModuleDefinition(
      key: 'saas_billing',
      title: 'সাবস্ক্রিপশন ও কমার্শিয়াল বিলিং (SaaS Billing)',
      icon: '💎',
      description: 'সাবস্ক্রিপশন প্ল্যান, ইনভয়েস, স্বয়ংক্রিয় পেমেন্ট ও রাজস্ব ম্যানেজমেন্ট',
      subFeatures: [
        FeatureItem(key: 'saas_plans', title: 'প্ল্যান প্যাকেজ ও প্রাইসিং', description: 'বেসিক, স্ট্যান্ডার্ড ও প্রিমিয়াম প্ল্যান কনফিগারেশন', moduleKey: 'saas_billing', isCore: true),
        FeatureItem(key: 'saas_invoicing', title: 'স্বয়ংক্রিয় ইনভয়েস ও মেমো', description: 'মাসিক ও বার্ষিক রিনিউয়াল ইনভয়েস জেনারেশন', moduleKey: 'saas_billing'),
        FeatureItem(key: 'saas_payment_gateways', title: 'পেমেন্ট গেটওয়ে ভেরিফিকেশন', description: 'bKash, Nagad ও কার্ড পেমেন্ট স্বয়ংক্রিয় সক্রিয়করণ', moduleKey: 'saas_billing'),
        FeatureItem(key: 'saas_coupons', title: 'ডিসকাউন্ট ও কুপন কোড', description: 'প্রমোশনাল কুপন ও সমিতিভিত্তিক বিশেষ ছাড়', moduleKey: 'saas_billing'),
        FeatureItem(key: 'saas_mrr_analytics', title: 'MRR ও রাজস্ব অ্যানালিটিক্স', description: 'মাসিক পুনরাবৃত্তিমূলক রাজস্ব ও গ্রোথ মেট্রিক্স', moduleKey: 'saas_billing'),
      ],
    ),
  ];
}

/// Convenience aliases and constants for modules and features
class DefaultPlatformModules {
  static List<ModuleDefinition> get modules => MasterFeatureRegistry.allModules;
}

class ModuleKeys {
  static const String society = 'society_management';
  static const String auth = 'authentication';
  static const String users = 'user_management';
  static const String roles = 'role_management';
  static const String permissions = 'permission_management';
  static const String members = 'member_management';
  static const String savings = 'savings_management';
  static const String loans = 'loan_management';
  static const String accounting = 'financial_accounting';
  static const String cash = 'cash_management';
  static const String bank = 'bank_management';
  static const String payments = 'payment_management';
  static const String employees = 'employee_management';
  static const String collections = 'collection_management';
  static const String reports = 'reports';
  static const String pdf = 'pdf_export';
  static const String excel = 'excel_export';
  static const String notifications = 'notifications';
  static const String announcements = 'announcements';
  static const String documents = 'document_management';
  static const String audit = 'audit_logs';
  static const String dashboard = 'dashboard_analytics';
  static const String settings = 'advanced_settings';
  static const String gateways = 'payment_gateways';
  static const String workflow = 'workflow_approval';
  static const String saas = 'saas_billing';
  static const String crm = 'society_crm';
  static const String kyc = 'digital_kyc';
  static const String hr = 'hr_management';
  static const String payroll = 'payroll_management';
  static const String inventory = 'inventory_management';
  static const String assets = 'asset_management';
  static const String procurement = 'procurement_management';
  static const String operations = 'operations_management';
  static const String paymentEcosystem = 'payment_ecosystem';
  static const String bankReconciliation = 'bank_reconciliation';
  static const String qrEngine = 'qr_engine';
  static const String settlementManagement = 'settlement_management';

  // Phase 8: Enterprise AI, Advanced Analytics & BI
  static const String aiAssistant = 'ai_assistant';
  static const String businessIntelligence = 'business_intelligence';
  static const String fraudAnomalyDetection = 'fraud_anomaly_detection';
  static const String predictiveAnalytics = 'predictive_analytics';
  static const String customReportBuilder = 'custom_report_builder';

  // Phase 9: Enterprise Offline-First, Field Operations & Mobile Experience
  static const String offlineMode = 'offline_mode';
  static const String fieldOperations = 'field_operations';
  static const String syncEngine = 'sync_engine';
  static const String deviceManagement = 'device_management';
  static const String cashReconciliation = 'cash_reconciliation';

  // Phase 10: Enterprise Monitoring, DevOps, Backup & Disaster Recovery
  static const String enterpriseMonitoring = 'enterprise_monitoring';
  static const String centralizedLogging = 'centralized_logging';
  static const String alertingNotifications = 'alerting_notifications';
  static const String incidentManagement = 'incident_management';
  static const String automatedBackups = 'automated_backups';
  static const String disasterRecovery = 'disaster_recovery';
  static const String devopsPipeline = 'devops_pipeline';
  static const String maintenanceMode = 'maintenance_mode';

  // Phase 11: Enterprise UI/UX Modernization, Design System & Accessibility
  static const String enterpriseUiModernization = 'enterprise_ui_modernization';
  static const String designSystem = 'design_system';
  static const String themeManagement = 'theme_management';
  static const String responsiveLayouts = 'responsive_layouts';
  static const String accessibilityWcag = 'accessibility_wcag';
  static const String localizationBilingual = 'localization_bilingual';
  static const String globalSearchHub = 'global_search_hub';
  static const String dashboardCustomization = 'dashboard_customization';

  // Phase 12: Enterprise Production Deployment, Launch & Operational Readiness
  static const String enterpriseProductionReadiness = 'enterprise_production_readiness';
  static const String universalPlatformControl = 'universal_platform_control';
  static const String goLiveCertification = 'go_live_certification';
  static const String crossModuleIntegration = 'cross_module_integration';

  // Phase 13: Enterprise Advanced QA, Security Audit & Continuous Testing Engine
  static const String enterpriseQaTesting = 'enterprise_qa_testing';
  static const String continuousTestingEngine = 'continuous_testing_engine';
  static const String securityAuditEngine = 'security_audit_engine';
  static const String qualityGates = 'quality_gates';

  // Phase 14: Enterprise Customer Support, Helpdesk & Service Management Engine
  static const String enterpriseHelpdesk = 'enterprise_helpdesk';
  static const String ticketManagement = 'ticket_management';
  static const String supportAgentManagement = 'support_agent_management';
  static const String slaEscalationEngine = 'sla_escalation_engine';
  static const String liveSupportChat = 'live_support_chat';
  static const String grievanceComplaints = 'grievance_complaints';
  static const String knowledgeBaseSelfService = 'knowledge_base_self_service';
  static const String customerFeedbackCsat = 'customer_feedback_csat';
  static const String supportAutomationNotifications = 'support_automation_notifications';

  // Phase 15: Enterprise API, Developer Portal & Third-Party Integration Ecosystem
  static const String enterpriseApiGateway = 'enterprise_api_gateway';
  static const String developerPortal = 'developer_portal';
  static const String apiKeyManagement = 'api_key_management';
  static const String oauth2Server = 'oauth2_server';
  static const String webhookEngine = 'webhook_engine';
  static const String thirdPartyIntegrations = 'third_party_integrations';
  static const String apiRateLimiting = 'api_rate_limiting';
  static const String apiSandbox = 'api_sandbox';

  // Phase 16: Enterprise White-Label SaaS & Society Customization Engine
  static const String whiteLabelEngine = 'whitelabel_engine';
  static const String societyBranding = 'society_branding';
  static const String customThemes = 'custom_themes';
  static const String customDomains = 'custom_domains';
  static const String documentTemplates = 'document_templates';
  static const String notificationTemplates = 'notification_templates';
  static const String businessConfig = 'business_config';
  static const String whiteLabelEntitlements = 'whitelabel_entitlements';

  // Phase 17: Enterprise Data Warehouse & Advanced Intelligence Platform
  static const String enterpriseDataWarehouse = 'enterprise_data_warehouse';
  static const String dwPipelines = 'dw_pipelines';
  static const String dwFinancialAnalytics = 'dw_financial_analytics';
  static const String dwBiDashboards = 'dw_bi_dashboards';
  static const String dwCrossSocietyBenchmarking = 'dw_cross_society_benchmarking';
  static const String dwDataExportEngine = 'dw_data_export_engine';
  static const String dwArchivalLifecycle = 'dw_archival_lifecycle';
  static const String dwDataGovernance = 'dw_data_governance';

  // Phase 18: Member Super App & Self-Service
  static const String memberSuperApp = 'member_super_app';
  static const String memberOnboardingKyc = 'member_onboarding_kyc';
  static const String memberDigitalCard = 'member_digital_card';
  static const String memberSavingsPortal = 'member_savings_portal';
  static const String memberLoansPortal = 'member_loans_portal';
  static const String memberPaymentsPortal = 'member_payments_portal';
  static const String memberDocumentCenter = 'member_document_center';
  static const String memberServiceRequests = 'member_service_requests';

  // Phase 19: Cooperative Governance, Audit & Regulatory Compliance
  static const String cooperativeGovernance = 'cooperative_governance';
  static const String govBoardCommittees = 'gov_board_committees';
  static const String govMeetingsAgm = 'gov_meetings_agm';
  static const String govResolutions = 'gov_resolutions';
  static const String govElections = 'gov_elections';
  static const String govInternalAudit = 'gov_internal_audit';
  static const String govRegulatoryCompliance = 'gov_regulatory_compliance';
  static const String govComplianceCalendar = 'gov_compliance_calendar';

  // Phase 20: Enterprise Automation & Autonomous Operations
  static const String enterpriseAutomation = 'enterprise_automation';
  static const String autoWorkflows = 'auto_workflows';
  static const String autoTriggers = 'auto_triggers';
  static const String autoActions = 'auto_actions';
  static const String autoScheduler = 'auto_scheduler';
  static const String autoHumanApproval = 'auto_human_approval';
  static const String autoAiAssistant = 'auto_ai_assistant';
  static const String autoMonitoring = 'auto_monitoring';
}

class FeatureKeys {
  static const String loanApplication = 'loan_application';
  static const String loanApproval = 'loan_approval';
  static const String loanDisbursement = 'loan_disbursement';
  static const String loanInterestFlat = 'loan_interest_flat';
  static const String loanInterestReducing = 'loan_interest_reducing';
  static const String loanPartialRepay = 'loan_partial_repay';
  static const String loanPenaltyOverdue = 'loan_penalty_overdue';
  static const String memberAdd = 'member_add';
  static const String memberPassbook = 'member_passbook';
  static const String memberIdCard = 'member_id_card';
  static const String savingsDaily = 'savings_daily';
  static const String savingsDps = 'savings_dps';
  static const String savingsWithdrawal = 'savings_withdrawal';

  // Double-Entry Financial Accounting Keys
  static const String doubleEntry = 'double_entry_accounting';
  static const String chartOfAccounts = 'chart_of_accounts';
  static const String journalEntries = 'journal_entries';
  static const String generalLedger = 'general_ledger';
  static const String trialBalance = 'trial_balance';
  static const String balanceSheet = 'balance_sheet';
  static const String profitAndLoss = 'profit_and_loss';
  static const String cashFlow = 'cash_flow_statement';
  static const String bankReconciliation = 'bank_reconciliation';
  static const String periodClosing = 'financial_period_closing';
  static const String financialAdjustment = 'financial_adjustments';
  static const String reversalTransaction = 'reversal_transactions';

  // Workflow & Approval Keys
  static const String workflowEngine = 'workflow_engine';
  static const String workflowMultiLevel = 'workflow_multi_level';
  static const String workflowMakerChecker = 'workflow_maker_checker';
  static const String workflowDelegation = 'workflow_delegation';
  static const String workflowEscalation = 'workflow_escalation';

  // Button & Action Controls
  static const String actJournalCreate = 'act_journal_create';
  static const String actJournalPost = 'act_journal_post';
  static const String actJournalReverse = 'act_journal_reverse';
  static const String actPeriodClose = 'act_period_close';
  static const String actPeriodReopen = 'act_period_reopen';
  static const String actBankReconcile = 'act_bank_reconcile';

  // Workflow Actions
  static const String actWfSubmit = 'act_wf_submit';
  static const String actWfApprove = 'act_wf_approve';
  static const String actWfReject = 'act_wf_reject';
  static const String actWfReturn = 'act_wf_return';
  static const String actWfDelegate = 'act_wf_delegate';
  static const String actWfEscalate = 'act_wf_escalate';

  // SaaS Commercial Actions
  static const String saasPlans = 'saas_plans';
  static const String saasInvoicing = 'saas_invoicing';
  static const String saasGateways = 'saas_payment_gateways';
  static const String saasCoupons = 'saas_coupons';
  static const String saasAnalytics = 'saas_mrr_analytics';

  // Phase 14: Helpdesk & Support Actions
  static const String actTicketCreate = 'act_ticket_create';
  static const String actTicketAssign = 'act_ticket_assign';
  static const String actTicketResolve = 'act_ticket_resolve';
  static const String actTicketClose = 'act_ticket_close';
  static const String actTicketReopen = 'act_ticket_reopen';
  static const String actComplaintSubmit = 'act_complaint_submit';
  static const String actComplaintInvestigate = 'act_complaint_investigate';
  static const String actKnowledgeArticlePublish = 'act_knowledge_article_publish';
  static const String actFeedbackSubmit = 'act_feedback_submit';

  // Phase 15: API & Integration Actions
  static const String actApiKeyGenerate = 'act_api_key_generate';
  static const String actApiKeyRevoke = 'act_api_key_revoke';
  static const String actOAuthClientRegister = 'act_oauth_client_register';
  static const String actWebhookCreate = 'act_webhook_create';
  static const String actWebhookTest = 'act_webhook_test';
  static const String actIntegrationConnect = 'act_integration_connect';
  static const String actRateLimitUpdate = 'act_rate_limit_update';

  // Phase 16: White-Label & Customization Actions
  static const String actBrandingUpdate = 'act_branding_update';
  static const String actThemePublish = 'act_theme_publish';
  static const String actDomainVerify = 'act_domain_verify';
  static const String actTemplateSave = 'act_template_save';
  static const String actTemplateRollback = 'act_template_rollback';
  static const String actNotificationTemplateTest = 'act_notification_template_test';
  static const String actWhiteLabelRollback = 'act_whitelabel_rollback';

  // Phase 17: Data Warehouse & BI Actions
  static const String actDwPipelineRun = 'act_dw_pipeline_run';
  static const String actDwReconcileVerify = 'act_dw_reconcile_verify';
  static const String actDwBiExport = 'act_dw_bi_export';
  static const String actDwBenchmarkAnalyze = 'act_dw_benchmark_analyze';
  static const String actDwArchiveExecute = 'act_dw_archive_execute';
  static const String actDwRestoreData = 'act_dw_restore_data';
  static const String actDwQualityCheck = 'act_dw_quality_check';

  // Phase 18: Member Super App Actions
  static const String actMemberSelfRegister = 'act_member_self_register';
  static const String actMemberKycUpload = 'act_member_kyc_upload';
  static const String actMemberQrScan = 'act_member_qr_scan';
  static const String actMemberWithdrawalRequest = 'act_member_withdrawal_request';
  static const String actMemberLoanApplication = 'act_member_loan_application';
  static const String actMemberOnlinePay = 'act_member_online_pay';
  static const String actMemberSupportTicket = 'act_member_support_ticket';

  // Phase 19: Cooperative Governance & Compliance Actions
  static const String actGovMeetingCreate = 'act_gov_meeting_create';
  static const String actGovResolutionPass = 'act_gov_resolution_pass';
  static const String actGovAgmNoticePublish = 'act_gov_agm_notice_publish';
  static const String actGovElectionSchedule = 'act_gov_election_schedule';
  static const String actGovAuditFindingLog = 'act_gov_audit_finding_log';
  static const String actGovComplianceFilingSubmit = 'act_gov_compliance_filing_submit';
  static const String actGovDocumentSign = 'act_gov_document_sign';

  // Phase 20: Enterprise Automation Actions
  static const String actAutoWorkflowCreate = 'act_auto_workflow_create';
  static const String actAutoWorkflowRun = 'act_auto_workflow_run';
  static const String actAutoTriggerToggle = 'act_auto_trigger_toggle';
  static const String actAutoActionExecute = 'act_auto_action_execute';
  static const String actAutoApprovalDecide = 'act_auto_approval_decide';
  static const String actAutoRetryTrigger = 'act_auto_retry_trigger';
  static const String actAutoLogExport = 'act_auto_log_export';
}
