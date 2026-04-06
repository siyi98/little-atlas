class Baby {
  final String id;
  final String name;
  final DateTime birthday;
  final String? gender; // 'boy' or 'girl'
  final String? avatarPath;
  final String? bloodType;
  final double? birthWeight; // in kg
  final double? birthHeight; // in cm

  Baby({
    required this.id,
    required this.name,
    required this.birthday,
    this.gender,
    this.avatarPath,
    this.bloodType,
    this.birthWeight,
    this.birthHeight,
  });

  int get ageInDays => DateTime.now().difference(birthday).inDays;

  String get ageText {
    final days = ageInDays;
    if (days < 30) return '$days天';
    if (days < 365) {
      final months = days ~/ 30;
      final remainDays = days % 30;
      return remainDays > 0 ? '$months个月$remainDays天' : '$months个月';
    }
    final years = days ~/ 365;
    final months = (days % 365) ~/ 30;
    if (months > 0) return '$years岁$months个月';
    return '$years岁';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'birthday': birthday.toIso8601String(),
      'gender': gender,
      'avatarPath': avatarPath,
      'bloodType': bloodType,
      'birthWeight': birthWeight,
      'birthHeight': birthHeight,
    };
  }

  factory Baby.fromMap(Map<String, dynamic> map) {
    return Baby(
      id: map['id'],
      name: map['name'],
      birthday: DateTime.parse(map['birthday']),
      gender: map['gender'],
      avatarPath: map['avatarPath'],
      bloodType: map['bloodType'],
      birthWeight: map['birthWeight']?.toDouble(),
      birthHeight: map['birthHeight']?.toDouble(),
    );
  }

  Baby copyWith({
    String? name,
    DateTime? birthday,
    String? gender,
    String? avatarPath,
    String? bloodType,
    double? birthWeight,
    double? birthHeight,
  }) {
    return Baby(
      id: id,
      name: name ?? this.name,
      birthday: birthday ?? this.birthday,
      gender: gender ?? this.gender,
      avatarPath: avatarPath ?? this.avatarPath,
      bloodType: bloodType ?? this.bloodType,
      birthWeight: birthWeight ?? this.birthWeight,
      birthHeight: birthHeight ?? this.birthHeight,
    );
  }
}
