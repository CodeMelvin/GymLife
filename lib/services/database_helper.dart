import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static const _dbName = 'gymlife.db';
  static const _dbVersion = 1;
  static String? debugOverridePath;

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final path = debugOverridePath ?? join(await getDatabasesPath(), _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        salt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE profiles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL DEFAULT '',
        description TEXT NOT NULL DEFAULT '',
        gender TEXT NOT NULL DEFAULT '',
        image_path TEXT NOT NULL DEFAULT '',
        membership_name TEXT NOT NULL DEFAULT '',
        membership_end_date TEXT NOT NULL DEFAULT ''
      )
    ''');

    await db.execute('''
      CREATE TABLE cart (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_email TEXT NOT NULL,
        membership_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        price INTEGER NOT NULL,
        image TEXT NOT NULL,
        benefits TEXT NOT NULL,
        payment_method TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'In Cart'
      )
    ''');

    await _seedDemoAccount(db);
  }

  Future<void> _seedDemoAccount(Database db) async {
    const email = 'user@demo.com';
    const password = 'user123';
    final salt = generateSalt();
    final existing = await db.query('users', where: 'email = ?', whereArgs: [email]);
    if (existing.isEmpty) {
      await db.insert('users', {
        'name': 'Demo User',
        'email': email,
        'password_hash': hashPassword(password, salt),
        'salt': salt,
      });
      await db.insert('profiles', {
        'email': email,
        'name': 'Demo User',
      });
    }
  }

  static String generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return sha256.convert(bytes).toString().substring(0, 16);
  }

  static String hashPassword(String password, String salt) {
    return sha256.convert(utf8.encode('$salt:$password')).toString();
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
