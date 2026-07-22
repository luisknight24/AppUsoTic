import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book.dart';

class WordSearchScreen extends StatefulWidget {
  final Book book;
  final bool isTutorialMode;
  final VoidCallback? onTutorialComplete;

  const WordSearchScreen({
    super.key,
    required this.book,
    this.isTutorialMode = false,
    this.onTutorialComplete,
  });

  @override
  State<WordSearchScreen> createState() => _WordSearchScreenState();
}

class _WordSearchScreenState extends State<WordSearchScreen> {
  static const int gridSize = 10;
  late List<List<String>> _grid;
  late List<String> _wordsToFind;
  late Set<String> _foundWords;
  late List<Point<int>> _selectedPoints;
  late Set<Point<int>> _permanentlyHighlightedPoints;
  late int _score;

  // Timer & Ranking Variables
  Timer? _gameTimer;
  int _secondsElapsed = 0;
  List<Map<String, dynamic>> _leaderboard = [];

  // Tutorial guided tapping variables
  int _tutorialStep = 0; // 0 to 6 representing characters of "AQUILES"
  final List<Point<int>> _tutorialPath = [
    Point(0, 0), // A
    Point(0, 1), // Q
    Point(0, 2), // U
    Point(0, 3), // I
    Point(0, 4), // L
    Point(0, 5), // E
    Point(0, 6), // S
  ];

  @override
  void initState() {
    super.initState();
    _score = 0;
    _startNewGame();
    _loadLeaderboard();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }

