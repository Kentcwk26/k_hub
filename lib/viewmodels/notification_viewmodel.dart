import 'package:flutter/material.dart';
import '../models/user.dart';
import '../repositories/notification_repository.dart';

class NotificationViewModel extends ChangeNotifier {
  final NotificationRepository _repository = NotificationRepository();
  List<Notifications> notifications = [];

  Future<void> loadNotifications() async {
    notifications = await _repository.getUserNotifications();
    notifyListeners();
  }

  Future<void> addNotification(Notifications notification) async {
    await _repository.createNotification(notification);
    notifications.insert(0, notification);
    notifyListeners();
  }

  Future<void> markAsRead(String id) async {
    await _repository.markAsRead(id);

    final index = notifications.indexWhere((n) => n.notificationId == id);
    if (index != -1) {
      final n = notifications[index];
      notifications[index] = Notifications(
        notificationId: n.notificationId,
        userId: n.userId,
        title: n.title,
        message: n.message,
        dateformat: n.dateformat,
        iconKey: 'message',  
        status: "Read",
      );
    }

    notifyListeners();
  }

  Future<void> markAsUnread(String id) async {
    await _repository.markAsUnread(id);

    final index = notifications.indexWhere((n) => n.notificationId == id);
    if (index != -1) {
      final n = notifications[index];
      notifications[index] = Notifications(
        notificationId: n.notificationId,
        userId: n.userId,
        title: n.title,
        message: n.message,
        dateformat: n.dateformat,
        iconKey: 'notification',
        status: "Unread",
      );
    }

    notifyListeners();
  }

  Future<void> markAllAsRead() async {
    await _repository.markAllAsRead();

    notifications = notifications.map((n) {
      return Notifications(
        notificationId: n.notificationId,
        userId: n.userId,
        title: n.title,
        message: n.message,
        dateformat: n.dateformat,
        iconKey: 'message',
        status: "Read",
      );
    }).toList();

    notifyListeners();
  }

  Future<void> deleteNotification(String id) async {
    await _repository.deleteNotification(id);
    notifications.removeWhere((n) => n.notificationId == id);
    notifyListeners();
  }

  Future<void> deleteAll() async {
    await _repository.deleteAllNotifications();
    notifications.clear();
    notifyListeners();
  }

  Stream<List<Notifications>> streamNotifications() {
    return _repository.streamUserNotifications();
  }
}
