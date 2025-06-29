import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

import '../../models/chat_file_metadata.dart';
import '../../screens/home_screen.dart';
import '../../services/local_storage.dart';

class MemoryBoxListScreen extends StatefulWidget {
  const MemoryBoxListScreen({super.key});

  @override
  State<MemoryBoxListScreen> createState() => _MemoryBoxListScreenState();
}

class _MemoryBoxListScreenState extends State<MemoryBoxListScreen> {
  final storage = LocalStorage();
  List<ChatFileMetadata> memoryBoxes = [];

  @override
  void initState() {
    super.initState();
    _loadMemoryBoxes();
  }

  Future<void> _loadMemoryBoxes() async {
    final saved = await storage.getSavedChatFiles();
    setState(() {
      memoryBoxes = saved;
    });
  }

  Future<void> _addNewChatFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );

    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;
      final id = sha1.convert(utf8.encode(filePath)).toString();
      final metadata = ChatFileMetadata(
        id: id,
        name: filePath.split('/').last,
        path: filePath,
        lastOpened: DateTime.now(),
      );

      await storage.upsertChatFileMetadata(metadata);
      _loadMemoryBoxes();

      // ✅ 바로 해당 대화 화면으로 이동
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(filePath: filePath)),
      );
    }
  }

  void _openChat(ChatFileMetadata file) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen(filePath: file.path)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('기억상자 목록')),
      body: memoryBoxes.isEmpty
          ? const Center(child: Text('불러온 대화가 없습니다.'))
          : ListView.builder(
              itemCount: memoryBoxes.length,
              itemBuilder: (context, index) {
                final file = memoryBoxes[index];
                return ListTile(
                  title: Text(file.name),
                  subtitle: Text('마지막 열람: ${file.lastOpened.toLocal()}'),
                  onTap: () => _openChat(file),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewChatFile,
        child: const Icon(Icons.add),
        tooltip: '새 대화 추가',
      ),
    );
  }
}
