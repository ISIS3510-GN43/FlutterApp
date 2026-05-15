import 'dart:convert';

import 'package:http/http.dart' as http;
import '/../../config/constants.dart';

class WebService {
  Future<String> fetchFriends(String userId) async {
    final response = await http
        .get(
          Uri.parse('${Config.baseUrl}/usuarios/$userId/amigos'),
          headers: {'Content-Type': 'application/json'},
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('There are no friends to display');
    }
  }

  Future<String> fetchUserDetail(String userId) async {
    final response = await http.get(
      Uri.parse('${Config.baseUrl}/usuarios/$userId'),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return response.body;
    }
    throw Exception('Could not fetch user data.');
  }

  Future<String> fetchRequests(String userId) async {
    final response = await http.get(
      Uri.parse('${Config.baseUrl}/usuarios/$userId/solicitudes'),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) return response.body;
    throw Exception('The requests could not be obtained.');
  }

  Future<void> acceptRequest(String currentUserId, String senderUserId) async {
    final response = await http.post(
      Uri.parse('${Config.baseUrl}/usuarios/$currentUserId/solicitudes/$senderUserId/aceptar'),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message'] ?? 'The friend request could not be accepted.');
    }
  }

  Future<void> rejectRequest(String currentUserId, String senderUserId) async {
    final response = await http.post(
      Uri.parse('${Config.baseUrl}/usuarios/$currentUserId/rechazarsolicitud/$senderUserId'),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message'] ?? 'The friend request could not be rejected.');
    }
  }

  Future<String?> fetchUserIdByUsername(String username) async {
    final response = await http.get(
      Uri.parse('${Config.baseUrl}/usuarios/codigo/username/$username'),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final body = response.body.trim();
      if (body.isEmpty || body == 'null') return null;
      return body.replaceAll('"', '');
    } else if (response.statusCode == 404) {
      return null;
    }
    throw Exception(jsonDecode(response.body)['message'] ?? 'The user could not be found.');
  }

  Future<void> sendRequest(String targetUserId, String senderUserId) async {
    final response = await http.post(
      Uri.parse('${Config.baseUrl}/usuarios/$targetUserId/solicitudes/$senderUserId'),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message'] ?? 'The friend request could not be sent.');
    }
  }

  Future<void> trackEvent(String event, String userId) async {
    final body = {
      "Evento": event,
      "FechaActividad": DateTime.now().toIso8601String(),
      "IdUsuario": userId,
      "Plataforma": "Flutter",
    };

    http.post(
      Uri.parse('${Config.baseUrl}/MetricaFriends/nuevo'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
  }

  Future<String> fetchAmigosLibres({
    required String userId,
    required String dia,
    required int horaInicio,
    required int horaFin,
  }) async {
    final response = await http.post(
      Uri.parse('${Config.baseUrl}/Horarios/amigos-libres'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'dia': dia,
        'horaInicio': horaInicio,
        'horaFin': horaFin,
      }),
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) return response.body;
    throw Exception('Failed to fetch availability');
  }

}