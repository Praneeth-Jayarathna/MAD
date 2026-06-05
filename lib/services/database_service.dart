import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/generator.dart';
import '../models/fuel_log.dart';
import '../models/running_log.dart';

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
      version: 3,
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
        await db.execute('''
          CREATE TABLE running_logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            generatorId INTEGER NOT NULL,
            date TEXT NOT NULL,
            hoursRun REAL NOT NULL,
            litresConsumed REAL NOT NULL,
            FOREIGN KEY (generatorId) REFERENCES generators(id)
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
              'ALTER TABLE generators ADD COLUMN runningHours INTEGER DEFAULT 0');
        }
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE running_logs (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              generatorId INTEGER NOT NULL,
              date TEXT NOT NULL,
              hoursRun REAL NOT NULL,
              litresConsumed REAL NOT NULL,
              FOREIGN KEY (generatorId) REFERENCES generators(id)
            )
          ''');
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
    await db.delete('running_logs', where: 'generatorId = ?', whereArgs: [id]);
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

  Future<List<FuelLog>> getFuelLogsByDateRange(DateTime start, DateTime end) async {
    final db = await database;
    final s = '${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}';
    final e = '${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}';
    final maps = await db.query('fuel_logs',
        where: 'date >= ? AND date <= ?',
        whereArgs: [s, e],
        orderBy: 'date DESC');
    return maps.map((m) => FuelLog.fromMap(m)).toList();
  }

  // --- Running Logs ---

  Future<int> insertRunningLog(RunningLog log) async {
    final db = await database;
    return db.insert('running_logs', log.toMap());
  }

  Future<List<RunningLog>> getRunningLogs(int generatorId) async {
    final db = await database;
    final maps = await db.query('running_logs',
        where: 'generatorId = ?',
        whereArgs: [generatorId],
        orderBy: 'date DESC');
    return maps.map((m) => RunningLog.fromMap(m)).toList();
  }

  // --- Reports ---

  Future<double> totalFuelConsumed(DateTime start, DateTime end) async {
    final db = await database;
    final s = _dateStr(start);
    final e = _dateStr(end);
    final result = await db.rawQuery(
        'SELECT COALESCE(SUM(litresConsumed), 0) as total FROM running_logs WHERE date >= ? AND date <= ?',
        [s, e]);
    return (result.first['total'] as num?)?.toDouble() ?? 0;
  }

  Future<double> totalFuelAdded(DateTime start, DateTime end) async {
    final db = await database;
    final s = _dateStr(start);
    final e = _dateStr(end);
    final result = await db.rawQuery(
        'SELECT COALESCE(SUM(CAST(litresAdded AS REAL)), 0) as total FROM fuel_logs WHERE date >= ? AND date <= ?',
        [s, e]);
    return (result.first['total'] as num?)?.toDouble() ?? 0;
  }

  Future<double> totalRunningHours(DateTime start, DateTime end) async {
    final db = await database;
    final s = _dateStr(start);
    final e = _dateStr(end);
    final result = await db.rawQuery(
        'SELECT COALESCE(SUM(hoursRun), 0) as total FROM running_logs WHERE date >= ? AND date <= ?',
        [s, e]);
    return (result.first['total'] as num?)?.toDouble() ?? 0;
  }

  Future<Map<int, double>> fuelConsumedByGenerator(DateTime start, DateTime end) async {
    final db = await database;
    final s = _dateStr(start);
    final e = _dateStr(end);
    final rows = await db.rawQuery(
        'SELECT generatorId, COALESCE(SUM(litresConsumed), 0) as total FROM running_logs WHERE date >= ? AND date <= ? GROUP BY generatorId',
        [s, e]);
    return {for (var r in rows) r['generatorId'] as int: (r['total'] as num).toDouble()};
  }

  Future<Map<int, double>> fuelAddedByGenerator(DateTime start, DateTime end) async {
    final db = await database;
    final s = _dateStr(start);
    final e = _dateStr(end);
    final rows = await db.rawQuery(
        'SELECT generatorId, COALESCE(SUM(CAST(litresAdded AS REAL)), 0) as total FROM fuel_logs WHERE date >= ? AND date <= ? GROUP BY generatorId',
        [s, e]);
    return {for (var r in rows) r['generatorId'] as int: (r['total'] as num).toDouble()};
  }

  Future<double> totalFuelCost(DateTime start, DateTime end) async {
    final db = await database;
    final s = _dateStr(start);
    final e = _dateStr(end);
    final result = await db.rawQuery(
        'SELECT COALESCE(SUM(CAST(litresAdded AS REAL) * CAST(rate AS REAL)), 0) as total FROM fuel_logs WHERE date >= ? AND date <= ?',
        [s, e]);
    return (result.first['total'] as num?)?.toDouble() ?? 0;
  }

  String _dateStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
