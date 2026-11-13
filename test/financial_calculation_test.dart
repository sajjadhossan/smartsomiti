import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_sync_drive/models/loan_model.dart';
import 'package:cloud_sync_drive/models/financial_report_model.dart';

void main() {
  group('Loan Financial Engine Tests', () {
    test('Flat Rate Interest and Amortization Schedule Calculation', () {
      const principal = 60000.0;
      const ratePercent = 10.0; // 10% annual
      const months = 12; // 1 year

      final schedule = LoanModel.generateSchedule(
        principal: principal,
        annualRatePercent: ratePercent,
        months: months,
        interestType: LoanInterestType.flat,
        startDate: DateTime(2026, 1, 1),
      );

      expect(schedule.length, equals(12));

      // Flat Rate: Total Interest = 60000 * 0.10 * 1 = 6000
      // Monthly Total = (60000 + 6000) / 12 = 5500
      double totalPrincipalCalculated = 0.0;
      double totalInterestCalculated = 0.0;

      for (var inst in schedule) {
        expect(inst.principalPortion, closeTo(5000.0, 0.01));
        expect(inst.interestPortion, closeTo(500.0, 0.01));
        expect(inst.totalInstallmentAmount, closeTo(5500.0, 0.01));
        totalPrincipalCalculated += inst.principalPortion;
        totalInterestCalculated += inst.interestPortion;
      }

      expect(totalPrincipalCalculated, closeTo(60000.0, 0.05));
      expect(totalInterestCalculated, closeTo(6000.0, 0.05));
    });

    test('Reducing Balance (EMI) Amortization Calculation', () {
      const principal = 100000.0;
      const ratePercent = 12.0; // 12% annual = 1% monthly
      const months = 12;

      final schedule = LoanModel.generateSchedule(
        principal: principal,
        annualRatePercent: ratePercent,
        months: months,
        interestType: LoanInterestType.reducing,
        startDate: DateTime(2026, 1, 1),
      );

      expect(schedule.length, equals(12));

      // With P = 100000, r = 0.01, n = 12:
      // EMI = [100000 * 0.01 * (1.01^12)] / [(1.01^12) - 1] ≈ 8884.88
      expect(schedule.first.totalInstallmentAmount, closeTo(8884.88, 1.0));

      // Month 1 interest should be 100000 * 0.01 = 1000
      expect(schedule.first.interestPortion, closeTo(1000.0, 1.0));

      // Final month interest should be significantly less than month 1
      expect(schedule.last.interestPortion, lessThan(schedule.first.interestPortion));

      // Total principal recovered must equal original principal
      double recoveredPrincipal = 0.0;
      for (var inst in schedule) {
        recoveredPrincipal += inst.principalPortion;
      }
      expect(recoveredPrincipal, closeTo(100000.0, 1.0));
    });
  });

  group('Balance Sheet Accounting Identity Tests', () {
    test('Assets equal Liabilities plus Equity (A = L + E)', () {
      final bs = BalanceSheetStatement(
        asOfDate: DateTime.now(),
        cashInHand: 40000.0,
        bankBalances: 150000.0,
        mfsWallets: 20000.0,
        activeLoansOutstanding: 90000.0,
        fixedAssets: 0.0,
        memberSavingsBalance: 250000.0, // Liability
        accountsPayable: 0.0,
        generalReserveFund: 5000.0,     // Equity
        accumulatedSurplus: 45000.0,    // Equity
      );

      // Total Assets = 40000 + 150000 + 20000 + 90000 = 300000
      expect(bs.totalAssets, equals(300000.0));

      // Total Liabilities = 250000
      expect(bs.totalLiabilities, equals(250000.0));

      // Total Equity = 5000 + 45000 = 50000
      expect(bs.totalEquity, equals(50000.0));

      // Identity: 300000 == 250000 + 50000
      expect(bs.isBalanced, isTrue);
      expect(bs.balanceDifference, closeTo(0.0, 0.001));
    });
  });
}
