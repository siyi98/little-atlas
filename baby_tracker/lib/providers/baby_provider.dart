import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/baby.dart';
import '../models/growth_record.dart';
import '../models/milestone.dart';
import '../utils/database_helper.dart';

class BabyProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  final Uuid _uuid = const Uuid();

  List<Baby> _babies = [];
  Baby? _currentBaby;
  List<GrowthRecord> _growthRecords = [];
  List<Milestone> _milestones = [];

  List<Baby> get babies => _babies;
  Baby? get currentBaby => _currentBaby;
  List<GrowthRecord> get growthRecords => _growthRecords;
  List<Milestone> get milestones => _milestones;

  Future<void> loadBabies() async {
    final maps = await _db.getBabies();
    _babies = maps.map((m) => Baby.fromMap(m)).toList();
    if (_babies.isNotEmpty && _currentBaby == null) {
      _currentBaby = _babies.first;
      await loadBabyData();
    }
    notifyListeners();
  }

  Future<void> setCurrentBaby(Baby baby) async {
    _currentBaby = baby;
    await loadBabyData();
    notifyListeners();
  }

  Future<void> loadBabyData() async {
    if (_currentBaby == null) return;
    await Future.wait([
      loadGrowthRecords(),
      loadMilestones(),
    ]);
  }

  Future<void> addBaby({
    required String name,
    required DateTime birthday,
    String? gender,
    String? avatarPath,
    String? bloodType,
    double? birthWeight,
    double? birthHeight,
  }) async {
    final baby = Baby(
      id: _uuid.v4(),
      name: name,
      birthday: birthday,
      gender: gender,
      avatarPath: avatarPath,
      bloodType: bloodType,
      birthWeight: birthWeight,
      birthHeight: birthHeight,
    );
    await _db.insertBaby(baby.toMap());
    _babies.add(baby);
    if (_currentBaby == null) {
      _currentBaby = baby;
    }
    notifyListeners();
  }

  Future<void> updateBaby(Baby baby) async {
    await _db.updateBaby(baby.toMap());
    final index = _babies.indexWhere((b) => b.id == baby.id);
    if (index != -1) {
      _babies[index] = baby;
    }
    if (_currentBaby?.id == baby.id) {
      _currentBaby = baby;
    }
    notifyListeners();
  }

  // Growth Records
  Future<void> loadGrowthRecords() async {
    if (_currentBaby == null) return;
    final maps = await _db.getGrowthRecords(_currentBaby!.id);
    _growthRecords = maps.map((m) => GrowthRecord.fromMap(m)).toList();
    notifyListeners();
  }

  Future<void> addGrowthRecord({
    required DateTime date,
    double? weight,
    double? height,
    double? headCircumference,
    String? notes,
  }) async {
    if (_currentBaby == null) return;
    final record = GrowthRecord(
      id: _uuid.v4(),
      babyId: _currentBaby!.id,
      date: date,
      weight: weight,
      height: height,
      headCircumference: headCircumference,
      notes: notes,
    );
    await _db.insertGrowthRecord(record.toMap());
    _growthRecords.add(record);
    _growthRecords.sort((a, b) => a.date.compareTo(b.date));
    notifyListeners();
  }

  Future<void> deleteGrowthRecord(String id) async {
    await _db.deleteGrowthRecord(id);
    _growthRecords.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  // Milestones
  Future<void> loadMilestones() async {
    if (_currentBaby == null) return;
    final maps = await _db.getMilestones(_currentBaby!.id);
    _milestones = maps.map((m) => Milestone.fromMap(m)).toList();
    notifyListeners();
  }

  Future<void> addMilestone({
    required String title,
    String? description,
    required DateTime date,
    required String category,
    String? photoPath,
    String icon = '⭐',
  }) async {
    if (_currentBaby == null) return;
    final milestone = Milestone(
      id: _uuid.v4(),
      babyId: _currentBaby!.id,
      title: title,
      description: description,
      date: date,
      category: category,
      photoPath: photoPath,
      icon: icon,
    );
    await _db.insertMilestone(milestone.toMap());
    _milestones.insert(0, milestone);
    notifyListeners();
  }

  Future<void> deleteMilestone(String id) async {
    await _db.deleteMilestone(id);
    _milestones.removeWhere((m) => m.id == id);
    notifyListeners();
  }
}
