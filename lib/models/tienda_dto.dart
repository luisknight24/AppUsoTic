class TiendaDTO {
  int id;
  String nombreTienda;
  String nombreEncargado;
  String telefono;
  String direccion;
  DateTime? fechaRegistro;
  int clienteId;

  TiendaDTO({
    this.id = 0,
    required this.nombreTienda,
    required this.nombreEncargado,
    required this.telefono,
    required this.direccion,
    this.fechaRegistro,
    this.clienteId = 0,
  });

// ------------------- FROM JSON -------------------
  factory TiendaDTO.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic date) {
      if (date is String) return DateTime.parse(date);
      if (date is int) return DateTime.fromMillisecondsSinceEpoch(date);
      return DateTime.now();
    }

    return TiendaDTO(
      id: json['Id'] ?? 0,
      nombreTienda: json['NombreTienda'] ?? '',
      nombreEncargado: json['NombreEncargado'] ?? '',
      telefono: json['Telefono'] ?? '',
      direccion: json['Direccion'] ?? '',
      fechaRegistro: parseDate(json['FechaRegistro']),
      clienteId: json['ClienteId'] ?? 0,
    );
  }

  // ------------------- TO JSON -------------------
  Map<String, dynamic> toJson() => {
        'Id': id,
        'NombreTienda': nombreTienda,
        'NombreEncargado': nombreEncargado,
        'Telefono': telefono,
        'Direccion': direccion,
 //       'FechaRegistro': fechaRegistro.toIso8601String(),
        'ClienteId': clienteId,
      };
}