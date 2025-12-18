import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trabajo1/models/credito_dto.dart';
import 'package:trabajo1/models/CreditoMostrarDTO.dart';
import 'package:signalr_core/signalr_core.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:flutter/material.dart';

class creditoMostrarHome {
  final String baseUrl = "http://192.168.100.13:7166/api";
  final String baseUrl1 = "http://192.168.100.13:7166";
  final storage = const FlutterSecureStorage();
  // WebSocket
  late HubConnection _connection;
  final isLoadingNotifier = ValueNotifier<bool>(false);
  // 🟢 CACHÉ EN MEMORIA
  List<CreditoMostrarDTO>? _cacheCreditos;
  // 🟢 Notificador para UI
 // final creditosNotifier = ValueNotifier<List<CreditoMostrarDTO>>([]);
  final mensajeNotifier = ValueNotifier<String>("");
final creditosNotifier = ValueNotifier<List<CreditoMostrarDTO>?>(null);
final cargandoNotifier = ValueNotifier<bool>(false);

  /// Conectar al WebSocket de SignalR
  /// 🔌 Conectar a SignalR
  /// 🔌 Conectar a AdminHub
  /*Future<void> connectSignalR() async {
  print("🟡 Iniciando conexión SignalR...");

  // Construir la conexión
  _connection = HubConnectionBuilder()
      .withUrl(
        '$baseUrl1/adminhub', // 👈 la URL de tu Hub
        HttpConnectionOptions(
          accessTokenFactory: () async {
            final token = await storage.read(key: 'jwt_token');
            debugPrint("🔑 Token enviado a SignalR: ${token != null}");
            return token; // mismo token que la API
          },
          logging: (level, message) => debugPrint("📡 SignalR: $message"),
        ),
      )
      .build();

  // Evento cuando el backend envía "CreditoActualizado"
  _connection.on('CreditoActualizado', (arguments) {
    
    if (arguments == null || arguments.isEmpty) {
      print("❌ Argumentos vacíos");
      return;
    }

    // Convertir a DTO
    final data = arguments[0] as Map<String, dynamic>;
    final creditoActualizado = CreditoMostrarDTO.fromJson(data);
debugPrint("🔔 Evento CreditoActualizado recibido");
  debugPrint("🔔 Evento CreditoActualizado recibido: $arguments");
  if (arguments == null || arguments.isEmpty) return;

 
  debugPrint("📌 Datos recibidos: $data");
    print("🔄 Crédito actualizado: ${creditoActualizado.id} | Monto pendiente: ${creditoActualizado.montoPendiente}");

    // Actualizar caché
    final index = _cacheCreditos?.indexWhere((c) => c.id == creditoActualizado.id);

    if (index != null && index >= 0) {
      _cacheCreditos![index] = creditoActualizado;
      debugPrint("♻️ Crédito actualizado en caché");
    } else {
      _cacheCreditos ??= [];
      _cacheCreditos!.add(creditoActualizado);
      print("➕ Crédito agregado a caché");
    }

    // Notificar UI
    creditosNotifier.value = List.from(_cacheCreditos!);
    mensajeNotifier.value = "Crédito actualizado";
    print("🚀 UI notificada");
  });

  // Evento cuando la conexión se cierra
  _connection.onclose((error) {
    print("⚡ SignalR desconectado: $error");
  });

  // Iniciar conexión
  try {
    await _connection.start();
    print("✅ SignalR conectado");
  } catch (e) {
    print("❌ Error conectando SignalR: $e");
  }
}


  /// 🔌 Desconectar
  Future<void> disconnectSignalR() async {

    _connection.onclose((error) {
  print("⚡ SignalR desconectado: $error");
});

_connection.onreconnecting((error) {
  print("🔄 SignalR reconectando: $error");
});

_connection.onreconnected((id) {
  print("✅ SignalR reconectado: $id");
});
    await _connection.stop();
  }

*/

