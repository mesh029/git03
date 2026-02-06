# Home Page Simple Design System (SDS)
## JuaX - Production-Ready Component Specifications

---

## DESIGN TOKENS

### Colors
```dart
// Light Mode
static const Color primaryBackground = Color(0xFFFFFFFF);
static const Color cardBackground = Color(0xFFFFFFFF);
static const Color searchBarBackground = Color(0xFFE0E0E0);
static const Color primaryText = Color(0xFF212121);
static const Color secondaryText = Color(0xFF757575);
static const Color mutedText = Color(0xFF9E9E9E);
static const Color accentGreen = Color(0xFF9EE03F);
static const Color accentOrange = Color(0xFFFFC107);

// Dark Mode
static const Color primaryBackgroundDark = Color(0xFF212121);
static const Color cardBackgroundDark = Color(0xFF2C2C2C);
static const Color searchBarBackgroundDark = Color(0xFF3A3A3A);
static const Color primaryTextDark = Color(0xFFFFFFFF);
static const Color secondaryTextDark = Color(0xFFB0B0B0);
static const Color mutedTextDark = Color(0xFF808080);
```

### Typography
```dart
// Font Sizes
static const double fontSizeDisplayLarge = 32.0;
static const double fontSizeDisplayMedium = 28.0;
static const double fontSizeHeadlineLarge = 24.0;
static const double fontSizeHeadlineMedium = 20.0;
static const double fontSizeBodyLarge = 16.0;
static const double fontSizeBodyMedium = 14.0;
static const double fontSizeBodySmall = 12.0;
static const double fontSizeButton = 15.0;

// Font Weights
static const FontWeight fontWeightRegular = FontWeight.w400;
static const FontWeight fontWeightMedium = FontWeight.w500;
static const FontWeight fontWeightSemiBold = FontWeight.w600;
static const FontWeight fontWeightBold = FontWeight.w700;

// Line Heights
static const double lineHeightTight = 1.2;
static const double lineHeightNormal = 1.5;
```

### Spacing
```dart
static const double spacingXS = 4.0;
static const double spacingSM = 8.0;
static const double spacingMD = 12.0;
static const double spacingLG = 16.0;
static const double spacingXL = 20.0;
static const double spacing2XL = 24.0;
static const double spacing3XL = 32.0;
static const double spacing4XL = 48.0;

// Screen Padding
static const double screenPaddingHorizontal = 20.0;
static const double screenPaddingVertical = 24.0;
```

### Border Radius
```dart
static const double radiusSmall = 8.0;
static const double radiusMedium = 12.0;
static const double radiusLarge = 16.0;
static const double radiusPill = 24.0;
```

### Shadows
```dart
// Light Mode
static const BoxShadow cardShadowLight = BoxShadow(
  color: Color(0x1A000000), // rgba(0, 0, 0, 0.1)
  blurRadius: 8.0,
  offset: Offset(0, 2),
  spreadRadius: 0,
);

// Dark Mode
static const BoxShadow cardShadowDark = BoxShadow(
  color: Color(0x4D000000), // rgba(0, 0, 0, 0.3)
  blurRadius: 8.0,
  offset: Offset(0, 2),
  spreadRadius: 0,
);
```

---

## HOME PAGE COMPONENTS

### 1. Header Section

**Structure:**
```
┌─────────────────────────────────┐
│ [Profile] Hello, User!          │
│        Your dream holiday        │
│         is waiting               │
└─────────────────────────────────┘
```

**Specifications:**
- **Height:** Auto (flexible)
- **Padding:** 20px horizontal, 24px top, 16px bottom
- **Profile Picture:**
  - Size: 48px × 48px
  - Shape: Circle
  - Border: None
- **Greeting Text:**
  - Font: 14px, 400 weight
  - Color: Secondary text color
  - Margin: 12px left of profile
- **Main Heading:**
  - Font: 32px, 700 weight
  - Color: Primary text color
  - Line height: 1.2
  - Margin: 4px top

---

### 2. Search Bar

