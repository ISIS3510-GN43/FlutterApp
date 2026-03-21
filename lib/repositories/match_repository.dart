import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/constants.dart';
import '../models/horario.dart';

class MatchScheduleRepository {
  Future<Horario> getMatchActiveSchedule(String friendId, String userId, String horario1Id, String horario2Id) async {
    final response = await http.get(
      Uri.parse('${Config.baseUrl}/horarios/horarioMatch/$userId/$horario1Id/segundo/$friendId/$horario2Id'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Horario.fromJson(data);
    } else {
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');
      throw Exception('No se pudo obtener el horario del amigo.');
    }
  }
}