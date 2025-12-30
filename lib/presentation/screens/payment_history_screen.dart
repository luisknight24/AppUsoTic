/*
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../services/historial_service.dart';
import '../../models/HistoriaAppDTO.dart';

class PaymentHistoryScreen extends StatefulWidget {
  final int creditoId;
  const PaymentHistoryScreen({super.key,required this.creditoId});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {

  
  final HistorialService _historialService = HistorialService();

  @override
  void initState() {
    super.initState();
   _historialService.getHistorialPagos(creditoId: widget.creditoId);


    
    // 2. Conectamos SignalR para escuchar actualizaciones en tiempo real
    _historialService.connectSignalR();

  
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Historial de Pagos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: _historialService.cargandoNotifier,
        builder: (context, isLoading, _) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ValueListenableBuilder<List<HistoriaAppDTO>?>(
            valueListenable: _historialService.historialNotifier,
            builder: (context, historial, _) {
              if (historial == null || historial.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history_toggle_off, size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 15),
                      Text("No hay historial registrado", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: historial.length,
                itemBuilder: (context, index) {
                  final item = historial[index];
                  return FadeInUp(
                    delay: Duration(milliseconds: index * 100),
                    child: _HistoryCard(pago: item),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final HistoriaAppDTO pago;

  const _HistoryCard({required this.pago});

  @override
  Widget build(BuildContext context) {
    // Configuración de estilo según estado
    Color statusColor;
    IconData statusIcon;
    String estadoTexto = pago.estadoCuota.toUpperCase();

    if (estadoTexto.contains("PAGADA") || estadoTexto.contains("COMPLETO")) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (estadoTexto.contains("VENCIDA") || estadoTexto.contains("ATRASO")) {
      statusColor = Colors.red;
      statusIcon = Icons.warning;
    } else {
      statusColor = Colors.orange;
      statusIcon = Icons.access_time_filled;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border(left: BorderSide(color: statusColor, width: 5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "FECHA DE CORTE",
                      style: TextStyle(fontSize: 10, color: Colors.grey[600], fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pago.proximaCuotaStr,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 5),
                      Text(
                        estadoTexto,
                        style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _InfoColumn("Abonado", "\$${pago.abonadoCuota.toStringAsFixed(2)}", Colors.black),
                _InfoColumn("Pendiente", "\$${pago.montoPendiente.toStringAsFixed(2)}", Colors.grey[700]!),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _InfoColumn(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: valueColor)),
      ],
    );
  }
}
 */

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../services/historial_service.dart';
import '../../models/HistoriaAppDTO.dart';

class PaymentHistoryScreen extends StatefulWidget {
  final int creditoId;
  const PaymentHistoryScreen({super.key, required this.creditoId});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  final HistorialService _historialService = HistorialService();

  @override
  void initState() {
    super.initState();
    _historialService.getHistorialPagos(creditoId: widget.creditoId);
    _historialService.connectSignalR();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo más limpio para lista
      appBar: AppBar(
        title: const Text('Historial de Pagos',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          // --- ENCABEZADO DE LA LISTA ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(flex: 3, child: _HeaderTitle("FECHA")),
                Expanded(flex: 3, child: _HeaderTitle("ESTADO")),
                Expanded(flex: 2, child: _HeaderTitle("ABONO", align: TextAlign.end)),
                Expanded(flex: 2, child: _HeaderTitle("SALDO", align: TextAlign.end)),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),

          // --- LISTA DE DATOS ---
          Expanded(
            child: ValueListenableBuilder<bool>(
              valueListenable: _historialService.cargandoNotifier,
              builder: (context, isLoading, _) {
                if (isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ValueListenableBuilder<List<HistoriaAppDTO>?>(
                  valueListenable: _historialService.historialNotifier,
                  builder: (context, historial, _) {
                    if (historial == null || historial.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history_toggle_off,
                                size: 80, color: Colors.grey[300]),
                            const SizedBox(height: 15),
                            Text("No hay historial registrado",
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 16)),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: historial.length,
                      itemBuilder: (context, index) {
                        final item = historial[index];
                        return FadeInUp(
                          duration: const Duration(milliseconds: 300),
                          child: _HistoryRowItem(pago: item, index: index),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _HeaderTitle(String text, {TextAlign align = TextAlign.start}) {
    return Text(
      text,
      textAlign: align,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.grey[700],
      ),
    );
  }
}

class _HistoryRowItem extends StatelessWidget {
  final HistoriaAppDTO pago;
  final int index;

  const _HistoryRowItem({required this.pago, required this.index});

  @override
  Widget build(BuildContext context) {
    // Configuración de estilo según estado
    Color statusColor;
    String estadoTexto = pago.estadoCuota.toUpperCase();

    if (estadoTexto.contains("PAGADO") || estadoTexto.contains("COMPLETO")) {
      statusColor = Colors.green;
    } else if (estadoTexto.contains("VENCIDA") ||
        estadoTexto.contains("ATRASO")) {
      statusColor = Colors.red;
    } else {
      statusColor = Colors.orange;
    }

    // Color alternado para las filas (efecto cebra sutil)
    Color rowColor = (index % 2 == 0) ? Colors.white : Colors.grey[50]!;

    return Container(
      color: rowColor,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      child: Row(
        children: [
          // 1. FECHA
          Expanded(
            flex: 3,
            child: Text(
              pago.proximaCuotaStr,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87),
            ),
          ),

          // 2. ESTADO
          Expanded(
            flex: 3,
            child: Text(
              estadoTexto,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // 3. ABONADO
          Expanded(
            flex: 2,
            child: Text(
              "\$${pago.abonadoCuota.toStringAsFixed(2)}",
              textAlign: TextAlign.end,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ),

          // 4. PENDIENTE (SALDO)
          Expanded(
            flex: 2,
            child: Text(
              "\$${pago.montoPendiente.toStringAsFixed(2)}",
              textAlign: TextAlign.end,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w400, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }
}