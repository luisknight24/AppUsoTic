class TiendaCrearDTO {
  String nombreTienda;
  String nombreEncargado;
  String telefono;
  String direccion;
  String codigoTienda;
  String? logoBase64;

  TiendaCrearDTO({
    required this.nombreTienda,
    required this.nombreEncargado,
    required this.telefono,
    required this.direccion,
    required this.codigoTienda,
    this.logoBase64,
  });

  Map<String, dynamic> toJson() => {
    'NombreTienda': nombreTienda,
    'NombreEncargado': nombreEncargado,
    'Telefono': telefono,
    'Direccion': direccion,
    'CodigoTienda': codigoTienda,
    'LogoBase64': logoBase64,
  };
}