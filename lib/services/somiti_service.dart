import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/somiti_model.dart';
import '../models/member_model.dart';
import '../models/deposit_model.dart';
import '../models/expense_model.dart';

class SomitiService {
  static final SomitiService _instance = SomitiService._internal();
  factory SomitiService() => _instance;
  SomitiService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _somitisCol() {
    return _firestore.collection('somitis');
  }

  // User's linked Somitis (whether as creator or joined member)
  Stream<List<SomitiModel>> getUserSomitisStream(String userEmail, String userId) {
    return _somitisCol()
        .where('creatorId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => SomitiModel.fromSnapshot(doc)).toList());
  }

  Future<SomitiModel> createSomiti({
    required String name,
    required String padHeader,
    required String address,
    required String bankAccount,
    required String bkashNumber,
    required String presidentName,
    required String secretaryName,
    required String cashierName,
    required String creatorId,
    required String creatorEmail,
  }) async {
    final randomNum = (1000 + Random().nextInt(9000)).toString();
    final somitiCode = 'SMT-$randomNum';

    final docRef = _somitisCol().doc();
    final somiti = SomitiModel(
      id: docRef.id,
      name: name,
      padHeader: padHeader,
      address: address,
      bankAccount: bankAccount,
      bkashNumber: bkashNumber,
      presidentName: presidentName,
      secretaryName: secretaryName,
      cashierName: cashierName.isEmpty ? 'কোষাধ্যক্ষ (এডমিন)' : cashierName,
      creatorId: creatorId,
      creatorEmail: creatorEmail,
      somitiCode: somitiCode,
      createdAt: DateTime.now(),
    );

    await docRef.set(somiti.toMap());
    return somiti;
  }

  Future<SomitiModel> joinSomitiByCode({
    required String somitiCode,
    required String userId,
    required String userEmail,
  }) async {
    final query = await _somitisCol()
        .where('somitiCode', isEqualTo: somitiCode.trim().toUpperCase())
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw Exception('সমিতির কোডটি সঠিক নয়! দয়া করে সঠিক কোড দিন।');
    }

    final somitiDoc = query.docs.first;
    return SomitiModel.fromSnapshot(somitiDoc);
  }

  // Sub-collections per Somiti
  CollectionReference<Map<String, dynamic>> _membersCol(String somitiId) {
    return _somitisCol().doc(somitiId).collection('members');
  }

  CollectionReference<Map<String, dynamic>> _depositsCol(String somitiId) {
    return _somitisCol().doc(somitiId).collection('deposits');
  }

  Stream<List<MemberModel>> getMembersStream(String somitiId) {
    return _membersCol(somitiId)
        .orderBy('memberNumber')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => MemberModel.fromSnapshot(doc)).toList());
  }

  Stream<List<DepositModel>> getDepositsStream(String somitiId) {
    return _depositsCol(somitiId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => DepositModel.fromSnapshot(doc)).toList());
  }

  Stream<List<DepositModel>> getMemberDepositsStream(String somitiId, String memberNumber) {
    return _depositsCol(somitiId)
        .where('memberNumber', isEqualTo: memberNumber)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => DepositModel.fromSnapshot(doc)).toList());
  }

  Future<void> addMember({
    required String somitiId,
    required String name,
    required String phone,
    required String memberNumber,
  }) async {
    final docRef = _membersCol(somitiId).doc();
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

  Future<void> registerMemberApplication({
    required String name,
    required String phone,
    required String email,
    required String userId,
    String somitiId = 'main',
  }) async {
    final membersSnapshot = await _membersCol(somitiId).get();
    final count = membersSnapshot.docs.length + 1;
    final memberNumber = count < 10 ? '0$count' : '$count';

    final member = MemberModel(
      id: userId,
      name: name,
      phone: phone,
      memberNumber: memberNumber,
      totalDeposit: 0.0,
      createdAt: DateTime.now(),
    );
    await _membersCol(somitiId).doc(userId).set(member.toMap());
  }

  Future<void> deleteMember(String somitiId, String memberId) async {

    await _membersCol(somitiId).doc(memberId).delete();
  }

  Future<void> addDeposit({
    required String somitiId,
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
    final depositRef = _depositsCol(somitiId).doc();

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

    final memberRef = _membersCol(somitiId).doc(memberId);
    batch.update(memberRef, {
      'totalDeposit': FieldValue.increment(amount),
    });

    await batch.commit();
  }

  Future<void> deleteDeposit({
    required String somitiId,
    required DepositModel deposit,
  }) async {
    final batch = _firestore.batch();
    final depositRef = _depositsCol(somitiId).doc(deposit.id);
    batch.delete(depositRef);

    final memberRef = _membersCol(somitiId).doc(deposit.memberId);
    batch.update(memberRef, {
      'totalDeposit': FieldValue.increment(-deposit.amount),
    });

    await batch.commit();
  }

  // Expense Management (খরচ ও ক্যাশ খাতা)
  CollectionReference<Map<String, dynamic>> _expensesCol(String somitiId) {
    return _somitisCol().doc(somitiId).collection('expenses');
  }

  Stream<List<ExpenseModel>> getExpensesStream(String somitiId) {
    return _expensesCol(somitiId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ExpenseModel.fromSnapshot(doc)).toList());
  }

  Future<void> addExpense({
    required String somitiId,
    required String title,
    required double amount,
    required String category,
    required DateTime date,
    required String note,
    required String recordedBy,
  }) async {
    final docRef = _expensesCol(somitiId).doc();
    final expense = ExpenseModel(
      id: docRef.id,
      title: title,
      amount: amount,
      category: category,
      date: date,
      note: note,
      recordedBy: recordedBy,
    );
    await docRef.set(expense.toMap());
  }

  Future<void> deleteExpense(String somitiId, String expenseId) async {
    await _expensesCol(somitiId).doc(expenseId).delete();
  }
}
