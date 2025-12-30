# Where Is Kenny?

A cross-platform Flutter app to find Kenny from South Park! Features distance tracking to Kenny's figure in Tromso, Norway, a soundboard with Kenny sounds, and a 3D model explorer.

## Features

### 1. Distance Tracker
- Real-time GPS distance to Kenny's location (69.705561°N, 18.832721°E, 488.8m altitude)
- Animated distance display with color coding (green = close, red = far)
- Automatic metric/imperial unit detection
- Optional proximity beep with variable pitch

### 2. Kenny Soundboard
- Grid of Kenny sound buttons
- Easy to add new sounds via JSON config
- Visual feedback and animations

### 3. 3D Model Explorer
- GLTF/GLB model viewer
- X-ray mode with slider to reveal parts
- Tap-to-focus on individual parts
- Touch rotation for detailed inspection
- Part info overlay

## Getting Started

### Prerequisites
- Flutter SDK 3.10.4+
- Android Studio / Xcode (for mobile builds)
- Chrome (for web builds)

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/where_is_kenny.git
cd where_is_kenny

# Get dependencies
flutter pub get

# Run on web
flutter run -d chrome

# Run on Android
flutter run -d android

# Run on iOS
flutter run -d ios
```

### Adding Sound Files

1. Download Kenny sounds from [MyInstants](https://www.myinstants.com/en/search/?name=kenny)
2. Add MP3 files to `assets/sounds/`
3. Update `assets/config/sounds.json` with new entries
4. Rebuild the app

Required sounds:
- `beep.mp3` - Proximity beep
- `killed_kenny.mp3` - "They killed Kenny!"
- `kenny_crying.mp3`, `kenny_muffled.mp3`, etc.

### Adding 3D Models

1. Export your model as GLTF/GLB format (Blender recommended)
2. Add files to `assets/models/`
3. Update `assets/config/model_config.json`
4. Rebuild the app

## Building for Production

```bash
# Web
flutter build web --release

# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS (requires Mac with Xcode)
flutter build ios --release
```

## Project Structure

```
lib/
├── main.dart              # App entry point
├── app.dart               # Main app with navigation
├── config/
│   └── constants.dart     # Kenny coordinates, settings
├── features/
│   ├── distance/          # Distance tracker feature
│   ├── soundboard/        # Kenny soundboard feature
│   └── model_viewer/      # 3D model explorer feature
├── services/
│   ├── location_service.dart
│   ├── audio_service.dart
│   └── unit_converter.dart
└── shared/
    └── theme/             # App theming
```

## Kenny's Location

The app tracks distance to a Kenny figure located at:
- **Latitude**: 69.705561°N
- **Longitude**: 18.832721°E
- **Altitude**: 488.8 meters

This is near Tromso, Norway!

## License

This project is for educational/personal use. South Park is a trademark of Comedy Central/Paramount.

## Contributing

Feel free to submit issues and pull requests!
