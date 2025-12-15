import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trabajo1/models/tiendaMostrar_dto.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
class tiendaService {
  final String baseUrl = "https://apicredito2-8.onrender.com/api";
 final storage = const FlutterSecureStorage();
  List<tiendaMostrar_dto>? _cacheTiendas;
 Future<List<tiendaMostrar_dto>> getTienda0() async {
  final token = await storage.read(key: 'jwt_token');

  if (token == null) {
    throw Exception("Token no encontrado. Usuario no autenticado.");
  }

  final url = Uri.parse('$baseUrl/Tienda/tiendasApp');

  final response = await http.get(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  print("Respuesta API Tiendas: ${response.body}");

  if (response.statusCode == 200) {
   final List decoded = jsonDecode(response.body);
  // final decoded = jsonDecode(response.body);



    return decoded
        .map((item) => tiendaMostrar_dto.fromJson(item))
        .toList();
  } else {
    throw Exception("Error al obtener las tiendas: ${response.statusCode}");
  }
}


 Future<List<tiendaMostrar_dto>> getTienda({bool forceRefresh = false}) async {

    // 1️⃣ Si hay caché y no forzamos refresh → devolver
    if (_cacheTiendas != null && !forceRefresh) {
      print("Tienda desde caché");
      return _cacheTiendas!;
    }

    final token = await storage.read(key: 'jwt_token');
    if (token == null) {
      throw Exception("Token no encontrado. Usuario no autenticado.");
    }

    final url = Uri.parse('$baseUrl/Tienda/tiendasApp');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print("Tienda desde API");

    if (response.statusCode == 200) {
      final List decoded = jsonDecode(response.body);

      _cacheTiendas = decoded
          .map((item) => tiendaMostrar_dto.fromJson(item))
          .toList();

      return _cacheTiendas!;
    } else {
      throw Exception("Error al obtener la tienda: ${response.statusCode}");
    }
  }

  // 🧹 Limpiar caché
  void clearCache() {
    _cacheTiendas = null;
  }

  
}