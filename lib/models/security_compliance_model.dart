import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Comprehensive Granular Permission Registry Keys
class SecurityPermissions {
  // --- সদস্য ব্যবস্থাপনা (Members) ---
  static const String membersView = 'members.view';
  static const String membersCreate = 'members.create';
  static const String membersUpdate = 'members.update';
  static const String membersDelete = 'members.delete';
  static const String membersIdCard = 'members.id_card';
  static const String membersExport = 'members.export';

  // --- সঞ্চয় ব্যবস্থাপনা (Savings) ---
  static const String savingsView = 'savings.view';
  static const String savingsDeposit = 'savings.deposit';
  static const String savingsWithdraw = 'savings.withdraw';
  static const String savingsApproveWithdrawal = 'savings.approve_withdrawal';
  static const String savingsPassbookPrint = 'savings.passbook_print';

  // --- ঋণ ব্যবস্থাপনা (Loans) ---
  static const String loansView = 'loans.view';
  static const String loansCreate = 'loans.create';
  static const String loansApprove = 'loans.approve';
  static const String loansReject = 'loans.reject';
  static const String loansDisburse = 'loans.disburse';
  static const String loansRepay = 'loans.repay';
  static const String loansReschedule = 'loans.reschedule';

  // --- আর্থিক হিসাববিজ্ঞান (Accounting) ---
  static const String accountingView = 'accounting.view';
  static const String accountingCreateJournal = 'accounting.create_journal';
  static const String accountingPostJournal = 'accounting.post_journal';
  static const String accountingReverseJournal = 'accounting.reverse_journal';
  static const String accountingClosePeriod = 'accounting.close_period';
  static const String accountingReconcileBank = 'accounting.reconcile_bank';

  // --- ওয়ার্কফ্লো ও অনুমোদন (Workflows) ---
  static const String workflowSubmit = 'workflow.submit';
  static const String workflowApprove = 'workflow.approve';
  static const String workflowReject = 'workflow.reject';
  static const String workflowReturn = 'workflow.return';
  static const String workflowDelegate = 'workflow.delegate';
  static const String workflowEscalate = 'workflow.escalate';

  // --- সিকিউরিটি ও কমপ্লায়েন্স (Security & Compliance) ---
  static const String securityView = 'security.view';
  static const String securityManageRoles = 'security.manage_roles';
  static const String securityManagePermissions = 'security.manage_permissions';
  static const String securityManageSessions = 'security.manage_sessions';
  static const String securityViewAuditLogs = 'security.view_audit_logs';
  static const String securityManagePolicies = 'security.manage_policies';

  // --- সাবস্ক্রিপশন ও কমার্শিয়াল (SaaS & Commercial) ---
  static const String saasPlansView = 'saas.plans.view';
  static const String saasPlansManage = 'saas.plans.manage';
  static const String saasSubscriptionsView = 'saas.subscriptions.view';
  static const String saasSubscriptionsManage = 'saas.subscriptions.manage';
  static const String saasInvoicesView = 'saas.invoices.view';
  static const String saasInvoicesCreate = 'saas.invoices.create';
  static const String saasPaymentsVerify = 'saas.payments.verify';
  static const String saasDiscountsManage = 'saas.discounts.manage';
  static const String saasAnalyticsView = 'saas.analytics.view';

  // --- ফেজ ৬: এন্টারপ্রাইজ সমিতি অপারেশনস (CRM, KYC, HR, Payroll, Inventory, Assets) ---
  static const String crmLeadsView = 'crm.leads.view';
  static const String crmLeadsManage = 'crm.leads.manage';
  static const String membersLifecycleManage = 'members.lifecycle.manage';
  static const String kycVerificationView = 'kyc.verification.view';
  static const String kycVerificationManage = 'kyc.verification.manage';
  static const String documentsStorageManage = 'documents.storage.manage';
  static const String hrEmployeesManage = 'hr.employees.manage';
  static const String attendanceRecordsManage = 'attendance.records.manage';
  static const String leaveRequestsManage = 'leave.requests.manage';
  static const String payrollProcessingManage = 'payroll.processing.manage';
  static const String inventoryStockManage = 'inventory.stock.manage';
  static const String assetsRegisterManage = 'assets.register.manage';
  static const String procurementOrdersManage = 'procurement.orders.manage';
  static const String operationsTasksManage = 'operations.tasks.manage';

  // --- ফেজ ৭: এন্টারপ্রাইজ পেমেন্ট, ব্যাংকিং ও আর্থিক ইন্টিগ্রেশন ---
  static const String paymentsGatewayManage = 'payments.gateway.manage';
  static const String paymentsTransactionsView = 'payments.transactions.view';
  static const String paymentsTransactionsVerify = 'payments.transactions.verify';
  static const String paymentsRefundManage = 'payments.refund.manage';
  static const String bankingAccountsManage = 'banking.accounts.manage';
  static const String bankingReconcileManage = 'banking.reconcile.manage';
  static const String qrPaymentsManage = 'qr.payments.manage';
  static const String collectionsFieldManage = 'collections.field.manage';
  static const String settlementsGatewayManage = 'settlements.gateway.manage';

  // --- ফেজ ৮: এন্টারপ্রাইজ এআই, অ্যাডভান্সড অ্যানালিটিক্স ও বিজনেস ইন্টেলিজেন্স ---
  static const String aiDashboardView = 'ai.dashboard.view';
  static const String aiAssistantUse = 'ai.assistant.use';
  static const String aiAssistantConfigure = 'ai.assistant.configure';
  static const String aiSearchUse = 'ai.search.use';
  static const String aiReportsGenerate = 'ai.reports.generate';
  static const String analyticsDashboardView = 'analytics.dashboard.view';
  static const String analyticsPredictionsView = 'analytics.predictions.view';
  static const String riskFraudAlertsManage = 'risk.fraud_alerts.manage';
  static const String reportsCustomBuilder = 'reports.custom.builder';
  static const String aiProvidersManage = 'ai.providers.manage';

  // --- ফেজ ৯: এন্টারপ্রাইজ অফলাইন-ফার্স্ট আর্কিটেকচার ও ফিল্ড অপারেশনস ---
  static const String offlineAccessEnable = 'offline.access.enable';
  static const String offlineMembersView = 'offline.members.view';
  static const String offlineCollectionsCreate = 'offline.collections.create';
  static const String offlineReceiptGenerate = 'offline.receipt.generate';
  static const String syncQueueManage = 'sync.queue.manage';
  static const String syncConflictsResolve = 'sync.conflicts.resolve';
  static const String fieldRoutesManage = 'field.routes.manage';
  static const String fieldCashReconcile = 'field.cash.reconcile';
  static const String deviceManagementControl = 'device.management.control';
  static const String mobileLocationAccess = 'mobile.location.access';

