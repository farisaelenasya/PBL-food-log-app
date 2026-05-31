import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/login_page.dart';
import 'pages/intro_screen_page.dart';
import 'services/notification_service.dart';
import 'database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: "assets/env/.env");

  if (!kIsWeb) {
    await DatabaseHelper.instance.database;
  }

  await NotificationService().init();

  // Cek apakah user sudah pernah lihat intro
  final prefs = await SharedPreferences.getInstance();
  final sudahLihatIntro = prefs.getBool('sudahLihatIntro') ?? false;

  runApp(AplikasiKu(tampilkanIntro: !sudahLihatIntro));
}

class AplikasiKu extends StatelessWidget {
  final bool tampilkanIntro;
  const AplikasiKu({super.key, required this.tampilkanIntro});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'food log app',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2979FF),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Poppins',
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF1A1A2E),
        ),
      ),
      // Tampilkan IntroScreen hanya jika belum pernah lihat
      home: tampilkanIntro ? const IntroScreen() : const LoginPage(),
    );
  }
}