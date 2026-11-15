// lib/models/production_readiness_model.dart
// Phase 12: Enterprise Production Deployment, Launch & Operational Readiness Models

enum UniversalControlScope {
  securityInvariant, // 1. Immutable Security Invariants (Tenant Isolation, Double-Entry, Auth)
  globalPlatform,    // 2. Global Platform Level
  environment,       // 3. Environment Level (Dev, Staging, Prod)
  society,           // 4. Individual Society Level
  subscriptionPlan,  // 5. Subscription Plan Level (Starter, Growth, Enterprise)
  module,            // 6. Module Level
  subFeature,        // 7. Sub-Feature Level
  pageScreen,        // 8. Page/Screen Level
  navigationMenu,    // 9. Navigation/Menu Level
  buttonAction,      // 10. Button/Action Level
  apiBackend,        // 11. API/Backend Operation Level
  role,              // 12. Role Level
  individualUser,    // 13. Individual User Level
  deviceSession;     // 14. Device/Session Level

  String get labelBn {
    switch (this) {
      case UniversalControlScope.securityInvariant: return '১. মৌলিক নিরাপত্তা ধ্রুবক (Security Invariant)';
      case UniversalControlScope.globalPlatform: return '২. গ্লোবাল প্ল্যাটফর্ম পর্যায় (Global Platform)';
      case UniversalControlScope.environment: return '৩. এনভায়রনমেন্ট পর্যায় (Environment)';
      case UniversalControlScope.society: return '৪. সমিতি পর্যায় (Society Level)';
      case UniversalControlScope.subscriptionPlan: return '৫. সাবস্ক্রিপশন প্ল্যান পর্যায় (Plan Level)';
      case UniversalControlScope.module: return '৬. মডিউল পর্যায় (Module Level)';
      case UniversalControlScope.subFeature: return '৭. সাব-ফিচার পর্যায় (Sub-Feature Level)';
      case UniversalControlScope.pageScreen: return '৮. পেজ ও স্ক্রিন পর্যায় (Page Level)';
      case UniversalControlScope.navigationMenu: return '৯. ন্যাভিগেশন ও মেনু পর্যায় (Navigation Level)';
      case UniversalControlScope.buttonAction: return '১০. বাটন ও অ্যাকশন পর্যায় (Action Level)';
      case UniversalControlScope.apiBackend: return '১১. এপিআই ও ব্যাকএন্ড পর্যায় (API Level)';
      case UniversalControlScope.role: return '১২. রোল ও পদবি পর্যায় (Role Level)';
      case UniversalControlScope.individualUser: return '১৩. ব্যবহারকারী পর্যায় (User Level)';
      case UniversalControlScope.deviceSession: return '১৪. ডিভাইস ও সেশন পর্যায় (Device Level)';
    }
  }
}

/// The 21 Platform Control Center Sections
enum ControlSectionId {
  globalModuleManagement,
  societyModuleManagement,
  subscriptionFeatureManagement,
  featureFlagManagement,
  subFeatureManagement,
  permissionRegistry,
  rolePermissionManagement,
  individualUserPermissionManagement,
  apiPermissionManagement,
  buttonActionPermissionManagement,
  navigationManagement,
  dashboardWidgetManagement,
  integrationManagement,
  financialOperationPermissions,
  aiFeatureManagement,
  offlineFeatureManagement,
  monitoringConfiguration,
  backupRestoreControls,
  deploymentPermissions,
  securityConfiguration,
  globalAuditLogs;

  String get titleBn {
    switch (this) {
      case ControlSectionId.globalModuleManagement: return '১. সার্বজনীন গ্লোবাল মডিউল কন্ট্রোল';
      case ControlSectionId.societyModuleManagement: return '২. সমিতি-ভিত্তিক মডিউল বরাদ্দ ও নিয়ন্ত্রণ';
      case ControlSectionId.subscriptionFeatureManagement: return '৩. সাবস্ক্রিপশন প্ল্যান ও ফিচার এন্টাইটেলমেন্ট';
      case ControlSectionId.featureFlagManagement: return '৪. ডাইনামিক ফিচার ফ্ল্যাগ ইঞ্জিন';
      case ControlSectionId.subFeatureManagement: return '৫. সূক্ষ্ম সাব-ফিচার ও ফাংশন সুইচ';
      case ControlSectionId.permissionRegistry: return '৬. সেন্ট্রালাইজড পারমিশন রেজিস্ট্রি (১২০+ কী)';
      case ControlSectionId.rolePermissionManagement: return '৭. রোল ও অ্যাক্সেস কন্ট্রোল ম্যাট্রিক্স (RBAC)';
      case ControlSectionId.individualUserPermissionManagement: return '৮. ব্যক্তিগত ইউজার পারমিশন ওভাররাইড';
      case ControlSectionId.apiPermissionManagement: return '৯. ব্যাকএন্ড এপিআই ও ক্লাউড ফাংশন ব্যারিয়ার';
      case ControlSectionId.buttonActionPermissionManagement: return '১০. বাটন ও ইন্টারঅ্যাক্টিভ অ্যাকশন গেট';
      case ControlSectionId.navigationManagement: return '১১. ন্যাভিগেশন মেনু ও রাউটিং কনফিগ';
      case ControlSectionId.dashboardWidgetManagement: return '১২. ড্যাশবোর্ড উইজেট ও কোর উইজেট লক';
      case ControlSectionId.integrationManagement: return '১৩. পেমেন্ট ও এক্সটার্নাল এপিআই গেটওয়ে';
      case ControlSectionId.financialOperationPermissions: return '১৪. আর্থিক কার্যক্রম ও দ্বৈত নিশ্চয়তাকরণ';
      case ControlSectionId.aiFeatureManagement: return '১৫. এন্টারপ্রাইজ এআই ও প্রেডিক্টিভ অ্যানালিটিক্স';
      case ControlSectionId.offlineFeatureManagement: return '১৬. অফলাইন সিঙ্ক ও ফিল্ড অপারেশন কন্ট্রোল';
      case ControlSectionId.monitoringConfiguration: return '১৭. সিস্টেম হেলথ ও সেন্ট্রালাইজড মনিটরিং';
      case ControlSectionId.backupRestoreControls: return '১৮. ক্লাউড ব্যাকআপ ও PITR রিকভারি ড্রিল';
      case ControlSectionId.deploymentPermissions: return '১৯. সিআই/সিডি রিলিজ ও অটো-রোলব্যাক পারমিশন';
      case ControlSectionId.securityConfiguration: return '২০. এন্টারপ্রাইজ সিকিউরিটি পলিসি ও এমএফএ';
      case ControlSectionId.globalAuditLogs: return '২১. অপরিবর্তনীয় সেন্ট্রালাইজড অডিট ট্রেইল';
    }
  }
}

