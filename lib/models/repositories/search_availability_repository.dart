import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/constants.dart';

class AmigoDisponibilidad {
  final String amigoId;
  final String username;
  final String estado;

  AmigoDisponibilidad({
    required this.amigoId,
    required this.username,
    required this.estado,
  });

  factory AmigoDisponibilidad.fromJson(Map<String, dynamic> json) {
    return AmigoDisponibilidad(
      amigoId: json['amigoId'] ?? '',
      username: json['username'] ?? '',
      estado: json['estado'] ?? 'ocupado',
    );
  }

  bool get isLibre => estado == 'libre';
}

class SearchAvailabilityRepository {
  Future<List<AmigoDisponibilidad>> buscarAmigosLibres({
    required String userId,
    required String dia,
    required int horaInicio,
    required int horaFin,
  }) async {
    final response = await http
        .post(
          Uri.parse('${Config.baseUrl}/Horarios/amigos-libres'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'userId': userId,
            'dia': dia,
            'horaInicio': horaInicio,
            'horaFin': horaFin,
          }),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => AmigoDisponibilidad.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch availability');
    }
  }
}