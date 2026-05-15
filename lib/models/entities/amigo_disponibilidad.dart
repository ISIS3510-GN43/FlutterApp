class AmigoDisponibilidad {
  final String amigoId;
  final String username;
  final String estado;

  AmigoDisponibilidad({
    required this.amigoId,
    required this.username,
    required this.estado,
  });

  factory AmigoDisponibilidad.fromJson(Map<String, dynamic> json) {
    return AmigoDisponibilidad(
      amigoId: json['amigoId'] ?? '',
      username: json['username'] ?? '',
      estado: json['estado'] ?? 'ocupado',
    );
  }

  bool get isLibre => estado == 'libre';
}