import 'dart:io';
import 'dart:convert';

void main() {
  print('App icon generation script');
  print('The SVG icon has been created at: assets/images/app_icon.svg');
  print('');
  print('To generate app icons, you have two options:');
  print('');
  print('Option 1: Use an online converter');
  print('  1. Open https://convertio.co/svg-png/ or https://cloudconvert.com/svg-to-png');
  print('  2. Upload assets/images/app_icon.svg');
  print('  3. Set size to 1024x1024');
  print('  4. Download and save as assets/images/app_icon.png');
  print('  5. Run: flutter pub run flutter_launcher_icons');
  print('');
  print('Option 2: Install conversion tool and run:');
  print('  sudo apt-get install librsvg2-bin  # For Ubuntu/Debian');
  print('  rsvg-convert -w 1024 -h 1024 assets/images/app_icon.svg > assets/images/app_icon.png');
  print('  flutter pub run flutter_launcher_icons');
  print('');
  print('The icon design features:');
  print('  - Modern house representing properties (Saka Keja)');
  print('  - Service stars representing services (Fresh Keja)');
  print('  - Purple gradient background matching your app theme');
  print('  - Clean, professional design');
}
