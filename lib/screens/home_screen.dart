import 'package:file_picker/file_picker.dart';
import 'package:firstlove_viewer/screens/chat_search_delegate.dart';
import 'package:firstlove_viewer/services/local_storage.dart';
import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/parser.dart';
import '../widgets/chat_bubble.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState  extends State<HomeScreen> {
  List<ChatMessage> messages = [];
  bool showOnlyFavorites = false;
  final _scrollController = ScrollController();
  final storage = LocalStorage();

  String? highlight; // ✅ 검색어 하이라이트 용

  void clearHighlight() {
    setState(() {
      highlight = null;
    });
  }


  void _scrollToMessage(ChatMessage target) { 
      final index = messages.indexOf(target);
      if (index != -1) {
        _scrollController.animateTo(
          index * 80.0, // 메시지 높이 대략값 (필요시 조정)
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }

  Future<void> _addChatFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );

    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;
      print('📂 선택된 파일 경로: $filePath');

      final newMessages = await parseChatFile(filePath);
      print('🪄 파싱된 메시지 수: ${newMessages.length}');

      // ✅ 저장된 상태 불러오기
      final favoriteMap = await storage.loadFavoriteStatuses();
      final noteMap = await storage.loadNotes();

      for (final msg in newMessages) {
        msg.isFavorite = favoriteMap[msg.hash] ?? false;
        msg.note = noteMap[msg.hash] ?? '';
      }

      setState(() {
        messages.addAll(newMessages);
        messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        print('📌 누적 메시지 수: ${messages.length}');
      });
    } else {
      print('🚫 파일 선택 취소됨 또는 경로 없음');
    }
  }


  void _showNoteDialog(ChatMessage msg) async {
    final controller = TextEditingController(text: msg.note ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('메모'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(hintText: '메모를 입력하세요'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('저장'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        msg.note = result;
      });
      final storage = LocalStorage();
      await storage.saveNote(msg.hash, result);
    }
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
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final result = await showSearch<ChatMessage?>(
                context: context,
                delegate: ChatSearchDelegate(messages),
              );
              if (result != null) {
                _scrollToMessage(result);
              }
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
                        onLongPress: () async {
                          setState(() {
                            msg.isFavorite = !msg.isFavorite;
                          });

                          final storage = LocalStorage();
                          await storage.saveFavoriteStatus(msg.hash, msg.isFavorite);
                          _showNoteDialog(msg); // ✏️ 메모 다이얼로그
                        },
                        child: ChatBubble(
                          sender: msg.sender,
                          message: msg.content,
                          isMine: isMyMessage(msg.sender),
                          isFavorite: msg.isFavorite,
                          timestamp: msg.timestamp, // ✅ 이 줄 꼭 추가
                          note: msg.note,
                            highlight: highlight, // ✅ 요 줄 추가
                        ),
                      );
                    },
                    controller: _scrollController,
                  ),
          ),
        ],
      ),
    );
  }
}
