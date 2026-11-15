// lib/services/white_label_customization_service.dart
// Phase 16: Enterprise White-Label SaaS & Society Customization Engine Service
// Centralized tenant branding, theme validation, domain verification, and document template engine

import 'dart:convert';
import 'dart:math';
import '../models/white_label_customization_model.dart';

class WhiteLabelCustomizationService {
  static final WhiteLabelCustomizationService _instance = WhiteLabelCustomizationService._internal();
  factory WhiteLabelCustomizationService() => _instance;
  WhiteLabelCustomizationService._internal() {
    _initDefaultSocietyData();
  }

  // In-memory data store for testing and offline execution
  final Map<String, SocietyBrandingModel> _brandingMap = {};
  final Map<String, List<SocietyThemeConfigModel>> _themeVersionHistory = {};
  final Map<String, SocietyThemeConfigModel> _activeThemeMap = {};
  final List<CustomDomainModel> _customDomains = [];
  final List<DocumentTemplateModel> _documentTemplates = [];
  final List<NotificationTemplateModel> _notificationTemplates = [];
  final Map<String, SocietyBusinessConfigModel> _businessConfigMap = {};
  final Map<String, WhiteLabelEntitlementModel> _entitlementsMap = {};
  final List<CustomizationAuditLogModel> _auditLogs = [];
  SuperAdminWhiteLabelMasterConfig _masterConfig = const SuperAdminWhiteLabelMasterConfig();

