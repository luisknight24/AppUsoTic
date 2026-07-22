import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book.dart';

class HangmanGameScreen extends StatefulWidget {
  final Book book;

  const HangmanGameScreen({super.key, required this.book});

  @override
  State<HangmanGameScreen> createState() => _HangmanGameScreenState();
}

class _HangmanGameScreenState extends State<HangmanGameScreen> {
  late String _word;
  late Set<String> _guessedLetters;
  late int _wrongGuesses;
  late int _score;
  static const int maxWrongGuesses = 6;
  List<Map<String, dynamic>> _leaderboard = [];

  @override
  void initState() {
    super.initState();
    _score = 0;
    _startNewGame();
    _loadLeaderboard();
  }

  void _startNewGame() {
    final list = widget.book.hangmanWords;
    final randomWord = (List.from(list)..shuffle()).first.toUpperCase();
    setState(() {
      _word = randomWord;
      _guessedLetters = {};
      _wrongGuesses = 0;
    });
  }

  Future<void> _loadLeaderboard() async {
    final prefs = await SharedPreferences.getInstance();
    final key = "leaderboard_hangman_${widget.book.title.replaceAll(' ', '_')}";
    final data = prefs.getString(key);
    if (data != null) {
      setState(() {
        _leaderboard = List<Map<String, dynamic>>.from(json.decode(data));
      });
    }
  }

  Future<void> _saveRecord(int score) async {
    final prefs = await SharedPreferences.getInstance();
    final key = "leaderboard_hangman_${widget.book.title.replaceAll(' ', '_')}";
    
    _leaderboard.add({
      "score": score,
      "date": DateTime.now().toLocal().toString().substring(0, 16),
    });

    // Sort by higher score first
    _leaderboard.sort((a, b) => (b["score"] as int).compareTo(a["score"] as int));

    // Keep top 5
    if (_leaderboard.length > 5) {
      _leaderboard = _leaderboard.sublist(0, 5);
    }

    await prefs.setString(key, json.encode(_leaderboard));
    setState(() {});
  }

  void _guessLetter(String letter) {
    if (_guessedLetters.contains(letter) || _wrongGuesses >= maxWrongGuesses) return;

    setState(() {
      _guessedLetters.add(letter);
      if (!_word.contains(letter)) {
        _wrongGuesses++;
      }
    });

    // Check Win
    bool isWon = _word.split('').every((char) => _guessedLetters.contains(char));
    if (isWon) {
      setState(() {
        _score += 10;
      });
      _saveRecord(_score);
      _showGameOverDialog(true);
    }
    // Check Lose
    else if (_wrongGuesses >= maxWrongGuesses) {
      _showGameOverDialog(false);
    }
  }

