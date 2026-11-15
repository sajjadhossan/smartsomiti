// lib/services/ui_design_system_service.dart
// Comprehensive Service for Phase 11 Enterprise UI/UX Modernization, Design System & Accessibility

import 'dart:math';
import '../models/ui_design_system_model.dart';

class UiDesignSystemService {
  static final UiDesignSystemService _instance = UiDesignSystemService._internal();
  factory UiDesignSystemService() => _instance;

  UiDesignSystemService._internal() {
    _initializeDefaultWidgets();
    _initializeSeedSearchItems();
  }

  // Active User/Session State
  AppThemeMode _currentThemeMode = AppThemeMode.light;
  AppLanguage _currentLanguage = AppLanguage.bangla;
  AccessibilityFontSize _currentFontSize = AccessibilityFontSize.standard;
  bool _isHighContrast = false;
  bool _isReducedMotion = false;

  // Super Admin Master Config
  SuperAdminUiMasterConfig _masterConfig = const SuperAdminUiMasterConfig();

  // In-memory state registries
  final Map<String, UiPreferenceModel> _userPreferences = {};
  final List<DashboardWidgetConfig> _registeredWidgets = [];
  final List<GlobalSearchItemModel> _searchIndex = [];

  // ============================================================================
  // 1. GETTERS & MASTER CONFIG
  // ============================================================================

  AppThemeMode get currentThemeMode => _currentThemeMode;
  AppLanguage get currentLanguage => _currentLanguage;
  AccessibilityFontSize get currentFontSize => _currentFontSize;
  bool get isHighContrast => _isHighContrast;
  bool get isReducedMotion => _isReducedMotion;
  SuperAdminUiMasterConfig get masterConfig => _masterConfig;
  List<DashboardWidgetConfig> get registeredWidgets => List.unmodifiable(_registeredWidgets);

  void updateMasterConfig(SuperAdminUiMasterConfig config) {
    _masterConfig = config;
  }

  // ============================================================================
  // 2. THEME & DESIGN TOKEN RESOLUTION
  // ============================================================================

  void setThemeMode(AppThemeMode mode) {
    _currentThemeMode = mode;
  }

  void setHighContrast(bool enabled) {
    if (_masterConfig.allowHighContrast || !enabled) {
      _isHighContrast = enabled;
      if (enabled) {
        _currentThemeMode = AppThemeMode.highContrast;
      } else if (_currentThemeMode == AppThemeMode.highContrast) {
        _currentThemeMode = AppThemeMode.light;
      }
    }
  }

  DesignTokensModel resolveActiveTokens({UiPreferenceModel? userPref}) {
    // 1. Super Admin Global Override has highest priority
    if (_masterConfig.isGlobalThemeOverride && _masterConfig.forcedThemeMode != null) {
      return DesignTokensModel.forMode(_masterConfig.forcedThemeMode!);
    }

    // 2. High Contrast preference
    if ((userPref?.isHighContrast ?? false) || _isHighContrast) {
      return DesignTokensModel.forMode(AppThemeMode.highContrast);
    }

    // 3. User preference
    final mode = userPref?.themeMode ?? _currentThemeMode;
    return DesignTokensModel.forMode(mode);
  }

  // ============================================================================
  // 3. WCAG 2.2 AA ACCESSIBILITY & CONTRAST CALCULATION
  // ============================================================================

  void setFontSize(AccessibilityFontSize size) {
    _currentFontSize = size;
  }

  void setReducedMotion(bool enabled) {
    _isReducedMotion = enabled;
  }

  double getFontScaleFactor({UiPreferenceModel? userPref}) {
    return (userPref?.fontSize ?? _currentFontSize).scaleFactor;
  }

  /// Calculates relative luminance contrast ratio according to WCAG 2.2 specs:
  /// (L1 + 0.05) / (L2 + 0.05), where L1 is lighter and L2 is darker.
  double calculateContrastRatio(double lum1, double lum2) {
    final lighter = max(lum1, lum2);
    final darker = min(lum1, lum2);
    return double.parse(((lighter + 0.05) / (darker + 0.05)).toStringAsFixed(2));
  }

  /// Verifies WCAG 2.2 AA compliance:
  /// Minimum 4.5:1 for normal text, 3.0:1 for large text (>= 18pt or bold 14pt).
  bool verifyWcagCompliance(double contrastRatio, {bool isLargeText = false}) {
    final minRequired = isLargeText ? 3.0 : 4.5;
    return contrastRatio >= minRequired;
  }

  /// Verifies touch target size conforms to minimum dimension (44x44px).
  bool verifyTouchTarget(double width, double height) {
    final minSize = _masterConfig.minimumTouchTargetSize;
    return width >= minSize && height >= minSize;
  }

