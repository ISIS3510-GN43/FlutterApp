import 'dia.dart';
import 'materia.dart';

class Horario {
  String id;
  String titulo;
  Dia? primerDia;
  Dia? ultimoDia;
  String? fondoPantalla;
  List<Materia> clases;
  bool activo;

  Horario({
    required this.id,
    required this.titulo,
    required this.primerDia,
    required this.ultimoDia,
    required this.fondoPantalla,
    required this.clases,
    required this.activo,
  });

  factory Horario.fromJson(Map<String, dynamic> json) {
    return Horario(
      id: json['id'] ?? '',
      titulo: json['titulo'] ?? '',
      primerDia: json['primerDia'] != null
          ? DiaExtension.fromJson(json['primerDia'])
          : null,
      ultimoDia: json['ultimoDia'] != null
          ? DiaExtension.fromJson(json['ultimoDia'])
          : null,
      fondoPantalla: json['fondoPantalla'] ?? '',
      clases: (json['clases'] as List<dynamic>? ?? [])
          .map((c) => Materia.fromJson(c))
          .toList(),
      activo: json['activo'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'primerDia': primerDia?.toJson(),
      'ultimoDia': ultimoDia?.toJson(),
      'fondoPantalla': fondoPantalla,
      'clases': clases.map((c) => c.toJson()).toList(),
      'activo': activo,
    };
  }
}