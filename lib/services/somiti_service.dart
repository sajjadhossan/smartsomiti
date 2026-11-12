import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/member_model.dart';
import '../models/deposit_model.dart';

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
