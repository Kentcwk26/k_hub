import 'dart:io';

import 'package:flutter/foundation.dart';
import '../models/eventsActivities.dart';
import '../repositories/announcement_repository.dart';

class AnnouncementViewModel with ChangeNotifier {
  final AnnouncementRepository _repository;
  List<Announcement> _announcements = [];
  bool _isLoading = false;
  String _error = '';

  AnnouncementViewModel(this._repository);

  List<Announcement> get announcements => _announcements;
  bool get isLoading => _isLoading;
  String get error => _error;

  Stream<List<Announcement>> getAnnouncementsStream() {
    return _repository.getAnnouncements();
  }
}

class ManageAnnouncementViewModel with ChangeNotifier {
  final AnnouncementRepository _repository;
  List<Announcement> _announcements = [];
  bool _isLoading = false;
  String _error = '';

  ManageAnnouncementViewModel(this._repository);

  List<Announcement> get announcements => _announcements;
  bool get isLoading => _isLoading;
  String get error => _error;

  Stream<List<Announcement>> getAnnouncementsStream() {
    return _repository.getAnnouncements();
  }

  Future<void> addAnnouncement(Announcement announcement, {File? imageFile}) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _repository.addAnnouncement(announcement, imageFile: imageFile);
      _error = '';
    } catch (e) {
      _error = 'Failed to add announcement: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateAnnouncement(Announcement announcement, {File? imageFile}) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _repository.updateAnnouncement(announcement, newImageFile: imageFile);
      _error = '';
    } catch (e) {
      _error = 'Failed to update announcement: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAnnouncement(String announcementId) async {
    try {
      await _repository.deleteAnnouncement(announcementId);
      _error = '';
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete announcement: $e';
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}