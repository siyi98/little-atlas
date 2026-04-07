class SleepRecord {
  final String id;
  final String babyId;
  final DateTime startTime;
  final DateTime? endTime;
  final String? notes;

  SleepRecord({
    required this.id,
    required this.babyId,
    required this.startTime,
    this.endTime,
    this.notes,
  });

  int? get durationMinutes {
    if (endTime == null) return null;
    return endTime!.difference(startTime).inMinutes;
  }

  String get durationText {
    final mins = durationMinutes;
    if (mins == null) return '进行中...';
    final h = mins ~/ 60;
    final m = mins % 60;
    if (h > 0 && m > 0) return '${h}小时${m}分钟';
    if (h > 0) return '$h小时';
    return '$m分钟';
  }

  bool get isOngoing => endTime == null;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'babyId': babyId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'notes': notes,
    };
  }

  factory SleepRecord.fromMap(Map<String, dynamic> map) {
    return SleepRecord(
      id: map['id'],
      babyId: map['babyId'],
      startTime: DateTime.parse(map['startTime']),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
      notes: map['notes'],
    );
  }

  SleepRecord copyWith({DateTime? endTime, String? notes}) {
    return SleepRecord(
      id: id,
      babyId: babyId,
      startTime: startTime,
      endTime: endTime ?? this.endTime,
      notes: notes ?? this.notes,
    );
  }
}
