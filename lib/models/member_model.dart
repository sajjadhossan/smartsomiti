import 'package:cloud_firestore/cloud_firestore.dart';

class MemberModel {
  final String id;
  final String name;
  final String phone;
  final String memberNumber;
  final double totalDeposit;
  final DateTime createdAt;

  MemberModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.memberNumber,
    this.totalDeposit = 0.0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'memberNumber': memberNumber,
      'totalDeposit': totalDeposit,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory MemberModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final timestamp = data['createdAt'];
    DateTime date;
    if (timestamp is Timestamp) {
      date = timestamp.toDate();
    } else {
      date = DateTime.now();
    }

    return MemberModel(
      id: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      memberNumber: data['memberNumber'] ?? '',
      totalDeposit: (data['totalDeposit'] as num?)?.toDouble() ?? 0.0,
      createdAt: date,
    );
  }

  MemberModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? memberNumber,
    double? totalDeposit,
    DateTime? createdAt,
  }) {
    return MemberModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      memberNumber: memberNumber ?? this.memberNumber,
      totalDeposit: totalDeposit ?? this.totalDeposit,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
