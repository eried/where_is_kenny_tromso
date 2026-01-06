# Kenny Scripts

Automation scripts for the Where Is Kenny app.

## Available Scripts

### 1. `regenerate_icons.py`
Regenerate app icons and splash screens from `kenny_splash_icon.png`

**Usage:**
```bash
python scripts/regenerate_icons.py
```

**What it does:**
- Generates Flutter launcher icons (Android, iOS, Web)
- Generates native splash screens (Android, iOS, Web)
- Uses `assets/images/kenny_splash_icon.png` as source

**Requirements:**
- Flutter packages: `flutter_launcher_icons`, `flutter_native_splash`

---

### 2. `organize_models.py`
Rename and organize STL files for 3D model parts

**Usage:**
```bash
python scripts/organize_models.py
```

**What it does:**
- Renames messy STL files to clean names
- Groups files by part category
- Generates conversion instructions for GLB

**Requirements:**
- Python 3.7+

---

### 3. `convert_stl_to_glb_blender.py`
Convert STL files to GLB using Blender (automated)

**Usage:**
```bash
blender --background --python scripts/convert_stl_to_glb_blender.py
```

**What it does:**
- Imports grouped STL files into Blender
- Combines multiple STLs into single GLB files
- Does NOT touch kenny.glb (main model)

**Requirements:**
- Blender 3.0+ installed
- Run `organize_models.py` first to rename files

**Installation:**
- Download Blender: https://www.blender.org/download/
- Add blender to PATH or use full path

---

## Workflow

### Regenerating Icons/Splash:
```bash
# Edit assets/images/kenny_splash_icon.png or .svg
# Then run:
python scripts/regenerate_icons.py
```

### Updating 3D Models:
```bash
# Step 1: Organize and rename STL files
python scripts/organize_models.py

# Step 2: Convert to GLB with Blender
blender --background --python scripts/convert_stl_to_glb_blender.py

# Or manually follow instructions in:
# GLB_CONVERSION_INSTRUCTIONS.md
```

---

## File Structure

```
assets/
├── images/
│   └── kenny_splash_icon.png  # Source icon
└── models/
    ├── kenny.glb              # ⚠️  DO NOT MODIFY
    ├── head.glb               # Generated from parts
    ├── parka_hood.glb
    ├── legs.glb
    ├── body_left.glb
    ├── body_right.glb
    ├── neck.glb
    ├── connectors.glb
    └── parts/
        ├── head_part_01.stl   # Renamed files
        ├── head_part_02.stl
        └── ...
```

---

## Notes

- `kenny.glb` is the main model and should never be regenerated
- Icon source is always `assets/images/kenny_splash_icon.png`
- STL files in `assets/models/parts/` are source files
- Generated GLB files go in `assets/models/`
