import 'package:cloud_firestore/cloud_firestore.dart';

class KWallpaper {
  final String id;
  final String userId;
  final String title;
  final String backgroundImage;
  final DateTime createdAt;
  final bool isActive; 

  KWallpaper({
    required this.id,
    required this.userId,
    required this.title,
    required this.backgroundImage,
    required this.createdAt,
    this.isActive = false, 
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'backgroundImage': backgroundImage,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isActive': isActive, 
    };
  }

  factory KWallpaper.fromMap(Map<String, dynamic> map) {
    return KWallpaper(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      backgroundImage: map['backgroundImage'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      isActive: map['isActive'] ?? false, 
    );
  }

  factory KWallpaper.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return KWallpaper(
      id: doc.id,
      userId: data['userId'],
      title: data['title'],
      backgroundImage: data['backgroundImage'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt']),
    );
  }
  
  KWallpaper copyWith({bool? isActive}) {
    return KWallpaper(
      id: id,
      userId: userId,
      title: title,
      backgroundImage: backgroundImage,
      createdAt: createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}