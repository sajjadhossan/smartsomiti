import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

enum LoanInterestType {
  flat,      // সরল সুদ (Flat Rate)
  reducing,  // হ্রাসমান ব্যালেন্স সুদ (Reducing Balance / EMI)
}

enum LoanStatus {
  pending,    // অনুমোদন অপেক্ষমাণ
  approved,   // অনুমোদিত
  rejected,   // বাতিল
  disbursed,  // বিতরণকৃত ও চলমান
  settled,    // সম্পূর্ণ পরিশোধিত
  defaulted,  // মেয়াদোত্তীর্ণ ও খেলাপি
}

/// Individual Loan Installment breakdown
class LoanInstallmentModel {
  final int installmentNo;
  final DateTime dueDate;
  final double principalPortion;
  final double interestPortion;
  final double totalInstallmentAmount;
  final double paidAmount;
  final double penaltyAmount;
  final bool isPaid;
  final DateTime? paidDate;

  LoanInstallmentModel({
    required this.installmentNo,
    required this.dueDate,
    required this.principalPortion,
    required this.interestPortion,
    required this.totalInstallmentAmount,
    this.paidAmount = 0.0,
    this.penaltyAmount = 0.0,
    this.isPaid = false,
    this.paidDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'installmentNo': installmentNo,
      'dueDate': Timestamp.fromDate(dueDate),
      'principalPortion': principalPortion,
      'interestPortion': interestPortion,
      'totalInstallmentAmount': totalInstallmentAmount,
      'paidAmount': paidAmount,
      'penaltyAmount': penaltyAmount,
      'isPaid': isPaid,
      'paidDate': paidDate != null ? Timestamp.fromDate(paidDate!) : null,
    };
  }

