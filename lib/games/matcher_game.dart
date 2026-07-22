import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book.dart';

class MatcherGameScreen extends StatefulWidget {
  final Book book;

  const MatcherGameScreen({super.key, required this.book});

  @override
  State<MatcherGameScreen> createState() => _MatcherGameScreenState();
}

class _MatcherGameScreenState extends State<MatcherGameScreen> {
  late List<MatchingItem> _draggableItems;
  late List<MatchingItem> _targetItems;
  late Set<String> _matchedDescriptions;
  late Map<String, MatchingItem?> _droppedItems; // target match -> dropped MatchingItem
  late Map<String, int> _mistakeCounts; // target match -> mistake count
  late int _score;
  List<Map<String, dynamic>> _leaderboard = [];

  @override
  void initState() {
    super.initState();
    _score = 0;
    _startNewGame();
    _loadLeaderboard();
  }

  void _startNewGame() {
    setState(() {
      _matchedDescriptions = {};
      _droppedItems = {};
      _mistakeCounts = {};
      _draggableItems = List.from(widget.book.matchingItems)..shuffle();
      _targetItems = List.from(widget.book.matchingItems)..shuffle();
      for (var item in _targetItems) {
        _droppedItems[item.match] = null;
        _mistakeCounts[item.match] = 0;
      }
    });
  }

  Future<void> _loadLeaderboard() async {
    final prefs = await SharedPreferences.getInstance();
    final key = "leaderboard_matcher_${widget.book.title.replaceAll(' ', '_')}";
    final data = prefs.getString(key);
    if (data != null) {
      setState(() {
        _leaderboard = List<Map<String, dynamic>>.from(json.decode(data));
      });
    }
  }