  // --- ফেজ ১০: এন্টারপ্রাইজ সিস্টেম মনিটরিং, ডেভঅপস, ব্যাকআপ ও ডিজাস্টার রিকভারি ---
  static const String systemDashboardView = 'system.dashboard.view';
  static const String monitoringManage = 'monitoring.manage';
  static const String monitoringLogsView = 'monitoring.logs.view';
  static const String monitoringErrorsView = 'monitoring.errors.view';
  static const String monitoringAlertsManage = 'monitoring.alerts.manage';
  static const String backupView = 'backup.view';
  static const String backupCreate = 'backup.create';
  static const String backupVerify = 'backup.verify';
  static const String backupRestoreExecute = 'backup.restore.execute';
  static const String disasterRecoveryManage = 'disaster_recovery.manage';
  static const String deploymentPipelineManage = 'deployment.pipeline.manage';
  static const String maintenanceModeControl = 'maintenance.mode.control';

  // --- ফেজ ১১: এন্টারপ্রাইজ ইউআই/ইউএক্স আধুনিকায়ন, ডিজাইন সিস্টেম ও অ্যাক্সেসিবিলিটি ---
  static const String uiDashboardView = 'ui.dashboard.view';
  static const String uiDashboardConfigure = 'ui.dashboard.configure';
  static const String uiDashboardWidgetsManage = 'ui.dashboard.widgets.manage';
  static const String uiNavigationConfigure = 'ui.navigation.configure';
  static const String uiThemeChange = 'ui.theme.change';
  static const String uiLanguageChange = 'ui.language.change';
  static const String uiAccessibilityConfigure = 'ui.accessibility.configure';
  static const String uiResponsiveLayout = 'ui.responsive.layout';
  static const String uiFormsValidate = 'ui.forms.validate';
  static const String uiTablesCustomize = 'ui.tables.customize';
  static const String uiSearchGlobal = 'ui.search.global';
  static const String uiComponentsManage = 'ui.components.manage';

  // Phase 12: Enterprise Production Deployment, Launch & Operational Readiness
  static const String productionDeployExecute = 'production.deploy.execute';
  static const String productionDeployRollback = 'production.deploy.rollback';
  static const String productionMigrationExecute = 'production.migration.execute';
  static const String productionHealthCertify = 'production.health.certify';
  static const String platformUniversalOverride = 'platform.universal.override';
  static const String platformControlCenter = 'platform.control.center';
  static const String platformAuditExport = 'platform.audit.export';
  static const String platformEmergencyLockdown = 'platform.emergency.lockdown';

  // Phase 13: Enterprise Advanced QA, Security Audit & Continuous Testing Engine
  static const String qaDashboardView = 'qa.dashboard.view';
  static const String qaSuitesExecute = 'qa.suites.execute';
  static const String qaRegressionRun = 'qa.regression.run';
  static const String qaSecurityAuditRun = 'qa.security_audit.run';
  static const String qaFinancialVerify = 'qa.financial.verify';
  static const String qaDefectsManage = 'qa.defects.manage';
  static const String qaQualityGatesConfigure = 'qa.quality_gates.configure';
  static const String qaReportsExport = 'qa.reports.export';

  // Phase 14: Enterprise Customer Support, Helpdesk & Service Management Engine
  static const String helpdeskDashboardView = 'helpdesk.dashboard.view';
  static const String helpdeskTicketsCreate = 'helpdesk.tickets.create';
  static const String helpdeskTicketsManage = 'helpdesk.tickets.manage';
  static const String helpdeskTicketsAssign = 'helpdesk.tickets.assign';
  static const String helpdeskSlaConfigure = 'helpdesk.sla.configure';
  static const String helpdeskChatParticipate = 'helpdesk.chat.participate';
  static const String helpdeskComplaintsManage = 'helpdesk.complaints.manage';
  static const String helpdeskKnowledgeBaseManage = 'helpdesk.knowledge_base.manage';
  static const String helpdeskFeedbackView = 'helpdesk.feedback.view';
  static const String helpdeskAutomationConfigure = 'helpdesk.automation.configure';

  // Phase 15: Enterprise API, Developer Portal & Third-Party Integration Ecosystem
  static const String apiGatewayDashboardView = 'api.gateway.dashboard.view';
  static const String apiKeysManage = 'api.keys.manage';
  static const String apiOAuthClientsManage = 'api.oauth_clients.manage';
  static const String apiScopesConfigure = 'api.scopes.configure';
  static const String apiWebhooksManage = 'api.webhooks.manage';
  static const String apiSandboxAccess = 'api.sandbox.access';
  static const String apiDocumentationView = 'api.documentation.view';
  static const String apiRateLimitsConfigure = 'api.rate_limits.configure';
  static const String apiUsageAnalyticsView = 'api.usage_analytics.view';
  static const String apiIntegrationsManage = 'api.integrations.manage';

  // Phase 16: Enterprise White-Label SaaS & Society Customization Engine
  static const String whiteLabelDashboardView = 'whitelabel.dashboard.view';
  static const String societyBrandingManage = 'whitelabel.branding.manage';
  static const String societyThemeConfigure = 'whitelabel.theme.configure';
  static const String societyCustomDomainManage = 'whitelabel.domain.manage';
  static const String societyDocumentTemplatesManage = 'whitelabel.templates.documents.manage';
  static const String societyNotificationTemplatesManage = 'whitelabel.templates.notifications.manage';
  static const String societyBusinessConfigManage = 'whitelabel.business.config.manage';
  static const String whiteLabelAssetsUpload = 'whitelabel.assets.upload';
  static const String whiteLabelRollbackExecute = 'whitelabel.rollback.execute';
  static const String whiteLabelEntitlementsManage = 'whitelabel.entitlements.manage';

  // Phase 17: Enterprise Data Warehouse & Advanced Intelligence Platform
  static const String dwDashboardView = 'dw.dashboard.view';
  static const String dwPipelinesManage = 'dw.pipelines.manage';
  static const String dwFinancialReconcile = 'dw.financial.reconcile';
  static const String dwBiDashboardsManage = 'dw.bi.dashboards.manage';
  static const String dwBenchmarkingAccess = 'dw.benchmarking.access';
  static const String dwExportsManage = 'dw.exports.manage';
  static const String dwArchivalExecute = 'dw.archival.execute';
  static const String dwLineageInspect = 'dw.lineage.inspect';
  static const String dwQualityAudit = 'dw.quality.audit';
  static const String dwRetentionConfigure = 'dw.retention.configure';

  // Phase 18: Enterprise Member Super App & Digital Self-Service Ecosystem
  static const String memberAppAccess = 'member.app.access';
  static const String memberProfileSelfManage = 'member.profile.self.manage';
  static const String memberKycSubmit = 'member.kyc.submit';
  static const String memberDigitalCardView = 'member.digital.card.view';
  static const String memberSavingsSelfService = 'member.savings.self.service';
  static const String memberWithdrawalApply = 'member.withdrawal.apply';
  static const String memberLoansSelfService = 'member.loans.self.service';
  static const String memberLoanApply = 'member.loan.apply';
  static const String memberOnlinePayment = 'member.online.payment';
  static const String memberServiceTicketsManage = 'member.service.tickets.manage';

