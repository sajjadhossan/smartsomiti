import 'package:cloud_firestore/cloud_firestore.dart';

enum AccountCategory {
  asset,       // ১০০০: সম্পদ (Assets) - স্বাভাবিক ব্যালেন্স ডেবিট
  liability,   // ২০০০: দায় (Liabilities) - স্বাভাবিক ব্যালেন্স ক্রেডিট
  equity,      // ৩০০০: মূলধন ও রিজার্ভ (Equity) - স্বাভাবিক ব্যালেন্স ক্রেডিট
  income,      // ৪০০০: পরিচালন আয় (Revenue/Income) - স্বাভাবিক ব্যালেন্স ক্রেডিট
  expense,     // ৫০০০: পরিচালন ব্যয় (Expenses) - স্বাভাবিক ব্যালেন্স ডেবিট
}

enum JournalStatus {
  draft,       // খসড়া
  submitted,   // অনুমোদনের অপেক্ষায়
  approved,    // অনুমোদিত
  posted,      // লেজারে চূড়ান্ত পোস্টকৃত (অপরিবর্তনযোগ্য)
  reversed,    // সংশোধিত / বাতিলকৃত (রিভার্সাল এন্ট্রি দ্বারা সমন্বিত)
}

enum VoucherType {
  journal,     // সাধারণ জাবেদা ভাউচার (JV)
  receipt,     // জমা / প্রাপ্তি ভাউচার (RV)
  payment,     // খরচ / পেমেন্ট ভাউচার (PV)
  contra,      // কন্ট্রা / তহবিল স্থানান্তর (CV)
  reversal,    // সংশোধনী রিভার্সাল ভাউচার (REV)
}

/// Represents a Chart of Accounts (COA) entry
class ChartOfAccountModel {
  final String id;
  final String code;
  final String name;
  final String englishName;
  final AccountCategory category;
  final String parentCode;
  final bool isHeaderAccount;
  final int normalBalance; // +1 for Debit, -1 for Credit
  final int balanceInPoisha;
  final bool isSystemLocked;
  final bool isActive;

  ChartOfAccountModel({
    required this.id,
    required this.code,
    required this.name,
    this.englishName = '',
    required this.category,
    this.parentCode = '',
    this.isHeaderAccount = false,
    this.normalBalance = 1,
    this.balanceInPoisha = 0,
    this.isSystemLocked = false,
    this.isActive = true,
  });

  double get balanceInTaka => balanceInPoisha / 100.0;

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'name': name,
      'englishName': englishName,
      'category': category.name,
      'parentCode': parentCode,
      'isHeaderAccount': isHeaderAccount,
      'normalBalance': normalBalance,
      'balanceInPoisha': balanceInPoisha,
      'isSystemLocked': isSystemLocked,
      'isActive': isActive,
    };
  }

  factory ChartOfAccountModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    AccountCategory cat = AccountCategory.asset;
    try {
      cat = AccountCategory.values.byName(data['category'] ?? 'asset');
    } catch (_) {}

    return ChartOfAccountModel(
      id: doc.id,
      code: data['code'] ?? '',
      name: data['name'] ?? '',
      englishName: data['englishName'] ?? '',
      category: cat,
      parentCode: data['parentCode'] ?? '',
      isHeaderAccount: data['isHeaderAccount'] == true,
      normalBalance: (data['normalBalance'] as num?)?.toInt() ?? 1,
      balanceInPoisha: (data['balanceInPoisha'] as num?)?.toInt() ?? 0,
      isSystemLocked: data['isSystemLocked'] == true,
      isActive: data['isActive'] != false,
    );
  }
}

/// Individual line inside a Journal Entry
class JournalLineModel {
  final int lineNumber;
  final String accountId;
  final String accountCode;
  final String accountName;
  final AccountCategory category;
  final int debitInPoisha;
  final int creditInPoisha;
  final String memo;

  JournalLineModel({
    required this.lineNumber,
    required this.accountId,
    required this.accountCode,
    required this.accountName,
    required this.category,
    this.debitInPoisha = 0,
    this.creditInPoisha = 0,
    this.memo = '',
  });

