import 'package:flutter/material.dart';
import '../models/materia.dart';

abstract class ScheduleViewModel extends ChangeNotifier {
  bool get isLoading;
  String get errorMessage;
  List<Materia> get materias;

  bool get isUsingCachedData => false;
  String get insightMessage => '';

  Future<void> loadSchedule();
}