  // Phase 19: Enterprise Cooperative Governance, Audit & Regulatory Compliance
  static const String govCommitteesManage = 'gov.committees.manage';
  static const String govMeetingsManage = 'gov.meetings.manage';
  static const String govAgmManage = 'gov.agm.manage';
  static const String govResolutionsManage = 'gov.resolutions.manage';
  static const String govElectionsManage = 'gov.elections.manage';
  static const String govInternalAuditManage = 'gov.internal.audit.manage';
  static const String govFinancialAuditManage = 'gov.financial.audit.manage';
  static const String govRegulatoryComplianceManage = 'gov.regulatory.compliance.manage';
  static const String govComplianceCalendarManage = 'gov.compliance.calendar.manage';
  static const String govDocumentsManage = 'gov.documents.manage';

  // Phase 20: Enterprise Automation & Autonomous Operations Engine
  static const String autoWorkflowsManage = 'auto.workflows.manage';
  static const String autoTriggersConfigure = 'auto.triggers.configure';
  static const String autoActionsConfigure = 'auto.actions.configure';
  static const String autoSchedulerManage = 'auto.scheduler.manage';
  static const String autoExecutionsView = 'auto.executions.view';
  static const String autoRetryQueueManage = 'auto.retry.queue.manage';
  static const String autoApprovalsProcess = 'auto.approvals.process';
  static const String autoAiAssistedConfigure = 'auto.ai.assisted.configure';
  static const String autoMonitoringView = 'auto.monitoring.view';
  static const String autoPoliciesManage = 'auto.policies.manage';

  /// Authoritative list of all 198 granular permission keys
  static const List<String> all = [
    membersView, membersCreate, membersUpdate, membersDelete, membersIdCard, membersExport,
    savingsView, savingsDeposit, savingsWithdraw, savingsApproveWithdrawal, savingsPassbookPrint,
    loansView, loansCreate, loansApprove, loansReject, loansDisburse, loansRepay, loansReschedule,
    accountingView, accountingCreateJournal, accountingPostJournal, accountingReverseJournal, accountingClosePeriod, accountingReconcileBank,
    workflowSubmit, workflowApprove, workflowReject, workflowReturn, workflowDelegate, workflowEscalate,
    securityView, securityManageRoles, securityManagePermissions, securityManageSessions, securityViewAuditLogs, securityManagePolicies,
    saasPlansView, saasPlansManage, saasSubscriptionsView, saasSubscriptionsManage, saasInvoicesView, saasInvoicesCreate, saasPaymentsVerify, saasDiscountsManage, saasAnalyticsView,
    crmLeadsView, crmLeadsManage, membersLifecycleManage, kycVerificationView, kycVerificationManage, documentsStorageManage,
    hrEmployeesManage, attendanceRecordsManage, leaveRequestsManage, payrollProcessingManage, inventoryStockManage, assetsRegisterManage, procurementOrdersManage, operationsTasksManage,
    paymentsGatewayManage, paymentsTransactionsView, paymentsTransactionsVerify, paymentsRefundManage, bankingAccountsManage, bankingReconcileManage, qrPaymentsManage, collectionsFieldManage, settlementsGatewayManage,
    aiDashboardView, aiAssistantUse, aiAssistantConfigure, aiSearchUse, aiReportsGenerate, analyticsDashboardView, analyticsPredictionsView, riskFraudAlertsManage, reportsCustomBuilder, aiProvidersManage,
    offlineAccessEnable, offlineMembersView, offlineCollectionsCreate, offlineReceiptGenerate, syncQueueManage, syncConflictsResolve, fieldRoutesManage, fieldCashReconcile, deviceManagementControl, mobileLocationAccess,
    systemDashboardView, monitoringManage, monitoringLogsView, monitoringErrorsView, monitoringAlertsManage, backupView, backupCreate, backupVerify, backupRestoreExecute, disasterRecoveryManage, deploymentPipelineManage, maintenanceModeControl,
    uiDashboardView, uiDashboardConfigure, uiDashboardWidgetsManage, uiNavigationConfigure, uiThemeChange, uiLanguageChange, uiAccessibilityConfigure, uiResponsiveLayout, uiFormsValidate, uiTablesCustomize, uiSearchGlobal, uiComponentsManage,
    productionDeployExecute, productionDeployRollback, productionMigrationExecute, productionHealthCertify, platformUniversalOverride, platformControlCenter, platformAuditExport, platformEmergencyLockdown,
    qaDashboardView, qaSuitesExecute, qaRegressionRun, qaSecurityAuditRun, qaFinancialVerify, qaDefectsManage, qaQualityGatesConfigure, qaReportsExport,
    helpdeskDashboardView, helpdeskTicketsCreate, helpdeskTicketsManage, helpdeskTicketsAssign, helpdeskSlaConfigure, helpdeskChatParticipate, helpdeskComplaintsManage, helpdeskKnowledgeBaseManage, helpdeskFeedbackView, helpdeskAutomationConfigure,
    apiGatewayDashboardView, apiKeysManage, apiOAuthClientsManage, apiScopesConfigure, apiWebhooksManage, apiSandboxAccess, apiDocumentationView, apiRateLimitsConfigure, apiUsageAnalyticsView, apiIntegrationsManage,
    whiteLabelDashboardView, societyBrandingManage, societyThemeConfigure, societyCustomDomainManage, societyDocumentTemplatesManage, societyNotificationTemplatesManage, societyBusinessConfigManage, whiteLabelAssetsUpload, whiteLabelRollbackExecute, whiteLabelEntitlementsManage,
    dwDashboardView, dwPipelinesManage, dwFinancialReconcile, dwBiDashboardsManage, dwBenchmarkingAccess, dwExportsManage, dwArchivalExecute, dwLineageInspect, dwQualityAudit, dwRetentionConfigure,
    memberAppAccess, memberProfileSelfManage, memberKycSubmit, memberDigitalCardView, memberSavingsSelfService, memberWithdrawalApply, memberLoansSelfService, memberLoanApply, memberOnlinePayment, memberServiceTicketsManage,
    govCommitteesManage, govMeetingsManage, govAgmManage, govResolutionsManage, govElectionsManage, govInternalAuditManage, govFinancialAuditManage, govRegulatoryComplianceManage, govComplianceCalendarManage, govDocumentsManage,
    autoWorkflowsManage, autoTriggersConfigure, autoActionsConfigure, autoSchedulerManage, autoExecutionsView, autoRetryQueueManage, autoApprovalsProcess, autoAiAssistedConfigure, autoMonitoringView, autoPoliciesManage,
  ];

