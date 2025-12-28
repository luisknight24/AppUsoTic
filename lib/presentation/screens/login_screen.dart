import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
//import 'package:url_launcher/url_launcher.dart'; // Opcional: si tienes el paquete instalado
import '../widgets/custom_text_field.dart';
import '../../models/login_dto.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController correoController = TextEditingController();
  final TextEditingController claveController = TextEditingController();
  final AuthService authService = AuthService();

  bool isLoading = false;

  void _login() async {
    final loginDTO = LoginDTO(
      correo: correoController.text,
      clave: claveController.text,
    );

    // Validación antes de enviar
    if (!loginDTO.esValido()) {
      final correoError = loginDTO.validarCorreo();
      final claveError = loginDTO.validarClave();
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Error'),
          content: Text('${correoError ?? ''}\n${claveError ?? ''}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            )
          ],
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    final success = await authService.login(loginDTO);

    setState(() => isLoading = false);

    if (success != null) {
      print('Token JWT: ${success['token']}');
      context.go('/home'); // Redirige a la pantalla principal
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Usuario o contraseña incorrectos'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            )
          ],
        ),
      );
    }
  }

  // Función auxiliar para abrir web (Maquetada)
  Future<void> _launchWeb() async {
    final Uri url = Uri.parse('https://www.google.com');
    // if (!await launchUrl(url)) { throw Exception('Could not launch $url'); }
    debugPrint("Redirigiendo a: $url");
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Cabecera con fondo curvo
            Stack(
              children: [
                Container(
                  height: size.height * 0.35,
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(80),
                    ),
                  ),
                ),
                Positioned(
                  top: 80,
                  left: 30,
                  child: FadeInDown(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bienvenido',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 35,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Inicia sesión para gestionar tu crédito',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),

            // Formulario login
            FadeInUp(
              duration: const Duration(milliseconds: 800),
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                child: Column(
                  children: [
                    CustomTextField(
                      controller: correoController,
                      label: 'Correo Electrónico',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: claveController,
                      label: 'Contraseña',
                      icon: Icons.lock_outline,
                      isPassword: true,
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.push('/forgot-password'),
                        child: Text(
                          '¿Olvidaste tu contraseña?',
                          style: TextStyle(color: theme.primaryColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _login,
                        child: isLoading
                            ? const CircularProgressIndicator(
                            color: Colors.white)
                            : const Text(
                          'INGRESAR',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('¿No tienes cuenta?'),
                        TextButton(
                          onPressed: () => context.push('/register'),
                          child: Text(
                            'Regístrate',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.secondary),
                          ),
                        ),
                      ],
                    ),

                    // --- SECCIÓN AGREGADA: SOPORTE Y WEB ---
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Divider(color: Colors.grey.withOpacity(0.3)),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Centro de Ayuda",
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Opción Soporte Técnico
                        InkWell(
                          onTap: () {
                            // Lógica para llamar
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              children: [
                                Icon(Icons.support_agent, color: theme.primaryColor, size: 28),
                                const SizedBox(height: 5),
                                const Text('Soporte Técnico', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                const Text('0987034477', style: TextStyle(color: Colors.grey, fontSize: 11)),
                              ],
                            ),
                          ),
                        ),

                        // Opción Página Web
                        InkWell(
                          onTap: _launchWeb,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              children: [
                                Icon(Icons.language, color: theme.colorScheme.secondary, size: 28),
                                const SizedBox(height: 5),
                                const Text('Página Web', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                const Text('Ir al sitio', style: TextStyle(color: Colors.grey, fontSize: 11)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // ---------------------------------------

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}