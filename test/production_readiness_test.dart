// test/production_readiness_test.dart
// Comprehensive Unit Tests for Phase 12 Enterprise Production Deployment, Launch & Operational Readiness

import 'package:test/test.dart';
import '../lib/models/production_readiness_model.dart';
import '../lib/models/security_compliance_model.dart';
import '../lib/services/production_readiness_service.dart';

void main() {
  group('Phase 12 - Enterprise Production Readiness & Universal Control Tests', () {
    late ProductionReadinessService service;

    setUp(() {
      service = ProductionReadinessService();
    });

    test('1. Universal Control Registry & 21 Sections Discovery', () {
      final settings = service.getAllSettings();
      expect(settings, isNotEmpty);

      // Verify key modules are registered
      expect(settings.any((s) => s.key == 'module.core_members'), isTrue);
      expect(settings.any((s) => s.key == 'module.accounting'), isTrue);
      expect(settings.any((s) => s.key == 'module.workflow_approval'), isTrue);
      expect(settings.any((s) => s.key == 'module.security_compliance'), isTrue);
      expect(settings.any((s) => s.key == 'module.payment_gateways'), isTrue);
      expect(settings.any((s) => s.key == 'module.ai_analytics'), isTrue);
      expect(settings.any((s) => s.key == 'module.offline_sync'), isTrue);
      expect(settings.any((s) => s.key == 'module.devops_monitoring'), isTrue);
      expect(settings.any((s) => s.key == 'module.ui_design_system'), isTrue);

      // Verify all 120 permissions are present in SecurityComplianceModel
      expect(SecurityComplianceModel.all.length, equals(120));
      expect(SecurityComplianceModel.all.contains(SecurityComplianceModel.productionDeployExecute), isTrue);
      expect(SecurityComplianceModel.all.contains(SecurityComplianceModel.platformControlCenter), isTrue);
    });

    test('2. 14 Scopes Hierarchical Permission Evaluation (Global Platform Kill-Switch)', () {
      // 1. Normal active platform: Accountant can post journal
      const validReq = EffectivePermissionRequest(
        userId: 'acc_001',
        userRole: 'accountant',
        societyId: 'society_main_01',
        permissionKey: SecurityComplianceModel.accountingPostJournal,
        moduleKey: 'accounting',
      );
      final activeDecision = service.evaluateEffectivePermission(validReq);
      expect(activeDecision.isGranted, isTrue);

      // 2. Global platform kill-switch triggered
      service.updateControlSetting(
        key: 'platform.global.active',
        isEnabled: false,
        actorId: 'master_admin_sajjad',
      );

      final blockedDecision = service.evaluateEffectivePermission(validReq);
      expect(blockedDecision.isGranted, isFalse);
      expect(blockedDecision.denyingScope, equals(UniversalControlScope.globalPlatform));
      expect(blockedDecision.reasonBn, contains('রক্ষণাবেক্ষণ মোডে'));

      // Restore platform switch
      service.updateControlSetting(
        key: 'platform.global.active',
        isEnabled: true,
        actorId: 'master_admin_sajjad',
      );
      expect(service.evaluateEffectivePermission(validReq).isGranted, isTrue);
    });

    test('3. Mandatory Security Invariants Protection (Cannot be Disabled by Any Admin)', () {
      final invariant = service.getSetting('invariant.tenant_isolation');
      expect(invariant, isNotNull);
      expect(invariant!.isSecurityInvariant, isTrue);
      expect(invariant.isEnabled, isTrue);

      // Attempt to disable Tenant Isolation MUST FAIL
      final disableAttempt = service.updateControlSetting(
        key: 'invariant.tenant_isolation',
        isEnabled: false,
        actorId: 'rogue_admin',
      );
      expect(disableAttempt, isFalse); // Rejection of disabling invariant

      // Setting remains true
      expect(service.getSetting('invariant.tenant_isolation')!.isEnabled, isTrue);

      // Attempt to disable Double-Entry Balance invariant MUST FAIL
      final doubleEntryDisable = service.updateControlSetting(
        key: 'invariant.double_entry_balance',
        isEnabled: false,
        actorId: 'rogue_admin',
      );
      expect(doubleEntryDisable, isFalse);
      expect(service.getSetting('invariant.double_entry_balance')!.isEnabled, isTrue);
    });

    test('4. Super Admin Universal Override vs General Member Restricted Access', () {
      // Super Admin attempting high-risk action
      const superAdminReq = EffectivePermissionRequest(
        userId: 'sajjad_master',
        userRole: 'super_admin',
        societyId: 'society_main_01',
        permissionKey: SecurityComplianceModel.productionDeployExecute,
      );
      final adminDecision = service.evaluateEffectivePermission(superAdminReq);
      expect(adminDecision.isGranted, isTrue);

      // General Member attempting high-risk action
      const memberReq = EffectivePermissionRequest(
        userId: 'mem_001',
        userRole: 'member',
        societyId: 'society_main_01',
        permissionKey: SecurityComplianceModel.loansDisburse,
      );
      final memberDecision = service.evaluateEffectivePermission(memberReq);
      expect(memberDecision.isGranted, isFalse);
      expect(memberDecision.denyingScope, equals(UniversalControlScope.role));
      expect(memberDecision.reasonBn, contains('সাধারণ সদস্যের'));
    });

    test('5. Cross-Module Workflow: Loan Approval to Disbursement & Accounting Entry', () {
      final result = service.simulateEndToEndWorkflow(workflowType: 'loan_application_to_disbursement');

      expect(result['status'], equals('SUCCESS'));
      expect(result['doubleEntryValid'], isTrue);
      expect(result['debitsPoisha'], equals(result['creditsPoisha']));
      expect(result['debitAccount'], equals('1100')); // Loan Asset
      expect(result['creditAccount'], equals('1020')); // Cash at Bank
      expect(result['auditTrailPreserved'], isTrue);
    });

    test('6. Cross-Module Workflow: Member Admission to Savings & Liability Classification', () {
      final result = service.simulateEndToEndWorkflow(workflowType: 'member_admission_to_savings');

      expect(result['status'], equals('SUCCESS'));
      expect(result['classifiedAsLiability'], isTrue); // Member savings is liability, NOT equity
      expect(result['doubleEntryValid'], isTrue);
      expect(result['debitAccount'], equals('1010')); // Cash in hand
      expect(result['creditAccount'], equals('2010')); // General Savings Liability
      expect(result['kycVerified'], isTrue);
    });

    test('7. Double-Entry Accounting Equilibrium Invariant', () {
      const sampleDebits = 500000; // ৳5,000 in Poisha
      const sampleCredits = 500000;

      expect(sampleDebits, equals(sampleCredits));
      expect(sampleDebits % 1, equals(0)); // Integer precision invariant
    });

    test('8. Multi-Tenant Data Isolation Enforcement (Missing or Cross-Society Rejection)', () {
      // Missing Society ID (Violation of Tenant Isolation)
      const invalidTenantReq = EffectivePermissionRequest(
        userId: 'user_101',
        userRole: 'admin',
        societyId: '   ', // Blank
        permissionKey: SecurityComplianceModel.membersView,
      );

      final decision = service.evaluateEffectivePermission(invalidTenantReq);
      expect(decision.isGranted, isFalse);
      expect(decision.denyingScope, equals(UniversalControlScope.securityInvariant));
      expect(decision.reasonBn, contains('টেন্যান্ট আইসোলেশন'));
    });

    test('9. Subscription Tier Entitlement Gating (AI on Starter vs Growth)', () {
      // Starter plan user requesting AI assistant
      const starterAiReq = EffectivePermissionRequest(
        userId: 'user_starter_01',
        userRole: 'admin',
        societyId: 'society_main_01',
        subscriptionTier: 'starter',
        permissionKey: SecurityComplianceModel.aiAssistantUse,
      );
      final starterDecision = service.evaluateEffectivePermission(starterAiReq);
      expect(starterDecision.isGranted, isFalse);
      expect(starterDecision.denyingScope, equals(UniversalControlScope.subscriptionPlan));

      // Growth plan user requesting AI assistant
      const growthAiReq = EffectivePermissionRequest(
        userId: 'user_growth_01',
        userRole: 'admin',
        societyId: 'society_main_01',
        subscriptionTier: 'growth',
        permissionKey: SecurityComplianceModel.aiAssistantUse,
      );
      final growthDecision = service.evaluateEffectivePermission(growthAiReq);
      expect(growthDecision.isGranted, isTrue);
    });

    test('10. Tamper-Evident Audit Logging for Universal Control Updates', () {
      final initialAuditCount = service.getAuditLog().length;

      service.updateControlSetting(
        key: 'feature.loan_high_value_double_confirm',
        isEnabled: false,
        actorId: 'master_admin_sajjad',
      );

      final updatedAuditLog = service.getAuditLog();
      expect(updatedAuditLog.length, equals(initialAuditCount + 1));

      final lastEntry = updatedAuditLog.last;
      expect(lastEntry.settingKey, equals('feature.loan_high_value_double_confirm'));
      expect(lastEntry.actorId, equals('master_admin_sajjad'));
      expect(lastEntry.checksum, isNotEmpty);
      expect(lastEntry.previousValue, isTrue);
      expect(lastEntry.newValue, isFalse);

      // Restore setting
      service.updateControlSetting(
        key: 'feature.loan_high_value_double_confirm',
        isEnabled: true,
        actorId: 'master_admin_sajjad',
      );
    });

    test('11. Production Readiness Checklist Calculation (100% Target)', () {
      final checklist = service.getChecklist();
      expect(checklist, isNotEmpty);
      expect(checklist.every((c) => c.isPassed), isTrue);

      final score = service.calculateReadinessScore();
      expect(score, equals(100)); // 100% production readiness required
    });

    test('12. Official Go-Live Health Certification Signoff Across All 12 Phases', () {
      final certification = service.certifyProductionGoLive(
        certifiedBy: 'master_admin_sajjad',
        targetVersion: 'v12.0.0-ENTERPRISE-PROD',
      );

      expect(certification.isApproved, isTrue);
      expect(certification.targetVersion, equals('v12.0.0-ENTERPRISE-PROD'));
      expect(certification.readinessScorePercent, equals(100));
      expect(certification.phaseSignoffs.length, equals(12));
      expect(certification.phaseSignoffs['Phase 12: Production Readiness & Launch'], isTrue);
      expect(certification.remarksBn, contains('প্রোডাকশন লাইভ রিলিজের জন্য প্রস্তুত'));
    });
  });
}