  void _initDefaultSocietyData() {
    const defaultSocietyId = 'SOMITI-001';

    // 1. Pre-seeded Society Branding
    _brandingMap[defaultSocietyId] = SocietyBrandingModel(
      societyId: defaultSocietyId,
      orgNameBn: 'স্বপ্ন ছোঁয়া ঐক্য সমিতি',
      orgNameEn: 'Swapno Chowa Oikya Somiti',
      shortName: 'স্বপ্ন ছোঁয়া',
      tagline: 'ছোট সঞ্চয়, বড় স্বপ্ন, আলোকিত ভবিষ্যৎ।',
      establishedYear: '২০২৬',
      registrationNumber: 'রেজি-০৯৮/২০২৬-ঢাকা',
      address: 'মিরপুর-১০, ঢাকা-১২১৬',
      officialPhone: '01711-223344',
      officialEmail: 'info@swapnochowa.org',
      websiteUrl: 'https://swapnochowa.somiti.app',
      logoUrl: 'assets/images/logo.png',
      altLogoUrl: 'assets/images/logo_white.png',
      faviconUrl: 'assets/icons/favicon.ico',
      watermarkText: 'স্মার্ট সমিতি • অনুমোদিত ডিজিটাল ভাউচার • VERIFIED',
      signatureSealUrls: [
        'assets/images/cashier_seal.png',
        'assets/images/president_seal.png',
        'assets/images/official_central_seal.png'
      ],
      loginBannerUrl: 'assets/images/login_bg.jpg',
      updatedAt: DateTime.now(),
      updatedBy: 'Sajjad Hossain (Tech Lead)',
    );

    // 2. Pre-seeded Active Theme
    const initialTheme = SocietyThemeConfigModel(
      societyId: defaultSocietyId,
      primaryColor: '#059669', // Emerald Green
      secondaryColor: '#DC2626', // Crimson Red
      accentColor: '#D97706', // Amber Gold
      backgroundColor: '#F8FAFC',
      surfaceColor: '#FFFFFF',
      textPrimaryColor: '#0F172A',
      textSecondaryColor: '#64748B',
      isDarkMode: false,
      fontPreference: 'Hind Siliguri',
      borderRadiusPreset: 'smooth',
      contrastRatio: 5.2,
      isPublished: true,
      version: 1,
    );
    _activeThemeMap[defaultSocietyId] = initialTheme;
    _themeVersionHistory[defaultSocietyId] = [initialTheme];

    // 3. Pre-seeded Custom Domains
    _customDomains.addAll([
      CustomDomainModel(
        id: 'dom_01',
        societyId: defaultSocietyId,
        domainName: 'portal.swapnochowa.org',
        subdomain: 'swapnochowa.somiti.app',
        verificationToken: 'somiti-verify=v=1;t=9a8f4c120e',
        cnameRecord: 'custom.somiti.app',
        txtRecord: '_somiti-challenge.portal',
        status: DomainVerificationStatus.verified,
        sslStatus: DomainSslStatus.issued,
        verifiedAt: DateTime.now().subtract(const Duration(days: 30)),
        lastHealthCheck: DateTime.now(),
      ),
      CustomDomainModel(
        id: 'dom_02',
        societyId: defaultSocietyId,
        domainName: 'swapnochowa.somiti.app',
        subdomain: 'swapnochowa.somiti.app',
        verificationToken: 'somiti-platform-subdomain',
        cnameRecord: 'ingress.somiti.app',
        txtRecord: '_subdomain-active',
        status: DomainVerificationStatus.verified,
        sslStatus: DomainSslStatus.issued,
        verifiedAt: DateTime.now().subtract(const Duration(days: 60)),
        lastHealthCheck: DateTime.now(),
      ),
    ]);

    // 4. Pre-seeded 12 Document Templates
    _documentTemplates.addAll([
      DocumentTemplateModel(
        id: 'tmpl_cert',
        societyId: defaultSocietyId,
        templateType: DocumentTemplateType.membershipCertificate,
        titleBn: 'সমবায় সদস্য সনদপত্র',
        titleEn: 'Cooperative Membership Certificate',
        headerHtml: '<div class="header"><h1>{{societyName}}</h1><p>{{tagline}}</p></div>',
        footerHtml: '<div class="footer"><p>রেজিস্ট্রেশন: {{regNo}} | স্মারক: {{memoNo}}</p></div>',
        bodyTemplate: 'এই মর্মে প্রত্যয়ন করা যাচ্ছে যে, জনাব/জনাবা {{memberName}}, পিতা/স্বামী: {{guardianName}}, সদস্য নং: {{memberId}}, আমাদের সমিতির একজন নিয়মিত ও সম্মানিত সদস্য।',
        availablePlaceholders: ['{{societyName}}', '{{tagline}}', '{{memberName}}', '{{guardianName}}', '{{memberId}}', '{{joinDate}}'],
        updatedAt: DateTime.now(),
      ),
      DocumentTemplateModel(
        id: 'tmpl_idcard',
        societyId: defaultSocietyId,
        templateType: DocumentTemplateType.memberIdCard,
        titleBn: 'স্মার্ট ডিজিটাল সদস্য পরিচয়পত্র',
        titleEn: 'Smart Digital Member ID Card',
        layoutType: 'SLIP_55MM',
        headerHtml: '<div class="id-header"><h3>{{societyName}}</h3></div>',
        footerHtml: '<div class="id-footer"><img src="{{qrCodeUrl}}" /></div>',
        bodyTemplate: 'নাম: {{memberName}}\nসদস্য নং: {{memberId}}\nমোবাইল: {{phone}}\nরক্তের গ্রুপ: {{bloodGroup}}',
        availablePlaceholders: ['{{societyName}}', '{{memberName}}', '{{memberId}}', '{{phone}}', '{{bloodGroup}}', '{{qrCodeUrl}}'],
        updatedAt: DateTime.now(),
      ),
      DocumentTemplateModel(
        id: 'tmpl_savings_receipt',
        societyId: defaultSocietyId,
        templateType: DocumentTemplateType.savingsReceipt,
        titleBn: 'সঞ্চয় কিস্তি জমার মানি রিসিট',
        titleEn: 'Savings Deposit Money Receipt',
        layoutType: 'POS_80MM',
        headerHtml: '<div class="rcpt-header"><h2>{{societyName}}</h2><p>{{address}}</p></div>',
        footerHtml: '<div class="rcpt-footer"><p>ধন্যবাদ। সঞ্চয়ই সমৃদ্ধির চাবিকাঠি।</p></div>',
        bodyTemplate: 'রসিদ নং: {{receiptNo}}\nতারিখ: {{date}}\nসদস্য: {{memberName}} ({{memberId}})\nজমা পরিমাণ: ৳ {{amount}}\nক্যাশ ব্যালেন্স: ৳ {{currentBalance}}',
        availablePlaceholders: ['{{societyName}}', '{{address}}', '{{receiptNo}}', '{{date}}', '{{memberName}}', '{{memberId}}', '{{amount}}', '{{currentBalance}}'],
        updatedAt: DateTime.now(),
      ),
      DocumentTemplateModel(
        id: 'tmpl_loan_receipt',
        societyId: defaultSocietyId,
        templateType: DocumentTemplateType.loanReceipt,
        titleBn: 'ঋণ কিস্তি আদায়ের ভাউচার',
        titleEn: 'Loan Installment Repayment Receipt',
        layoutType: 'A4',
        headerHtml: '<div class="loan-header"><h2>{{societyName}}</h2></div>',
        footerHtml: '<div class="loan-footer"><p>স্বাক্ষর: ক্যাশিয়ার ও সভাপতি</p></div>',
        bodyTemplate: 'ঋণ হিসাব: {{loanId}}\nসদস্য: {{memberName}}\nকিস্তি পরিমাণ: ৳ {{amount}}\nঅবশিষ্ট ঋণ বকেয়া: ৳ {{remainingPrincipal}}',
        availablePlaceholders: ['{{societyName}}', '{{loanId}}', '{{memberName}}', '{{amount}}', '{{remainingPrincipal}}'],
        updatedAt: DateTime.now(),
      ),
      DocumentTemplateModel(
        id: 'tmpl_notice',
        societyId: defaultSocietyId,
        templateType: DocumentTemplateType.officialNotice,
        titleBn: 'জরুরি সাধারণ সভা ও দাপ্তরিক নোটিশ',
        titleEn: 'Official Notice Pad',
        layoutType: 'A4',
        headerHtml: '<div class="notice-head"><h2>{{societyName}}</h2><p>স্মারক: {{memoNo}} | তারিখ: {{date}}</p></div>',
        footerHtml: '<div class="notice-foot"><p>আদেশক্রমে: কার্যনির্বাহী কমিটি</p></div>',
        bodyTemplate: 'বিষয়: {{subject}}\n\nসম্মানিত সদস্যবৃন্দ,\n{{noticeBody}}\n\nসকলকে উপস্থিত থাকার জন্য বিশেষভাবে অনুরোধ করা হলো।',
        availablePlaceholders: ['{{societyName}}', '{{memoNo}}', '{{date}}', '{{subject}}', '{{noticeBody}}'],
        updatedAt: DateTime.now(),
      ),
      DocumentTemplateModel(
        id: 'tmpl_cashbook',
        societyId: defaultSocietyId,
        templateType: DocumentTemplateType.cashbookReport,
        titleBn: 'মাসিক ক্যাশ বুক ও হিসাব বহি',
        titleEn: 'Monthly Cashbook Ledger Report',
        layoutType: 'A4',
        headerHtml: '<div class="cashbook-head"><h2>{{societyName}} - ক্যাশ বহি</h2></div>',
        footerHtml: '<div class="cashbook-foot"><p>নিরীক্ষক স্বাক্ষর</p></div>',
        bodyTemplate: 'মাস: {{month}} {{year}}\nমোট জমা (ডেবিট): ৳ {{totalDebit}}\nমোট খরচ (ক্রেডিট): ৳ {{totalCredit}}\nসমাপনী ব্যালেন্স: ৳ {{closingBalance}}',
        availablePlaceholders: ['{{societyName}}', '{{month}}', '{{year}}', '{{totalDebit}}', '{{totalCredit}}', '{{closingBalance}}'],
        updatedAt: DateTime.now(),
      ),
    ]);

    // 5. Pre-seeded Notification Templates
    _notificationTemplates.addAll([
      const NotificationTemplateModel(
        id: 'notif_01',
        societyId: defaultSocietyId,
        channel: NotificationChannelType.sms,
        eventTrigger: 'deposit.confirmed',
        templateContentBn: 'প্রিয় {{memberName}}, আপনার {{societyName}}-এর হিসাবে ৳{{amount}} কিস্তি সফলভাবে জমা হয়েছে। রসিদ নং: {{receiptNo}}। বর্তমান সঞ্চয়: ৳{{totalSavings}}।',
        templateContentEn: 'Dear {{memberName}}, BDT {{amount}} deposit received for {{societyName}}. Receipt: {{receiptNo}}. Current Savings: BDT {{totalSavings}}.',
        approvedVariables: ['{{memberName}}', '{{societyName}}', '{{amount}}', '{{receiptNo}}', '{{totalSavings}}'],
        isEnabled: true,
      ),
      const NotificationTemplateModel(
        id: 'notif_02',
        societyId: defaultSocietyId,
        channel: NotificationChannelType.inApp,
        eventTrigger: 'loan.disbursed',
        templateContentBn: 'অভিনন্দন {{memberName}}! আপনার ৳{{loanAmount}} ঋণ আবেদন অনুমোদিত ও বিতরণ করা হয়েছে। প্রথম কিস্তির তারিখ: {{firstDueDate}}।',
        templateContentEn: 'Congratulations {{memberName}}! Your loan of BDT {{loanAmount}} has been disbursed. First due date: {{firstDueDate}}.',
        subjectLine: 'ঋণ বিতরণ নিশ্চিতকরণ',
        approvedVariables: ['{{memberName}}', '{{loanAmount}}', '{{firstDueDate}}'],
        isEnabled: true,
      ),
      const NotificationTemplateModel(
        id: 'notif_03',
        societyId: defaultSocietyId,
        channel: NotificationChannelType.sms,
        eventTrigger: 'installment.overdue',
        templateContentBn: 'সম্মানিত {{memberName}}, আপনার চলতি মাসের কিস্তি বকেয়া রয়েছে। বিলম্ব ফি এড়াতে দ্রুত পরিশোধ করার অনুরোধ করা হলো। {{societyName}}',
        templateContentEn: 'Dear {{memberName}}, your installment is overdue. Please settle promptly to avoid late fees. {{societyName}}',
        approvedVariables: ['{{memberName}}', '{{societyName}}'],
        isEnabled: true,
      ),
    ]);

    // 6. Pre-seeded Society Business Config
    _businessConfigMap[defaultSocietyId] = const SocietyBusinessConfigModel(
      societyId: defaultSocietyId,
      fiscalYearStartMonth: 7,
      receiptPrefix: 'RCPT',
      memberIdPrefix: 'MEM',
      loanPrefix: 'LN',
      currencySymbol: '৳',
      dateFormat: 'DD/MM/YYYY',
      timeZone: 'Asia/Dhaka',
      languagePreference: 'bn',
      defaultDashboardView: 'modern',
    );

    // 7. Pre-seeded Entitlements (Enterprise Tier)
    _entitlementsMap[defaultSocietyId] = WhiteLabelEntitlementModel.forPlan(WhiteLabelTier.enterprise);
  }

