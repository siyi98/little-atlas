class Milestone {
  final String id;
  final String babyId;
  final String title;
  final String? description;
  final DateTime date;
  final String category; // 'first', 'health', 'growth', 'social', 'motor', 'language'
  final String? photoPath;
  final String icon;

  Milestone({
    required this.id,
    required this.babyId,
    required this.title,
    this.description,
    required this.date,
    required this.category,
    this.photoPath,
    this.icon = '⭐',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'babyId': babyId,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'category': category,
      'photoPath': photoPath,
      'icon': icon,
    };
  }

  factory Milestone.fromMap(Map<String, dynamic> map) {
    return Milestone(
      id: map['id'],
      babyId: map['babyId'],
      title: map['title'],
      description: map['description'],
      date: DateTime.parse(map['date']),
      category: map['category'],
      photoPath: map['photoPath'],
      icon: map['icon'] ?? '⭐',
    );
  }

  static List<Map<String, String>> get predefinedMilestones => [
    {'title': '第一次微笑', 'icon': '😊', 'category': 'social'},
    {'title': '第一次翻身', 'icon': '🔄', 'category': 'motor'},
    {'title': '第一次坐起', 'icon': '🪑', 'category': 'motor'},
    {'title': '第一次爬行', 'icon': '🐛', 'category': 'motor'},
    {'title': '第一次站立', 'icon': '🧍', 'category': 'motor'},
    {'title': '第一次走路', 'icon': '🚶', 'category': 'motor'},
    {'title': '第一次叫妈妈', 'icon': '👩', 'category': 'language'},
    {'title': '第一次叫爸爸', 'icon': '👨', 'category': 'language'},
    {'title': '第一颗牙齿', 'icon': '🦷', 'category': 'growth'},
    {'title': '第一次吃辅食', 'icon': '🥣', 'category': 'growth'},
    {'title': '第一次洗澡', 'icon': '🛁', 'category': 'first'},
    {'title': '第一次理发', 'icon': '✂️', 'category': 'first'},
    {'title': '第一次出游', 'icon': '🏖️', 'category': 'first'},
    {'title': '第一次过生日', 'icon': '🎂', 'category': 'first'},
    {'title': '第一次上幼儿园', 'icon': '🏫', 'category': 'social'},
    {'title': '会抬头', 'icon': '👶', 'category': 'motor'},
    {'title': '会拍手', 'icon': '👏', 'category': 'motor'},
    {'title': '会挥手再见', 'icon': '👋', 'category': 'social'},
    {'title': '第一次打疫苗', 'icon': '💉', 'category': 'health'},
    {'title': '第一次生病', 'icon': '🤒', 'category': 'health'},
  ];
}
