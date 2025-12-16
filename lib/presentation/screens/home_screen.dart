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
import 'new_credit_request_screen.dart';

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

// 2. Tarjeta Crédito + Lógica de Renovación
             FutureBuilder<List<CreditoMostrarDTO>>(
               future: _futureCreditos,
               builder: (context, snapshot) {
                 // --- LOADING ---
                 if (snapshot.connectionState == ConnectionState.waiting) {
                   return const Center(child: CircularProgressIndicator());
                 }

                 // --- ERROR ---
                 if (snapshot.hasError) {
                   return Container(
                     padding: const EdgeInsets.all(15),
                     decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(10)),
                     child: Text('Error al cargar créditos: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
                   );
                 }

                 // --- SIN DATOS (No tiene crédito activo) ---
                 // Si no tiene créditos, asumimos que puede pedir uno nuevo (ClienteId debería venir del usuario en este caso, pero por ahora lo manejamos así)
                 if (!snapshot.hasData || snapshot.data!.isEmpty) {
                   return Center(
                     child: Column(
                       children: [
                         const Text('No tienes créditos activos.'),
                         const SizedBox(height: 10),
                         ElevatedButton(
                             onPressed: () {
                               // Aquí deberíamos tener el ID del cliente guardado en sesión o preferencia
                               // Por ahora pondremos 1 como ejemplo o lo sacamos del servicio de usuario
                               context.push('/new-credit-request', extra: 1);
                             },
                             child: const Text("Solicitar mi primer crédito")
                         )
                       ],
                     ),
                   );
                 }

                 // --- CON DATOS ---
                 final credito = snapshot.data!.first;

                 // LÓGICA CORE: ¿Está pagado?
                 // Usamos 0.01 para evitar problemas de punto flotante
                 final bool estaPagado = (credito.montoPendiente <= 0.01);

                 return Column(
                   children: [
                     // A. Tarjeta de Resumen (Visualización)
                     FadeInLeft(child: CreditSummaryCard(credito: credito)),

                     const SizedBox(height: 20),

                     // B. Tarjeta de Acción (Nuevo Crédito)
                     FadeInLeft(
                       delay: const Duration(milliseconds: 100),
                       child: _NewCreditRequestCard(
                         isPaid: estaPagado, // <--- Aquí pasamos la bandera
                         onTap: () {
                           // Navegamos pasando el ID del cliente para el nuevo DTO
                           context.push('/new-credit-request', extra: credito.clienteId);
                         },
                       ),
                     ),
                   ],
                 );
               },
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

class _NewCreditRequestCard extends StatelessWidget {
  final bool isPaid;
  final VoidCallback onTap;

  const _NewCreditRequestCard({required this.isPaid, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = isPaid ? theme.primaryColor : Colors.grey.shade300;
    final textColor = isPaid ? Colors.white : Colors.grey.shade600;
    final iconColor = isPaid ? Colors.white : Colors.grey.shade500;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isPaid ? onTap : null,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(15),
            boxShadow: isPaid
                ? [BoxShadow(color: theme.primaryColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]
                : null,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(isPaid ? 0.2 : 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add_card_rounded, color: iconColor, size: 28),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Solicitar Nuevo Crédito',
                      style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isPaid
                          ? '¡Estás listo para renovar tu equipo!'
                          : 'Termina de pagar tu crédito actual para desbloquear.',
                      style: TextStyle(color: textColor.withOpacity(isPaid ? 0.9 : 0.7), fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (isPaid) Icon(Icons.arrow_forward_ios, color: textColor, size: 18)
              else Icon(Icons.lock_outline, color: iconColor, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}