  // --- Branding Methods ---

  SocietyBrandingModel getBranding(String societyId) {
    return _brandingMap[societyId] ?? _brandingMap['SOMITI-001']!;
  }

  bool updateBranding(String societyId, SocietyBrandingModel newBranding, String userId) {
    if (!_masterConfig.isGlobalWhiteLabelEnabled) return false;

    final oldState = _brandingMap[societyId]?.toMap() ?? {};
    _brandingMap[societyId] = newBranding;

    _auditLogs.add(CustomizationAuditLogModel(
      id: 'aud_${DateTime.now().millisecondsSinceEpoch}',
      societyId: societyId,
      actionType: 'BRANDING_UPDATE',
      targetEntity: 'society_branding',
      changedByUserId: userId,
      userRole: 'ADMIN',
      previousState: oldState,
      newState: newBranding.toMap(),
      timestamp: DateTime.now(),
    ));

    return true;
  }

  // --- Theme Methods ---

  SocietyThemeConfigModel getTheme(String societyId) {
    return _activeThemeMap[societyId] ?? _activeThemeMap['SOMITI-001']!;
  }

  bool updateTheme(String societyId, SocietyThemeConfigModel newTheme, String userId) {
    if (!_masterConfig.isThemeEngineEnabled) return false;

    // Check WCAG AA contrast ratio safety (must be >= 4.5 for text readability)
    if (newTheme.contrastRatio < 4.5) {
      throw ArgumentError('থিম কালার বৈসাদৃশ্য (Contrast Ratio) খুব কম! অ্যাক্সেসিবিলিটি বজায় রাখতে ন্যূনতম ৪.৫ অনুপাত আবশ্যক।');
    }

    final oldState = _activeThemeMap[societyId]?.toMap() ?? {};
    final nextVersion = (_activeThemeMap[societyId]?.version ?? 1) + 1;

    final updated = SocietyThemeConfigModel(
      societyId: societyId,
      primaryColor: newTheme.primaryColor,
      secondaryColor: newTheme.secondaryColor,
      accentColor: newTheme.accentColor,
      backgroundColor: newTheme.backgroundColor,
      surfaceColor: newTheme.surfaceColor,
      textPrimaryColor: newTheme.textPrimaryColor,
      textSecondaryColor: newTheme.textSecondaryColor,
      isDarkMode: newTheme.isDarkMode,
      fontPreference: newTheme.fontPreference,
      borderRadiusPreset: newTheme.borderRadiusPreset,
      contrastRatio: newTheme.contrastRatio,
      isPublished: true,
      version: nextVersion,
    );

    _activeThemeMap[societyId] = updated;
    _themeVersionHistory.putIfAbsent(societyId, () => []).add(updated);

    _auditLogs.add(CustomizationAuditLogModel(
      id: 'aud_${DateTime.now().millisecondsSinceEpoch}',
      societyId: societyId,
      actionType: 'THEME_PUBLISH',
      targetEntity: 'society_themes',
      changedByUserId: userId,
      userRole: 'ADMIN',
      previousState: oldState,
      newState: updated.toMap(),
      timestamp: DateTime.now(),
    ));

    return true;
  }

