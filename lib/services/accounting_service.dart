import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/financial_account_model.dart';

class AccountingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _accountsRef(String somitiId) {
    return _firestore.collection('somitis').doc(somitiId).collection('financial_accounts');
  }

  CollectionReference<Map<String, dynamic>> _transactionsRef(String somitiId) {
    return _firestore.collection('somitis').doc(somitiId).collection('financial_transactions');
  }

  /// Ensure society has default financial accounts (Primary Cash Drawer, MFS, Bank)
  Future<void> ensureDefaultAccounts(String somitiId) async {
    final snapshot = await _accountsRef(somitiId).limit(1).get();
    if (snapshot.docs.isEmpty) {
      final batch = _firestore.batch();

      // 1. প্রধান ক্যাশ ড্রয়ার (হাতের নগদ)
      final cashDoc = _accountsRef(somitiId).doc();
      batch.set(cashDoc, {
        'name': 'প্রধান ক্যাশ ড্রয়ার (হাতের নগদ)',
        'type': AccountType.cashDrawer.name,
        'accountNumber': 'CASH-MAIN',
        'bankName': '',
        'branchName': 'প্রধান কার্যালয়',
        'currentBalance': 0.0,
        'isDefault': true,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 2. বিকাশ / নগদ ওয়ালেট (MFS)
      final mfsDoc = _accountsRef(somitiId).doc();
      batch.set(mfsDoc, {
        'name': 'বিকাশ / নগদ মার্চেন্ট ওয়ালেট',
        'type': AccountType.mfsWallet.name,
        'accountNumber': '',
        'bankName': 'bKash / Nagad',
        'branchName': 'ডিজিটাল পেমেন্ট',
        'currentBalance': 0.0,
        'isDefault': false,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    }
  }

  /// Real-time stream of all financial accounts
  Stream<List<FinancialAccountModel>> getAccountsStream(String somitiId) {
    return _accountsRef(somitiId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => FinancialAccountModel.fromSnapshot(d)).toList());
  }

  /// Create a new bank account or wallet
  Future<void> createAccount(String somitiId, FinancialAccountModel account) async {
    await _accountsRef(somitiId).add(account.toMap());
  }

  /// Update an existing account
  Future<void> updateAccount(String somitiId, String accountId, Map<String, dynamic> updates) async {
    await _accountsRef(somitiId).doc(accountId).update(updates);
  }

  /// Real-time stream of general ledger transactions
  Stream<List<FinancialTransactionModel>> getTransactionsStream(String somitiId, {int limit = 100}) {
    return _transactionsRef(somitiId)
        .orderBy('date', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((d) => FinancialTransactionModel.fromSnapshot(d)).toList());
  }

  /// Generate next formatted voucher number
  String _generateVoucherNo(String prefix) {
    final now = DateTime.now();
    return '$prefix-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch.toString().substring(8)}';
  }

  /// Record an Expense (খরচ) with automatic balance deduction
  Future<void> recordExpense(
    String somitiId, {
    required String accountId,
    required String accountName,
    required double amount,
    required String category,
    required String description,
    required String recordedBy,
    String referenceNo = '',
  }) async {
    if (amount <= 0) throw Exception('খরচের পরিমাণ শূন্যের বেশি হতে হবে');

    final voucherNo = _generateVoucherNo('EXP');
    final accountRef = _accountsRef(somitiId).doc(accountId);
    final txRef = _transactionsRef(somitiId).doc();

    await _firestore.runTransaction((transaction) async {
      final accSnap = await transaction.get(accountRef);
      if (!accSnap.exists) throw Exception('নির্বাচিত একাউন্ট পাওয়া যায়নি');

      final currentBalance = (accSnap.data()?['currentBalance'] as num?)?.toDouble() ?? 0.0;
      final newBalance = currentBalance - amount;

      transaction.update(accountRef, {'currentBalance': newBalance});

      transaction.set(txRef, {
        'voucherNo': voucherNo,
        'type': FinancialTransactionType.expenseOut.name,
        'amount': amount,
        'fromAccountId': accountId,
        'fromAccountName': accountName,
        'category': category,
        'description': description,
        'referenceNo': referenceNo,
        'recordedBy': recordedBy,
        'date': Timestamp.fromDate(DateTime.now()),
      });
    });
  }

  /// Record Miscellaneous Income (বিবিধ আয়)
  Future<void> recordIncome(
    String somitiId, {
    required String accountId,
    required String accountName,
    required double amount,
    required String category,
    required String description,
    required String recordedBy,
    String referenceNo = '',
  }) async {
    if (amount <= 0) throw Exception('আয়ের পরিমাণ শূন্যের বেশি হতে হবে');

    final voucherNo = _generateVoucherNo('INC');
    final accountRef = _accountsRef(somitiId).doc(accountId);
    final txRef = _transactionsRef(somitiId).doc();

    await _firestore.runTransaction((transaction) async {
      final accSnap = await transaction.get(accountRef);
      if (!accSnap.exists) throw Exception('নির্বাচিত একাউন্ট পাওয়া যায়নি');

      final currentBalance = (accSnap.data()?['currentBalance'] as num?)?.toDouble() ?? 0.0;
      final newBalance = currentBalance + amount;

      transaction.update(accountRef, {'currentBalance': newBalance});

      transaction.set(txRef, {
        'voucherNo': voucherNo,
        'type': FinancialTransactionType.adjustment.name,
        'amount': amount,
        'fromAccountId': accountId,
        'fromAccountName': accountName,
        'category': category,
        'description': description,
        'referenceNo': referenceNo,
        'recordedBy': recordedBy,
        'date': Timestamp.fromDate(DateTime.now()),
      });
    });
  }

  /// Transfer funds between accounts (যেমন: ক্যাশ থেকে ব্যাংকে জমা বা ব্যাংক থেকে উত্তোলন)
  Future<void> transferFunds(
    String somitiId, {
    required String fromAccountId,
    required String fromAccountName,
    required String toAccountId,
    required String toAccountName,
    required double amount,
    required String recordedBy,
    String note = '',
  }) async {
    if (amount <= 0) throw Exception('স্থানান্তরের পরিমাণ শূন্যের বেশি হতে হবে');
    if (fromAccountId == toAccountId) throw Exception('একই একাউন্টে স্থানান্তর সম্ভব নয়');

    final voucherNo = _generateVoucherNo('TRF');
    final fromRef = _accountsRef(somitiId).doc(fromAccountId);
    final toRef = _accountsRef(somitiId).doc(toAccountId);
    final txRef = _transactionsRef(somitiId).doc();

    await _firestore.runTransaction((transaction) async {
      final fromSnap = await transaction.get(fromRef);
      final toSnap = await transaction.get(toRef);

      if (!fromSnap.exists || !toSnap.exists) {
        throw Exception('উৎস বা গন্তব্য একাউন্ট পাওয়া যায়নি');
      }

      final fromBal = (fromSnap.data()?['currentBalance'] as num?)?.toDouble() ?? 0.0;
      final toBal = (toSnap.data()?['currentBalance'] as num?)?.toDouble() ?? 0.0;

      transaction.update(fromRef, {'currentBalance': fromBal - amount});
      transaction.update(toRef, {'currentBalance': toBal + amount});

      transaction.set(txRef, {
        'voucherNo': voucherNo,
        'type': FinancialTransactionType.transfer.name,
        'amount': amount,
        'fromAccountId': fromAccountId,
        'fromAccountName': fromAccountName,
        'toAccountId': toAccountId,
        'toAccountName': toAccountName,
        'category': 'হিসাব স্থানান্তর',
        'description': note.isNotEmpty ? note : '$fromAccountName থেকে $toAccountName এ তহবিল স্থানান্তর',
        'referenceNo': '',
        'recordedBy': recordedBy,
        'date': Timestamp.fromDate(DateTime.now()),
      });
    });
  }
}
