import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import '../models/chat_message.dart';

final _dateOnlyRegex = RegExp(r'^\d{4}년 \d{1,2}월 \d{1,2}일');
final _messageRegex =
    RegExp(r'^(\d{4}년 \d{1,2}월 \d{1,2}일 (오전|오후) \d{1,2}:\d{2}), (.+?) : (.+)$');

final List<String> myNicknames = ['회원님', '나'];
final List<String> theirNicknames = ['히', '히히', '첫사랑이름'];

Future<List<ChatMessage>> parseChatFile(String filePath) async {
  final file = File(filePath);
  final lines = await file.readAsLines(encoding: utf8);
  final List<ChatMessage> messages = [];

  for (final line in lines) {
    if (_messageRegex.hasMatch(line)) {
      final match = _messageRegex.firstMatch(line)!;
      final rawDate = match.group(1)!;
      final sender = match.group(3)!;
      final content = match.group(4)!;
      final timestamp = _parseKakaoDatetime(rawDate);

      messages.add(ChatMessage(
        sender: sender,
        content: content,
        timestamp: timestamp,
      ));
    }
  }

  return messages;
}

DateTime _parseKakaoDatetime(String rawDate) {
  final formatter = DateFormat('yyyy년 M월 d일 a h:mm', 'ko_KR');
  return formatter.parse(rawDate);
}

bool isMyMessage(String sender) => myNicknames.contains(sender);
