import 'package:cloud_firestore/cloud_firestore.dart';

class SomitiModel {
  final String id;
  final String name;
  final String englishName;
  final String regNo;
  final String padHeader;
  final String address;
  final String bankAccount;
  final String bkashNumber;
  final String presidentName;
  final String secretaryName;
  final String cashierName;
  final String logoEmoji;
  final String notice;
  final String sealPos;
  final String sealAlign;
  final String sealOrder;
  final String creatorId;
  final String creatorEmail;
  final String somitiCode;
  final List<String> assignedMemberEmails;
  final DateTime createdAt;

  SomitiModel({
    required this.id,
    required this.name,
    this.englishName = 'SWAPNA CHOWYA COOPERATIVE SOCIETY LTD.',
    this.regNo = 'সমবায় রেজিঃ নং-৭৮৯০/২০২৬',
    required this.padHeader,
    required this.address,
    required this.bankAccount,
    required this.bkashNumber,
    required this.presidentName,
    required this.secretaryName,
    required this.cashierName,
    this.logoEmoji = '🏛️',
    this.notice = '',
    this.sealPos = 'bottom',
    this.sealAlign = 'between',
    this.sealOrder = 'sign-seal',
    required this.creatorId,
    required this.creatorEmail,
    required this.somitiCode,
    this.assignedMemberEmails = const [],
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'englishName': englishName,
      'regNo': regNo,
      'padHeader': padHeader,
      'address': address,
      'bankAccount': bankAccount,
      'bkashNumber': bkashNumber,
      'presidentName': presidentName,
      'secretaryName': secretaryName,
      'cashierName': cashierName,
      'logoEmoji': logoEmoji,
      'notice': notice,
      'sealPos': sealPos,
      'sealAlign': sealAlign,
      'sealOrder': sealOrder,
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
      englishName: data['englishName'] ?? 'SWAPNA CHOWYA COOPERATIVE SOCIETY LTD.',
      regNo: data['regNo'] ?? 'সমবায় রেজিঃ নং-৭৮৯০/২০২৬',
      padHeader: data['padHeader'] ?? '',
      address: data['address'] ?? '',
      bankAccount: data['bankAccount'] ?? '',
      bkashNumber: data['bkashNumber'] ?? '',
      presidentName: data['presidentName'] ?? '',
      secretaryName: data['secretaryName'] ?? '',
      cashierName: data['cashierName'] ?? '',
      logoEmoji: data['logoEmoji'] ?? '🏛️',
      notice: data['notice'] ?? '',
      sealPos: data['sealPos'] ?? 'bottom',
      sealAlign: data['sealAlign'] ?? 'between',
      sealOrder: data['sealOrder'] ?? 'sign-seal',
      creatorId: data['creatorId'] ?? '',
      creatorEmail: data['creatorEmail'] ?? '',
      somitiCode: data['somitiCode'] ?? '',
      assignedMemberEmails: assignedEmails,
      createdAt: date,
    );
  }
}

