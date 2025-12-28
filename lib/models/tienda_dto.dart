class TiendaDTO {
  int id;
  String cedulaEncargado;
  String estadoDeComision; // "Recibida" o "Pendiente"
  DateTime? fechaRegistro;

  TiendaDTO({
    this.id = 0,
    required this.cedulaEncargado,
    required this.estadoDeComision,
    this.fechaRegistro,
  });

  // ------------------- FROM JSON -------------------
  factory TiendaDTO.fromJson(Map<String, dynamic> json) {
    return TiendaDTO(
      id: json['id'] ?? 0,
      cedulaEncargado: json['cedulaEncargado'] ?? '',
      estadoDeComision: json['estadoDeComision'] ?? 'Pendiente',
      fechaRegistro: json['fechaRegistro'] != null
          ? DateTime.parse(json['fechaRegistro'])
          : null,
    );
  }

  // ------------------- TO JSON -------------------
  Map<String, dynamic> toJson() => {
    'Id': id,
    'CedulaEncargado': cedulaEncargado,
    'EstadoDeComision': estadoDeComision,
    'FechaRegistro': fechaRegistro?.toUtc().toIso8601String(),
  };
}