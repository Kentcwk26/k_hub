class Announcement {
  final String id;
  final String announcementTitle;
  final String announcementContent;
  final String announcementImage;
  final String announcementLink;
  final DateTime createdTime;

  Announcement({
    required this.id,
    required this.announcementTitle,
    required this.announcementContent,
    required this.announcementImage,
    required this.announcementLink,
    required this.createdTime,
  });

  factory Announcement.fromFirestore(Map<String, dynamic> data, String id) {
    return Announcement(
      id: id,
      announcementTitle: data['announcement_title'] ?? '',
      announcementContent: data['announcement_content'] ?? '',
      announcementImage: data['announcement_image'] ?? '',
      announcementLink: data['announcement_link'] ?? '',
      createdTime: _parseDateTime(data['created_time']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'announcement_title': announcementTitle,
      'announcement_content': announcementContent,
      'announcement_image': announcementImage,
      'announcement_link': announcementLink,
      'created_time': createdTime.toIso8601String(),
    };
  }

  static DateTime _parseDateTime(dynamic timeData) {
    if (timeData is String) {
      try {
        return DateTime.parse(timeData);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  Announcement copyWith({
    String? id,
    String? announcementTitle,
    String? announcementContent,
    String? announcementImage,
    String? announcementLink,
    DateTime? createdTime,
  }) {
    return Announcement(
      id: id ?? this.id,
      announcementTitle: announcementTitle ?? this.announcementTitle,
      announcementContent: announcementContent ?? this.announcementContent,
      announcementImage: announcementImage ?? this.announcementImage,
      announcementLink: announcementLink ?? this.announcementLink,
      createdTime: createdTime ?? this.createdTime,
    );
  }
}