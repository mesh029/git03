import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// The [AppTheme] defines light and dark themes for the app.
///
/// Theme setup for FlexColorScheme package v8.
/// Use same major flex_color_scheme package version. If you use a
/// lower minor version, some properties may not be supported.
/// In that case, remove them after copying this theme to your
/// app or upgrade the package to version 8.4.0.
///
/// Use it in a [MaterialApp] like this:
///
/// MaterialApp(
///   theme: AppTheme.light,
///   darkTheme: AppTheme.dark,
/// );
abstract final class AppTheme {
  // Custom Material 3 Color Scheme - Vibrant Lime Green Theme
  // Light theme: Lime green primary, Orange secondary
  static const FlexSchemeColor _lightScheme = FlexSchemeColor(
    primary: Color(0xFF9EE03F),                    // Vibrant lime green
    primaryContainer: Color(0xFFE8F5D6),           // Light green container
    secondary: Color(0xFFFFC107),                   // Orange/yellow
    secondaryContainer: Color(0xFFFFF4D6),         // Light orange container
    tertiary: Color(0xFF757575),                    // Grey tertiary
    tertiaryContainer: Color(0xFFE0E0E0),          // Light grey container
    appBarColor: Color(0xFFFFFFFF),                // White app bar
    error: Color(0xFFBA1A1A),                      // Red error
  );

  // Dark theme: Same vibrant colors, darker containers
  static const FlexSchemeColor _darkScheme = FlexSchemeColor(
    primary: Color(0xFF9EE03F),                    // Same vibrant lime green
    primaryContainer: Color(0xFF4A5C2A),           // Darker green container
    secondary: Color(0xFFFFC107),                   // Same orange
    secondaryContainer: Color(0xFF8B6F00),         // Darker orange container
    tertiary: Color(0xFFB0B0B0),                   // Light grey tertiary
    tertiaryContainer: Color(0xFF3A3A3A),          // Dark grey container
    appBarColor: Color(0xFF212121),                // Dark app bar
    error: Color(0xFFFFB4AB),                     // Light red error
  );

  // The FlexColorScheme defined light mode ThemeData.
  static ThemeData light = FlexThemeData.light(
    // Using custom lime green color scheme
    colors: _lightScheme,
    // Component theme configurations for light mode.
    subThemesData: const FlexSubThemesData(
      interactionEffects: true,
      tintedDisabledControls: true,
      useM2StyleDividerInM3: true,
      inputDecoratorIsFilled: true,
      inputDecoratorBorderType: FlexInputBorderType.outline,
      alignedDropdown: true,
      navigationRailUseIndicator: true,
      // Card theme
      cardElevation: 1.0,
      cardRadius: 16.0,                            // 16px for cards
      // Button themes - Pill-shaped
      elevatedButtonRadius: 24.0,                  // 24px for buttons
      filledButtonRadius: 24.0,
      outlinedButtonRadius: 24.0,
      // Input decoration - Pill-shaped
      inputDecoratorRadius: 24.0,                  // 24px for search bar
      // Bottom navigation
      bottomNavigationBarElevation: 8.0,
    ),
    // Direct ThemeData properties.
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
    // Typography
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: 0,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.29,
        letterSpacing: 0,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.33,
        letterSpacing: 0,
      ),
      headlineLarge: TextStyle(
        fontSize: 24,                              // 24px for section headings
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: 0,
        color: Color(0xFF9EE03F),                  // Lime green for section headings
      ),
      headlineMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.44,
        letterSpacing: 0,
      ),
      headlineSmall: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.5,
        letterSpacing: 0,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.43,
        letterSpacing: 0.25,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.33,
        letterSpacing: 0.4,
      ),
      labelLarge: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.33,
        letterSpacing: 0.1,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.33,
        letterSpacing: 0.5,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.45,
        letterSpacing: 0.5,
      ),
    ),
  ).copyWith(
    // Card theme with CardThemeData
    cardTheme: CardThemeData(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),    // 16px for cards
      ),
    ),
    // AppBar theme
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
      scrolledUnderElevation: 1,
    ),
  );

  // The FlexColorScheme defined dark mode ThemeData.
  static ThemeData dark = FlexThemeData.dark(
    // Using custom lime green color scheme
    colors: _darkScheme,
    // Component theme configurations for dark mode.
    subThemesData: const FlexSubThemesData(
      interactionEffects: true,
      tintedDisabledControls: true,
      blendOnColors: true,
      useM2StyleDividerInM3: true,
      inputDecoratorIsFilled: true,
      inputDecoratorBorderType: FlexInputBorderType.outline,
      alignedDropdown: true,
      navigationRailUseIndicator: true,
      // Card theme
      cardElevation: 2.0,
      cardRadius: 16.0,                            // 16px for cards
      // Button themes - Pill-shaped
      elevatedButtonRadius: 24.0,                  // 24px for buttons
      filledButtonRadius: 24.0,
      outlinedButtonRadius: 24.0,
      // Input decoration - Pill-shaped
      inputDecoratorRadius: 24.0,                  // 24px for search bar
      // Bottom navigation
      bottomNavigationBarElevation: 8.0,
    ),
    // Direct ThemeData properties.
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
    // Typography (same as light)
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: 0,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.29,
        letterSpacing: 0,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.33,
        letterSpacing: 0,
      ),
      headlineLarge: TextStyle(
        fontSize: 24,                              // 24px for section headings
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: 0,
        color: Color(0xFF9EE03F),                  // Lime green for section headings
      ),
      headlineMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.44,
        letterSpacing: 0,
      ),
      headlineSmall: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.5,
        letterSpacing: 0,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.43,
        letterSpacing: 0.25,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.33,
        letterSpacing: 0.4,
      ),
      labelLarge: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.33,
        letterSpacing: 0.1,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.33,
        letterSpacing: 0.5,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.45,
        letterSpacing: 0.5,
      ),
    ),
  ).copyWith(
    // Card theme with CardThemeData
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),    // 16px for cards
      ),
    ),
    // AppBar theme
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
      scrolledUnderElevation: 1,
    ),
  );
}

