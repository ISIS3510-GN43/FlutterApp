import 'package:flutter/material.dart';

import '../models/dia.dart';
import '../models/horario.dart';
import '../models/usuario.dart';
import '../models/repositories/friends_repository.dart';

class FriendsViewModel extends ChangeNotifier {
  final FriendsRepository _friendsRepository;

  FriendsViewModel({FriendsRepository? friendsRepository})
      : _friendsRepository = friendsRepository ?? FriendsRepository();

  bool _isLoading = false;
  String _errorMessage = '';
  List<Usuario> _friends = [];
  bool _isOffline = false;
  DateTime? _lastSyncedAt;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<Usuario> get friends => _friends;
  bool get hasFriends => _friends.isNotEmpty;
  bool get isOffline => _isOffline;
  DateTime? get lastSyncedAt => _lastSyncedAt;

  Future<void> loadFriends(String userId) async {
    _isLoading = true;
    _errorMessage = '';
    _isOffline = false;
    notifyListeners();

    try {
      _friends = await _friendsRepository.getFriends(userId);
      _isOffline = false;
    } catch (e) {
      if (e is OfflineWithDataException) {
        _friends = e.cachedFriends; 
        _isOffline = true;     
      } else {
        final message = e.toString().replaceFirst('Exception: ', '');
        if (message.contains('no cached')) {
          _errorMessage = 'No internet connection and no saved data.';
        } else {
          _errorMessage = message;
        }
      }
    } finally {
      _lastSyncedAt = await _friendsRepository.getLastSyncedAt();
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isFriendAvailable(Usuario friend) {
    final horario = _getSelectedSchedule(friend);

    if (horario == null) return true;

    final now = DateTime.now();
    final currentDay = _weekdayToDia(now.weekday);
    final currentTime = now.hour * 100 + now.minute;

    for (final materia in horario.clases) {
      final length = materia.dias.length;    

      for (int i = 0; i < length; i++) {
        final sameDay = materia.dias[i] == currentDay;
        final inTimeRange = currentTime >= materia.horaInicio[i] &&
            currentTime < materia.horaFin[i];

        if (sameDay && inTimeRange) {
          return false;
        }
      }
    }

    return true;
  }

  Horario? _getSelectedSchedule(Usuario friend) {
    if (friend.horarios.isEmpty) return null;
    if (friend.horarios.length == 1) return friend.horarios.first;

    for (final horario in friend.horarios) {
      if (horario.activo) return horario;
    }

    return friend.horarios.first;
  }

  Dia _weekdayToDia(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return Dia.lunes;
      case DateTime.tuesday:
        return Dia.martes;
      case DateTime.wednesday:
        return Dia.miercoles;
      case DateTime.thursday:
        return Dia.jueves;
      case DateTime.friday:
        return Dia.viernes;
      case DateTime.saturday:
        return Dia.sabado;
      default:
        return Dia.domingo;
    }
  }
}