**Structure:**
```
┌─────────────────────────────────┐
│ 🔍  Search Places               │
└─────────────────────────────────┘
```

**Specifications:**
- **Height:** 56px
- **Border Radius:** 24px (pill-shaped)
- **Background:** Search bar background color
- **Padding:** 16px vertical, 20px horizontal
- **Margin:** 0px horizontal (screen padding), 24px bottom
- **Icon:**
  - Size: 24px
  - Color: Muted text color
  - Position: Left, 20px from edge
- **Placeholder:**
  - Font: 16px, 400 weight
  - Color: Muted text color
  - Text: "Search Places"
- **Text Input:**
  - Font: 16px, 400 weight
  - Color: Primary text color

---

### 3. Travel Places Section

**Structure:**
```
Travel Places
┌─────┐ ┌─────┐ ┌─────┐
│Card │ │Card │ │Card │ → (scrollable)
└─────┘ └─────┘ └─────┘
```

**Section Header:**
- **Text:** "Travel Places"
- **Font:** 24px, 600 weight
- **Color:** Accent green (#9EE03F)
- **Padding:** 20px horizontal, 0px vertical
- **Margin:** 0px top, 16px bottom

**Card Specifications:**
- **Width:** 280px
- **Height:** Auto (flexible)
- **Border Radius:** 16px
- **Background:** Card background color
- **Padding:** 0px (image takes full width)
- **Margin:** 0px right, 16px between cards
- **Shadow:** Card shadow
- **Layout:** Vertical stack

**Card Content:**
1. **Image:**
   - Width: 280px
   - Height: 180px
   - Border radius: 16px top corners only
   - Fit: Cover

2. **Price Tag (Overlay):**
   - Position: Top right of image
   - Background: Accent green (#9EE03F)
   - Text: White, 14px, 600 weight
   - Padding: 8px horizontal, 6px vertical
   - Border radius: 8px
   - Margin: 12px from edges

3. **Content Padding:** 16px all sides

4. **Title:**
   - Font: 20px, 600 weight
   - Color: Primary text
   - Margin: 0px top, 8px bottom

5. **Location:**
   - Font: 14px, 400 weight
   - Color: Secondary text
   - Icon: 16px, secondary text color
   - Margin: 0px top, 4px bottom

6. **Duration:**
   - Font: 12px, 400 weight
   - Color: Secondary text
   - Icon: 16px, secondary text color

---

### 4. My Schedule Section

**Structure:**
```
My Schedule
┌─────────────────────────────┐
│ [Image] Title        [Btn]  │
│         Location            │
└─────────────────────────────┘
┌─────────────────────────────┐
│ [Image] Title        [Btn]  │
│         Location            │
└─────────────────────────────┘
```

**Section Header:**
- **Text:** "My Schedule"
- **Font:** 24px, 600 weight
- **Color:** Accent green (#9EE03F)
- **Padding:** 20px horizontal, 0px vertical
- **Margin:** 32px top, 16px bottom

**Card Specifications:**
- **Width:** Full width (minus screen padding)
- **Height:** Auto (flexible, min 100px)
- **Border Radius:** 16px
- **Background:** Card background color
- **Padding:** 16px all sides
- **Margin:** 0px horizontal, 16px bottom (last item: 0px)
- **Shadow:** Card shadow
- **Layout:** Horizontal (Row)

**Card Content:**
1. **Image (Left):**
   - Width: 80px
   - Height: 80px
   - Border radius: 12px
   - Fit: Cover
   - Margin: 0px right, 16px right

2. **Content (Middle, Flexible):**
   - **Title:**
     - Font: 18px, 600 weight
     - Color: Primary text
     - Margin: 0px top, 8px bottom
   
   - **Location:**
     - Font: 14px, 400 weight
     - Color: Secondary text
     - Icon: 16px, secondary text color
     - Margin: 0px top

3. **Button (Right):**
   - **Text:** "Joined"
   - **Background:** Accent green (#9EE03F)
   - **Text Color:** White
   - **Font:** 14px, 600 weight
   - **Padding:** 10px horizontal, 8px vertical
   - **Border Radius:** 20px
   - **Min Width:** 80px

---

### 5. Bottom Navigation Bar

**Structure:**
```
┌─────┬─────┬─────┬─────┬─────┐
│ 🏠  │ 🔧  │ 📋  │ 👤  │ 💬  │
│Home │Svc  │Ord  │Prof │Msg  │
└─────┴─────┴─────┴─────┴─────┘
```

**Specifications:**
- **Height:** 80px (including safe area)
- **Background:** Card background color
- **Border Radius:** 24px top corners
- **Padding:** 12px horizontal, 8px vertical
- **Shadow:** Top shadow (elevation)
- **Layout:** Row, evenly distributed

**Navigation Item:**
- **Width:** Flexible (equal distribution)
- **Height:** Auto
- **Padding:** 8px vertical, 4px horizontal
- **Active Background:** Accent green with 15% opacity, 12px radius
- **Icon:**
  - Size: 24px
  - Active: Accent green, filled
  - Inactive: Secondary text, outlined
- **Label:**
  - Font: 11px
  - Active: Accent green, 600 weight
  - Inactive: Secondary text, 400 weight
  - Margin: 4px top

---

## LAYOUT STRUCTURE

### Home Page Layout (Vertical Stack)

```
┌─────────────────────────────┐
│      Header Section         │ ← 24px top padding
│                             │
├─────────────────────────────┤
│      Search Bar             │ ← 24px margin bottom
│                             │
├─────────────────────────────┤
│  Travel Places              │ ← Section header
│  [Card] [Card] [Card] →     │ ← Horizontal scroll
│                             │
├─────────────────────────────┤
│  My Schedule                │ ← 32px top margin
│  [Schedule Card]            │
│  [Schedule Card]            │
│  [Schedule Card]            │
│                             │
└─────────────────────────────┘
│  Bottom Navigation          │ ← Fixed at bottom
└─────────────────────────────┘
```

### Spacing Between Sections
- Header to Search: 0px (search has top margin)
- Search to Travel Places: 0px (section has top margin)
- Travel Places to Schedule: 32px
- Schedule items: 16px vertical
- Bottom padding: 100px (for navigation bar)

---

## RESPONSIVE BREAKPOINTS

### Mobile (Default)
- Screen padding: 20px horizontal
- Card width: 280px (travel places)
- Max content width: Full width

### Tablet (768px+)
- Screen padding: 24px horizontal
- Card width: 320px (travel places)
- Max content width: 1200px (centered)

---

## ANIMATIONS & INTERACTIONS

### Card Interactions
- **Tap Scale:** 0.98 (subtle press feedback)
- **Duration:** 150ms
- **Curve:** Ease out

### Scroll Behavior
- **Travel Places:** Horizontal scroll with snap
- **Schedule:** Vertical scroll, smooth

### Navigation
- **Tab Switch:** Fade transition, 200ms
- **Active Indicator:** Smooth color/background change

---

## ACCESSIBILITY

### Touch Targets
- Minimum: 44px × 44px
- Button height: 56px
- Navigation item: 60px × 60px

### Contrast Ratios
- Primary text: 4.5:1 minimum (WCAG AA)
- Accent green on dark: 4.5:1 minimum
- Secondary text: 3:1 minimum

### Screen Reader
- Semantic labels for all interactive elements
- Section headings properly marked
- Button labels descriptive

---

## IMPLEMENTATION CHECKLIST

### Phase 1: Foundation
- [ ] Color tokens defined
- [ ] Typography system implemented
- [ ] Spacing system implemented
- [ ] Border radius system implemented

### Phase 2: Components
- [ ] Header component
- [ ] Search bar component
- [ ] Travel place card component
- [ ] Schedule card component
- [ ] Bottom navigation component

### Phase 3: Layout
- [ ] Home page scaffold
- [ ] Section headers
- [ ] Scrollable lists
- [ ] Spacing and padding

### Phase 4: Polish
- [ ] Animations
- [ ] Shadows and elevation
- [ ] Dark mode support
- [ ] Accessibility testing

---

*SDS Complete. Ready for implementation.*
