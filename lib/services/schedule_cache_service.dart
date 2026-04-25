import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/horario.dart';

class ScheduleLoadResult {
  final Horario horario;
  final bool isFromCache;

  const ScheduleLoadResult({
    required this.horario,
    required this.isFromCache,
  });
}

class ScheduleCacheService {
  static final Map<String, Horario> _memoryCache = {};

  Future<void> saveHorario(String key, Horario horario) async {
    _memoryCache[key] = horario;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(horario.toJson()));
  }

  Future<Horario?> loadHorario(String key) async {
    final memoryValue = _memoryCache[key];
    if (memoryValue != null) {
      return memoryValue;
    }

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);

    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final horario = Horario.fromJson(decoded);
      _memoryCache[key] = horario;
      return horario;
    } catch (_) {
      await prefs.remove(key);
      return null;
    }
  }

  Future<void> clearHorario(String key) async {
    _memoryCache.remove(key);

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}