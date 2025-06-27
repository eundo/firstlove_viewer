class ChatFileMetadata {
  final String id;
  final String name;
  final String path;
  DateTime lastOpened; // ← ✅ 변경: String → DateTime

  ChatFileMetadata({
    required this.id,
    required this.name,
    required this.path,
    required this.lastOpened,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'path': path,
        'lastOpened': lastOpened.toIso8601String(), // ✅ DateTime → String 저장
      };

  factory ChatFileMetadata.fromJson(Map<String, dynamic> json) =>
      ChatFileMetadata(
        id: json['id'],
        name: json['name'],
        path: json['path'],
        lastOpened: DateTime.parse(json['lastOpened']), // ✅ String → DateTime 복원
      );
}
