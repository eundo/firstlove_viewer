import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../models/chat_message.dart';


class ChatBubble extends StatelessWidget {
  final String sender;
  final String message;
  final bool isMine;
  final bool isFavorite;
  final String? note;
  final DateTime timestamp;
  final String? highlight; // nullable

  const ChatBubble({
    super.key,
    required this.sender,
    required this.message,
    required this.isMine,
    required this.isFavorite,
    required this.timestamp,
    this.note,
    this.highlight,
  });



String _formatTime(DateTime dt) {
  final hour = dt.hour.toString().padLeft(2, '0');
  final minute = dt.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}


List<TextSpan> _buildHighlightedText(String text, String keyword) {
  final spans = <TextSpan>[];
  final lowerText = text.toLowerCase();
  final lowerKeyword = keyword.toLowerCase();

  int start = 0;
  int index;

  while ((index = lowerText.indexOf(lowerKeyword, start)) != -1) {
    if (index > start) {
      spans.add(TextSpan(text: text.substring(start, index)));
    }

    spans.add(TextSpan(
      text: text.substring(index, index + keyword.length),
      style: const TextStyle(backgroundColor: Colors.yellow),
    ));

    start = index + keyword.length;
  }

  if (start < text.length) {
    spans.add(TextSpan(text: text.substring(start)));
  }

  return spans;
}

// String _formatTime(DateTime ts) {
//   final formatter = DateFormat('yyyy.MM.dd HH:mm');
//   return formatter.format(ts);
// }


  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMine ? Colors.blue[100] : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment:
              isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            highlight != null && highlight!.isNotEmpty
              ? RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 16,
                      color: isMine ? Colors.white : Colors.black,
                    ),
                    children: _buildHighlightedText(message, highlight!),
                  ),
                )
              : Text(
                  message,
                  style: TextStyle(
                    fontSize: 16,
                    color: isMine ? Colors.white : Colors.black,
                  ),
                )
                , // <- ✅ 이 줄 추가
            const SizedBox(height: 4),
            Text(
              '$sender • ${_formatTime(timestamp)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            if (note != null && note!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  '💬 $note',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
