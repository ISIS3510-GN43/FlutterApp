import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../config/constants.dart';
import '../data/cache/schedule_cache_service.dart';
import '../entities/horario.dart';

class FriendScheduleRepository {
  final ScheduleCacheService _cacheService;

  FriendScheduleRepository({
    ScheduleCacheService? cacheService,
  }) : _cacheService = cacheService ?? ScheduleCacheService();

  Future<ScheduleLoadResult> getFriendActiveScheduleWithCache(
    String friendId,
  ) async {
    final cacheKey = 'friend_schedule_$friendId';

    try {
      final response = await http
          .get(
            Uri.parse('${Config.baseUrl}/horarios/activeH/$friendId'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 3));

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
        'The friends schedule could not be obtained and no data was saved.',
      );
    }
  }

  Future<Horario> getFriendActiveSchedule(String friendId) async {
    final result = await getFriendActiveScheduleWithCache(friendId);
    return result.horario;
  }
}