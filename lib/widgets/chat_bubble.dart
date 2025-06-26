import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../utils/time_formatter.dart'; // 🕓 시간 포맷 함수

class ChatBubble extends StatelessWidget {
  final String sender;
  final String message;
  final bool isMine;
  final bool isFavorite;
  final DateTime timestamp;
  final String? note;
  final String? highlight;

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

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isMine ? const Color(0xFFDCF8C6) : Colors.white;
    final textColor = Colors.black;
    final timeText = timeFormatter.format(timestamp);

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Column(
          crossAxisAlignment: isMine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (!isMine)
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 2),
                child: Text(
                  sender,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!isMine)
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: bubbleColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _buildMessageText(),
                    ),
                  ),
                if (!isMine) const SizedBox(width: 6),
                Text(
                  timeText,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                if (isMine) const SizedBox(width: 6),
                if (isMine)
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: bubbleColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _buildMessageText(),
                    ),
                  ),
              ],
            ),
            if (note != null && note!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '📝 $note',
                  style: const TextStyle(fontSize: 12, color: Colors.purple),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageText() {
    if (highlight != null && highlight!.isNotEmpty) {
      final parts = message.split(
        RegExp('(${RegExp.escape(highlight!)})', caseSensitive: false),
      );
      return RichText(
        text: TextSpan(
          children: parts.map((part) {
            final isMatch = part.toLowerCase() == highlight!.toLowerCase();
            return TextSpan(
              text: part,
              style: TextStyle(
                fontSize: 14,
                color: isMatch ? Colors.red : Colors.black,
                height: 1.3,
                fontWeight: isMatch ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      );
    } else {
      return Text(
        message,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black,
          height: 1.3, // 자간 줄이기
        ),
      );
    }
  }
}
