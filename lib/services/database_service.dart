import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/generator.dart';
import '../models/fuel_log.dart';

class DatabaseService {
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final path = join(await getDatabasesPath(), 'fuel_tracker.db');
    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE generators (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            imagePath TEXT NOT NULL,
            code TEXT DEFAULT '',
            capacity TEXT DEFAULT '',
            usage TEXT DEFAULT '',
            remainingFuel REAL DEFAULT 0,
            runningHours INTEGER DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE fuel_logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            generatorId INTEGER NOT NULL,
            date TEXT NOT NULL,
            litresAdded TEXT NOT NULL,
            rate TEXT NOT NULL,
            FOREIGN KEY (generatorId) REFERENCES generators(id)
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
              'ALTER TABLE generators ADD COLUMN runningHours INTEGER DEFAULT 0');
        }
      },
    );
  }

  // --- Generators ---

  Future<int> insertGenerator(Generator g) async {
    final db = await database;
    return db.insert('generators', g.toMap());
  }

  Future<List<Generator>> getGenerators() async {
    final db = await database;
    final maps = await db.query('generators');
    return maps.map((m) => Generator.fromMap(m)).toList();
  }

  Future<Generator?> getGenerator(int id) async {
    final db = await database;
    final maps = await db.query('generators', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Generator.fromMap(maps.first);
  }

  Future<int> updateGenerator(Generator g) async {
    final db = await database;
    return db.update('generators', g.toMap(), where: 'id = ?', whereArgs: [g.id]);
  }

  Future<int> deleteGenerator(int id) async {
    final db = await database;
    await db.delete('fuel_logs', where: 'generatorId = ?', whereArgs: [id]);
    return db.delete('generators', where: 'id = ?', whereArgs: [id]);
  }

  // --- Fuel Logs ---

  Future<int> insertFuelLog(FuelLog log) async {
    final db = await database;
    return db.insert('fuel_logs', log.toMap());
  }

  Future<List<FuelLog>> getFuelLogs(int generatorId) async {
    final db = await database;
    final maps = await db.query('fuel_logs',
        where: 'generatorId = ?',
        whereArgs: [generatorId],
        orderBy: 'date DESC');
    return maps.map((m) => FuelLog.fromMap(m)).toList();
  }
}
