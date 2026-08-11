import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/profile_provider.dart';
import 'screens/auth/auth_screen.dart';
import 'services/db_factory.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDbFactory();
  runApp(const GymLife());
}

class GymLife extends StatelessWidget {
  const GymLife({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: MaterialApp(
        title: 'GymLife',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFF1A1F37),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4B6CB7),
            brightness: Brightness.dark,
          ),
        ),
        home: const AuthScreen(),
      ),
    );
  }
}