  Future<void> _saveRecord(int score) async {
    final prefs = await SharedPreferences.getInstance();
    final key = "leaderboard_matcher_${widget.book.title.replaceAll(' ', '_')}";
    
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

  void _handleDrop(MatchingItem draggedItem, String targetMatch) {
    // If the item was already dropped on another target, remove it from there
    String? previousTarget;
    _droppedItems.forEach((key, value) {
      if (value?.description == draggedItem.description) {
        previousTarget = key;
      }
    });
    if (previousTarget != null) {
      setState(() {
        _droppedItems[previousTarget!] = null;
      });
    }

    final isCorrect = draggedItem.match == targetMatch;

    setState(() {
      if (isCorrect) {
        _matchedDescriptions.add(draggedItem.description);
        _droppedItems[targetMatch] = draggedItem;
        _draggableItems.removeWhere((mi) => mi.description == draggedItem.description);
        _score += 20;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("¡Excelente emparejamiento!", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.greenAccent.withOpacity(0.9),
            duration: const Duration(seconds: 1),
          ),
        );
      } else {
        _droppedItems[targetMatch] = draggedItem;
        final count = (_mistakeCounts[targetMatch] ?? 0) + 1;
        _mistakeCounts[targetMatch] = count;
        
        // Subtract points: 5 for first mistake, 10 for second, etc.
        final pointsToSubtract = count * 5;
        _score = max(0, _score - pointsToSubtract);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Incorrecto. Pierdes $pointsToSubtract puntos.", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.redAccent.withOpacity(0.9),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    });

    if (_matchedDescriptions.length == widget.book.matchingItems.length) {
      _saveRecord(_score);
      _showFinishDialog();
    }
  }

  void _showFinishDialog() {
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
            "¡Excelente emparejamiento!",
            style: GoogleFonts.playfairDisplay(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified_rounded, color: Colors.cyanAccent, size: 60),
              const SizedBox(height: 18),
              Text(
                "Has relacionado todos los elementos de la obra correctamente.",
                style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              Text(
                "Puntaje obtenido: $_score pts",
                style: GoogleFonts.plusJakartaSans(color: Colors.yellowAccent, fontSize: 16, fontWeight: FontWeight.bold),
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
                _startNewGame();
              },
              child: Text(
                "Jugar de nuevo",
                style: GoogleFonts.plusJakartaSans(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // dialog
                Navigator.pop(context); // screen
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
                "Tus 5 mejores puntajes relacionando citas en ${widget.book.title}",
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
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Relacionar citas y personajes",
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
              left: -120,
              bottom: 50,
              child: Container(
                width: 380,
                height: 380,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.cyanAccent.withOpacity(0.04),
                      Colors.cyanAccent.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
                child: Column(
                  children: [
                    // Stats and instructions
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "Arrastra la cita hacia el personaje correcto:",
                              style: GoogleFonts.plusJakartaSans(color: Colors.white.withOpacity(0.5), fontSize: 11),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.02),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withOpacity(0.08)),
                            ),
                            child: Text(
                              "Pts: $_score",
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.yellowAccent,
                                fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Matching workspace
                    Expanded(
                      child: Row(
                        children: [
                          // Draggable Column
                          Expanded(
                            child: ListView.builder(
                              itemCount: _draggableItems.length,
                              itemBuilder: (context, index) {
                                final item = _draggableItems[index];

                                final cardContent = Container(
                                  height: 115,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF09090C),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: SingleChildScrollView(
                                      child: Text(
                                        item.description,
                                        style: GoogleFonts.plusJakartaSans(color: Colors.white.withOpacity(0.8), fontSize: 10.5, height: 1.45),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                );

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: Draggable<MatchingItem>(
                                    data: item,
                                    feedback: Material(
                                      color: Colors.transparent,
                                      child: SizedBox(
                                        width: MediaQuery.of(context).size.width * 0.42,
                                        child: Opacity(
                                          opacity: 0.85,
                                          child: cardContent,
                                        ),
                                      ),
                                    ),
                                    childWhenDragging: Opacity(
                                      opacity: 0.3,
                                      child: cardContent,
                                    ),
                                    child: cardContent,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),

                          // DropTarget Column
                          Expanded(
                            child: ListView.builder(
                              itemCount: _targetItems.length,
                              itemBuilder: (context, index) {
                                final targetItem = _targetItems[index];
                                final droppedItem = _droppedItems[targetItem.match];
                                final isCorrect = droppedItem != null && droppedItem.match == targetItem.match;

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: DragTarget<MatchingItem>(
                                    onWillAccept: (data) => data != null && !isCorrect,
                                    onAccept: (data) {
                                      _handleDrop(data, targetItem.match);
                                    },
                                    builder: (context, candidateData, rejectedData) {
                                      final isHovering = candidateData.isNotEmpty;

                                      Color outlineColor = Colors.white.withOpacity(0.06);
                                      Color bgColor = Colors.white.withOpacity(0.01);
                                      Color textColor = Colors.white.withOpacity(0.9);

                                      if (isCorrect) {
                                        outlineColor = Colors.greenAccent.withOpacity(0.4);
                                        bgColor = Colors.green.withOpacity(0.08);
                                        textColor = Colors.greenAccent;
                                      } else if (droppedItem != null) {
                                        // Incorrectly dropped item (Mismatch State)
                                        outlineColor = Colors.redAccent.withOpacity(0.35);
                                        bgColor = Colors.red.withOpacity(0.06);
                                        textColor = Colors.redAccent;
                                      } else if (isHovering) {
                                        outlineColor = Colors.cyanAccent.withOpacity(0.5);
                                        bgColor = Colors.cyanAccent.withOpacity(0.05);
                                        textColor = Colors.cyanAccent;
                                      }

                                      return Container(
                                        height: 115,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: bgColor,
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: outlineColor, width: 1.5),
                                        ),
                                        child: Center(
                                          child: SingleChildScrollView(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  targetItem.match,
                                                  style: GoogleFonts.plusJakartaSans(
                                                    color: textColor,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                                if (droppedItem != null) ...[
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    droppedItem.description,
                                                    style: GoogleFonts.plusJakartaSans(
                                                      color: isCorrect ? Colors.white60 : Colors.redAccent.withOpacity(0.7),
                                                      fontSize: 8.5,
                                                    ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
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
