import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../config/constants.dart';
import '../horario.dart';

class ScheduleRepository {
  Future<Horario> getActiveSchedule(String userId) async {
    final response = await http.get(
      Uri.parse('${Config.baseUrl}/horarios/activeH/$userId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Horario.fromJson(data);
    } else {
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');
      throw Exception('No se pudo obtener el horario activo.');
    }
  }
}