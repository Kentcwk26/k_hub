import 'package:flutter/material.dart';
import 'package:k_hub/screens/profile.dart';
import '../app_router.dart';
import '../screens/home.dart';
import '../screens/wallpaper_creator.dart';

class DeepLinkRouter {
  static void navigate(Map<String, dynamic> data) {
    final navigator = rootNavigatorKey.currentState;
    if (navigator == null) return;

    switch (data['open'] ?? data['type']) {
      case 'wallpaper_creator':
        navigator.push(
          MaterialPageRoute(builder: (_) => const WallpaperCreator()),
        );
        break;

      case 'profile':
        navigator.push(
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
        break;

      case 'chat':
        // navigator.push(...)
        break;

      default:
        navigator.push(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
    }
  }
}