  static String getTitleBn(String key) {
    switch (key) {
      case membersView: return 'সদস্য তালিকা ও পাসবুক দেখা';
      case membersCreate: return 'নতুন সদস্য নিবন্ধন';
      case membersUpdate: return 'সদস্য তথ্য সম্পাদন';
      case membersDelete: return 'সদস্য নিষ্ক্রিয়/বাতিলকরণ';
      case membersIdCard: return 'ডিজিটাল আইডি কার্ড প্রিন্ট';
      case membersExport: return 'সদস্য ডাটা এক্সপোর্ট';

      case savingsView: return 'সঞ্চয় ব্যালেন্স ও তালিকা দেখা';
      case savingsDeposit: return 'সঞ্চয় কিস্তি জমা গ্রহণ';
      case savingsWithdraw: return 'সঞ্চয় উত্তোলন আবেদন';
      case savingsApproveWithdrawal: return 'সঞ্চয় উত্তোলন অনুমোদন';
      case savingsPassbookPrint: return 'পাসবুক ও মানি রসিদ প্রিন্ট';

      case loansView: return 'ঋণ তালিকা ও কিস্তি সূচি দেখা';
      case loansCreate: return 'নতুন ঋণের আবেদন প্রস্তুত';
      case loansApprove: return 'ঋণের আবেদন অনুমোদন';
      case loansReject: return 'ঋণের আবেদন বাতিল';
      case loansDisburse: return 'ঋণ বিতরণ (Disbursement)';
      case loansRepay: return 'ঋণের কিস্তি আদায়';
      case loansReschedule: return 'কিস্তি পুনর্গঠন ও মওকুফ';

      case accountingView: return 'হিসাব খতিয়ান ও চার্ট দেখা';
      case accountingCreateJournal: return 'খসড়া ভাউচার তৈরি';
      case accountingPostJournal: return 'ভাউচার লেজারে পোস্টিং';
      case accountingReverseJournal: return 'ভাউচার বিপরীত দাখিলা';
      case accountingClosePeriod: return 'হিসাবকাল বন্ধ (Period Close)';
      case accountingReconcileBank: return 'ব্যাংক বিবরণী সমন্বয়';

      case workflowSubmit: return 'অনুমোদন আবেদন দাখিল';
      case workflowApprove: return 'ওয়ার্কফ্লো ধাপ অনুমোদন';
      case workflowReject: return 'ওয়ার্কফ্লো আবেদন বাতিল';
      case workflowReturn: return 'সংশোধনে ফেরত পাঠানো';
      case workflowDelegate: return 'অনুমোদন ক্ষমতা অর্পণ';
      case workflowEscalate: return 'উচ্চতর পর্যায়ে এস্কেলেশন';

      case securityView: return 'সিকিউরিটি ড্যাশবোর্ড দেখা';
      case securityManageRoles: return 'রোল ও পারমিশন ম্যাপিং';
      case securityManagePermissions: return 'সার্বজনীন পারমিশন কন্ট্রোল';
      case securityManageSessions: return 'সেশন ও ডিভাইস ম্যানেজমেন্ট';
      case securityViewAuditLogs: return 'অডিট লগ ও হিস্ট্রি দেখা';
      case securityManagePolicies: return 'এমএফএ ও সিকিউরিটি পলিসি';

      case saasPlansView: return 'সাবস্ক্রিপশন প্ল্যান ও প্রাইসিং দেখা';
      case saasPlansManage: return 'প্ল্যান তৈরি ও ফিচার কনফিগারেশন';
      case saasSubscriptionsView: return 'সমিতি সাবস্ক্রিপশন স্ট্যাটাস ভিউ';
      case saasSubscriptionsManage: return 'সাবস্ক্রিপশন আপগ্রেড, নবায়ন ও স্থগিত';
      case saasInvoicesView: return 'বিলিং ইনভয়েস ও মেমো তালিকা';
      case saasInvoicesCreate: return 'নতুন বিলিং ইনভয়েস ইস্যু';
      case saasPaymentsVerify: return 'পেমেন্ট গেটওয়ে যাচাই ও ছাড়পত্র';
      case saasDiscountsManage: return 'কুপন কোড ও ছাড় ব্যবস্থাপনা';
      case saasAnalyticsView: return 'MRR ও কমার্শিয়াল রাজস্ব রিপোর্ট';

      case crmLeadsView: return 'CRM প্রসপেক্ট ও লিড পাইপলাইন দেখা';
      case crmLeadsManage: return 'CRM লিড তৈরি, ফলো-আপ ও রূপান্তর';
      case membersLifecycleManage: return 'সদস্য অনুমোদন, স্থগিত ও বহিষ্কার পরিচালনা';
      case kycVerificationView: return 'KYC জাতীয় পরিচয়পত্র ও পাসপোর্ট ফাইল দেখা';
      case kycVerificationManage: return 'KYC আবেদন যাচাই, অনুমোদন ও বাতিল';
      case documentsStorageManage: return 'সমিতি ফাইল ও নথিপত্র আপলোড/ডাউনলোড';
      case hrEmployeesManage: return 'কর্মকর্তা প্রোফাইল, বিভাগ ও পদবি পরিচালনা';
      case attendanceRecordsManage: return 'দৈনিক উপস্থিতি ও সংশোধন এন্ট্রি';
      case leaveRequestsManage: return 'ছুটির আবেদন যাচাই ও অনুমোদন';
      case payrollProcessingManage: return 'মাসিক বেতন হিসাব ও ভাউচার পোস্টিং';
      case inventoryStockManage: return 'স্টক মালামাল ইনওয়ার্ড, আউটওয়ার্ড ও সমন্বয়';
      case assetsRegisterManage: return 'স্থাবর সম্পত্তি রেজিস্ট্রি ও অবচয় ট্র্যাকিং';
      case procurementOrdersManage: return 'ক্রয় প্রস্তাব, ভেন্ডর অর্ডার ও মালামাল রিসিভ';
      case operationsTasksManage: return 'দাপ্তরিক ও ফিল্ড টাস্ক অ্যাসাইনমেন্ট';

      case paymentsGatewayManage: return 'পেমেন্ট গেটওয়ে সক্রিয় ও কনফিগারেশন';
      case paymentsTransactionsView: return 'অনলাইন লেনদেন ও পেমেন্ট হিস্ট্রি দেখা';
      case paymentsTransactionsVerify: return 'পেমেন্ট ভেরিফিকেশন ও ছাড়পত্র';
      case paymentsRefundManage: return 'পেমেন্ট রিফান্ড ও রিভার্সাল ব্যবস্থাপনা';
      case bankingAccountsManage: return 'সমিতি ব্যাংক একাউন্ট পরিচালনা';
      case bankingReconcileManage: return 'ব্যাংক বিবরণী আপলোড ও সমন্বয়করণ';
      case qrPaymentsManage: return 'ডাইনামিক বাংলা কিউআর ও পেমেন্ট টোকেন';
      case collectionsFieldManage: return 'মাঠ পর্যায় কালেকশন ও রসিদ যাচাই';
      case settlementsGatewayManage: return 'গেটওয়ে সেটেলমেন্ট রিপোর্ট ও কমিশন নিরীক্ষা';

      case aiDashboardView: return 'এআই ড্যাশবোর্ড ও চ্যাট পর্যবেক্ষণ';
      case aiAssistantUse: return 'এআই অ্যাসিস্ট্যান্ট চ্যাট ব্যবহার';
      case aiAssistantConfigure: return 'এআই অ্যাসিস্ট্যান্ট কনফিগারেশন';
      case aiSearchUse: return 'এআই চালিত স্মার্ট ও ডকুমেন্ট সার্চ';
      case aiReportsGenerate: return 'এআই চালিত স্বয়ংক্রিয় রিপোর্ট ও সারাংশ';
      case analyticsDashboardView: return 'উন্নত আর্থিক ও প্রাতিষ্ঠানিক অ্যানালিটিক্স দেখা';
      case analyticsPredictionsView: return 'ভবিষ্যদ্বাণী ও আর্থিক পূর্বাভাস দেখা';
      case riskFraudAlertsManage: return 'প্রতারণা ও অসঙ্গতি (Anomaly) অ্যালার্ট ব্যবস্থাপনা';
      case reportsCustomBuilder: return 'কাস্টম রিপোর্ট বিল্ডার ও এক্সপোর্ট';
      case aiProvidersManage: return 'এআই মডেল ও প্রোভাইডার সেটিংস কন্ট্রোল';

      case offlineAccessEnable: return 'অফলাইন মোড ও লোকাল ডেটা এক্সেস';
      case offlineMembersView: return 'অফলাইনে সদস্য প্রোফাইল ও ব্যালেন্স দেখা';
      case offlineCollectionsCreate: return 'অফলাইন ফিল্ড কালেকশন এন্ট্রি';
      case offlineReceiptGenerate: return 'অফলাইন সাময়িক রসিদ প্রস্তুত';
      case syncQueueManage: return 'সিঙ্ক কিউ ব্যবস্থাপনা ও ম্যানুয়াল সিঙ্ক';
      case syncConflictsResolve: return 'সিঙ্ক কনফ্লিক্ট ও ডেটা রিভিউ সমাধান';
      case fieldRoutesManage: return 'মাঠ অফিসার রুট ও ভিজিট প্ল্যানিং';
      case fieldCashReconcile: return 'ফিল্ড ক্যাশ ও ক্যাশিয়ার সমন্বয়করণ';
      case deviceManagementControl: return 'ডিভাইস রেজিস্ট্রেশন ও অনুমোদন নিয়ন্ত্রণ';
      case mobileLocationAccess: return 'মাঠ পর্যায় জিপিএস ও লোকেশন যাচাই';

      case systemDashboardView: return 'সিস্টেম হেলথ ও ইনফ্রাস্ট্রাকচার মেট্রিক্স পর্যবেক্ষণ';
      case monitoringManage: return 'মনিটরিং কনফিগারেশন ও সার্ভিস কন্ট্রোল';
      case monitoringLogsView: return 'সেন্ট্রালাইজড সিস্টেম অডিট ও অ্যাপ্লিকেশন লগ ভিউ';
      case monitoringErrorsView: return 'এরর ট্র্যাকিং ও স্ট্যাকট্রেস পরিদর্শন';
      case monitoringAlertsManage: return 'সিস্টেম অ্যালার্ট ও নোটিফিকেশন রুলস কন্ট্রোল';
      case backupView: return 'ক্লাউড ব্যাকআপ হিস্ট্রি ও মেটাডাটা দেখা';
      case backupCreate: return 'ম্যানুয়াল অন-ডিমান্ড ব্যাকআপ তৈরি';
      case backupVerify: return 'ব্যাকআপ ফাইল ইন্টিগ্রিটি ও চেকবক্স ভেরিফিকেশন';
      case backupRestoreExecute: return 'ডাটাবেস রিস্টোর ও রিকভারি এক্সিকিউশন';
      case disasterRecoveryManage: return 'ডিজাস্টার রিকভারি ও BCP প্ল্যান নিয়ন্ত্রণ';
      case deploymentPipelineManage: return 'CI/CD রিলিজ, ডিপ্লয়মেন্ট ও রোলব্যাক ম্যানেজমেন্ট';
      case maintenanceModeControl: return 'প্ল্যাটফর্ম মেইনটেন্যান্স মোড ও বাইপাস সুইচ';

      case uiDashboardView: return 'মডার্ন ড্যাশবোর্ড ও অ্যানালিটিক্স উইজেট দর্শন';
      case uiDashboardConfigure: return 'ড্যাশবোর্ড লেআউট ও উইজেট পারমিশন কনফিগার';
      case uiDashboardWidgetsManage: return 'ড্যাশবোর্ড উইজেট সক্রিয়করণ ও বিন্যাস নিয়ন্ত্রণ';
      case uiNavigationConfigure: return 'ন্যাভিগেশন বার, ড্রয়ার ও মেনু দৃশ্যমানতা নিয়ন্ত্রণ';
      case uiThemeChange: return 'থিম পরিবর্তন (লাইট, ডার্ক ও হাই-কন্ট্রাস্ট মোড)';
      case uiLanguageChange: return 'প্ল্যাটফর্ম ভাষা পরিবর্তন (বাংলা / English)';
      case uiAccessibilityConfigure: return 'অ্যাক্সেসিবিলিটি সেটিংস ও টেক্সট স্কেলিং কন্ট্রোল';
      case uiResponsiveLayout: return 'রেসপনসিভ লেআউট ও ডিভাইস অ্যাডাপ্টেশন কনফিগার';
      case uiFormsValidate: return 'আর্থিক ফর্ম সেফটি নিশ্চিতকরণ ও ভ্যালিডেশন';
      case uiTablesCustomize: return 'ডাটা গ্রিড সর্টিং ও কলাম কাস্টমাইজেশন';
      case uiSearchGlobal: return 'গ্লোবাল সার্চ হাব ও টেন্যান্ট-আইসোলেটেড কুয়েরি';
      case uiComponentsManage: return 'ডিজাইন সিস্টেম কম্পোনেন্ট লাইব্রেরি ও টোকেন ম্যানেজমেন্ট';

      case productionDeployExecute: return 'প্রোডাকশন ডেপ্লয়মেন্ট রিলিজ ও পাবলিশ এক্সিকিউশন';
      case productionDeployRollback: return 'ইমার্জেন্সি ডেপ্লয়মেন্ট ইনস্ট্যান্ট রোলব্যাক কন্ট্রোল';
      case productionMigrationExecute: return 'ডাটাবেস লাইভ মাইগ্রেশন ও স্কিমা আপগ্রেড';
      case productionHealthCertify: return 'প্ল্যাটফর্ম হেলথ সার্টিফিকেশন ও গো-লাইভ সাইনঅফ';
      case platformUniversalOverride: return 'সার্বজনীন সুপার এডমিন ওভাররাইড ও মাস্টার কন্ট্রোল';
      case platformControlCenter: return '২১-সেকশন সেন্ট্রালাইজড প্ল্যাটফর্ম কন্ট্রোল সেন্টার অ্যাক্সেস';
      case platformAuditExport: return 'সার্বজনীন প্ল্যাটফর্ম অডিট ট্রেইল ও রেগুলেটরি এক্সপোর্ট';
      case platformEmergencyLockdown: return 'জরুরি প্ল্যাটফর্ম লকডাউন ও সিকিউরিটি আইসোলেশন';

      case qaDashboardView: return 'কিউএ ও সিকিউরিটি অডিট ড্যাশবোর্ড দেখা';
      case qaSuitesExecute: return 'স্বয়ংক্রিয় টেস্ট স্যুট ও টেস্ট কেস চালনা';
      case qaRegressionRun: return 'রিগ্রেশন টেস্ট স্যুট ও ইন্টিগ্রেশন চেক';
      case qaSecurityAuditRun: return 'এন্টারপ্রাইজ সিকিউরিটি অডিট ও ভালনারেবিলিটি স্ক্যান';
      case qaFinancialVerify: return 'দ্বৈত-দাখিলা ও আর্থিক হিসাবরক্ষণ রিকনসিলিয়েশন ভেরিফিকেশন';
      case qaDefectsManage: return 'ডিফেক্ট ট্র্যাকিং, অগ্রাধিকার নির্ধারণ ও বাগ সমাধান';
      case qaQualityGatesConfigure: return 'CI/CD কোয়ালিটি গেটস ও রিলিজ ব্লকার কনফিগারেশন';
      case qaReportsExport: return 'কিউএ এক্সিকিউটিভ রিপোর্ট ও কমপ্লায়েন্স ডাটা এক্সপোর্ট';

      case helpdeskDashboardView: return 'কাস্টমার সাপোর্ট ও হেল্পডেস্ক ড্যাশবোর্ড দেখা';
      case helpdeskTicketsCreate: return 'নতুন সাপোর্ট টিকেট ও সেবা অনুসন্ধান দাখিল';
      case helpdeskTicketsManage: return 'সাপোর্ট টিকেট ট্র্যাকিং, স্ট্যাটাস পরিবর্তন ও রেসপন্স';
      case helpdeskTicketsAssign: return 'টিকেট ডিপার্টমেন্ট ও সাপোর্ট এজেন্ট অ্যাসাইনমেন্ট';
      case helpdeskSlaConfigure: return 'এসএলএ পলিসি, এস্কেলেশন ম্যাট্রিক্স ও ক্যালেন্ডার কনফিগারেশন';
      case helpdeskChatParticipate: return 'লাইভ সাপোর্ট চ্যাট ও তাৎক্ষণিক বার্তা আদান-প্রদান';
      case helpdeskComplaintsManage: return 'গোপনীয় অভিযোগ ও গ্রিভেন্স সেল তদন্ত ও প্রতিকার';
      case helpdeskKnowledgeBaseManage: return 'নলেজ বেস নিবন্ধ, এফএকিউ ও টিউটোরিয়াল ব্যবস্থাপনা';
      case helpdeskFeedbackView: return 'গ্রাহক সন্তুষ্টি (CSAT) ও সেবা পর্যালোচনা বিশ্লেষণ';
      case helpdeskAutomationConfigure: return 'সাপোর্ট অটোমেশন রুলস ও নোটিফিকেশন ট্রিগার কনফিগার';

      case apiGatewayDashboardView: return 'এন্টারপ্রাইজ এপিআই গেটওয়ে ও মনিটরিং ড্যাশবোর্ড দেখা';
      case apiKeysManage: return 'এপিআই কি জেনারেশন, রোটেশন, রিভোকেশন ও ব্যবস্থাপনা';
      case apiOAuthClientsManage: return 'ওঅথ ২.০ ক্লায়েন্ট অ্যাপ্লিকেশন নিবন্ধন ও স্কোপ কন্ট্রোল';
      case apiScopesConfigure: return 'গ্র্যানুলার এপিআই পারমিশন ও এক্সেস স্কোপ কনফিগারেশন';
      case apiWebhooksManage: return 'ইভেন্ট-ড্রিভেন ওয়েবহুক এন্ডপয়েন্ট ও রিট্রাই পলিসি ম্যানেজমেন্ট';
      case apiSandboxAccess: return 'আইসোলেটেড ডেভেলপার স্যান্ডবক্স ও টেস্ট এনভায়রনমেন্ট অ্যাক্সেস';
      case apiDocumentationView: return 'ওপেনএপিআই/সোয়াগার ইন্টারঅ্যাক্টিভ ডকুমেন্টেশন ও এক্সপ্লোরার';
      case apiRateLimitsConfigure: return 'এপিআই রেট লিমিটিং, থ্রটলিং ও কোটা পলিসি কনফিগারেশন';
      case apiUsageAnalyticsView: return 'এপিআই রিকোয়েস্ট মিটারিং, লেটেন্সি ও ব্যবহারের অ্যানালিটিক্স';
      case apiIntegrationsManage: return 'থার্ড-পার্টি পেমেন্ট, ব্যাংকিং ও এসএমএস গেটওয়ে ইন্টিগ্রেশন হাব';

      case whiteLabelDashboardView: return 'হোয়াইট-লেবেল ও সমিতি কাস্টমাইজেশন ড্যাশবোর্ড দেখা';
      case societyBrandingManage: return 'সমিতির নিজস্ব লোগো, নাম, সিল ও ব্র্যান্ডিং অ্যাসেট পরিচালনা';
      case societyThemeConfigure: return 'কাস্টম কালার প্যালেট, ফন্ট ও থিম স্টাইলিং কনফিগারেশন';
      case societyCustomDomainManage: return 'কাস্টম নিজস্ব ডোমেন, সাবডোমেন ও ডিএনএস ভেরিফিকেশন';
      case societyDocumentTemplatesManage: return 'অফিসিয়াল সনদ, রশিদ ও নোটিশ টেমপ্লেট বিল্ডার';
      case societyNotificationTemplatesManage: return 'এসএমএস, ইমেইল ও ইন-অ্যাপ বার্তা টেমপ্লেট কনফিগার';
      case societyBusinessConfigManage: return 'সমিতির ব্যবসায়িক নিয়মাবলী, ভাউচার কোড ও অপারেশনাল সেটিংস';
      case whiteLabelAssetsUpload: return 'ব্র্যান্ডিং ইমেজ, ব্যানার ও ডকুমেন্ট ফাইল আপলোড অনুমোদন';
      case whiteLabelRollbackExecute: return 'পূর্ববর্তী ব্র্যান্ডিং ও থিম সংস্করণে জরুরি রোলব্যাক কার্যকর';
      case whiteLabelEntitlementsManage: return 'সাবস্ক্রিপশন প্ল্যানভিত্তিক হোয়াইট-লেবেল ফিচার এনটাইটেলমেন্ট';

      case dwDashboardView: return 'এন্টারপ্রাইজ ডাটা ওয়্যারহাউজ ও বিআই ড্যাশবোর্ড দেখা';
      case dwPipelinesManage: return 'ইটিএল ডাটা পাইপলাইন, চেকপয়েন্টিং ও ইনজেশন জবস পরিচালনা';
      case dwFinancialReconcile: return 'ওয়্যারহাউজ ফ্যাক্ট টেবিল ও জেনারেল লেজার রিকনসিলিয়েশন';
      case dwBiDashboardsManage: return 'এক্সিকিউটিভ বিআই রিপোর্ট, কেপিআই ও ভিজ্যুয়ালাইজেশন কন্ট্রোল';
      case dwBenchmarkingAccess: return 'ক্রস-সমিতি গোপনীয় ও বেনামী পারফরম্যান্স বেন্চমার্কিং';
      case dwExportsManage: return 'অ্যানালিটিক্যাল ডাটা এক্সপোর্ট (CSV, Excel, PDF) ও অডিট লগ';
      case dwArchivalExecute: return 'ঐতিহাসিক ডাটা আর্কাইভিং ও ১০ বছর আইনি সংরক্ষণ পরিচালনা';
      case dwLineageInspect: return 'এন্ড-টু-এন্ড ডাটা লিনিয়েজ, রূপান্তর ইতিহাস ও মেটাডাটা ট্রেস';
      case dwQualityAudit: return 'ডাটা কোয়ালিটি স্কোরকার্ড, অসঙ্গতি শনাক্তকরণ ও কুয়ারেন্টাইন লগ';
      case dwRetentionConfigure: return 'ডাটা লাইফসাইকেল, কোল্ড স্টোরেজ ও লিগ্যাল হোল্ড কনফিগারেশন';

      // Phase 18: Member Super App
      case memberAppAccess: return 'মেম্বার সুপার অ্যাপে লগইন ও সেলফ-সার্ভিস ব্যবহার';
      case memberProfileSelfManage: return 'ব্যক্তিগত মেম্বার প্রোফাইল ও তথ্য হালনাগাদ আবেদন';
      case memberKycSubmit: return 'ডিজিটাল কেওয়াইসি (KYC) নথি ও জাতীয় পরিচয়পত্র জমা';
      case memberDigitalCardView: return 'ডিজিটাল মেম্বারশিপ কার্ড ও সুরক্ষিত QR আইডেন্টিফিকেশন';
      case memberSavingsSelfService: return 'সঞ্চয় ব্যালেন্স, ডিপোজিট হিস্টোরি ও স্টেটমেন্ট ডাউনলোড';
      case memberWithdrawalApply: return 'সঞ্চয় উত্তোলন বা উইথড্রয়াল রিকোয়েস্ট সাবমিট';
      case memberLoansSelfService: return 'চলমান ঋণের কিস্তি সূচি, আসল/সুদ স্থিতি ও স্টেটমেন্ট';
      case memberLoanApply: return 'নতুন ঋণের জন্য ডিজিটাল আবেদন জমা দান';
      case memberOnlinePayment: return 'অনলাইন পেমেন্ট গেটওয়ে (bKash/Nagad/Bank) দিয়ে কিস্তি পরিশোধ';
      case memberServiceTicketsManage: return 'ডিজিটাল হেল্পডেস্ক সাপোর্ট টিকিট ও অভিযোগ দায়ের';

      // Phase 19: Cooperative Governance, Audit & Compliance
      case govCommitteesManage: return 'পরিচালনা পর্ষদ ও উপ-কমিটি গঠন এবং দায়িত্ব বণ্টন';
      case govMeetingsManage: return 'বোর্ড সভা আহ্বান, নোটিশ জারি ও কার্যবিবরণী অনুমোদন';
      case govAgmManage: return 'বার্ষিক সাধারণ সভা (AGM), কোরাম ও কার্যসূচি পরিচালনা';
      case govResolutionsManage: return 'আনুষ্ঠানিক বোর্ড রেজুলেশন গ্রহণ ও বাস্তবায়ন ট্র্যাকিং';
      case govElectionsManage: return 'ব্যবস্থাপনা কমিটি নির্বাচন, ভোটার তালিকা ও ফলাফল';
      case govInternalAuditManage: return 'অভ্যন্তরীণ নিরীক্ষা পরিকল্পনা, পরিদর্শন ও ফাইন্ডিংস লগ';
      case govFinancialAuditManage: return 'আর্থিক অডিট, ভাউচার যাচাই ও লেজার রিকনসিলিয়েশন';
      case govRegulatoryComplianceManage: return 'সমবায় সমিতি আইন ২০০১ বিধিবদ্ধ কমপ্লায়েন্স ও ফাইলিং';
      case govComplianceCalendarManage: return 'বার্ষিক কমপ্লায়েন্স ক্যালেন্ডার ও আইনি সময়সীমা ট্র্যাকিং';
      case govDocumentsManage: return 'অফিসিয়াল গভর্ন্যান্স ডকুমেন্টস, মিনিটস ও প্রামাণ্য দলিল';
      case autoWorkflowsManage: return 'স্বয়ংক্রিয় ওয়ার্কফ্লো তৈরি, সম্পাদন ও পরিচালনা';
      case autoTriggersConfigure: return 'ইভেন্ট ও শিডিউলড ক্রোন ট্রিগার কনফিগারেশন';
      case autoActionsConfigure: return 'অনুমোদিত অ্যাকশন লাইব্রেরি ও ইন্টিগ্রেশন নিয়ন্ত্রণ';
      case autoSchedulerManage: return 'টাইম-বেসড ক্রোন জব ও অটোনোমাস শিডিউলার';
      case autoExecutionsView: return 'ওয়ার্কফ্লো এক্সিকিউশন ইতিহাস ও লাইভ স্ট্যাটাস মনিটরিং';
      case autoRetryQueueManage: return 'ব্যর্থ টাস্ক পুনরায় চেষ্টা ও ডেড-লেটার কিউ (DLQ)';
      case autoApprovalsProcess: return 'মেকার-চেকার অনুমোদন কিউ ও মানবিক তদারকি';
      case autoAiAssistedConfigure: return 'স্মার্ট এআই রুলস ও অপ্টিমাইজেশন অ্যাসিস্ট্যান্ট';
      case autoMonitoringView: return 'সার্বক্ষণিক অটোমেশন পারফরম্যান্স ও রিসোর্স অ্যানালিটিক্স';
      case autoPoliciesManage: return 'সার্কিট ব্রেকার, লুপ প্রতিরোধ ও নিরাপত্তা পলিসি';
      default: return key;
    }
  }
}

