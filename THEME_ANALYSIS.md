# JuaX Theme Analysis & Design System
## Complete Visual Design Specification

---

## 1. COLOR PALETTE ANALYSIS

### Primary Colors
- **Primary Background (Dark Mode):** `#212121` - Very dark charcoal grey, almost black
- **Primary Background (Light Mode):** `#FFFFFF` - Pure white (inferred for light mode)
- **Card Background (Dark Mode):** `#2C2C2C` - Slightly lighter dark grey for elevation
- **Card Background (Light Mode):** `#F5F5F5` - Light grey for cards (inferred)
- **Search Bar Background (Dark Mode):** `#3A3A3A` - Distinct lighter dark grey
- **Search Bar Background (Light Mode):** `#E0E0E0` - Light grey (inferred)

### Accent Colors
- **Primary Accent (Lime Green):** `#9EE03F` - Vibrant lime green
  - Used for: CTAs, active states, highlights, price tags, section headings
- **Secondary Accent (Orange/Yellow):** `#FFC107` - Warm orange/yellow
  - Used for: Weather icons, rating stars, secondary highlights

### Text Colors
- **Primary Text (Dark Mode):** `#FFFFFF` - Pure white
- **Primary Text (Light Mode):** `#212121` - Dark charcoal (inferred)
- **Secondary Text (Dark Mode):** `#B0B0B0` - Light grey
- **Secondary Text (Light Mode):** `#757575` - Medium grey (inferred)
- **Muted/Placeholder (Dark Mode):** `#808080` - Medium grey
- **Muted/Placeholder (Light Mode):** `#9E9E9E` - Light grey (inferred)

### Icon Colors
- **Active Icons:** `#9EE03F` - Lime green
- **Inactive Icons (Dark Mode):** `#B0B0B0` - Light grey
- **Inactive Icons (Light Mode):** `#757575` - Medium grey (inferred)

---

## 2. TYPOGRAPHY SYSTEM

### Font Family
- **Primary:** Modern sans-serif (Roboto, Poppins, or Inter recommended)
- **Style:** Clean, highly legible, modern

### Font Size Scale
```
Display Large:    32px / 700 weight  (Hero headlines: "Your dream holiday is waiting")
Display Medium:   28px / 700 weight  (Large section titles)
Headline Large:   24px / 600 weight  (Section headings: "Travel Places", "My Schedule")
Headline Medium:  20px / 600 weight  (Card titles: "City Rome", "London Eye")
Headline Small:   18px / 500 weight  (Subheadings)
Body Large:       16px / 400 weight  (Primary body text)
Body Medium:      14px / 400 weight  (Descriptions, secondary text)
Body Small:       12px / 400 weight  (Labels, metadata: "Italy", "5 Days")
Label Large:      15px / 600 weight  (Button text)
Label Medium:     12px / 500 weight  (Small labels)
```

### Typography Properties
- **Line Height:** 1.5 (comfortable reading)
- **Letter Spacing:** -0.5px to 0px (tight, modern feel)
- **Font Weights:** 400 (regular), 500 (medium), 600 (semi-bold), 700 (bold)

---

## 3. SHAPES & BORDER RADIUS

### Border Radius System
- **Pill-shaped (High Radius):** 24px - 28px
  - Primary CTA buttons ("Get Started", "Book Now")
  - Search bar
  - Active navigation item background
  
- **Rounded Rectangles (Medium Radius):** 12px - 16px
  - Content cards (travel places, schedule items)
  - Weather card
  - Bottom navigation bar container
  - Filter buttons
  
- **Small Radius:** 8px
  - Icon containers
  - Small badges
  - Price tag bubbles

### Card Elevation
- **Card Shadow (Dark Mode):**
  - Color: `rgba(0, 0, 0, 0.3)`
  - Blur: 8px
  - Offset: (0, 2px)
  - Spread: 0px
  
- **Card Shadow (Light Mode):**
  - Color: `rgba(0, 0, 0, 0.1)`
  - Blur: 8px
  - Offset: (0, 2px)
  - Spread: 0px

---

## 4. SPACING SYSTEM

### Base Unit: 4px

### Spacing Scale
```
xs:   4px   - Tight grouping
sm:   8px   - Related elements
md:   12px  - Card internal padding
lg:   16px  - Standard spacing
xl:   20px  - Section spacing
2xl:  24px  - Major section breaks
3xl:  32px  - Screen edge padding
4xl:  48px  - Hero spacing
```

### Layout Spacing
- **Screen Edge Padding:** 20px (mobile), 24px (tablet)
- **Card Internal Padding:** 16px - 20px
- **Section Vertical Spacing:** 24px - 32px
- **Component Spacing:** 12px - 16px

---

## 5. COMPONENT SPECIFICATIONS

### Buttons

#### Primary CTA Button
- **Background:** `#9EE03F` (lime green)
- **Text Color:** `#FFFFFF` (white)
- **Border Radius:** 24px (pill-shaped)
- **Padding:** 16px vertical, 32px horizontal
- **Font:** 15px, 600 weight
- **Height:** 56px (minimum touch target)
- **Width:** Full width or auto with min-width

#### Secondary Button
- **Background:** Transparent or card color
- **Text Color:** `#9EE03F` (lime green)
- **Border:** 1px solid `#9EE03F`
- **Border Radius:** 24px
- **Padding:** 12px vertical, 24px horizontal

### Input Fields

