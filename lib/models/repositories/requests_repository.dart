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
      throw Exception('No se pudo aceptar la solicitud.');
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
      throw Exception('No se pudo rechazar la solicitud.');
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
      throw Exception('No se pudo buscar el usuario.');
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
      throw Exception('No se pudo obtener el usuario.');
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

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(jsonDecode(response.body)['message'] ?? 'No se pudo enviar la solicitud.');
    }
  }
  
}