import 'package:flutter/material.dart';
import '../models/dia.dart';
import '../models/repositories/search_availability_repository.dart';
 
class SearchAvailabilityViewModel extends ChangeNotifier {
  final SearchAvailabilityRepository _repository;
 
  SearchAvailabilityViewModel({SearchAvailabilityRepository? repository})
      : _repository = repository ?? SearchAvailabilityRepository();
 
  TimeOfDay? horaInicio;
  TimeOfDay? horaFin;
  Dia? diaSeleccionado;
 
  bool _isLoading = false;
  String _errorMessage = '';
  List<AmigoDisponibilidad>? _resultados;
  bool _hasSearched = false;
 
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<AmigoDisponibilidad>? get resultados => _resultados;
  bool get hasSearched => _hasSearched;
 
  bool get canSearch => horaInicio != null && horaFin != null && diaSeleccionado != null;
 
  String? get horaError {
    if (horaInicio == null || horaFin == null) return null;
    final inicioMins = horaInicio!.hour * 60 + horaInicio!.minute;
    final finMins = horaFin!.hour * 60 + horaFin!.minute;
    if (finMins <= inicioMins) {
      return 'End time must be after start time';
    }
    return null;
  }
 
  bool get isHoraValida => horaError == null;
 
  void setHoraInicio(TimeOfDay time) {
    horaInicio = time;
    notifyListeners();
  }
 
  void setHoraFin(TimeOfDay time) {
    horaFin = time;
    notifyListeners();
  }
 
  void setDia(Dia dia) {
    diaSeleccionado = dia;
    notifyListeners();
  }
 
  int _toHoraInt(TimeOfDay time) {
    return time.hour * 100 + time.minute;
  }
 
  String _diaToString(Dia dia) {
    switch (dia) {
      case Dia.lunes:
        return 'LUNES';
      case Dia.martes:
        return 'MARTES';
      case Dia.miercoles:
        return 'MIERCOLES';
      case Dia.jueves:
        return 'JUEVES';
      case Dia.viernes:
        return 'VIERNES';
      case Dia.sabado:
        return 'SABADO';
      case Dia.domingo:
        return 'DOMINGO';
    }
  }
 
  Future<void> buscar(String userId) async {
    if (!canSearch || !isHoraValida) return;
 
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
 
    try {
      _resultados = await _repository.buscarAmigosLibres(
        userId: userId,
        dia: _diaToString(diaSeleccionado!),
        horaInicio: _toHoraInt(horaInicio!),
        horaFin: _toHoraInt(horaFin!),
      );
      _hasSearched = true;
    } catch (e) {
      _errorMessage = 'Could not fetch availability. Check your connection.';
      _resultados = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}