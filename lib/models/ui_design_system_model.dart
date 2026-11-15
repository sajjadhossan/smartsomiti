// lib/models/ui_design_system_model.dart
// Phase 11: Enterprise UI/UX Modernization, Design System & Accessibility Models

enum AppThemeMode {
  light,
  dark,
  highContrast,
  system;

  String get labelBn {
    switch (this) {
      case AppThemeMode.light: return 'লাইট মোড (Light)';
      case AppThemeMode.dark: return 'ডার্ক মোড (Dark)';
      case AppThemeMode.highContrast: return 'হাই-কন্ট্রাস্ট মোড (High Contrast)';
      case AppThemeMode.system: return 'সিস্টেম ডিফল্ট (System)';
    }
  }
}

enum AppLanguage {
  bangla,
  english;

  String get code => this == AppLanguage.bangla ? 'bn' : 'en';

  String get label {
    switch (this) {
      case AppLanguage.bangla: return 'বাংলা (Bangla)';
      case AppLanguage.english: return 'English';
    }
  }
}

enum ScreenBreakpoint {
  mobileSmall, // < 360px
  mobileStandard, // 360px - 639px
  tablet, // 640px - 1023px
  desktopStandard, // 1024px - 1439px
  desktopLarge; // >= 1440px

  static ScreenBreakpoint fromWidth(double width) {
    if (width < 360) return ScreenBreakpoint.mobileSmall;
    if (width < 640) return ScreenBreakpoint.mobileStandard;
    if (width < 1024) return ScreenBreakpoint.tablet;
    if (width < 1440) return ScreenBreakpoint.desktopStandard;
    return ScreenBreakpoint.desktopLarge;
  }

  bool get isMobile => this == ScreenBreakpoint.mobileSmall || this == ScreenBreakpoint.mobileStandard;
  bool get isTablet => this == ScreenBreakpoint.tablet;
  bool get isDesktop => this == ScreenBreakpoint.desktopStandard || this == ScreenBreakpoint.desktopLarge;
}

enum AccessibilityFontSize {
  standard, // 1.0x
  medium, // 1.15x
  large, // 1.3x
  extraLarge; // 1.5x

  double get scaleFactor {
    switch (this) {
      case AccessibilityFontSize.standard: return 1.0;
      case AccessibilityFontSize.medium: return 1.15;
      case AccessibilityFontSize.large: return 1.30;
      case AccessibilityFontSize.extraLarge: return 1.50;
    }
  }
}

enum ToastType {
  success,
  warning,
  error,
  info;
}

/// Authoritative Design Tokens Model
class DesignTokensModel {
  final String primaryColorHex;
  final String secondaryColorHex;
  final String surfaceColorHex;
  final String backgroundColorHex;
  final String textPrimaryHex;
  final String textMutedHex;
  final String dangerColorHex;
  final String warningColorHex;
  final String successColorHex;
  final double borderRadiusMd;
  final double cardElevation;
  final double contrastRatio;

  const DesignTokensModel({
    required this.primaryColorHex,
    required this.secondaryColorHex,
    required this.surfaceColorHex,
    required this.backgroundColorHex,
    required this.textPrimaryHex,
    required this.textMutedHex,
    required this.dangerColorHex,
    required this.warningColorHex,
    required this.successColorHex,
    this.borderRadiusMd = 8.0,
    this.cardElevation = 1.0,
    required this.contrastRatio,
  });

  factory DesignTokensModel.forMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.dark:
        return const DesignTokensModel(
          primaryColorHex: '#10B981',
          secondaryColorHex: '#38BDF8',
          surfaceColorHex: '#1E293B',
          backgroundColorHex: '#0F172A',
          textPrimaryHex: '#F8FAFC',
          textMutedHex: '#94A3B8',
          dangerColorHex: '#EF4444',
          warningColorHex: '#F59E0B',
          successColorHex: '#22C55E',
          contrastRatio: 9.2,
        );
      case AppThemeMode.highContrast:
        return const DesignTokensModel(
          primaryColorHex: '#00FF66',
          secondaryColorHex: '#00E5FF',
          surfaceColorHex: '#000000',
          backgroundColorHex: '#000000',
          textPrimaryHex: '#FFFFFF',
          textMutedHex: '#FFFF00',
          dangerColorHex: '#FF0000',
          warningColorHex: '#FFA500',
          successColorHex: '#00FF00',
          contrastRatio: 21.0, // Maximum accessible contrast
        );
      case AppThemeMode.light:
      case AppThemeMode.system:
      default:
        return const DesignTokensModel(
          primaryColorHex: '#059669',
          secondaryColorHex: '#0284C7',
          surfaceColorHex: '#FFFFFF',
          backgroundColorHex: '#F8FAFC',
          textPrimaryHex: '#1E293B',
          textMutedHex: '#64748B',
          dangerColorHex: '#DC2626',
          warningColorHex: '#D97706',
          successColorHex: '#16A34A',
          contrastRatio: 7.4, // Exceeds WCAG 2.2 AA (4.5:1)
        );
    }
  }

  Map<String, dynamic> toMap() => {
    'primaryColorHex': primaryColorHex,
    'secondaryColorHex': secondaryColorHex,
    'surfaceColorHex': surfaceColorHex,
    'backgroundColorHex': backgroundColorHex,
    'textPrimaryHex': textPrimaryHex,
    'textMutedHex': textMutedHex,
    'dangerColorHex': dangerColorHex,
    'warningColorHex': warningColorHex,
    'successColorHex': successColorHex,
    'borderRadiusMd': borderRadiusMd,
    'cardElevation': cardElevation,
    'contrastRatio': contrastRatio,
  };
}

