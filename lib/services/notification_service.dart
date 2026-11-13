import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  loanReminder,
  depositReceipt,
  expenseAlert,
  announcement,
  systemAlert,
}

class SomitiNotification {
  final String id;
  final String somitiId;
  final String recipientId;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? metadata;

  const SomitiNotification({
    required this.id,
    required this.somitiId,
    required this.recipientId,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.metadata,
  });

  factory SomitiNotification.fromFirestore(Map<String, dynamic> data, String id) {
    NotificationType parseType(String? t) {
      switch (t) {
        case 'loanReminder':
          return NotificationType.loanReminder;
        case 'depositReceipt':
          return NotificationType.depositReceipt;
        case 'expenseAlert':
          return NotificationType.expenseAlert;
        case 'announcement':
          return NotificationType.announcement;
        default:
          return NotificationType.systemAlert;
      }
    }

    return SomitiNotification(
      id: id,
      somitiId: data['somitiId'] as String? ?? '',
      recipientId: data['recipientId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      type: parseType(data['type'] as String?),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] as bool? ?? false,
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'somitiId': somitiId,
      'recipientId': recipientId,
      'title': title,
      'body': body,
      'type': type.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
      'metadata': metadata,
    };
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Register or update FCM device token for real-time push
  Future<void> registerDeviceToken({
    required String userId,
    required String token,
    String? somitiId,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'fcmToken': token,
        'tokenUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (somitiId != null && somitiId.isNotEmpty) {
        await _firestore
            .collection('somitis')
            .doc(somitiId)
            .collection('device_tokens')
            .doc(userId)
            .set({
          'token': token,
          'platform': defaultTargetPlatform.name,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('NotificationService registerDeviceToken error: $e');
    }
  }

  /// Send in-app & push notification record to Firestore
  Future<void> sendNotification({
    required String somitiId,
    required String recipientId,
    required String title,
    required String body,
    required NotificationType type,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final docRef = _firestore
          .collection('somitis')
          .doc(somitiId)
          .collection('notifications')
          .doc();

      final notification = SomitiNotification(
        id: docRef.id,
        somitiId: somitiId,
        recipientId: recipientId,
        title: title,
        body: body,
        type: type,
        createdAt: DateTime.now(),
        metadata: metadata,
      );

      await docRef.set(notification.toFirestore());
    } catch (e) {
      debugPrint('NotificationService sendNotification error: $e');
    }
  }

  /// Broadcast announcement to all society members
  Future<void> broadcastAnnouncement({
    required String somitiId,
    required String title,
    required String body,
  }) async {
    await sendNotification(
      somitiId: somitiId,
      recipientId: 'ALL_MEMBERS',
      title: title,
      body: body,
      type: NotificationType.announcement,
    );
  }

  /// Send loan installment reminder
  Future<void> sendLoanInstallmentReminder({
    required String somitiId,
    required String memberId,
    required String memberName,
    required double installmentAmount,
    required DateTime dueDate,
  }) async {
    await sendNotification(
      somitiId: somitiId,
      recipientId: memberId,
      title: 'ঋণ কিস্তির তাগাদা ($memberName)',
      body: 'আপনার ৳${installmentAmount.toStringAsFixed(0)} টাকার কিস্তি পরিশোধের নির্ধারিত তারিখ: ${dueDate.day}/${dueDate.month}/${dueDate.year}।',
      type: NotificationType.loanReminder,
      metadata: {
        'memberId': memberId,
        'installmentAmount': installmentAmount,
        'dueDate': dueDate.toIso8601String(),
      },
    );
  }

  /// Send deposit receipt notification
  Future<void> sendDepositReceiptNotification({
    required String somitiId,
    required String memberId,
    required double depositAmount,
    required String receiptNumber,
  }) async {
    await sendNotification(
      somitiId: somitiId,
      recipientId: memberId,
      title: 'জমা নিশ্চিতকরণ রসিদ ($receiptNumber)',
      body: 'আপনার সঞ্চয়ী হিসাবে ৳${depositAmount.toStringAsFixed(0)} টাকা সফলভাবে জমা হয়েছে।',
      type: NotificationType.depositReceipt,
      metadata: {
        'memberId': memberId,
        'depositAmount': depositAmount,
        'receiptNumber': receiptNumber,
      },
    );
  }

  /// Real-time stream of notifications for a member / admin
  Stream<List<SomitiNotification>> getNotificationsStream({
    required String somitiId,
    required String userId,
  }) {
    return _firestore
        .collection('somitis')
        .doc(somitiId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SomitiNotification.fromFirestore(doc.data(), doc.id))
          .where((n) => n.recipientId == userId || n.recipientId == 'ALL_MEMBERS')
          .toList();
    });
  }

  /// Mark notification as read
  Future<void> markAsRead({
    required String somitiId,
    required String notificationId,
  }) async {
    try {
      await _firestore
          .collection('somitis')
          .doc(somitiId)
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      debugPrint('NotificationService markAsRead error: $e');
    }
  }
}