  // ============================================================================
  // 4. LOCALIZATION & BENGALI NUMERALS (toBnDigits)
  // ============================================================================

  void setLanguage(AppLanguage language) {
    _currentLanguage = language;
  }

  /// Converts English numeric digits (0-9) to standard Bengali digits (০-৯)
  String toBnDigits(dynamic input) {
    if (input == null) return '';
    final str = input.toString();
    const en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const bn = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];

    var result = str;
    for (int i = 0; i < 10; i++) {
      result = result.replaceAll(en[i], bn[i]);
    }
    return result;
  }

  /// Converts integer Poisha to formatted BDT currency string
  /// 100 Poisha = 1 BDT
  String formatCurrencyPoisha(
    int poisha, {
    bool includeSymbol = true,
    bool useBnDigits = true,
  }) {
    final isNegative = poisha < 0;
    final absPoisha = poisha.abs();
    final taka = absPoisha ~/ 100;
    final remPoisha = absPoisha % 100;

    // Format thousands with commas (South Asian style: e.g. 1,00,000 or standard 100,000)
    final takaStr = taka.toString().replaceAllMapped(
      RegExp(r'(\d+?)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    final poishaStr = remPoisha.toString().padLeft(2, '0');
    final formattedNum = '$takaStr.$poishaStr';

    final sign = isNegative ? '-' : '';
    final symbol = includeSymbol ? '৳' : '';

    if (useBnDigits) {
      final bnNumber = toBnDigits(formattedNum);
      return '$symbol$sign$bnNumber';
    } else {
      return '$symbol$sign$formattedNum';
    }
  }

  /// Translation Dictionary
  String translate(String key, {AppLanguage? lang}) {
    final activeLang = lang ?? _currentLanguage;
    final isBn = activeLang == AppLanguage.bangla;

    final Map<String, Map<String, String>> dictionary = {
      'app_title': {
        'bn': 'স্বপ্ন ছোঁয়া ঐক্য সমিতি',
        'en': 'Shopno Chowa Oikya Somiti',
      },
      'nav_dashboard': {
        'bn': 'ড্যাশবোর্ড',
        'en': 'Dashboard',
      },
      'nav_members': {
        'bn': 'সদস্য ব্যবস্থাপনা',
        'en': 'Member Management',
      },
      'nav_loans': {
        'bn': 'ঋণ ও কিস্তি',
        'en': 'Loans & Installments',
      },
      'nav_savings': {
        'bn': 'সঞ্চয় হিসাব',
        'en': 'Savings Accounts',
      },
      'nav_accounting': {
        'bn': 'হিসাবরক্ষণ ও ভাউচার',
        'en': 'Accounting & Vouchers',
      },
      'nav_ui_modernization': {
        'bn': 'ডিজাইন সিস্টেম ও UI/UX',
        'en': 'Design System & UI/UX',
      },
      'confirm': {
        'bn': 'নিশ্চিত করুন',
        'en': 'Confirm',
      },
      'cancel': {
        'bn': 'বাতিল',
        'en': 'Cancel',
      },
      'safety_warning': {
        'bn': 'উচ্চ মূল্যের বা সংবেদনশীল লেনদেন। নিশ্চিতকরণ আবশ্যক।',
        'en': 'High-value or critical financial operation. Confirmation required.',
      },
    };

    if (dictionary.containsKey(key)) {
      return isBn ? dictionary[key]!['bn']! : dictionary[key]!['en']!;
    }
    return key;
  }

  // ============================================================================
  // 5. RESPONSIVE BREAKPOINT HELPER
  // ============================================================================

  ScreenBreakpoint getBreakpointForWidth(double width) {
    return ScreenBreakpoint.fromWidth(width);
  }

  int getGridColumnCount(double width) {
    final bp = ScreenBreakpoint.fromWidth(width);
    switch (bp) {
      case ScreenBreakpoint.mobileSmall:
      case ScreenBreakpoint.mobileStandard:
        return 1;
      case ScreenBreakpoint.tablet:
        return 2;
      case ScreenBreakpoint.desktopStandard:
        return 3;
      case ScreenBreakpoint.desktopLarge:
        return 4;
    }
  }

  // ============================================================================
  // 6. DASHBOARD WIDGET CONFIGURATION & ROLE FILTERING
  // ============================================================================

  void _initializeDefaultWidgets() {
    _registeredWidgets.addAll([
      const DashboardWidgetConfig(
        widgetId: 'widget_kpi_summary',
        titleBn: 'মূল আর্থিক সূচক (KPIs)',
        titleEn: 'Core Financial KPIs',
        category: 'financial',
        isEnabled: true,
        isCore: true,
        minRoleRequired: 'member',
        orderIndex: 1,
      ),
      const DashboardWidgetConfig(
        widgetId: 'widget_collection_chart',
        titleBn: 'আদায় ও বিতরণ বিশ্লেষণ',
        titleEn: 'Collection & Disbursement Chart',
        category: 'analytics',
        isEnabled: true,
        isCore: false,
        minRoleRequired: 'accountant',
        orderIndex: 2,
      ),
      const DashboardWidgetConfig(
        widgetId: 'widget_field_officer_tracker',
        titleBn: 'ফিল্ড অফিসার কালেকশন ট্র্যাকার',
        titleEn: 'Field Officer Collection Tracker',
        category: 'field',
        isEnabled: true,
        isCore: false,
        minRoleRequired: 'field_officer',
        orderIndex: 3,
      ),
      const DashboardWidgetConfig(
        widgetId: 'widget_passbook_quickview',
        titleBn: 'সদস্য সঞ্চয় ও ঋণ পাসবই',
        titleEn: 'Member Savings & Loan Passbook',
        category: 'financial',
        isEnabled: true,
        isCore: true,
        minRoleRequired: 'member',
        orderIndex: 4,
      ),
      const DashboardWidgetConfig(
        widgetId: 'widget_audit_compliance_alerts',
        titleBn: 'অডিট ও কমপ্লায়েন্স নোটিফিকেশন',
        titleEn: 'Audit & Compliance Alerts',
        category: 'operational',
        isEnabled: true,
        isCore: false,
        minRoleRequired: 'admin',
        orderIndex: 5,
      ),
    ]);
  }

  void registerWidget(DashboardWidgetConfig widget) {
    final idx = _registeredWidgets.indexWhere((w) => w.widgetId == widget.widgetId);
    if (idx >= 0) {
      _registeredWidgets[idx] = widget;
    } else {
      _registeredWidgets.add(widget);
    }
  }

  bool toggleWidgetEnabled(String widgetId, bool enabled) {
    final idx = _registeredWidgets.indexWhere((w) => w.widgetId == widgetId);
    if (idx >= 0) {
      final current = _registeredWidgets[idx];
      // Core widgets cannot be disabled
      if (current.isCore && !enabled) {
        return false;
      }
      _registeredWidgets[idx] = DashboardWidgetConfig(
        widgetId: current.widgetId,
        titleBn: current.titleBn,
        titleEn: current.titleEn,
        category: current.category,
        isEnabled: enabled,
        isCore: current.isCore,
        minRoleRequired: current.minRoleRequired,
        orderIndex: current.orderIndex,
      );
      return true;
    }
    return false;
  }

  List<DashboardWidgetConfig> filterWidgetsForRole({
    required String userRole,
    required bool isSuperAdmin,
  }) {
    const roleHierarchy = {
      'member': 1,
      'field_officer': 2,
      'accountant': 3,
      'admin': 4,
      'super_admin': 5,
    };

    final userRank = roleHierarchy[userRole.toLowerCase()] ?? 1;

    return _registeredWidgets.where((widget) {
      if (!widget.isEnabled) return false;
      if (isSuperAdmin) return true;
      final requiredRank = roleHierarchy[widget.minRoleRequired.toLowerCase()] ?? 1;
      return userRank >= requiredRank;
    }).toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
  }

  // ============================================================================
  // 7. TENANT-AWARE GLOBAL SEARCH HUB
  // ============================================================================

  void _initializeSeedSearchItems() {
    _searchIndex.addAll([
      const GlobalSearchItemModel(
        itemId: 'MEM-001',
        title: 'মো. রফিকুল ইসলাম (সদস্য নং ০১)',
        subtitle: 'ফোন: ০১৭১১-০০০০০০ | সঞ্চয় ব্যালেন্স: ৳২৫,০০০',
        category: 'member',
        societyId: 'society_main_01',
        routeKey: '/members/MEM-001',
        permissionKey: 'member.view',
      ),
      const GlobalSearchItemModel(
        itemId: 'LN-2026-0042',
        title: 'ক্ষুদ্র ব্যবসা ঋণ (LN-2026-0042)',
        subtitle: 'মূল ঋণ: ৳১,৫০,০০০ | অবশিষ্ট কিস্তি: ০৩টি',
        category: 'loan',
        societyId: 'society_main_01',
        routeKey: '/loans/LN-2026-0042',
        permissionKey: 'loan.view',
      ),
      const GlobalSearchItemModel(
        itemId: 'SAV-009',
        title: 'মাসিক ডিপিএস হিসাব (SAV-009)',
        subtitle: 'মাসিক কিস্তি: ৳২,০০০ | মোট জমা: ৳৪৮,০০০',
        category: 'savings',
        societyId: 'society_main_01',
        routeKey: '/savings/SAV-009',
        permissionKey: 'savings.view',
      ),
      const GlobalSearchItemModel(
        itemId: 'VCH-2026-108',
        title: 'ডেবিট ভাউচার (VCH-2026-108)',
        subtitle: 'বিবরণ: অফিস ভাড়া প্রদান | পরিমাণ: ৳১৫,০০০',
        category: 'journal',
        societyId: 'society_main_01',
        routeKey: '/accounting/vouchers/VCH-2026-108',
        permissionKey: 'accounting.view',
      ),
      const GlobalSearchItemModel(
        itemId: 'MEM-099',
        title: 'অন্য সমিতির সদস্য (Society 02)',
        subtitle: 'ফোন: ০১৮১১-০০০০০০',
        category: 'member',
        societyId: 'society_branch_02',
        routeKey: '/members/MEM-099',
        permissionKey: 'member.view',
      ),
    ]);
  }

  void addSearchItem(GlobalSearchItemModel item) {
    _searchIndex.removeWhere((i) => i.itemId == item.itemId && i.societyId == item.societyId);
    _searchIndex.add(item);
  }

  List<GlobalSearchItemModel> executeGlobalSearch({
    required String query,
    required String societyId,
    required List<String> userPermissions,
    required bool isSuperAdmin,
  }) {
    if (!_masterConfig.globalSearchEnabled || query.trim().isEmpty) {
      return [];
    }

    final q = query.trim().toLowerCase();

    return _searchIndex.where((item) {
      // 1. Strict Society Isolation (Super Admin can search within specific society if chosen)
      if (item.societyId != societyId) {
        return false;
      }

      // 2. Permission Check: User must possess permission key unless super admin
      if (!isSuperAdmin && !userPermissions.contains(item.permissionKey)) {
        return false;
      }

      // 3. Substring matching in title, subtitle, or category
      return item.title.toLowerCase().contains(q) ||
          item.subtitle.toLowerCase().contains(q) ||
          item.category.toLowerCase().contains(q) ||
          item.itemId.toLowerCase().contains(q);
    }).toList();
  }

  // ============================================================================
  // 8. FINANCIAL INPUT SAFETY ENGINE (ZERO SILENT EXECUTION)
  // ============================================================================

  /// Evaluates financial actions to ensure critical/high-impact operations require
  /// explicit user confirmation and double-entry review before execution.
  FinancialSafetyResult validateFinancialActionSafety({
    required String actionType,
    required int amountPoisha,
    required bool userConfirmed,
    int confirmationThresholdPoisha = 5000000, // ৳50,000 threshold
  }) {
    const criticalActionTypes = {
      'loan_disbursement',
      'dividend_payout',
      'period_close',
      'manual_journal_reversal',
      'capital_withdrawal',
      'member_account_closure',
    };

    final isCriticalType = criticalActionTypes.contains(actionType);
    final isHighAmount = amountPoisha >= confirmationThresholdPoisha;

    if (isCriticalType || isHighAmount) {
      if (!userConfirmed) {
        return FinancialSafetyResult(
          allowed: false,
          requiresConfirmation: true,
          actionType: actionType,
          amountPoisha: amountPoisha,
          warningMessageBn: 'উচ্চ মূল্যের বা সংবেদনশীল লেনদেন। নিশ্চিতকরণ আবশ্যক।',
          warningMessageEn: 'High-value or critical financial operation. Confirmation required.',
        );
      }
    }

    return FinancialSafetyResult(
      allowed: true,
      requiresConfirmation: false,
      actionType: actionType,
      amountPoisha: amountPoisha,
      warningMessageBn: 'লেনদেন অনুমোদিত।',
      warningMessageEn: 'Transaction permitted.',
    );
  }

  // ============================================================================
  // 9. USER PREFERENCES MANAGEMENT
  // ============================================================================

  void saveUserPreferences(UiPreferenceModel pref) {
    _userPreferences['${pref.userId}_${pref.societyId}'] = pref;
  }

  UiPreferenceModel getUserPreferences(String userId, String societyId) {
    final key = '${userId}_$societyId';
    return _userPreferences[key] ??
        UiPreferenceModel(userId: userId, societyId: societyId);
  }
}

/// Financial Safety Evaluation Result
class FinancialSafetyResult {
  final bool allowed;
  final bool requiresConfirmation;
  final String actionType;
  final int amountPoisha;
  final String warningMessageBn;
  final String warningMessageEn;

  const FinancialSafetyResult({
    required this.allowed,
    required this.requiresConfirmation,
    required this.actionType,
    required this.amountPoisha,
    required this.warningMessageBn,
    required this.warningMessageEn,
  });
}
