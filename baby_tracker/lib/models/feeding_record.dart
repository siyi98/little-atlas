class FeedingRecord {
  final String id;
  final String babyId;
  final DateTime startTime;
  final DateTime? endTime;
  final String type; // 'breast_left', 'breast_right', 'bottle', 'solid'
  final int? durationMinutes;
  final double? amountMl;
  final String? foodName;
  final String? notes;

  FeedingRecord({
    required this.id,
    required this.babyId,
    required this.startTime,
    this.endTime,
    required this.type,
    this.durationMinutes,
    this.amountMl,
    this.foodName,
    this.notes,
  });

  String get typeLabel {
    switch (type) {
      case 'breast_left': return '左侧母乳';
      case 'breast_right': return '右侧母乳';
      case 'bottle': return '奶瓶';
      case 'solid': return '辅食';
      default: return type;
    }
  }

  String get typeIcon {
    switch (type) {
      case 'breast_left':
      case 'breast_right': return '🤱';
      case 'bottle': return '🍼';
      case 'solid': return '🥣';
      default: return '🍽️';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'babyId': babyId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'type': type,
      'durationMinutes': durationMinutes,
      'amountMl': amountMl,
      'foodName': foodName,
      'notes': notes,
    };
  }

  factory FeedingRecord.fromMap(Map<String, dynamic> map) {
    return FeedingRecord(
      id: map['id'],
      babyId: map['babyId'],
      startTime: DateTime.parse(map['startTime']),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
      type: map['type'],
      durationMinutes: map['durationMinutes'],
      amountMl: map['amountMl']?.toDouble(),
      foodName: map['foodName'],
      notes: map['notes'],
    );
  }
}
