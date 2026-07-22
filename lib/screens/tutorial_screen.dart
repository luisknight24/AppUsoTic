import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book.dart';
import '../games/word_search_game.dart';
import 'dashboard.dart';

class OnboardingTutorialScreen extends StatefulWidget {
  const OnboardingTutorialScreen({super.key});

  @override
  State<OnboardingTutorialScreen> createState() => _OnboardingTutorialScreenState();
}

class _OnboardingTutorialScreenState extends State<OnboardingTutorialScreen> {
  int _tutorialStep = 0; // 0: Welcome, 1: Dashboard Guide (Select Iliada), 2: Book Details (Video/Summary), 3: Games Intro, 4: Select Sopa, 5: Playing Sopa (managed inside game), 6: Outro (Tutorial finished)
  late Book _iliadaBook;

  @override
  void initState() {
    super.initState();
    // Iliada is always first book
    _iliadaBook = booksData.firstWhere((b) => b.title == "La Ilíada", orElse: () => booksData.first);
  }

  Future<void> _completeTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_run_completed', true);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Render layout based on step
          _buildActiveStepLayout(),

          // Render tutorial dialog/overlay on top
          _buildTutorialOverlay(),
        ],
      ),
    );
  }

  Widget _buildActiveStepLayout() {
    switch (_tutorialStep) {
      case 0:
      case 1:
        // Render Dashboard Mocked/Disabled state
        return IgnorePointer(
          ignoring: _tutorialStep != 1,
          child: _buildMockDashboard(),
        );
      case 2:
      case 3:
      case 4:
        // Render Book Details Mocked/Disabled state
        return IgnorePointer(
          ignoring: _tutorialStep != 4,
          child: _buildMockBookDetails(),
        );
      case 6:
        // Render final screen background
        return Container(color: const Color(0xFF030303));
      default:
        return Container();
    }
  }

  Widget _buildTutorialOverlay() {
    if (_tutorialStep == 0) {
      return _buildGlassModal(
        title: "¡Bienvenido!",
        message: "Hola, te damos la bienvenida a 'Tics en la Literatura'. Aquí combinamos grandes clásicos literarios con herramientas tecnológicas para que los explores de forma interactiva.\n\nComencemos con un breve tutorial guiado.",
        buttonText: "Iniciar Guía",
        onPressed: () {
          setState(() {
            _tutorialStep = 1;
          });
        },
      );
    }

    if (_tutorialStep == 1) {
      // Direct instruction pointer
      return Positioned(
        left: 24,
        right: 24,
        top: 175,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF09090C),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.cyanAccent.withOpacity(0.4)),
            boxShadow: [
              BoxShadow(
                color: Colors.cyanAccent.withOpacity(0.08),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                "SELECCIONA UN RELATO",
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.cyanAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Para empezar, presiona la tarjeta de 'La Ilíada' a continuación para entrar a ver los detalles.",
                style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 13),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 16),
              const Icon(Icons.arrow_downward_rounded, color: Colors.cyanAccent, size: 24),
            ],
          ),
        ),
      );
    }

    if (_tutorialStep == 2) {
      return _buildGlassModal(
        title: "Resumen en video y sinopsis",
        message: "En esta pantalla encontrarás la sinopsis y datos formales de la obra, además de un video-resumen interactivo en la parte superior para comprender los sucesos claves de la historia.",
        buttonText: "Continuar",
        onPressed: () {
          setState(() {
            _tutorialStep = 3;
          });
        },
      );
    }

    if (_tutorialStep == 3) {
      return _buildGlassModal(
        title: "Actividades interactivas",
        message: "En la parte inferior de la obra tendrás acceso a 4 minijuegos interactivos basados en los personajes, tramas y vocabulario del relato para afianzar tus conocimientos.",
        buttonText: "Ver minijuegos",
        onPressed: () {
          setState(() {
            _tutorialStep = 4;
          });
        },
      );
    }

    if (_tutorialStep == 4) {
      return Positioned(
        left: 24,
        right: 24,
        bottom: 230, // Positioned slightly above the Sopa de letras button
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF09090C),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.tealAccent.withOpacity(0.4)),
            boxShadow: [
              BoxShadow(
                color: Colors.tealAccent.withOpacity(0.08),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                "ELIGE LA SOPA DE LETRAS",
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.tealAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Toca el minijuego de 'Sopa de letras' para realizar una pequeña partida de demostración.",
                style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 13),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 16),
              const Icon(Icons.arrow_downward_rounded, color: Colors.tealAccent, size: 24),
            ],
          ),
        ),
      );
    }

    if (_tutorialStep == 6) {
      return _buildGlassModal(
        title: "¡Listo para explorar!",
        message: "Has completado la guía introductoria con éxito. A partir de ahora podrás explorar todas las demás obras clásicas y registrar tus mejores tiempos en el ranking de intentos.\n\n¡Disfruta tu viaje literario!",
        buttonText: "Explorar la aplicación",
        onPressed: _completeTutorial,
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildGlassModal({
    required String title,
    required String message,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.85),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(4), // Outer Bezel
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.01),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Container(
              padding: const EdgeInsets.all(24), // Inner Core
              decoration: BoxDecoration(
                color: const Color(0xFF09090C),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.playfairDisplay(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    message,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.justify, // Justified text
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    ),
                    onPressed: onPressed,
                    child: Text(
                      buttonText,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMockDashboard() {
    return Container(
      color: const Color(0xFF030303),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Explora la Historia", style: GoogleFonts.plusJakartaSans(color: Colors.white24, fontSize: 10)),
              Text("Tics en la Literatura", style: GoogleFonts.playfairDisplay(color: Colors.white60, fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Container(
                height: 48,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), borderRadius: BorderRadius.circular(16)),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 0.70,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    // Guided Iliada Card (Active in step 1)
                    GestureDetector(
                      onTap: () {
                        if (_tutorialStep == 1) {
                          setState(() {
                            _tutorialStep = 2; // proceed to details
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.cyanAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.cyanAccent, width: 2),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            image: const DecorationImage(
                              image: AssetImage("assets/images/iliada.png"),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                "La Ilíada",
                                style: GoogleFonts.playfairDisplay(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Inactive Odisea
                    Opacity(
                      opacity: 0.25,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.02),
                          borderRadius: BorderRadius.circular(24),
                          image: const DecorationImage(
                            image: AssetImage("assets/images/odisea.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMockBookDetails() {
    return Container(
      color: const Color(0xFF030303),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 200,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/iliada.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("La Ilíada", style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    // Mock YouTube
                    Container(
                      height: 160,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(_tutorialStep == 2 ? 0.8 : 0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _tutorialStep == 2 ? Colors.cyanAccent : Colors.white12,
                          width: _tutorialStep == 2 ? 2.0 : 1.0,
                        ),
                      ),
                      child: const Center(
                        child: Icon(Icons.play_circle_fill_rounded, color: Colors.cyanAccent, size: 50),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Mock Summary text
                    Text(
                      _iliadaBook.summary,
                      style: GoogleFonts.plusJakartaSans(color: Colors.white38, fontSize: 13),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 30),
                    // Games Area
                    Text("Actividades interactivas", style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),

                    // Guided Sopa Game button (Highlight in step 4)
                    GestureDetector(
                      onTap: () {
                        if (_tutorialStep == 4) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WordSearchScreen(
                                book: _iliadaBook,
                                isTutorialMode: true,
                                onTutorialComplete: () {
                                  Navigator.pop(context); // pop game
                                  setState(() {
                                    _tutorialStep = 6; // outro
                                  });
                                },
                              ),
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: _tutorialStep == 4 ? Colors.tealAccent.withOpacity(0.1) : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _tutorialStep == 4 ? Colors.tealAccent : Colors.white.withOpacity(0.08),
                            width: _tutorialStep == 4 ? 2.0 : 1.0,
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: const Color(0xFF09090C), borderRadius: BorderRadius.circular(14)),
                          child: Row(
                            children: [
                              const Icon(Icons.grid_on_rounded, color: Colors.tealAccent),
                              const SizedBox(width: 14),
                              Text("Sopa de letras", style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Inactive other games
                    Opacity(
                      opacity: 0.25,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: const Color(0xFF09090C), borderRadius: BorderRadius.circular(16)),
                        child: Row(
                          children: [
                            const Icon(Icons.psychology_rounded, color: Colors.white),
                            const SizedBox(width: 14),
                            Text("Ahorcado literario", style: GoogleFonts.plusJakartaSans(color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
