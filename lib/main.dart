import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Gerado para o projeto Firebase correto pelo comando: flutterfire configure.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Meu Aplicativo',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F0E5),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFA64B2A),
          primary: const Color(0xFFA64B2A),
          secondary: const Color(0xFFC17B36),
          surface: const Color(0xFFF7F0E5),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF7F0E5),
          foregroundColor: Color(0xFF6B3F2A),
          centerTitle: true,
        ),
      ),
      home: const AuthGate(),
    );
  }
}