/// Active Session and Device Tracking Model
class UserSessionModel {
  final String sessionId;
  final String userId;
  final String userEmail;
  final String societyId;
  final String deviceName;
  final String ipAddress;
  final DateTime loginAt;
  final DateTime lastActiveAt;
  final DateTime expiresAt;
  final bool isRevoked;
  final String? revokedBy;
  final String? revocationReason;

  const UserSessionModel({
    required this.sessionId,
    required this.userId,
    required this.userEmail,
    required this.societyId,
    required this.deviceName,
    required this.ipAddress,
    required this.loginAt,
    required this.lastActiveAt,
    required this.expiresAt,
    this.isRevoked = false,
    this.revokedBy,
    this.revocationReason,
  });

  bool get isValid => !isRevoked && DateTime.now().isBefore(expiresAt);

  Map<String, dynamic> toMap() {
    return {
      'sessionId': sessionId,
      'userId': userId,
      'userEmail': userEmail,
      'societyId': societyId,
      'deviceName': deviceName,
      'ipAddress': ipAddress,
      'loginAt': Timestamp.fromDate(loginAt),
      'lastActiveAt': Timestamp.fromDate(lastActiveAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'isRevoked': isRevoked,
      'revokedBy': revokedBy,
      'revocationReason': revocationReason,
    };
  }

  factory UserSessionModel.fromMap(Map<String, dynamic> map, String id) {
    return UserSessionModel(
      sessionId: map['sessionId'] ?? id,
      userId: map['userId'] ?? '',
      userEmail: map['userEmail'] ?? '',
      societyId: map['societyId'] ?? '',
      deviceName: map['deviceName'] ?? 'Unknown Device',
      ipAddress: map['ipAddress'] ?? '127.0.0.1',
      loginAt: (map['loginAt'] is Timestamp) ? (map['loginAt'] as Timestamp).toDate() : DateTime.now(),
      lastActiveAt: (map['lastActiveAt'] is Timestamp) ? (map['lastActiveAt'] as Timestamp).toDate() : DateTime.now(),
      expiresAt: (map['expiresAt'] is Timestamp) ? (map['expiresAt'] as Timestamp).toDate() : DateTime.now().add(const Duration(hours: 8)),
      isRevoked: map['isRevoked'] == true,
      revokedBy: map['revokedBy'],
      revocationReason: map['revocationReason'],
    );
  }

  UserSessionModel copyWith({
    bool? isRevoked,
    String? revokedBy,
    String? revocationReason,
    DateTime? lastActiveAt,
  }) {
    return UserSessionModel(
      sessionId: sessionId,
      userId: userId,
      userEmail: userEmail,
      societyId: societyId,
      deviceName: deviceName,
      ipAddress: ipAddress,
      loginAt: loginAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      expiresAt: expiresAt,
      isRevoked: isRevoked ?? this.isRevoked,
      revokedBy: revokedBy ?? this.revokedBy,
      revocationReason: revocationReason ?? this.revocationReason,
    );
  }
}

/// Platform Security Policy Settings Model
class SecurityPolicyModel {
  final List<String> mfaRequiredRoles;
  final int maxFailedLoginAttempts;
  final int lockoutDurationMinutes;
  final int sessionTimeoutMinutes;
  final bool appCheckEnforced;
  final bool allowExportWithoutMfa;