  bool rollbackTheme(String societyId, String userId) {
    final history = _themeVersionHistory[societyId];
    if (history == null || history.length < 2) return false;

    history.removeLast(); // Remove current
    final previousTheme = history.last;
    _activeThemeMap[societyId] = previousTheme;

    _auditLogs.add(CustomizationAuditLogModel(
      id: 'aud_${DateTime.now().millisecondsSinceEpoch}',
      societyId: societyId,
      actionType: 'ROLLBACK',
      targetEntity: 'society_themes',
      changedByUserId: userId,
      userRole: 'ADMIN',
      previousState: {},
      newState: previousTheme.toMap(),
      timestamp: DateTime.now(),
    ));

    return true;
  }

  // --- Custom Domain Methods ---

  List<CustomDomainModel> getDomains(String societyId) {
    return _customDomains.where((d) => d.societyId == societyId).toList();
  }

  CustomDomainModel registerCustomDomain(String societyId, String domainName, String userId) {
    final entitlement = getEntitlement(societyId);
    if (!entitlement.canUseCustomDomain) {
      throw StateError('আপনার বর্তমান সাবস্ক্রিপশন প্ল্যানে কাস্টম ডোমেন সুবিধা অন্তর্ভুক্ত নেই। এন্টারপ্রাইজ প্ল্যানে আপগ্রেড করুন।');
    }

    final existing = _customDomains.where((d) => d.societyId == societyId).length;
    if (existing >= entitlement.maxCustomDomains) {
      throw StateError('সর্বোচ্চ অনুমোদিত ডোমেনের সংখ্যা (${entitlement.maxCustomDomains}টি) ইতিমধ্যে পূর্ণ হয়েছে।');
    }

    final randomToken = 'somiti-verify=v=1;t=${Random().nextInt(900000) + 100000}';
    final newDomain = CustomDomainModel(
      id: 'dom_${DateTime.now().millisecondsSinceEpoch}',
      societyId: societyId,
      domainName: domainName.toLowerCase().trim(),
      subdomain: domainName.split('.').first + '.somiti.app',
      verificationToken: randomToken,
      cnameRecord: 'custom.somiti.app',
      txtRecord: '_somiti-challenge.${domainName.split('.').first}',
      status: DomainVerificationStatus.pending,
      sslStatus: DomainSslStatus.provisioning,
      lastHealthCheck: DateTime.now(),
    );

    _customDomains.add(newDomain);
    return newDomain;
  }

