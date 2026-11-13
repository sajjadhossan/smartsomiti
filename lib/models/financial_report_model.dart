import 'package:cloud_firestore/cloud_firestore.dart';

/// Item in a financial report
class ReportLineItem {
  final String title;
  final double amount;
  final String note;

  const ReportLineItem({
    required this.title,
    required this.amount,
    this.note = '',
  });

  Map<String, dynamic> toMap() => {
    'title': title,
    'amount': amount,
    'note': note,
  };
}

/// লাভ-ক্ষতি বিবরণী (Profit & Loss Statement)
class ProfitAndLossStatement {
  final DateTime startDate;
  final DateTime endDate;
  
  // Revenues (আয়সমূহ)
  final double loanInterestIncome;   // ঋণ থেকে অর্জিত সুদ
  final double memberAdmissionFees;   // ভর্তি ফি
  final double passbookSalesIncome;   // পাসবুক ও ফরম বিক্রয়
  final double lateFeePenalties;      // বিলম্ব জরিমানা
  final double otherRevenues;         // বিবিধ আয়
  final List<ReportLineItem> revenueDetails;

  // Operating Expenses (পরিচালন ব্যয়সমূহ)
  final double officeRentExpense;     // অফিস ভাড়া
  final double utilityBillsExpense;   // বিদ্যুৎ ও ইন্টারনেট
  final double employeeSalaries;      // কর্মচারী বেতন ও ভাতা
  final double stationeryExpense;     // খাতা, কলম ও প্রিন্টিং
  final double refreshmentsExpense;   // আপ্যায়ন খরচ
  final double bankChargesExpense;    // ব্যাংক চার্জ
  final double miscellaneousExpenses; // অন্যান্য বিবিধ খরচ
  final List<ReportLineItem> expenseDetails;

  ProfitAndLossStatement({
    required this.startDate,
    required this.endDate,
    this.loanInterestIncome = 0.0,
    this.memberAdmissionFees = 0.0,
    this.passbookSalesIncome = 0.0,
    this.lateFeePenalties = 0.0,
    this.otherRevenues = 0.0,
    this.revenueDetails = const [],
    this.officeRentExpense = 0.0,
    this.utilityBillsExpense = 0.0,
    this.employeeSalaries = 0.0,
    this.stationeryExpense = 0.0,
    this.refreshmentsExpense = 0.0,
    this.bankChargesExpense = 0.0,
    this.miscellaneousExpenses = 0.0,
    this.expenseDetails = const [],
  });

  double get totalRevenue =>
      loanInterestIncome + memberAdmissionFees + passbookSalesIncome + lateFeePenalties + otherRevenues;

  double get totalOperatingExpenses =>
      officeRentExpense + utilityBillsExpense + employeeSalaries + stationeryExpense +
      refreshmentsExpense + bankChargesExpense + miscellaneousExpenses;

  /// নিট উদ্বৃত্ত / মুনাফা (Net Profit / Surplus)
  double get netProfit => totalRevenue - totalOperatingExpenses;
  bool get isProfitable => netProfit >= 0;
}

/// আর্থিক উদ্বৃত্তপত্র / ব্যালেন্স শিট (Balance Sheet)
class BalanceSheetStatement {
  final DateTime asOfDate;

  // Assets (সম্পদসমূহ)
  final double cashInHand;           // হাতের নগদ (ক্যাশ ড্রয়ার)
  final double bankBalances;         // ব্যাংক হিসাব উদ্বৃত্ত
  final double mfsWallets;           // মোবাইল ব্যাংকিং ব্যালেন্স (বিকাশ/নগদ)
  final double activeLoansOutstanding; // সদস্যদের মাঝে বিতরণকৃত ঋণ স্থিতি (বর্তমান প্রাপ্য)
  final double fixedAssets;          // স্থায়ী সম্পদ (অফিস সরঞ্জামাদি ও ফার্নিচার)

  // Liabilities (দায়সমূহ)
  final double memberSavingsBalance; // সদস্যদের মোট সঞ্চয় আমানত (প্রধান দায়)
  final double accountsPayable;      // প্রদেয় বিল ও খরচ

  // Equity (মূলধন ও সংরক্ষিত তহবিল)
  final double generalReserveFund;   // সংরক্ষিত তহবিল
  final double accumulatedSurplus;   // পুঞ্জীভূত মুনাফা / উদ্বৃত্ত

  BalanceSheetStatement({
    required this.asOfDate,
    required this.cashInHand,
    required this.bankBalances,
    required this.mfsWallets,
    required this.activeLoansOutstanding,
    this.fixedAssets = 0.0,
    required this.memberSavingsBalance,
    this.accountsPayable = 0.0,
    this.generalReserveFund = 0.0,
    this.accumulatedSurplus = 0.0,
  });

  /// মোট চলতি সম্পদ (Current Assets)
  double get totalCurrentAssets =>
      cashInHand + bankBalances + mfsWallets + activeLoansOutstanding;

  /// সর্বমোট সম্পদ (Total Assets)
  double get totalAssets => totalCurrentAssets + fixedAssets;

  /// মোট দায় (Total Liabilities)
  double get totalLiabilities => memberSavingsBalance + accountsPayable;

  /// মোট ইক্যুইটি / মূলধন তহবিল (Total Equity)
  double get totalEquity => generalReserveFund + accumulatedSurplus;

  /// হিসাববিজ্ঞান সমীকরণ যাচাই: Assets = Liabilities + Equity
  double get balanceDifference => totalAssets - (totalLiabilities + totalEquity);
  bool get isBalanced => balanceDifference.abs() < 1.0;
}
