import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/feeding_record.dart';
import '../models/sleep_record.dart';
import '../models/vaccination.dart';
import '../utils/database_helper.dart';

class DailyCareProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  final Uuid _uuid = const Uuid();

  List<FeedingRecord> _feedingRecords = [];
  List<SleepRecord> _sleepRecords = [];
  List<VaccinationRecord> _vaccinationRecords = [];

  List<FeedingRecord> get feedingRecords => _feedingRecords;
  List<SleepRecord> get sleepRecords => _sleepRecords;
  List<VaccinationRecord> get vaccinationRecords => _vaccinationRecords;

  SleepRecord? get ongoingSleep => _sleepRecords.where((s) => s.isOngoing).firstOrNull;

  int get todayFeedingCount {
    final today = DateTime.now();
    return _feedingRecords.where((r) =>
        r.startTime.year == today.year &&
        r.startTime.month == today.month &&
        r.startTime.day == today.day).length;
  }

  int get todaySleepMinutes {
    final today = DateTime.now();
    return _sleepRecords
        .where((r) =>
            r.startTime.year == today.year &&
            r.startTime.month == today.month &&
            r.startTime.day == today.day &&
            r.durationMinutes != null)
        .fold(0, (sum, r) => sum + r.durationMinutes!);
  }

  Set<String> get completedVaccinationIds =>
      _vaccinationRecords.map((r) => r.vaccinationId).toSet();

  Future<void> loadAll(String babyId) async {
    await Future.wait([
      loadFeedingRecords(babyId),
      loadSleepRecords(babyId),
      loadVaccinationRecords(babyId),
    ]);
  }

  // Feeding
  Future<void> loadFeedingRecords(String babyId) async {
    final maps = await _db.getFeedingRecords(babyId);
    _feedingRecords = maps.map((m) => FeedingRecord.fromMap(m)).toList();
    notifyListeners();
  }

  Future<void> addFeedingRecord({
    required String babyId,
    required DateTime startTime,
    DateTime? endTime,
    required String type,
    int? durationMinutes,
    double? amountMl,
    String? foodName,
    String? notes,
  }) async {
    final record = FeedingRecord(
      id: _uuid.v4(), babyId: babyId, startTime: startTime, endTime: endTime,
      type: type, durationMinutes: durationMinutes, amountMl: amountMl,
      foodName: foodName, notes: notes,
    );
    await _db.insertFeedingRecord(record.toMap());
    _feedingRecords.insert(0, record);
    notifyListeners();
  }

  Future<void> deleteFeedingRecord(String id) async {
    await _db.deleteFeedingRecord(id);
    _feedingRecords.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  // Sleep
  Future<void> loadSleepRecords(String babyId) async {
    final maps = await _db.getSleepRecords(babyId);
    _sleepRecords = maps.map((m) => SleepRecord.fromMap(m)).toList();
    notifyListeners();
  }

  Future<void> startSleep({required String babyId, DateTime? startTime}) async {
    final record = SleepRecord(
      id: _uuid.v4(), babyId: babyId, startTime: startTime ?? DateTime.now(),
    );
    await _db.insertSleepRecord(record.toMap());
    _sleepRecords.insert(0, record);
    notifyListeners();
  }

  Future<void> endSleep(String id) async {
    final index = _sleepRecords.indexWhere((r) => r.id == id);
    if (index != -1) {
      final updated = _sleepRecords[index].copyWith(endTime: DateTime.now());
      await _db.updateSleepRecord(updated.toMap());
      _sleepRecords[index] = updated;
      notifyListeners();
    }
  }

  Future<void> deleteSleepRecord(String id) async {
    await _db.deleteSleepRecord(id);
    _sleepRecords.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  // Vaccination
  Future<void> loadVaccinationRecords(String babyId) async {
    final maps = await _db.getVaccinationRecords(babyId);
    _vaccinationRecords = maps.map((m) => VaccinationRecord.fromMap(m)).toList();
    notifyListeners();
  }

  Future<void> addVaccinationRecord({
    required String babyId,
    required String vaccinationId,
    required DateTime date,
    String? hospital,
    String? batchNumber,
    String? notes,
  }) async {
    final record = VaccinationRecord(
      id: _uuid.v4(), babyId: babyId, vaccinationId: vaccinationId,
      date: date, hospital: hospital, batchNumber: batchNumber, notes: notes,
    );
    await _db.insertVaccinationRecord(record.toMap());
    _vaccinationRecords.insert(0, record);
    notifyListeners();
  }

  Future<void> deleteVaccinationRecord(String id) async {
    await _db.deleteVaccinationRecord(id);
    _vaccinationRecords.removeWhere((r) => r.id == id);
    notifyListeners();
  }
}
