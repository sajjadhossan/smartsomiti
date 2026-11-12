import 'package:cloud_firestore/cloud_firestore.dart';

class DepositModel {
  final String id;
  final String memberId;
  final String memberName;
  final String memberNumber;
  final double amount;
  final String type; // দৈনিক, সাপ্তাহিক, মাসিক
  final DateTime date;
  final String note;
  final String deviceSource;

  DepositModel({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.memberNumber,
    required this.amount,
    required this.type,
    required this.date,
    this.note = '',
    required this.deviceSource,
  });

  Map<String, dynamic> toMap() {
    return {
      'memberId': memberId,
      'memberName': memberName,
      'memberNumber': memberNumber,
      'amount': amount,
      'type': type,
      'date': Timestamp.fromDate(date),
      'note': note,
      'deviceSource': deviceSource,
    };
  }

  factory DepositModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final timestamp = data['date'];
    DateTime date;
    if (timestamp is Timestamp) {
      date = timestamp.toDate();
    } else {
      date = DateTime.now();
    }

    return DepositModel(
      id: doc.id,
      memberId: data['memberId'] ?? '',
      memberName: data['memberName'] ?? '',
      memberNumber: data['memberNumber'] ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      type: data['type'] ?? 'মাসিক',
      date: date,
      note: data['note'] ?? '',
      deviceSource: data['deviceSource'] ?? 'Unknown',
    );
  }
}
