import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/loan_model.dart';
import '../models/financial_account_model.dart';

class LoanService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _loansRef(String somitiId) {
    return _firestore.collection('somitis').doc(somitiId).collection('loans');
  }

  CollectionReference<Map<String, dynamic>> _applicationsRef(String somitiId) {
    return _firestore.collection('somitis').doc(somitiId).collection('loan_applications');
  }

  CollectionReference<Map<String, dynamic>> _accountsRef(String somitiId) {
    return _firestore.collection('somitis').doc(somitiId).collection('financial_accounts');
  }

  CollectionReference<Map<String, dynamic>> _transactionsRef(String somitiId) {
    return _firestore.collection('somitis').doc(somitiId).collection('financial_transactions');
  }

  /// Real-time stream of active/settled loans
  Stream<List<LoanModel>> getLoansStream(String somitiId) {
    return _loansRef(somitiId)
        .orderBy('disbursementDate', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => LoanModel.fromSnapshot(d)).toList());
  }

  /// Real-time stream of loan applications
  Stream<List<LoanApplicationModel>> getLoanApplicationsStream(String somitiId) {
    return _applicationsRef(somitiId)
        .orderBy('appliedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => LoanApplicationModel.fromSnapshot(d)).toList());
  }

  /// Submit a new loan application
  Future<void> submitLoanApplication(String somitiId, LoanApplicationModel application) async {
    await _applicationsRef(somitiId).add(application.toMap());
  }

  /// Review (Approve or Reject) loan application
  Future<void> reviewLoanApplication(
    String somitiId,
    String applicationId, {
    required bool approve,
    String? reviewNote,
    required String reviewerName,
  }) async {
    await _applicationsRef(somitiId).doc(applicationId).update({
      'status': approve ? 'approved' : 'rejected',
      'reviewNote': reviewNote,
      'reviewedBy': reviewerName,
      'reviewedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Disburse an approved loan: creates active loan record, generates amortization schedule, and disburses cash
  Future<void> disburseApprovedLoan(
    String somitiId,
    LoanApplicationModel app, {
    required String accountId,
    required String accountName,
    required String approvedBy,
  }) async {
    final loanDocRef = _loansRef(somitiId).doc();
    final appDocRef = _applicationsRef(somitiId).doc(app.id);
    final accDocRef = _accountsRef(somitiId).doc(accountId);
    final txDocRef = _transactionsRef(somitiId).doc();

    final now = DateTime.now();
    // Schedule amortization calculation
    final schedule = LoanModel.generateSchedule(
      principal: app.requestedAmount,
      annualRatePercent: app.proposedInterestRate,
      months: app.durationMonths,
      interestType: app.interestType,
      startDate: now,
    );

    double totalInterest = 0.0;
    double totalPayable = 0.0;
    for (var inst in schedule) {
      totalInterest += inst.interestPortion;
      totalPayable += inst.totalInstallmentAmount;
    }

    final newLoan = LoanModel(
      id: loanDocRef.id,
      memberId: app.memberId,
      memberName: app.memberName,
      memberNumber: app.memberNumber,
      principalAmount: app.requestedAmount,
      interestRatePercent: app.proposedInterestRate,
      interestType: app.interestType,
      durationMonths: app.durationMonths,
      totalInterest: double.parse(totalInterest.toStringAsFixed(2)),
      totalPayable: double.parse(totalPayable.toStringAsFixed(2)),
      totalPaid: 0.0,
      outstandingBalance: double.parse(totalPayable.toStringAsFixed(2)),
      status: LoanStatus.disbursed,
      disbursementDate: now,
      approvedBy: approvedBy,
      guarantorName: app.guarantorName,
      guarantorPhone: app.guarantorPhone,
      schedule: schedule,
    );

    final voucherNo = 'LN-DISB-${now.year}${now.month.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch.toString().substring(8)}';

    await _firestore.runTransaction((transaction) async {
      final accSnap = await transaction.get(accDocRef);
      if (!accSnap.exists) throw Exception('তহবিল হিসাব পাওয়া যায়নি');

      final currentBalance = (accSnap.data()?['currentBalance'] as num?)?.toDouble() ?? 0.0;
      if (currentBalance < app.requestedAmount) {
        throw Exception('নির্বাচিত একাউন্টে পর্যাপ্ত ব্যালেন্স নেই (বর্তমান: ৳$currentBalance)');
      }

      // 1. Deduct cash from account
      transaction.update(accDocRef, {'currentBalance': currentBalance - app.requestedAmount});

      // 2. Add cashbook transaction
      transaction.set(txDocRef, {
        'voucherNo': voucherNo,
        'type': FinancialTransactionType.loanDisbursement.name,
        'amount': app.requestedAmount,
        'fromAccountId': accountId,
        'fromAccountName': accountName,
        'category': 'ঋণ বিতরণ',
        'description': '${app.memberName}-কে ঋণ প্রদান (ভাউচার: $voucherNo)',
        'referenceNo': loanDocRef.id,
        'recordedBy': approvedBy,
        'date': Timestamp.fromDate(now),
      });

      // 3. Create Loan Record
      transaction.set(loanDocRef, newLoan.toMap());

      // 4. Update application status
      transaction.update(appDocRef, {
        'status': 'disbursed',
        'reviewedBy': approvedBy,
        'reviewedAt': Timestamp.fromDate(now),
      });
    });
  }

  /// Collect Loan Repayment installment with interest/principal calculation and cashbook entry
  Future<void> recordLoanRepayment(
    String somitiId, {
    required String loanId,
    required double amountPaid,
    required String accountId,
    required String accountName,
    required String collectedBy,
    String note = '',
  }) async {
    if (amountPaid <= 0) throw Exception('কিস্তির পরিমাণ শূন্যের বেশি হতে হবে');

    final loanDocRef = _loansRef(somitiId).doc(loanId);
    final accDocRef = _accountsRef(somitiId).doc(accountId);
    final txDocRef = _transactionsRef(somitiId).doc();
    final now = DateTime.now();

    final voucherNo = 'LN-PAY-${now.year}${now.month.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch.toString().substring(8)}';

    await _firestore.runTransaction((transaction) async {
      final loanSnap = await transaction.get(loanDocRef);
      if (!loanSnap.exists) throw Exception('ঋণ রেকর্ড পাওয়া যায়নি');

      final accSnap = await transaction.get(accDocRef);
      if (!accSnap.exists) throw Exception('তহবিল হিসাব পাওয়া যায়নি');

      final loan = LoanModel.fromSnapshot(loanSnap);
      final newTotalPaid = loan.totalPaid + amountPaid;
      final newOutstanding = (loan.totalPayable - newTotalPaid) > 0 ? (loan.totalPayable - newTotalPaid) : 0.0;
      final isSettled = newOutstanding <= 0.01;

      // Update installment schedule
      double remainingPayment = amountPaid;
      List<Map<String, dynamic>> updatedSchedule = [];

      for (var inst in loan.schedule) {
        if (!inst.isPaid && remainingPayment > 0) {
          final dueForThisInst = inst.totalInstallmentAmount - inst.paidAmount;
          if (remainingPayment >= dueForThisInst) {
            remainingPayment -= dueForThisInst;
            updatedSchedule.add(LoanInstallmentModel(
              installmentNo: inst.installmentNo,
              dueDate: inst.dueDate,
              principalPortion: inst.principalPortion,
              interestPortion: inst.interestPortion,
              totalInstallmentAmount: inst.totalInstallmentAmount,
              paidAmount: inst.totalInstallmentAmount,
              penaltyAmount: inst.penaltyAmount,
              isPaid: true,
              paidDate: now,
            ).toMap());
          } else {
            final partialPaid = inst.paidAmount + remainingPayment;
            remainingPayment = 0;
            updatedSchedule.add(LoanInstallmentModel(
              installmentNo: inst.installmentNo,
              dueDate: inst.dueDate,
              principalPortion: inst.principalPortion,
              interestPortion: inst.interestPortion,
              totalInstallmentAmount: inst.totalInstallmentAmount,
              paidAmount: partialPaid,
              penaltyAmount: inst.penaltyAmount,
              isPaid: false,
              paidDate: now,
            ).toMap());
          }
        } else {
          updatedSchedule.add(inst.toMap());
        }
      }

      // 1. Update Loan Document
      transaction.update(loanDocRef, {
        'totalPaid': newTotalPaid,
        'outstandingBalance': newOutstanding,
        'status': isSettled ? LoanStatus.settled.name : loan.status.name,
        'schedule': updatedSchedule,
      });

      // 2. Add cash to account
      final currentAccBal = (accSnap.data()?['currentBalance'] as num?)?.toDouble() ?? 0.0;
      transaction.update(accDocRef, {'currentBalance': currentAccBal + amountPaid});

      // 3. Record transaction in Cashbook Ledger
      transaction.set(txDocRef, {
        'voucherNo': voucherNo,
        'type': FinancialTransactionType.loanRepayment.name,
        'amount': amountPaid,
        'fromAccountId': accountId,
        'fromAccountName': accountName,
        'category': 'ঋণ কিস্তি আদায়',
        'description': '${loan.memberName}-এর ঋণের কিস্তি আদায় (ভাউচার: $voucherNo)',
        'referenceNo': loanId,
        'recordedBy': collectedBy,
        'date': Timestamp.fromDate(now),
      });
    });
  }
}