  void _startNewGame() {
    _gameTimer?.cancel();
    _secondsElapsed = 0;
    
    // Start stopwatch
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsed++;
      });
    });

    setState(() {
      _wordsToFind = List.from(widget.book.wordSearchWords)..shuffle();
      if (_wordsToFind.length > 5) {
        _wordsToFind = _wordsToFind.sublist(0, 5);
      }
      
      // Ensure "AQUILES" is available in tutorial mode
      if (widget.isTutorialMode) {
        if (!_wordsToFind.contains("AQUILES")) {
          _wordsToFind.insert(0, "AQUILES");
        }
      }
      
      _foundWords = {};
      _selectedPoints = [];
      _permanentlyHighlightedPoints = {};
      _generateGrid();
    });
  }

  void _generateGrid() {
    _grid = List.generate(gridSize, (_) => List.generate(gridSize, (_) => "-"));
    final random = Random();

    // If tutorial mode, place "AQUILES" at the first row (row 0, col 0-6)
    if (widget.isTutorialMode) {
      String word = "AQUILES";
      for (int i = 0; i < word.length; i++) {
        _grid[0][i] = word[i];
      }
    }

    for (String word in _wordsToFind) {
      // Skip manually placing AQUILES in tutorial since it's already there
      if (widget.isTutorialMode && word == "AQUILES") continue;

      bool wordPlaced = false;
      int attempts = 0;
      word = word.toUpperCase();

      while (!wordPlaced && attempts < 150) {
        attempts++;
        final direction = random.nextInt(3); // 0: Horizontal, 1: Vertical, 2: Diagonal
        final row = widget.isTutorialMode ? random.nextInt(gridSize - 1) + 1 : random.nextInt(gridSize);
        final col = random.nextInt(gridSize);

        if (direction == 0) {
          // Horizontal
          if (col + word.length <= gridSize) {
            bool canPlace = true;
            for (int i = 0; i < word.length; i++) {
              if (_grid[row][col + i] != "-" && _grid[row][col + i] != word[i]) {
                canPlace = false;
                break;
              }
            }
            if (canPlace) {
              for (int i = 0; i < word.length; i++) {
                _grid[row][col + i] = word[i];
              }
              wordPlaced = true;
            }
          }
        } else if (direction == 1) {
          // Vertical
          if (row + word.length <= gridSize) {
            bool canPlace = true;
            for (int i = 0; i < word.length; i++) {
              if (_grid[row + i][col] != "-" && _grid[row + i][col] != word[i]) {
                canPlace = false;
                break;
              }
            }
            if (canPlace) {
              for (int i = 0; i < word.length; i++) {
                _grid[row + i][col] = word[i];
              }
              wordPlaced = true;
            }
          }
        } else {
          // Diagonal
          if (row + word.length <= gridSize && col + word.length <= gridSize) {
            bool canPlace = true;
            for (int i = 0; i < word.length; i++) {
              if (_grid[row + i][col + i] != "-" && _grid[row + i][col + i] != word[i]) {
                canPlace = false;
                break;
              }
            }
            if (canPlace) {
              for (int i = 0; i < word.length; i++) {
                _grid[row + i][col + i] = word[i];
              }
              wordPlaced = true;
            }
          }
        }
      }
    }

    const alphabet = "ABCDEFGHIJKLMNÑOPQRSTUVWXYZ";
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        if (_grid[r][c] == "-") {
          _grid[r][c] = alphabet[random.nextInt(alphabet.length)];
        }
      }
    }
  }

  String _formatDuration(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  Future<void> _loadLeaderboard() async {
    final prefs = await SharedPreferences.getInstance();
    final key = "leaderboard_${widget.book.title.replaceAll(' ', '_')}";
    final data = prefs.getString(key);
    if (data != null) {
      setState(() {
        _leaderboard = List<Map<String, dynamic>>.from(json.decode(data));
      });
    }
  }

  Future<void> _saveRecord(int score, int timeInSeconds) async {
    final prefs = await SharedPreferences.getInstance();
    final key = "leaderboard_${widget.book.title.replaceAll(' ', '_')}";
    
    _leaderboard.add({
      "score": score,
      "time": timeInSeconds,
      "date": DateTime.now().toLocal().toString().substring(0, 16),
    });

    // Sort by higher score first, then by lower time
    _leaderboard.sort((a, b) {
      int scoreCompare = b["score"].compareTo(a["score"]);
      if (scoreCompare == 0) {
        return a["time"].compareTo(b["time"]);
      }
      return scoreCompare;
    });

    // Keep top 5
    if (_leaderboard.length > 5) {
      _leaderboard = _leaderboard.sublist(0, 5);
    }

    await prefs.setString(key, json.encode(_leaderboard));
    setState(() {});
  }

  void _onCellTap(int row, int col) {
    final tappedPoint = Point(row, col);

    // Tutorial guided taps verification
    if (widget.isTutorialMode && !_foundWords.contains("AQUILES") && _tutorialStep < _tutorialPath.length) {
      final expectedPoint = _tutorialPath[_tutorialStep];
      if (tappedPoint != expectedPoint) {
        // Tapped wrong cell, show guidance hint
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Toca la celda indicada con borde parpadeante para formar 'AQUILES'."),
            duration: Duration(milliseconds: 700),
          ),
        );
        return;
      }
    }

    setState(() {
      if (_selectedPoints.contains(tappedPoint)) {
        _selectedPoints.clear();
        if (widget.isTutorialMode) {
          _tutorialStep = 0; // reset tutorial selection
        }
        return;
      }

      if (_selectedPoints.isNotEmpty) {
        final last = _selectedPoints.last;
        final isAdjacent = (last.x - row).abs() <= 1 && (last.y - col).abs() <= 1;
        if (!isAdjacent) {
          _selectedPoints.clear();
          if (widget.isTutorialMode) {
            _tutorialStep = 0;
          }
        }
      }

      _selectedPoints.add(tappedPoint);
      if (widget.isTutorialMode) {
        _tutorialStep++;
      }

      String currentWord = _selectedPoints.map((p) => _grid[p.x][p.y]).join();

      if (_wordsToFind.contains(currentWord) && !_foundWords.contains(currentWord)) {
        _foundWords.add(currentWord);
        _permanentlyHighlightedPoints.addAll(_selectedPoints);
        _score += 15;
        _selectedPoints.clear();
        
        if (widget.isTutorialMode) {
          _tutorialStep = 7; // Word found successfully
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("¡Encontraste: $currentWord!", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.tealAccent.withOpacity(0.9),
            duration: const Duration(seconds: 1),
          ),
        );

        if (_foundWords.length == _wordsToFind.length) {
          _gameTimer?.cancel();
          _saveRecord(_score, _secondsElapsed);
          _showWinDialog();
        }
      } else {
        bool isPrefix = _wordsToFind.any((w) => w.startsWith(currentWord));
        if (!isPrefix) {
          _selectedPoints.clear();
          if (widget.isTutorialMode) {
            _tutorialStep = 0;
          }
          // Subtract 2 points for invalid prefix/mistake, minimum 0 points
          _score = max(0, _score - 2);
          
          _selectedPoints.add(tappedPoint);
          if (widget.isTutorialMode && tappedPoint == _tutorialPath[0]) {
            _tutorialStep = 1;
          }
        }
      }
    });
  }

  void _showWinDialog() {
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
            widget.isTutorialMode ? "¡Tutorial completado!" : "¡Sopa completada!",
            style: GoogleFonts.playfairDisplay(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 24),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.stars_rounded, color: Colors.yellowAccent, size: 60),
              const SizedBox(height: 18),
              Text(
                widget.isTutorialMode
                    ? "¡Felicidades! Lograste completar la sopa de letras tutorial de forma excelente."
                    : "Has encontrado todas las palabras escondidas con éxito.",
                style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              Text(
                "Puntaje total: $_score pts",
                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 4),
              Text(
                "Tiempo récord: ${_formatDuration(_secondsElapsed)}",
                style: GoogleFonts.plusJakartaSans(color: Colors.cyanAccent, fontWeight: FontWeight.w600, fontSize: 14),
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
                Navigator.of(context).pop(); // dismiss dialog
                if (widget.isTutorialMode && widget.onTutorialComplete != null) {
                  widget.onTutorialComplete!();
                } else {
                  _startNewGame();
                }
              },
              child: Text(
                widget.isTutorialMode ? "Finalizar tutorial" : "Jugar de nuevo",
                style: GoogleFonts.plusJakartaSans(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            if (!widget.isTutorialMode)
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
                "Ranking de Intentos",
                style: GoogleFonts.playfairDisplay(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                "Tus 5 mejores tiempos en ${widget.book.title}",
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
                    final recordTime = record["time"] as int;
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
                          Text(
                            _formatDuration(recordTime),
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.cyanAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
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
          widget.isTutorialMode ? "Tutorial de sopa de letras" : "Sopa de letras",
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: widget.isTutorialMode
            ? const SizedBox.shrink()
            : Padding(
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
          if (!widget.isTutorialMode)
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
              left: -150,
              top: 50,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.tealAccent.withOpacity(0.05),
                      Colors.tealAccent.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  // Info/Stats Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.isTutorialMode ? "Sigue las instrucciones guia" : "Encuentra las palabras",
                          style: GoogleFonts.plusJakartaSans(color: Colors.white.withOpacity(0.5), fontSize: 11),
                        ),
                        Row(
                          children: [
                            Icon(Icons.timer_outlined, color: Colors.white.withOpacity(0.6), size: 14),
                            const SizedBox(width: 4),
                            Text(
                              _formatDuration(_secondsElapsed),
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.02),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white.withOpacity(0.08)),
                              ),
                              child: Text(
                                "Pts: $_score",
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.cyanAccent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Guided Tutorial Step instruction banner
                  if (widget.isTutorialMode && !_foundWords.contains("AQUILES") && _tutorialStep < 7)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.tealAccent.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.tealAccent.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.school_rounded, color: Colors.tealAccent, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _tutorialStep == 0
                                  ? "Para empezar, selecciona la letra 'A' en la primera celda."
                                  : "Excelente, ahora continúa tocando la siguiente celda parpadeante para formar 'AQUILES'.",
                              style: GoogleFonts.plusJakartaSans(color: Colors.tealAccent, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (widget.isTutorialMode && (_foundWords.contains("AQUILES") || _tutorialStep >= 7))
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.emoji_emotions_outlined, color: Colors.greenAccent, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "¡Felicidades, encontraste tu primera palabra! Ahora encuentra el resto de palabras de la lista por tu cuenta.",
                              style: GoogleFonts.plusJakartaSans(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Word Search Grid
                  Expanded(
                    flex: 6,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          padding: const EdgeInsets.all(4), // Outer Bezel
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.01),
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(color: Colors.white.withOpacity(0.06)),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(10), // Inner Core
                            decoration: BoxDecoration(
                              color: const Color(0xFF09090C),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: gridSize,
                                mainAxisSpacing: 4,
                                crossAxisSpacing: 4,
                              ),
                              itemCount: gridSize * gridSize,
                              itemBuilder: (context, index) {
                                final r = index ~/ gridSize;
                                final c = index % gridSize;
                                final point = Point(r, c);
                                final letter = _grid[r][c];

                                final isSelected = _selectedPoints.contains(point);
                                final isPermanentlyHighlighted = _permanentlyHighlightedPoints.contains(point);

                                // Guidance indicators
                                bool isTutorialExpected = false;
                                if (widget.isTutorialMode && !_foundWords.contains("AQUILES") && _tutorialStep < _tutorialPath.length) {
                                  isTutorialExpected = _tutorialPath[_tutorialStep] == point;
                                }

                                Color cellColor = Colors.transparent;
                                Color textColor = Colors.white.withOpacity(0.85);
                                Color borderColor = Colors.white.withOpacity(0.03);

                                if (isSelected) {
                                  cellColor = Colors.cyanAccent.withOpacity(0.12);
                                  textColor = Colors.cyanAccent;
                                  borderColor = Colors.cyanAccent.withOpacity(0.3);
                                } else if (isPermanentlyHighlighted) {
                                  cellColor = Colors.tealAccent.withOpacity(0.08);
                                  textColor = Colors.tealAccent;
                                  borderColor = Colors.tealAccent.withOpacity(0.2);
                                } else if (isTutorialExpected) {
                                  // Highlight next required cell with a pulsing/cyan border
                                  cellColor = Colors.cyanAccent.withOpacity(0.04);
                                  borderColor = Colors.cyanAccent;
                                }

                                return InkWell(
                                  onTap: () => _onCellTap(r, c),
                                  borderRadius: BorderRadius.circular(6),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    decoration: BoxDecoration(
                                      color: cellColor,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: borderColor,
                                        width: isTutorialExpected ? 2.0 : 1.0,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        letter,
                                        style: GoogleFonts.plusJakartaSans(
                                          color: textColor,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Words List
                  Expanded(
                    flex: 3,
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF09090C),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.06)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Vocabulario:",
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _wordsToFind.map((word) {
                                  final isFound = _foundWords.contains(word);
                                  return Chip(
                                    backgroundColor: isFound ? Colors.tealAccent.withOpacity(0.1) : Colors.white.withOpacity(0.02),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: BorderSide(
                                        color: isFound ? Colors.tealAccent.withOpacity(0.4) : Colors.white.withOpacity(0.08),
                                      ),
                                    ),
                                    label: Text(
                                      word,
                                      style: GoogleFonts.plusJakartaSans(
                                        color: isFound ? Colors.tealAccent : Colors.white70,
                                        decoration: isFound ? TextDecoration.lineThrough : null,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
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
          ],
        ),
      ),
    );
  }
}
