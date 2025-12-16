import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/notificacion_dto.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // --- DATOS MOCK (Simulación del Backend) ---
    // Cuando tengas el servicio, esto se reemplazará por un FutureBuilder
    final List<NotificacionDTO> notificaciones = [
      NotificacionDTO(
          id: 1,
          clienteId: 1,
          tipo: "Aviso",
          mensaje: "Recuerda que tu pago vence en 3 días",
          fecha: DateTime.now().subtract(const Duration(hours: 2)),
          leida: false
      ),
      NotificacionDTO(
          id: 2,
          clienteId: 1,
          tipo: "Pago",
          mensaje: "Hemos recibido tu pago correctamente. ¡Gracias!",
          fecha: DateTime.now().subtract(const Duration(days: 5)),
          leida: true
      ),
      NotificacionDTO(
          id: 3,
          clienteId: 1,
          tipo: "Mora",
          mensaje: "Tu pago ha vencido. Evita recargos.",
          fecha: DateTime.now().subtract(const Duration(days: 10)),
          leida: true
      ),
    ];
    // -------------------------------------------

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Notificaciones', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: notificaciones.isEmpty
          ? const Center(child: Text("No tienes notificaciones nuevas"))
          : ListView.builder(
        itemCount: notificaciones.length,
        padding: const EdgeInsets.all(10),
        itemBuilder: (context, index) {
          final noti = notificaciones[index];
          return Card(
            elevation: noti.leida ? 0 : 3,
            color: noti.leida ? Colors.white : Colors.blue[50],
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getColorPorTipo(noti.tipo),
                child: Icon(_getIconPorTipo(noti.tipo), color: Colors.white, size: 20),
              ),
              title: Text(
                noti.tipo,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: noti.leida ? Colors.grey : Colors.black,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Text(noti.mensaje),
                  const SizedBox(height: 5),
                  Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(noti.fecha),
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                ],
              ),
              trailing: !noti.leida
                  ? const Icon(Icons.circle, color: Colors.blue, size: 12)
                  : null,
            ),
          );
        },
      ),
    );
  }

  // Helpers visuales para diferenciar tipos de notificación
  Color _getColorPorTipo(String tipo) {
    switch (tipo) {
      case "Pago": return Colors.green;
      case "Aviso": return Colors.orange;
      case "Mora": return Colors.red;
      default: return Colors.blue;
    }
  }

  IconData _getIconPorTipo(String tipo) {
    switch (tipo) {
      case "Pago": return Icons.check_circle_outline;
      case "Aviso": return Icons.notifications_active_outlined;
      case "Mora": return Icons.warning_amber_rounded;
      default: return Icons.info_outline;
    }
  }
}