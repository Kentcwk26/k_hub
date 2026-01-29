import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/eventsActivities.dart';

class AnnouncementRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String _collectionName = 'announcement';

  Stream<List<Announcement>> getAnnouncements() {
    return _firestore
        .collection(_collectionName)
        .orderBy('created_time', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Announcement.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Future<String> _uploadImage(File imageFile, String announcementId) async {
    try {
      final ref = _storage.ref().child('announcements/$announcementId/${DateTime.now().millisecondsSinceEpoch}');
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> addAnnouncement(Announcement announcement, {File? imageFile}) async {
    try {
      String imageUrl = announcement.announcementImage;
      
      if (imageFile != null) {
        imageUrl = await _uploadImage(imageFile, announcement.id);
      }

      final announcementWithImage = announcement.copyWith(announcementImage: imageUrl);
      
      await _firestore
          .collection(_collectionName)
          .add(announcementWithImage.toFirestore());
    } catch (e) {
      throw Exception('Failed to add announcement: $e');
    }
  }

  Future<void> updateAnnouncement(Announcement announcement, {File? newImageFile}) async {
    try {
      String imageUrl = announcement.announcementImage;
      
      if (newImageFile != null) {
        imageUrl = await _uploadImage(newImageFile, announcement.id);
      }

      final updatedAnnouncement = announcement.copyWith(announcementImage: imageUrl);
      
      await _firestore
          .collection(_collectionName)
          .doc(announcement.id)
          .update(updatedAnnouncement.toFirestore());
    } catch (e) {
      throw Exception('Failed to update announcement: $e');
    }
  }

  Future<void> deleteAnnouncement(String announcementId) async {
    await _firestore
        .collection(_collectionName)
        .doc(announcementId)
        .delete();
  }
}