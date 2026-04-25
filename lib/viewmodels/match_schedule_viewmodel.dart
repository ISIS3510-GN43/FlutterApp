import '../models/dia.dart';
import '../models/materia.dart';
import '../models/repositories/match_repository.dart';
import 'schedule_viewmodel.dart';

class MatchScheduleViewModel extends ScheduleViewModel {
  final MatchScheduleRepository _repository;
  final String friendId;
  final String userId;
  final String horario1Id;
  final String horario2Id;

  MatchScheduleViewModel({
    required this.friendId,
    required this.userId,
    required this.horario1Id,
    required this.horario2Id,
    MatchScheduleRepository? repository,
  }) : _repository = repository ?? MatchScheduleRepository();

  bool _isLoading = false;
  String _errorMessage = '';
  List<Materia> _materias = [];
  bool _isUsingCachedData = false;
  String _insightMessage = '';

  @override
  bool get isLoading => _isLoading;

  @override
  String get errorMessage => _errorMessage;

  @override
  List<Materia> get materias => _materias;

  @override
  bool get isUsingCachedData => _isUsingCachedData;

  @override
  String get insightMessage => _insightMessage;

  @override
  Future<void> loadSchedule() async {
    _isLoading = true;
    _errorMessage = '';
    _isUsingCachedData = false;
    _insightMessage = '';
    notifyListeners();

    try {
      final result = await _repository.getMatchActiveScheduleWithCache(
        friendId,
        userId,
        horario1Id,
        horario2Id,
      );

      final horario = result.horario;

      _materias = horario.clases;
      _isUsingCachedData = result.isFromCache;
      _insightMessage = _buildNextCommonSlotMessage(_materias);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _buildNextCommonSlotMessage(List<Materia> commonSlots) {
    if (commonSlots.isEmpty) {
      return 'No se encontraron espacios libres comunes con este amigo.';
    }

    final now = DateTime.now();
    final nowWeekday = now.weekday;
    final nowMinutes = now.hour * 60 + now.minute;

    _SlotCandidate? bestCandidate;

    for (final materia in commonSlots) {
      final occurrences = [
        materia.dias.length,
        materia.horaInicio.length,
        materia.horaFin.length,
      ].reduce((a, b) => a < b ? a : b);

      for (int i = 0; i < occurrences; i++) {
        final day = materia.dias[i];
        final dayNumber = _weekdayNumber(day);

        final startMinutes = _hhmmToMinutes(materia.horaInicio[i]);
        final endMinutes = _hhmmToMinutes(materia.horaFin[i]);

        if (endMinutes <= startMinutes) {
          continue;
        }

        var daysUntil = dayNumber - nowWeekday;

        if (daysUntil < 0 || (daysUntil == 0 && endMinutes <= nowMinutes)) {
          daysUntil += 7;
        }

        final effectiveStart =
            daysUntil == 0 && startMinutes < nowMinutes
                ? nowMinutes
                : startMinutes;

        final distanceFromNow = daysUntil * 1440 + effectiveStart - nowMinutes;

        final candidate = _SlotCandidate(
          day: day,
          daysUntil: daysUntil,
          startMinutes: startMinutes,
          effectiveStartMinutes: effectiveStart,
          endMinutes: endMinutes,
          distanceFromNow: distanceFromNow,
        );

        if (bestCandidate == null ||
            candidate.distanceFromNow < bestCandidate.distanceFromNow) {
          bestCandidate = candidate;
        }
      }
    }

    if (bestCandidate == null) {
      return 'No se encontraron espacios libres comunes próximos.';
    }

    final dayLabel =
        bestCandidate.daysUntil == 0 ? 'Hoy' : _dayLabel(bestCandidate.day);

    final startLabel = bestCandidate.effectiveStartMinutes == nowMinutes &&
            bestCandidate.startMinutes < nowMinutes
        ? 'ahora'
        : _formatMinutes(bestCandidate.startMinutes);

    final endLabel = _formatMinutes(bestCandidate.endMinutes);

    return 'Siguiente espacio libre en común : $dayLabel, $startLabel - $endLabel';
  }

  int _weekdayNumber(Dia day) {
    switch (day) {
      case Dia.lunes:
        return 1;
      case Dia.martes:
        return 2;
      case Dia.miercoles:
        return 3;
      case Dia.jueves:
        return 4;
      case Dia.viernes:
        return 5;
      case Dia.sabado:
        return 6;
      case Dia.domingo:
        return 7;
    }
  }

  int _hhmmToMinutes(int value) {
    final hours = value ~/ 100;
    final minutes = value % 100;
    return hours * 60 + minutes;
  }

  String _formatMinutes(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}';
  }

  String _dayLabel(Dia day) {
    switch (day) {
      case Dia.lunes:
        return 'Lunes';
      case Dia.martes:
        return 'Martes';
      case Dia.miercoles:
        return 'Miércoles';
      case Dia.jueves:
        return 'Jueves';
      case Dia.viernes:
        return 'Viernes';
      case Dia.sabado:
        return 'Sábado';
      case Dia.domingo:
        return 'Domingo';
    }
  }
}

class _SlotCandidate {
  final Dia day;
  final int daysUntil;
  final int startMinutes;
  final int effectiveStartMinutes;
  final int endMinutes;
  final int distanceFromNow;

  const _SlotCandidate({
    required this.day,
    required this.daysUntil,
    required this.startMinutes,
    required this.effectiveStartMinutes,
    required this.endMinutes,
    required this.distanceFromNow,
  });
}