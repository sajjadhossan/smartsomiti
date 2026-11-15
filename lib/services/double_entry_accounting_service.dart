import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/double_entry_accounting_model.dart';

class DoubleEntryAccountingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _coaRef(String somitiId) {
    return _firestore.collection('somitis').doc(somitiId).collection('chart_of_accounts');
  }

  CollectionReference<Map<String, dynamic>> _journalsRef(String somitiId) {
    return _firestore.collection('somitis').doc(somitiId).collection('journal_entries');
  }

  CollectionReference<Map<String, dynamic>> _glRef(String somitiId) {
    return _firestore.collection('somitis').doc(somitiId).collection('general_ledger');
  }

  CollectionReference<Map<String, dynamic>> _periodsRef(String somitiId) {
    return _firestore.collection('somitis').doc(somitiId).collection('accounting_periods');
  }

  /// Initialize standardized Chart of Accounts for a society
  Future<void> ensureDefaultChartOfAccounts(String somitiId) async {
    final snap = await _coaRef(somitiId).limit(1).get();
    if (snap.docs.isNotEmpty) return;

    final batch = _firestore.batch();

    final defaultAccounts = [
      // 1000 - ASSETS
      ChartOfAccountModel(id: 'coa_1110', code: '1110', name: 'প্রধান ক্যাশ ড্রয়ার (হাতের নগদ)', category: AccountCategory.asset, normalBalance: 1, isSystemLocked: true),
      ChartOfAccountModel(id: 'coa_1121', code: '1121', name: 'ব্যাংক হিসাব (City Bank PLC)', category: AccountCategory.asset, normalBalance: 1),
      ChartOfAccountModel(id: 'coa_1131', code: '1131', name: 'বিকাশ / নগদ মার্চেন্ট ওয়ালেট (MFS)', category: AccountCategory.asset, normalBalance: 1),
      ChartOfAccountModel(id: 'coa_1141', code: '1141', name: 'ক্ষুদ্রঋণ আসল প্রাপ্য (Loan Principal Receivable)', category: AccountCategory.asset, normalBalance: 1, isSystemLocked: true),
      ChartOfAccountModel(id: 'coa_1210', code: '1210', name: 'অফিস আসবাবপত্র ও ডেকোরেশন', category: AccountCategory.asset, normalBalance: 1),
      ChartOfAccountModel(id: 'coa_1220', code: '1220', name: 'কম্পিউটার ও ইলেকট্রনিক সরঞ্জাম', category: AccountCategory.asset, normalBalance: 1),

      // 2000 - LIABILITIES (Strictly member savings deposits!)
      ChartOfAccountModel(id: 'coa_2110', code: '2110', name: 'সাধারণ দৈনিক সঞ্চয় আমানত দায়', category: AccountCategory.liability, normalBalance: -1, isSystemLocked: true),
      ChartOfAccountModel(id: 'coa_2120', code: '2120', name: 'মাসিক ডিপিএস সঞ্চয় আমানত দায়', category: AccountCategory.liability, normalBalance: -1, isSystemLocked: true),
      ChartOfAccountModel(id: 'coa_2210', code: '2210', name: 'বকেয়া কর্মকর্তা/কর্মচারী বেতন', category: AccountCategory.liability, normalBalance: -1),
      ChartOfAccountModel(id: 'coa_2220', code: '2220', name: 'বকেয়া অফিস ভাড়া', category: AccountCategory.liability, normalBalance: -1),

      // 3000 - EQUITY & RESERVES
      ChartOfAccountModel(id: 'coa_3110', code: '3110', name: 'সদস্য পরিশোধিত শেয়ার মূলধন', category: AccountCategory.equity, normalBalance: -1, isSystemLocked: true),
      ChartOfAccountModel(id: 'coa_3210', code: '3210', name: 'সংবিধিবদ্ধ সংরক্ষিত তহবিল (১৫%)', category: AccountCategory.equity, normalBalance: -1, isSystemLocked: true),
      ChartOfAccountModel(id: 'coa_3220', code: '3220', name: 'সমবায় উন্নয়ন তহবিল (৩%)', category: AccountCategory.equity, normalBalance: -1, isSystemLocked: true),
      ChartOfAccountModel(id: 'coa_3310', code: '3310', name: 'পুঞ্জীভূত নিট উদ্বৃত্ত (Retained Surplus)', category: AccountCategory.equity, normalBalance: -1, isSystemLocked: true),

      // 4000 - OPERATIONAL REVENUE
      ChartOfAccountModel(id: 'coa_4110', code: '4110', name: 'ঋণের সুদ বাবদ আয় (Interest Income)', category: AccountCategory.income, normalBalance: -1, isSystemLocked: true),
      ChartOfAccountModel(id: 'coa_4120', code: '4120', name: 'ঋণ প্রসেসিং ও ফরম ফি বাবদ আয়', category: AccountCategory.income, normalBalance: -1),
      ChartOfAccountModel(id: 'coa_4130', code: '4130', name: 'বকেয়া কিস্তির বিলম্ব ফি আয়', category: AccountCategory.income, normalBalance: -1),
      ChartOfAccountModel(id: 'coa_4210', code: '4210', name: 'সদস্য ভর্তি ও পাসবুক ফি বাবদ আয়', category: AccountCategory.income, normalBalance: -1),

      // 5000 - OPERATIONAL EXPENSES
      ChartOfAccountModel(id: 'coa_5210', code: '5210', name: 'কর্মকর্তা-কর্মচারীদের বেতন ও ভাতা', category: AccountCategory.expense, normalBalance: 1, isSystemLocked: true),
      ChartOfAccountModel(id: 'coa_5310', code: '5310', name: 'অফিস ভাড়া খরচ', category: AccountCategory.expense, normalBalance: 1),
      ChartOfAccountModel(id: 'coa_5320', code: '5320', name: 'বিদ্যুৎ ও ইন্টারনেট বিল', category: AccountCategory.expense, normalBalance: 1),
      ChartOfAccountModel(id: 'coa_5330', code: '5330', name: 'কাগজ, প্রিন্টিং ও স্টেশনারি', category: AccountCategory.expense, normalBalance: 1),
      ChartOfAccountModel(id: 'coa_5340', code: '5340', name: 'আপ্যায়ন ও মেহমানদারি খরচ', category: AccountCategory.expense, normalBalance: 1),
      ChartOfAccountModel(id: 'coa_5120', code: '5120', name: 'ব্যাংক ও মোবাইল ব্যাংকিং চার্জ', category: AccountCategory.expense, normalBalance: 1),
      ChartOfAccountModel(id: 'coa_5390', code: '5390', name: 'বিবিধ অফিস পরিচালনা ব্যয়', category: AccountCategory.expense, normalBalance: 1),
    ];

    for (final acc in defaultAccounts) {
      batch.set(_coaRef(somitiId).doc(acc.id), acc.toMap());
    }

    await batch.commit();
  }

  /// Real-time stream of all Chart of Accounts
  Stream<List<ChartOfAccountModel>> getChartOfAccountsStream(String somitiId) {
    return _coaRef(somitiId)
        .orderBy('code')
        .snapshots()
        .map((s) => s.docs.map((d) => ChartOfAccountModel.fromSnapshot(d)).toList());
  }

  /// Post a complete Double-Entry Journal Entry with zero-sum validation
  Future<String> createAndPostJournalEntry(
    String somitiId,
    JournalEntryModel entry,
  ) async {
    // 1. Strict Double-Entry Invariant Validation
    final sumDebit = entry.lines.fold<int>(0, (prev, l) => prev + l.debitInPoisha);
    final sumCredit = entry.lines.fold<int>(0, (prev, l) => prev + l.creditInPoisha);

    if (sumDebit <= 0 || sumDebit != sumCredit) {
      throw Exception('অসম জাবেদা বাতিল: মোট ডেবিট (৳${sumDebit / 100}) এবং মোট ক্রেডিট (৳${sumCredit / 100}) সমান হতে হবে!');
    }

    final journalDocRef = entry.id.isNotEmpty ? _journalsRef(somitiId).doc(entry.id) : _journalsRef(somitiId).doc();
    final now = DateTime.now();

    await _firestore.runTransaction((transaction) async {
      // 2. Check Idempotency
      if (entry.idempotencyKey.isNotEmpty) {
        final existing = await _journalsRef(somitiId)
            .where('idempotencyKey', isEqualTo: entry.idempotencyKey)
            .limit(1)
            .get();
        if (existing.docs.isNotEmpty) {
          return; // Duplicate submission prevented
        }
      }

      // 3. Set Journal Entry Document
      transaction.set(journalDocRef, {
        ...entry.toMap(),
        'totalDebitInPoisha': sumDebit,
        'totalCreditInPoisha': sumCredit,
        'status': JournalStatus.posted.name,
        'postedAt': Timestamp.fromDate(now),
      });

      // 4. Update individual Account balances & create General Ledger lines
      for (final line in entry.lines) {
        final glDocRef = _glRef(somitiId).doc();
        final accDocRef = _coaRef(somitiId).doc(line.accountId);

        final accSnap = await transaction.get(accDocRef);
        int currentBalInPoisha = 0;
        int normalBal = 1;
        if (accSnap.exists) {
          currentBalInPoisha = (accSnap.data()?['balanceInPoisha'] as num?)?.toInt() ?? 0;
          normalBal = (accSnap.data()?['normalBalance'] as num?)?.toInt() ?? 1;
        }

        // Account balance calculation based on normal balance direction
        int balanceDelta = 0;
        if (normalBal == 1) {
          // Debit increases, Credit decreases (Assets, Expenses)
          balanceDelta = line.debitInPoisha - line.creditInPoisha;
        } else {
          // Credit increases, Debit decreases (Liabilities, Equity, Income)
          balanceDelta = line.creditInPoisha - line.debitInPoisha;
        }

        final newBalanceInPoisha = currentBalInPoisha + balanceDelta;

        if (accSnap.exists) {
          transaction.update(accDocRef, {'balanceInPoisha': newBalanceInPoisha});
        }

        // Write GL Line
        transaction.set(glDocRef, {
          'somitiId': somitiId,
          'journalId': journalDocRef.id,
          'journalNumber': entry.journalNumber,
          'entryDate': Timestamp.fromDate(entry.entryDate),
          'accountingPeriodId': entry.accountingPeriodId,
          'accountId': line.accountId,
          'accountCode': line.accountCode,
          'accountName': line.accountName,
          'category': line.category.name,
          'debitInPoisha': line.debitInPoisha,
          'creditInPoisha': line.creditInPoisha,
          'runningBalanceInPoisha': newBalanceInPoisha,
          'description': entry.description,
          'referenceNo': entry.referenceNo,
          'createdByUid': entry.createdByUid,
          'postedAt': Timestamp.fromDate(now),
        });
      }
    });

    return journalDocRef.id;
  }

  /// Reverse a posted Journal Entry
  Future<String> reverseJournalEntry(
    String somitiId, {
    required String originalJournalId,
    required String reason,
    required String actorUid,
    required String actorName,
  }) async {
    final origDoc = await _journalsRef(somitiId).doc(originalJournalId).get();
    if (!origDoc.exists) throw Exception('মূল জাবেদা পাওয়া যায়নি');

    final origEntry = JournalEntryModel.fromSnapshot(origDoc);
    if (origEntry.status == JournalStatus.reversed) {
      throw Exception('এই জাবেদাটি ইতিমধ্যে রিভার্স বা সংশোধন করা হয়েছে');
    }

    final now = DateTime.now();
    final revJournalNo = 'REV-${now.year}${now.month.toString().padLeft(2, '0')}-${origEntry.journalNumber}';

    // Reverse lines: Swap debits and credits
    final revLines = origEntry.lines.map((l) {
      return JournalLineModel(
        lineNumber: l.lineNumber,
        accountId: l.accountId,
        accountCode: l.accountCode,
        accountName: l.accountName,
        category: l.category,
        debitInPoisha: l.creditInPoisha, // Swapped!
        creditInPoisha: l.debitInPoisha, // Swapped!
        memo: 'সংশোধনী রিভার্সাল: ${l.memo}',
      );
    }).toList();

    final revEntry = JournalEntryModel(
      id: '',
      journalNumber: revJournalNo,
      somitiId: somitiId,
      entryDate: now,
      accountingPeriodId: origEntry.accountingPeriodId,
      voucherType: VoucherType.reversal,
      description: 'সংশোধনী রিভার্সাল: $reason (মূল জাবেদা: ${origEntry.journalNumber})',
      referenceNo: origEntry.journalNumber,
      idempotencyKey: 'REV-${origEntry.id}',
      totalDebitInPoisha: origEntry.totalCreditInPoisha,
      totalCreditInPoisha: origEntry.totalDebitInPoisha,
      lines: revLines,
      createdByUid: actorUid,
      createdByName: actorName,
      reversalOfJournalId: originalJournalId,
    );

    final newRevId = await createAndPostJournalEntry(somitiId, revEntry);

    // Mark original as reversed
    await _journalsRef(somitiId).doc(originalJournalId).update({
      'status': JournalStatus.reversed.name,
      'reversedByJournalId': newRevId,
    });

    return newRevId;
  }

  /// Generate Trial Balance
  Future<TrialBalanceReport> generateTrialBalance(String somitiId, DateTime asOfDate) async {
    final coaSnap = await _coaRef(somitiId).where('isActive', isEqualTo: true).get();
    final List<TrialBalanceLine> lines = [];
    int totalDebit = 0;
    int totalCredit = 0;

    for (final doc in coaSnap.docs) {
      final acc = ChartOfAccountModel.fromSnapshot(doc);
      if (acc.balanceInPoisha == 0) continue;

      int d = 0;
      int c = 0;
      if (acc.normalBalance == 1) {
        if (acc.balanceInPoisha > 0) {
          d = acc.balanceInPoisha;
        } else {
          c = acc.balanceInPoisha.abs();
        }
      } else {
        if (acc.balanceInPoisha > 0) {
          c = acc.balanceInPoisha;
        } else {
          d = acc.balanceInPoisha.abs();
        }
      }

      totalDebit += d;
      totalCredit += c;

      lines.add(TrialBalanceLine(
        accountCode: acc.code,
        accountName: acc.name,
        category: acc.category,
        debitInPoisha: d,
        creditInPoisha: c,
      ));
    }

    return TrialBalanceReport(
      asOfDate: asOfDate,
      lines: lines,
      totalDebitInPoisha: totalDebit,
      totalCreditInPoisha: totalCredit,
    );
  }

  /// Real-time stream of General Ledger
  Stream<List<GeneralLedgerEntryModel>> getLedgerStream(String somitiId, {String? accountId, int limit = 100}) {
    Query<Map<String, dynamic>> q = _glRef(somitiId).orderBy('postedAt', descending: true).limit(limit);
    if (accountId != null && accountId.isNotEmpty) {
      q = _glRef(somitiId).where('accountId', isEqualTo: accountId).orderBy('postedAt', descending: true).limit(limit);
    }
    return q.snapshots().map((s) => s.docs.map((d) => GeneralLedgerEntryModel.fromSnapshot(d)).toList());
  }
}
