class KWidget {
  String id;
  String userId;
  String type;
  String name;
  Map<String, dynamic> style;
  Map<String, dynamic> data;
  DateTime createdAt;

  KWidget({
    required this.id,
    required this.userId,
    required this.type,
    required this.name,
    required this.style,
    required this.data,
    required this.createdAt,
  });

  KWidget copyWith({
    String? id,
    String? userId,
    String? type,
    String? name,
    Map<String, dynamic>? style,
    Map<String, dynamic>? data,
    DateTime? createdAt,
  }) {
    return KWidget(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      name: name ?? this.name,
      style: style ?? this.style,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory KWidget.fromMap(Map<String, dynamic> map) {
    return KWidget(
      id: map['id'],
      userId: map['userId'],
      type: map['type'],
      name: map['name'],
      style: Map<String, dynamic>.from(map['style']),
      data: Map<String, dynamic>.from(map['data']),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'name': name,
      'style': style,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
