// lib/main.dart

import 'package:firstlove_viewer/services/memory_box_list_screen.dart';
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

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
        fontFamily: 'NotoSansKR', // ✅ 폰트 지정
        scaffoldBackgroundColor: const Color(0xFFF2F2F2), // ✅ 카톡스러운 밝은 배경
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9370DB), // 연보라 느낌
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const MemoryBoxListScreen(), // ✅ 첫 진입 화면 변경
    );
  }
}
