import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/HistoriaAppDTO.dart';

class HistorialService {
  final String baseUrl = "https://apicredito2-8.onrender.com/api"; // Tu URL
  final storage = const FlutterSecureStorage();

  // Notifier para actualizar la UI
  final historialNotifier = ValueNotifier<List<HistoriaAppDTO>?>(null);
  final cargandoNotifier = ValueNotifier<bool>(false);

  Future<void> getHistorialPagos({bool forceRefresh = false}) async {
    cargandoNotifier.value = true;

    // Si ya tenemos datos y no forzamos, no recargamos (Opcional)
    // if (historialNotifier.value != null && !forceRefresh) {
    //   cargandoNotifier.value = false;
    //   return;
    // }

    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) throw Exception("Sin autenticación");

      // 📝 Endpoint Maquetado: Ajusta la ruta según tu API real
      final url = Uri.parse('$baseUrl/Credito/HistorialPagos');

      debugPrint("🔵 Consultando historial: $url");

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> decoded = jsonDecode(response.body);

        // Mapeamos la lista
        final listaHistorial = decoded.map((e) => HistoriaAppDTO.fromJson(e)).toList();

        // Actualizamos el estado
        historialNotifier.value = listaHistorial;
      } else {
        debugPrint("❌ Error API Historial: ${response.statusCode}");
        // Si falla, podrías limpiar o manejar error
        // historialNotifier.value = [];
      }
    } catch (e) {
      debugPrint("❌ Error servicio historial: $e");
      // MOCK DE RESPALDO PARA PRUEBAS VISUALES SI FALLA LA RED
      await Future.delayed(const Duration(seconds: 1));
      historialNotifier.value = [
        HistoriaAppDTO(id: 1, proximaCuotaStr: "2023-10-15", montoPendiente: 150.00, abonadoCuota: 50.00, estadoCuota: "Pagada", clienteId: 1),
        HistoriaAppDTO(id: 1, proximaCuotaStr: "2023-10-22", montoPendiente: 100.00, abonadoCuota: 50.00, estadoCuota: "Pagada", clienteId: 1),
        HistoriaAppDTO(id: 1, proximaCuotaStr: "2023-10-29", montoPendiente: 50.00, abonadoCuota: 50.00, estadoCuota: "Pendiente", clienteId: 1),
        HistoriaAppDTO(id: 1, proximaCuotaStr: "2023-11-05", montoPendiente: 0.00, abonadoCuota: 0.00, estadoCuota: "Vencida", clienteId: 1),
      ];
    } finally {
      cargandoNotifier.value = false;
    }
  }
}