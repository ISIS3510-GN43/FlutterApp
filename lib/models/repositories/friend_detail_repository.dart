import 'dart:convert';
import '../data/external/web_service.dart';

class FriendDetailRepository {
  final WebService _webService;

  FriendDetailRepository({WebService? webService})
      : _webService = webService ?? WebService();

  Future<String> getCurrentUsername(String userId) async {
    final rawJson = await _webService.fetchUserDetail(userId);
    return jsonDecode(rawJson)['username'] as String;
  }
}