import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/register_provider.dart';
import '../../models/credito_dto.dart';
import '../../data/services/auth_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/photo_upload_card.dart'; // IMPORTANTE
import '../../services/UsuarioRegistroData.dart';
import '../../models/cliente_dto.dart';
import '../../models/enviar_codigo_dto.dart';
import '../../services/ValidarCuenta.dart';
import '../../services/firebase_service.dart'; // IMPORTANTE

class CreditDataScreen extends StatefulWidget {


  const CreditDataScreen({super.key


  });

  @override
  State<CreditDataScreen> createState() => _CreditDataScreenState();
}

class _CreditDataScreenState extends State<CreditDataScreen> {
  UsuarioRegistroData registroData = UsuarioRegistroData();
  final _precioCtrl = TextEditingController();
  final _entradaCtrl = TextEditingController();
  final _cuotasCtrl = TextEditingController();
  final _marcaCtrl = TextEditingController();
  final _modeloCtrl = TextEditingController();
  // NUEVO: Controlador IMEI
  final _imeiCtrl = TextEditingController();

  String _frecuencia = 'Semanal';
  DateTime _fechaPago = DateTime.now();

  double _montoFinanciar = 0;
  double _valorCuota = 0;
  DateTime _proximaCuota = DateTime.now();

  // NUEVO: Variable para Tipo de Producto
  String _tipoProducto = 'Teléfono';
  final List<String> _tiposProducto = ['Teléfono', 'Televisor'];

