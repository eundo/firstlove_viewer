// lib/screens/memory_box_list_screen.dart
import 'package:firstlove_viewer/screens/home_screen.dart';
import 'package:flutter/material.dart';
import '../models/chat_file_metadata.dart';
import '../services/local_storage.dart';

class MemoryBoxListScreen extends StatefulWidget {
  const MemoryBoxListScreen({super.key});

  @override
  State<MemoryBoxListScreen> createState() => _MemoryBoxListScreenState();
}

class _MemoryBoxListScreenState extends State<MemoryBoxListScreen> {
  List<ChatFileMetadata> memoryBoxes = [];

  @override
  void initState() {
    super.initState();
    _loadMemoryBoxes();
  }

  Future<void> _loadMemoryBoxes() async {
    final loaded = await LocalStorage().loadChatFileMetadataList();
    setState(() {
      memoryBoxes = loaded;
    });
  }

  void _openMemoryBox(ChatFileMetadata box) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(filePath: box.path),
      ),
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
                final box = memoryBoxes[index];
                return ListTile(
                  title: Text(box.name),
                  subtitle: Text('최근 열람: ${box.lastOpened}'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _openMemoryBox(box),
                );
              },
            ),
    );
  }
}
