enum Dia {
  lunes,
  martes,
  miercoles,
  jueves,
  viernes,
  sabado,
  domingo,
}

extension DiaExtension on Dia {
  static Dia fromJson(String value) {
    switch (value.toUpperCase()) {
      case 'LUNES':
        return Dia.lunes;
      case 'MARTES':
        return Dia.martes;
      case 'MIERCOLES':
      case 'MIÉRCOLES':
        return Dia.miercoles;
      case 'JUEVES':
        return Dia.jueves;
      case 'VIERNES':
        return Dia.viernes;
      case 'SABADO':
      case 'SÁBADO':
        return Dia.sabado;
      case 'DOMINGO':
        return Dia.domingo;
      default:
        throw Exception('Día no válido: $value');
    }
  }

  String toJson() {
    switch (this) {
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
}