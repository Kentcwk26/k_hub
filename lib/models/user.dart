import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../constants/icon.dart';

class AppUsers {
  final String userId;
  final String name;
  final String email;
  final String photoUrl;
  final String contact;
  final String gender;
  final String role;
  final List<String> wallpaperHistory;
  final DateTime creationDateTime;

  AppUsers({
    required this.userId,
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.contact,
    required this.gender,
    required this.role,
    List<String>? wallpaperHistory,
    required this.creationDateTime,
  }) : wallpaperHistory = wallpaperHistory ?? [];

  AppUsers copyWith({
    String? userId,
    String? name,
    String? email,
    String? photoUrl,
    String? contact,
    String? gender,
    String? role,
    List<String>? wallpaperHistory,
    DateTime? createdAt,
  }) {
    return AppUsers(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      contact: contact ?? this.contact,
      gender: gender ?? this.gender,
      role: role ?? this.role,
      wallpaperHistory: wallpaperHistory ?? this.wallpaperHistory,
      creationDateTime: createdAt ?? creationDateTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'contact': contact,
      'gender': gender,
      'role': role,
      'wallpaperHistory': wallpaperHistory,
      'createdAt': Timestamp.fromDate(creationDateTime),
    };
  }

  factory AppUsers.fromMap(Map<String, dynamic> map, String id) {
    return AppUsers(
      userId: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      contact: map['contact'] ?? '',
      gender: map['gender'] ?? '',
      role: map['role'] ?? 'Member',
      wallpaperHistory: List<String>.from(map['wallpaperHistory'] ?? []),
      creationDateTime: _parseDate(map['createdAt']),
    );
  }

  AppUsers addToWallpaperHistory(String wallpaperId) {
    final newHistory = List<String>.from(wallpaperHistory)..add(wallpaperId);
    return copyWith(wallpaperHistory: newHistory);
  }

  AppUsers removeFromWallpaperHistory(String wallpaperId) {
    final newHistory = List<String>.from(wallpaperHistory)..remove(wallpaperId);
    return copyWith(wallpaperHistory: newHistory);
  }

  bool hasWallpaperInHistory(String wallpaperId) {
    return wallpaperHistory.contains(wallpaperId);
  }

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return DateTime.now();
  }
}

class ChatRoom {
  final String id;
  final List<String> participantIds;
  final String lastMessage;
  final Timestamp updatedAt;
  final String? lastMediaType;
  final bool isGroup;
  final String? groupName;
  final String? groupDescription;
  final String? groupPhotoUrl;
  final String? createdBy;
  final List<String>? admins;

  ChatRoom({
    required this.id,
    required this.participantIds,
    required this.lastMessage,
    required this.updatedAt,
    this.lastMediaType,
    this.isGroup = false,
    this.groupName,
    this.groupDescription,
    this.groupPhotoUrl,
    this.createdBy,
    this.admins,
  });

  factory ChatRoom.fromMap(String id, Map<String, dynamic> data) {
    return ChatRoom(
      id: id,
      participantIds: List<String>.from(data['participantIds'] ?? []),
      lastMessage: data['lastMessage'] ?? '',
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
      lastMediaType: data['lastMediaType'],
      isGroup: data['isGroup'] ?? false,
      groupName: data['groupName'],
      groupDescription: data['groupDescription'],
      groupPhotoUrl: data['groupPhotoUrl'],
      createdBy: data['createdBy'],
      admins: data['admins'] != null ? List<String>.from(data['admins']) : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participantIds': participantIds,
      'lastMessage': lastMessage,
      'updatedAt': updatedAt,
      'lastMediaType': lastMediaType,
      'isGroup': isGroup,
      'groupName': groupName,
      'groupDescription': groupDescription,
      'groupPhotoUrl': groupPhotoUrl,
      'createdBy': createdBy,
      'admins': admins,
    };
  }
}

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String senderPhoto;
  final String text;
  final DateTime timestamp;
  final String? mediaUrl;
  final String? mediaType;
  final bool isEdited;
  final bool isRead;
  final Map<String, dynamic>? pollData;
  final List<String> readBy;
  final bool isSystemMessage;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderPhoto,
    required this.text,
    required this.timestamp,
    this.mediaUrl,
    this.mediaType,
    this.isEdited = false,
    this.isRead = false,
    this.pollData,
    this.readBy = const [],
    this.isSystemMessage = false,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map, String id) {
    return ChatMessage(
      id: id,
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? 'Unknown User',
      senderPhoto: map['senderPhoto'] ?? '',
      text: map['text'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      mediaUrl: map['mediaUrl'],
      mediaType: map['mediaType'],
      isEdited: map['isEdited'] ?? false,
      isRead: map['isRead'] ?? false,
      pollData: map['pollData'],
      readBy: List<String>.from(map['readBy'] ?? []),
      isSystemMessage: map['isSystemMessage'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'senderPhoto': senderPhoto,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
      'isEdited': isEdited,
      'isRead': isRead,
      'pollData': pollData,
      'readBy': readBy,
      'isSystemMessage': isSystemMessage,
    };
  }

  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? senderPhoto,
    String? text,
    DateTime? timestamp,
    String? mediaUrl,
    String? mediaType,
    bool? isEdited,
    bool? isRead,
    Map<String, dynamic>? pollData,
    List<String>? readBy,
    bool? isSystemMessage,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderPhoto: senderPhoto ?? this.senderPhoto,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaType: mediaType ?? this.mediaType,
      isEdited: isEdited ?? this.isEdited,
      isRead: isRead ?? this.isRead,
      pollData: pollData ?? this.pollData,
      readBy: readBy ?? this.readBy,
      isSystemMessage: isSystemMessage ?? this.isSystemMessage,
    );
  }
}

class Notifications {
  final String notificationId;
  final String userId;
  final String title;
  final String message;
  final String dateformat;
  final String iconKey;
  final String status;

  Notifications({
    required this.notificationId,
    required this.userId,
    required this.title,
    required this.message,
    required this.dateformat,
    required this.iconKey,
    required this.status,
  });

  IconData get icon => kIconRegistry[iconKey] ?? Icons.notifications;

  Map<String, dynamic> toMap() => {
    'notificationId': notificationId,
    'userId': userId,
    'title': title,
    'message': message,
    'dateformat': dateformat,
    'iconKey': iconKey,
    'status': status,
  };

  factory Notifications.fromMap(Map<String, dynamic> map) {
    return Notifications(
      notificationId: map['notificationId'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      dateformat: map['dateformat'] ?? '',
      iconKey: map['iconKey'] ?? 'notification',
      status: map['status'] ?? 'Unread',
    );
  }
}