# JuaX Dark Mode Theme Specification
## Complete Color & Design Token Implementation

---

## COLOR SCHEME

### Primary Colors
```dart
// Backgrounds
static const Color scaffoldBackground = Color(0xFF212121);          // Dark charcoal
static const Color cardBackground = Color(0xFF2C2C2C);              // Lighter dark grey
static const Color surfaceBackground = Color(0xFF1E1E1E);           // Darker for sections
static const Color searchBarBackground = Color(0xFF3A3A3A);         // Distinct dark grey

// Accents (same as light mode)
static const Color primaryAccent = Color(0xFF9EE03F);              // Lime green
static const Color secondaryAccent = Color(0xFFFFC107);             // Orange/yellow
```

### Text Colors
```dart
static const Color textPrimary = Color(0xFFFFFFFF);                 // Pure white
static const Color textSecondary = Color(0xFFB0B0B0);               // Light grey
static const Color textMuted = Color(0xFF808080);                   // Medium grey
static const Color textOnAccent = Color(0xFFFFFFFF);                // White on green
```

### Icon Colors
```dart
static const Color iconActive = Color(0xFF9EE03F);                  // Lime green
static const Color iconInactive = Color(0xFFB0B0B0);                // Light grey
static const Color iconSecondary = Color(0xFF808080);               // Medium grey
```

### Border & Divider Colors
```dart
static const Color borderColor = Color(0xFF3A3A3A);                 // Dark grey
static const Color dividerColor = Color(0xFF3A3A3A);                // Dark grey
```

### Shadow Colors
```dart
static const Color shadowColor = Color(0x4D000000);                  // rgba(0,0,0,0.3)
static const Color shadowColorStrong = Color(0x80000000);           // rgba(0,0,0,0.5)
```

---

## MATERIAL 3 COLOR SCHEME MAPPING

### FlexColorScheme Configuration
```dart
static const FlexSchemeColor darkScheme = FlexSchemeColor(
  primary: Color(0xFF9EE03F),                    // Lime green primary (same)
  primaryContainer: Color(0xFF4A5C2A),          // Darker green container
  secondary: Color(0xFFFFC107),                  // Orange secondary (same)
  secondaryContainer: Color(0xFF8B6F00),        // Darker orange container
  tertiary: Color(0xFFB0B0B0),                   // Light grey tertiary
  tertiaryContainer: Color(0xFF3A3A3A),         // Dark grey container
  appBarColor: Color(0xFF2C2C2C),                // Card color app bar
  error: Color(0xFFFFB4AB),                     // Light red error
);
```

### ColorScheme Properties
```dart
ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF9EE03F),
  onPrimary: Color(0xFF212121),
  primaryContainer: Color(0xFF4A5C2A),
  onPrimaryContainer: Color(0xFF9EE03F),
  secondary: Color(0xFFFFC107),
  onSecondary: Color(0xFF212121),
  secondaryContainer: Color(0xFF8B6F00),
  onSecondaryContainer: Color(0xFFFFC107),
  tertiary: Color(0xFFB0B0B0),
  onTertiary: Color(0xFF212121),
  error: Color(0xFFFFB4AB),
  onError: Color(0xFF690005),
  surface: Color(0xFF212121),
  onSurface: Color(0xFFFFFFFF),
  surfaceVariant: Color(0xFF2C2C2C),
  onSurfaceVariant: Color(0xFFB0B0B0),
  outline: Color(0xFF3A3A3A),
  outlineVariant: Color(0xFF3A3A3A),
  shadow: Color(0xFF000000),
  scrim: Color(0xFF000000),
  inverseSurface: Color(0xFFFFFFFF),
  onInverseSurface: Color(0xFF212121),
  inversePrimary: Color(0xFF9EE03F),
)
```

---

## TYPOGRAPHY THEME

### Text Theme Configuration
```dart
TextTheme(
  // Display styles
  displayLarge: TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
    color: Color(0xFFFFFFFF),                    // White
  ),
  displayMedium: TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.5,
    color: Color(0xFFFFFFFF),
  ),
  displaySmall: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0,
    color: Color(0xFFFFFFFF),
  ),
  
  // Headline styles
  headlineLarge: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0,
    color: Color(0xFF9EE03F),                    // Accent green
  ),
  headlineMedium: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0,
    color: Color(0xFFFFFFFF),
  ),
  headlineSmall: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: Color(0xFFFFFFFF),
  ),
  
  // Body styles
  bodyLarge: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.25,
    color: Color(0xFFFFFFFF),
  ),
  bodyMedium: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.25,
    color: Color(0xFFB0B0B0),
  ),
  bodySmall: TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.4,
    color: Color(0xFFB0B0B0),
  ),
  
  // Label styles
  labelLarge: TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0.1,
    color: Color(0xFFFFFFFF),
  ),
  labelMedium: TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.5,
    color: Color(0xFFB0B0B0),
  ),
  labelSmall: TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.5,
    color: Color(0xFF808080),
  ),
)
```

---

## COMPONENT THEMES

### Card Theme
```dart
CardThemeData(
  color: Color(0xFF2C2C2C),                    // Lighter dark grey
  shadowColor: Color(0x4D000000),              // Stronger shadow
  elevation: 2,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
  margin: EdgeInsets.symmetric(
    horizontal: 0,
    vertical: 8,
  ),
)
```

### Button Themes

