
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:adhan/adhan.dart';

final prayerTrackerServiceProvider = Provider((ref) => PrayerTrackerService());

class PrayerTrackerService {
  Database? _database;
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'prayer_tracker.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE prayer_logs(id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT, prayer TEXT, prayed INTEGER)',
        );
      },
    );
  }
  
  Future<void> logPrayer(DateTime date, Prayer prayer, bool prayed) async {
    final db = await database;
    final dateString = date.toIso8601String().split('T')[0];
    
    await db.insert(
      'prayer_logs',
      {
        'date': dateString,
        'prayer': prayer.name,
        'prayed': prayed ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  Future<bool> isPrayerLogged(DateTime date, Prayer prayer) async {
    final db = await database;
    final dateString = date.toIso8601String().split('T')[0];
    
    final List<Map<String, dynamic>> maps = await db.query(
      'prayer_logs',
      where: 'date = ? AND prayer = ?',
      whereArgs: [dateString, prayer.name],
    );
    
    if (maps.isNotEmpty) {
      return maps.first['prayed'] == 1;
    }
    return false;
  }
}