  bool verifyDomainDns(String domainId) {
    final domain = _customDomains.firstWhere((d) => d.id == domainId, orElse: () => throw ArgumentError('ডোমেন পাওয়া যায়নি'));
    
    // Simulate DNS verification handshake
    final updated = CustomDomainModel(
      id: domain.id,
      societyId: domain.societyId,
      domainName: domain.domainName,
      subdomain: domain.subdomain,
      verificationToken: domain.verificationToken,
      cnameRecord: domain.cnameRecord,
      txtRecord: domain.txtRecord,
      status: DomainVerificationStatus.verified,
      sslStatus: DomainSslStatus.issued,
      verifiedAt: DateTime.now(),
      lastHealthCheck: DateTime.now(),
    );

    final idx = _customDomains.indexWhere((d) => d.id == domainId);
    _customDomains[idx] = updated;
    return true;
  }

  // --- Document Template Methods ---

  List<DocumentTemplateModel> getDocumentTemplates(String societyId) {
    return _documentTemplates.where((t) => t.societyId == societyId).toList();
  }

  String renderDocument(String templateId, Map<String, dynamic> data) {
    final template = _documentTemplates.firstWhere((t) => t.id == templateId, orElse: () => throw ArgumentError('টেমপ্লেট পাওয়া যায়নি'));
    String renderedBody = template.bodyTemplate;

    data.forEach((key, val) {
      renderedBody = renderedBody.replaceAll(key, val.toString());
    });

    return renderedBody;
  }

