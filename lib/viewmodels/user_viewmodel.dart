import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../repositories/user_repository.dart';

class UserViewModel extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();
  final Map<String, AppUsers> _cachedUsers = {};
  AppUsers? _currentUser;

  Future<AppUsers?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;
    
    final currentUserId = await _getCurrentUserIdFromAuth();
    
    if (currentUserId != null) {
      _currentUser = await getUser(currentUserId);
      return _currentUser;
    }
    
    return null;
  }

  Future<String?> _getCurrentUserIdFromAuth() async {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  Future<AppUsers?> getUser(String userId) async {
    if (_cachedUsers.containsKey(userId)) return _cachedUsers[userId];
    final user = await _userRepository.getUser(userId);
    if (user != null) _cachedUsers[userId] = user;
    return user;
  }

  Future<List<AppUsers>> getAllUsers() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('users').get();
      return snapshot.docs.map((doc) => AppUsers.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      debugPrint('Error getting all users: $e');
      return [];
    }
  }

  Future<void> addWallpaperToHistory(String wallpaperId) async {
    if (_currentUser != null) {
      final updatedUser = _currentUser!.addToWallpaperHistory(wallpaperId);
      await _userRepository.updateUser(updatedUser);
      _currentUser = updatedUser;
      _cachedUsers[_currentUser!.userId] = updatedUser;
      notifyListeners();
    }
  }

  Future<void> setActiveWallpaper(String wallpaperId) async {
    if (_currentUser != null) {
        _currentUser = _currentUser!.addToWallpaperHistory(wallpaperId);
        _cachedUsers[_currentUser!.userId] = _currentUser!;
        notifyListeners();
      }
    }

  String? getActiveWallpaperId() {
    final history = _currentUser?.wallpaperHistory ?? [];
    return history.isNotEmpty ? history.last : null;
  }
}