import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../entities/usuario.dart';

const _hiveFriendsBox = 'amigos';
const _prefsLastSync = 'friends_last_synced_at';

class FriendsCache {
  Future<void> saveFriends(String userId, List<dynamic> parsedList) async {
    final box = await Hive.openBox<String>(_hiveFriendsBox);

    final minimal = parsedList.map((u) => {
      'id': u['id'] ?? '',
      'username': u['username'] ?? '',
      'foto': u['foto'] ?? '',
    }).toList();

    await box.put(userId, jsonEncode(minimal));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsLastSync,
      DateTime.now().toIso8601String(),
    );
  }

  Future<List<Usuario>?> loadFriends(String userId) async {
    final box = await Hive.openBox<String>(_hiveFriendsBox);
    final cached = box.get(userId);
    if (cached == null) return null;

    final List<dynamic> parsed = jsonDecode(cached);
    return parsed.map((json) => Usuario.fromJson(json)).toList();
  }

  Future<DateTime?> getLastSyncedAt() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsLastSync);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }
}