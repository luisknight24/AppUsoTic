import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trabajo1/models/credito_dto.dart';
import 'package:trabajo1/models/CreditoMostrarDTO.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class creditoMostrarHome {
  final String baseUrl = "https://apicredito2-8.onrender.com/api";
 final storage = const FlutterSecureStorage();
  // 🟢 CACHÉ EN MEMORIA
  List<CreditoMostrarDTO>? _cacheCreditos;
Future<List<CreditoMostrarDTO>> getCreditos1() async {
  final token = await storage.read(key: 'jwt_token');
  final url = Uri.parse('$baseUrl/Credito/pendientesApp'); // sin clienteId
  final response = await http.get(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // aquí mandas el JWT
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => CreditoMostrarDTO.fromJson(e)).toList();
  } else {
    throw Exception('Error al obtener los créditos');
  }
}


 Future<List<CreditoMostrarDTO>> getCreditos2() async {
    final token = await storage.read(key: 'jwt_token');

    if (token == null) {
      throw Exception("Token no encontrado. Usuario no autenticado.");
    }

    final url = Uri.parse('$baseUrl/Credito/pendientesApp');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print("Respuesta API Créditos: ${response.body}");

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      // La API devuelve: { status: true, value: [ ... ] }
      if (decoded["status"] == true) {
        final List lista = decoded["value"];

        return lista
            .map((item) => CreditoMostrarDTO.fromJson(item))
            .toList();
      } else {
        throw Exception("API respondió con status=false");
      }
    } else {
      throw Exception(
          "Error al obtener los créditos: ${response.statusCode}");
    }
  }

  Future<List<CreditoMostrarDTO>> getCreditos0({bool forceRefresh = false}) async {
  final token = await storage.read(key: 'jwt_token');

 
   // 1️⃣ Si hay caché y no forzamos refresh → devolver
    if (_cacheCreditos != null && !forceRefresh) {
      print("⚡ Créditos desde caché");
      return _cacheCreditos!;
    }

  if (token == null) {
    throw Exception("Token no encontrado. Usuario no autenticado.");
  }

  final url = Uri.parse('$baseUrl/Credito/pendientesApp');

  final response = await http.get(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  print("Respuesta API Créditos: ${response.body}");

  if (response.statusCode == 200) {
    final List decoded = jsonDecode(response.body);

    return decoded
        .map((item) => CreditoMostrarDTO.fromJson(item))
        .toList();
  } else {
    throw Exception("Error al obtener los créditos: ${response.statusCode}");
  }
}


 Future<List<CreditoMostrarDTO>> getCreditos({bool forceRefresh = false}) async {

    // 1️⃣ Si hay caché y no forzamos refresh → devolver
    if (_cacheCreditos != null && !forceRefresh) {
      print("⚡ Créditos desde caché");
      return _cacheCreditos!;
    }

    final token = await storage.read(key: 'jwt_token');
    if (token == null) {
      throw Exception("Token no encontrado. Usuario no autenticado.");
    }

    final url = Uri.parse('$baseUrl/Credito/pendientesApp');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print("🌐 Créditos desde API");

    if (response.statusCode == 200) {
      final List decoded = jsonDecode(response.body);

      _cacheCreditos = decoded
          .map((item) => CreditoMostrarDTO.fromJson(item))
          .toList();

      return _cacheCreditos!;
    } else {
      throw Exception("Error al obtener los créditos: ${response.statusCode}");
    }
  }

  // 🧹 Limpiar caché
  void clearCache() {
    _cacheCreditos = null;
  }
}
