import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trabajo1/models/notificacion_dto.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class NotificacionService {
  final String baseUrl = "http://192.168.100.13:7166/api";
 final storage = const FlutterSecureStorage();
  // 🟢 CACHÉ EN MEMORIA
  List<NotificacionDTO>? _cacheCreditos;

 Future<List<NotificacionDTO>> getNotificaciones({bool forceRefresh = false}) async {

    // 1️⃣ Si hay caché y no forzamos refresh → devolver
    if (_cacheCreditos != null && !forceRefresh) {
      print("⚡ Notificacion desde caché");
      return _cacheCreditos!;
    }

    final token = await storage.read(key: 'jwt_token');
    if (token == null) {
      throw Exception("Token no encontrado. Usuario no autenticado.");
    }

    final url = Uri.parse('$baseUrl/Notificacion/pendientesNotApp');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print("🌐 Notificacion desde API");

    if (response.statusCode == 200) {
      final List decoded = jsonDecode(response.body);

      _cacheCreditos = decoded
          .map((item) => NotificacionDTO.fromJson(item))
          .toList();

      return _cacheCreditos!;
    } else {
      throw Exception("Error al obtener las notificaciones:  ${response.statusCode} - ${response.body}");
    }
  }

  // 🧹 Limpiar caché
  void clearCache() {
    _cacheCreditos = null;
  }
}