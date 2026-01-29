import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/wallpaper_model.dart';
import '../models/widget_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> saveWallpaper(KWallpaper wallpaper) async {
    await _firestore
        .collection('wallpapers')
        .doc(wallpaper.id)
        .set(wallpaper.toMap());
  }

  Future<List<KWallpaper>> getUserWallpapers(String userId) async {
    final snapshot = await _firestore
        .collection('wallpapers')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => KWallpaper.fromMap(doc.data())).toList();
  }

  Future<String> uploadImage(String path, Uint8List imageBytes) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putData(imageBytes);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> saveWidget(KWidget widget) async {
    await _firestore.collection('widgets').doc(widget.id).set(widget.toMap());
  }

  Future<List<KWidget>> getUserWidgets(String userId) async {
    final snapshot = await _firestore
        .collection('widgets')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => KWidget.fromMap(doc.data())).toList();
  }

  Future<List<KWallpaper>> getPublicWallpapers() async {
    final snapshot = await _firestore
        .collection('wallpapers')
        .where('isPublic', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .get();

    return snapshot.docs.map((doc) => KWallpaper.fromMap(doc.data())).toList();
  }

  Future<void> deleteWallpaper(String wallpaperId) async {
    await _firestore.collection('wallpapers').doc(wallpaperId).delete();
  }

  Future<void> updateWidget(KWidget widget) async {
    await _firestore.collection('widgets').doc(widget.id).update(widget.toMap());
  }

  Future<void> deleteWidget(String widgetId) async {
    await _firestore.collection('widgets').doc(widgetId).delete();
  }

  Future<void> addToWallpaperHistory(String userId, String wallpaperId) async {
    final userDoc = _firestore.collection('users').doc(userId);

    await userDoc.update({
      'wallpaperHistory': FieldValue.arrayUnion([wallpaperId]),
    });
  }

  Future<List<KWallpaper>> getWallpaperHistory(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final wallpaperIds = List<String>.from(
      userDoc.data()?['wallpaperHistory'] ?? [],
    );

    if (wallpaperIds.isEmpty) return [];

    final query = await _firestore
        .collection('wallpapers')
        .where(FieldPath.documentId, whereIn: wallpaperIds)
        .get();

    return query.docs.map((doc) => KWallpaper.fromFirestore(doc)).toList();
  }

  Future<KWallpaper?> getWallpaperById(String wallpaperId) async {
    try {
      final doc = await _firestore
          .collection('wallpapers')
          .doc(wallpaperId)
          .get();
      if (doc.exists) {
        return KWallpaper.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting wallpaper by ID: $e');
      return null;
    }
  }

  Future<void> setWallpaperAsActive(String wallpaperId, String userId) async {
    try {
      final userWallpapers = await _firestore
          .collection('wallpapers')
          .where('userId', isEqualTo: userId)
          .get();

      final batch = _firestore.batch();

      for (final doc in userWallpapers.docs) {
        batch.update(doc.reference, {'isActive': false});
      }

      final wallpaperRef = _firestore.collection('wallpapers').doc(wallpaperId);
      batch.update(wallpaperRef, {'isActive': true});

      await batch.commit();

      await addToWallpaperHistory(userId, wallpaperId);
    } catch (e) {
      print('Error setting wallpaper as active: $e');
      throw e;
    }
  }

  Future<KWallpaper?> getActiveWallpaper(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('wallpapers')
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return KWallpaper.fromMap(snapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      print('Error getting active wallpaper: $e');
      return null;
    }
  }

  Future<void> deactivateAllWallpapers(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('wallpapers')
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'isActive': false});
      }
      await batch.commit();
    } catch (e) {
      print('Error deactivating wallpapers: $e');
      throw e;
    }
  }

  Future<List<KWallpaper>> getWallpapersByUser(String userId) async {
    try {
      final snapshot = await _firestore
          .collection("wallpapers")
          .where("userId", isEqualTo: userId)
          .get();

      return snapshot.docs.map((doc) {
        return KWallpaper.fromFirestore(doc);
      }).toList();
    } catch (e) {
      print("ERROR getWallpapersByUser: $e");
      return [];
    }
  }

}