  factory LoanInstallmentModel.fromMap(Map<String, dynamic> map) {
    DateTime due = DateTime.now();
    final tsDue = map['dueDate'];
    if (tsDue is Timestamp) due = tsDue.toDate();

    DateTime? paid;
    final tsPaid = map['paidDate'];
    if (tsPaid is Timestamp) paid = tsPaid.toDate();

    return LoanInstallmentModel(
      installmentNo: map['installmentNo'] ?? 1,
      dueDate: due,
      principalPortion: (map['principalPortion'] as num?)?.toDouble() ?? 0.0,
      interestPortion: (map['interestPortion'] as num?)?.toDouble() ?? 0.0,
      totalInstallmentAmount: (map['totalInstallmentAmount'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (map['paidAmount'] as num?)?.toDouble() ?? 0.0,
      penaltyAmount: (map['penaltyAmount'] as num?)?.toDouble() ?? 0.0,
      isPaid: map['isPaid'] == true,
      paidDate: paid,
    );
  }
}

/// Master Loan Document
class LoanModel {
  final String id;
  final String memberId;
  final String memberName;
  final String memberNumber;
  final double principalAmount;     // মূল ঋণের পরিমাণ
  final double interestRatePercent; // বার্ষিক সুদের শতকরা হার (%)
  final LoanInterestType interestType;
  final int durationMonths;         // মেয়াদের মাস সংখ্যা
  final double totalInterest;       // মোট প্রদেয় সুদ
  final double totalPayable;        // মোট পরিশোধযোগ্য (আসল + সুদ)
  final double totalPaid;           // মোট পরিশোধিত টাকা
  final double outstandingBalance;  // বর্তমান অবশিষ্ট ঋণ
  final LoanStatus status;
  final DateTime disbursementDate;  // ঋণ বিতরণের তারিখ
  final String approvedBy;
  final String guarantorName;
  final String guarantorPhone;
  final List<LoanInstallmentModel> schedule;

  LoanModel({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.memberNumber,
    required this.principalAmount,
    required this.interestRatePercent,
    required this.interestType,
    required this.durationMonths,
    required this.totalInterest,
    required this.totalPayable,
    this.totalPaid = 0.0,
    required this.outstandingBalance,
    this.status = LoanStatus.disbursed,
    required this.disbursementDate,
    required this.approvedBy,
    this.guarantorName = '',
    this.guarantorPhone = '',
    this.schedule = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'memberId': memberId,
      'memberName': memberName,
      'memberNumber': memberNumber,
      'principalAmount': principalAmount,
      'interestRatePercent': interestRatePercent,
      'interestType': interestType.name,
      'durationMonths': durationMonths,
      'totalInterest': totalInterest,
      'totalPayable': totalPayable,
      'totalPaid': totalPaid,
      'outstandingBalance': outstandingBalance,
      'status': status.name,
      'disbursementDate': Timestamp.fromDate(disbursementDate),
      'approvedBy': approvedBy,
      'guarantorName': guarantorName,
      'guarantorPhone': guarantorPhone,
      'schedule': schedule.map((inst) => inst.toMap()).toList(),
    };
  }

  factory LoanModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    LoanInterestType iType = LoanInterestType.flat;
    if (data['interestType'] == 'reducing') iType = LoanInterestType.reducing;

    LoanStatus st = LoanStatus.disbursed;
    try {
      st = LoanStatus.values.byName(data['status'] ?? 'disbursed');
    } catch (_) {}

    DateTime disbDate = DateTime.now();
    final tsDisb = data['disbursementDate'];
    if (tsDisb is Timestamp) disbDate = tsDisb.toDate();

    final rawSchedule = data['schedule'] as List<dynamic>? ?? [];
    final scheduleList = rawSchedule
        .map((item) => LoanInstallmentModel.fromMap(Map<String, dynamic>.from(item)))
        .toList();

    return LoanModel(
      id: doc.id,
      memberId: data['memberId'] ?? '',
      memberName: data['memberName'] ?? '',
      memberNumber: data['memberNumber'] ?? '',
      principalAmount: (data['principalAmount'] as num?)?.toDouble() ?? 0.0,
      interestRatePercent: (data['interestRatePercent'] as num?)?.toDouble() ?? 0.0,
      interestType: iType,
      durationMonths: (data['durationMonths'] as num?)?.toInt() ?? 12,
      totalInterest: (data['totalInterest'] as num?)?.toDouble() ?? 0.0,
      totalPayable: (data['totalPayable'] as num?)?.toDouble() ?? 0.0,
      totalPaid: (data['totalPaid'] as num?)?.toDouble() ?? 0.0,
      outstandingBalance: (data['outstandingBalance'] as num?)?.toDouble() ?? 0.0,
      status: st,
      disbursementDate: disbDate,
      approvedBy: data['approvedBy'] ?? '',
      guarantorName: data['guarantorName'] ?? '',
      guarantorPhone: data['guarantorPhone'] ?? '',
      schedule: scheduleList,
    );
  }

  /// Financial Calculation Engine: Generates an exact repayment amortization schedule
  static List<LoanInstallmentModel> generateSchedule({
    required double principal,
    required double annualRatePercent,
    required int months,
    required LoanInterestType interestType,
    required DateTime startDate,
  }) {
    List<LoanInstallmentModel> list = [];
    if (months <= 0 || principal <= 0) return list;

    if (interestType == LoanInterestType.flat) {
      // 1. Flat Rate: Total Interest = Principal * (Rate/100) * (Months/12)
      final totalInterest = principal * (annualRatePercent / 100.0) * (months / 12.0);
      final monthlyPrincipal = principal / months;
      final monthlyInterest = totalInterest / months;
      final monthlyTotal = monthlyPrincipal + monthlyInterest;

      for (int i = 1; i <= months; i++) {
        // Month step forward
        final dueDate = DateTime(startDate.year, startDate.month + i, startDate.day);
        list.add(LoanInstallmentModel(
          installmentNo: i,
          dueDate: dueDate,
          principalPortion: double.parse(monthlyPrincipal.toStringAsFixed(2)),
          interestPortion: double.parse(monthlyInterest.toStringAsFixed(2)),
          totalInstallmentAmount: double.parse(monthlyTotal.toStringAsFixed(2)),
        ));
      }
    } else {
      // 2. Reducing Balance (Equated Monthly Installment - EMI)
      // EMI = [P * r * (1 + r)^n] / [(1 + r)^n - 1] where r = monthly rate
      final monthlyRate = (annualRatePercent / 100.0) / 12.0;

      double emi;
      if (monthlyRate == 0) {
        emi = principal / months;
      } else {
        final factor = pow(1.0 + monthlyRate, months);
        emi = (principal * monthlyRate * factor) / (factor - 1.0);
      }

      double remainingPrincipal = principal;

      for (int i = 1; i <= months; i++) {
        final interestForMonth = remainingPrincipal * monthlyRate;
        double principalForMonth = emi - interestForMonth;

        if (i == months) {
          // Adjust round-off difference on the final installment
          principalForMonth = remainingPrincipal;
          emi = principalForMonth + interestForMonth;
        }

        remainingPrincipal -= principalForMonth;
        if (remainingPrincipal < 0) remainingPrincipal = 0.0;

        final dueDate = DateTime(startDate.year, startDate.month + i, startDate.day);
        list.add(LoanInstallmentModel(
          installmentNo: i,
          dueDate: dueDate,
          principalPortion: double.parse(principalForMonth.toStringAsFixed(2)),
          interestPortion: double.parse(interestForMonth.toStringAsFixed(2)),
          totalInstallmentAmount: double.parse(emi.toStringAsFixed(2)),
        ));
      }
    }

    return list;
  }
}

/// Loan Application Model submitted by members or field officers
class LoanApplicationModel {
  final String id;
  final String memberId;
  final String memberName;
  final String memberNumber;
  final String memberPhone;
  final double requestedAmount;
  final int durationMonths;
  final LoanInterestType interestType;
  final double proposedInterestRate;
  final String purpose;
  final String guarantorName;
  final String guarantorPhone;
  final String guarantorRelation;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime appliedAt;
  final String appliedBy;
  final String? reviewNote;
  final String? reviewedBy;
  final DateTime? reviewedAt;

