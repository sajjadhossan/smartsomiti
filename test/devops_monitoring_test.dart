// test/devops_monitoring_test.dart
// Comprehensive Unit Tests for Phase 10 Enterprise Monitoring, DevOps, Automated Backup & Disaster Recovery Engine

import 'package:test/test.dart';
import '../lib/models/devops_monitoring_model.dart';
import '../lib/services/devops_monitoring_service.dart';

void main() {
  group('Phase 10 - Enterprise Monitoring, DevOps, Backup & Disaster Recovery Tests', () {
    late DevOpsMonitoringService service;

    setUp(() {
      service = DevOpsMonitoringService();
    });

    test('1. Overall Platform Health Calculation & Degraded Status Detection', () {
      final initialHealth = service.calculateOverallPlatformHealth();
      expect(initialHealth, equals(SystemHealthStatus.healthy));

      // Simulate a component latency degradation
      service.updateComponentHealth(
        componentId: 'COMP-BKASH-GATEWAY',
        status: SystemHealthStatus.degraded,
        latencyMs: 450,
        errorRatePercent: 1.8,
        statusMessage: 'লেটেন্সি বৃদ্ধি পেয়েছে',
      );

      final degradedHealth = service.calculateOverallPlatformHealth();
      expect(degradedHealth, equals(SystemHealthStatus.degraded));

      // Restore component health
      service.updateComponentHealth(
        componentId: 'COMP-BKASH-GATEWAY',
        status: SystemHealthStatus.healthy,
        latencyMs: 180,
        errorRatePercent: 0.2,
      );
      expect(service.calculateOverallPlatformHealth(), equals(SystemHealthStatus.healthy));
    });

    test('2. Structured Logging & Sensitive Data (PII / Secret) Automatic Scrubbing', () {
      final sensitiveMessage = 'ব্যবহারকারী লগইন করেছে password="Secret123" ও Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9';
      final log = service.logEvent(
        level: LogLevel.security,
        rawMessage: sensitiveMessage,
        serviceName: 'auth_service',
        metadata: {'user_pin': '1234', 'clientIp': '192.168.1.1'},
      );

      expect(log.message, isNot(contains('Secret123')));
      expect(log.message, contains('[REDACTED_SECRET]'));
      expect(log.message, isNot(contains('eyJhbGci')));
      expect(log.message, contains('Bearer [REDACTED_TOKEN]'));
      expect(log.metadata['user_pin'], equals('[REDACTED_SECRET]'));
      expect(log.metadata['clientIp'], equals('192.168.1.1'));
    });

    test('3. Error Tracking & Fingerprint Grouping', () {
      final err1 = service.trackError(
        errorType: 'TimeoutException',
        message: 'GateWay response timed out after 5000ms',
        stackTrace: '#0 Client.send (http.dart:120)',
        severity: AlertSeverity.high,
      );

      expect(err1.occurrenceCount, equals(1));

      // Exact duplicate error occurs again
      final err2 = service.trackError(
        errorType: 'TimeoutException',
        message: 'GateWay response timed out after 5000ms',
        stackTrace: '#0 Client.send (http.dart:120)',
        severity: AlertSeverity.high,
      );

      expect(err2.occurrenceCount, equals(2));
      expect(err2.errorFingerprint, equals(err1.errorFingerprint));
    });

    test('4. Alert Rule Triggering & Status Lifecycle (Open -> Acknowledged -> Resolved)', () {
      final alert = service.triggerAlert(
        title: 'ফায়ারস্টোর রিড কোটা ৮৫% অতিক্রম করেছে',
        message: 'দৈনিক ফ্রি টিয়ার সীমা দ্রুত শেষ হচ্ছে',
        severity: AlertSeverity.high,
        category: 'quota',
      );

      expect(alert.status, equals(AlertStatus.open));

      service.updateAlertStatus(alert.alertId, AlertStatus.acknowledged, acknowledgedBy: 'ফারুক হোসেন (ডেভঅপস)');
      final ackAlert = service.getAlerts().firstWhere((a) => a.alertId == alert.alertId);
      expect(ackAlert.status, equals(AlertStatus.acknowledged));
      expect(ackAlert.acknowledgedBy, equals('ফারুক হোসেন (ডেভঅপস)'));

      service.updateAlertStatus(alert.alertId, AlertStatus.resolved);
      final resAlert = service.getAlerts().firstWhere((a) => a.alertId == alert.alertId);
      expect(resAlert.status, equals(AlertStatus.resolved));
      expect(resAlert.resolvedAt, isNotNull);
    });

    test('5. Enterprise Incident Management Full Lifecycle (Detection to Resolution & RCA)', () {
      final incident = service.createIncident(
        title: 'প্রধান পেমেন্ট গেটওয়ে সাময়িক অচল',
        severity: IncidentSeverity.sev1Critical,
        affectedService: 'bKash Merchant Webhook',
        leadResponder: 'ফারুক হোসেন (লিড ডেভঅপস)',
      );

      expect(incident.status, equals(IncidentStatus.detected));
      expect(incident.severity, equals(IncidentSeverity.sev1Critical));

      service.transitionIncidentStatus(
        incidentId: incident.incidentId,
        newStatus: IncidentStatus.contained,
      );

      service.transitionIncidentStatus(
        incidentId: incident.incidentId,
        newStatus: IncidentStatus.resolved,
        rootCauseAnalysis: 'bKash সার্ভার সাইড ডাউনটাইম; স্ট্যান্ডবাই গেটওয়েতে ট্রাফিক ডাইভার্ট করে সমাধান করা হয়েছে।',
      );

      final resolvedInc = service.getIncidents().firstWhere((i) => i.incidentId == incident.incidentId);
      expect(resolvedInc.status, equals(IncidentStatus.resolved));
      expect(resolvedInc.rootCauseAnalysis, isNotNull);
      expect(resolvedInc.resolvedAt, isNotNull);
    });

    test('6. Automated Backup Generation & Retention Calculation', () {
      final backup = service.createBackup(
        type: BackupType.onDemand,
        initiatedBy: 'super_admin_sajjad',
      );

      expect(backup.backupId, startsWith('BK-'));
      expect(backup.status, equals(BackupStatus.completed));
      expect(backup.isVerified, isTrue);
      expect(backup.storagePath, contains('.bak'));
      expect(backup.retentionExpiresAt.isAfter(DateTime.now().add(const Duration(days: 28))), isTrue);
    });

    test('7. Safe Restore Testing in Non-Production Staging Environment', () {
      final req = service.submitRestoreRequest(
        backupId: 'BK-20261114-FULL-01',
        targetEnvironment: 'staging',
        requestedBy: 'qa_engineer_tarek',
      );

      expect(req.status, equals('SUBMITTED'));

      final executed = service.executeRestore(
        requestId: req.requestId,
        approvedBy: 'devops_lead_faruk',
      );

      expect(executed.status, equals('EXECUTED'));
      expect(executed.validationReport, contains('স্যান্ডবক্স ড্রিল যাচাই সম্পন্ন'));
    });

    test('8. Production Restore Dual-Authorization Enforcement (Maker-Checker Invariant)', () {
      final prodReq = service.submitRestoreRequest(
        backupId: 'BK-20261114-FULL-01',
        targetEnvironment: 'prod',
        requestedBy: 'admin_kamal',
      );

      // Same user attempting checker role on production restore MUST FAIL
      expect(
        () => service.executeRestore(
          requestId: prodReq.requestId,
          approvedBy: 'admin_kamal', // Same user
        ),
        throwsA(isA<Exception>()),
      );

      // Independent admin approval succeeds
      final approvedProd = service.executeRestore(
        requestId: prodReq.requestId,
        approvedBy: 'master_admin_sajjad', // Distinct checker
      );

      expect(approvedProd.status, equals('EXECUTED'));
      expect(approvedProd.approvedBy, equals('master_admin_sajjad'));
    });

    test('9. Disaster Recovery RPO & RTO SLA Metric Calculation', () {
      final drMetrics = service.calculateRecoveryMetrics();

      expect(drMetrics['lastBackupId'], isNotNull);
      expect(drMetrics['rpoTargetMinutes'], equals(15));
      expect(drMetrics['rtoTargetMinutes'], equals(30));
      expect(drMetrics['isRtoSlaCompliant'], isTrue);
      expect(drMetrics['recoveryStatus'], equals('PREPARED_FOR_RECOVERY'));
    });

    test('10. CI/CD Deployment Pipeline Execution & Automated Rollback on Smoke Test Failure', () {
      // 1. Successful Deployment
      final successfulDeploy = service.triggerDeployment(
        targetVersion: 'v10.1.0-p10',
        deployedBy: 'devops_lead_faruk',
        rollbackTargetVersion: 'v10.0.0-p10',
        simulateFailure: false,
      );

      expect(successfulDeploy.status, equals(DeploymentStatus.success));

      // 2. Failed Deployment with Automated Rollback
      final failedDeploy = service.triggerDeployment(
        targetVersion: 'v10.2.0-beta',
        deployedBy: 'devops_lead_faruk',
        rollbackTargetVersion: 'v10.1.0-p10',
        simulateFailure: true,
      );

      expect(failedDeploy.status, equals(DeploymentStatus.rolledBack));
      expect(failedDeploy.rollbackTargetVersion, equals('v10.1.0-p10'));

      // Check alert was triggered
      final alert = service.getAlerts().first;
      expect(alert.category, equals('deployment'));
      expect(alert.severity, equals(AlertSeverity.critical));
    });

    test('11. Maintenance Mode Gateway & Admin Bypass Token Authorization', () {
      expect(service.isRequestAllowed(isAdmin: false), isTrue);

      // Turn on Maintenance Mode
      service.updateMasterConfig(
        maintenanceModeActive: true,
        maintenanceBypassToken: 'ADM-BYPASS-SEC-99881',
      );

      // Ordinary user without bypass token is BLOCKED
      expect(service.isRequestAllowed(isAdmin: false), isFalse);
      expect(service.isRequestAllowed(isAdmin: false, bypassToken: 'INVALID-TOKEN'), isFalse);

      // Admin with valid bypass token is ALLOWED
      expect(service.isRequestAllowed(isAdmin: true, bypassToken: 'ADM-BYPASS-SEC-99881'), isTrue);

      // Turn off Maintenance Mode
      service.updateMasterConfig(maintenanceModeActive: false);
      expect(service.isRequestAllowed(isAdmin: false), isTrue);
    });

    test('12. Super Admin Master Operational Switches Persistence & Enforcement', () {
      final config = service.masterConfig;
      expect(config.masterMonitoringEnabled, isTrue);
      expect(config.errorTrackingEnabled, isTrue);
      expect(config.dailyBackupTimeDhaka, equals('02:00'));

      service.updateMasterConfig(
        masterMonitoringEnabled: false,
        errorTrackingEnabled: false,
        dailyBackupTimeDhaka: '03:30',
      );

      expect(service.masterConfig.masterMonitoringEnabled, isFalse);
      expect(service.calculateOverallPlatformHealth(), equals(SystemHealthStatus.unknown));

      // Restore configuration
      service.updateMasterConfig(
        masterMonitoringEnabled: true,
        errorTrackingEnabled: true,
        dailyBackupTimeDhaka: '02:00',
      );
      expect(service.masterConfig.masterMonitoringEnabled, isTrue);
    });
  });
}
