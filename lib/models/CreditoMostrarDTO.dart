
import '../models/tiendaMostrar_dto.dart';

class CreditoMostrarDTO {
  final int id;
  final  double montoTotal;
  final double montoPendiente;
  final String proximaCuotaStr;
  final int plazoCuotas;
  final double valorPorCuota;
  final String estado;
  final String marca;
  final String modelo;
  final double abonadoTotal;
  final double abonadoCuota;
  final String estadoCuota;
  final int clienteId;
  final int? tiendaId;
   final tiendaMostrar_dto? tienda;

  CreditoMostrarDTO({
    required this.id,
    required this.montoTotal,
    required this.montoPendiente,
    required this.proximaCuotaStr,
    required this.plazoCuotas,
    required this.valorPorCuota,
    required this.estado,
    required this.clienteId,
    required this.marca,
    required this.modelo,
    required this.abonadoTotal,
    required this.abonadoCuota,
    required this.estadoCuota,
    this.tiendaId,
    this.tienda,
  });

  factory CreditoMostrarDTO.fromJson(Map<String, dynamic> json) {
  return CreditoMostrarDTO(
    id: json["id"] ?? 0,
    montoTotal: (json['MontoTotal'] ?? 0).toDouble(),
    montoPendiente: (json["montoPendiente"] ?? 0).toDouble(),
    proximaCuotaStr: json["proximaCuotaStr"] ?? "",
    plazoCuotas: (json["plazoCuotas"] ?? 0).toInt(),
    valorPorCuota: (json["valorPorCuota"] ?? 0).toDouble(),
    estado: json["estado"] ?? "",
    clienteId: (json["clienteId"] ?? 0).toInt(),
    tiendaId: (json["tiendaId"]?? 0).toInt(),
      // 🔥 AQUÍ está la clave
      tienda: json['tienda'] != null
          ? tiendaMostrar_dto.fromJson(json['tienda'])
          : null,
    marca: json['marca'] ?? '',
    modelo: json['modelo'] ?? '',
    abonadoTotal: (json['abonadoTotal'] ?? 0).toDouble(),
    abonadoCuota: (json['abonadoCuota'] ?? 0).toDouble(),
    estadoCuota: json['estadoCuota'] ?? '',

  );
}


  // 🔑 Método copyWith para actualizaciones parciales
  CreditoMostrarDTO copyWith({
    double? montoPendiente,
    String? proximaCuotaStr,
    String? estado,
    tiendaMostrar_dto? tienda,
  }) {
    return CreditoMostrarDTO(
      id: this.id,
      montoTotal: this.montoTotal,
      montoPendiente: montoPendiente ?? this.montoPendiente,
      proximaCuotaStr: proximaCuotaStr ?? this.proximaCuotaStr,
      plazoCuotas: this.plazoCuotas,
      valorPorCuota: this.valorPorCuota,
      estado: estado ?? this.estado,
      clienteId: this.clienteId,
       tiendaId: tiendaId ?? this.tiendaId, 
      tienda: tienda ?? this.tienda,
      marca: this.marca,
      modelo: this.modelo,
      abonadoTotal: this.abonadoTotal,
      abonadoCuota: this.abonadoCuota,
      estadoCuota: this.estadoCuota,
      
    );
  }

}