  // --- Notification Template Methods ---

  List<NotificationTemplateModel> getNotificationTemplates(String societyId) {
    return _notificationTemplates.where((n) => n.societyId == societyId).toList();
  }

  String renderNotification(String eventTrigger, NotificationChannelType channel, Map<String, dynamic> variables) {
    final template = _notificationTemplates.firstWhere(
      (n) => n.eventTrigger == eventTrigger && n.channel == channel && n.isEnabled,
      orElse: () => throw ArgumentError('সক্রিয় নোটিফিকেশন টেমপ্লেট পাওয়া যায়নি'),
    );

    String message = template.templateContentBn;
    variables.forEach((key, val) {
      message = message.replaceAll(key, val.toString());
    });

    return message;
  }

  // --- Entitlements & Business Config ---

  WhiteLabelEntitlementModel getEntitlement(String societyId) {
    return _entitlementsMap[societyId] ?? WhiteLabelEntitlementModel.forPlan(WhiteLabelTier.starter);
  }

  SocietyBusinessConfigModel getBusinessConfig(String societyId) {
    return _businessConfigMap[societyId] ?? _businessConfigMap['SOMITI-001']!;
  }

  // --- Super Admin Universal Policy Controls ---

  SuperAdminWhiteLabelMasterConfig getMasterConfig() => _masterConfig;

  void updateSuperAdminPolicy(String policyKey, bool isEnabled) {
    if (policyKey == 'isTenantIsolationEnforced') {
      throw UnsupportedError('🔒 এটি একটি নন-নেগোশিয়েবল সিকিউরিটি ইনভ্যারিয়েন্ট! টেন্যান্ট আইসোলেশন ও ডেটা সুরক্ষা বন্ধ করা সম্পূর্ণ নিষিদ্ধ।');
    }

    _masterConfig = SuperAdminWhiteLabelMasterConfig(
      isGlobalWhiteLabelEnabled: policyKey == 'isGlobalWhiteLabelEnabled' ? isEnabled : _masterConfig.isGlobalWhiteLabelEnabled,
      isTenantIsolationEnforced: true, // Immutable invariant
      isThemeEngineEnabled: policyKey == 'isThemeEngineEnabled' ? isEnabled : _masterConfig.isThemeEngineEnabled,
      isCustomDomainSystemEnabled: policyKey == 'isCustomDomainSystemEnabled' ? isEnabled : _masterConfig.isCustomDomainSystemEnabled,
      isTemplateEngineEnabled: policyKey == 'isTemplateEngineEnabled' ? isEnabled : _masterConfig.isTemplateEngineEnabled,
      isNotificationTemplateEnabled: policyKey == 'isNotificationTemplateEnabled' ? isEnabled : _masterConfig.isNotificationTemplateEnabled,
      isNativeBuildWorkflowEnabled: policyKey == 'isNativeBuildWorkflowEnabled' ? isEnabled : _masterConfig.isNativeBuildWorkflowEnabled,
      maxBrandingAssetSizeMb: _masterConfig.maxBrandingAssetSizeMb,
    );
  }

  List<CustomizationAuditLogModel> getAuditLogs(String societyId) {
    return _auditLogs.where((l) => l.societyId == societyId).toList();
  }
}
