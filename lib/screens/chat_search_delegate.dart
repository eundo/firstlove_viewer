import 'package:flutter/material.dart';
import '../models/chat_message.dart';

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
