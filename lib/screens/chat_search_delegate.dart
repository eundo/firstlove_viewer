import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../screens/home_screen.dart'; // 또는 정확한 경로

class ChatSearchDelegate extends SearchDelegate<ChatMessage?> {
  final List<ChatMessage> messages;

  ChatSearchDelegate(this.messages);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));
  }

  @override
  void close(BuildContext context, ChatMessage? result) {
    // 🔁 검색 종료 시 highlight 초기화
    if (context is StatefulElement && context.state is HomeScreenState) {
      final state = context.state as HomeScreenState;
      state.clearHighlight();
    }
    super.close(context, result);
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = messages
        .where((m) => m.content.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final msg = results[index];
        return ListTile(
          title: Text(msg.content),
          subtitle: Text('${msg.sender} • ${msg.timestamp}'),
          onTap: () => close(context, msg),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }
}
