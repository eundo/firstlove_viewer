import 'package:shared_preferences/shared_preferences.dart';

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
}