  const SecurityPolicyModel({
    this.mfaRequiredRoles = const ['superAdmin', 'societyOwner', 'accountant'],
    this.maxFailedLoginAttempts = 5,
    this.lockoutDurationMinutes = 30,
    this.sessionTimeoutMinutes = 480, // 8 hours
    this.appCheckEnforced = false,
    this.allowExportWithoutMfa = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'mfaRequiredRoles': mfaRequiredRoles,
      'maxFailedLoginAttempts': maxFailedLoginAttempts,
      'lockoutDurationMinutes': lockoutDurationMinutes,
      'sessionTimeoutMinutes': sessionTimeoutMinutes,
      'appCheckEnforced': appCheckEnforced,
      'allowExportWithoutMfa': allowExportWithoutMfa,
    };
  }

  factory SecurityPolicyModel.fromMap(Map<String, dynamic> map) {
    return SecurityPolicyModel(
      mfaRequiredRoles: List<String>.from(map['mfaRequiredRoles'] ?? ['superAdmin', 'societyOwner']),
      maxFailedLoginAttempts: map['maxFailedLoginAttempts'] ?? 5,
      lockoutDurationMinutes: map['lockoutDurationMinutes'] ?? 30,
      sessionTimeoutMinutes: map['sessionTimeoutMinutes'] ?? 480,
      appCheckEnforced: map['appCheckEnforced'] == true,
      allowExportWithoutMfa: map['allowExportWithoutMfa'] == true,
    );
  }
}

/// Security Alert and Threat Anomaly Model
enum SecurityAlertSeverity { critical, high, medium, low }

class SecurityAlertModel {
  final String alertId;
  final DateTime timestamp;
  final SecurityAlertSeverity severity;
  final String category;
  final String affectedUid;
  final String affectedSocietyId;
  final String messageBn;
  final bool isResolved;

