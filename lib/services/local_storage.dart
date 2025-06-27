import 'dart:convert';

import 'package:firstlove_viewer/models/chat_file_metadata.dart';
import 'package:shared_preferences/shared_preferences.dart';
const _metadataKey = 'chat_file_metadata';
class LocalStorage {
  // ===== 🎯 즐겨찾기 관련 =====

  /// 메시지 단일 즐겨찾기 저장
  Future<void> saveFavoriteStatus(String hash, bool isFavorite) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('favorite_$hash', isFavorite);
  }

  /// 메시지 단일 즐겨찾기 불러오기
  Future<bool> loadFavorite(String hash) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('favorite_$hash') ?? false;
  }

  /// 모든 즐겨찾기 로딩 (해시 → bool Map)
  Future<Map<String, bool>> loadFavoriteStatuses() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final result = <String, bool>{};

    for (final key in keys) {
      if (key.startsWith('favorite_')) {
        final hash = key.substring('favorite_'.length);
        result[hash] = prefs.getBool(key) ?? false;
      }
    }

    return result;
  }

  // ===== 📝 메모 관련 =====

  /// 메시지 단일 메모 저장
  Future<void> saveNote(String hash, String note) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('note_$hash', note);
  }

  /// 메시지 단일 메모 불러오기
  Future<String?> loadNote(String hash) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('note_$hash');
  }

  /// 모든 메모 로딩 (해시 → note Map)
  Future<Map<String, String>> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final result = <String, String>{};

    for (final key in keys) {
      if (key.startsWith('note_')) {
        final hash = key.substring('note_'.length);
        result[hash] = prefs.getString(key) ?? '';
      }
    }

    return result;
  }

  // local_storage.dart 내 추가
  Future<void> saveChatFileMetadataList(List<ChatFileMetadata> list) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = list.map((e) => e.toJson()).toList();
    prefs.setString('chat_file_metadata_list', jsonEncode(jsonList));
  }

  Future<List<ChatFileMetadata>> loadChatFileMetadataList() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('chat_file_metadata_list');
    if (raw == null) return [];
    final jsonList = jsonDecode(raw) as List;
    return jsonList.map((e) => ChatFileMetadata.fromJson(e)).toList();
  }


Future<void> upsertChatFileMetadata(ChatFileMetadata newItem) async {
  final prefs = await SharedPreferences.getInstance();
  final existingList = await loadChatFileMetadataList();

  final updatedList = [
    ...existingList.where((item) => item.path != newItem.path),
    newItem,
  ];

  final jsonString = jsonEncode(updatedList.map((e) => e.toJson()).toList());
  await prefs.setString('chat_files', jsonString);
}

Future<List<ChatFileMetadata>> getSavedChatFiles() async {
  final prefs = await SharedPreferences.getInstance();
  final jsonString = prefs.getString(_metadataKey);
  if (jsonString == null) return [];

  final List<dynamic> jsonList = json.decode(jsonString);
  return jsonList
      .map((item) => ChatFileMetadata.fromJson(item as Map<String, dynamic>))
      .toList();
}


Future<void> _saveMetadataList(List<ChatFileMetadata> list) async {
  final prefs = await SharedPreferences.getInstance();
  final jsonString = json.encode(list.map((e) => e.toJson()).toList());
  await prefs.setString(_metadataKey, jsonString);
}

Future<void> updateLastOpened(String id) async {
  final metadataList = await getSavedChatFiles();
  final index = metadataList.indexWhere((item) => item.id == id);

  if (index != -1) {
    final updated = ChatFileMetadata(
      id: metadataList[index].id,
      name: metadataList[index].name,
      path: metadataList[index].path,
      lastOpened:  DateTime.now(), // ✅ 여기!
    );

    metadataList[index] = updated;
    await _saveMetadataList(metadataList);
  }
}


}
