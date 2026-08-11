import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../services/database_helper.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider({DatabaseHelper? helper})
      : _helper = helper ?? DatabaseHelper.instance;

  final DatabaseHelper _helper;

  String _currentEmail = '';

  String _name = '';
  String _description = '';
  String _gender = '';
  String _imagePath = '';
  String _membershipName = '';
  String _membershipEndDate = '';

  String get name => _name;
  String get email => _currentEmail;
  String get description => _description;
  String get gender => _gender;
  String get membershipName => _membershipName;
  DateTime? get membershipEndDate {
    if (_membershipEndDate.isEmpty) return null;
    return DateTime.tryParse(_membershipEndDate);
  }

  Uint8List? get imageBytes {
    if (_imagePath.isEmpty) return null;
    return base64Decode(_imagePath);
  }

  Future<void> setActiveUser(String email, String name) async {
    _currentEmail = email;
    _name = name;
    await _loadProfile();
    notifyListeners();
  }

  Future<void> _loadProfile() async {
    final db = await _helper.database;
    final rows = await db.query(
      'profiles',
      where: 'email = ?',
      whereArgs: [_currentEmail],
    );
    if (rows.isEmpty) {
      await db.insert('profiles', {
        'email': _currentEmail,
        'name': _name,
      });
      return;
    }
    final row = rows.first;
    _name = row['name'] as String? ?? _name;
    _description = row['description'] as String? ?? '';
    _gender = row['gender'] as String? ?? '';
    _imagePath = row['image_path'] as String? ?? '';
    _membershipName = row['membership_name'] as String? ?? '';
    _membershipEndDate = row['membership_end_date'] as String? ?? '';
  }

  Future<void> _update({required Map<String, Object?> values}) async {
    final db = await _helper.database;
    await db.update(
      'profiles',
      values,
      where: 'email = ?',
      whereArgs: [_currentEmail],
    );
  }

  Future<void> updateName(String newName) async {
    _name = newName;
    await _update(values: {'name': newName});
    notifyListeners();
  }

  Future<void> updateDescription(String newDesc) async {
    _description = newDesc;
    await _update(values: {'description': newDesc});
    notifyListeners();
  }

  Future<void> updateGender(String newGender) async {
    _gender = newGender;
    await _update(values: {'gender': newGender});
    notifyListeners();
  }

  Future<void> updateProfileImage(Uint8List bytes) async {
    _imagePath = base64Encode(bytes);
    await _update(values: {'image_path': _imagePath});
    notifyListeners();
  }

  Future<void> setMembership(String name, DateTime endDate) async {
    _membershipName = name;
    _membershipEndDate = endDate.toIso8601String();
    await _update(values: {
      'membership_name': _membershipName,
      'membership_end_date': _membershipEndDate,
    });
    notifyListeners();
  }

  Future<void> clearMembership() async {
    _membershipName = '';
    _membershipEndDate = '';
    await _update(values: {
      'membership_name': _membershipName,
      'membership_end_date': _membershipEndDate,
    });
    notifyListeners();
  }

  Future<void> logoutProfileKeepData() async {
    _currentEmail = '';
    _name = '';
    _description = '';
    _gender = '';
    _imagePath = '';
    _membershipName = '';
    _membershipEndDate = '';
    notifyListeners();
  }
}
