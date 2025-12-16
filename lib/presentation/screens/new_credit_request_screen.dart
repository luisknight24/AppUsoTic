import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../../models/credito_dto.dart'; // <--- Usamos el DTO existente
import '../widgets/custom_text_field.dart';

class NewCreditRequestScreen extends StatefulWidget {
  final int clienteId; // Necesitamos saber quién pide el crédito
  const NewCreditRequestScreen({super.key, required this.clienteId});

  @override
  State<NewCreditRequestScreen> createState() => _NewCreditRequestScreenState();
}

class _NewCreditRequestScreenState extends State<NewCreditRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final _montoCtrl = TextEditingController();
  final _entradaCtrl = TextEditingController(); // Agregado para respetar tu DTO
  final _plazoCtrl = TextEditingController();

  String? _frecuenciaSeleccionada;
  bool _isLoading = false;

  final List<String> _frecuencias = ['Semanal', 'Quincenal', 'Mensual'];

  @override
  void dispose() {
    _montoCtrl.dispose();
    _entradaCtrl.dispose();
    _plazoCtrl.dispose();
    super.dispose();
  }

  void _enviarSolicitud() async {
    if (!_formKey.currentState!.validate()) return;
    if (_frecuenciaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona una frecuencia de pago')));
      return;
    }

    setState(() => _isLoading = true);

    // --- LÓGICA DE MAPEO (Aquí reutilizamos tu CreditoDTO) ---
    // Creamos el objeto tal cual lo espera tu API en el endpoint de Crear/Guardar
    final solicitudCredito = CreditoDTO(
      id: 0, // 0 porque es nuevo
      clienteId: widget.clienteId,
      montoTotal: double.parse(_montoCtrl.text),
      entrada: _entradaCtrl.text.isEmpty ? 0.0 : double.parse(_entradaCtrl.text),
      plazoCuotas: int.parse(_plazoCtrl.text),
      frecuenciaPago: _frecuenciaSeleccionada!,
      diaPago: DateTime.now(), // Por defecto hoy, o podrías agregar un DatePicker
      estado: "PENDIENTE", // Puedes manejar estados si tu API lo requiere
      // Los demás campos calculados (valorPorCuota, etc.) los suele calcular el backend
    );

    // --- AQUÍ IRÍA LA LLAMADA AL SERVICIO ---
    // Ejemplo: await _creditoService.guardarCredito(solicitudCredito);

    // Simulación de espera (Maquetación)
    await Future.delayed(const Duration(seconds: 2));
    final exito = true;

    if (mounted) setState(() => _isLoading = false);

    if (exito && mounted) {
      // Feedback visual
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => AlertDialog(
          title: const Text('Solicitud Enviada'),
          content: Text(
              'Se ha generado la solicitud por \$${solicitudCredito.montoTotal}. '
                  'Tu estado actual es PENDIENTE.'
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(c);
                context.go('/home'); // Regresar al dashboard
              },
              child: const Text('ACEPTAR'),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitar Crédito', style: TextStyle(color: Colors.white)),
        backgroundColor: theme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(
                child: Text('Configura tu nuevo equipo', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.primaryColor)),
              ),
              const SizedBox(height: 10),
              FadeInDown(
                child: const Text('Ingresa los valores para calcular tu plan de pagos.', style: TextStyle(color: Colors.grey)),
              ),
              const SizedBox(height: 30),

              // CAMPO: MONTO
              FadeInUp(
                child: CustomTextField(
                  label: 'Precio del Equipo / Monto (\$)',
                  controller: _montoCtrl,
                  icon: Icons.attach_money,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Requerido';
                    if (double.tryParse(v) == null || double.parse(v) <= 0) return 'Inválido';
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),

              // CAMPO: ENTRADA (Opcional según tu lógica, pero el DTO lo tiene)
              FadeInUp(
                delay: const Duration(milliseconds: 100),
                child: CustomTextField(
                  label: 'Entrada Inicial (\$) (Opcional)',
                  controller: _entradaCtrl,
                  icon: Icons.money_off,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              const SizedBox(height: 20),

              // CAMPO: PLAZO Y FRECUENCIA
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Plazo (Cuotas)',
                        controller: _plazoCtrl,
                        icon: Icons.calendar_today,
                        keyboardType: TextInputType.number,
                        validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
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
                        onChanged: (v) => setState(() => _frecuenciaSeleccionada = v),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 50),

              FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: SizedBox(
                  width: double.infinity, height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _enviarSolicitud,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('CALCULAR Y SOLICITAR', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}