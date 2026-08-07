import 'package:flutter_test/flutter_test.dart';
import 'package:gymlife/providers/auth_provider.dart';
import 'package:gymlife/services/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    DatabaseHelper.debugOverridePath = inMemoryDatabasePath;
  });

  tearDown(() async {
    await DatabaseHelper.instance.close();
  });

  group('DatabaseHelper', () {
    test('seeds the demo account on first run', () async {
      final db = await DatabaseHelper.instance.database;
      final rows = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: ['user@demo.com'],
      );
      expect(rows, hasLength(1));
      final user = rows.first;
      expect(user['name'], 'Demo User');
      expect(user['password_hash'], isNot('user123'));
      expect(user['salt'], isNotEmpty);
    });

    test('password hashes are salted and unique', () {
      const password = 'user123';
      final saltA = DatabaseHelper.generateSalt();
      final saltB = DatabaseHelper.generateSalt();
      expect(DatabaseHelper.hashPassword(password, saltA), isNot(saltA));
      expect(
        DatabaseHelper.hashPassword(password, saltA),
        isNot(DatabaseHelper.hashPassword(password, saltB)),
      );
    });
  });

  group('AuthProvider', () {
    test('register stores a hashed password and can login', () async {
      final auth = AuthProvider();

      await auth.register(
        name: 'Budi',
        email: 'budi@mail.com',
        password: 'secret123',
      );
      expect(auth.errorMessage, isNull);

      final db = await DatabaseHelper.instance.database;
      final rows = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: ['budi@mail.com'],
      );
      expect(rows, hasLength(1));
      expect(rows.first['password_hash'], isNot('secret123'));

      await auth.login(email: 'budi@mail.com', password: 'secret123');
      expect(auth.errorMessage, isNull);
      expect(auth.isLoggedIn, isTrue);
      expect(auth.currentUserName, 'Budi');
    });

    test('register rejects duplicate emails', () async {
      final auth = AuthProvider();

      await auth.register(
        name: 'A',
        email: 'dup@mail.com',
        password: 'aaaa',
      );
      await auth.register(
        name: 'B',
        email: 'dup@mail.com',
        password: 'bbbb',
      );
      expect(auth.errorMessage, 'Email already registered.');
    });

    test('login fails on wrong password', () async {
      final auth = AuthProvider();

      await auth.login(email: 'user@demo.com', password: 'wrong-password');
      expect(auth.errorMessage, 'Email or password wrong.');
      expect(auth.isLoggedIn, isFalse);
    });

    test('login succeeds with the seeded demo account', () async {
      final auth = AuthProvider();

      await auth.login(email: 'user@demo.com', password: 'user123');
      expect(auth.errorMessage, isNull);
      expect(auth.isLoggedIn, isTrue);
      expect(auth.currentUserName, 'Demo User');
    });

    test('changePassword requires the correct old password', () async {
      final auth = AuthProvider();

      await auth.changePassword(
        email: 'user@demo.com',
        oldPassword: 'nope',
        newPassword: 'newpass123',
      );
      expect(auth.errorMessage, 'Wrong password.');

      await auth.changePassword(
        email: 'user@demo.com',
        oldPassword: 'user123',
        newPassword: 'newpass123',
      );
      expect(auth.errorMessage, isNull);

      await auth.login(email: 'user@demo.com', password: 'newpass123');
      expect(auth.errorMessage, isNull);
      expect(auth.isLoggedIn, isTrue);
    });

    test('resetPassword reports unknown emails', () async {
      final auth = AuthProvider();

      await auth.resetPassword('ghost@mail.com');
      expect(auth.errorMessage, 'Email not found.');

      await auth.resetPassword('user@demo.com');
      expect(auth.errorMessage, isNull);
    });
  });
}
