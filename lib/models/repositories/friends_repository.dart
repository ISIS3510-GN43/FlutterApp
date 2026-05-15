import 'dart:isolate';
import 'dart:convert';

import '../entities/usuario.dart';
import '../data/external/web_service.dart';
import '../data/cache/friends_cache.dart';

class OfflineWithDataException implements Exception {
  final List<Usuario> cachedFriends;
  OfflineWithDataException(this.cachedFriends);
}

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

class FriendsRepository {
  final WebService _webService;
  final FriendsCache _cache;

  FriendsRepository({
    WebService? webService,
    FriendsCache? cache,
  })  : _webService = webService ?? WebService(),
        _cache = cache ?? FriendsCache();

  Future<List<dynamic>> _parseInIsolate(String rawJson) async {
    final receivePort = ReceivePort();

    await Isolate.spawn(
      _parseFriendsIsolate,
      [receivePort.sendPort, rawJson],
    );

    return await receivePort.first as List<dynamic>;
  }

  Future<List<Usuario>> getFriends(String userId) async {
    try {
      final rawJson = await _webService.fetchFriends(userId);
      final parsed = await _parseInIsolate(rawJson);

      await _cache.saveFriends(userId, parsed);

      return parsed.map((json) => Usuario.fromJson(json)).toList();
    } catch (e) {
      final isServerError = e is Exception &&
          e.toString().contains('There are no friends');

      if (isServerError) rethrow;

      final cached = await _cache.loadFriends(userId);
      if (cached != null) {
        throw OfflineWithDataException(cached);
      }

      throw Exception('No connection and no cached data available');
    }
  }

  Future<DateTime?> getLastSyncedAt() => _cache.getLastSyncedAt();
}