import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../config/constants.dart';
import '../usuario.dart';

class FriendsRepository {
  Future<List<Usuario>> getFriends(String userId) async {
    final response = await http.get(
      Uri.parse('${Config.baseUrl}/usuarios/$userId/amigos'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Usuario.fromJson(json)).toList();
    } else {
      throw Exception('There are no friends to display');
    }
  }
}