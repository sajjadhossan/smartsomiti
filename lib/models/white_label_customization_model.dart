// lib/models/white_label_customization_model.dart
// Phase 16: Enterprise White-Label SaaS & Society Customization Engine
// Complete data models for branding, custom themes, domains, document & notification templates

import 'dart:convert';

/// Status of custom domain ownership verification
enum DomainVerificationStatus {
  pending,
  verified,
  suspended,
  failed;

  String get labelBn {
    switch (this) {
      case DomainVerificationStatus.pending: return 'যাচাইকরণ অপেক্ষমাণ';
      case DomainVerificationStatus.verified: return 'সফলভাবে ভেরিফাইড';
      case DomainVerificationStatus.suspended: return 'স্থগিতকৃত (Suspended)';
      case DomainVerificationStatus.failed: return 'যাচাই ব্যর্থ';
    }
  }

  static DomainVerificationStatus fromString(String val) {
    return DomainVerificationStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => DomainVerificationStatus.pending,
    );
  }
}

/// SSL/TLS Certificate Provisioning Status
enum DomainSslStatus {
  provisioning,
  issued,
  expired,
  failed;

  String get labelBn {
    switch (this) {
      case DomainSslStatus.provisioning: return 'সার্টিফিকেট প্রস্তুত হচ্ছে...';
      case DomainSslStatus.issued: return 'TLS 1.3 সুরক্ষিত (Issued)';
      case DomainSslStatus.expired: return 'মেয়াদোত্তীর্ণ';
      case DomainSslStatus.failed: return 'ইস্যু ব্যর্থ';
    }
  }

  static DomainSslStatus fromString(String val) {
    return DomainSslStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => DomainSslStatus.provisioning,
    );
  }
}

/// 12 Approved Enterprise Document Template Types
enum DocumentTemplateType {
  membershipCertificate,
  memberIdCard,
  savingsReceipt,
  loanReceipt,
  loanApprovalLetter,
  loanStatement,
  savingsStatement,
  paymentReceipt,
  cashbookReport,
  financialStatement,
  officialNotice,
  resolutionLetter;

  String get labelBn {
    switch (this) {
      case DocumentTemplateType.membershipCertificate: return 'সমবায় সদস্য সনদপত্র';
      case DocumentTemplateType.memberIdCard: return 'স্মার্ট ডিজিটাল সদস্য পরিচয়পত্র';
      case DocumentTemplateType.savingsReceipt: return 'সঞ্চয় কিস্তি জমার মানি রিসিট';
      case DocumentTemplateType.loanReceipt: return 'ঋণ কিস্তি আদায়ের ভাউচার';
      case DocumentTemplateType.loanApprovalLetter: return 'ঋণ মঞ্জুরি ও অনুমোদন পত্র';
      case DocumentTemplateType.loanStatement: return 'ঋণের পূর্ণাঙ্গ কিস্তি ও বকেয়া বিবরণী';
      case DocumentTemplateType.savingsStatement: return 'সদস্যের মাসিক সঞ্চয় ও ব্যালেন্স বিবরণী';
      case DocumentTemplateType.paymentReceipt: return 'সাধারণ ডিজিটাল পেমেন্ট রিসিট';
      case DocumentTemplateType.cashbookReport: return 'মাসিক ক্যাশ বুক ও হিসাব বহি';
      case DocumentTemplateType.financialStatement: return 'আর্থিক নিরীক্ষা ও ব্যালেন্স শিট';
      case DocumentTemplateType.officialNotice: return 'জরুরি সাধারণ সভা ও দাপ্তরিক নোটিশ';
      case DocumentTemplateType.resolutionLetter: return 'কার্যনির্বাহী কমিটির রেজুলেশন কপি';
    }
  }

  static DocumentTemplateType fromString(String val) {
    return DocumentTemplateType.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => DocumentTemplateType.officialNotice,
    );
  }
}

/// Multi-Channel Notification Channels
enum NotificationChannelType {
  inApp,
  sms,
  email,
  push;

  String get labelBn {
    switch (this) {
      case NotificationChannelType.inApp: return 'ইন-অ্যাপ পুশ নোটিফিকেশন';
      case NotificationChannelType.sms: return 'মোবাইল বাংলা এসএমএস';
      case NotificationChannelType.email: return 'অফিসিয়াল ইমেইল নোটিফিকেশন';
      case NotificationChannelType.push: return 'ওয়েব ও মোবাইল পুশ বার্তা';
    }
  }

