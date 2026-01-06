# Scripts Usage Guide

All automation scripts for the Where Is Kenny app.

## Quick Reference

### Regenerate Icons & Splash
```bash
python scripts/regenerate_icons.py
```
Uses: `assets/images/kenny_splash_icon.png`

### Organize 3D Models
```bash
# Step 1: Rename files
python scripts/organize_models.py

# Step 2: Convert to GLB with Blender
blender --background --python scripts/convert_stl_to_glb_blender.py
```

---

## 1. Icon & Splash Generation

### `regenerate_icons.py`

**Purpose:** Automatically regenerate all app icons and splash screens

**Source:** `assets/images/kenny_splash_icon.png`

**Generates:**
- Android launcher icons (all densities)
- iOS app icons
- Web icons
- Android splash screens
- iOS splash screens
- Web splash screens

**Usage:**
```bash
cd where_is_kenny_tromso
python scripts/regenerate_icons.py
```

**When to use:**
- After editing `kenny_splash_icon.png`
- After editing `kenny_splash_icon.svg` (export to PNG first)
- After changing splash background color

**What it runs:**
1. `dart run flutter_launcher_icons` - Generates app icons
2. `dart run flutter_native_splash:create` - Generates splash screens

---

## 2. 3D Model Organization

### `organize_models.py`

**Purpose:** Rename messy STL files to clean, organized names

**Input:** Files in `assets/models/parts/` (original messy names)

**Output:**
- Renamed files in `assets/models/parts/`
- Instructions file: `GLB_CONVERSION_INSTRUCTIONS.md`

**Usage:**
```bash
python scripts/organize_models.py
```

**File Mappings:**

| Category | Original | Renamed |
|----------|----------|---------|
| **Head** | head_branded.stl_A_A_A_A_A.stl | head_part_01.stl |
| **Parka** | headfront.stl_A.stl | parka_hood_front_a.stl |
| **Legs** | legs.stl_A_A_A_A.stl | body_legs_01.stl |
| **Arms** | left.stl.stl | arm_left.stl |
| **Neck** | neck.stl.stl | neck_connector.stl |
| **Connectors** | bigpeg.stl.stl | connector_bigpeg_01.stl |

---

### `convert_stl_to_glb_blender.py`

**Purpose:** Convert grouped STL files into GLB 3D models

**Requirements:**
- Blender 3.0+ installed
- Run `organize_models.py` first

**Usage:**
```bash
blender --background --python scripts/convert_stl_to_glb_blender.py
```

**GLB Groups Created:**

| GLB File | Contains |
|----------|----------|
| `head.glb` | 18 head parts (inner structure) |
| `parka_hood.glb` | 2 parka hood front pieces |
| `legs.glb` | 8 body and leg pieces |
| `body_left.glb` | Left arm |
| `body_right.glb` | Right arm |
| `neck.glb` | Neck connector |
| `connectors.glb` | 11 pegs and dowels |

**Note:** `kenny.glb` is never modified (main assembled model)

---

## Complete Workflow Examples

### Updating the App Icon
```bash
# 1. Edit the icon
# Edit: assets/images/kenny_splash_icon.svg in Inkscape/AI
# Or edit: assets/images/kenny_splash_icon.png in Photoshop/GIMP

# 2. Export PNG if needed (1024x1024 or higher)

# 3. Regenerate
python scripts/regenerate_icons.py

# 4. Rebuild app
flutter clean
flutter run
```

### Adding New 3D Model Parts
```bash
# 1. Add new STL files to assets/models/parts/

# 2. Edit organize_models.py
# Add new file mappings to FILE_RENAMES
# Add to appropriate GLB_GROUPS

# 3. Organize
python scripts/organize_models.py

# 4. Convert to GLB
blender --background --python scripts/convert_stl_to_glb_blender.py

# 5. Update model_config.json if needed

# 6. Rebuild app
flutter clean
flutter run
```

---

## Troubleshooting

### Icon generation fails
```bash
# Ensure packages are added to pubspec.yaml
flutter pub get

# Verify icon exists
ls assets/images/kenny_splash_icon.png
```

### Blender script fails
```bash
# Check Blender is in PATH
blender --version

# Or use full path
"C:\Program Files\Blender Foundation\Blender 4.0\blender.exe" --background --python scripts/convert_stl_to_glb_blender.py

# Check STL files exist after organizing
ls assets/models/parts/head_part_*.stl
```

### Encoding errors on Windows
```bash
# Already handled in scripts
# If issues persist, run in PowerShell instead of CMD
```

---

## File Structure

```
where_is_kenny_tromso/
├── assets/
│   ├── images/
│   │   ├── kenny_splash_icon.png  ← SOURCE for all icons/splash
│   │   └── kenny_splash_icon.svg  ← Edit this, export to PNG
│   └── models/
│       ├── kenny.glb              ← NEVER MODIFY
│       ├── head.glb               ← Generated
│       ├── parka_hood.glb         ← Generated
│       └── parts/
│           ├── head_part_01.stl   ← Renamed by script
│           └── ...
├── scripts/
│   ├── regenerate_icons.py
│   ├── organize_models.py
│   ├── convert_stl_to_glb_blender.py
│   └── README.md
└── pubspec.yaml                   ← Icon/splash config
```

---

## Summary

- **ONE source icon**: `kenny_splash_icon.png`
- **ONE command**: `python scripts/regenerate_icons.py`
- **STLs organized**: `python scripts/organize_models.py`
- **GLBs generated**: `blender --background --python scripts/convert_stl_to_glb_blender.py`
- **kenny.glb**: Never touched

All automation, all the time!
