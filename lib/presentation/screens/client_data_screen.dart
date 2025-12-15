import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/register_provider.dart';
import '../../models/detalle_cliente_dto.dart'; // <--- IMPORT DTO
import '../widgets/custom_text_field.dart';
import '../widgets/photo_upload_card.dart';
import '../../services/UsuarioRegistroData.dart';
import '../../services/firebase_service.dart';
import '../../models/cliente_dto.dart';

class ClientDataScreen extends StatefulWidget {
  const ClientDataScreen({super.key});

  @override
  State<ClientDataScreen> createState() => _ClientDataScreenState();
}

class _ClientDataScreenState extends State<ClientDataScreen> {
  bool _isUploading = false;
    UsuarioRegistroData registroData = UsuarioRegistroData();
  final _formKey = GlobalKey<FormState>();
  final _cedulaCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();

  File? _fotoCliente;
  File? _fotoCelular;
  File? _fotoContrato;

  @override
  void initState() {
    super.initState();
    final nombreRegistrado = context.read<RegisterProvider>().usuario.nombreApellidos;
    _nombreCtrl.text = nombreRegistrado ?? '';
  }

  @override
  void dispose() {
    _cedulaCtrl.dispose(); _nombreCtrl.dispose(); _telefonoCtrl.dispose(); _direccionCtrl.dispose();
    super.dispose();
  }

    void _onNextPressed() async  {
    // 1. Validar Inputs
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 2. Validar TODAS las Fotos (Corrección)
    if (_fotoCliente == null || _fotoCelular == null || _fotoContrato == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Debes subir las 3 fotos obligatorias (Cliente, Celular y Contrato)'),
            backgroundColor: Colors.red
        ),
      );
      return;
    }

  // 3. Mostrar diálogo de carga
  setState(() => _isUploading = true);

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const PopScope(
      canPop: false,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 15),
            Text(
              "Subiendo imágenes a la nube...",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    ),
  );



try {
    final firebaseService = FirebaseService();

    // 4. Subir imágenes a Firebase Storage
    final String? urlCliente =
        await firebaseService.uploadImage(_fotoCliente!, 'clientes');
    final String? urlCelular =
        await firebaseService.uploadImage(_fotoCelular!, 'celulares');
    final String? urlContrato =
        await firebaseService.uploadImage(_fotoContrato!, 'contratos');

    // Cerrar diálogo
    if (mounted) Navigator.pop(context);
    setState(() => _isUploading = false);

    // 5. Verificar errores
    if (urlCliente == null || urlCelular == null || urlContrato == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al subir imágenes. Verifica tu internet.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 6. Crear DTO CON URLs REALES
    final detalle = DetalleClienteDTO(
      numeroCedula: _cedulaCtrl.text,
      nombreApellidos: _nombreCtrl.text,
      telefono: _telefonoCtrl.text,
      direccion: _direccionCtrl.text,
      fotoClienteUrl: urlCliente,
      fotoCelularEntregadoUrl: urlCelular,
      fotoContrato: urlContrato,
    );

    // 7. Guardar en Provider
    final registerProvider = context.read<RegisterProvider>();
    registerProvider.setDetalleCliente(detalle);

    // 8. Guardar también en tu objeto local
    registroData.cliente ??= ClienteDTO();
    registroData.cliente!.detalleCliente = detalle;

    // --- Debug ---
    print("=== Datos del Cliente ===");
    print("Cédula: ${detalle.numeroCedula}");
    print("Nombre: ${detalle.nombreApellidos}");
    print("Foto Cliente: ${detalle.fotoClienteUrl}");
    print("Foto Celular: ${detalle.fotoCelularEntregadoUrl}");
    print("Foto Contrato: ${detalle.fotoContrato}");
    print("=========================");

    // 9. Navegar
    if (mounted) context.push('/store-data');

  } catch (e) {
    if (mounted) Navigator.pop(context);
    setState(() => _isUploading = false);
    print("Error crítico Firebase: $e");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ocurrió un error al procesar el registro'),
        backgroundColor: Colors.red,
      ),
    );
  }







/*


    final registerProvider = context.read<RegisterProvider>();
final detalle = DetalleClienteDTO(
  numeroCedula: _cedulaCtrl.text,
  nombreApellidos: _nombreCtrl.text,
  telefono: _telefonoCtrl.text,
  direccion: _direccionCtrl.text,
  fotoClienteUrl: "https://github.com/AnJoGar?tab=repositories",
  fotoCelularEntregadoUrl: "https://github.com/AnJoGar?tab=repositories",
  fotoContrato: "https://github.com/AnJoGar?tab=repositories",
);
// Guardar el detalle del cliente en registroData
  registroData.cliente ??= ClienteDTO(); // Crear cliente si no existe
registroData.cliente!.detalleCliente = detalle;
registerProvider.setDetalleCliente(detalle);
// Debug
print("Correo desde Provider: ${registerProvider.usuario.correo}");
// Si quieres guardar las fotos en el DTO, podrías hacer algo así
//registroData.cliente!.detalleCliente!.fotoClienteUrl = _fotoCliente;
//registroData.cliente!.detalleCliente!.fotoCelularEntregadoUrl = _fotoCelular;
//registroData.cliente!.detalleCliente!.fotoContrato = _fotoContrato;

  // --- Console log ---
  print("=== Datos del Cliente Registrado ===");
  print("Cédula: ${detalle.numeroCedula}");
  print("Nombre: ${detalle.nombreApellidos}");
  print("Teléfono: ${detalle.telefono}");
  print("Dirección: ${detalle.direccion}");
  print("Foto Cliente URL: ${detalle.fotoClienteUrl}");
  print("Foto Celular URL: ${detalle.fotoCelularEntregadoUrl}");
  print("Foto Contrato URL: ${detalle.fotoContrato}");
  print("=== Fin de Datos ===");
    context.push('/store-data');
    */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paso 2: Datos Cliente'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Información Personal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 15),
              CustomTextField(
                label: 'Número de Cédula', controller: _cedulaCtrl, keyboardType: TextInputType.number,
                validator: (v) => (v!.isEmpty || v.length != 10) ? 'Debe tener 10 dígitos' : null,
              ),
              const SizedBox(height: 15),
              CustomTextField(
                label: 'Nombres y Apellidos', controller: _nombreCtrl, icon: Icons.person,
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 15),
              CustomTextField(
                label: 'Teléfono', controller: _telefonoCtrl, keyboardType: TextInputType.phone, icon: Icons.phone,
                validator: (v) => (v!.isEmpty || v.length != 10) ? 'Debe tener 10 dígitos' : null,
              ),
              const SizedBox(height: 15),
              CustomTextField(
                label: 'Dirección / Sector', controller: _direccionCtrl, icon: Icons.location_on,
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 30),
              const Text('Evidencia Digital', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: PhotoUploadCard(label: 'Foto Cliente *', onImageSelected: (f) => _fotoCliente = f)),
                  const SizedBox(width: 15),
                  Expanded(child: PhotoUploadCard(label: 'Foto Celular', onImageSelected: (f) => _fotoCelular = f)),
                ],
              ),
              const SizedBox(height: 15),
              PhotoUploadCard(label: 'Foto Contrato', onImageSelected: (f) => _fotoContrato = f),
              const SizedBox(height: 40),
              SizedBox(width: double.infinity, height: 55, child: ElevatedButton(onPressed: _onNextPressed, child: const Text('SIGUIENTE: DATOS TIENDA'))),
            ],
          ),
        ),
      ),
    );
  }
}