#### Search Bar
- **Background (Dark Mode):** `#3A3A3A`
- **Background (Light Mode):** `#E0E0E0`
- **Border Radius:** 24px (pill-shaped)
- **Padding:** 16px vertical, 20px horizontal
- **Height:** 56px
- **Placeholder Color:** `#808080` (muted grey)
- **Text Color:** `#FFFFFF` (dark mode) / `#212121` (light mode)
- **Icon:** Left-aligned, 24px, grey color

### Cards

#### Travel Place Card
- **Background (Dark Mode):** `#2C2C2C`
- **Background (Light Mode):** `#FFFFFF`
- **Border Radius:** 16px
- **Padding:** 16px
- **Shadow:** Subtle elevation (see elevation system)
- **Layout:** Vertical stack
  - Image: Top, full width, rounded top corners
  - Title: 20px, 600 weight, white/dark
  - Location: 14px, 400 weight, grey
  - Duration: 12px, 400 weight, grey
- **Price Tag:** Overlay on image, lime green background, white text, 8px radius

#### Schedule Card
- **Background:** Same as travel card
- **Border Radius:** 16px
- **Padding:** 16px
- **Layout:** Horizontal
  - Image: Left, 80px width, rounded corners
  - Content: Right, flexible
  - Button: Right-aligned, lime green

### Navigation Bar

#### Bottom Navigation
- **Background (Dark Mode):** `#2C2C2C`
- **Background (Light Mode):** `#FFFFFF`
- **Border Radius:** Top corners 24px
- **Height:** 80px (including safe area)
- **Padding:** 12px horizontal, 8px vertical
- **Active Item:**
  - Icon: `#9EE03F` (lime green), filled
  - Text: `#9EE03F`, 600 weight
  - Background: `#9EE03F` with 15% opacity, 12px radius
- **Inactive Item:**
  - Icon: `#B0B0B0` (grey), outlined
  - Text: `#B0B0B0`, 400 weight

### App Bar / Header

#### Home Screen Header
- **Background:** Transparent or primary background
- **Layout:** Horizontal
  - Profile Picture: Left, 48px circle
  - Greeting: Left, 14px, grey
  - Main Heading: Left, 32px, 700 weight, white/dark
- **Padding:** 20px horizontal, 16px vertical

---

## 6. VISUAL EFFECTS

### Shadows
- **Card Elevation:** Soft, diffuse shadows for depth
- **Button Press:** Subtle scale (0.98) on press
- **Hover States:** Slight elevation increase

### Opacity Usage
- **Active Nav Background:** 15% opacity of lime green
- **Overlay Elements:** 80% opacity for dark overlays
- **Disabled States:** 50% opacity

### Borders
- **Card Borders:** None (using shadows instead)
- **Input Borders:** None (using background color)
- **Button Borders:** 1px solid for secondary buttons

---

## 7. LAYOUT STRUCTURE

### Home Screen Layout
1. **Header Section** (Top)
   - Profile picture + greeting + main heading
   - Padding: 20px horizontal, 24px top, 16px bottom

2. **Search Bar** (Below header)
   - Full width, 20px horizontal padding
   - Margin bottom: 24px

3. **Travel Places Section**
   - Section heading: "Travel Places" (lime green, 24px, 600 weight)
   - Horizontal scrolling card list
   - Card width: 280px
   - Card spacing: 16px

4. **My Schedule Section**
   - Section heading: "My Schedule" (lime green, 24px, 600 weight)
   - Vertical list of schedule cards
   - Card spacing: 16px vertical

5. **Bottom Navigation** (Fixed)
   - Always visible at bottom
   - Safe area handling

---

## 8. DESIGN PRINCIPLES

### Core Principles
1. **Dark-First Design:** Optimized for dark mode, with light mode adaptation
2. **Vibrant Accents:** Strategic use of lime green for CTAs and highlights
3. **Minimalism:** Clean, uncluttered, focus on essential information
4. **Consistency:** Uniform application of radius, spacing, and colors
5. **Accessibility:** High contrast ratios, clear hierarchy
6. **Modern Aesthetic:** Rounded corners, soft shadows, generous spacing

### Visual Hierarchy
1. **Primary:** Large headings, lime green accents, CTAs
2. **Secondary:** Card titles, section headings
3. **Tertiary:** Body text, descriptions, metadata

---

## 9. LIGHT MODE ADAPTATION

### Color Adjustments for Light Mode
- **Background:** `#FFFFFF` → `#F5F5F5` (subtle grey)
- **Card Background:** `#FFFFFF` (pure white)
- **Primary Text:** `#212121` (dark charcoal)
- **Secondary Text:** `#757575` (medium grey)
- **Search Bar:** `#E0E0E0` (light grey)
- **Accent Colors:** Same (lime green `#9EE03F`, orange `#FFC107`)
- **Shadows:** Lighter, more subtle (`rgba(0, 0, 0, 0.1)`)

### Component Adjustments
- **Cards:** White background with subtle shadow
- **Navigation Bar:** White background with subtle top border
- **Icons:** Darker grey for inactive states
- **Text:** Darker for better contrast

---

## 10. IMPLEMENTATION PRIORITIES

### Phase 1: Core Theme (Light Mode)
1. Color palette implementation
2. Typography system
3. Spacing system
4. Border radius system

### Phase 2: Components (Home Page)
1. Search bar
2. Travel place cards
3. Schedule cards
4. Bottom navigation
5. Header section

### Phase 3: Dark Mode
1. Dark mode color palette
2. Component dark mode variants
3. Shadow adjustments

### Phase 4: Polish
1. Animations and transitions
2. Micro-interactions
3. Accessibility refinements

---

*Analysis complete. Ready for theme implementation.*
