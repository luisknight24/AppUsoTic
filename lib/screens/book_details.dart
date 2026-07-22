import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../models/book.dart';
import '../games/hangman_game.dart';
import '../games/word_search_game.dart';
import '../games/quiz_game.dart';
import '../games/matcher_game.dart';

class BookDetailsScreen extends StatefulWidget {
  final Book book;

  const BookDetailsScreen({super.key, required this.book});

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  late YoutubePlayerController _ytController;

  @override
  void initState() {
    super.initState();
    _ytController = YoutubePlayerController(
      initialVideoId: widget.book.youtubeVideoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    );
  }

  @override
  void dispose() {
    _ytController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: CircleAvatar(
            backgroundColor: Colors.black.withOpacity(0.4),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Base Dark Background
          Positioned.fill(
            child: Container(color: const Color(0xFF030303)),
          ),
          // Radial Mesh Orb Glow
          Positioned(
            left: -100,
            top: 150,
            child: Container(
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.indigoAccent.withOpacity(0.08),
                    Colors.indigoAccent.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),

          // Scrollable content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Book Cover Header (Hero Art)
                Container(
                  height: 380,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(widget.book.imagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          const Color(0xFF030303).withOpacity(0.5),
                          const Color(0xFF030303),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),

                // Main Info Container (Double-Bezel Shell)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Genre Eyebrow tag
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                        ),
                        child: Text(
                          widget.book.genre.toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.cyanAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Book Title (Huge playfair display)
                      Text(
                        widget.book.title,
                        style: GoogleFonts.playfairDisplay(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Author & Year subtext
                      Row(
                        children: [
                          Text(
                            "por ${widget.book.author}",
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 15,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "•",
                            style: TextStyle(color: Colors.white.withOpacity(0.3)),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            widget.book.year,
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Video Section (Nested Card Bezel)
                      Text(
                        "Resumen en video",
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(4), // Outer Bezel
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.02),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.06)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: YoutubePlayer(
                            controller: _ytController,
                            showVideoProgressIndicator: true,
                            progressIndicatorColor: Colors.cyanAccent,
                            progressColors: const ProgressBarColors(
                              playedColor: Colors.cyanAccent,
                              handleColor: Colors.cyanAccent,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Sinopsis Section (Double Bezel Container)
                      Container(
                        padding: const EdgeInsets.all(2), // Outer Bezel
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.02),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withOpacity(0.06)),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(20), // Inner Core
                          decoration: BoxDecoration(
                            color: const Color(0xFF09090C),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Sinopsis literaria",
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                widget.book.summary,
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 13,
                                  height: 1.6,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),

                      // Activities Section (Buttons in Button theme)
                      Text(
                        "Actividades interactivas",
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Vertical list of premium wide buttons (Button-in-Button architecture)
                      _buildInteractiveIslandButton(
                        context,
                        title: "Ahorcado literario",
                        subtitle: "Adivina la palabra oculta",
                        icon: Icons.psychology_rounded,
                        color: Colors.indigoAccent,
                        screen: HangmanGameScreen(book: widget.book),
                      ),
                      _buildInteractiveIslandButton(
                        context,
                        title: "Sopa de letras",
                        subtitle: "Encuentra el vocabulario",
                        icon: Icons.grid_on_rounded,
                        color: Colors.tealAccent,
                        screen: WordSearchScreen(book: widget.book),
                      ),
                      _buildInteractiveIslandButton(
                        context,
                        title: "Cuestionario literario",
                        subtitle: "Pon a prueba tus conocimientos",
                        icon: Icons.assignment_turned_in_rounded,
                        color: Colors.purpleAccent,
                        screen: QuizGameScreen(book: widget.book),
                      ),
                      _buildInteractiveIslandButton(
                        context,
                        title: "Relacionar citas y personajes",
                        subtitle: "Conecta elementos de la obra",
                        icon: Icons.compare_arrows_rounded,
                        color: Colors.amberAccent,
                        screen: MatcherGameScreen(book: widget.book),
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveIslandButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget screen,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(2), // Outer Bezel
          decoration: BoxDecoration(
            color: color.withOpacity(0.04),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.15)),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16), // Inner Core
            decoration: BoxDecoration(
              color: const Color(0xFF09090C),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                // Floating circle icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                // Premium nested circular trailing icon
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white60,
                    size: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
