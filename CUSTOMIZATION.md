# Where Is Kenny - Customization Guide

This guide explains how to customize sounds, 3D models, app icons, and splash screens.

---

## Table of Contents

1. [Sounds (Soundboard)](#1-sounds-soundboard)
2. [3D Models](#2-3d-models)
3. [App Icons](#3-app-icons)
4. [Splash Screen](#4-splash-screen)
5. [Distance Messages](#5-distance-messages)
6. [Kenny's Location](#6-kennys-location)

---

## 1. Sounds (Soundboard)

### Files to Modify

| File | Purpose |
|------|---------|
| `assets/sounds/*.mp3` | Sound files (MP3 format) |
| `assets/config/sounds.json` | Sound configuration |

### Adding Sounds

1. **Download MP3 files** from [MyInstants Kenny Sounds](https://www.myinstants.com/en/search/?name=kenny)

2. **Place MP3 files** in `assets/sounds/` folder:
   ```
   assets/sounds/
   ├── killed_kenny.mp3
   ├── kenny_crying.mp3
   ├── kenny_muffled.mp3
   └── your_custom_sound.mp3
   ```

3. **Edit `assets/config/sounds.json`**:
   ```json
   {
     "sounds": [
       {
         "id": "unique_id",
         "file": "your_sound.mp3",
         "label": "Button Label",
         "icon": "icon_name"
       }
     ]
   }
   ```

### Available Icons for Sounds

- `skull` - Warning amber icon
- `sentiment_very_dissatisfied` - Sad face
- `record_voice_over` - Voice icon
- `warning` - Priority high icon
- `favorite_border` - Heart outline
- `mic` - Microphone
- `music_note` - Default music note

### Apply Changes

No rebuild needed - sounds are loaded at runtime. Just restart the app.

---

## 2. 3D Models

### Files to Modify

| File | Purpose |
|------|---------|
| `assets/models/*.glb` | 3D model files (GLTF/GLB format) |
| `assets/config/model_config.json` | Model configuration |

### Adding a 3D Model

1. **Export your 3D model** as GLB (recommended) or GLTF format
   - Blender: File > Export > glTF 2.0 (.glb/.gltf)
   - Size: Keep under 50MB for smooth loading

2. **Place GLB files** in `assets/models/` folder:
   ```
   assets/models/
   ├── kenny_full.glb          # Main assembled model
   ├── kenny_head.glb          # Individual part
   ├── kenny_body.glb          # Individual part
   └── kenny_base.glb          # Individual part
   ```

3. **Edit `assets/config/model_config.json`**:
   ```json
   {
     "mainModel": "kenny_full.glb",
     "name": "Kenny Statue - Tromsø",
     "parts": [
       {
         "id": "head",
         "name": "Hood Section",
         "filename": "kenny_head.glb",
         "description": "The iconic orange hood with fur trim",
         "order": 0,
         "metadata": {
           "material": "Orange ABS plastic",
           "weight": "2.1 kg",
           "print_time": "18 hours"
         }
       },
       {
         "id": "body",
         "name": "Body Section",
         "filename": "kenny_body.glb",
         "description": "Main torso and arms",
         "order": 1,
         "metadata": {
           "material": "Orange ABS plastic",
           "weight": "8.5 kg",
           "print_time": "72 hours"
         }
       }
     ]
   }
   ```

### Model Requirements

- Format: GLTF 2.0 (.glb or .gltf)
- Textures: Embedded in GLB or separate files referenced in GLTF
- Scale: Models are displayed as-is, ensure consistent scale
- Colors: Use PBR materials for best appearance

### Apply Changes

Restart the app. Models are loaded dynamically from the config.

---

## 3. App Icons

### Files to Create

| File | Size | Purpose |
|------|------|---------|
| `assets/images/app_icon.png` | 1024x1024 | Main app icon |
| `assets/images/app_icon_foreground.png` | 1024x1024 | Android adaptive icon foreground |

### Creating Icons

1. **Design your icon** (1024x1024 pixels, PNG with transparency)
   - Recommended: Kenny's hooded face on orange background
   - Keep important content in center 66% for adaptive icons

2. **Place files** in `assets/images/`:
   ```
   assets/images/
   ├── app_icon.png              # Full icon (1024x1024)
   └── app_icon_foreground.png   # Just the foreground (1024x1024)
   ```

3. **Run icon generator**:
   ```bash
   flutter pub run flutter_launcher_icons
   ```

### Configuration (already set in pubspec.yaml)

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  web:
    generate: true
  image_path: "assets/images/app_icon.png"
  adaptive_icon_background: "#FF6B35"  # Orange
  adaptive_icon_foreground: "assets/images/app_icon_foreground.png"
```

### Generated Files

The command generates icons for:
- Android: `android/app/src/main/res/mipmap-*/`
- iOS: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- Web: `web/icons/`

---

## 4. Splash Screen

### Option A: Static Image Splash

1. **Create splash logo** (512x512 pixels, PNG with transparency):
   ```
   assets/images/splash_logo.png
   ```

2. **Run splash generator**:
   ```bash
   flutter pub run flutter_native_splash:create
   ```

### Configuration (already set in pubspec.yaml)

```yaml
flutter_native_splash:
  color: "#1a1a2e"  # Dark background
  image: "assets/images/splash_logo.png"
  android_12:
    color: "#1a1a2e"
    icon_background_color: "#FF6B35"
```

### Option B: Animated Splash (Current Implementation)

The app uses a programmatic animated splash screen (`lib/features/splash/splash_screen.dart`) that:
- Shows Kenny's hood icon with glow effect
- Animates the logo scale and fade
- Displays loading indicator
- Transitions smoothly to main screen

To customize the animated splash, edit:
- `lib/features/splash/splash_screen.dart` - Animation and layout
- `KennyHoodPainter` class - Custom icon drawing

---

## 5. Distance Messages

### File to Modify

`lib/config/distance_messages.dart`

### Customizing Messages

The file contains distance-based message lists:

```dart
// Messages shown when >100km away
static const _tooFarMessages = [
  "Your custom message here!",
  "Another fun message...",
];

// Messages shown when 50-100km away
static const _veryFarMessages = [
  // ...
];

// Continue for each distance bracket...
```

### Distance Brackets

| Distance | Variable |
|----------|----------|
| >100km | `_tooFarMessages` |
| 50-100km | `_veryFarMessages` |
| 10-50km | `_farMessages` |
| 5-10km | `_mediumFarMessages` |
| 1-5km | `_gettingCloserMessages` |
| 500m-1km | `_prettyCloseMessages` |
| 100-500m | `_veryCloseMessages` |
| 50-100m | `_almostThereMessages` |
| 10-50m | `_soCloseMessages` |
| <10m | `_youMadeItMessages` |

### Apply Changes

Rebuild the app:
```bash
flutter build apk  # Android
flutter build ios  # iOS
flutter build web  # Web
```

---

## 6. Kenny's Location

### File to Modify

`lib/config/constants.dart`

### Changing Location

```dart
class KennyLocation {
  static const double latitude = 69.705561;   // Your latitude
  static const double longitude = 18.832721;  // Your longitude
  static const double altitude = 488.8;       // Altitude in meters
}
```

### Distance Color Thresholds

```dart
class AppConfig {
  static const double closeDistance = 100;    // Green zone (meters)
  static const double mediumDistance = 1000;  // Orange zone
  static const double farDistance = 10000;    // Red zone
}
```

---

## Quick Reference: Commands

```bash
# Install dependencies
flutter pub get

# Generate app icons (after adding icon images)
flutter pub run flutter_launcher_icons

# Generate native splash (after adding splash image)
flutter pub run flutter_native_splash:create

# Build for platforms
flutter build apk --release          # Android APK
flutter build appbundle --release    # Android App Bundle
flutter build ios --release          # iOS
flutter build web --release          # Web

# Run in development
flutter run -d chrome    # Web
flutter run              # Connected device
```

---

## Color Palette Reference

| Color | Hex | Usage |
|-------|-----|-------|
| Orange (Primary) | `#FF6B35` | Kenny's color, accents |
| Dark Background | `#1a1a2e` | Main background |
| Darker | `#0f0f1a` | Navigation bar, headers |
| White | `#FFFFFF` | Text |

---

## File Structure

```
where_is_kenny/
├── assets/
│   ├── config/
│   │   ├── sounds.json        # Sound configuration
│   │   └── model_config.json  # 3D model configuration
│   ├── images/
│   │   ├── app_icon.png       # 1024x1024 app icon
│   │   ├── app_icon_foreground.png
│   │   └── splash_logo.png    # 512x512 splash logo
│   ├── models/
│   │   └── *.glb              # 3D model files
│   └── sounds/
│       └── *.mp3              # Sound files
├── lib/
│   ├── config/
│   │   ├── constants.dart     # Location & app settings
│   │   └── distance_messages.dart  # Distance-based messages
│   └── features/
│       └── splash/
│           └── splash_screen.dart  # Animated splash
└── pubspec.yaml               # Icon & splash config
```
