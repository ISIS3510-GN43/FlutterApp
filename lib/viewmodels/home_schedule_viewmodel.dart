import '../models/materia.dart';
import '../repositories/schedule_repository.dart';
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
      final horario = await _repository.getActiveSchedule(userId);
      _materias = horario.clases;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}