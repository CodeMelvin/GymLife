import 'dart:io';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> initDbFactory() async {
  if (!(Platform.isAndroid || Platform.isIOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
}
