class DiaryEntry {
  final String id;
  final String babyId;
  final DateTime date;
  final String content;
  final String? mood; // emoji
  final List<String> photos;
  final String? weather;
  final DateTime createdAt;

  DiaryEntry({
    required this.id,
    required this.babyId,
    required this.date,
    required this.content,
    this.mood,
    this.photos = const [],
    this.weather,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'babyId': babyId,
      'date': date.toIso8601String(),
      'content': content,
      'mood': mood,
      'photos': photos.join(','),
      'weather': weather,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory DiaryEntry.fromMap(Map<String, dynamic> map) {
    return DiaryEntry(
      id: map['id'],
      babyId: map['babyId'],
      date: DateTime.parse(map['date']),
      content: map['content'],
      mood: map['mood'],
      photos: map['photos'] != null && map['photos'].toString().isNotEmpty
          ? map['photos'].toString().split(',').where((p) => p.isNotEmpty).toList()
          : [],
      weather: map['weather'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  DiaryEntry copyWith({
    String? content,
    String? mood,
    List<String>? photos,
    String? weather,
  }) {
    return DiaryEntry(
      id: id,
      babyId: babyId,
      date: date,
      content: content ?? this.content,
      mood: mood ?? this.mood,
      photos: photos ?? this.photos,
      weather: weather ?? this.weather,
      createdAt: createdAt,
    );
  }
}
