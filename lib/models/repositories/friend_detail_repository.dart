import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/constants.dart';

class FriendDetailRepository {
  Future<String> getCurrentUsername(String userId) async {
    final response = await http.get(
      Uri.parse('${Config.baseUrl}/usuarios/$userId'),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['username'] as String;
    }
    throw Exception('Could not fetch user data.');
  }
}