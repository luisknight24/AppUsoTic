import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/book.dart';
import 'book_details.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  String _searchQuery = "";
  String _selectedGenre = "Todos";
  late AnimationController _entryController;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final genres = ["Todos", ...booksData.map((b) => b.genre).toSet()];

    final filteredBooks = booksData.where((book) {
      final matchesSearch = book.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          book.author.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesGenre = _selectedGenre == "Todos" || book.genre == _selectedGenre;
      return matchesSearch && matchesGenre;
    }).toList();

    return Scaffold(
      body: Stack(
        children: [
          // Ethereal Mesh Glowing Background
          Positioned.fill(
            child: Container(
              color: const Color(0xFF030303),
            ),
          ),
          // Radial Glow Top Right
          Positioned(
            right: -100,
            top: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.indigoAccent.withOpacity(0.12),
                    Colors.indigoAccent.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          // Radial Glow Bottom Left
          Positioned(
            left: -150,
            bottom: -50,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.cyanAccent.withOpacity(0.08),
                    Colors.cyanAccent.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),

          // Main Scrollable Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  
                  // Header Block (Editorial Split inspired layout)
                   Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Text(
                          "EXPLORA LA HISTORIA",
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Tics en la Literatura",
                        style: GoogleFonts.playfairDisplay(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Double-Bezel Search Box
                  Container(
                    padding: const EdgeInsets.all(2), // Outer Bezel
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.01),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.06)),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2), // Inner Bezel
                      decoration: BoxDecoration(
                        color: const Color(0xFF09090C),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: TextField(
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                        style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 15),
                        decoration: InputDecoration(
                          icon: Icon(Icons.search, color: Colors.white.withOpacity(0.4), size: 20),
                          border: InputBorder.none,
                          hintText: "Buscar por título, autor...",
                          hintStyle: GoogleFonts.plusJakartaSans(color: Colors.white.withOpacity(0.3), fontSize: 15),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Genre Filter Row (Pills)
                  SizedBox(
                    height: 38,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: genres.length,
                      itemBuilder: (context, index) {
                        final genre = genres[index];
                        final isSelected = _selectedGenre == genre;
                        return Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedGenre = genre;
                              });
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.fastOutSlowIn,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.white : Colors.white.withOpacity(0.03),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.08),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  genre,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: isSelected ? Colors.black : Colors.white.withOpacity(0.7),
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Books Grid with Staggered Fade Up
                  Expanded(
                    child: filteredBooks.isEmpty
                        ? Center(
                            child: Text(
                              "No se encontraron obras literarias.",
                              style: GoogleFonts.plusJakartaSans(color: Colors.white.withOpacity(0.4), fontSize: 15),
                            ),
                          )
                        : GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.70,
                              crossAxisSpacing: 18,
                              mainAxisSpacing: 18,
                            ),
                            itemCount: filteredBooks.length,
                            itemBuilder: (context, index) {
                              final book = filteredBooks[index];

                              // Calculate staggered animation offset
                              final animStart = index * 0.12;
                              final animCurve = CurvedAnimation(
                                parent: _entryController,
                                curve: Interval(
                                  animStart.clamp(0.0, 0.99),
                                  1.0,
                                  curve: const Cubic(0.25, 1.0, 0.5, 1.0),
                                ),
                              );

                              return FadeTransition(
                                opacity: animCurve,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0.0, 0.15),
                                    end: Offset.zero,
                                  ).animate(animCurve),
                                  child: _buildBookCard(context, book),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookCard(BuildContext context, Book book) {
    return Container(
      padding: const EdgeInsets.all(6), // Outer Bezel
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Container(
        // Inner Core
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          image: DecorationImage(
            image: AssetImage(book.imagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 600),
                reverseTransitionDuration: const Duration(milliseconds: 400),
                pageBuilder: (context, animation, secondaryAnimation) {
                  return FadeTransition(
                    opacity: animation,
                    child: BookDetailsScreen(book: book),
                  );
                },
              ),
            );
          },
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Rich Linear Gradient Overlay for High Readability
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.05),
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.85),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),

              // Content Inside Cover Card
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Eyebrow Tag Genre
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Text(
                        book.genre.toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.cyanAccent,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Playfair Display Premium H3 title
                    Text(
                      book.title,
                      style: GoogleFonts.playfairDisplay(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Author Subtext
                    Text(
                      book.author,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),

                    // Button-in-button style indicator at bottom
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          book.year,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 9,
                          ),
                        ),
                        // Circular Nested Mini Arrow
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white,
                            size: 10,
                          ),
                        ),
                      ],
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
