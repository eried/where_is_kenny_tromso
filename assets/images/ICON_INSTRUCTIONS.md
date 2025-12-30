# App Icon and Splash Screen Setup

## Required Files

Create the following images and place them in this folder:

### 1. `app_icon.png`
- Size: 1024x1024 pixels
- Format: PNG with transparency
- Design: Kenny's hooded face (orange background, hidden face)
- Used for: iOS and Android app icons

### 2. `app_icon_foreground.png` (Android Adaptive Icon)
- Size: 1024x1024 pixels
- Format: PNG with transparency
- Design: Just Kenny's silhouette/face, no background
- The background will be orange (#FF6B35)

### 3. `splash_logo.png`
- Size: 512x512 pixels
- Format: PNG with transparency
- Design: Kenny silhouette or "K" logo
- Background will be dark (#1a1a2e)

## Generating Icons

After adding the images, run these commands:

```bash
# Generate app icons
flutter pub run flutter_launcher_icons

# Generate splash screen
flutter pub run flutter_native_splash:create
```

## Design Tips

- Kenny's iconic look: Orange parka hood covering face
- Only eyes visible (or just the hood shape)
- Simple, bold shapes work best at small sizes
- Consider a stylized "K" as an alternative

## Tools for Creating Icons

- Figma (free)
- Canva (free)
- Adobe Illustrator
- Inkscape (free)

## Color Palette

- Orange (Primary): #FF6B35
- Dark Background: #1a1a2e
- Darker: #0f0f1a
- White: #FFFFFF
