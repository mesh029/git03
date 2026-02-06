# Screenshot Replication Plan for JuaX Home Page
## Exact Component Structure Matching Reference Design

---

## SCREENSHOT STRUCTURE ANALYSIS

### Layout Hierarchy (Top to Bottom):
1. **Header Section**
   - Profile picture (circular, left)
   - Greeting: "Hello, User!"
   - Main heading: "Your dream holiday is waiting"

2. **Search Bar**
   - Pill-shaped (24px radius)
   - Search icon (left)
   - Placeholder: "Search Places"
   - Background: Distinct grey (#3A3A3A dark / #E0E0E0 light)

3. **Travel Places Section**
   - Section heading: "Travel Places" (lime green, 24px, 600 weight)
   - Horizontal scrolling cards:
     - Image (top, full width, rounded top corners)
     - Price tag overlay (lime green, top-right)
     - Title (20px, 600 weight)
     - Location with icon (14px, grey)
     - Duration with icon (12px, grey)

4. **My Schedule Section**
   - Section heading: "My Schedule" (lime green, 24px, 600 weight)
   - Vertical list of cards:
     - Image (left, 80px, rounded)
     - Title (18px, 600 weight)
     - Location (14px, grey)
     - "Joined" button (right, lime green, pill-shaped)

5. **Bottom Navigation**
   - Fixed at bottom
   - Active item: Lime green with background highlight

---

## JUAX ADAPTATION MAPPING

### Component Mapping:
- **"Travel Places"** → **"Featured Properties"** or **"Popular Listings"**
- **"My Schedule"** → **"My Bookings"** or **"Recent Orders"**
- **Search Places** → **"Search Properties"** or **"Search Services"**

---

## IMPLEMENTATION STRATEGY

### Phase 1: Restructure Home Screen Layout

**Current Structure:**
```
- Header (greeting + location)
- Service Cards (Saka Keja, Laundry)
- Other Services
- Featured Listings
```

**Target Structure (Matching Screenshot):**
```
- Header (profile + greeting + main heading)
- Search Bar
- Travel Places Section (horizontal scroll)
- My Schedule Section (vertical list)
```

### Phase 2: Component Creation

#### 2.1 Header Component
**Match Screenshot:**
- Profile picture: 48px circle, left side
- Greeting: "Hello, [User Name]!" (14px, grey)
- Main heading: "Your dream holiday is waiting" (32px, 700 weight, white/dark)
- Layout: Row with profile on left, text on right

**JuaX Adaptation:**
- Keep profile picture
- Greeting: "Hello, [User Name]!"
- Main heading: "Find your perfect home" or "Discover amazing places"

#### 2.2 Search Bar Component
**Match Screenshot:**
- Height: 56px
- Border radius: 24px (pill)
- Background: #3A3A3A (dark) / #E0E0E0 (light)
- Padding: 16px vertical, 20px horizontal
- Icon: Left, 24px, grey
- Placeholder: "Search Places"

**JuaX Adaptation:**
- Placeholder: "Search properties" or "Search services"
- Functionality: Navigate to search/map screen

#### 2.3 Travel Places Section
**Match Screenshot:**
- Section heading: "Travel Places" (24px, lime green, 600 weight)
- Horizontal scrolling ListView
- Card width: 280px
- Card structure:
  - Image: 280px × 180px, rounded top corners (16px)
  - Price tag: Overlay, top-right, lime green background, white text, 8px radius
  - Content padding: 16px
  - Title: 20px, 600 weight
  - Location: 14px, grey, with icon
  - Duration: 12px, grey, with icon

**JuaX Adaptation:**
- Section heading: "Featured Properties" or "Popular Listings"
- Use existing listings data
- Card shows: Image, price, title, location, property type

#### 2.4 My Schedule Section
**Match Screenshot:**
- Section heading: "My Schedule" (24px, lime green, 600 weight)
- Vertical ListView
- Card structure:
  - Image: Left, 80px × 80px, 12px radius
  - Content: Middle, flexible
    - Title: 18px, 600 weight
    - Location: 14px, grey
  - Button: Right, "Joined" (lime green, pill, 20px radius)
- Card spacing: 16px vertical

**JuaX Adaptation:**
- Section heading: "My Bookings" or "Recent Orders"
- Use orders/bookings data
- Card shows: Property image, title, location, status button
- Button: "View" or "Active" (lime green)

---

## DETAILED COMPONENT SPECIFICATIONS

### 1. Header Component

```dart
Widget _buildHeader(BuildContext context) {
  return Padding(
    padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
    child: Row(
      children: [
        // Profile Picture
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.grey[300],
          // Use user profile image if available
        ),
        SizedBox(width: 12),
        // Greeting and Heading
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, ${userName}!',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Your dream holiday is waiting',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
```

### 2. Search Bar Component

```dart
Widget _buildSearchBar(BuildContext context) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
    child: Container(
      height: 56,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Color(0xFF3A3A3A)
            : Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(24),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search Places',
          hintStyle: TextStyle(
            color: Theme.of(context).textTheme.bodySmall?.color,
            fontSize: 16,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Theme.of(context).textTheme.bodySmall?.color,
            size: 24,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    ),
  );
}
```

### 3. Travel Places Card Component

```dart
Widget _buildTravelPlaceCard({
  required String imageUrl,
  required String title,
  required String location,
  required String price,
  required String duration,
}) {
  return Container(
    width: 280,
    margin: EdgeInsets.only(right: 16),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image with price tag
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                imageUrl,
                width: 280,
                height: 180,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(0xFF9EE03F),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  price,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        // Content
        Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    location,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    duration,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
```

### 4. My Schedule Card Component

```dart
Widget _buildScheduleCard({
  required String imageUrl,
  required String title,
  required String location,
  required VoidCallback onTap,
}) {
  return Container(
    margin: EdgeInsets.only(bottom: 16),
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        // Image
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            imageUrl,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(width: 16),
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    location,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Button
        FilledButton(
          onPressed: onTap,
          style: FilledButton.styleFrom(
            backgroundColor: Color(0xFF9EE03F),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: Text(
            'Joined',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}
```

---

## COMPLETE LAYOUT STRUCTURE

```dart
Scaffold(
  body: SafeArea(
    child: Column(
      children: [
        // 1. Header
        _buildHeader(context),
        
        // 2. Search Bar
        _buildSearchBar(context),
        
        // 3. Content (Scrollable)
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 4. Travel Places Section
                Text(
                  'Travel Places',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9EE03F),
                  ),
                ),
                SizedBox(height: 16),
                SizedBox(
                  height: 280, // Card height + padding
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: featuredListings.length,
                    itemBuilder: (context, index) {
                      return _buildTravelPlaceCard(...);
                    },
                  ),
                ),
                
                SizedBox(height: 32),
                
                // 5. My Schedule Section
                Text(
                  'My Schedule',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9EE03F),
                  ),
                ),
                SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: myBookings.length,
                  itemBuilder: (context, index) {
                    return _buildScheduleCard(...);
                  },
                ),
                
                SizedBox(height: 100), // Space for bottom nav
              ],
            ),
          ),
        ),
      ],
    ),
  ),
  bottomNavigationBar: AppBottomNavigationBar(...),
)
```

---

## DATA SOURCE MAPPING

### Travel Places Data
- **Source:** `ListingsProvider.availableListings`
- **Map to:** Featured/popular properties
- **Fields:**
  - `imageUrl` → `images.first`
  - `title` → `title`
  - `location` → `areaLabel`
  - `price` → `priceLabel`
  - `duration` → "Available" or property type

### My Schedule Data
- **Source:** `OrderProvider` or create mock bookings
- **Map to:** User's active bookings/orders
- **Fields:**
  - `imageUrl` → Property image
  - `title` → Property title
  - `location` → Property location
  - `status` → "Joined", "Active", "View"

---

## IMPLEMENTATION CHECKLIST

### Step 1: Update Theme
- [ ] Set primary color to `#9EE03F` (lime green)
- [ ] Update border radius: 24px buttons, 16px cards
- [ ] Set section heading color to primary

### Step 2: Restructure Home Screen
- [ ] Replace current header with new header component
- [ ] Add search bar component
- [ ] Remove old service cards section
- [ ] Add "Travel Places" section with horizontal scroll
- [ ] Add "My Schedule" section with vertical list

### Step 3: Create New Components
- [ ] `_buildHeader()` - Profile + greeting + heading
- [ ] `_buildSearchBar()` - Pill-shaped search
- [ ] `_buildTravelPlaceCard()` - Horizontal card
- [ ] `_buildScheduleCard()` - Vertical card with button

### Step 4: Data Integration
- [ ] Connect Travel Places to listings provider
- [ ] Connect My Schedule to orders/bookings
- [ ] Handle empty states

### Step 5: Styling & Polish
- [ ] Verify all colors match specification
- [ ] Check spacing (20px horizontal, 24px vertical)
- [ ] Test dark mode
- [ ] Verify shadows and elevation

---

## KEY DIFFERENCES FROM CURRENT

### Removed:
- Service cards (Saka Keja, Laundry)
- Other services section
- Current featured listings layout

### Added:
- Search bar
- Travel Places horizontal scroll section
- My Schedule vertical list section

### Modified:
- Header structure (profile + greeting + heading)
- Section headings (lime green, 24px)
- Card layouts (match screenshot exactly)

---

*Ready for implementation. This will completely restructure the home page to match the screenshot design.*
