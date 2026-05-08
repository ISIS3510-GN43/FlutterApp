import 'horario.dart';

class Usuario {
  String id;
  String foto;
  String gmail;
  String username;
  String? password;
  String cumpleanios;
  List<String> amigosIds;
  List<String> amigosUsernames;
  List<Horario> horarios;
  List<String> solicitudes;
  List<dynamic> eventos;

  Usuario({
    required this.id,
    required this.foto,
    required this.gmail,
    required this.username,
    required this.password,
    required this.cumpleanios,
    required this.amigosIds,
    required this.amigosUsernames,
    required this.horarios,
    required this.solicitudes,
    required this.eventos,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] ?? '',
      foto: json['foto'] ?? '',
      gmail: json['gmail'] ?? '',
      username: json['username'] ?? '',
      password: json['password'],
      cumpleanios: json['cumpleanios'] ?? '',
      amigosIds: List<String>.from(json['amigosIds'] ?? []),
      amigosUsernames: List<String>.from(json['amigosUsernames'] ?? []),
      horarios: (json['horarios'] as List<dynamic>? ?? [])
          .map((h) => Horario.fromJson(h))
          .toList(),
      solicitudes: List<String>.from(json['solicitudes'] ?? []),
      eventos: List<dynamic>.from(json['eventos'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'foto': foto,
      'gmail': gmail,
      'username': username,
      'password': password,
      'cumpleanios': cumpleanios,
      'amigosIds': amigosIds,
      'amigosUsernames': amigosUsernames,
      'horarios': horarios.map((h) => h.toJson()).toList(),
      'solicitudes': solicitudes,
      'eventos': eventos,
    };
  }
}