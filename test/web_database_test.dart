@TestOn('browser')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:gymlife/providers/auth_provider.dart';
import 'package:gymlife/services/database_helper.dart';
import 'package:gymlife/services/db_factory.dart';

void main() {
  setUp(() async {
    await initDbFactory();
  });

  tearDown(() async {
    await DatabaseHelper.instance.close();
  });

  test('seeds the demo account and login works on web', () async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: ['user@demo.com'],
    );
    expect(rows, hasLength(1));

    final auth = AuthProvider();
    await auth.login(email: 'user@demo.com', password: 'user123');
    expect(auth.errorMessage, isNull);
    expect(auth.isLoggedIn, isTrue);
  });
}
