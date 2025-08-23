import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalStorage {
  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDB();
    return _database;
  }

  _initDB() async {
    String path = join(await getDatabasesPath(), 'reports.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  _onCreate(Database db, int version) async {
    await db.execute(
        'CREATE TABLE reports (id INTEGER PRIMARY KEY, imagePath TEXT, violationType TEXT, synced INTEGER)');
  }

  Future<void> insertReport(Map<String, dynamic> report) async {
    final db = await database;
    await db.insert('reports', report,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getReports() async {
    final db = await database;
    return await db.query('reports', where: 'synced = 0');
  }

  Future<void> updateReport(int id) async {
    final db = await database;
    await db.update('reports', {'synced': 1}, where: 'id = ?', whereArgs: [id]);
  }
}