  double get debitInTaka => debitInPoisha / 100.0;
  double get creditInTaka => creditInPoisha / 100.0;

  Map<String, dynamic> toMap() {
    return {
      'lineNumber': lineNumber,
      'accountId': accountId,
      'accountCode': accountCode,
      'accountName': accountName,
      'category': category.name,
      'debitInPoisha': debitInPoisha,
      'creditInPoisha': creditInPoisha,
      'memo': memo,
    };
  }

  factory JournalLineModel.fromMap(Map<String, dynamic> map) {
    AccountCategory cat = AccountCategory.asset;
    try {
      cat = AccountCategory.values.byName(map['category'] ?? 'asset');
    } catch (_) {}

    return JournalLineModel(
      lineNumber: (map['lineNumber'] as num?)?.toInt() ?? 1,
      accountId: map['accountId'] ?? '',
      accountCode: map['accountCode'] ?? '',
      accountName: map['accountName'] ?? '',
      category: cat,
      debitInPoisha: (map['debitInPoisha'] as num?)?.toInt() ?? 0,
      creditInPoisha: (map['creditInPoisha'] as num?)?.toInt() ?? 0,
      memo: map['memo'] ?? '',
    );
  }
}

/// Represents a double-entry Journal Voucher (JV)
class JournalEntryModel {
  final String id;
  final String journalNumber;
  final String somitiId;
  final DateTime entryDate;
  final String accountingPeriodId;
  final VoucherType voucherType;
  final String description;
  final String referenceNo;
  final String relatedEventId;
  final String idempotencyKey;
  final JournalStatus status;
  final int totalDebitInPoisha;
  final int totalCreditInPoisha;
  final List<JournalLineModel> lines;
  final String createdByUid;
  final String createdByName;
  final String? approvedByUid;
  final String? approvedByName;
  final DateTime? postedAt;
  final String? reversalOfJournalId;
  final String? reversedByJournalId;

  JournalEntryModel({
    required this.id,
    required this.journalNumber,
    required this.somitiId,
    required this.entryDate,
    required this.accountingPeriodId,
    required this.voucherType,
    required this.description,
    this.referenceNo = '',
    this.relatedEventId = '',
    required this.idempotencyKey,
    this.status = JournalStatus.posted,
    required this.totalDebitInPoisha,
    required this.totalCreditInPoisha,
    required this.lines,
    required this.createdByUid,
    this.createdByName = '',
    this.approvedByUid,
    this.approvedByName,
    this.postedAt,
    this.reversalOfJournalId,
    this.reversedByJournalId,
  });

  bool get isBalanced => totalDebitInPoisha > 0 && totalDebitInPoisha == totalCreditInPoisha;
  double get totalDebitInTaka => totalDebitInPoisha / 100.0;
  double get totalCreditInTaka => totalCreditInPoisha / 100.0;

  Map<String, dynamic> toMap() {
    return {
      'journalNumber': journalNumber,
      'somitiId': somitiId,
      'entryDate': Timestamp.fromDate(entryDate),
      'accountingPeriodId': accountingPeriodId,
      'voucherType': voucherType.name,
      'description': description,
      'referenceNo': referenceNo,
      'relatedEventId': relatedEventId,
      'idempotencyKey': idempotencyKey,
      'status': status.name,
      'totalDebitInPoisha': totalDebitInPoisha,
      'totalCreditInPoisha': totalCreditInPoisha,
      'lines': lines.map((l) => l.toMap()).toList(),
      'createdByUid': createdByUid,
      'createdByName': createdByName,
      'approvedByUid': approvedByUid,
      'approvedByName': approvedByName,
      'postedAt': postedAt != null ? Timestamp.fromDate(postedAt!) : null,
      'reversalOfJournalId': reversalOfJournalId,
      'reversedByJournalId': reversedByJournalId,
    };
  }

  factory JournalEntryModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    VoucherType vt = VoucherType.journal;
    try {
      vt = VoucherType.values.byName(data['voucherType'] ?? 'journal');
    } catch (_) {}

