class Vaccination {
  final String id;
  final String name;
  final String disease;
  final int doseNumber;
  final int recommendedMonths;
  final bool isFree; // true = 免费（一类）, false = 自费（二类）

  const Vaccination({
    required this.id,
    required this.name,
    required this.disease,
    required this.doseNumber,
    required this.recommendedMonths,
    this.isFree = true,
  });

  String get recommendedAgeText {
    if (recommendedMonths == 0) return '出生时';
    if (recommendedMonths < 12) return '$recommendedMonths月龄';
    final years = recommendedMonths ~/ 12;
    final months = recommendedMonths % 12;
    if (months > 0) return '$years岁$months月';
    return '$years岁';
  }

  static const List<Vaccination> standardSchedule = [
    Vaccination(id: 'bcg_1', name: '卡介苗', disease: '结核病', doseNumber: 1, recommendedMonths: 0),
    Vaccination(id: 'hepb_1', name: '乙肝疫苗', disease: '乙型肝炎', doseNumber: 1, recommendedMonths: 0),
    Vaccination(id: 'hepb_2', name: '乙肝疫苗', disease: '乙型肝炎', doseNumber: 2, recommendedMonths: 1),
    Vaccination(id: 'hepb_3', name: '乙肝疫苗', disease: '乙型肝炎', doseNumber: 3, recommendedMonths: 6),
    Vaccination(id: 'polio_1', name: '脊灰疫苗', disease: '脊髓灰质炎', doseNumber: 1, recommendedMonths: 2),
    Vaccination(id: 'polio_2', name: '脊灰疫苗', disease: '脊髓灰质炎', doseNumber: 2, recommendedMonths: 3),
    Vaccination(id: 'polio_3', name: '脊灰疫苗', disease: '脊髓灰质炎', doseNumber: 3, recommendedMonths: 4),
    Vaccination(id: 'polio_4', name: '脊灰疫苗', disease: '脊髓灰质炎', doseNumber: 4, recommendedMonths: 48),
    Vaccination(id: 'dpt_1', name: '百白破疫苗', disease: '百日咳/白喉/破伤风', doseNumber: 1, recommendedMonths: 3),
    Vaccination(id: 'dpt_2', name: '百白破疫苗', disease: '百日咳/白喉/破伤风', doseNumber: 2, recommendedMonths: 4),
    Vaccination(id: 'dpt_3', name: '百白破疫苗', disease: '百日咳/白喉/破伤风', doseNumber: 3, recommendedMonths: 5),
    Vaccination(id: 'dpt_4', name: '百白破疫苗', disease: '百日咳/白喉/破伤风', doseNumber: 4, recommendedMonths: 18),
    Vaccination(id: 'mmr_1', name: '麻腮风疫苗', disease: '麻疹/腮腺炎/风疹', doseNumber: 1, recommendedMonths: 8),
    Vaccination(id: 'mmr_2', name: '麻腮风疫苗', disease: '麻疹/腮腺炎/风疹', doseNumber: 2, recommendedMonths: 18),
    Vaccination(id: 'je_1', name: '乙脑减毒疫苗', disease: '流行性乙型脑炎', doseNumber: 1, recommendedMonths: 8),
    Vaccination(id: 'je_2', name: '乙脑减毒疫苗', disease: '流行性乙型脑炎', doseNumber: 2, recommendedMonths: 24),
    Vaccination(id: 'mena_1', name: 'A群流脑疫苗', disease: '流行性脑脊髓膜炎', doseNumber: 1, recommendedMonths: 6),
    Vaccination(id: 'mena_2', name: 'A群流脑疫苗', disease: '流行性脑脊髓膜炎', doseNumber: 2, recommendedMonths: 9),
    Vaccination(id: 'menac_1', name: 'A+C群流脑疫苗', disease: '流行性脑脊髓膜炎', doseNumber: 1, recommendedMonths: 36),
    Vaccination(id: 'menac_2', name: 'A+C群流脑疫苗', disease: '流行性脑脊髓膜炎', doseNumber: 2, recommendedMonths: 72),
    Vaccination(id: 'hepa_1', name: '甲肝减毒疫苗', disease: '甲型肝炎', doseNumber: 1, recommendedMonths: 18),
    Vaccination(id: 'dt_1', name: '白破疫苗', disease: '白喉/破伤风', doseNumber: 1, recommendedMonths: 72),
    Vaccination(id: 'var_1', name: '水痘疫苗', disease: '水痘', doseNumber: 1, recommendedMonths: 12, isFree: false),
    Vaccination(id: 'hib_1', name: 'Hib疫苗', disease: 'b型流感嗜血杆菌', doseNumber: 1, recommendedMonths: 2, isFree: false),
    Vaccination(id: 'rota_1', name: '轮状病毒疫苗', disease: '轮状病毒腹泻', doseNumber: 1, recommendedMonths: 2, isFree: false),
    Vaccination(id: 'flu_1', name: '流感疫苗', disease: '流行性感冒', doseNumber: 1, recommendedMonths: 6, isFree: false),
  ];
}

class VaccinationRecord {
  final String id;
  final String babyId;
  final String vaccinationId;
  final DateTime date;
  final String? hospital;
  final String? batchNumber;
  final String? notes;

  VaccinationRecord({
    required this.id,
    required this.babyId,
    required this.vaccinationId,
    required this.date,
    this.hospital,
    this.batchNumber,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'babyId': babyId,
      'vaccinationId': vaccinationId,
      'date': date.toIso8601String(),
      'hospital': hospital,
      'batchNumber': batchNumber,
      'notes': notes,
    };
  }

  factory VaccinationRecord.fromMap(Map<String, dynamic> map) {
    return VaccinationRecord(
      id: map['id'],
      babyId: map['babyId'],
      vaccinationId: map['vaccinationId'],
      date: DateTime.parse(map['date']),
      hospital: map['hospital'],
      batchNumber: map['batchNumber'],
      notes: map['notes'],
    );
  }
}