  void _showGameOverDialog(bool won) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF09090C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
          title: Text(
            won ? "¡Felicidades!" : "Juego terminado",
            style: GoogleFonts.playfairDisplay(
              color: won ? Colors.greenAccent : Colors.redAccent,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                won ? "Has adivinado la palabra correctamente." : "Te has quedado sin intentos.",
                style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              Text(
                "LA PALABRA ERA:",
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _word,
                style: GoogleFonts.playfairDisplay(
                  color: Colors.cyanAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              Text(
                "Puntuación: $_score pts",
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.yellowAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _startNewGame();
              },
              child: Text(
                "Jugar de nuevo",
                style: GoogleFonts.plusJakartaSans(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // dialog
                Navigator.of(context).pop(); // screen
              },
              child: Text("Salir", style: GoogleFonts.plusJakartaSans(color: Colors.white38)),
            ),
          ],
        );
      },
    );
  }

  void _showRecordsBoard() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF09090C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Ranking de intentos",
                style: GoogleFonts.playfairDisplay(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                "Tus 5 mejores puntajes en el ahorcado de ${widget.book.title}",
                style: GoogleFonts.plusJakartaSans(color: Colors.white38, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              if (_leaderboard.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Text(
                    "Aún no hay récords guardados.",
                    style: GoogleFonts.plusJakartaSans(color: Colors.white38),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _leaderboard.length,
                  itemBuilder: (context, index) {
                    final record = _leaderboard[index];
                    final recordScore = record["score"] as int;
                    final recordDate = record["date"] as String;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.02),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withOpacity(0.06)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: index == 0 ? Colors.amber.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                "${index + 1}",
                                style: GoogleFonts.plusJakartaSans(
                                  color: index == 0 ? Colors.amber : Colors.white60,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Puntaje: $recordScore pts",
                                  style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                Text(
                                  recordDate,
                                  style: GoogleFonts.plusJakartaSans(color: Colors.white38, fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            index == 0 ? Icons.emoji_events : Icons.star_border,
                            color: index == 0 ? Colors.amber : Colors.white24,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.06),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Cerrar",
                  style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> alphabet = "ABCDEFGHIJKLMNÑOPQRSTUVWXYZ".split('');

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Ahorcado literario",
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, fontSize: 20),
        ),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events_outlined, color: Colors.yellowAccent),
            onPressed: _showRecordsBoard,
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFF030303),
        child: Stack(
          children: [
            // Mesh Glow Radial
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
                      Colors.indigoAccent.withOpacity(0.04),
                      Colors.indigoAccent.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
                child: Column(
                  children: [
                    // Stats Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Intentos fallidos: $_wrongGuesses de $maxWrongGuesses",
                          style: GoogleFonts.plusJakartaSans(
                            color: _wrongGuesses >= 4 ? Colors.redAccent : Colors.white60,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          "Puntos: $_score",
                          style: GoogleFonts.plusJakartaSans(color: Colors.yellowAccent, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Hangman Drawing Panel (Double Bezel Container)
                    Container(
                      height: 180,
                      padding: const EdgeInsets.all(2), // Outer Bezel
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.02),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.06)),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF09090C),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Center(
                          child: CustomPaint(
                            size: const Size(120, 120),
                            painter: _HangmanPainter(_wrongGuesses),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Word Display
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _word.split('').map((char) {
                        final isGuessed = _guessedLetters.contains(char);
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 24,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: isGuessed ? Colors.cyanAccent : Colors.white24,
                                width: 2,
                              ),
                            ),
                          ),
                          child: Text(
                            isGuessed ? char : ' ',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 48),

                    // Keyboard List
                    Expanded(
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 10,
                          alignment: WrapAlignment.center,
                          children: alphabet.map((letter) {
                            final isGuessed = _guessedLetters.contains(letter);
                            final isCorrect = isGuessed && _word.contains(letter);
                            final isWrong = isGuessed && !_word.contains(letter);

                            Color btnColor = Colors.white.withOpacity(0.02);
                            Color txtColor = Colors.white.withOpacity(0.7);
                            Color borderCol = Colors.white.withOpacity(0.08);

                            if (isCorrect) {
                              btnColor = Colors.green.withOpacity(0.12);
                              txtColor = Colors.greenAccent;
                              borderCol = Colors.greenAccent.withOpacity(0.4);
                            } else if (isWrong) {
                              btnColor = Colors.red.withOpacity(0.08);
                              txtColor = Colors.redAccent.withOpacity(0.5);
                              borderCol = Colors.redAccent.withOpacity(0.15);
                            }

                            return Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: btnColor,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: borderCol, width: 1.2),
                              ),
                              child: InkWell(
                                onTap: isGuessed ? null : () => _guessLetter(letter),
                                borderRadius: BorderRadius.circular(10),
                                child: Center(
                                  child: Text(
                                    letter,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: txtColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
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

class _HangmanPainter extends CustomPainter {
  final int wrongGuesses;

  _HangmanPainter(this.wrongGuesses);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white38
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // Gallows Base & Post
    if (wrongGuesses > 0) {
      canvas.drawLine(Offset(20, size.height - 10), Offset(size.width - 20, size.height - 10), paint);
      canvas.drawLine(Offset(size.width / 4, size.height - 10), Offset(size.width / 4, 10), paint);
    }
    // Crossbar & Noose
    if (wrongGuesses > 1) {
      canvas.drawLine(Offset(size.width / 4, 10), Offset(size.width * 0.7, 10), paint);
      canvas.drawLine(Offset(size.width * 0.7, 10), Offset(size.width * 0.7, 30), paint);
    }

    final bodyPaint = Paint()
      ..color = Colors.cyanAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    // Head
    if (wrongGuesses > 2) {
      canvas.drawCircle(Offset(size.width * 0.7, 42), 12, bodyPaint);
    }
    // Torso
    if (wrongGuesses > 3) {
      canvas.drawLine(Offset(size.width * 0.7, 54), Offset(size.width * 0.7, 85), bodyPaint);
    }
    // Arms
    if (wrongGuesses > 4) {
      canvas.drawLine(Offset(size.width * 0.7, 62), Offset(size.width * 0.55, 74), bodyPaint);
      canvas.drawLine(Offset(size.width * 0.7, 62), Offset(size.width * 0.85, 74), bodyPaint);
    }
    // Legs
    if (wrongGuesses > 5) {
      canvas.drawLine(Offset(size.width * 0.7, 85), Offset(size.width * 0.58, 105), bodyPaint);
      canvas.drawLine(Offset(size.width * 0.7, 85), Offset(size.width * 0.82, 105), bodyPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _HangmanPainter oldDelegate) {
    return oldDelegate.wrongGuesses != wrongGuesses;
  }
}
