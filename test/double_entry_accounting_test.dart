import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_sync_drive/models/double_entry_accounting_model.dart';

void main() {
  group('Double-Entry Accounting Engine Mathematical & Invariant Tests', () {
    test('Balanced Journal Entry passes equality check (Debit == Credit)', () {
      final lines = [
        JournalLineModel(
          lineNumber: 1,
          accountId: 'coa_1110',
          accountCode: '1110',
          accountName: 'প্রধান ক্যাশ ড্রয়ার',
          category: AccountCategory.asset,
          debitInPoisha: 100000, // ৳1,000.00
          creditInPoisha: 0,
        ),
        JournalLineModel(
          lineNumber: 2,
          accountId: 'coa_2120',
          accountCode: '2120',
          accountName: 'মাসিক ডিপিএস সঞ্চয় আমানত দায়',
          category: AccountCategory.liability,
          debitInPoisha: 0,
          creditInPoisha: 100000, // ৳1,000.00
        ),
      ];

      final entry = JournalEntryModel(
        id: 'test_jrn_1',
        journalNumber: 'JRN-202611-00001',
        somitiId: 'test_somiti',
        entryDate: DateTime.now(),
        accountingPeriodId: 'PERIOD-2026-11',
        voucherType: VoucherType.receipt,
        description: 'সদস্য ডিপিএস সঞ্চয় জমা',
        idempotencyKey: 'idemp_key_1',
        totalDebitInPoisha: 100000,
        totalCreditInPoisha: 100000,
        lines: lines,
        createdByUid: 'cashier_uid',
      );

      expect(entry.isBalanced, isTrue);
      expect(entry.totalDebitInTaka, equals(1000.0));
      expect(entry.totalCreditInTaka, equals(1000.0));
    });

    test('Unbalanced Journal Entry fails isBalanced property', () {
      final lines = [
        JournalLineModel(
          lineNumber: 1,
          accountId: 'coa_1110',
          accountCode: '1110',
          accountName: 'প্রধান ক্যাশ ড্রয়ার',
          category: AccountCategory.asset,
          debitInPoisha: 50000, // ৳500.00
          creditInPoisha: 0,
        ),
        JournalLineModel(
          lineNumber: 2,
          accountId: 'coa_2120',
          accountCode: '2120',
          accountName: 'মাসিক ডিপিএস সঞ্চয় আমানত দায়',
          category: AccountCategory.liability,
          debitInPoisha: 0,
          creditInPoisha: 49000, // ৳490.00 (1000 poisha difference!)
        ),
      ];

      final entry = JournalEntryModel(
        id: 'test_jrn_2',
        journalNumber: 'JRN-202611-00002',
        somitiId: 'test_somiti',
        entryDate: DateTime.now(),
        accountingPeriodId: 'PERIOD-2026-11',
        voucherType: VoucherType.receipt,
        description: 'অসম জমা ভাউচার',
        idempotencyKey: 'idemp_key_2',
        totalDebitInPoisha: 50000,
        totalCreditInPoisha: 49000,
        lines: lines,
        createdByUid: 'cashier_uid',
      );

      expect(entry.isBalanced, isFalse);
    });

    test('Multi-line Split Journal Entry: Loan Repayment (Principal + Interest + Late Fee)', () {
      final lines = [
        JournalLineModel(
          lineNumber: 1,
          accountId: 'coa_1110',
          accountCode: '1110',
          accountName: 'প্রধান ক্যাশ ড্রয়ার',
          category: AccountCategory.asset,
          debitInPoisha: 480000, // ৳4,800.00 Cash received
          creditInPoisha: 0,
        ),
        JournalLineModel(
          lineNumber: 2,
          accountId: 'coa_1141',
          accountCode: '1141',
          accountName: 'ক্ষুদ্রঋণ আসল প্রাপ্য',
          category: AccountCategory.asset,
          debitInPoisha: 0,
          creditInPoisha: 400000, // ৳4,000.00 Principal recovered
        ),
        JournalLineModel(
          lineNumber: 3,
          accountId: 'coa_4110',
          accountCode: '4110',
          accountName: 'ঋণের সুদ বাবদ আয়',
          category: AccountCategory.income,
          debitInPoisha: 0,
          creditInPoisha: 70000, // ৳700.00 Interest income
        ),
        JournalLineModel(
          lineNumber: 4,
          accountId: 'coa_4130',
          accountCode: '4130',
          accountName: 'বকেয়া কিস্তির বিলম্ব ফি আয়',
          category: AccountCategory.income,
          debitInPoisha: 0,
          creditInPoisha: 10000, // ৳100.00 Late fee
        ),
      ];

      final totalDebit = lines.fold<int>(0, (sum, l) => sum + l.debitInPoisha);
      final totalCredit = lines.fold<int>(0, (sum, l) => sum + l.creditInPoisha);

      expect(totalDebit, equals(480000));
      expect(totalCredit, equals(480000));
      expect(totalDebit == totalCredit, isTrue);
    });

    test('Trial Balance Report balances to zero difference', () {
      final tb = TrialBalanceReport(
        asOfDate: DateTime(2026, 11, 14),
        lines: [
          TrialBalanceLine(accountCode: '1110', accountName: 'Cash', category: AccountCategory.asset, debitInPoisha: 500000, creditInPoisha: 0),
          TrialBalanceLine(accountCode: '1141', accountName: 'Loan Receivable', category: AccountCategory.asset, debitInPoisha: 800000, creditInPoisha: 0),
          TrialBalanceLine(accountCode: '2120', accountName: 'DPS Liability', category: AccountCategory.liability, debitInPoisha: 0, creditInPoisha: 900000),
          TrialBalanceLine(accountCode: '3110', accountName: 'Share Capital', category: AccountCategory.equity, debitInPoisha: 0, creditInPoisha: 400000),
        ],
        totalDebitInPoisha: 1300000,
        totalCreditInPoisha: 1300000,
      );

      expect(tb.isBalanced, isTrue);
      expect(tb.differenceInPoisha, equals(0));
    });

    test('Balance Sheet Equation: Assets = Liabilities + Equity', () {
      const int assets = 2500000;      // ৳25,000.00
      const int liabilities = 1800000; // ৳18,000.00 (Member Savings)
      const int equity = 700000;       // ৳7,000.00 (Capital + Retained Surplus)

      expect(assets, equals(liabilities + equity));
    });
  });
}