#### Filled Button (Primary CTA)
```dart
FilledButtonThemeData(
  style: FilledButton.styleFrom(
    backgroundColor: Color(0xFF9EE03F),        // Lime green (same)
    foregroundColor: Color(0xFF212121),        // Dark text on green
    elevation: 0,
    padding: EdgeInsets.symmetric(
      horizontal: 32,
      vertical: 16,
    ),
    minimumSize: Size(0, 56),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    ),
    textStyle: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
    ),
  ),
)
```

#### Outlined Button (Secondary)
```dart
OutlinedButtonThemeData(
  style: OutlinedButton.styleFrom(
    foregroundColor: Color(0xFF9EE03F),        // Lime green text
    side: BorderSide(
      color: Color(0xFF9EE03F),
      width: 1,
    ),
    padding: EdgeInsets.symmetric(
      horizontal: 24,
      vertical: 12,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    ),
    textStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
  ),
)
```

### Input Decoration Theme
```dart
InputDecorationTheme(
  filled: true,
  fillColor: Color(0xFF3A3A3A),                // Distinct dark grey
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(24),
    borderSide: BorderSide.none,
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(24),
    borderSide: BorderSide.none,
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(24),
    borderSide: BorderSide(
      color: Color(0xFF9EE03F),
      width: 2,
    ),
  ),
  contentPadding: EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 16,
  ),
  hintStyle: TextStyle(
    color: Color(0xFF808080),
    fontSize: 16,
    fontWeight: FontWeight.w400,
  ),
)
```

### App Bar Theme
```dart
AppBarTheme(
  backgroundColor: Color(0xFF212121),           // Dark background
  foregroundColor: Color(0xFFFFFFFF),           // White text
  elevation: 0,
  scrolledUnderElevation: 1,
  centerTitle: false,
  titleTextStyle: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Color(0xFFFFFFFF),
  ),
)
```

### Bottom Navigation Bar Theme
```dart
BottomNavigationBarThemeData(
  backgroundColor: Color(0xFF2C2C2C),          // Card color
  selectedItemColor: Color(0xFF9EE03F),        // Lime green
  unselectedItemColor: Color(0xFFB0B0B0),      // Light grey
  selectedLabelStyle: TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
  ),
  unselectedLabelStyle: TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
  ),
  type: BottomNavigationBarType.fixed,
  elevation: 8,
)
```

---

## ELEVATION & SHADOWS

### Shadow System
```dart
// Card shadow (stronger for dark mode)
static const BoxShadow cardShadow = BoxShadow(
  color: Color(0x4D000000),                     // rgba(0,0,0,0.3)
  blurRadius: 8.0,
  offset: Offset(0, 2),
  spreadRadius: 0,
);

// Button shadow
static const BoxShadow buttonShadow = BoxShadow(
  color: Color(0x80000000),                     // rgba(0,0,0,0.5)
  blurRadius: 4.0,
  offset: Offset(0, 2),
  spreadRadius: 0,
);

// Navigation bar shadow
static const BoxShadow navBarShadow = BoxShadow(
  color: Color(0x4D000000),
  blurRadius: 12.0,
  offset: Offset(0, -2),
  spreadRadius: 0,
);
```

---

## SPACING SYSTEM

### Padding & Margins (Same as Light Mode)
```dart
// Screen level
static const double screenPaddingHorizontal = 20.0;
static const double screenPaddingVertical = 24.0;

// Component level
static const double cardPadding = 16.0;
static const double sectionSpacing = 32.0;
static const double itemSpacing = 16.0;
```

---

## BORDER RADIUS SYSTEM

### Same as Light Mode
```dart
static const double radiusSmall = 8.0;
static const double radiusMedium = 12.0;
static const double radiusLarge = 16.0;
static const double radiusPill = 24.0;
```

---

## ACTIVE NAVIGATION INDICATOR

### Special Dark Mode Treatment
```dart
// Active navigation item background
static const Color activeNavBackground = Color(0x269EE03F);  // 15% opacity green

// Usage in navigation bar
Container(
  decoration: BoxDecoration(
    color: activeNavBackground,
    borderRadius: BorderRadius.circular(12),
  ),
  // ... navigation item content
)
```

---

## IMPLEMENTATION NOTES

### Key Considerations
1. **Contrast:** Ensure lime green (#9EE03F) has sufficient contrast on dark backgrounds
2. **Eye Comfort:** Dark backgrounds reduce eye strain in low-light conditions
3. **Accent Visibility:** Bright accents (lime green, orange) stand out more on dark
4. **Consistency:** Maintain same spacing and radius values as light mode
5. **Accessibility:** Test with screen readers and high contrast modes

### Color Usage Guidelines
- **Primary Accent (Lime Green):** Same vibrant color for maximum visibility
- **Dark Backgrounds:** Use subtle elevation differences (#212121 → #2C2C2C → #3A3A3A)
- **White Text:** Use for primary content, grey for secondary
- **Shadows:** Stronger shadows create better depth perception

### Differences from Light Mode
1. **Background Colors:** Dark instead of white
2. **Text Colors:** White/light instead of dark
3. **Shadow Opacity:** Higher (0.3 vs 0.1) for better depth
4. **Container Colors:** Darker variants of accent colors
5. **Search Bar:** Distinct darker grey (#3A3A3A) for separation

---

*Dark Mode Theme Specification Complete*
