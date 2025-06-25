import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/parser.dart';
import '../widgets/chat_bubble.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatMessage> messages = [];
  bool showOnlyFavorites = false;

  Future<void> _addChatFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );

    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;
      print("📂 선택된 파일 경로: $filePath");

      final newMessages = await parseChatFile(filePath);
      print("📦 파싱된 메시지 수: ${newMessages.length}");

      setState(() {
        messages.addAll(newMessages);
        messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        print("🧠 누적 메시지 수: ${messages.length}");
      });
    } else {
      print("🚫 파일 선택 취소됨 또는 경로 없음");
    }
  }

  void _showNoteDialog(ChatMessage msg) {
    final controller = TextEditingController(text: msg.note ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('메모 추가'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: '이 대화에 남기고 싶은 말'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                msg.note = controller.text;
              });
              Navigator.pop(context);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleMessages = showOnlyFavorites
        ? messages.where((m) => m.isFavorite).toList()
        : messages;
    return Scaffold(
      appBar: AppBar(
        title: const Text('카톡 대화 뷰어'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              showOnlyFavorites ? Icons.star : Icons.star_border,
            ),
            tooltip: showOnlyFavorites ? '전체 보기' : '즐겨찾기만 보기',
            onPressed: () {
              setState(() {
                showOnlyFavorites = !showOnlyFavorites;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _addChatFile,
            child: const Text('대화 파일 추가하기'),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: messages.isEmpty
                ? const Center(child: Text('대화를 불러오세요!'))
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: visibleMessages.length,
                    itemBuilder: (context, index) {
                      final msg = visibleMessages[index];
                      return GestureDetector(
                        onLongPress: () => _showNoteDialog(msg),
                        child: ChatBubble(
                          sender: msg.sender,
                          message: msg.content,
                          isMine: isMyMessage(msg.sender),
                          isFavorite: msg.isFavorite,
                          onFavoriteToggle: () {
                            setState(() {
                              msg.isFavorite = !msg.isFavorite;
                            });
                          },
                          note: msg.note,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
