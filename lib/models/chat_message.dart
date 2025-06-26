class ChatMessage {
  final String sender;
  final String content;
  final DateTime timestamp;
  bool isFavorite;
  String? note;
  final String hash; // ✅ 해시 필드 추가

  ChatMessage({
    required this.sender,
    required this.content,
    required this.timestamp,
    this.isFavorite = false,
    this.note,
    required this.hash, // ✅ 생성자에도 추가
  });

  @override
  String toString() {
    return '[$timestamp] $sender: $content';
  }
}