    JournalStatus st = JournalStatus.posted;
    try {
      st = JournalStatus.values.byName(data['status'] ?? 'posted');
    } catch (_) {}

    DateTime entryD = DateTime.now();
    final tsEntry = data['entryDate'];
    if (tsEntry is Timestamp) entryD = tsEntry.toDate();

    DateTime? postD;
    final tsPost = data['postedAt'];
    if (tsPost is Timestamp) postD = tsPost.toDate();

    final rawLines = (data['lines'] as List<dynamic>?) ?? [];
    final linesList = rawLines.map((l) => JournalLineModel.fromMap(Map<String, dynamic>.from(l))).toList();

    return JournalEntryModel(
      id: doc.id,
      journalNumber: data['journalNumber'] ?? '',
      somitiId: data['somitiId'] ?? '',
      entryDate: entryD,
      accountingPeriodId: data['accountingPeriodId'] ?? '',
      voucherType: vt,
      description: data['description'] ?? '',
      referenceNo: data['referenceNo'] ?? '',
      relatedEventId: data['relatedEventId'] ?? '',
      idempotencyKey: data['idempotencyKey'] ?? '',
      status: st,
      totalDebitInPoisha: (data['totalDebitInPoisha'] as num?)?.toInt() ?? 0,
      totalCreditInPoisha: (data['totalCreditInPoisha'] as num?)?.toInt() ?? 0,
      lines: linesList,
      createdByUid: data['createdByUid'] ?? '',
      createdByName: data['createdByName'] ?? '',
      approvedByUid: data['approvedByUid'],
      approvedByName: data['approvedByName'],
      postedAt: postD,
      reversalOfJournalId: data['reversalOfJournalId'],
      reversedByJournalId: data['reversedByJournalId'],
    );
  }
}

/// Represents a General Ledger record
class GeneralLedgerEntryModel {
  final String id;
  final String somitiId;
  final String journalId;
  final String journalNumber;
  final DateTime entryDate;
  final String accountingPeriodId;
  final String accountId;
  final String accountCode;
  final String accountName;
  final AccountCategory category;
  final int debitInPoisha;
  final int creditInPoisha;
  final int runningBalanceInPoisha;
  final String description;
  final String referenceNo;
  final String createdByUid;
  final DateTime postedAt;

  GeneralLedgerEntryModel({
    required this.id,
    required this.somitiId,
    required this.journalId,
    required this.journalNumber,
    required this.entryDate,
    required this.accountingPeriodId,
    required this.accountId,
    required this.accountCode,
    required this.accountName,
    required this.category,
    this.debitInPoisha = 0,
    this.creditInPoisha = 0,
    this.runningBalanceInPoisha = 0,
    required this.description,
    this.referenceNo = '',
    required this.createdByUid,
    required this.postedAt,
  });

  double get debitInTaka => debitInPoisha / 100.0;
  double get creditInTaka => creditInPoisha / 100.0;
  double get runningBalanceInTaka => runningBalanceInPoisha / 100.0;

  Map<String, dynamic> toMap() {
    return {
      'somitiId': somitiId,
      'journalId': journalId,
      'journalNumber': journalNumber,
      'entryDate': Timestamp.fromDate(entryDate),
      'accountingPeriodId': accountingPeriodId,
      'accountId': accountId,
      'accountCode': accountCode,
      'accountName': accountName,
      'category': category.name,
      'debitInPoisha': debitInPoisha,
      'creditInPoisha': creditInPoisha,
      'runningBalanceInPoisha': runningBalanceInPoisha,
      'description': description,
      'referenceNo': referenceNo,
      'createdByUid': createdByUid,
      'postedAt': Timestamp.fromDate(postedAt),
    };
  }

  factory GeneralLedgerEntryModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    AccountCategory cat = AccountCategory.asset;
    try {
      cat = AccountCategory.values.byName(data['category'] ?? 'asset');
    } catch (_) {}

    DateTime entryD = DateTime.now();
    final tsEntry = data['entryDate'];
    if (tsEntry is Timestamp) entryD = tsEntry.toDate();