/// Authoritative Control Setting Model
class UniversalControlSetting {
  final String key;
  final UniversalControlScope scope;
  final ControlSectionId sectionId;
  final String titleBn;
  final String titleEn;
  final bool isEnabled;
  final bool isSecurityInvariant; // If true, cannot be disabled under any circumstances
  final Map<String, dynamic> metadata;

  const UniversalControlSetting({
    required this.key,
    required this.scope,
    required this.sectionId,
    required this.titleBn,
    required this.titleEn,
    this.isEnabled = true,
    this.isSecurityInvariant = false,
    this.metadata = const {},
  });

  Map<String, dynamic> toMap() => {
    'key': key,
    'scope': scope.name,
    'sectionId': sectionId.name,
    'titleBn': titleBn,
    'titleEn': titleEn,
    'isEnabled': isEnabled,
    'isSecurityInvariant': isSecurityInvariant,
    'metadata': metadata,
  };
}

/// Request for Effective Authorization Evaluation
class EffectivePermissionRequest {
  final String userId;
  final String userRole;
  final String societyId;
  final String subscriptionTier; // starter, growth, enterprise, custom
  final String permissionKey;
  final String? moduleKey;
  final String? actionType;
  final String? deviceId;

  const EffectivePermissionRequest({
    required this.userId,
    required this.userRole,
    required this.societyId,
    this.subscriptionTier = 'growth',
    required this.permissionKey,
    this.moduleKey,
    this.actionType,
    this.deviceId,
  });
}

/// Effective Authorization Decision
class EffectivePermissionDecision {
  final bool isGranted;
  final UniversalControlScope? denyingScope;
  final String reasonBn;
  final String reasonEn;

  const EffectivePermissionDecision({
    required this.isGranted,
    this.denyingScope,
    required this.reasonBn,
    required this.reasonEn,
  });
}

/// Production Readiness Verification Checklist Item
class ProductionReadinessCheckItem {
  final String checkId;
  final String category;
  final String titleBn;
  final String titleEn;
  final bool isPassed;
  final String verificationMethod;
  final String details;

  const ProductionReadinessCheckItem({
    required this.checkId,
    required this.category,
    required this.titleBn,
    required this.titleEn,
    required this.isPassed,
    required this.verificationMethod,
    required this.details,
  });

  Map<String, dynamic> toMap() => {
    'checkId': checkId,
    'category': category,
    'titleBn': titleBn,
    'titleEn': titleEn,
    'isPassed': isPassed,
    'verificationMethod': verificationMethod,
    'details': details,
  };
}

/// Production Health & Go-Live Certification Model
class ProductionHealthCertification {
  final String certificationId;
  final String targetVersion;
  final DateTime certifiedAt;
  final String certifiedBy;
  final bool isApproved;
  final int readinessScorePercent;
  final Map<String, bool> phaseSignoffs;
  final String remarksBn;

  const ProductionHealthCertification({
    required this.certificationId,
    required this.targetVersion,
    required this.certifiedAt,
    required this.certifiedBy,
    required this.isApproved,
    required this.readinessScorePercent,
    required this.phaseSignoffs,
    required this.remarksBn,
  });

  Map<String, dynamic> toMap() => {
    'certificationId': certificationId,
    'targetVersion': targetVersion,
    'certifiedAt': certifiedAt.toIso8601String(),
    'certifiedBy': certifiedBy,
    'isApproved': isApproved,
    'readinessScorePercent': readinessScorePercent,
    'phaseSignoffs': phaseSignoffs,
    'remarksBn': remarksBn,
  };
}

/// Production Configuration Audit Log Entry
class ProductionAuditEntry {
  final String auditId;
  final String action;
  final String actorId;
  final UniversalControlScope scope;
  final String settingKey;
  final dynamic previousValue;
  final dynamic newValue;
  final DateTime timestamp;
  final String checksum;

  const ProductionAuditEntry({
    required this.auditId,
    required this.action,
    required this.actorId,
    required this.scope,
    required this.settingKey,
    required this.previousValue,
    required this.newValue,
    required this.timestamp,
    required this.checksum,
  });

  Map<String, dynamic> toMap() => {
    'auditId': auditId,
    'action': action,
    'actorId': actorId,
    'scope': scope.name,
    'settingKey': settingKey,
    'previousValue': previousValue,
    'newValue': newValue,
    'timestamp': timestamp.toIso8601String(),
    'checksum': checksum,
  };
}
