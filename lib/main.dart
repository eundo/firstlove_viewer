// lib/main.dart

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/memory_box_list_screen.dart'; // 💡 MemoryBoxListScreen이 위치한 곳

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null);
  runApp(const FirstLoveViewerApp());
}

class FirstLoveViewerApp extends StatelessWidget {
  const FirstLoveViewerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FirstLove Viewer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'NotoSansKR',
        scaffoldBackgroundColor: const Color(0xFFF2F2F2), // 💛 카카오톡 느낌 배경
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9370DB), // 연보라 계열
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const MemoryBoxListScreen(), // ✅ 시작화면으로 메모리 박스 목록
    );
  }
}
