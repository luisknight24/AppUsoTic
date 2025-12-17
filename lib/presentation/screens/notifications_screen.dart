import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/notificacion_dto.dart';

import '../../services/notificacion_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => NotificationsScreenState();
}

class NotificationsScreenState extends State<NotificationsScreen>  {
 
  final _formKey = GlobalKey<FormState>();
  late Future<List<NotificacionDTO>> _futureNotificaciones;
  final _notificacionService = NotificacionService();


    @override
  void initState() {
    super.initState();
     _futureNotificaciones = _notificacionService.getNotificaciones();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Notificaciones', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<List<NotificacionDTO>>(
        future: _futureNotificaciones,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No tienes notificaciones nuevas"));
          }

          final notificaciones = snapshot.data!;

          return ListView.builder(
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