  // VARIABLES PARA LAS FOTOS
  // File? _fotoContrato; // 📸 COMENTADO
  // File? _fotoCelular;  // 📸 COMENTADO
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _precioCtrl.addListener(_calcularValores);
    _entradaCtrl.addListener(_calcularValores);
    _cuotasCtrl.addListener(_calcularValores);
  }

  // NUEVO: Variable para el combo de cuotas
  int? _plazoSeleccionado;
  final List<int> _opcionesCuotas = [3, 6, 9, 12, 15, 18, 24];


  @override
  void dispose() {
    _precioCtrl.dispose(); _entradaCtrl.dispose(); _cuotasCtrl.dispose();
    _marcaCtrl.dispose();
    _modeloCtrl.dispose();
    _imeiCtrl.dispose(); // Dispose IMEI
    super.dispose();
  }

  void _calcularValores() {
    final precio = double.tryParse(_precioCtrl.text) ?? 0;
    final entrada = double.tryParse(_entradaCtrl.text) ?? 0;
    final cuotas = int.tryParse(_cuotasCtrl.text) ?? 1;

    setState(() {
      _montoFinanciar = precio - entrada;
      if (_montoFinanciar < 0) _montoFinanciar = 0;
      _valorCuota = (cuotas > 0) ? _montoFinanciar / cuotas : 0;
      _proximaCuota = _calcularProximaFecha(_fechaPago, _frecuencia);
    });
  }

  DateTime _calcularProximaFecha(DateTime fechaBase, String frecuencia) {
    switch (frecuencia) {
      case 'Semanal': return fechaBase.add(const Duration(days: 7));
      case 'Quincenal': return fechaBase.add(const Duration(days: 15));
      case 'Mensual': return DateTime(fechaBase.year, fechaBase.month + 1, fechaBase.day);
      default: return fechaBase.add(const Duration(days: 7));
    }
  }

  Future<void> _seleccionarFecha() async {
    final picked = await showDatePicker(
      context: context, initialDate: _fechaPago, firstDate: DateTime.now().toUtc(), lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() { _fechaPago = picked; _calcularValores(); });
    }
  }

  void _finalizarRegistro() async {
    if (_precioCtrl.text.isEmpty || _cuotasCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Define precio y cuotas')));
      return;
    }

    // --- VALIDACIÓN DE CUOTAS DINÁMICA ---
    final int cuotasIngresadas = int.tryParse(_cuotasCtrl.text) ?? 0;
    int maxCuotas = 24; // Default Mensual

    if (_frecuencia == 'Semanal') maxCuotas = 52;
    if (_frecuencia == 'Quincenal') maxCuotas = 48;
    if (_frecuencia == 'Mensual') maxCuotas = 24;

    if (cuotasIngresadas > maxCuotas) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Para $_frecuencia el máximo es $maxCuotas cuotas'), backgroundColor: Colors.red)
      );
      return;
    }
    // ------------------------------------

    // VALIDAR IMEI SI ES TELÉFONO
    if (_tipoProducto == 'Teléfono' && _imeiCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El IMEI es requerido para teléfonos'), backgroundColor: Colors.red));
      return;
    }

    // ------------------------------------

    /* 📸 VALIDACIÓN DE FOTOS COMENTADA
    // 1. VALIDAR FOTOS
    if (_fotoContrato == null || _fotoCelular == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Debes subir fotos de Contrato y Celular'), backgroundColor: Colors.red));
      return;
    }
    */

    // Guardar crédito en Provider

    setState(() => _isUploading = true);

    // Dialogo de Carga
    showDialog(
      context: context, barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text("Procesando solicitud...", style: TextStyle(fontWeight: FontWeight.bold))
          ]),
        ),
      ),
    );

    try {
      // final firebaseService = FirebaseService(); // 📸 COMENTADO

      // 2. SUBIR EVIDENCIAS
      // String? urlContrato = await firebaseService.uploadImage(_fotoContrato!, 'contratos'); // 📸 COMENTADO
      // String? urlCelular = await firebaseService.uploadImage(_fotoCelular!, 'celulares');   // 📸 COMENTADO

      /* 📸 VALIDACIÓN URL COMENTADA
      if (urlContrato == null || urlCelular == null) throw Exception("Error al subir evidencias");
      */

      // 🚨 CAMBIO: ELIMINADO EL Navigator.pop(context) TEMPRANO
      // if (mounted) Navigator.pop(context); // <--- ESTE SE ELIMINÓ

      // 3. CREAR DTO
      final credito = CreditoDTO(
        montoTotal: double.parse(_precioCtrl.text),
        entrada: double.tryParse(_entradaCtrl.text) ?? 0,
        plazoCuotas: int.parse(_cuotasCtrl.text) ,//_plazoSeleccionado!,
        frecuenciaPago: _frecuencia,
        diaPago: _fechaPago,
        valorPorCuota: _valorCuota,
        montoPendiente: _montoFinanciar,
        proximaCuota: _proximaCuota,
        proximaCuotaStr: DateFormat('yyyy-MM-dd').format(_proximaCuota),
        estado: 'Pendiente',
        fechaCreacion: DateTime.now().toUtc(),
        marca: _marcaCtrl.text,
        modelo: _modeloCtrl.text,
        estadoCuota: "Pendiente",
        abonadoTotal: 0.0,
        // ASIGNAMOS LAS URLS
        fotoContratoUrl: null, // urlContrato, // 📸 URL COMENTADA
        fotoCelularUrl: null,  // urlCelular,  // 📸 URL COMENTADA

        // NUEVOS CAMPOS PRODUCTO
        tipoProducto: _tipoProducto,
        imei: (_tipoProducto == 'Teléfono') ? _imeiCtrl.text : null,
      );

      final registerProvider = context.read<RegisterProvider>();
      registerProvider.setCredito(credito);

      // 4. ENVIAR CODIGO DE VERIFICACIÓN
      final usuarioFinal = registerProvider.getUsuarioFinal();
      final correoUser = usuarioFinal.correo;

      if (correoUser == null || correoUser.isEmpty) {
        if (mounted) Navigator.pop(context); // Cerrar loading si hay error
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Correo no disponible')));
        return;
      }

      final validarCuenta = ValidarCuenta();
      final enviado = await validarCuenta.enviarCodigoCompleto(usuarioFinal);

      // 🚨 CAMBIO: AHORA CERRAMOS EL LOADING AQUÍ, AL FINAL
      if (mounted) Navigator.pop(context);

      setState(() => _isUploading = false);

      if (enviado != null) {
        context.push('/verify-otp', extra: correoUser);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al enviar correo.'), backgroundColor: Colors.red));
      }

    } catch (e) {
      if (mounted) Navigator.pop(context);
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Paso 4: Crédito y Evidencias')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- RESUMEN ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: theme.primaryColor, borderRadius: BorderRadius.circular(15)),
              child: Column(
                children: [
                  const Text('Saldo a Financiar', style: TextStyle(color: Colors.white70)),
                  Text('\$${_montoFinanciar.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Divider(color: Colors.white24),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Cuota: \$${_valorCuota.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 16)),
                    Text('Prox: ${DateFormat('dd/MM').format(_proximaCuota)}', style: const TextStyle(color: Colors.greenAccent)),
                  ])
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- NUEVO: TIPO PRODUCTO Y MARCA ---
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Tipo Producto', border: OutlineInputBorder()),
                    value: _tipoProducto,
                    items: _tiposProducto.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (val) {
                      setState(() => _tipoProducto = val!);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: CustomTextField(label: 'Marca', controller: _marcaCtrl, icon: Icons.branding_watermark)),
              ],
            ),
            const SizedBox(height: 15),

            // --- NUEVO: MODELO Y IMEI (CONDICIONAL) ---
            Row(
              children: [
                // ✏️ CAMBIO ESTÉTICO: Ícono más general
                Expanded(child: CustomTextField(label: 'Modelo', controller: _modeloCtrl, icon: Icons.devices)),
                // Mostrar IMEI solo si es Teléfono
                if (_tipoProducto == 'Teléfono') ...[
                  const SizedBox(width: 10),
                  Expanded(child: CustomTextField(label: 'IMEI', controller: _imeiCtrl, icon: Icons.qr_code)),
                ]
              ],
            ),

            const SizedBox(height: 15),

            // --- CAMPOS ---
            // ✏️ CAMBIO ESTÉTICO: Ícono más general
            CustomTextField(label: 'Precio Equipo (Total)', controller: _precioCtrl, keyboardType: TextInputType.number, icon: Icons.monetization_on_outlined),
            const SizedBox(height: 15),
            CustomTextField(label: 'Entrada (Pago Inicial)', controller: _entradaCtrl, keyboardType: TextInputType.number, icon: Icons.monetization_on),
            const SizedBox(height: 15),


            CustomTextField(label: 'Plazo (Cuotas)', controller: _cuotasCtrl, keyboardType: TextInputType.number, icon: Icons.calendar_view_week),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _frecuencia,
              decoration: InputDecoration(labelText: 'Frecuencia de Pago', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              items: ['Semanal', 'Quincenal', 'Mensual'].map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
              onChanged: (val) { setState(() { _frecuencia = val!; _calcularValores(); }); },
            ),
            const SizedBox(height: 20),
            ListTile(
              title: const Text('Fecha de Inicio / Pago'), subtitle: Text(DateFormat('dd MMMM yyyy').format(_fechaPago)),
              trailing: const Icon(Icons.calendar_today),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.withOpacity(0.5))),
              onTap: _seleccionarFecha,
            ),

            const SizedBox(height: 30),

            /* 📸 SECCIÓN EVIDENCIAS COMENTADA
            // --- SECCIÓN EVIDENCIAS (NUEVO) ---
            const Divider(),
            const Text("EVIDENCIA DIGITAL", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(child: PhotoUploadCard(label: 'Foto Contrato *', onImageSelected: (f) => _fotoContrato = f)),
                const SizedBox(width: 10),
                Expanded(child: PhotoUploadCard(label: 'Foto Celular *', onImageSelected: (f) => _fotoCelular = f)),
              ],
            ),
            */

            const SizedBox(height: 40),
            SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: _finalizarRegistro,
                    child: const Text('FINALIZAR Y VERIFICAR', style: TextStyle(fontSize: 16))
                )
            ),
          ],
        ),
      ),
    );
  }
}