import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book.dart';

class QuizGameScreen extends StatefulWidget {
  final Book book;

  const QuizGameScreen({super.key, required this.book});

  @override
  State<QuizGameScreen> createState() => _QuizGameScreenState();
}

class _QuizGameScreenState extends State<QuizGameScreen> {
  int _currentQuestionIndex = 0;
  int? _selectedOptionIndex;
  bool _answered = false;
  int _score = 0;
  List<Map<String, dynamic>> _leaderboard = [];

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    final prefs = await SharedPreferences.getInstance();
    final key = "leaderboard_quiz_${widget.book.title.replaceAll(' ', '_')}";
    final data = prefs.getString(key);
    if (data != null) {
      setState(() {
        _leaderboard = List<Map<String, dynamic>>.from(json.decode(data));
      });
    }
  }

  Future<void> _saveRecord(int score) async {
    final prefs = await SharedPreferences.getInstance();
    final key = "leaderboard_quiz_${widget.book.title.replaceAll(' ', '_')}";
    
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

  void _answerQuestion(int index) {
    if (_answered) return;

    setState(() {
      _selectedOptionIndex = index;
      _answered = true;

      if (index == widget.book.quizQuestions[_currentQuestionIndex].correctOptionIndex) {
        _score += 20;
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      if (_currentQuestionIndex < widget.book.quizQuestions.length - 1) {
        _currentQuestionIndex++;
        _selectedOptionIndex = null;
        _answered = false;
      } else {
        _saveRecord(_score);
        _showQuizFinishedDialog();
      }
    });
  }

  void _showQuizFinishedDialog() {
    final maxScore = widget.book.quizQuestions.length * 20;
    final isLowScore = _score < (maxScore / 2);

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
            "Cuestionario completado",
            style: GoogleFonts.playfairDisplay(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isLowScore ? Icons.sentiment_neutral_rounded : Icons.verified_rounded,
                color: isLowScore ? Colors.orangeAccent : Colors.indigoAccent,
                size: 60,
              ),
              const SizedBox(height: 18),
              Text(
                "Tu puntuación fue: $_score / $maxScore pts",
                style: GoogleFonts.plusJakartaSans(color: Colors.yellowAccent, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              Text(
                isLowScore
                    ? "¡No te preocupes! La literatura está llena de detalles y simbolismos. ¡Vuelve a intentarlo para mejorar tu puntuación!"
                    : "¡Excelente trabajo! Has demostrado un gran dominio de los acontecimientos y personajes de la obra.",
                style: GoogleFonts.plusJakartaSans(color: Colors.white60, fontSize: 13),
                textAlign: TextAlign.center,
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
                Navigator.pop(context); // dialog
                setState(() {
                  _currentQuestionIndex = 0;
                  _selectedOptionIndex = null;
                  _answered = false;
                  _score = 0;
                });
              },
              child: Text(
                "Reintentar",
                style: GoogleFonts.plusJakartaSans(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // dialog
                Navigator.pop(context); // screen
              },
              child: Text("Finalizar", style: GoogleFonts.plusJakartaSans(color: Colors.white38)),
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
        final maxScore = widget.book.quizQuestions.length * 20;
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
                "Tus 5 mejores puntajes en el cuestionario de ${widget.book.title}",
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
                                  "Puntaje: $recordScore / $maxScore pts",
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
    final questions = widget.book.quizQuestions;
    final currentQuestion = questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / questions.length;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Cuestionario literario",
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
              right: -100,
              bottom: 100,
              child: Container(
                width: 380,
                height: 380,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.purpleAccent.withOpacity(0.04),
                      Colors.purpleAccent.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Stats Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Pregunta ${_currentQuestionIndex + 1} de ${questions.length}",
                          style: GoogleFonts.plusJakartaSans(color: Colors.white60, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        Text(
                          "Puntos: $_score",
                          style: GoogleFonts.plusJakartaSans(color: Colors.yellowAccent, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white.withOpacity(0.04),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.indigoAccent),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Question Card (Double Bezel Container)
                    Container(
                      padding: const EdgeInsets.all(2), // Outer Bezel
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.02),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.06)),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(24), // Inner Core
                        decoration: BoxDecoration(
                          color: const Color(0xFF09090C),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Text(
                          currentQuestion.question,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Options list
                    Expanded(
                      child: ListView.builder(
                        itemCount: currentQuestion.options.length,
                        itemBuilder: (context, index) {
                          final optionText = currentQuestion.options[index];
                          Color outlineColor = Colors.white.withOpacity(0.08);
                          Color bgColor = Colors.white.withOpacity(0.01);
                          IconData? icon;

                          if (_answered) {
                            if (index == currentQuestion.correctOptionIndex) {
                              outlineColor = Colors.greenAccent.withOpacity(0.4);
                              bgColor = Colors.green.withOpacity(0.08);
                              icon = Icons.check_circle_outline_rounded;
                            } else if (_selectedOptionIndex == index) {
                              outlineColor = Colors.redAccent.withOpacity(0.4);
                              bgColor = Colors.red.withOpacity(0.06);
                              icon = Icons.highlight_off_rounded;
                            }
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: InkWell(
                              onTap: () => _answerQuestion(index),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: outlineColor, width: 1.5),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        optionText,
                                        style: GoogleFonts.plusJakartaSans(
                                          color: _answered && index == currentQuestion.correctOptionIndex
                                              ? Colors.greenAccent
                                              : Colors.white.withOpacity(0.85),
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    if (icon != null)
                                      Icon(
                                        icon,
                                        color: icon == Icons.check_circle_outline_rounded ? Colors.greenAccent : Colors.redAccent,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Action Button (Button in button style)
                    if (_answered)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: _nextQuestion,
                          child: Text(
                            _currentQuestionIndex == questions.length - 1 ? "Ver resultados" : "Siguiente pregunta",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
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
