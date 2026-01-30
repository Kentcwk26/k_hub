import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app_router.dart';
import 'providers/theme_provider.dart';
import 'screens/adminstrators/adminstrator.dart';
import 'screens/home.dart';
import 'screens/login.dart';
import 'services/deep_link_router.dart';
import 'services/notification_service.dart';
import 'viewmodels/auth_viewmodel.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  print("🔵 Background message received: ${message.messageId}");
  print("🔵 Notification data: ${message.data}");
  print("🔵 Notification title: ${message.notification?.title}");
  print("🔵 Notification body: ${message.notification?.body}");

  await _showNotificationFromMessage(message);
}

Future<void> _showNotificationFromMessage(RemoteMessage message) async {
  final notification = message.notification;
  final data = message.data;

  if (notification != null) {
    await NotificationService.showNotification(
      title: notification.title ?? 'New Message',
      body: notification.body ?? 'You have a new message',
      payload: data.toString(),
    );
  }
}

Future<void> _setupFCM() async {
  try {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );

    print('📱 Notification permission: ${settings.authorizationStatus}');

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("🟢 FOREGROUND MESSAGE RECEIVED");
      print("🟢 Message ID: ${message.messageId}");
      print("🟢 Data: ${message.data}");
      print("🟢 Notification: ${message.notification?.title} - ${message.notification?.body}");

      await _showNotificationFromMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("🟠 APP OPENED FROM NOTIFICATION");
      print("🟠 Data: ${message.data}");
      _handleNotificationNavigation(message);
    });

    RemoteMessage? initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      print("🔴 INITIAL MESSAGE FOUND");
      print("🔴 Data: ${initialMessage.data}");
      _handleNotificationNavigation(initialMessage);
    }

    String? token = await messaging.getToken();
    print("🎫 FCM TOKEN: $token");

    messaging.onTokenRefresh.listen((newToken) {
      print("🔄 TOKEN REFRESHED: $newToken");
      _sendTokenToServer(newToken);
    });

    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    print("✅ FCM setup completed");
  } catch (e) {
    print("❌ FCM setup error: $e");
  }
}

void _handleNotificationNavigation(RemoteMessage message) {
  DeepLinkRouter.navigate(message.data);
}

void _sendTokenToServer(String token) {
  print("📤 Send token to server: $token");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.initialize();
  await _setupFCM();
  await initializeDateFormatting();

  final initialUri = await HomeWidget.initiallyLaunchedFromHomeWidget();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('ko'),
        Locale('ja'),
        Locale('zh'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: ProviderScope(
        child: MyApp(initialUri: initialUri),
      ),
    ),
  );
}

class MyApp extends ConsumerWidget {
  final Uri? initialUri;

  const MyApp({super.key, this.initialUri});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    if (initialUri != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleHomeWidgetLaunch(initialUri!);
      });
    }

    final themeState = ref.watch(themeProvider);
    return MaterialApp(
      navigatorKey: rootNavigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'K-Hub',
      theme: _buildTheme(themeState),
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      home: const AuthGate(),
    );
  }

  ThemeData _buildTheme(ThemeState themeState) {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: themeState.scaffoldBackgroundColor,
      primaryColor: themeState.primaryColor,
      appBarTheme: AppBarTheme(
        backgroundColor: themeState.appBarColor,
        foregroundColor: _getContrastColor(themeState.appBarColor),
        elevation: 0,
        iconTheme: IconThemeData(
          color: _getContrastColor(themeState.appBarColor),
        ),
      ),
      colorScheme: ColorScheme.light(
        primary: themeState.primaryColor,
        onPrimary: _getContrastColor(themeState.primaryColor),
        secondary: themeState.secondaryColor,
        onSecondary: _getContrastColor(themeState.secondaryColor),
        background: themeState.scaffoldBackgroundColor,
        surface: themeState.scaffoldBackgroundColor,
        onBackground: _getContrastColor(themeState.scaffoldBackgroundColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: themeState.primaryColor,
          foregroundColor: _getContrastColor(themeState.primaryColor),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: themeState.primaryColor,
          textStyle: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: themeState.scaffoldBackgroundColor,
        unselectedLabelColor: _getContrastColor(
          themeState.scaffoldBackgroundColor,
        ),
        indicator: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: themeState.primaryColor, width: 2.0),
          ),
        ),
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 14,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: themeState.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: _getContrastColor(themeState.scaffoldBackgroundColor),
        ),
        contentTextStyle: TextStyle(
          fontSize: 14,
          color: _getContrastColor(
            themeState.scaffoldBackgroundColor,
          ).withOpacity(0.8),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: themeState.primaryColor,
        foregroundColor: _getContrastColor(themeState.primaryColor),
      ),
      cardTheme: CardThemeData(
        color: _getCardColor(themeState.scaffoldBackgroundColor),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: themeState.scaffoldBackgroundColor,
        selectedItemColor: themeState.primaryColor,
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  Color _getContrastColor(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5
        ? Colors.black
        : Colors.white;
  }

  Color _getCardColor(Color backgroundColor) {
    double luminance = backgroundColor.computeLuminance();
    if (luminance > 0.8) return Colors.white;
    if (luminance < 0.2) return Colors.grey;
    return backgroundColor.withOpacity(0.9);
  }

  void _handleHomeWidgetLaunch(Uri uri) {
    final widgetId = uri.queryParameters['appWidgetId'];

    if (widgetId != null) {
      DeepLinkRouter.navigate({
        'type': 'home_widget',
        'widgetId': widgetId,
      });
    }
  }
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);

    if (authState.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (authState.user == null) {
      return const LoginScreen();
    }

    return authState.user!.role == 'admin'
        ? const AdminstratorScreen()
        : const HomeScreen();
  }
}