  const SecurityAlertModel({
    required this.alertId,
    required this.timestamp,
    required this.severity,
    required this.category,
    required this.affectedUid,
    required this.affectedSocietyId,
    required this.messageBn,
    this.isResolved = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'alertId': alertId,
      'timestamp': Timestamp.fromDate(timestamp),
      'severity': severity.name,
      'category': category,
      'affectedUid': affectedUid,
      'affectedSocietyId': affectedSocietyId,
      'messageBn': messageBn,
      'isResolved': isResolved,
    };
  }

  factory SecurityAlertModel.fromMap(Map<String, dynamic> map, String id) {
    SecurityAlertSeverity sev = SecurityAlertSeverity.medium;
    if (map['severity'] == 'critical') sev = SecurityAlertSeverity.critical;
    if (map['severity'] == 'high') sev = SecurityAlertSeverity.high;
    if (map['severity'] == 'low') sev = SecurityAlertSeverity.low;

    return SecurityAlertModel(
      alertId: map['alertId'] ?? id,
      timestamp: (map['timestamp'] is Timestamp) ? (map['timestamp'] as Timestamp).toDate() : DateTime.now(),
      severity: sev,
      category: map['category'] ?? 'anomaly',
      affectedUid: map['affectedUid'] ?? '',
      affectedSocietyId: map['affectedSocietyId'] ?? '',
      messageBn: map['messageBn'] ?? '',
      isResolved: map['isResolved'] == true,
    );
  }
}

/// Cryptographically Hash-Chained Audit Record Model
class SecurityAuditRecordModel {
  final String id;
  final DateTime timestamp;
  final String actorUid;
  final String actorEmail;
  final String actorRole;
  final String societyId;
  final String actionType;
  final String resourceType;
  final String resourceId;
  final String detailsBn;
  final String previousHash;
  final String currentHash;

