class tiendaMostrar_dto {
  int id;
   String nombreEncargado;
    String telefono;
  int clienteId;


  tiendaMostrar_dto({
    required this.id,
    required this.nombreEncargado,
     required this.telefono,
    required this.clienteId,
 
  });

  factory tiendaMostrar_dto.fromJson(Map<String, dynamic> json) {
  return tiendaMostrar_dto(
    id: json["id"] ?? 0,
    nombreEncargado: json['nombreEncargado'] ?? '',
     telefono: json['telefono'] ?? '',
    clienteId: (json["clienteId"] ?? 0).toInt(),  
  
  );
}

}
