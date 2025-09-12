import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('calendar.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        description TEXT,
        location TEXT,
        repeating TEXT
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE events ADD COLUMN time TEXT NOT NULL DEFAULT ""');
      await db.execute('ALTER TABLE events ADD COLUMN description TEXT');
      await db.execute('ALTER TABLE events ADD COLUMN location TEXT');
      await db.execute('ALTER TABLE events ADD COLUMN repeating TEXT');
    }
  }

  Future<int> insertEvent(String title, DateTime date, String time, String description, String location, String repeating) async {
    final db = await instance.database;
    return await db.insert('events', {
      'title': title,
      'date': date.toIso8601String(),
      'time': time,
      'description': description,
      'location': location,
      'repeating': repeating,
    });
  }

  Future<List<Map<String, dynamic>>> getEvents() async {
    final db = await instance.database;
    return await db.query('events', orderBy: 'date ASC');
  }

  Future<int> deleteEvent(int id) async {
    final db = await instance.database;
    return await db.delete('events', where: 'id = ?', whereArgs: [id]);
  }
}
