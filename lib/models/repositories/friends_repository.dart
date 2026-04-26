import 'dart:convert';
import 'dart:isolate';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
 
import '../../config/constants.dart';
import '../usuario.dart';

void _parseFriendsIsolate(List<Object> args) {
  final sendPort = args[0] as SendPort;
  final rawJson = args[1] as String;
 
  try {
    final List<dynamic> data = jsonDecode(rawJson);
    sendPort.send(data);
  } catch (e) {
    sendPort.send(<dynamic>[]);
  }
}

const _hiveFriendsBox = 'amigos';
const _prefsLastSync = 'friends_last_synced_at';

class OfflineWithDataException implements Exception {
  final List<Usuario> cachedFriends;
  OfflineWithDataException(this.cachedFriends);
}

class FriendsRepository {

  Future<List<dynamic>> _parseInIsolate(String rawJson) async {
    final receivePort = ReceivePort();
 
    await Isolate.spawn(
      _parseFriendsIsolate,
      [receivePort.sendPort, rawJson],
    );
 
    final result = await receivePort.first as List<dynamic>;
    return result;
  }

  Future<void> _saveToCache(String userId, String rawJson) async {
    final box = await Hive.openBox<String>(_hiveFriendsBox);

    final List<dynamic> full = jsonDecode(rawJson);
    final minimal = full.map((u) => {
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

  Future<List<Usuario>?> _loadFromCache(String userId) async {
    final box = await Hive.openBox<String>(_hiveFriendsBox);
    final cached = box.get(userId);
 
    if (cached == null) return null;
 
    final parsed = await _parseInIsolate(cached);
    return parsed.map((json) => Usuario.fromJson(json)).toList();
  }

  Future<DateTime?> getLastSyncedAt() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsLastSync);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  Future<List<Usuario>> getFriends(String userId) async {
    try {
      final response = await http
          .get(
            Uri.parse('${Config.baseUrl}/usuarios/$userId/amigos'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));
 
      if (response.statusCode == 200) {
        await _saveToCache(userId, response.body);
 
        final parsed = await _parseInIsolate(response.body);
        return parsed.map((json) => Usuario.fromJson(json)).toList();
      } else {
        throw Exception('There are no friends to display');
      }
    } catch (e) {
      final isServerError = e is Exception &&
          e.toString().contains('There are no friends');
      
      if (isServerError) rethrow; 
      
      final cached = await _loadFromCache(userId);
      if (cached != null) {
        throw OfflineWithDataException(cached);
      }
      throw Exception('No connection and no cached data available');
    }
  }
}