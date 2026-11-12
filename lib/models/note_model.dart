import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  final String id;
  final String title;
  final String content;
  final String? driveFileId;
  final String? driveWebViewLink;
  final DateTime updatedAt;
  final String deviceSource;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    this.driveFileId,
    this.driveWebViewLink,
    required this.updatedAt,
    required this.deviceSource,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'driveFileId': driveFileId,
      'driveWebViewLink': driveWebViewLink,
      'updatedAt': Timestamp.fromDate(updatedAt),
      'deviceSource': deviceSource,
    };
  }

  factory NoteModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final timestamp = data['updatedAt'];
    DateTime date;
    if (timestamp is Timestamp) {
      date = timestamp.toDate();
    } else {
      date = DateTime.now();
    }

    return NoteModel(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      driveFileId: data['driveFileId'],
      driveWebViewLink: data['driveWebViewLink'],
      updatedAt: date,
      deviceSource: data['deviceSource'] ?? 'Unknown Device',
    );
  }

  NoteModel copyWith({
    String? id,
    String? title,
    String? content,
    String? driveFileId,
    String? driveWebViewLink,
    DateTime? updatedAt,
    String? deviceSource,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      driveFileId: driveFileId ?? this.driveFileId,
      driveWebViewLink: driveWebViewLink ?? this.driveWebViewLink,
      updatedAt: updatedAt ?? this.updatedAt,
      deviceSource: deviceSource ?? this.deviceSource,
    );
  }
}
