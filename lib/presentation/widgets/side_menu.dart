import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/usuario_service.dart';

class SideMenu extends StatelessWidget {
  final String userName;
  final String userEmail;

  const SideMenu({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF1A237E), // Azul primario
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Color(0xFF1A237E)),
            ),
            accountName: Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: Text(userEmail),
          ),

          /*
          // --- OPCIÓN MI PERFIL ---
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Mi Perfil'),
            onTap: () {
              Navigator.pop(context); // 1. Cierra el drawer
              context.push('/profile'); // 2. Navega a la pantalla de perfil
            },
          ),

          // --- OPCIÓN CONFIGURACIÓN ---
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Configuración'),
            onTap: () {
              Navigator.pop(context); // 1. Cierra el drawer
              context.push('/settings'); // 2. Navega a la pantalla de configuración
            },
          ),
        */
          const Divider(),

          // --- OPCIÓN CERRAR SESIÓN ---
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
            onTap: () async {
              final usuarioService = UsuarioService();

              // Cierra el drawer antes de salir
              Navigator.pop(context);

              await usuarioService.logout(); // 🔥 Limpia storage/tokens

              if (context.mounted) {
                context.go('/login'); // Redirige al login borrando el historial
              }
            },
          ),
        ],
      ),
    );
  }
}