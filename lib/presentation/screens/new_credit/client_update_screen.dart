import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../providers/register_provider.dart'; // Para leer datos actuales
import '../../../models/detalle_cliente_dto.dart';
import '../../../presentation/widgets/custom_text_field.dart';

class ClientUpdateScreen extends StatefulWidget {
  final int clienteId;
  const ClientUpdateScreen({super.key, required this.clienteId});

  @override
  State<ClientUpdateScreen> createState() => _ClientUpdateScreenState();
}

class _ClientUpdateScreenState extends State<ClientUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cedulaCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // MOCK: Aquí cargarías los datos reales del cliente usando widget.clienteId
    // Por ahora usamos los del provider o dejamos vacíos
    final user = context.read<RegisterProvider>().usuario;
    _nombreCtrl.text = user.nombreApellidos ?? '';
    // _cedulaCtrl.text = ... (Cargar desde API)
  }

  void _actualizarDatos() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // 1. Crear DTO para PUT
    final detalleUpdate = DetalleClienteDTO(
      numeroCedula: _cedulaCtrl.text,
      nombreApellidos: _nombreCtrl.text,
      telefono: _telefonoCtrl.text,
      direccion: _direccionCtrl.text,
      // Las fotos no se cambian aquí, se mantienen las viejas o se envían nulas
    );

    // 2. LLAMADA AL BACKEND (PUT /Cliente/{id})
    // await clienteService.updateCliente(widget.clienteId, detalleUpdate);
    await Future.delayed(const Duration(seconds: 1)); // Simulación

    if (mounted) {
      setState(() => _isLoading = false);
      // Avanzar al siguiente paso: TIENDA
      context.push('/new-credit-store', extra: widget.clienteId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paso 1: Validar Mis Datos')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(child: const Text('Verifica tu información actual', style: TextStyle(fontSize: 16, color: Colors.grey))),
              const SizedBox(height: 20),

              CustomTextField(
                label: 'Cédula', controller: _cedulaCtrl, keyboardType: TextInputType.number,
                validator: (v) => v!.length != 10 ? '10 dígitos requeridos' : null,
              ),
              const SizedBox(height: 15),

              CustomTextField(
                label: 'Nombre Completo', controller: _nombreCtrl, icon: Icons.person,
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 15),

              CustomTextField(
                label: 'Teléfono Actual', controller: _telefonoCtrl, keyboardType: TextInputType.phone, icon: Icons.phone,
                validator: (v) => v!.length < 10 ? 'Teléfono válido requerido' : null,
              ),
              const SizedBox(height: 15),

              CustomTextField(
                label: 'Dirección Domiciliaria', controller: _direccionCtrl, icon: Icons.location_on,
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity, height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _actualizarDatos,
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('CONFIRMAR Y CONTINUAR'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}