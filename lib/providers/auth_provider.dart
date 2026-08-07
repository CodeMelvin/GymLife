import 'package:flutter/foundation.dart';

import '../services/database_helper.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({DatabaseHelper? helper}) : _helper = helper ?? DatabaseHelper.instance;

  final DatabaseHelper _helper;

  bool _isLoggedIn = false;
  String? _currentEmail;
  String? _currentUserName;
  String? _errorMessage;

  bool get isLoggedIn => _isLoggedIn;
  String? get currentEmail => _currentEmail;
  String? get currentUserName => _currentUserName;
  String? get errorMessage => _errorMessage;

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _errorMessage = null;
    final db = await _helper.database;

    final existing = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (existing.isNotEmpty) {
      _errorMessage = 'Email already registered.';
      notifyListeners();
      return;
    }

    final salt = DatabaseHelper.generateSalt();
    await db.insert('users', {
      'name': name,
      'email': email,
      'password_hash': DatabaseHelper.hashPassword(password, salt),
      'salt': salt,
    });
    await db.insert('profiles', {
      'email': email,
      'name': name,
    });

    _errorMessage = null;
    notifyListeners();
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    _errorMessage = null;
    final db = await _helper.database;

    final rows = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (rows.isEmpty) {
      _errorMessage = 'Email or password wrong.';
      notifyListeners();
      return;
    }

    final user = rows.first;
    final salt = user['salt'] as String;
    final hash = user['password_hash'] as String;
    final inputHash = DatabaseHelper.hashPassword(password, salt);

    if (hash != inputHash) {
      _errorMessage = 'Email or password wrong.';
      notifyListeners();
      return;
    }

    _isLoggedIn = true;
    _currentEmail = email;
    _currentUserName = user['name'] as String;
    notifyListeners();
  }

  Future<bool> emailExists(String email) async {
    final db = await _helper.database;
    final rows = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return rows.isNotEmpty;
  }

  Future<void> resetPassword(String email) async {
    _errorMessage = null;
    final exists = await emailExists(email);
    if (!exists) {
      _errorMessage = 'Email not found.';
      notifyListeners();
      return;
    }
    notifyListeners();
  }

  Future<void> changePassword({
    required String email,
    required String oldPassword,
    required String newPassword,
  }) async {
    _errorMessage = null;
    final db = await _helper.database;

    final rows = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (rows.isEmpty) {
      _errorMessage = 'Email not found.';
      notifyListeners();
      return;
    }

    final user = rows.first;
    final salt = user['salt'] as String;
    final hash = user['password_hash'] as String;
    final oldHash = DatabaseHelper.hashPassword(oldPassword, salt);

    if (hash != oldHash) {
      _errorMessage = 'Wrong password.';
      notifyListeners();
      return;
    }

    final newSalt = DatabaseHelper.generateSalt();
    await db.update(
      'users',
      {
        'password_hash': DatabaseHelper.hashPassword(newPassword, newSalt),
        'salt': newSalt,
      },
      where: 'email = ?',
      whereArgs: [email],
    );

    _errorMessage = null;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _currentEmail = null;
    _currentUserName = null;
    _errorMessage = null;
    notifyListeners();
  }
}
