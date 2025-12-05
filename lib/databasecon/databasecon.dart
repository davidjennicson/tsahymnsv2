import 'dart:io';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseCon {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase('dtb.db');
    return _database!;
  }

  static Future<Database> _initDatabase(String dbName) async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, dbName);

    // Check if database exists in the filesystem
    var exists = await databaseExists(path);

    if (!exists) {
      // Database doesn't exist - create it
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      // Try to load from assets first
      try {
        ByteData data = await rootBundle.load('assets/$dbName');
        List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await File(path).writeAsBytes(bytes, flush: true);
        exists = true;
      } catch (e) {
        // If no asset database exists, create a new empty database
        //print('No asset database found, creating new database: $e');
      }
    }

    // Open the database
    final database = await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );

    // Ensure app_settings table exists
    await _ensureAppSettingsTable(database);

    return database;
  }

  static Future<void> _createDatabase(Database db, int version) async {
    // Create app_settings table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS app_settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        key TEXT UNIQUE NOT NULL,
        value TEXT NOT NULL
      )
    ''');

    // You can add other tables here that should exist in a new database
    //print('Database created with version $version');
  }

  static Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here if needed
    //print('Upgrading database from version $oldVersion to $newVersion');

    if (oldVersion < 1) {
      // Upgrade from version 0 to 1
      await _ensureAppSettingsTable(db);
    }
  }

  static Future<void> _ensureAppSettingsTable(Database db) async {
    // Check if app_settings table exists
    final List<Map<String, dynamic>> tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='app_settings'"
    );

    if (tables.isEmpty) {
      // Create the app_settings table if it doesn't exist
      await db.execute('''
        CREATE TABLE app_settings (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          key TEXT UNIQUE NOT NULL,
          value TEXT NOT NULL
        )
      ''');
      //print('app_settings table created');
    } else {
      //print('app_settings table already exists');
    }
  }

  // Helper method to initialize database (call this in main())
  static Future<void> initDatabase() async {
    await database;
  }

  // Close the database connection
  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  // Get database path for debugging
  static Future<String> getDatabasePath() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    return join(documentsDirectory.path, 'dtb.db');
  }

  // Check if database file exists
  static Future<bool> databaseFileExists() async {
    final path = await getDatabasePath();
    return await databaseExists(path);
  }

  // Delete database (for testing/reset)
  static Future<void> deleteDatabase(String path) async {
    final path = await getDatabasePath();
    await deleteDatabase(path);
    _database = null;
  }
}

