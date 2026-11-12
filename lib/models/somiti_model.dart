import 'package:cloud_firestore/cloud_firestore.dart';

class SomitiModel {
  final String id;
  final String name;
  final String padHeader;
  final String address;
  final String bankAccount;
  final String bkashNumber;
  final String presidentName;
  final String secretaryName;
  final String cashierName;
  final String creatorId;
  final String creatorEmail;
  final String somitiCode;
  final List<String> assignedMemberEmails;
  final DateTime createdAt;

  SomitiModel({
    required this.id,
    required this.name,
    required this.padHeader,
    required this.address,
    required this.bankAccount,
    required this.bkashNumber,
    required this.presidentName,
    required this.secretaryName,
    required this.cashierName,
    required this.creatorId,
    required this.creatorEmail,
    required this.somitiCode,
    this.assignedMemberEmails = const [],
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'padHeader': padHeader,
      'address': address,
      'bankAccount': bankAccount,
      'bkashNumber': bkashNumber,
      'presidentName': presidentName,
      'secretaryName': secretaryName,
      'cashierName': cashierName,
      'creatorId': creatorId,
      'creatorEmail': creatorEmail,
      'somitiCode': somitiCode,
      'assignedMemberEmails': assignedMemberEmails,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory SomitiModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final timestamp = data['createdAt'];
    DateTime date;
    if (timestamp is Timestamp) {
      date = timestamp.toDate();
    } else {
      date = DateTime.now();
    }

    final rawEmails = data['assignedMemberEmails'];
    List<String> assignedEmails = [];
    if (rawEmails is List) {
      assignedEmails = rawEmails.map((e) => e.toString().toLowerCase()).toList();
    }

    return SomitiModel(
      id: doc.id,
      name: data['name'] ?? '',
      padHeader: data['padHeader'] ?? '',
      address: data['address'] ?? '',
      bankAccount: data['bankAccount'] ?? '',
      bkashNumber: data['bkashNumber'] ?? '',
      presidentName: data['presidentName'] ?? '',
      secretaryName: data['secretaryName'] ?? '',
      cashierName: data['cashierName'] ?? '',
      creatorId: data['creatorId'] ?? '',
      creatorEmail: data['creatorEmail'] ?? '',
      somitiCode: data['somitiCode'] ?? '',
      assignedMemberEmails: assignedEmails,
      createdAt: date,
    );
  }
}