  const SecurityAuditRecordModel({
    required this.id,
    required this.timestamp,
    required this.actorUid,
    required this.actorEmail,
    required this.actorRole,
    required this.societyId,
    required this.actionType,
    required this.resourceType,
    required this.resourceId,
    required this.detailsBn,
    required this.previousHash,
    required this.currentHash,
  });

  static String calculateHash({
    required String id,
    required DateTime timestamp,
    required String actorUid,
    required String actionType,
    required String resourceId,
    required String previousHash,
  }) {
    final payload = '$id|${timestamp.toIso8601String()}|$actorUid|$actionType|$resourceId|$previousHash';
    return sha256.convert(utf8.encode(payload)).toString();
  }

  bool verifyIntegrity() {
    final computed = calculateHash(
      id: id,
      timestamp: timestamp,
      actorUid: actorUid,
      actionType: actionType,
      resourceId: resourceId,
      previousHash: previousHash,
    );
    return computed == currentHash;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': Timestamp.fromDate(timestamp),
      'actorUid': actorUid,
      'actorEmail': actorEmail,
      'actorRole': actorRole,
      'societyId': societyId,
      'actionType': actionType,
      'resourceType': resourceType,
      'resourceId': resourceId,
      'detailsBn': detailsBn,
      'previousHash': previousHash,
      'currentHash': currentHash,
    };
  }

  factory SecurityAuditRecordModel.fromMap(Map<String, dynamic> map, String id) {
    return SecurityAuditRecordModel(
      id: map['id'] ?? id,
      timestamp: (map['timestamp'] is Timestamp) ? (map['timestamp'] as Timestamp).toDate() : DateTime.now(),
      actorUid: map['actorUid'] ?? '',
      actorEmail: map['actorEmail'] ?? '',
      actorRole: map['actorRole'] ?? '',
      societyId: map['societyId'] ?? '',
      actionType: map['actionType'] ?? '',
      resourceType: map['resourceType'] ?? '',
      resourceId: map['resourceId'] ?? '',
      detailsBn: map['detailsBn'] ?? '',
      previousHash: map['previousHash'] ?? 'GENESIS_SOMITI_SECURITY_CHAIN_2026',
      currentHash: map['currentHash'] ?? '',
    );
  }
}