  Future<void> connectSignalR1() async {
    debugPrint("🟡 Conectando SignalR...");

    final token = await storage.read(key: 'jwt_token');

    _connection = HubConnectionBuilder()
        .withUrl(
          '$baseUrl1/adminhub',
          HttpConnectionOptions(accessTokenFactory: () async => token),
        )
        .build();

    // 🔔 Evento crédito actualizado
    _connection.on('CreditoActualizado', (args) {
      if (args == null || args.isEmpty) return;

      final data = args.first as Map<String, dynamic>;
      final credito = CreditoMostrarDTO.fromJson(data);

      // Inicializar caché si es null
      final cache = _cacheCreditos ??= [];

      // Buscar índice
      final index = cache.indexWhere((c) => c.id == credito.id);

      if (index >= 0) {
        cache[index] = credito;
      } else {
        cache.add(credito);
      }

      // 🔥 Notificar solo UNA vez
      creditosNotifier.value = List.unmodifiable(cache);
      mensajeNotifier.value = "Crédito actualizado";
    });

    // 🔌 Ciclo de vida de conexión
    _connection.onclose((e) => debugPrint("⚡ SignalR cerrado: $e"));
    _connection.onreconnecting((e) => debugPrint("🔄 Reconectando..."));
    _connection.onreconnected((id) => debugPrint("✅ Reconectado"));

    try {
      await _connection.start();
      debugPrint("✅ SignalR conectado");
    } catch (e) {
      debugPrint("❌ Error SignalR: $e");
    }
  }


Future<void> connectSignalR() async {
  debugPrint("🟡 Iniciando conexión SignalR");

  final token = await storage.read(key: 'jwt_token');

  // 🔐 Verificar token
  if (token == null || token.isEmpty) {
    debugPrint("❌ TOKEN NULL O VACÍO");
    return;
  }
  debugPrint("🔐 Token OK: ${token.substring(0, 15)}...");

  final hubUrl = '$baseUrl1/adminhub';
  debugPrint("🌐 URL SignalR: $hubUrl");

  _connection = HubConnectionBuilder()
      .withUrl(
        hubUrl,
        HttpConnectionOptions(
          accessTokenFactory: () async {
            debugPrint("🔁 SignalR solicitó token");
            return token;
          },
        ),
      )
      .build();

  // 📡 Evento crédito actualizado
  _connection.on('CreditoActualizado', (args) {
    debugPrint("📩 Evento CreditoActualizado recibido");
    debugPrint("📦 Args: $args");

    if (args == null || args.isEmpty) {
      debugPrint("⚠️ Args vacíos");
      return;
    }

    try {
      final data = Map<String, dynamic>.from(args.first);
      debugPrint("📄 Data parseada: $data");

      final credito = CreditoMostrarDTO.fromJson(data);

      final cache = _cacheCreditos ??= [];

      final index = cache.indexWhere((c) => c.id == credito.id);
      debugPrint("🔎 Índice encontrado: $index");

      if (index >= 0) {
        cache[index] = credito;
        debugPrint("✏️ Crédito actualizado en caché");
      } else {
        cache.add(credito);
        debugPrint("➕ Crédito agregado a caché");
      }

      creditosNotifier.value = List.unmodifiable(cache);
      mensajeNotifier.value = "Crédito actualizado";

      debugPrint("✅ Notificadores actualizados");
    } catch (e, s) {
      debugPrint("❌ Error procesando evento: $e");
      debugPrint("📛 Stack: $s");
    }
  });

  // 🔌 Ciclo de vida de conexión
  _connection.onclose((e) {
    debugPrint("⚡ SignalR cerrado");
    debugPrint("📛 Error: $e");
  });

  _connection.onreconnecting((e) {
    debugPrint("🔄 SignalR reconectando");
    debugPrint("📛 Error: $e");
  });

  _connection.onreconnected((id) {
    debugPrint("✅ SignalR reconectado - ConnectionId: $id");
  });

  try {
    debugPrint("🚀 Intentando conectar SignalR...");
    await _connection.start();
    debugPrint("✅ SignalR CONECTADO CORRECTAMENTE");
    debugPrint("🆔 ConnectionId: ${_connection.connectionId}");
  } catch (e, s) {
    debugPrint("❌ ERROR AL CONECTAR SIGNALR");
    debugPrint("📛 Error: $e");
    debugPrint("📛 Stack: $s");
  }
}

  /// 🔌 Desconectar
  Future<void> disconnectSignalR() async {
    await _connection.stop();
  }

  Future<List<CreditoMostrarDTO>> getCreditos1({
    bool forceRefresh = false,
  }) async {
    debugPrint("🟡 getCreditos() llamado | forceRefresh: $forceRefresh");
    isLoadingNotifier.value = true;

    try {
      // 1️⃣ Usar caché si existe
      if (_cacheCreditos != null && !forceRefresh) {
        creditosNotifier.value = List.from(_cacheCreditos!);
        return _cacheCreditos!;
      }

      // 2️⃣ Leer token
      final token = await storage.read(key: 'jwt_token');
      if (token == null) {
        throw Exception("Token no encontrado.");
      }
      // 3️⃣ Llamada HTTP
      final url = Uri.parse('$baseUrl/Credito/pendientesApp');

      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      // 4️⃣ Procesar respuesta
      if (response.statusCode == 200) {
        final List decoded = jsonDecode(response.body);

        _cacheCreditos = decoded
            .map((e) => CreditoMostrarDTO.fromJson(e))
            .toList();
        // Notificar UI
        creditosNotifier.value = List.from(_cacheCreditos!);
        return _cacheCreditos!;
      } else {
        throw Exception("Error API");
      }
    } finally {
      isLoadingNotifier.value = false;
    }
  }

  Future<void> getCreditos({bool forceRefresh = false}) async {
  cargandoNotifier.value = true;

  try {
    if (_cacheCreditos != null && !forceRefresh) {
      creditosNotifier.value = List.unmodifiable(_cacheCreditos!);
      return;
    }

    final token = await storage.read(key: 'jwt_token');
    if (token == null) throw Exception("Token no encontrado");

    final response = await http.get(
      Uri.parse('$baseUrl/Credito/pendientesApp'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List decoded = jsonDecode(response.body);
      _cacheCreditos = decoded.map((e) => CreditoMostrarDTO.fromJson(e)).toList();
      creditosNotifier.value = List.unmodifiable(_cacheCreditos!);
    } else {
      throw Exception("Error API: ${response.statusCode}");
    }
  } finally {
    cargandoNotifier.value = false;
  }
}
  // 🧹 Limpiar caché
  void clearCache() {
    _cacheCreditos = null;
  }


  
Future<CreditoDTO> guardarCredito(CreditoDTO tienda) async {
  final token = await storage.read(key: 'jwt_token');

  if (token == null) {
    throw Exception("Token no encontrado. Usuario no autenticado.");
  }

  final url = Uri.parse('$baseUrl/Credito/GuardarJWT');

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(tienda.toJson()),
  );

  print("Respuesta API Guardar Tienda: ${response.body}");

  if (response.statusCode == 200) {
    final decoded = jsonDecode(response.body);

    if (decoded['status'] == true) {
      // 🔄 Limpiamos caché para que al listar se refresque
      clearCache();

      return CreditoDTO.fromJson(decoded['value']);
    } else {
      throw Exception(decoded['msg']);
    }
  } else {
    throw Exception("Error al guardar tienda: ${response.statusCode}");
  }
}
}
