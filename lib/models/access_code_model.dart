import 'package:cloud_firestore/cloud_firestore.dart';

class AccessCodeModel {
  final String code;
  final String role; // 'admin', 'president', 'secretary', 'member'
  final String roleTitle; // 'প্রধান এডমিন ও কোষাধ্যক্ষ', 'সভাপতি', 'সাধারণ সম্পাদক', 'সাধারণ সদস্য'
  final String? memberNumber;
  final String? memberName;
  final String? linkedEmail;

  AccessCodeModel({
    required this.code,
    required this.role,
    required this.roleTitle,
    this.memberNumber,
    this.memberName,
    this.linkedEmail,
  });

  Map<String, dynamic> toMap() {
    return {
      'code': code.toUpperCase().trim(),
      'role': role,
      'roleTitle': roleTitle,
      'memberNumber': memberNumber,
      'memberName': memberName,
      'linkedEmail': linkedEmail,
    };
  }

  factory AccessCodeModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return AccessCodeModel(
      code: doc.id,
      role: data['role'] ?? 'member',
      roleTitle: data['roleTitle'] ?? 'সাধারণ সদস্য',
      memberNumber: data['memberNumber'],
      memberName: data['memberName'],
      linkedEmail: data['linkedEmail'],
    );
  }
}
