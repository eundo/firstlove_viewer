class ChatMessage {
  final String sender;
  final String content;
  final DateTime timestamp;
  final String hash;
  bool isFavorite;
  String? note;

  final int order; // ✅ 추가

  ChatMessage({
    required this.sender,
    required this.content,
    required this.timestamp,
    required this.hash,
    this.isFavorite = false,
    this.note,
    required this.order, // ✅ 추가
  });
}