  static NotificationChannelType fromString(String val) {
    return NotificationChannelType.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => NotificationChannelType.inApp,
    );
  }
}

/// White-Label Subscription Tier Availability
enum WhiteLabelTier {
  starter,
  standard,
  enterprise,
  customGov;

  String get labelBn {
    switch (this) {
      case WhiteLabelTier.starter: return 'স্টার্টার প্ল্যান (বেসিক)';
      case WhiteLabelTier.standard: return 'স্ট্যান্ডার্ড প্ল্যান';
      case WhiteLabelTier.enterprise: return 'এন্টারপ্রাইজ প্ল্যান (সম্পূর্ণ)';
      case WhiteLabelTier.customGov: return 'কাস্টম সরকারি / এপেক্স সমিতি';
    }
  }

  static WhiteLabelTier fromString(String val) {
    return WhiteLabelTier.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => WhiteLabelTier.starter,
    );
  }
}

/// Society Branding Configuration Model
class SocietyBrandingModel {
  final String societyId;
  final String orgNameBn;
  final String orgNameEn;
  final String shortName;
  final String tagline;
  final String establishedYear;
  final String registrationNumber;
  final String address;
  final String officialPhone;
  final String officialEmail;
  final String? websiteUrl;
  final String logoUrl;
  final String? altLogoUrl;
  final String? faviconUrl;
  final String? watermarkText;
  final List<String> signatureSealUrls;
  final String? loginBannerUrl;
  final DateTime updatedAt;
  final String updatedBy;

  const SocietyBrandingModel({
    required this.societyId,
    required this.orgNameBn,
    required this.orgNameEn,
    required this.shortName,
    required this.tagline,
    required this.establishedYear,
    required this.registrationNumber,
    required this.address,
    required this.officialPhone,
    required this.officialEmail,
    this.websiteUrl,
    required this.logoUrl,
    this.altLogoUrl,
    this.faviconUrl,
    this.watermarkText,
    this.signatureSealUrls = const [],
    this.loginBannerUrl,
    required this.updatedAt,
    required this.updatedBy,
  });

  Map<String, dynamic> toMap() => {
    'societyId': societyId,
    'orgNameBn': orgNameBn,
    'orgNameEn': orgNameEn,
    'shortName': shortName,
    'tagline': tagline,
    'establishedYear': establishedYear,
    'registrationNumber': registrationNumber,
    'address': address,
    'officialPhone': officialPhone,
    'officialEmail': officialEmail,
    'websiteUrl': websiteUrl,
    'logoUrl': logoUrl,
    'altLogoUrl': altLogoUrl,
    'faviconUrl': faviconUrl,
    'watermarkText': watermarkText,
    'signatureSealUrls': signatureSealUrls,
    'loginBannerUrl': loginBannerUrl,
    'updatedAt': updatedAt.toIso8601String(),
    'updatedBy': updatedBy,
  };

  factory SocietyBrandingModel.fromMap(Map<String, dynamic> map) => SocietyBrandingModel(
    societyId: map['societyId'] ?? '',
    orgNameBn: map['orgNameBn'] ?? '',
    orgNameEn: map['orgNameEn'] ?? '',
    shortName: map['shortName'] ?? '',
    tagline: map['tagline'] ?? '',
    establishedYear: map['establishedYear'] ?? '',
    registrationNumber: map['registrationNumber'] ?? '',
    address: map['address'] ?? '',
    officialPhone: map['officialPhone'] ?? '',
    officialEmail: map['officialEmail'] ?? '',
    websiteUrl: map['websiteUrl'],
    logoUrl: map['logoUrl'] ?? '',
    altLogoUrl: map['altLogoUrl'],
    faviconUrl: map['faviconUrl'],
    watermarkText: map['watermarkText'],
    signatureSealUrls: List<String>.from(map['signatureSealUrls'] ?? []),
    loginBannerUrl: map['loginBannerUrl'],
    updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
    updatedBy: map['updatedBy'] ?? '',
  );
}

/// Society Custom Theme Configuration Model
class SocietyThemeConfigModel {
  final String societyId;
  final String primaryColor;
  final String secondaryColor;
  final String accentColor;
  final String backgroundColor;
  final String surfaceColor;
  final String textPrimaryColor;
  final String textSecondaryColor;
  final bool isDarkMode;
  final String fontPreference; // Hind Siliguri, SolaimanLipi, Inter
  final String borderRadiusPreset; // rounded, smooth, sharp
  final double contrastRatio; // WCAG AA Compliance (e.g. 4.5+)
  final bool isPublished;
  final int version;

