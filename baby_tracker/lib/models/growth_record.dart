class GrowthRecord {
  final String id;
  final String babyId;
  final DateTime date;
  final double? weight; // in kg
  final double? height; // in cm
  final double? headCircumference; // in cm
  final String? notes;

  GrowthRecord({
    required this.id,
    required this.babyId,
    required this.date,
    this.weight,
    this.height,
    this.headCircumference,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'babyId': babyId,
      'date': date.toIso8601String(),
      'weight': weight,
      'height': height,
      'headCircumference': headCircumference,
      'notes': notes,
    };
  }

  factory GrowthRecord.fromMap(Map<String, dynamic> map) {
    return GrowthRecord(
      id: map['id'],
      babyId: map['babyId'],
      date: DateTime.parse(map['date']),
      weight: map['weight']?.toDouble(),
      height: map['height']?.toDouble(),
      headCircumference: map['headCircumference']?.toDouble(),
      notes: map['notes'],
    );
  }
}
