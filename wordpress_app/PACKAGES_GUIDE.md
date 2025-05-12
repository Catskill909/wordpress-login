# WordPress App Packages Guide

This guide explains how to use the newly added packages in the WordPress App project.

## Table of Contents
1. [Flutter Launcher Icons](#flutter-launcher-icons)
2. [Flutter Native Splash](#flutter-native-splash)
3. [Google Fonts](#google-fonts)

## Flutter Launcher Icons

Flutter Launcher Icons is a package that simplifies the task of updating your Flutter app's launcher icon.

### Configuration

The configuration for Flutter Launcher Icons is in the `flutter_launcher_icons.yaml` file at the root of the project.

```yaml
flutter_launcher_icons:
  android: "launcher_icon"
  ios: true
  image_path: "assets/images/app_icon.png"
  min_sdk_android: 21
  web:
    generate: true
    image_path: "assets/images/app_icon.png"
    background_color: "#ffffff"
    theme_color: "#ffffff"
  windows:
    generate: true
    image_path: "assets/images/app_icon.png"
    icon_size: 48
  macos:
    generate: true
    image_path: "assets/images/app_icon.png"
```

### Usage

To generate icons for all platforms:

```bash
flutter pub run flutter_launcher_icons
```

Or you can run it for specific platforms:

```bash
flutter pub run flutter_launcher_icons:main -f flutter_launcher_icons.yaml
```

## Flutter Native Splash

Flutter Native Splash is a package that generates native code for customizing the default splash screen with a background color and splash image.

### Configuration

The configuration for Flutter Native Splash is in the `flutter_native_splash.yaml` file at the root of the project.

```yaml
flutter_native_splash:
  color: "#ffffff"
  image: assets/images/splash_logo.png
  color_dark: "#121212"
  image_dark: assets/images/splash_logo.png
  android_12:
    image: assets/images/android12_splash.png
    color: "#ffffff"
    image_dark: assets/images/android12_splash.png
    color_dark: "#121212"
  android: true
  ios: true
  web: true
```

### Usage

To generate the splash screen:

```bash
dart run flutter_native_splash:create
```

To remove the splash screen:

```bash
dart run flutter_native_splash:remove
```

## Google Fonts

Google Fonts package allows you to easily use fonts from the Google Fonts catalog in your Flutter app.

### Usage in Theme

The Google Fonts package has been integrated into the app's theme in `lib/core/constants/app_theme.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ...
  static ThemeData lightTheme = ThemeData(
    // ...
    textTheme: TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      // ...
      bodyLarge: GoogleFonts.roboto(
        fontSize: 16,
        color: Colors.black87,
      ),
      // ...
    ),
  );
}
```

### Using Google Fonts in Widgets

You can also use Google Fonts directly in your widgets:

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      'Hello World',
      style: GoogleFonts.lato(
        textStyle: TextStyle(
          color: Colors.blue,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
```

### Available Fonts

You can browse all available fonts at [fonts.google.com](https://fonts.google.com/).

The package automatically downloads and caches the font files, so you don't need to include them in your assets.

### Customizing Fonts

You can customize various aspects of the fonts:

```dart
Text(
  'Custom Font with TextStyle',
  style: GoogleFonts.getFont(
    'Lato',
    textStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.italic,
    ),
  ),
)
```

## Generating Assets

To generate both app icons and splash screen, run:

```bash
flutter pub run flutter_launcher_icons
dart run flutter_native_splash:create
```

This will update your app with the new icons and splash screen based on the configuration files.
