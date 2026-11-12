import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/member_model.dart';
import '../models/deposit_model.dart';
import '../models/user_profile.dart';

class SomitiService {
  static final SomitiService _instance = SomitiService._internal();
  factory SomitiService() => _instance;
  SomitiService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _membersCol(String userId) {
    return _firestore.collection('somiti').doc(userId).collection('members');
  }

  CollectionReference<Map<String, dynamic>> _depositsCol(String userId) {
    return _firestore.collection('somiti').doc(userId).collection('deposits');
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
        role: 'admin',
      );
    });
  }

  Future<UserProfile> ensureUserProfile(User user) async {
    final doc = await _userProfileDoc(user.uid).get();
    if (doc.exists && doc.data() != null) {
      return UserProfile.fromMap(doc.data()!, user.uid);
    }

    final newProfile = UserProfile(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? 'ইউজার',
      role: 'admin', // ডিফল্টভাবে প্রথম ব্যবহারকারী এডমিন
    );

    await _userProfileDoc(user.uid).set(newProfile.toMap());
    return newProfile;
  }

  Future<void> switchRole(String userId, String newRole, {String? linkedMemberId}) async {
    await _userProfileDoc(userId).update({
      'role': newRole,
      if (linkedMemberId != null) 'linkedMemberId': linkedMemberId,
    });
  }

  Stream<List<MemberModel>> getMembersStream(String userId) {
    return _membersCol(userId)
        .orderBy('memberNumber')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => MemberModel.fromSnapshot(doc)).toList());
  }

  Stream<List<DepositModel>> getDepositsStream(String userId) {
    return _depositsCol(userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => DepositModel.fromSnapshot(doc)).toList());
  }

  Stream<List<DepositModel>> getMemberDepositsStream(String userId, String memberId) {
    return _depositsCol(userId)
        .where('memberId', isEqualTo: memberId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => DepositModel.fromSnapshot(doc)).toList());
  }

  Future<void> addMember({
    required String userId,
    required String name,
    required String phone,
    required String memberNumber,
  }) async {
    final docRef = _membersCol(userId).doc();
    final member = MemberModel(
      id: docRef.id,
      name: name,
      phone: phone,
      memberNumber: memberNumber,
      totalDeposit: 0.0,
      createdAt: DateTime.now(),
    );
    await docRef.set(member.toMap());
  }

  Future<void> deleteMember(String userId, String memberId) async {
    await _membersCol(userId).doc(memberId).delete();
  }

  Future<void> addDeposit({
    required String userId,
    required String memberId,
    required String memberName,
    required String memberNumber,
    required double amount,
    required String type,
    required DateTime date,
    required String note,
    required String deviceSource,
  }) async {
    final batch = _firestore.batch();
    final depositRef = _depositsCol(userId).doc();

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

    final memberRef = _membersCol(userId).doc(memberId);
    batch.update(memberRef, {
      'totalDeposit': FieldValue.increment(amount),
    });

    await batch.commit();
  }

  Future<void> deleteDeposit({
    required String userId,
    required DepositModel deposit,
  }) async {
    final batch = _firestore.batch();
    final depositRef = _depositsCol(userId).doc(deposit.id);
    batch.delete(depositRef);

    final memberRef = _membersCol(userId).doc(deposit.memberId);
    batch.update(memberRef, {
      'totalDeposit': FieldValue.increment(-deposit.amount),
    });

    await batch.commit();
  }
}
