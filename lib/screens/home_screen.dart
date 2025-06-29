import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:firstlove_viewer/models/chat_file_metadata.dart';
import 'package:firstlove_viewer/screens/chat_search_delegate.dart';
import 'package:firstlove_viewer/services/local_storage.dart';
import 'package:flutter/material.dart';

import '../models/chat_message.dart';
import '../services/parser.dart';
import '../widgets/chat_bubble.dart';

class HomeScreen extends StatefulWidget {
  final String filePath;

  const HomeScreen({super.key, required this.filePath});
  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<ChatMessage> messages = [];
  bool showOnlyFavorites = false;
  final _scrollController = ScrollController();
  final storage = LocalStorage();
  String? highlight;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void clearHighlight() {
    setState(() {
      highlight = null;
    });
  }

  void _scrollToMessage(ChatMessage target) {
    final index = messages.indexOf(target);
    if (index != -1) {
      _scrollController.animateTo(
        index * 80.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _loadMessages() async {
    final parsed = await parseChatFile(widget.filePath);
    final favoriteMap = await storage.loadFavoriteStatuses();
    final noteMap = await storage.loadNotes();

    for (final msg in parsed) {
      msg.isFavorite = favoriteMap[msg.hash] ?? false;
      msg.note = noteMap[msg.hash] ?? '';
    }

    parsed.sort((a, b) {
      final cmp = a.timestamp.compareTo(b.timestamp);
      return cmp != 0 ? cmp : a.order.compareTo(b.order);
    });

    setState(() {
      messages = parsed;
    });

    final id = sha1.convert(utf8.encode(widget.filePath)).toString();
    await storage.upsertChatFileMetadata(
      ChatFileMetadata(
        id: id,
        name: widget.filePath.split('/').last,
        path: widget.filePath,
        lastOpened: DateTime.now(),
      ),
    );
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
      await storage.saveNote(msg.hash, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibleMessages = showOnlyFavorites
        ? messages.where((m) => m.isFavorite).toList()
        : messages;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text('카톡 대화 뷰어'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(showOnlyFavorites ? Icons.star : Icons.star_border),
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
      body: messages.isEmpty
          ? const Center(child: Text('대화를 불러오고 있습니다...'))
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: visibleMessages.length,
              controller: _scrollController,
              itemBuilder: (context, index) {
                final msg = visibleMessages[index];
                return GestureDetector(
                  onLongPress: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (_) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: Icon(
                                msg.isFavorite ? Icons.star : Icons.star_border,
                              ),
                              title: Text(
                                msg.isFavorite ? '즐겨찾기 해제' : '즐겨찾기 추가',
                              ),
                              onTap: () async {
                                Navigator.pop(context);
                                setState(() {
                                  msg.isFavorite = !msg.isFavorite;
                                });
                                await storage.saveFavoriteStatus(
                                  msg.hash,
                                  msg.isFavorite,
                                );
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.edit_note),
                              title: const Text('메모 작성'),
                              onTap: () {
                                Navigator.pop(context);
                                _showNoteDialog(msg);
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: ChatBubble(
                    sender: msg.sender,
                    message: msg.content,
                    isMine: isMyMessage(msg.sender),
                    isFavorite: msg.isFavorite,
                    timestamp: msg.timestamp,
                    note: msg.note,
                    highlight: highlight,
                  ),
                );
              },
            ),
    );
  }
}
