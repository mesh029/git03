# App Icon Setup Guide

A modern, professional app icon has been created for Jua X! 🎨

## Icon Design

The icon features:
- **House icon**: Represents properties (Saka Keja)
- **Service stars**: Represent services (Fresh Keja)
- **Purple gradient**: Matches your app's modern theme
- **Clean design**: Professional and recognizable

## Quick Setup

### Option 1: Online Converter (Easiest)

1. Go to https://convertio.co/svg-png/ or https://cloudconvert.com/svg-to-png
2. Upload `assets/images/app_icon.svg`
3. Set output size to **1024x1024 pixels**
4. Download the PNG file
5. Save it as `assets/images/app_icon.png`
6. Run:
   ```bash
   flutter pub run flutter_launcher_icons
   ```

### Option 2: Command Line (Linux/Mac)

1. Install rsvg-convert:
   ```bash
   # Ubuntu/Debian
   sudo apt-get install librsvg2-bin
   
   # macOS
   brew install librsvg
   ```

2. Convert SVG to PNG:
   ```bash
   rsvg-convert -w 1024 -h 1024 assets/images/app_icon.svg > assets/images/app_icon.png
   ```

3. Generate app icons:
   ```bash
   flutter pub run flutter_launcher_icons
   ```

### Option 3: Using Inkscape

1. Install Inkscape (if not already installed)
2. Open `assets/images/app_icon.svg` in Inkscape
3. File → Export PNG Image
4. Set size to 1024x1024
5. Save as `assets/images/app_icon.png`
6. Run:
   ```bash
   flutter pub run flutter_launcher_icons
   ```

## What Gets Generated

After running `flutter pub run flutter_launcher_icons`, the following will be created:

- **Android**: All required icon sizes in `android/app/src/main/res/mipmap-*/`
- **iOS**: App icon set in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- **Adaptive icons**: For modern Android devices

## Icon Files

- **Source SVG**: `assets/images/app_icon.svg` (editable vector file)
- **PNG (to be created)**: `assets/images/app_icon.png` (1024x1024)

## Customization

To customize the icon:
1. Edit `assets/images/app_icon.svg` in any vector graphics editor (Inkscape, Figma, Adobe Illustrator)
2. Follow the conversion steps above
3. Regenerate icons with `flutter pub run flutter_launcher_icons`

## Current Icon Colors

- **Background**: Purple gradient (#6366F1 to #8B5CF6)
- **House**: White with gradient
- **Service Stars**: Gold (#FCD34D)
- **Details**: Indigo (#6366F1)

Enjoy your new app icon! 🚀
