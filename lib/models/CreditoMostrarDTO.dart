class CreditoMostrarDTO {
  final int id;
  final double montoPendiente;
  final String proximaCuotaStr;
  final int plazoCuotas;
  final double valorPorCuota;
  final String estado;
  final int clienteId;

  CreditoMostrarDTO({
    required this.id,
    required this.montoPendiente,
    required this.proximaCuotaStr,
    required this.plazoCuotas,
    required this.valorPorCuota,
    required this.estado,
    required this.clienteId,
  });

  factory CreditoMostrarDTO.fromJson(Map<String, dynamic> json) {
  return CreditoMostrarDTO(
    id: json["id"] ?? 0,
    montoPendiente: (json["montoPendiente"] ?? 0).toDouble(),
    proximaCuotaStr: json["proximaCuotaStr"] ?? "",
    plazoCuotas: (json["plazoCuotas"] ?? 0).toInt(),
    valorPorCuota: (json["valorPorCuota"] ?? 0).toDouble(),
    estado: json["estado"] ?? "",
    clienteId: (json["clienteId"] ?? 0).toInt(),
  );
}

}
