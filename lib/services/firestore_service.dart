import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note_model.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userNotesCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('notes');
  }

  Stream<List<NoteModel>> getNotesStream(String userId) {
    return _userNotesCollection(userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => NoteModel.fromSnapshot(doc)).toList();
    });
  }

  Future<void> saveNote(String userId, NoteModel note) async {
    final docRef = note.id.isEmpty
        ? _userNotesCollection(userId).doc()
        : _userNotesCollection(userId).doc(note.id);

    final toSave = note.copyWith(id: docRef.id);
    await docRef.set(toSave.toMap(), SetOptions(merge: true));
  }

  Future<void> deleteNote(String userId, String noteId) async {
    await _userNotesCollection(userId).doc(noteId).delete();
  }
}
