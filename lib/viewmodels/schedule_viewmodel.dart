import 'package:flutter/material.dart';
import '../models/materia.dart';

abstract class ScheduleViewModel extends ChangeNotifier {
  bool get isLoading;
  String get errorMessage;
  List<Materia> get materias;

  Future<void> loadSchedule();
}