    DateTime postD = DateTime.now();
    final tsPost = data['postedAt'];
    if (tsPost is Timestamp) postD = tsPost.toDate();

    return GeneralLedgerEntryModel(
      id: doc.id,
      somitiId: data['somitiId'] ?? '',
      journalId: data['journalId'] ?? '',
      journalNumber: data['journalNumber'] ?? '',
      entryDate: entryD,
      accountingPeriodId: data['accountingPeriodId'] ?? '',
      accountId: data['accountId'] ?? '',
      accountCode: data['accountCode'] ?? '',
      accountName: data['accountName'] ?? '',
      category: cat,
      debitInPoisha: (data['debitInPoisha'] as num?)?.toInt() ?? 0,
      creditInPoisha: (data['creditInPoisha'] as num?)?.toInt() ?? 0,
      runningBalanceInPoisha: (data['runningBalanceInPoisha'] as num?)?.toInt() ?? 0,
      description: data['description'] ?? '',
      referenceNo: data['referenceNo'] ?? '',
      createdByUid: data['createdByUid'] ?? '',
      postedAt: postD,
    );
  }
}

/// Represents an Accounting Period (Monthly or Annual)
class AccountingPeriodModel {
  final String id;
  final String somitiId;
  final String periodName; // e.g. "নভেম্বর ২০২৬"
  final DateTime startDate;
  final DateTime endDate;
  final bool isLocked;
  final String? closedByUid;
  final DateTime? closedAt;
  final String? reopenReason;

  AccountingPeriodModel({
    required this.id,
    required this.somitiId,
    required this.periodName,
    required this.startDate,
    required this.endDate,
    this.isLocked = false,
    this.closedByUid,
    this.closedAt,
    this.reopenReason,
  });

  Map<String, dynamic> toMap() {
    return {
      'somitiId': somitiId,
      'periodName': periodName,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'isLocked': isLocked,
      'closedByUid': closedByUid,
      'closedAt': closedAt != null ? Timestamp.fromDate(closedAt!) : null,
      'reopenReason': reopenReason,
    };
  }

  factory AccountingPeriodModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    DateTime sDate = DateTime.now();
    final tsS = data['startDate'];
    if (tsS is Timestamp) sDate = tsS.toDate();

    DateTime eDate = DateTime.now();
    final tsE = data['endDate'];
    if (tsE is Timestamp) eDate = tsE.toDate();

    DateTime? cDate;
    final tsC = data['closedAt'];
    if (tsC is Timestamp) cDate = tsC.toDate();

    return AccountingPeriodModel(
      id: doc.id,
      somitiId: data['somitiId'] ?? '',
      periodName: data['periodName'] ?? '',
      startDate: sDate,
      endDate: eDate,
      isLocked: data['isLocked'] == true,
      closedByUid: data['closedByUid'],
      closedAt: cDate,
      reopenReason: data['reopenReason'],
    );
  }
}

/// Represents a Trial Balance row
class TrialBalanceLine {
  final String accountCode;
  final String accountName;
  final AccountCategory category;
  final int debitInPoisha;
  final int creditInPoisha;

  TrialBalanceLine({
    required this.accountCode,
    required this.accountName,
    required this.category,
    required this.debitInPoisha,
    required this.creditInPoisha,
  });

  double get debitInTaka => debitInPoisha / 100.0;
  double get creditInTaka => creditInPoisha / 100.0;
}

/// Represents complete Trial Balance Statement
class TrialBalanceReport {
  final DateTime asOfDate;
  final List<TrialBalanceLine> lines;
  final int totalDebitInPoisha;
  final int totalCreditInPoisha;

  TrialBalanceReport({
    required this.asOfDate,
    required this.lines,
    required this.totalDebitInPoisha,
    required this.totalCreditInPoisha,
  });

  bool get isBalanced => totalDebitInPoisha == totalCreditInPoisha;
  int get differenceInPoisha => (totalDebitInPoisha - totalCreditInPoisha).abs();
  double get totalDebitInTaka => totalDebitInPoisha / 100.0;
  double get totalCreditInTaka => totalCreditInPoisha / 100.0;
}
