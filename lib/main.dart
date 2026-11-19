import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/login_screen.dart';

void main() async {
  // Memastikan inisialisasi Flutter engine selesai sebelum operasi async
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Hive database lokal
  await Hive.initFlutter();

  // Membuka box 'favorites' untuk menyimpan resep yang disukai
  await Hive.openBox('favorites');

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Resep Masakan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00B050)),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
