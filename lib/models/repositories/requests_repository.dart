import 'dart:convert';
import '../entities/usuario.dart';
import '../data/external/web_service.dart';

class RequestsRepository {
  final WebService _webService;

  RequestsRepository({WebService? webService})
      : _webService = webService ?? WebService();

  Future<List<Usuario>> getRequests(String userId) async {
    final rawJson = await _webService.fetchRequests(userId);
    final List<dynamic> data = jsonDecode(rawJson);
    return data.map((json) => Usuario.fromJson(json)).toList();
  }

  Future<void> acceptRequest({
    required String currentUserId,
    required String senderUserId,
  }) => _webService.acceptRequest(currentUserId, senderUserId);

  Future<void> rejectRequest({
    required String currentUserId,
    required String senderUserId,
  }) => _webService.rejectRequest(currentUserId, senderUserId);

  Future<Usuario?> findUserByUsername(String username) async {
    final userId = await _webService.fetchUserIdByUsername(username);
    if (userId == null || userId.isEmpty) return null;

    final rawJson = await _webService.fetchUserDetail(userId);
    return Usuario.fromJson(jsonDecode(rawJson));
  }

  Future<void> sendRequest({
    required String targetUserId,
    required String senderUserId,
  }) => _webService.sendRequest(targetUserId, senderUserId);

  Future<void> trackEvent(String event, String userId) =>
      _webService.trackEvent(event, userId);
}