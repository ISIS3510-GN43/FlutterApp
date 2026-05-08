import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../config/constants.dart';
import '../data/cache/schedule_cache_service.dart';
import '../entities/horario.dart';

class ScheduleRepository {
  final ScheduleCacheService _cacheService;

  ScheduleRepository({
    ScheduleCacheService? cacheService,
  }) : _cacheService = cacheService ?? ScheduleCacheService();

  Future<ScheduleLoadResult> getActiveScheduleWithCache(String userId) async {
    final cacheKey = 'user_schedule_$userId';

    try {
      final response = await http
          .get(
            Uri.parse('${Config.baseUrl}/horarios/activeH/$userId'),
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
        'The active schedule could not be obtained and there is no saved data.',
      );
    }
  }

  Future<Horario> getActiveSchedule(String userId) async {
    final result = await getActiveScheduleWithCache(userId);
    return result.horario;
  }
}