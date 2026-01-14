import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/order_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const JuaXApp());
}

class JuaXApp extends StatelessWidget {
  const JuaXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Jua X',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.light(
                primary: const Color(0xFF1DB954), // Spotify green - vibrant and cool
                secondary: const Color(0xFF1DB954), // Same green for consistency
                surface: const Color(0xFFFFFFFF),
                background: const Color(0xFFFFFFFF), // Spotify uses white/very light gray
                onPrimary: Colors.white,
                onSecondary: Colors.white,
                onSurface: const Color(0xFF000000), // Pure black text on light
                onBackground: const Color(0xFF000000),
                brightness: Brightness.light,
              ),
              scaffoldBackgroundColor: const Color(0xFFFFFFFF),
              cardColor: const Color(0xFFFFFFFF),
              dividerColor: const Color(0xFFD1D5DB), // Solid divider for light mode
              textTheme: GoogleFonts.interTextTheme().copyWith(
                displayLarge: GoogleFonts.inter(color: const Color(0xFF000000), fontSize: 32, fontWeight: FontWeight.w700),
                displayMedium: GoogleFonts.inter(color: const Color(0xFF000000), fontSize: 28, fontWeight: FontWeight.w700),
                displaySmall: GoogleFonts.inter(color: const Color(0xFF000000), fontSize: 24, fontWeight: FontWeight.w700),
                headlineMedium: GoogleFonts.inter(color: const Color(0xFF000000), fontSize: 20, fontWeight: FontWeight.w600),
                titleLarge: GoogleFonts.inter(color: const Color(0xFF000000), fontSize: 18, fontWeight: FontWeight.w600),
                titleMedium: GoogleFonts.inter(color: const Color(0xFF000000), fontSize: 16, fontWeight: FontWeight.w500),
                bodyLarge: GoogleFonts.inter(color: const Color(0xFF000000), fontSize: 16, fontWeight: FontWeight.normal),
                bodyMedium: GoogleFonts.inter(color: const Color(0xFF6A6A6A), fontSize: 14, fontWeight: FontWeight.normal),
                bodySmall: GoogleFonts.inter(color: const Color(0xFF6A6A6A), fontSize: 12, fontWeight: FontWeight.normal),
              ),
              iconTheme: const IconThemeData(color: Color(0xFF000000)),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.dark(
                primary: const Color(0xFF1DB954), // Spotify green - same in dark mode
                secondary: const Color(0xFF1DB954),
                surface: const Color(0xFF121212), // Spotify dark background
                background: const Color(0xFF000000), // Pure black like Spotify
                onPrimary: Colors.white,
                onSecondary: Colors.white,
                onSurface: const Color(0xFFFFFFFF), // White text on dark
                onBackground: const Color(0xFFFFFFFF),
                brightness: Brightness.dark,
              ),
              scaffoldBackgroundColor: const Color(0xFF000000), // Pure black like Spotify
              cardColor: const Color(0xFF181818), // Spotify-style dark cards for better contrast
              dividerColor: const Color(0xFF3A3A3A), // More visible divider in dark mode
              textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
                displayLarge: GoogleFonts.inter(color: const Color(0xFFFFFFFF), fontSize: 32, fontWeight: FontWeight.w700),
                displayMedium: GoogleFonts.inter(color: const Color(0xFFFFFFFF), fontSize: 28, fontWeight: FontWeight.w700),
                displaySmall: GoogleFonts.inter(color: const Color(0xFFFFFFFF), fontSize: 24, fontWeight: FontWeight.w700),
                headlineMedium: GoogleFonts.inter(color: const Color(0xFFFFFFFF), fontSize: 20, fontWeight: FontWeight.w600),
                titleLarge: GoogleFonts.inter(color: const Color(0xFFFFFFFF), fontSize: 18, fontWeight: FontWeight.w600),
                titleMedium: GoogleFonts.inter(color: const Color(0xFFFFFFFF), fontSize: 16, fontWeight: FontWeight.w500),
                bodyLarge: GoogleFonts.inter(color: const Color(0xFFFFFFFF), fontSize: 16, fontWeight: FontWeight.normal),
                bodyMedium: GoogleFonts.inter(color: const Color(0xFFB3B3B3), fontSize: 14, fontWeight: FontWeight.normal),
                bodySmall: GoogleFonts.inter(color: const Color(0xFFB3B3B3), fontSize: 12, fontWeight: FontWeight.normal),
              ),
              iconTheme: const IconThemeData(color: Color(0xFFFFFFFF)),
              useMaterial3: true,
            ),
            themeMode: themeProvider.themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
