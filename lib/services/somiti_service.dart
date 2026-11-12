import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/member_model.dart';
import '../models/deposit_model.dart';
import '../models/user_profile.dart';
import '../models/access_code_model.dart';

class SomitiService {
  static final SomitiService _instance = SomitiService._internal();
  factory SomitiService() => _instance;
  SomitiService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _membersCol() {
    return _firestore.collection('somiti').doc('main').collection('members');
  }

  CollectionReference<Map<String, dynamic>> _depositsCol() {
    return _firestore.collection('somiti').doc('main').collection('deposits');
  }

  CollectionReference<Map<String, dynamic>> _codesCol() {
    return _firestore.collection('somiti').doc('main').collection('access_codes');
  }

  DocumentReference<Map<String, dynamic>> _userProfileDoc(String userId) {
    return _firestore.collection('somiti_users').doc(userId);
  }

  Stream<UserProfile> getUserProfileStream(String userId) {
    return _userProfileDoc(userId).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return UserProfile.fromMap(snapshot.data()!, userId);
      }
      return UserProfile(
        uid: userId,
        email: '',
        displayName: 'ব্যবহারকারী',
        role: 'pending',
      );
    });
  }

  Future<UserProfile> ensureUserProfile(User user) async {
    final doc = await _userProfileDoc(user.uid).get();
    if (doc.exists && doc.data() != null) {
      return UserProfile.fromMap(doc.data()!, user.uid);
    }

    // Initialize default access codes if not yet present
    await _initDefaultCodes();

    final newProfile = UserProfile(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? 'ইউজার',
      role: 'pending', // কোড দেওয়ার অপেক্ষায় থাকবে
      roleTitle: 'অপেক্ষমান',
    );

    await _userProfileDoc(user.uid).set(newProfile.toMap());
    return newProfile;
  }

  Future<void> _initDefaultCodes() async {
    final defaultCodes = [
      {
        'code': 'ADM-2026',
        'role': 'admin',
        'roleTitle': 'প্রধান এডমিন ও কোষাধ্যক্ষ',
      },
      {
        'code': 'PRE-2026',
        'role': 'president',
        'roleTitle': 'সভাপতি',
      },
      {
        'code': 'SEC-2026',
        'role': 'secretary',
        'roleTitle': 'সাধারণ সম্পাদক',
      },
    ];

    for (final item in defaultCodes) {
      final docRef = _codesCol().doc(item['code']!);
      final exists = (await docRef.get()).exists;
      if (!exists) {
        await docRef.set(item);
      }
    }
  }

  Future<UserProfile> verifyAndApplyCode(User user, String rawCode) async {
    final code = rawCode.trim().toUpperCase();
    if (code.isEmpty) {
      throw Exception('দয়া করে কোডটি প্রবেশ করুন');
    }

    final codeDoc = await _codesCol().doc(code).get();
    if (!codeDoc.exists) {
      throw Exception('ভুল কোড! আপনার অ্যাডমিনের দেওয়া সঠিক সিক্রেট কোড লিখুন।');
    }

    final data = codeDoc.data()!;
    final role = data['role'] ?? 'member';
    final roleTitle = data['roleTitle'] ?? 'সাধারণ সদস্য';
    final memberNumber = data['memberNumber'];

    final updatedProfile = UserProfile(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? 'ব্যবহারকারী',
      role: role,
      roleTitle: roleTitle,
      memberNumber: memberNumber,
      secretCode: code,
    );

    await _userProfileDoc(user.uid).set(updatedProfile.toMap(), SetOptions(merge: true));
    await _codesCol().doc(code).update({'linkedEmail': user.email});

    return updatedProfile;
  }

  Future<void> resetUserRole(String userId) async {
    await _userProfileDoc(userId).update({
      'role': 'pending',
      'roleTitle': 'অপেক্ষমান',
      'secretCode': null,
      'memberNumber': null,
    });
  }

  Stream<List<MemberModel>> getMembersStream() {
    return _membersCol()
        .orderBy('memberNumber')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => MemberModel.fromSnapshot(doc)).toList());
  }

  Stream<List<DepositModel>> getDepositsStream() {
    return _depositsCol()
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => DepositModel.fromSnapshot(doc)).toList());
  }

  Stream<List<DepositModel>> getMemberDepositsStream(String memberNumber) {
    return _depositsCol()
        .where('memberNumber', isEqualTo: memberNumber)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => DepositModel.fromSnapshot(doc)).toList());
  }

  Stream<List<AccessCodeModel>> getAccessCodesStream() {
    return _codesCol()
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => AccessCodeModel.fromSnapshot(doc)).toList());
  }

  Future<void> addMember({
    required String name,
    required String phone,
    required String memberNumber,
  }) async {
    final docRef = _membersCol().doc();
    final member = MemberModel(
      id: docRef.id,
      name: name,
      phone: phone,
      memberNumber: memberNumber,
      totalDeposit: 0.0,
      createdAt: DateTime.now(),
    );
    await docRef.set(member.toMap());

    // Automatically create a member secret code
    final memberCode = 'MEM-$memberNumber';
    await _codesCol().doc(memberCode).set({
      'code': memberCode,
      'role': 'member',
      'roleTitle': 'সাধারণ সদস্য',
      'memberNumber': memberNumber,
      'memberName': name,
    });
  }

  Future<void> deleteMember(String memberId, String memberNumber) async {
    await _membersCol().doc(memberId).delete();
    await _codesCol().doc('MEM-$memberNumber').delete();
  }

  Future<void> addDeposit({
    required String memberId,
    required String memberName,
    required String memberNumber,
    required double amount,
    required String type,
    required DateTime date,
    required String note,
    required String recordedBy,
    required String deviceSource,
  }) async {
    final batch = _firestore.batch();
    final depositRef = _depositsCol().doc();

    final deposit = DepositModel(
      id: depositRef.id,
      memberId: memberId,
      memberName: memberName,
      memberNumber: memberNumber,
      amount: amount,
      type: type,
      date: date,
      note: note,
      deviceSource: deviceSource,
    );

    batch.set(depositRef, deposit.toMap());

    final memberRef = _membersCol().doc(memberId);
    batch.update(memberRef, {
      'totalDeposit': FieldValue.increment(amount),
    });

    await batch.commit();
  }

  Future<void> deleteDeposit(DepositModel deposit) async {
    final batch = _firestore.batch();
    final depositRef = _depositsCol().doc(deposit.id);
    batch.delete(depositRef);

    final memberRef = _membersCol().doc(deposit.memberId);
    batch.update(memberRef, {
      'totalDeposit': FieldValue.increment(-deposit.amount),
    });

    await batch.commit();
  }
}
