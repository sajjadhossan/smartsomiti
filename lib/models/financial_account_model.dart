import 'package:cloud_firestore/cloud_firestore.dart';

enum AccountType {
  cashDrawer,   // ক্যাশ ড্রয়ার (হাতের নগদ)
  bankAccount,  // বাণিজ্যিক ব্যাংক হিসাব
  mfsWallet,    // মোবাইল ফিন্যান্সিয়াল সার্ভিস (বিকাশ / নগদ / রকেট)
}

enum FinancialTransactionType {
  depositIn,        // সঞ্চয় কিস্তি জমা (আয়)
  expenseOut,       // সমিতি পরিচালনা ব্যয় (খরচ)
  loanDisbursement, // ঋণ বিতরণ (ক্যাশ আউট)
  loanRepayment,    // ঋণের কিস্তি আদায় (ক্যাশ ইন)
  transfer,         // এক একাউন্ট থেকে অন্য একাউন্টে স্থানান্তর
  adjustment,       // হিসাব সমন্বয়
}

/// Represents a financial holding account (Cash Drawer, Bank Account, or MFS)
class FinancialAccountModel {
  final String id;
  final String name;
  final AccountType type;
  final String accountNumber;
  final String bankName;
  final String branchName;
  final double currentBalance;
  final bool isDefault;
  final bool isActive;
  final DateTime createdAt;

  FinancialAccountModel({
    required this.id,
    required this.name,
    required this.type,
    this.accountNumber = '',
    this.bankName = '',
    this.branchName = '',
    this.currentBalance = 0.0,
    this.isDefault = false,
    this.isActive = true,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type.name,
      'accountNumber': accountNumber,
      'bankName': bankName,
      'branchName': branchName,
      'currentBalance': currentBalance,
      'isDefault': isDefault,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory FinancialAccountModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    AccountType t = AccountType.cashDrawer;
    try {
      t = AccountType.values.byName(data['type'] ?? 'cashDrawer');
    } catch (_) {}

    DateTime created = DateTime.now();
    final ts = data['createdAt'];
    if (ts is Timestamp) created = ts.toDate();

    return FinancialAccountModel(
      id: doc.id,
      name: data['name'] ?? 'প্রধান ক্যাশ ড্রয়ার',
      type: t,
      accountNumber: data['accountNumber'] ?? '',
      bankName: data['bankName'] ?? '',
      branchName: data['branchName'] ?? '',
      currentBalance: (data['currentBalance'] as num?)?.toDouble() ?? 0.0,
      isDefault: data['isDefault'] == true,
      isActive: data['isActive'] != false,
      createdAt: created,
    );
  }
}

/// Represents a double-entry financial ledger transaction
class FinancialTransactionModel {
  final String id;
  final String voucherNo;
  final FinancialTransactionType type;
  final double amount;
  final String fromAccountId;
  final String fromAccountName;
  final String? toAccountId;
  final String? toAccountName;
  final String category;
  final String description;
  final String referenceNo;
  final String recordedBy;
  final DateTime date;

  FinancialTransactionModel({
    required this.id,
    required this.voucherNo,
    required this.type,
    required this.amount,
    required this.fromAccountId,
    required this.fromAccountName,
    this.toAccountId,
    this.toAccountName,
    required this.category,
    required this.description,
    this.referenceNo = '',
    required this.recordedBy,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'voucherNo': voucherNo,
      'type': type.name,
      'amount': amount,
      'fromAccountId': fromAccountId,
      'fromAccountName': fromAccountName,
      'toAccountId': toAccountId,
      'toAccountName': toAccountName,
      'category': category,
      'description': description,
      'referenceNo': referenceNo,
      'recordedBy': recordedBy,
      'date': Timestamp.fromDate(date),
    };
  }

  factory FinancialTransactionModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    FinancialTransactionType t = FinancialTransactionType.expenseOut;
    try {
      t = FinancialTransactionType.values.byName(data['type'] ?? 'expenseOut');
    } catch (_) {}

    DateTime dt = DateTime.now();
    final ts = data['date'];
    if (ts is Timestamp) dt = ts.toDate();

    return FinancialTransactionModel(
      id: doc.id,
      voucherNo: data['voucherNo'] ?? 'VCH-001',
      type: t,
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      fromAccountId: data['fromAccountId'] ?? '',
      fromAccountName: data['fromAccountName'] ?? 'ক্যাশ',
      toAccountId: data['toAccountId'],
      toAccountName: data['toAccountName'],
      category: data['category'] ?? 'সাধারণ',
      description: data['description'] ?? '',
      referenceNo: data['referenceNo'] ?? '',
      recordedBy: data['recordedBy'] ?? 'এডমিন',
      date: dt,
    );
  }
}
