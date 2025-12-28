class tiendaMostrar_dto {
  final int id;
  final String fechaRegistroStr;
  final int clienteId;

  tiendaMostrar_dto({
    required this.id,
    required this.fechaRegistroStr,
    required this.clienteId,
  });

  factory tiendaMostrar_dto.fromJson(Map<String, dynamic> json) {
    return tiendaMostrar_dto(
      id: json['id'] ?? json['Id'] ?? 0,
      fechaRegistroStr: json['fechaRegistroStr'] ?? json['FechaRegistroStr'] ?? '',
      clienteId: json['clienteId'] ?? json['ClienteId'] ?? 0,
    );
  }
}