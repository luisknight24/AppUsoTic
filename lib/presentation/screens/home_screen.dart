import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import '../../models/credito_dto.dart';
import '../../models/tienda_dto.dart';
import '../../models/CreditoMostrarDTO.dart';
import '../widgets/credit_summary_card.dart';
import '../widgets/side_menu.dart';
import '../../services/creditoMostrarHome.dart';
import '../../services/tiendaService.dart';
import '../../models/tiendaMostrar_dto.dart';
import '../../services/usuario_service.dart';
import '../../models/ClienteMostrarDTO.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // DATOS FICTICIOS PARA MAQUETACIÓN (MOCKS)
  // Luego esto vendrá de tu API con un FutureBuilder o Provider
  final creditoMostrarHome _creditoService = creditoMostrarHome();
  late Future<List<CreditoMostrarDTO>> _futureCreditos;
  final tiendaService _tiendaService = tiendaService();
  late Future<List<tiendaMostrar_dto>> _Tiendas;
  final UsuarioService _clienteService = UsuarioService();
  late Future<ClienteMostrarDTO> _futureClientes;

  //final String _nombreUsuario = "aszcsz";
  final String _emailUsuario = "luis@ejemplo.com";

  final TiendaDTO _tiendaMock = TiendaDTO(
    nombreTienda: "Celulares El Centro",
    nombreEncargado: "Luis",
    telefono: "0999999999",
    direccion: "Av. Principal 123",
    //  fechaRegistro: DateTime.now(),
  );
  @override
  void initState() {
    super.initState();
    _futureCreditos = _creditoService.getCreditos();
    _Tiendas = _tiendaService.getTienda(); //
    _futureClientes = _clienteService.getCliente();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
        backgroundColor: theme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              context.push('/notifications');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sin notificaciones nuevas')),
              );
            },
          ),
        ],
      ),
      drawer: //SideMenu(userName: _nombreUsuario, userEmail: _emailUsuario),
      FutureBuilder<ClienteMostrarDTO>(
        future: _futureClientes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Drawer(); // Drawer vacío mientras carga
          }

          if (snapshot.hasError) {
            return Drawer(
              child: Center(child: Text('Error: ${snapshot.error}')),
            );
          }

          final usuario = snapshot.data!;
          return SideMenu(
            userName: usuario.nombreApellidos,
            userEmail: usuario.correo,
          );
        },
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
           children: [
            FutureBuilder<ClienteMostrarDTO>(
              future: _futureClientes,
              builder: (context, snapshot) {


 // Verifica el estado de la conexión
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (!snapshot.hasData) {
                  return const Text('No se encontraron datos del usuario');
                }

                String saludo = 'Hola, usuario';
                if (snapshot.hasData) {
                  saludo = 'Hola, ${snapshot.data!.nombreApellidos}';
                }
                return FadeInDown(
                  child: Text(
                    saludo,
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),

            // 1. Saludo
            //FadeInDown(

             // child: Text(
               // 'Hola, $_nombreUsuario',
                //style: theme.textTheme.headlineSmall?.copyWith(
                  //fontWeight: FontWeight.bold,
                //),
             // ),
            //),
            const SizedBox(height: 5),
            FadeInDown(
              child: Text(
                'Aquí está el resumen de tu crédito',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),

            const SizedBox(height: 20),

            // 2. Tarjeta Principal (Crédito)
            FadeInLeft(
              //child: CreditSummaryCard(credito: _creditoMock),
              child: FutureBuilder<List<CreditoMostrarDTO>>(
                future: _futureCreditos,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    print("🔥 ERROR COMPLETO:");
                    print(snapshot.error);
                    print("🔥 STACKTRACE:");
                    print(snapshot.stackTrace);

                    return Center(
                      child: Text(
                        'Error al cargar créditos:\n${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('No hay créditos pendientes'),
                    );
                  }

                  final credito = snapshot.data!.first;

                  return CreditSummaryCard(credito: credito);
                },
              ),
            ),

            const SizedBox(height: 30),

            // 3. Sección Tienda
            FadeInUp(
              child: Text(
                'Mi Tienda',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),

            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: FutureBuilder<List<tiendaMostrar_dto>>(
                future: _Tiendas,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    print("🔥 ERROR TIENDAS:");
                    print(snapshot.error);
                    print(snapshot.stackTrace);

                    return const Text(
                      'Error al cargar tienda',
                      style: TextStyle(color: Colors.red),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No hay tienda registrada');
                  }

                  final tienda = snapshot.data!.first;

                  return Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.store, color: Colors.orange),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tienda.nombreEncargado,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                tienda.telefono,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 30),

            // 4. Accesos Rápidos (Opcional pero útil)
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _QuickActionBtn(
                    icon: Icons.receipt_long,
                    label: 'Historial',
                    color: Colors.blue,
                    onTap: () {},
                  ),
                  _QuickActionBtn(
                    icon: Icons.support_agent,
                    label: 'Soporte',
                    color: Colors.purple,
                    onTap: () {},
                  ),
                  _QuickActionBtn(
                    icon: Icons.qr_code,
                    label: 'Mi QR',
                    color: Colors.teal,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget auxiliar para botones rápidos
class _QuickActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
