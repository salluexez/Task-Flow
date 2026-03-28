import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class LocalDatabaseService {
  LocalDatabaseService({
    DatabaseFactory? databaseFactoryOverride,
    this.databaseName = 'task_flow.db',
  }) : _databaseFactoryOverride = databaseFactoryOverride;

  final DatabaseFactory? _databaseFactoryOverride;
  final String databaseName;
  Database? _database;

  DatabaseFactory get databaseFactory =>
      _databaseFactoryOverride ?? _resolveFactory();

  Future<void> initialize() async {
    _database ??= await _openDatabase();
  }

  Future<Database> get database async {
    await initialize();
    return _database!;
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }

  Future<void> deleteDatabaseFile() async {
    final path = await _databasePath();
    await close();
    await databaseFactory.deleteDatabase(path);
  }

  Future<Database> _openDatabase() async {
    final path = await _databasePath();
    return databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE tasks(
              id TEXT PRIMARY KEY,
              title TEXT NOT NULL,
              description TEXT NOT NULL,
              due_date TEXT NOT NULL,
              status TEXT NOT NULL,
              blocked_by_task_id TEXT,
              created_at TEXT NOT NULL,
              updated_at TEXT NOT NULL
            )
          ''');
        },
      ),
    );
  }

  Future<String> _databasePath() async {
    final basePath = await databaseFactory.getDatabasesPath();
    return p.join(basePath, databaseName);
  }

  DatabaseFactory _resolveFactory() {
    if (kIsWeb) {
      throw UnsupportedError('Task Flow does not support web persistence.');
    }

    if (Platform.isAndroid || Platform.isIOS) {
      return sqflite.databaseFactory;
    }

    sqfliteFfiInit();
    return databaseFactoryFfi;
  }
}
