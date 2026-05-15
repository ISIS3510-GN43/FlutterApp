import 'dart:convert';
import '../entities/amigo_disponibilidad.dart';
import '../data/external/web_service.dart';

class SearchAvailabilityRepository {
  final WebService _webService;

  SearchAvailabilityRepository({WebService? webService})
      : _webService = webService ?? WebService();

  Future<List<AmigoDisponibilidad>> buscarAmigosLibres({
    required String userId,
    required String dia,
    required int horaInicio,
    required int horaFin,
  }) async {
    final rawJson = await _webService.fetchAmigosLibres(
      userId: userId,
      dia: dia,
      horaInicio: horaInicio,
      horaFin: horaFin,
    );
    final List<dynamic> data = jsonDecode(rawJson);
    return data.map((json) => AmigoDisponibilidad.fromJson(json)).toList();
  }
}