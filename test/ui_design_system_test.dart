// test/ui_design_system_test.dart
// Comprehensive Unit Tests for Phase 11 Enterprise UI/UX Modernization, Design System & Accessibility Engine

import 'package:test/test.dart';
import '../lib/models/ui_design_system_model.dart';
import '../lib/services/ui_design_system_service.dart';

void main() {
  group('Phase 11 - Enterprise UI/UX Modernization, Design System & Accessibility Tests', () {
    late UiDesignSystemService service;

    setUp(() {
      service = UiDesignSystemService();
      // Reset master config to defaults
      service.updateMasterConfig(const SuperAdminUiMasterConfig());
      service.setThemeMode(AppThemeMode.light);
      service.setLanguage(AppLanguage.bangla);
      service.setFontSize(AccessibilityFontSize.standard);
      service.setHighContrast(false);
      service.setReducedMotion(false);
    });

    test('1. Design Tokens Resolution for Light, Dark, and High-Contrast Modes', () {
      // Light Mode tokens
      final lightTokens = DesignTokensModel.forMode(AppThemeMode.light);
      expect(lightTokens.primaryColorHex, equals('#059669')); // Emerald
      expect(lightTokens.secondaryColorHex, equals('#0284C7')); // Sky Blue
      expect(lightTokens.surfaceColorHex, equals('#FFFFFF'));
      expect(lightTokens.contrastRatio, greaterThanOrEqualTo(4.5));

      // Dark Mode tokens
      final darkTokens = DesignTokensModel.forMode(AppThemeMode.dark);
      expect(darkTokens.primaryColorHex, equals('#10B981'));
      expect(darkTokens.surfaceColorHex, equals('#1E293B'));
      expect(darkTokens.contrastRatio, greaterThanOrEqualTo(7.0));

      // High-Contrast Mode tokens
      final hcTokens = DesignTokensModel.forMode(AppThemeMode.highContrast);
      expect(hcTokens.surfaceColorHex, equals('#000000'));
      expect(hcTokens.textPrimaryHex, equals('#FFFFFF'));
      expect(hcTokens.contrastRatio, equals(21.0));
    });

    test('2. WCAG 2.2 Level AA Color Contrast Verification (>= 4.5:1 for Normal Text)', () {
      // White background (lum = 1.0) and dark slate text (lum = 0.05)
      final ratioNormal = service.calculateContrastRatio(1.0, 0.05);
      expect(ratioNormal, greaterThanOrEqualTo(4.5));
      expect(service.verifyWcagCompliance(ratioNormal, isLargeText: false), isTrue);

      // Low contrast scenario (lum1 = 0.5, lum2 = 0.4) -> ratio ~ 1.2
      final ratioFailing = service.calculateContrastRatio(0.5, 0.4);
      expect(ratioFailing, lessThan(4.5));
      expect(service.verifyWcagCompliance(ratioFailing, isLargeText: false), isFalse);

      // Large text requirement threshold is 3.0:1
      expect(service.verifyWcagCompliance(3.5, isLargeText: true), isTrue);
      expect(service.verifyWcagCompliance(3.5, isLargeText: false), isFalse);
    });

    test('3. Language Localization Toggle & Bengali Numerals Conversion (toBnDigits)', () {
      expect(service.currentLanguage, equals(AppLanguage.bangla));
      expect(service.translate('app_title'), equals('স্বপ্ন ছোঁয়া ঐক্য সমিতি'));

      // Switch language to English
      service.setLanguage(AppLanguage.english);
      expect(service.currentLanguage, equals(AppLanguage.english));
      expect(service.translate('app_title'), equals('Shopno Chowa Oikya Somiti'));

      // Test toBnDigits utility
      expect(service.toBnDigits('0123456789'), equals('০১২৩৪৫৬৭৮৯'));
      expect(service.toBnDigits('1,250.50'), equals('১,২৫০.৫০'));
      expect(service.toBnDigits(2026), equals('২০২৬'));
    });

    test('4. Integer Poisha Financial Currency Formatting with BDT Symbol and Digits', () {
      // 100,000 Poisha = 1,000.00 BDT
      final formattedBn = service.formatCurrencyPoisha(100000, includeSymbol: true, useBnDigits: true);
      expect(formattedBn, equals('৳১,০০০.০০'));

      final formattedEn = service.formatCurrencyPoisha(125050, includeSymbol: true, useBnDigits: false);
      expect(formattedEn, equals('৳1,250.50'));

      // Negative value (e.g. withdrawal or deficit)
      final negativeFormatted = service.formatCurrencyPoisha(-50000, includeSymbol: true, useBnDigits: true);
      expect(negativeFormatted, equals('৳-৫০০.০০'));
    });

    test('5. Tenant-Aware & Permission-Aware Global Search Hub', () {
      const societyA = 'society_main_01';
      const societyB = 'society_branch_02';

      // 1. User in Society A with member.view permission searches 'রফিকুল'
      final searchA = service.executeGlobalSearch(
        query: 'রফিকুল',
        societyId: societyA,
        userPermissions: ['member.view'],
        isSuperAdmin: false,
      );
      expect(searchA.length, equals(1));
      expect(searchA.first.itemId, equals('MEM-001'));
      expect(searchA.first.title, contains('রফিকুল'));

      // 2. Multi-tenant isolation: Society A user cannot see records from Society B
      final crossTenantSearch = service.executeGlobalSearch(
        query: 'অন্য সমিতির সদস্য',
        societyId: societyA,
        userPermissions: ['member.view'],
        isSuperAdmin: false,
      );
      expect(crossTenantSearch, isEmpty);

      // 3. Permission check: User without accounting.view cannot see vouchers
      final unpermittedSearch = service.executeGlobalSearch(
        query: 'ভাউচার',
        societyId: societyA,
        userPermissions: ['member.view'], // Lacks accounting.view
        isSuperAdmin: false,
      );
      expect(unpermittedSearch, isEmpty);

      // 4. Authorized user with accounting.view can see vouchers
      final permittedSearch = service.executeGlobalSearch(
        query: 'ভাউচার',
        societyId: societyA,
        userPermissions: ['member.view', 'accounting.view'],
        isSuperAdmin: false,
      );
      expect(permittedSearch.length, equals(1));
      expect(permittedSearch.first.itemId, equals('VCH-2026-108'));
    });

    test('6. Responsive Layout Breakpoints & Adaptive Grid Columns', () {
      // Mobile screens (< 640px)
      expect(service.getBreakpointForWidth(320), equals(ScreenBreakpoint.mobileSmall));
      expect(service.getBreakpointForWidth(480), equals(ScreenBreakpoint.mobileStandard));
      expect(service.getBreakpointForWidth(480).isMobile, isTrue);
      expect(service.getGridColumnCount(480), equals(1));

      // Tablet screens (640px - 1023px)
      expect(service.getBreakpointForWidth(768), equals(ScreenBreakpoint.tablet));
      expect(service.getBreakpointForWidth(768).isTablet, isTrue);
      expect(service.getGridColumnCount(768), equals(2));

      // Desktop screens (>= 1024px)
      expect(service.getBreakpointForWidth(1200), equals(ScreenBreakpoint.desktopStandard));
      expect(service.getBreakpointForWidth(1200).isDesktop, isTrue);
      expect(service.getGridColumnCount(1200), equals(3));

      expect(service.getBreakpointForWidth(1600), equals(ScreenBreakpoint.desktopLarge));
      expect(service.getGridColumnCount(1600), equals(4));
    });

    test('7. Super Admin Universal UI Master Switches & Forced Theme Override', () {
      // User sets dark theme
      service.setThemeMode(AppThemeMode.dark);
      var tokens = service.resolveActiveTokens();
      expect(tokens.surfaceColorHex, equals('#1E293B')); // Dark mode active

      // Super Admin forces Light Mode globally across the platform
      service.updateMasterConfig(
        const SuperAdminUiMasterConfig(
          isGlobalThemeOverride: true,
          forcedThemeMode: AppThemeMode.light,
        ),
      );

      // Now resolveActiveTokens returns forced Light Mode regardless of user preference
      tokens = service.resolveActiveTokens();
      expect(tokens.surfaceColorHex, equals('#FFFFFF')); // Forced Light mode
      expect(tokens.primaryColorHex, equals('#059669'));
    });

    test('8. High-Impact Financial Safety Confirmation (Zero Silent Execution)', () {
      // 1. High value operation (৳60,000 = 6,000,000 Poisha) without confirmation is BLOCKED
      final highValueUnconfirmed = service.validateFinancialActionSafety(
        actionType: 'savings_withdrawal',
        amountPoisha: 6000000,
        userConfirmed: false,
      );
      expect(highValueUnconfirmed.allowed, isFalse);
      expect(highValueUnconfirmed.requiresConfirmation, isTrue);
      expect(highValueUnconfirmed.warningMessageBn, contains('নিশ্চিতকরণ আবশ্যক'));

      // 2. High value operation with confirmation is ALLOWED
      final highValueConfirmed = service.validateFinancialActionSafety(
        actionType: 'savings_withdrawal',
        amountPoisha: 6000000,
        userConfirmed: true,
      );
      expect(highValueConfirmed.allowed, isTrue);
      expect(highValueConfirmed.requiresConfirmation, isFalse);

      // 3. Critical operation type (e.g. loan_disbursement) always requires confirmation
      final criticalUnconfirmed = service.validateFinancialActionSafety(
        actionType: 'loan_disbursement',
        amountPoisha: 1000000, // ৳10,000 (below 50k threshold, but critical type)
        userConfirmed: false,
      );
      expect(criticalUnconfirmed.allowed, isFalse);
      expect(criticalUnconfirmed.requiresConfirmation, isTrue);

      // 4. Low value standard operation without confirmation is ALLOWED immediately
      final regularOp = service.validateFinancialActionSafety(
        actionType: 'member_deposit',
        amountPoisha: 50000, // ৳500
        userConfirmed: false,
      );
      expect(regularOp.allowed, isTrue);
      expect(regularOp.requiresConfirmation, isFalse);
    });

    test('9. Role-Based Dashboard Widget Hierarchy Filtering', () {
      // 1. Member role only sees widgets requiring 'member'
      final memberWidgets = service.filterWidgetsForRole(
        userRole: 'member',
        isSuperAdmin: false,
      );
      expect(memberWidgets.any((w) => w.widgetId == 'widget_kpi_summary'), isTrue);
      expect(memberWidgets.any((w) => w.widgetId == 'widget_passbook_quickview'), isTrue);
      expect(memberWidgets.any((w) => w.widgetId == 'widget_collection_chart'), isFalse); // Requires accountant
      expect(memberWidgets.any((w) => w.widgetId == 'widget_audit_compliance_alerts'), isFalse); // Requires admin

      // 2. Accountant role sees member, field officer, and accountant widgets
      final accountantWidgets = service.filterWidgetsForRole(
        userRole: 'accountant',
        isSuperAdmin: false,
      );
      expect(accountantWidgets.any((w) => w.widgetId == 'widget_collection_chart'), isTrue);
      expect(accountantWidgets.any((w) => w.widgetId == 'widget_field_officer_tracker'), isTrue);
      expect(accountantWidgets.any((w) => w.widgetId == 'widget_audit_compliance_alerts'), isFalse);

      // 3. Super Admin sees all widgets
      final superAdminWidgets = service.filterWidgetsForRole(
        userRole: 'super_admin',
        isSuperAdmin: true,
      );
      expect(superAdminWidgets.length, equals(service.registeredWidgets.length));
    });

    test('10. Accessibility Font-Scale Multiplier & Reduced-Motion Preferences', () {
      // Standard font scale = 1.0x
      expect(service.getFontScaleFactor(), equals(1.0));

      // Set to Large = 1.30x
      service.setFontSize(AccessibilityFontSize.large);
      expect(service.getFontScaleFactor(), equals(1.30));

      // Extra Large = 1.50x
      service.setFontSize(AccessibilityFontSize.extraLarge);
      expect(service.getFontScaleFactor(), equals(1.50));

      // Reduced motion toggle
      expect(service.isReducedMotion, isFalse);
      service.setReducedMotion(true);
      expect(service.isReducedMotion, isTrue);
    });

    test('11. Core Dashboard Widget Protection Invariant', () {
      // Core widget (isCore == true) CANNOT be disabled
      final success = service.toggleWidgetEnabled('widget_kpi_summary', false);
      expect(success, isFalse); // Rejects disabling core widget

      final kpiWidget = service.registeredWidgets.firstWhere((w) => w.widgetId == 'widget_kpi_summary');
      expect(kpiWidget.isEnabled, isTrue);

      // Non-core widget CAN be disabled
      final nonCoreSuccess = service.toggleWidgetEnabled('widget_collection_chart', false);
      expect(nonCoreSuccess, isTrue);

      final chartWidget = service.registeredWidgets.firstWhere((w) => w.widgetId == 'widget_collection_chart');
      expect(chartWidget.isEnabled, isFalse);

      // Re-enable non-core widget
      service.toggleWidgetEnabled('widget_collection_chart', true);
    });

    test('12. Touch Target Minimum Dimension Compliance (>= 44x44px)', () {
      // Standard compliant touch target
      expect(service.verifyTouchTarget(48.0, 48.0), isTrue);
      expect(service.verifyTouchTarget(44.0, 44.0), isTrue);

      // Sub-minimum touch target fails
      expect(service.verifyTouchTarget(40.0, 44.0), isFalse);
      expect(service.verifyTouchTarget(44.0, 32.0), isFalse);
      expect(service.verifyTouchTarget(24.0, 24.0), isFalse);
    });
  });
}
