import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../config/constants.dart';
import '../data/cache/schedule_cache_service.dart';
import '../entities/horario.dart';

class MatchScheduleRepository {
  final ScheduleCacheService _cacheService;

  MatchScheduleRepository({
    ScheduleCacheService? cacheService,
  }) : _cacheService = cacheService ?? ScheduleCacheService();

  Future<ScheduleLoadResult> getMatchActiveScheduleWithCache(
    String friendId,
    String userId,
    String horario1Id,
    String horario2Id,
  ) async {
    final cacheKey =
        'match_schedule_${userId}_${friendId}_${horario1Id}_$horario2Id';

    try {
      final response = await http
          .get(
            Uri.parse(
              '${Config.baseUrl}/horarios/horarioMatch/$userId/$horario1Id/segundo/$friendId/$horario2Id',
            ),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final horario = Horario.fromJson(data);

        await _cacheService.saveHorario(cacheKey, horario);

        return ScheduleLoadResult(
          horario: horario,
          isFromCache: false,
        );
      }

      throw Exception('Server error ${response.statusCode}');
    } catch (_) {
      final cachedHorario = await _cacheService.loadHorario(cacheKey);

      if (cachedHorario != null) {
        return ScheduleLoadResult(
          horario: cachedHorario,
          isFromCache: true,
        );
      }

      throw Exception(
        'The schedule match could not be obtained and there is no saved data.',
      );
    }
  }

  Future<Horario> getMatchActiveSchedule(
    String friendId,
    String userId,
    String horario1Id,
    String horario2Id,
  ) async {
    final result = await getMatchActiveScheduleWithCache(
      friendId,
      userId,
      horario1Id,
      horario2Id,
    );
    return result.horario;
  }
}