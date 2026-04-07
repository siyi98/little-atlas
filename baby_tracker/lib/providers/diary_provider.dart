import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/diary_entry.dart';
import '../utils/database_helper.dart';

class DiaryProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  final Uuid _uuid = const Uuid();

  List<DiaryEntry> _entries = [];

  List<DiaryEntry> get entries => _entries;

  Future<void> loadEntries(String babyId) async {
    final maps = await _db.getDiaryEntries(babyId);
    _entries = maps.map((m) => DiaryEntry.fromMap(m)).toList();
    notifyListeners();
  }

  Future<void> addEntry({
    required String babyId,
    required DateTime date,
    required String content,
    String? mood,
    List<String> photos = const [],
    String? weather,
  }) async {
    final entry = DiaryEntry(
      id: _uuid.v4(),
      babyId: babyId,
      date: date,
      content: content,
      mood: mood,
      photos: photos,
      weather: weather,
    );
    await _db.insertDiaryEntry(entry.toMap());
    _entries.insert(0, entry);
    notifyListeners();
  }

  Future<void> updateEntry(DiaryEntry entry) async {
    await _db.updateDiaryEntry(entry.toMap());
    final index = _entries.indexWhere((e) => e.id == entry.id);
    if (index != -1) {
      _entries[index] = entry;
    }
    notifyListeners();
  }

  Future<void> deleteEntry(String id) async {
    await _db.deleteDiaryEntry(id);
    _entries.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}
