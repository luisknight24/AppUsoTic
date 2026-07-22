import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const UsoTicApp());
}

class UsoTicApp extends StatelessWidget {
  const UsoTicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tics en la Literatura',
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: child!,
          ),
        );
      },
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF030303), // OLED Black
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          ThemeData.dark().textTheme,
        ),
        colorScheme: const ColorScheme.dark(
          primary: Colors.indigoAccent,
          secondary: Colors.cyanAccent,
          background: Color(0xFF030303),
          surface: Color(0xFF09090C), // Vantablack Card Base
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