  const SocietyThemeConfigModel({
    required this.societyId,
    this.primaryColor = '#059669', // Emerald Green
    this.secondaryColor = '#DC2626', // Crimson Red
    this.accentColor = '#D97706', // Amber Gold
    this.backgroundColor = '#F8FAFC',
    this.surfaceColor = '#FFFFFF',
    this.textPrimaryColor = '#0F172A',
    this.textSecondaryColor = '#64748B',
    this.isDarkMode = false,
    this.fontPreference = 'Hind Siliguri',
    this.borderRadiusPreset = 'smooth',
    this.contrastRatio = 5.2,
    this.isPublished = true,
    this.version = 1,
  });

  Map<String, dynamic> toMap() => {
    'societyId': societyId,
    'primaryColor': primaryColor,
    'secondaryColor': secondaryColor,
    'accentColor': accentColor,
    'backgroundColor': backgroundColor,
    'surfaceColor': surfaceColor,
    'textPrimaryColor': textPrimaryColor,
    'textSecondaryColor': textSecondaryColor,
    'isDarkMode': isDarkMode,
    'fontPreference': fontPreference,
    'borderRadiusPreset': borderRadiusPreset,
    'contrastRatio': contrastRatio,
    'isPublished': isPublished,
    'version': version,
  };

  factory SocietyThemeConfigModel.fromMap(Map<String, dynamic> map) => SocietyThemeConfigModel(
    societyId: map['societyId'] ?? '',
    primaryColor: map['primaryColor'] ?? '#059669',
    secondaryColor: map['secondaryColor'] ?? '#DC2626',
    accentColor: map['accentColor'] ?? '#D97706',
    backgroundColor: map['backgroundColor'] ?? '#F8FAFC',
    surfaceColor: map['surfaceColor'] ?? '#FFFFFF',
    textPrimaryColor: map['textPrimaryColor'] ?? '#0F172A',
    textSecondaryColor: map['textSecondaryColor'] ?? '#64748B',
    isDarkMode: map['isDarkMode'] ?? false,
    fontPreference: map['fontPreference'] ?? 'Hind Siliguri',
    borderRadiusPreset: map['borderRadiusPreset'] ?? 'smooth',
    contrastRatio: (map['contrastRatio'] as num?)?.toDouble() ?? 5.2,
    isPublished: map['isPublished'] ?? true,
    version: (map['version'] as num?)?.toInt() ?? 1,
  );
}

/// Custom Domain and Subdomain Model
class CustomDomainModel {
  final String id;
  final String societyId;
  final String domainName; // e.g. portal.swapnochowa.org
  final String subdomain; // e.g. swapnochowa.somiti.app
  final String verificationToken;
  final String cnameRecord;
  final String txtRecord;
  final DomainVerificationStatus status;
  final DomainSslStatus sslStatus;
  final DateTime? verifiedAt;
  final DateTime? lastHealthCheck;
  final String? failureReason;

  const CustomDomainModel({
    required this.id,
    required this.societyId,
    required this.domainName,
    required this.subdomain,
    required this.verificationToken,
    required this.cnameRecord,
    required this.txtRecord,
    required this.status,
    required this.sslStatus,
    this.verifiedAt,
    this.lastHealthCheck,
    this.failureReason,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'societyId': societyId,
    'domainName': domainName,
    'subdomain': subdomain,
    'verificationToken': verificationToken,
    'cnameRecord': cnameRecord,
    'txtRecord': txtRecord,
    'status': status.name,
    'sslStatus': sslStatus.name,
    'verifiedAt': verifiedAt?.toIso8601String(),
    'lastHealthCheck': lastHealthCheck?.toIso8601String(),
    'failureReason': failureReason,
  };

  factory CustomDomainModel.fromMap(Map<String, dynamic> map) => CustomDomainModel(
    id: map['id'] ?? '',
    societyId: map['societyId'] ?? '',
    domainName: map['domainName'] ?? '',
    subdomain: map['subdomain'] ?? '',
    verificationToken: map['verificationToken'] ?? '',
    cnameRecord: map['cnameRecord'] ?? '',
    txtRecord: map['txtRecord'] ?? '',
    status: DomainVerificationStatus.fromString(map['status'] ?? ''),
    sslStatus: DomainSslStatus.fromString(map['sslStatus'] ?? ''),
    verifiedAt: map['verifiedAt'] != null ? DateTime.tryParse(map['verifiedAt']) : null,
    lastHealthCheck: map['lastHealthCheck'] != null ? DateTime.tryParse(map['lastHealthCheck']) : null,
    failureReason: map['failureReason'],
  );
}

/// Custom Document Template Model
class DocumentTemplateModel {
  final String id;
  final String societyId;
  final DocumentTemplateType templateType;
  final String titleBn;
  final String titleEn;
  final String layoutType; // A4, POS_80MM, SLIP_55MM
  final String headerHtml;
  final String footerHtml;
  final String bodyTemplate;
  final List<String> availablePlaceholders;
  final bool isDefault;
  final int version;
  final bool isPublished;
  final DateTime updatedAt;

