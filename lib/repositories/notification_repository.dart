import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';

class NotificationRepository {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _userId {
    final user = _auth.currentUser;
    if (user == null) throw Exception("No authenticated user found.");
    return user.uid;
  }

  Future<void> createNotification(Notifications notification) async {
    final userId = _userId;
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notification.notificationId)
        .set(notification.toMap());
  }

  Future<List<Notifications>> getUserNotifications() async {
    final userId = _userId;
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) => Notifications.fromMap(doc.data())).toList();
  }

  Future<void> updateNotification(Notifications notification) async {
    final userId = _userId;
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notification.notificationId)
        .update(notification.toMap());
  }

  Future<void> deleteNotification(String notificationId) async {
    final userId = _userId;
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }

  Future<void> markAsRead(String notificationId) async {
    final userId = _userId;
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .update({'status': 'Read'});
  }

  Future<void> markAsUnread(String notificationId) async {
    final userId = _userId;
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .update({'status': 'Unread'});
  }

  Future<void> markAllAsRead() async {
    final userId = _userId;
    final batch = _firestore.batch();

    final query = await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('status', isEqualTo: 'Unread')
        .get();

    for (final doc in query.docs) {
      batch.update(doc.reference, {'status': 'Read'});
    }

    await batch.commit();
  }

  Future<void> deleteAllNotifications() async {
    final userId = _userId;
    final batch = _firestore.batch();

    final query = await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .get();

    for (final doc in query.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  Stream<List<Notifications>> streamUserNotifications() {
    final userId = _userId;
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Notifications.fromMap(doc.data())).toList());
  }
}