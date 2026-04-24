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

  @override
  bool get isLoading => _isLoading;

  @override
  String get errorMessage => _errorMessage;

  @override
  List<Materia> get materias => _materias;

  @override
  Future<void> loadSchedule() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final horario = await _repository.getMatchActiveSchedule(friendId, userId, horario1Id, horario2Id);
      _materias = horario.clases;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}