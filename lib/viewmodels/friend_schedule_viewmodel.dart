import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/materia.dart';
import '../models/repositories/friend_schedule_repository.dart';
import 'schedule_viewmodel.dart';

class FriendScheduleViewModel extends ScheduleViewModel {
  final FriendScheduleRepository _repository;
  final String friendId;

  static int _totalCalls = 0;
  static double _totalMs = 0;

  static const double _targetMs = 1.0;
  static const String _webhookUrl = 'https://automation.luminotest.com/webhook/time-bq';

  FriendScheduleViewModel({
    required this.friendId,
    FriendScheduleRepository? repository,
  }) : _repository = repository ?? FriendScheduleRepository();

  bool _isLoading = false;
  String _errorMessage = '';
  List<Materia> _materias = [];
  String _horarioId = '';

  @override
  bool get isLoading => _isLoading;

  @override
  String get errorMessage => _errorMessage;

  @override
  List<Materia> get materias => _materias;

  String get horarioId => _horarioId;

  @override
  Future<void> loadSchedule() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final time = Stopwatch()..start();

    try {
      final horario = await _repository.getFriendActiveSchedule(friendId);
      _horarioId = horario.id;
      _materias = horario.clases;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      time.stop();
      _isLoading = false;
      notifyListeners();

      final currentMs = time.elapsedMicroseconds / 1000.0;
      _totalCalls++;
      _totalMs += currentMs;
      final averageMs = _totalMs / _totalCalls;

      if (averageMs > _targetMs) {
        await _sendToWebhook(averageMs, currentMs);
      }
    }
  }

  Future<void> _sendToWebhook(double averageMs, double currentMs) async {
    try {
      final response = await http.post(
        Uri.parse(_webhookUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'averageMs': averageMs,
          'currentMs': currentMs,
          'friendId': friendId,
        }),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to send data to webhook.');
      }
    } catch (e) {
      print('Error sending to webhook: $e');
    }
  }
}