/// Dashboard Widget Customization Model
class DashboardWidgetConfig {
  final String widgetId;
  final String titleBn;
  final String titleEn;
  final String category; // financial, operational, analytics, field
  final bool isEnabled;
  final bool isCore;
  final String minRoleRequired;
  final int orderIndex;

  const DashboardWidgetConfig({
    required this.widgetId,
    required this.titleBn,
    required this.titleEn,
    required this.category,
    this.isEnabled = true,
    this.isCore = false,
    this.minRoleRequired = 'member',
    required this.orderIndex,
  });

  Map<String, dynamic> toMap() => {
    'widgetId': widgetId,
    'titleBn': titleBn,
    'titleEn': titleEn,
    'category': category,
    'isEnabled': isEnabled,
    'isCore': isCore,
    'minRoleRequired': minRoleRequired,
    'orderIndex': orderIndex,
  };

  factory DashboardWidgetConfig.fromMap(Map<String, dynamic> map) => DashboardWidgetConfig(
    widgetId: map['widgetId'] ?? '',
    titleBn: map['titleBn'] ?? '',
    titleEn: map['titleEn'] ?? '',
    category: map['category'] ?? '',
    isEnabled: map['isEnabled'] ?? true,
    isCore: map['isCore'] ?? false,
    minRoleRequired: map['minRoleRequired'] ?? 'member',
    orderIndex: map['orderIndex'] ?? 0,
  );
}

/// Global Search Item Model
class GlobalSearchItemModel {
  final String itemId;
  final String title;
  final String subtitle;
  final String category; // member, loan, savings, journal, document
  final String societyId;
  final String routeKey;
  final String permissionKey;

  const GlobalSearchItemModel({
    required this.itemId,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.societyId,
    required this.routeKey,
    required this.permissionKey,
  });

  Map<String, dynamic> toMap() => {
    'itemId': itemId,
    'title': title,
    'subtitle': subtitle,
    'category': category,
    'societyId': societyId,
    'routeKey': routeKey,
    'permissionKey': permissionKey,
  };
}

/// User UI Preferences Model
class UiPreferenceModel {
  final String userId;
  final String societyId;
  final AppThemeMode themeMode;
  final AppLanguage language;
  final AccessibilityFontSize fontSize;
  final bool isHighContrast;
  final bool isReducedMotion;

  const UiPreferenceModel({
    required this.userId,
    required this.societyId,
    this.themeMode = AppThemeMode.light,
    this.language = AppLanguage.bangla,
    this.fontSize = AccessibilityFontSize.standard,
    this.isHighContrast = false,
    this.isReducedMotion = false,
  });

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'societyId': societyId,
    'themeMode': themeMode.name,
    'language': language.name,
    'fontSize': fontSize.name,
    'isHighContrast': isHighContrast,
    'isReducedMotion': isReducedMotion,
  };

  factory UiPreferenceModel.fromMap(Map<String, dynamic> map) => UiPreferenceModel(
    userId: map['userId'] ?? '',
    societyId: map['societyId'] ?? '',
    themeMode: AppThemeMode.values.firstWhere(
      (e) => e.name == map['themeMode'],
      orElse: () => AppThemeMode.light,
    ),
    language: AppLanguage.values.firstWhere(
      (e) => e.name == map['language'],
      orElse: () => AppLanguage.bangla,
    ),
    fontSize: AccessibilityFontSize.values.firstWhere(
      (e) => e.name == map['fontSize'],
      orElse: () => AccessibilityFontSize.standard,
    ),
    isHighContrast: map['isHighContrast'] ?? false,
    isReducedMotion: map['isReducedMotion'] ?? false,
  );
}

/// Super Admin UI Master Configuration
class SuperAdminUiMasterConfig {
  final bool isGlobalThemeOverride;
  final AppThemeMode? forcedThemeMode;
  final AppLanguage defaultLanguage;
  final bool allowHighContrast;
  final bool allowUserCustomDashboard;
  final bool globalSearchEnabled;
  final double minimumTouchTargetSize; // standard 44.0 px

  const SuperAdminUiMasterConfig({
    this.isGlobalThemeOverride = false,
    this.forcedThemeMode,
    this.defaultLanguage = AppLanguage.bangla,
    this.allowHighContrast = true,
    this.allowUserCustomDashboard = true,
    this.globalSearchEnabled = true,
    this.minimumTouchTargetSize = 44.0,
  });

  Map<String, dynamic> toMap() => {
    'isGlobalThemeOverride': isGlobalThemeOverride,
    'forcedThemeMode': forcedThemeMode?.name,
    'defaultLanguage': defaultLanguage.name,
    'allowHighContrast': allowHighContrast,
    'allowUserCustomDashboard': allowUserCustomDashboard,
    'globalSearchEnabled': globalSearchEnabled,
    'minimumTouchTargetSize': minimumTouchTargetSize,
  };
}
