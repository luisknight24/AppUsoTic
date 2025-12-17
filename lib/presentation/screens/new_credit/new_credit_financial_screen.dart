import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../../../models/credito_dto.dart';
import '../../../presentation/widgets/custom_text_field.dart';
import '../../../presentation/widgets/photo_upload_card.dart';
import '../../../services/firebase_service.dart';

class NewCreditFinancialScreen extends StatefulWidget {
  final int clienteId;
  final int tiendaId;

  const NewCreditFinancialScreen({super.key, required this.clienteId, required this.tiendaId});

  @override
  State<NewCreditFinancialScreen> createState() => _NewCreditFinancialScreenState();
}

class _NewCreditFinancialScreenState extends State<NewCreditFinancialScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final _montoCtrl = TextEditingController();
  final _entradaCtrl = TextEditingController();
  final _plazoCtrl = TextEditingController();

  // Variables de Estado
  String? _frecuenciaSeleccionada;
  File? _fotoContrato;
  File? _fotoCelular;
  File? _fotoCliente; // <--- NUEVO: Foto del Usuario

  bool _isLoading = false;

  // Variables calculadas
  double _valorCuota = 0.0;
  double _totalPagar = 0.0;

  final List<String> _frecuencias = ['Semanal', 'Quincenal', 'Mensual'];

  @override
  void initState() {
    super.initState();
    _montoCtrl.addListener(_calcularValores);
    _entradaCtrl.addListener(_calcularValores);
    _plazoCtrl.addListener(_calcularValores);
  }

  @override
  void dispose() {
    _montoCtrl.dispose();
    _entradaCtrl.dispose();
    _plazoCtrl.dispose();
    super.dispose();
  }

  // --- LÓGICA DE CALCULADORA ---
  void _calcularValores() {
    double monto = double.tryParse(_montoCtrl.text) ?? 0.0;
    double entrada = double.tryParse(_entradaCtrl.text) ?? 0.0;
    int plazo = int.tryParse(_plazoCtrl.text) ?? 0;

    if (monto > 0 && plazo > 0) {
      double saldoFinanciar = monto - entrada;

      // LÓGICA DE INTERÉS SEGÚN FRECUENCIA (Ejemplo)
      // Ajusta estos factores según tu regla de negocio real
      double factorInteres = 1.0;
      if (_frecuenciaSeleccionada == 'Semanal') factorInteres = 1.05;   // 5% interés global
      if (_frecuenciaSeleccionada == 'Quincenal') factorInteres = 1.10; // 10%
      if (_frecuenciaSeleccionada == 'Mensual') factorInteres = 1.15;   // 15%

      // Si no ha seleccionado frecuencia, usamos base plana
      double totalConInteres = saldoFinanciar * (_frecuenciaSeleccionada != null ? factorInteres : 1.0);

      setState(() {
        _totalPagar = totalConInteres;
        _valorCuota = totalConInteres / plazo;
      });
    } else {
      setState(() {
        _valorCuota = 0.0;
        _totalPagar = 0.0;
      });
    }
  }

  void _finalizarSolicitud() async {
    if (!_formKey.currentState!.validate()) return;

    if (_frecuenciaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona una frecuencia')));
      return;
    }

    // VALIDAMOS LAS 3 FOTOS AHORA
    if (_fotoContrato == null || _fotoCelular == null || _fotoCliente == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faltan fotos de evidencia (Contrato, Celular o Usuario)')));
      return;
    }

    setState(() => _isLoading = true);

    // Diálogo de carga bonito
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text("Subiendo evidencias...", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );

    try {
      final firebaseService = FirebaseService();

      // 1. Subir Fotos (Descomentar para producción)
      // String? urlContrato = await firebaseService.uploadImage(_fotoContrato!, 'contratos');
      // String? urlCelular = await firebaseService.uploadImage(_fotoCelular!, 'celulares');
      // String? urlCliente = await firebaseService.uploadImage(_fotoCliente!, 'clientes_selfies'); // <--- NUEVO

      await Future.delayed(const Duration(seconds: 2)); // Simulación

      if (mounted) Navigator.pop(context); // Cerrar diálogo de carga

      // 2. Crear DTO Crédito
      final credito = CreditoDTO(
        id: 0,
        clienteId: widget.clienteId,
        montoTotal: double.parse(_montoCtrl.text),
        entrada: _entradaCtrl.text.isEmpty ? 0.0 : double.parse(_entradaCtrl.text),
        plazoCuotas: int.parse(_plazoCtrl.text),
        frecuenciaPago: _frecuenciaSeleccionada!,
        valorPorCuota: _valorCuota,
        montoPendiente: _totalPagar,
        diaPago: DateTime.now(),
        estado: "PENDIENTE",
        // Aquí podrías agregar los campos de URLs si modificas el DTO, o enviarlos en otro endpoint
      );

      // 3. LLAMADA AL BACKEND
      // await creditoService.crearCredito(credito);

      if (mounted) {
        setState(() => _isLoading = false);
        _mostrarExito(credito.montoTotal);
      }

    } catch (e) {
      if (mounted) Navigator.pop(context); // Cerrar diálogo si falla
      //setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al procesar solicitud')));
    }
  }

  void _mostrarExito(double monto) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Column(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green, size: 60),
            SizedBox(height: 10),
            Text('¡Solicitud Enviada!'),
          ],
        ),
        content: Text('Tu crédito por \$$monto ha sido registrado y está en revisión.', textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(c);
              context.go('/home');
            },
            child: const Text('FINALIZAR'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Texto dinámico para la etiqueta de la cuota
    String etiquetaCuota = "Cuota Estimada";
    if (_frecuenciaSeleccionada != null) {
      etiquetaCuota = "Cuota $_frecuenciaSeleccionada";
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Paso 3: Cotizador y Envío')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // --- SECCIÓN CALCULADORA ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50, // Color suave de fondo
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, spreadRadius: 2)],
                ),
                child: Column(
                  children: [
                    const Text('RESUMEN DE PAGOS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2)),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('$etiquetaCuota:', style: const TextStyle(fontSize: 16)), // Texto dinámico
                        Text('\$${_valorCuota.toStringAsFixed(2)}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.primaryColor)),
                      ],
                    ),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider()),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Final (con interés):', style: TextStyle(fontWeight: FontWeight.w500)),
                        Text('\$${_totalPagar.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              CustomTextField(
                label: 'Precio Equipo (\$)',
                controller: _montoCtrl,
                keyboardType: TextInputType.number,
                icon: Icons.attach_money,
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 15),
              CustomTextField(
                  label: 'Entrada (\$)',
                  controller: _entradaCtrl,
                  keyboardType: TextInputType.number,
                  icon: Icons.money_off
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Plazo (Cuotas)',
                      controller: _plazoCtrl,
                      keyboardType: TextInputType.number,
                      icon: Icons.calendar_today,
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Frecuencia',
                        prefixIcon: const Icon(Icons.repeat),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                      ),
                      value: _frecuenciaSeleccionada,
                      items: _frecuencias.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                      onChanged: (v) {
                        setState(() {
                          _frecuenciaSeleccionada = v;
                        });
                        // Recalcular al cambiar la frecuencia para aplicar interés o actualizar etiqueta
                        _calcularValores();
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),
              const Divider(thickness: 2),
              const SizedBox(height: 10),
              const Text("EVIDENCIA DIGITAL", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
              const SizedBox(height: 15),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: PhotoUploadCard(label: 'Contrato', onImageSelected: (f) => _fotoContrato = f)),
                  const SizedBox(width: 10),
                  Expanded(child: PhotoUploadCard(label: 'Celular', onImageSelected: (f) => _fotoCelular = f)),
                ],
              ),
              const SizedBox(height: 15),

              // --- CAMPO NUEVO: FOTO USUARIO ---
              Center(
                child: SizedBox(
                  width: 160,
                  child: PhotoUploadCard(
                      label: 'Foto Cliente',
                      onImageSelected: (f) => _fotoCliente = f
                  ),
                ),
              ),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity, height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _finalizarSolicitud,
                  style: ElevatedButton.styleFrom(
                      elevation: 5,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                  ),
                  child: _isLoading
                      ? const Text('Enviando...', style: TextStyle(fontSize: 18))
                      : const Text('ENVIAR SOLICITUD', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}