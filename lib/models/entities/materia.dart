import 'dia.dart';

class Materia {
  String id;
  String nombre;
  List<String> aula;
  List<Dia> dias;
  List<int> horaInicio;
  List<int> horaFin;
  String color;
  DateTime? fechaInicio;
  DateTime? fechaFin;

  Materia({
    required this.id,
    required this.nombre,
    required this.aula,
    required this.dias,
    required this.horaInicio,
    required this.horaFin,
    required this.color,
    required this.fechaInicio,
    required this.fechaFin,
  });

  factory Materia.fromJson(Map<String, dynamic> json) {
    return Materia(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      aula: List<String>.from(json['aula'] ?? []),
      dias: (json['dias'] as List<dynamic>? ?? [])
          .map((d) => DiaExtension.fromJson(d))
          .toList(),
      horaInicio: List<int>.from(json['horaInicio'] ?? []),
      horaFin: List<int>.from(json['horaFin'] ?? []),
      color: json['color'] ?? '',
      fechaInicio: json['fechaInicio'] != null
          ? DateTime.parse(json['fechaInicio'])
          : null,
      fechaFin: json['fechaFin'] != null
          ? DateTime.parse(json['fechaFin'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'aula': aula,
      'dias': dias.map((d) => d.toJson()).toList(),
      'horaInicio': horaInicio,
      'horaFin': horaFin,
      'color': color,
      'fechaInicio': fechaInicio?.toIso8601String(),
      'fechaFin': fechaFin?.toIso8601String(),
    };
  }
}