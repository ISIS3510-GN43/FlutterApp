import '../models/materia.dart';
import '../repositories/friend_schedule_repository.dart';
import 'schedule_viewmodel.dart';

class FriendScheduleViewModel extends ScheduleViewModel {
  final FriendScheduleRepository _repository;
  final String friendId;

  FriendScheduleViewModel({
    required this.friendId,
    FriendScheduleRepository? repository,
  }) : _repository = repository ?? FriendScheduleRepository();

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
      final horario = await _repository.getFriendActiveSchedule(friendId);
      _materias = horario.clases;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}