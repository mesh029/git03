# JuaX Light Mode Theme Specification
## Complete Color & Design Token Implementation

---

## COLOR SCHEME

### Primary Colors
```dart
// Backgrounds
static const Color scaffoldBackground = Color(0xFFFFFFFF);        // Pure white
static const Color cardBackground = Color(0xFFFFFFFF);             // White cards
static const Color surfaceBackground = Color(0xFFF5F5F5);          // Subtle grey for sections
static const Color searchBarBackground = Color(0xFFE0E0E0);        // Light grey search

// Accents
static const Color primaryAccent = Color(0xFF9EE03F);              // Lime green
static const Color secondaryAccent = Color(0xFFFFC107);           // Orange/yellow
```

### Text Colors
```dart
static const Color textPrimary = Color(0xFF212121);                 // Dark charcoal
static const Color textSecondary = Color(0xFF757575);              // Medium grey
static const Color textMuted = Color(0xFF9E9E9E);                   // Light grey
static const Color textOnAccent = Color(0xFFFFFFFF);               // White on green
```

### Icon Colors
```dart
static const Color iconActive = Color(0xFF9EE03F);                 // Lime green
static const Color iconInactive = Color(0xFF757575);                // Medium grey
static const Color iconSecondary = Color(0xFF9E9E9E);             // Light grey
```

### Border & Divider Colors
```dart
static const Color borderColor = Color(0xFFE0E0E0);                 // Light grey
static const Color dividerColor = Color(0xFFE0E0E0);                // Light grey
```

### Shadow Colors
```dart
static const Color shadowColor = Color(0x1A000000);                 // rgba(0,0,0,0.1)
static const Color shadowColorStrong = Color(0x33000000);          // rgba(0,0,0,0.2)
```

---

## MATERIAL 3 COLOR SCHEME MAPPING

### FlexColorScheme Configuration
```dart
static const FlexSchemeColor lightScheme = FlexSchemeColor(
  primary: Color(0xFF9EE03F),                    // Lime green primary
  primaryContainer: Color(0xFFE8F5D6),           // Light green container
  secondary: Color(0xFFFFC107),                   // Orange secondary
  secondaryContainer: Color(0xFFFFF4D6),         // Light orange container
  tertiary: Color(0xFF757575),                    // Grey tertiary
  tertiaryContainer: Color(0xFFE0E0E0),          // Light grey container
  appBarColor: Color(0xFFFFFFFF),                // White app bar
  error: Color(0xFFBA1A1A),                      // Red error
);
```

### ColorScheme Properties
```dart
ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF9EE03F),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFE8F5D6),
  onPrimaryContainer: Color(0xFF212121),
  secondary: Color(0xFFFFC107),
  onSecondary: Color(0xFF212121),
  secondaryContainer: Color(0xFFFFF4D6),
  onSecondaryContainer: Color(0xFF212121),
  tertiary: Color(0xFF757575),
  onTertiary: Color(0xFFFFFFFF),
  error: Color(0xFFBA1A1A),
  onError: Color(0xFFFFFFFF),
  surface: Color(0xFFFFFFFF),
  onSurface: Color(0xFF212121),
  surfaceVariant: Color(0xFFF5F5F5),
  onSurfaceVariant: Color(0xFF757575),
  outline: Color(0xFFE0E0E0),
  outlineVariant: Color(0xFFE0E0E0),
  shadow: Color(0xFF000000),
  scrim: Color(0xFF000000),
  inverseSurface: Color(0xFF212121),
  onInverseSurface: Color(0xFFFFFFFF),
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
    color: Color(0xFF212121),
  ),
  displayMedium: TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.5,
    color: Color(0xFF212121),
  ),
  displaySmall: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0,
    color: Color(0xFF212121),
  ),
  
  // Headline styles
  headlineLarge: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0,
    color: Color(0xFF9EE03F),  // Accent green for section headings
  ),
  headlineMedium: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0,
    color: Color(0xFF212121),
  ),
  headlineSmall: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: Color(0xFF212121),
  ),
  
  // Body styles
  bodyLarge: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.25,
    color: Color(0xFF212121),
  ),
  bodyMedium: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.25,
    color: Color(0xFF757575),
  ),
  bodySmall: TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.4,
    color: Color(0xFF757575),
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
    color: Color(0xFF757575),
  ),
  labelSmall: TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.5,
    color: Color(0xFF9E9E9E),
  ),
)
```

---

## COMPONENT THEMES

### Card Theme
```dart
CardThemeData(
  color: Color(0xFFFFFFFF),                    // White background
  shadowColor: Color(0x1A000000),              // Subtle shadow
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
    backgroundColor: Color(0xFF9EE03F),        // Lime green
    foregroundColor: Color(0xFFFFFFFF),        // White text
    elevation: 0,
    padding: EdgeInsets.symmetric(
      horizontal: 32,
      vertical: 16,
    ),
    minimumSize: Size(0, 56),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24), // Pill shape
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
  fillColor: Color(0xFFE0E0E0),                // Search bar background
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(24),   // Pill shape
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
    color: Color(0xFF9E9E9E),
    fontSize: 16,
    fontWeight: FontWeight.w400,
  ),
)
```

### App Bar Theme
```dart
AppBarTheme(
  backgroundColor: Color(0xFFFFFFFF),          // White
  foregroundColor: Color(0xFF212121),          // Dark text
  elevation: 0,
  scrolledUnderElevation: 1,
  centerTitle: false,
  titleTextStyle: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Color(0xFF212121),
  ),
)
```

### Bottom Navigation Bar Theme
```dart
BottomNavigationBarThemeData(
  backgroundColor: Color(0xFFFFFFFF),         // White
  selectedItemColor: Color(0xFF9EE03F),        // Lime green
  unselectedItemColor: Color(0xFF757575),      // Medium grey
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
// Card shadow
static const BoxShadow cardShadow = BoxShadow(
  color: Color(0x1A000000),                     // rgba(0,0,0,0.1)
  blurRadius: 8.0,
  offset: Offset(0, 2),
  spreadRadius: 0,
);

// Button shadow (when needed)
static const BoxShadow buttonShadow = BoxShadow(
  color: Color(0x33000000),                    // rgba(0,0,0,0.2)
  blurRadius: 4.0,
  offset: Offset(0, 2),
  spreadRadius: 0,
);

// Navigation bar shadow
static const BoxShadow navBarShadow = BoxShadow(
  color: Color(0x1A000000),
  blurRadius: 12.0,
  offset: Offset(0, -2),
  spreadRadius: 0,
);
```

---

## SPACING SYSTEM

### Padding & Margins
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

```dart
static const double radiusSmall = 8.0;         // Small badges, icons
static const double radiusMedium = 12.0;        // Image containers
static const double radiusLarge = 16.0;         // Cards
static const double radiusPill = 24.0;          // Buttons, search bar
```

---

## IMPLEMENTATION NOTES

### Key Considerations
1. **High Contrast:** Ensure text meets WCAG AA standards (4.5:1 ratio)
2. **Touch Targets:** Minimum 44px × 44px for all interactive elements
3. **Consistency:** Use design tokens consistently across all components
4. **Performance:** Use const constructors where possible
5. **Accessibility:** Support screen readers and high contrast modes

### Color Usage Guidelines
- **Primary Accent (Lime Green):** Use for CTAs, active states, highlights
- **Secondary Accent (Orange):** Use for ratings, weather, secondary highlights
- **White Backgrounds:** Use for cards and surfaces
- **Grey Text:** Use for hierarchy (primary → secondary → muted)

---

*Light Mode Theme Specification Complete*
