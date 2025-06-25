class ChatMessage {
  final String sender;
  final String content;
  final DateTime timestamp;
  bool isFavorite;
  String? note; // <-- 메모 추가

  ChatMessage({
    required this.sender,
    required this.content,
    required this.timestamp,
    this.isFavorite = false,
    this.note,
  });

  @override
  String toString() {
    return '[$timestamp] $sender: $content';
  }
}
