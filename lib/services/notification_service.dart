import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static final AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('notification'),
    enableVibration: true,
    vibrationPattern: Int64List.fromList([0, 500, 500, 500]),
  );

  static Future<void> initialize() async {
    try {
      const AndroidInitializationSettings androidInitializationSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosInitializationSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings = InitializationSettings(
        android: androidInitializationSettings,
        iOS: iosInitializationSettings,
      );

      await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
        onDidReceiveBackgroundNotificationResponse: _onDidReceiveBackgroundNotificationResponse,
      );

      // Create notification channel for Android 8.0+
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);

      print('✅ Local notifications initialized successfully');

    } catch (e) {
      print('❌ Error initializing local notifications: $e');
    }
  }

  /// Handle notification tap when app is in foreground
  static void _onDidReceiveNotificationResponse(NotificationResponse response) {
    print('🟢 Notification tapped: ${response.payload}');
    _handleNotificationTap(response.payload);
  }

  /// Handle notification tap when app is in background
  static void _onDidReceiveBackgroundNotificationResponse(NotificationResponse response) {
    print('🟠 Background notification tapped: ${response.payload}');
    _handleNotificationTap(response.payload);
  }

  /// Handle iOS local notification
  static void _onDidReceiveLocalNotification(int id, String? title, String? body, String? payload) {
    print('📱 iOS Local notification: $title - $body');
    _handleNotificationTap(payload);
  }

  /// Show local notification
  static Future<void> showNotification({
    required String title,
    required String body,
    required String payload,
    int id = 0,
  }) async {
    try {
      AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        channelDescription: 'This channel is used for important notifications.',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 500, 500, 500]),
        ticker: 'ticker',
        styleInformation: DefaultStyleInformation(true, true),
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
      );

      NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(
        id,
        title,
        body,
        details,
        payload: payload,
      );

      print('📤 Notification shown: $title');
    } catch (e) {
      print('❌ Error showing notification: $e');
    }
  }

  /// Handle notification tap navigation
  static void _handleNotificationTap(String? payload) {
    if (payload != null) {
      print('🎯 Handling notification tap with payload: $payload');
      // You can add navigation logic here
      // For example, use a global navigator key to navigate
    }
  }

  static AndroidNotificationChannel get channel => _channel;
}