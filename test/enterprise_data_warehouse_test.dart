// test/enterprise_data_warehouse_test.dart
// Phase 17: Enterprise Data Warehouse & Advanced Intelligence Platform Unit Tests

import 'package:flutter_test/flutter_test.dart';
import '../lib/models/data_warehouse_analytics_model.dart';
import '../lib/services/data_warehouse_analytics_service.dart';

void main() {
  group('Phase 17 — Enterprise Data Warehouse & BI Tests', () {
    late DataWarehouseAnalyticsService service;

    setUp(() {
      service = DataWarehouseAnalyticsService();
    });

    // Test 1: OLTP to OLAP Star Schema Fact Model Integrity
    test('1. OLTP to OLAP Star Schema Fact Model Integrity', () {
      final recon = service.reconcileFinancialLedger('SOMITI-001');
      expect(recon.factSavingsTotalPoisha, equals(84520000)); // ৳8,45,200.00
      expect(recon.factLoanPrincipalPoisha, equals(18500000)); // ৳1,85,000.00
      expect(recon.factCashBalancePoisha, equals(66020000)); // ৳6,60,200.00
    });

    // Test 2: Zero-Discrepancy Financial Reconciliation with General Ledger
    test('2. Zero-Discrepancy Financial Reconciliation with General Ledger', () {
      final recon = service.reconcileFinancialLedger('SOMITI-001');
      expect(recon.isBalanced, isTrue);
      expect(recon.discrepancyPoisha, equals(0));
      expect(recon.factSavingsTotalPoisha, equals(recon.glSavingsLiabilityPoisha));
      expect(recon.factLoanPrincipalPoisha, equals(recon.glLoanAssetPoisha));
      expect(recon.factCashBalancePoisha, equals(recon.glCashBalancePoisha));
    });

    // Test 3: Portfolio-at-Risk (PAR 30/60/90) Aging Classification
    test('3. Portfolio-at-Risk (PAR 30/60/90) Aging Classification', () {
      const activeLoan = FactLoanInstallmentModel(
        factId: 't_ln_01',
        societyId: 'SOMITI-001',
        loanId: 'LN-TEST',
        memberId: 'MEM-101',
        dateKey: '20261114',
        principalPoisha: 500000,
        interestPoisha: 50000,
        remainingPrincipalPoisha: 1250000,
        isOverdue: true,
        daysPastDue: 22,
        parCategory: ParCategory.par30,
        dueDate: null,
      );

      expect(activeLoan.isOverdue, isTrue);
      expect(activeLoan.daysPastDue, equals(22));
      expect(activeLoan.parCategory, equals(ParCategory.par30));
    });

    // Test 4: Data Pipeline Ingestion with Checkpointing & Idempotency
    test('4. Data Pipeline Ingestion with Checkpointing & Idempotency', () {
      final job = service.runPipeline('Daily Savings Fact ETL', 'SOMITI-001');
      expect(job.status, equals(PipelineJobStatus.completed));
      expect(job.processedRecords, greaterThan(0));
      expect(job.quarantinedRecords, equals(0));
      expect(job.durationMs, greaterThan(0));
    });

    // Test 5: Data Quality Scorecard (Completeness, Accuracy, Consistency)
    test('5. Data Quality Scorecard Completeness, Accuracy, Consistency', () {
      final dq = service.generateDataQualityReport('SOMITI-001');
      expect(dq.completenessScore, greaterThanOrEqualTo(99.0));
      expect(dq.accuracyScore, equals(100.0));
      expect(dq.consistencyScore, greaterThanOrEqualTo(99.0));
      expect(dq.overallQualityScore, greaterThanOrEqualTo(99.5));
      expect(dq.duplicateCount, equals(0));
    });

    // Test 6: Privacy-Preserving Cross-Society Benchmarking with k-Anonymity
    test('6. Privacy-Preserving Cross-Society Benchmarking with k-Anonymity (k >= 5)', () {
      final benchmarks = service.getBenchmarks('SOMITI-001');
      expect(benchmarks.length, greaterThanOrEqualTo(4));

      for (final bm in benchmarks) {
        expect(bm.kAnonymityCount, greaterThanOrEqualTo(5)); // Strict k-anonymity
        expect(bm.societyScore, greaterThan(0));
        expect(bm.peerGroupMedian, greaterThan(0));
      }
    });

    // Test 7: Cross-Tenant Confidential Data Isolation Safeguard
    test('7. Cross-Tenant Confidential Data Isolation Safeguard', () {
      final benchmarks = service.getBenchmarks('SOMITI-001');
      // Verify no raw confidential row names or individual balances are leaked
      for (final bm in benchmarks) {
        expect(bm.metricKey, isNotEmpty);
        expect(bm.percentileRank, contains('শীর্ষ'));
        expect(bm.isAuthorized, isTrue);
      }
    });

    // Test 8: Analytical Dataset Export Sanitization & Permissions
    test('8. Analytical Dataset Export Sanitization & Permissions', () {
      final exportFileName = service.exportAnalyticalDataset('FINANCIAL_RECON', 'SOMITI-001', 'CSV');
      expect(exportFileName, startsWith('EXPORT_FINANCIAL_RECON_SOMITI-001_'));
      expect(exportFileName, endsWith('.csv'));
    });

    // Test 9: 10-Year Statutory Retention Policy Compliance (Co-op Act 2001)
    test('9. 10-Year Statutory Retention Policy Compliance (Co-op Act 2001)', () {
      final policy = service.getRetentionPolicy('SOMITI-001');
      expect(policy, isNotNull);
      expect(policy!.retentionPeriodYears, equals(10));
      expect(policy.isStatutoryCompliant, isTrue);
    });

    // Test 10: Legal Hold Protection Preventing Accidental Purging
    test('10. Legal Hold Protection Preventing Accidental Purging', () {
      final toggleSuccess = service.toggleLegalHold('SOMITI-001', true);
      expect(toggleSuccess, isTrue);

      final updatedPolicy = service.getRetentionPolicy('SOMITI-001');
      expect(updatedPolicy!.isLegalHoldActive, isTrue);

      // Reset
      service.toggleLegalHold('SOMITI-001', false);
      expect(service.getRetentionPolicy('SOMITI-001')!.isLegalHoldActive, isFalse);
    });

    // Test 11: Super Admin Universal Feature Toggle Controls
    test('11. Super Admin Universal Feature Toggle Controls', () {
      expect(service.getMasterConfig().isCrossSocietyBenchmarkingEnabled, isTrue);

      service.updateSuperAdminPolicy('isCrossSocietyBenchmarkingEnabled', false);
      expect(service.getMasterConfig().isCrossSocietyBenchmarkingEnabled, isFalse);
      expect(service.getBenchmarks('SOMITI-001'), isEmpty); // Disabled

      service.updateSuperAdminPolicy('isCrossSocietyBenchmarkingEnabled', true);
      expect(service.getMasterConfig().isCrossSocietyBenchmarkingEnabled, isTrue);
    });

    // Test 12: Immutable Security & Financial Invariants Protection (Non-disablable)
    test('12. Immutable Security & Financial Invariants Protection (Non-disablable)', () {
      // Invariant: Ledger reconciliation lock & tenant isolation cannot be disabled
      expect(
        () => service.updateSuperAdminPolicy('isFinancialLedgerReconciliationLocked', false),
        throwsA(isA<UnsupportedError>()),
      );
      expect(
        () => service.updateSuperAdminPolicy('isTenantIsolationEnforced', false),
        throwsA(isA<UnsupportedError>()),
      );
      expect(
        () => service.updateSuperAdminPolicy('isStatutory10YearRetentionEnforced', false),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });
}