  const DocumentTemplateModel({
    required this.id,
    required this.societyId,
    required this.templateType,
    required this.titleBn,
    required this.titleEn,
    this.layoutType = 'A4',
    required this.headerHtml,
    required this.footerHtml,
    required this.bodyTemplate,
    required this.availablePlaceholders,
    this.isDefault = true,
    this.version = 1,
    this.isPublished = true,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'societyId': societyId,
    'templateType': templateType.name,
    'titleBn': titleBn,
    'titleEn': titleEn,
    'layoutType': layoutType,
    'headerHtml': headerHtml,
    'footerHtml': footerHtml,
    'bodyTemplate': bodyTemplate,
    'availablePlaceholders': availablePlaceholders,
    'isDefault': isDefault,
    'version': version,
    'isPublished': isPublished,
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory DocumentTemplateModel.fromMap(Map<String, dynamic> map) => DocumentTemplateModel(
    id: map['id'] ?? '',
    societyId: map['societyId'] ?? '',
    templateType: DocumentTemplateType.fromString(map['templateType'] ?? ''),
    titleBn: map['titleBn'] ?? '',
    titleEn: map['titleEn'] ?? '',
    layoutType: map['layoutType'] ?? 'A4',
    headerHtml: map['headerHtml'] ?? '',
    footerHtml: map['footerHtml'] ?? '',
    bodyTemplate: map['bodyTemplate'] ?? '',
    availablePlaceholders: List<String>.from(map['availablePlaceholders'] ?? []),
    isDefault: map['isDefault'] ?? true,
    version: (map['version'] as num?)?.toInt() ?? 1,
    isPublished: map['isPublished'] ?? true,
    updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
  );
}

/// Custom Notification Template Model
class NotificationTemplateModel {
  final String id;
  final String societyId;
  final NotificationChannelType channel;
  final String eventTrigger; // deposit.confirmed, loan.disbursed, installment.overdue
  final String templateContentBn;
  final String templateContentEn;
  final String? subjectLine;
  final List<String> approvedVariables;
  final bool isEnabled;
  final int version;

  const NotificationTemplateModel({
    required this.id,
    required this.societyId,
    required this.channel,
    required this.eventTrigger,
    required this.templateContentBn,
    required this.templateContentEn,
    this.subjectLine,
    required this.approvedVariables,
    this.isEnabled = true,
    this.version = 1,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'societyId': societyId,
    'channel': channel.name,
    'eventTrigger': eventTrigger,
    'templateContentBn': templateContentBn,
    'templateContentEn': templateContentEn,
    'subjectLine': subjectLine,
    'approvedVariables': approvedVariables,
    'isEnabled': isEnabled,
    'version': version,
  };

  factory NotificationTemplateModel.fromMap(Map<String, dynamic> map) => NotificationTemplateModel(
    id: map['id'] ?? '',
    societyId: map['societyId'] ?? '',
    channel: NotificationChannelType.fromString(map['channel'] ?? ''),
    eventTrigger: map['eventTrigger'] ?? '',
    templateContentBn: map['templateContentBn'] ?? '',
    templateContentEn: map['templateContentEn'] ?? '',
    subjectLine: map['subjectLine'],
    approvedVariables: List<String>.from(map['approvedVariables'] ?? []),
    isEnabled: map['isEnabled'] ?? true,
    version: (map['version'] as num?)?.toInt() ?? 1,
  );
}

/// Society Business Configuration Model
class SocietyBusinessConfigModel {
  final String societyId;
  final int fiscalYearStartMonth; // 7 = July
  final String receiptPrefix; // RCPT
  final String memberIdPrefix; // MEM
  final String loanPrefix; // LN
  final List<String> approvedVoucherLayouts;
  final String currencySymbol; // ৳
  final String dateFormat; // DD/MM/YYYY
  final String timeZone; // Asia/Dhaka
  final String languagePreference; // bn / en
  final String defaultDashboardView; // summary / modern / detailed

  const SocietyBusinessConfigModel({
    required this.societyId,
    this.fiscalYearStartMonth = 7,
    this.receiptPrefix = 'RCPT',
    this.memberIdPrefix = 'MEM',
    this.loanPrefix = 'LN',
    this.approvedVoucherLayouts = const ['A4', 'POS_80MM', 'SLIP_55MM'],
    this.currencySymbol = '৳',
    this.dateFormat = 'DD/MM/YYYY',
    this.timeZone = 'Asia/Dhaka',
    this.languagePreference = 'bn',
    this.defaultDashboardView = 'modern',
  });

  Map<String, dynamic> toMap() => {
    'societyId': societyId,
    'fiscalYearStartMonth': fiscalYearStartMonth,
    'receiptPrefix': receiptPrefix,
    'memberIdPrefix': memberIdPrefix,
    'loanPrefix': loanPrefix,
    'approvedVoucherLayouts': approvedVoucherLayouts,
    'currencySymbol': currencySymbol,
    'dateFormat': dateFormat,
    'timeZone': timeZone,
    'languagePreference': languagePreference,
    'defaultDashboardView': defaultDashboardView,
  };

  factory SocietyBusinessConfigModel.fromMap(Map<String, dynamic> map) => SocietyBusinessConfigModel(
    societyId: map['societyId'] ?? '',
    fiscalYearStartMonth: (map['fiscalYearStartMonth'] as num?)?.toInt() ?? 7,
    receiptPrefix: map['receiptPrefix'] ?? 'RCPT',
    memberIdPrefix: map['memberIdPrefix'] ?? 'MEM',
    loanPrefix: map['loanPrefix'] ?? 'LN',
    approvedVoucherLayouts: List<String>.from(map['approvedVoucherLayouts'] ?? ['A4', 'POS_80MM', 'SLIP_55MM']),
    currencySymbol: map['currencySymbol'] ?? '৳',
    dateFormat: map['dateFormat'] ?? 'DD/MM/YYYY',
    timeZone: map['timeZone'] ?? 'Asia/Dhaka',
    languagePreference: map['languagePreference'] ?? 'bn',
    defaultDashboardView: map['defaultDashboardView'] ?? 'modern',
  );
}

/// Plan-Based White-Label Entitlements
class WhiteLabelEntitlementModel {
  final WhiteLabelTier planTier;
  final bool canUseCustomBranding;
  final bool canUseCustomColors;
  final bool canUseCustomFonts;
  final bool canUseSubdomain;
  final bool canUseCustomDomain;
  final bool canEditDocumentTemplates;
  final bool canEditNotificationTemplates;
  final bool canExportNativeBuilds;
  final int maxCustomDomains;

  const WhiteLabelEntitlementModel({
    required this.planTier,
    required this.canUseCustomBranding,
    required this.canUseCustomColors,
    required this.canUseCustomFonts,
    required this.canUseSubdomain,
    required this.canUseCustomDomain,
    required this.canEditDocumentTemplates,
    required this.canEditNotificationTemplates,
    required this.canExportNativeBuilds,
    required this.maxCustomDomains,
  });

  Map<String, dynamic> toMap() => {
    'planTier': planTier.name,
    'canUseCustomBranding': canUseCustomBranding,
    'canUseCustomColors': canUseCustomColors,
    'canUseCustomFonts': canUseCustomFonts,
    'canUseSubdomain': canUseSubdomain,
    'canUseCustomDomain': canUseCustomDomain,
    'canEditDocumentTemplates': canEditDocumentTemplates,
    'canEditNotificationTemplates': canEditNotificationTemplates,
    'canExportNativeBuilds': canExportNativeBuilds,
    'maxCustomDomains': maxCustomDomains,
  };

  factory WhiteLabelEntitlementModel.forPlan(WhiteLabelTier tier) {
    switch (tier) {
      case WhiteLabelTier.starter:
        return const WhiteLabelEntitlementModel(
          planTier: WhiteLabelTier.starter,
          canUseCustomBranding: true,
          canUseCustomColors: false,
          canUseCustomFonts: false,
          canUseSubdomain: false,
          canUseCustomDomain: false,
          canEditDocumentTemplates: false,
          canEditNotificationTemplates: false,
          canExportNativeBuilds: false,
          maxCustomDomains: 0,
        );
      case WhiteLabelTier.standard:
        return const WhiteLabelEntitlementModel(
          planTier: WhiteLabelTier.standard,
          canUseCustomBranding: true,
          canUseCustomColors: true,
          canUseCustomFonts: false,
          canUseSubdomain: true,
          canUseCustomDomain: false,
          canEditDocumentTemplates: true,
          canEditNotificationTemplates: true,
          canExportNativeBuilds: false,
          maxCustomDomains: 0,
        );
      case WhiteLabelTier.enterprise:
        return const WhiteLabelEntitlementModel(
          planTier: WhiteLabelTier.enterprise,
          canUseCustomBranding: true,
          canUseCustomColors: true,
          canUseCustomFonts: true,
          canUseSubdomain: true,
          canUseCustomDomain: true,
          canEditDocumentTemplates: true,
          canEditNotificationTemplates: true,
          canExportNativeBuilds: false,
          maxCustomDomains: 1,
        );
      case WhiteLabelTier.customGov:
        return const WhiteLabelEntitlementModel(
          planTier: WhiteLabelTier.customGov,
          canUseCustomBranding: true,
          canUseCustomColors: true,
          canUseCustomFonts: true,
          canUseSubdomain: true,
          canUseCustomDomain: true,
          canEditDocumentTemplates: true,
          canEditNotificationTemplates: true,
          canExportNativeBuilds: true,
          maxCustomDomains: 5,
        );
    }
  }
}

/// Super Admin Centralized White-Label Master Configuration
class SuperAdminWhiteLabelMasterConfig {
  final bool isGlobalWhiteLabelEnabled;
  final bool isTenantIsolationEnforced; // Invariant: Cannot be disabled
  final bool isThemeEngineEnabled;
  final bool isCustomDomainSystemEnabled;
  final bool isTemplateEngineEnabled;
  final bool isNotificationTemplateEnabled;
  final bool isNativeBuildWorkflowEnabled;
  final int maxBrandingAssetSizeMb; // Default 5 MB

  const SuperAdminWhiteLabelMasterConfig({
    this.isGlobalWhiteLabelEnabled = true,
    this.isTenantIsolationEnforced = true,
    this.isThemeEngineEnabled = true,
    this.isCustomDomainSystemEnabled = true,
    this.isTemplateEngineEnabled = true,
    this.isNotificationTemplateEnabled = true,
    this.isNativeBuildWorkflowEnabled = true,
    this.maxBrandingAssetSizeMb = 5,
  });

  Map<String, dynamic> toMap() => {
    'isGlobalWhiteLabelEnabled': isGlobalWhiteLabelEnabled,
    'isTenantIsolationEnforced': isTenantIsolationEnforced,
    'isThemeEngineEnabled': isThemeEngineEnabled,
    'isCustomDomainSystemEnabled': isCustomDomainSystemEnabled,
    'isTemplateEngineEnabled': isTemplateEngineEnabled,
    'isNotificationTemplateEnabled': isNotificationTemplateEnabled,
    'isNativeBuildWorkflowEnabled': isNativeBuildWorkflowEnabled,
    'maxBrandingAssetSizeMb': maxBrandingAssetSizeMb,
  };
}

/// Customization Audit Log Model
class CustomizationAuditLogModel {
  final String id;
  final String societyId;
  final String actionType; // BRANDING_UPDATE, THEME_PUBLISH, DOMAIN_VERIFY, TEMPLATE_SAVE, ROLLBACK
  final String targetEntity;
  final String changedByUserId;
  final String userRole;
  final Map<String, dynamic> previousState;
  final Map<String, dynamic> newState;
  final DateTime timestamp;

  const CustomizationAuditLogModel({
    required this.id,
    required this.societyId,
    required this.actionType,
    required this.targetEntity,
    required this.changedByUserId,
    required this.userRole,
    required this.previousState,
    required this.newState,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'societyId': societyId,
    'actionType': actionType,
    'targetEntity': targetEntity,
    'changedByUserId': changedByUserId,
    'userRole': userRole,
    'previousState': previousState,
    'newState': newState,
    'timestamp': timestamp.toIso8601String(),
  };
}
