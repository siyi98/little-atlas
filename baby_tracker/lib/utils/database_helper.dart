import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'baby_tracker.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE babies (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        birthday TEXT NOT NULL,
        gender TEXT,
        avatarPath TEXT,
        bloodType TEXT,
        birthWeight REAL,
        birthHeight REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE growth_records (
        id TEXT PRIMARY KEY,
        babyId TEXT NOT NULL,
        date TEXT NOT NULL,
        weight REAL,
        height REAL,
        headCircumference REAL,
        notes TEXT,
        FOREIGN KEY (babyId) REFERENCES babies (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE milestones (
        id TEXT PRIMARY KEY,
        babyId TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        date TEXT NOT NULL,
        category TEXT NOT NULL,
        photoPath TEXT,
        icon TEXT DEFAULT '⭐',
        FOREIGN KEY (babyId) REFERENCES babies (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE diary_entries (
        id TEXT PRIMARY KEY,
        babyId TEXT NOT NULL,
        date TEXT NOT NULL,
        content TEXT NOT NULL,
        mood TEXT,
        photos TEXT,
        weather TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (babyId) REFERENCES babies (id)
      )
    ''');
  }

  // Baby operations
  Future<int> insertBaby(Map<String, dynamic> baby) async {
    final db = await database;
    return await db.insert('babies', baby);
  }

  Future<List<Map<String, dynamic>>> getBabies() async {
    final db = await database;
    return await db.query('babies');
  }

  Future<int> updateBaby(Map<String, dynamic> baby) async {
    final db = await database;
    return await db.update('babies', baby, where: 'id = ?', whereArgs: [baby['id']]);
  }

  Future<int> deleteBaby(String id) async {
    final db = await database;
    return await db.delete('babies', where: 'id = ?', whereArgs: [id]);
  }

  // Growth records operations
  Future<int> insertGrowthRecord(Map<String, dynamic> record) async {
    final db = await database;
    return await db.insert('growth_records', record);
  }

  Future<List<Map<String, dynamic>>> getGrowthRecords(String babyId) async {
    final db = await database;
    return await db.query(
      'growth_records',
      where: 'babyId = ?',
      whereArgs: [babyId],
      orderBy: 'date ASC',
    );
  }

  Future<int> deleteGrowthRecord(String id) async {
    final db = await database;
    return await db.delete('growth_records', where: 'id = ?', whereArgs: [id]);
  }

  // Milestone operations
  Future<int> insertMilestone(Map<String, dynamic> milestone) async {
    final db = await database;
    return await db.insert('milestones', milestone);
  }

  Future<List<Map<String, dynamic>>> getMilestones(String babyId) async {
    final db = await database;
    return await db.query(
      'milestones',
      where: 'babyId = ?',
      whereArgs: [babyId],
      orderBy: 'date DESC',
    );
  }

  Future<int> deleteMilestone(String id) async {
    final db = await database;
    return await db.delete('milestones', where: 'id = ?', whereArgs: [id]);
  }

  // Diary operations
  Future<int> insertDiaryEntry(Map<String, dynamic> entry) async {
    final db = await database;
    return await db.insert('diary_entries', entry);
  }

  Future<List<Map<String, dynamic>>> getDiaryEntries(String babyId) async {
    final db = await database;
    return await db.query(
      'diary_entries',
      where: 'babyId = ?',
      whereArgs: [babyId],
      orderBy: 'date DESC',
    );
  }

  Future<int> updateDiaryEntry(Map<String, dynamic> entry) async {
    final db = await database;
    return await db.update('diary_entries', entry, where: 'id = ?', whereArgs: [entry['id']]);
  }

  Future<int> deleteDiaryEntry(String id) async {
    final db = await database;
    return await db.delete('diary_entries', where: 'id = ?', whereArgs: [id]);
  }
}
