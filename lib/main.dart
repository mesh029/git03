import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/order_provider.dart';
import 'providers/messages_provider.dart';
import 'providers/map_provider.dart';
import 'providers/listings_provider.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';

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
        ChangeNotifierProvider(create: (_) => MessagesProvider()),
        ChangeNotifierProvider(create: (_) => MapProvider()),
        ChangeNotifierProvider(create: (_) => ListingsProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          final baseTheme = themeProvider.isDarkMode ? AppTheme.dark : AppTheme.light;
          
          return MaterialApp(
            title: 'Jua X',
            debugShowCheckedModeBanner: false,
            theme: baseTheme.copyWith(
              textTheme: GoogleFonts.interTextTheme(baseTheme.textTheme),
            ),
            darkTheme: AppTheme.dark.copyWith(
              textTheme: GoogleFonts.interTextTheme(AppTheme.dark.textTheme),
            ),
            themeMode: themeProvider.themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
