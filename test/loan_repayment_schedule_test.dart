import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_sync_drive/models/loan_model.dart';

void main() {
  group('Loan Repayment Schedule & Amortization Tests', () {
    test('Flat Rate Schedule generates equal installments with exact sums', () {
      const principal = 120000.0;
      const rate = 10.0; // 10% annual
      const months = 12;
      final startDate = DateTime(2025, 1, 1);

      final schedule = LoanCalculationEngine.generateSchedule(
        principal: principal,
        annualRatePercent: rate,
        months: months,
        type: LoanInterestType.flat,
        startDate: startDate,
      );

      expect(schedule.length, equals(12));

      double sumPrincipal = 0.0;
      double sumInterest = 0.0;

      for (int i = 0; i < schedule.length; i++) {
        final item = schedule[i];
        expect(item.installmentNo, equals(i + 1));
        expect(item.principalPortion, equals(10000.0));
        expect(item.interestPortion, equals(1000.0));
        expect(item.totalInstallmentAmount, equals(11000.0));

        sumPrincipal += item.principalPortion;
        sumInterest += item.interestPortion;
      }

      expect(sumPrincipal, closeTo(principal, 0.01));
      expect(sumInterest, closeTo(12000.0, 0.01));
    });

    test('Reducing Balance (EMI) decreasing interest and increasing principal', () {
      const principal = 100000.0;
      const rate = 12.0; // 12% annual = 1% monthly
      const months = 6;
      final startDate = DateTime(2025, 1, 1);

      final schedule = LoanCalculationEngine.generateSchedule(
        principal: principal,
        annualRatePercent: rate,
        months: months,
        type: LoanInterestType.reducing,
        startDate: startDate,
      );

      expect(schedule.length, equals(6));

      double sumPrincipal = 0.0;

      // In reducing balance, interest starts high and decreases every month
      for (int i = 0; i < schedule.length - 1; i++) {
        expect(schedule[i].interestPortion, greaterThanOrEqualTo(schedule[i + 1].interestPortion));
        expect(schedule[i].principalPortion, lessThanOrEqualTo(schedule[i + 1].principalPortion));
        sumPrincipal += schedule[i].principalPortion;
      }
      sumPrincipal += schedule.last.principalPortion;

      // Total principal repaid must exactly equal original loan principal
      expect(sumPrincipal, closeTo(principal, 0.1));
    });

    test('Installment serialization and deserialization preserves amounts and dates', () {
      final now = DateTime(2025, 5, 15);
      final item = LoanInstallmentModel(
        installmentNo: 3,
        dueDate: now,
        principalPortion: 5000.0,
        interestPortion: 450.0,
        totalInstallmentAmount: 5450.0,
        paidAmount: 5450.0,
        isPaid: true,
        paidDate: now,
      );

      final map = item.toMap();
      expect(map['installmentNo'], equals(3));
      expect(map['isPaid'], isTrue);

      final reconstructed = LoanInstallmentModel.fromMap(map);
      expect(reconstructed.installmentNo, equals(item.installmentNo));
      expect(reconstructed.totalInstallmentAmount, equals(item.totalInstallmentAmount));
      expect(reconstructed.isPaid, isTrue);
    });
  });
}
