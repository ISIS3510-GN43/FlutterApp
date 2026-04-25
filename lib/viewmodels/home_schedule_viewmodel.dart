import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/horario.dart';
import '../models/materia.dart';
import '../models/repositories/schedule_repository.dart';
import 'schedule_viewmodel.dart';

class HomeScheduleViewModel extends ScheduleViewModel {
  final ScheduleRepository _repository;
  final String userId;

  HomeScheduleViewModel({
    required this.userId,
    ScheduleRepository? repository,
  }) : _repository = repository ?? ScheduleRepository();

  bool _isLoading = false;
  String _errorMessage = '';
  List<Materia> _materias = [];
  String? horarioId;
  bool _isOffline = false;

  @override
  bool get isOffline => _isOffline;

  String get _cacheKey => 'schedule_cache_$userId';

  @override
  bool get isLoading => _isLoading;

  @override
  String get errorMessage => _errorMessage;

  @override
  List<Materia> get materias => _materias;

  Future<void> _saveCache(Horario horario) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, jsonEncode(horario.toJson()));
  }

  Future<Horario?> _loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null) return null;
    return Horario.fromJson(jsonDecode(raw));
  }

  @override
  Future<void> loadSchedule() async {
    _isLoading = true;
    _errorMessage = '';
    _isOffline = false;
    notifyListeners();

    try {
      final horario = await _repository.getActiveSchedule(userId);
      horarioId = horario.id;
      _materias = horario.clases;
      await _saveCache(horario);
    } catch (_) {
      final cached = await _loadCache();
      if (cached != null) {
        horarioId = cached.id;
        _materias = cached.clases;
        _isOffline = true;
      } else {
        _errorMessage = 'Sin conexión y sin datos guardados.';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}