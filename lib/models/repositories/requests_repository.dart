import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../config/constants.dart';
import '../usuario.dart';

class RequestsRepository {
  Future<List<Usuario>> getRequests(String userId) async {
    final response = await http.get(
      Uri.parse('${Config.baseUrl}/usuarios/$userId/solicitudes'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Usuario.fromJson(json)).toList();
    } else {
      throw Exception('No se pudieron obtener las solicitudes.');
    }
  }

  Future<void> acceptRequest({
    required String currentUserId,
    required String senderUserId,
  }) async {
    final response = await http.post(
      Uri.parse(
        '${Config.baseUrl}/usuarios/$currentUserId/solicitudes/$senderUserId/aceptar',
      ),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode < 200) {
      throw Exception(jsonDecode(response.body)['message'] ?? 'The friend request could not be accepted.');
    }
  }

  Future<void> rejectRequest({
    required String currentUserId,
    required String senderUserId,
  }) async {
    final response = await http.post(
      Uri.parse(
        '${Config.baseUrl}/usuarios/$currentUserId/rechazarsolicitud/$senderUserId',
      ),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode < 200) {
      throw Exception(jsonDecode(response.body)['message'] ?? 'The friend request could not be rejected.');
    }
  }
  Future<String?> findUserIdByUsername(String username) async {
    final response = await http.get(
      Uri.parse('${Config.baseUrl}/usuarios/codigo/username/$username'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final body = response.body.trim();

      if (body.isEmpty || body == 'null') {
        return null;
      }

      return body.replaceAll('"', '');
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'The user could not be found.');
    }
  }

  Future<Usuario?> findUserByUsername(String username) async {
    final userId = await findUserIdByUsername(username);

    if (userId == null || userId.isEmpty) {
      return null;
    }

    final response = await http.get(
      Uri.parse('${Config.baseUrl}/usuarios/$userId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return Usuario.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'The user could not be found.');
    }
  }

  Future<void> sendRequest({
    required String targetUserId,
    required String senderUserId,
  }) async {
    final response = await http.post(
      Uri.parse(
        '${Config.baseUrl}/usuarios/$targetUserId/solicitudes/$senderUserId',
      ),
      headers: {'Content-Type': 'application/json'},
    );

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
  
}