// lib/main.dart

import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'package:intl/date_symbol_data_local.dart'; // 👈 이거 추가

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 👈 필수
  await initializeDateFormatting('ko_KR', null); // 👈 이 줄이 핵심
  runApp(const FirstLoveViewerApp());
}

class FirstLoveViewerApp extends StatelessWidget {
  const FirstLoveViewerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FirstLove Viewer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