  LoanApplicationModel({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.memberNumber,
    this.memberPhone = '',
    required this.requestedAmount,
    required this.durationMonths,
    this.interestType = LoanInterestType.flat,
    this.proposedInterestRate = 10.0,
    required this.purpose,
    this.guarantorName = '',
    this.guarantorPhone = '',
    this.guarantorRelation = '',
    this.status = 'pending',
    required this.appliedAt,
    required this.appliedBy,
    this.reviewNote,
    this.reviewedBy,
    this.reviewedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'memberId': memberId,
      'memberName': memberName,
      'memberNumber': memberNumber,
      'memberPhone': memberPhone,
      'requestedAmount': requestedAmount,
      'durationMonths': durationMonths,
      'interestType': interestType.name,
      'proposedInterestRate': proposedInterestRate,
      'purpose': purpose,
      'guarantorName': guarantorName,
      'guarantorPhone': guarantorPhone,
      'guarantorRelation': guarantorRelation,
      'status': status,
      'appliedAt': Timestamp.fromDate(appliedAt),
      'appliedBy': appliedBy,
      'reviewNote': reviewNote,
      'reviewedBy': reviewedBy,
      'reviewedAt': reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
    };
  }

  factory LoanApplicationModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    LoanInterestType it = LoanInterestType.flat;
    if (data['interestType'] == 'reducing') it = LoanInterestType.reducing;

    DateTime appAt = DateTime.now();
    final tsApp = data['appliedAt'];
    if (tsApp is Timestamp) appAt = tsApp.toDate();

    DateTime? revAt;
    final tsRev = data['reviewedAt'];
    if (tsRev is Timestamp) revAt = tsRev.toDate();

    return LoanApplicationModel(
      id: doc.id,
      memberId: data['memberId'] ?? '',
      memberName: data['memberName'] ?? '',
      memberNumber: data['memberNumber'] ?? '',
      memberPhone: data['memberPhone'] ?? '',
      requestedAmount: (data['requestedAmount'] as num?)?.toDouble() ?? 0.0,
      durationMonths: (data['durationMonths'] as num?)?.toInt() ?? 12,
      interestType: it,
      proposedInterestRate: (data['proposedInterestRate'] as num?)?.toDouble() ?? 10.0,
      purpose: data['purpose'] ?? '',
      guarantorName: data['guarantorName'] ?? '',
      guarantorPhone: data['guarantorPhone'] ?? '',
      guarantorRelation: data['guarantorRelation'] ?? '',
      status: data['status'] ?? 'pending',
      appliedAt: appAt,
      appliedBy: data['appliedBy'] ?? '',
      reviewNote: data['reviewNote'],
      reviewedBy: data['reviewedBy'],
      reviewedAt: revAt,
    );
  }
}

/// Calculation engine adapter for financial schedule generation
class LoanCalculationEngine {
  static List<LoanInstallmentModel> generateSchedule({
    required double principal,
    required double annualRatePercent,
    required int months,
    required LoanInterestType type,
    required DateTime startDate,
  }) {
    return LoanModel.generateSchedule(
      principal: principal,
      annualRatePercent: annualRatePercent,
      months: months,
      interestType: type,
      startDate: startDate,
    );
  }
}
