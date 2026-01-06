#!/usr/bin/env python3
"""
Organize and convert STL files to GLB models

This script:
1. Renames STL files based on their category
2. Combines STL files into GLB files for each part category
3. Does NOT touch kenny.glb (main model)

Categories:
- Head Parts: Inner head structure pieces
- Parka Hood: Front parka hood pieces
- Body & Legs: Torso and leg pieces
- Arms: Left and right arms
- Neck: Neck connector
- Connectors: Pegs and dowels

Requirements:
    pip install trimesh pygltflib numpy

Usage:
    python scripts/organize_models.py
"""

import shutil
from pathlib import Path
import json

# File mappings: old_name -> new_name
FILE_RENAMES = {
    # Ignore files (keep but don't convert)
    "glue_base_hole.stl.stl": "ignore_glue_base_hole.stl",
    "ground_anchor.stl.stl": "ignore_ground_anchor.stl",

    # Head parts (inner structure)
    "head_branded.stl_A_A_A_A_A.stl": "head_part_01.stl",
    "head_branded.stl_A_A_A_A_B.stl": "head_part_02.stl",
    "head_branded.stl_A_A_A_B_B.stl": "head_part_03.stl",
    "head_branded.stl_A_A_B_A_A.stl": "head_part_04.stl",
    "head_branded.stl_A_A_B_A_B.stl": "head_part_05.stl",
    "head_branded.stl_A_A_B_B_B.stl": "head_part_06.stl",
    "head_branded.stl_A_B_B_A_A.stl": "head_part_07.stl",
    "head_branded.stl_A_B_B_A_B.stl": "head_part_08.stl",
    "head_branded.stl_A_B_B_B_B.stl": "head_part_09.stl",
    "head_branded.stl_B_A_A_A_A.stl": "head_part_10.stl",
    "head_branded.stl_B_A_A_A_B.stl": "head_part_11.stl",
    "head_branded.stl_B_A_A_B_B.stl": "head_part_12.stl",
    "head_branded.stl_B_A_B_A_A.stl": "head_part_13.stl",
    "head_branded.stl_B_A_B_A_B.stl": "head_part_14.stl",
    "head_branded.stl_B_A_B_B_B.stl": "head_part_15.stl",
    "head_branded.stl_B_B_B_A_A.stl": "head_part_16.stl",
    "head_branded.stl_B_B_B_A_B.stl": "head_part_17.stl",
    "head_branded.stl_B_B_B_B_B.stl": "head_part_18.stl",

    # Parka hood front
    "headfront.stl_A.stl": "parka_hood_front_a.stl",
    "headfront.stl_B.stl": "parka_hood_front_b.stl",

    # Body and legs
    "legs.stl_A_A_A_A (2).stl": "body_legs_01.stl",
    "legs.stl_A_A_A_A.stl": "body_legs_02.stl",
    "legs.stl_A_A_B_A.stl": "body_legs_03.stl",
    "legs.stl_A_B_A_B.stl": "body_legs_04.stl",
    "legs.stl_A_B_B_B.stl": "body_legs_05.stl",
    "legs.stl_B_A_A_A.stl": "body_legs_06.stl",
    "legs.stl_B_A_B_A.stl": "body_legs_07.stl",
    "legs.stl_B_B_A_B.stl": "body_legs_08.stl",

    # Arms
    "left.stl.stl": "arm_left.stl",
    "right.stl.stl": "arm_right.stl",

    # Neck
    "neck.stl.stl": "neck_connector.stl",

    # Pegs and connectors
    "bigpeg.stl(6).stl": "connector_bigpeg_01.stl",
    "bigpeg.stl(7).stl": "connector_bigpeg_02.stl",
    "bigpeg.stl.stl": "connector_bigpeg_03.stl",
    "headfront.stl-Dowel-Connector-1.stl": "connector_dowel_01.stl",
    "headfrontpegs.stl_3(6).stl": "connector_peg_01.stl",
    "headfrontpegs.stl_3(7).stl": "connector_peg_02.stl",
    "headfrontpegs.stl_3(8).stl": "connector_peg_03.stl",
    "headfrontpegs.stl_3(9).stl": "connector_peg_04.stl",
    "headfrontpegs.stl_3(10).stl": "connector_peg_05.stl",
    "headfrontpegs.stl_3(11).stl": "connector_peg_06.stl",
    "headfrontpegs.stl_3.stl": "connector_peg_07.stl",
}

# GLB groupings: glb_name -> list of stl files (using new names)
GLB_GROUPS = {
    "head.glb": [
        "head_part_01.stl", "head_part_02.stl", "head_part_03.stl",
        "head_part_04.stl", "head_part_05.stl", "head_part_06.stl",
        "head_part_07.stl", "head_part_08.stl", "head_part_09.stl",
        "head_part_10.stl", "head_part_11.stl", "head_part_12.stl",
        "head_part_13.stl", "head_part_14.stl", "head_part_15.stl",
        "head_part_16.stl", "head_part_17.stl", "head_part_18.stl",
    ],
    "parka_hood.glb": [
        "parka_hood_front_a.stl",
        "parka_hood_front_b.stl",
    ],
    "legs.glb": [
        "body_legs_01.stl", "body_legs_02.stl", "body_legs_03.stl",
        "body_legs_04.stl", "body_legs_05.stl", "body_legs_06.stl",
        "body_legs_07.stl", "body_legs_08.stl",
    ],
    "body_left.glb": ["arm_left.stl"],
    "body_right.glb": ["arm_right.stl"],
    "neck.glb": ["neck_connector.stl"],
    "connectors.glb": [
        "connector_bigpeg_01.stl", "connector_bigpeg_02.stl", "connector_bigpeg_03.stl",
        "connector_dowel_01.stl",
        "connector_peg_01.stl", "connector_peg_02.stl", "connector_peg_03.stl",
        "connector_peg_04.stl", "connector_peg_05.stl", "connector_peg_06.stl",
        "connector_peg_07.stl",
    ],
}


def rename_stl_files(parts_dir: Path):
    """Rename STL files according to FILE_RENAMES mapping."""
    print("\n📝 Step 1: Renaming STL files...")
    print("="*60)

    renamed_count = 0
    for old_name, new_name in FILE_RENAMES.items():
        old_path = parts_dir / old_name
        new_path = parts_dir / new_name

        if old_path.exists():
            print(f"  {old_name}")
            print(f"  → {new_name}")
            shutil.move(str(old_path), str(new_path))
            renamed_count += 1
        else:
            print(f"  ⚠️  Not found: {old_name}")

    print(f"\n✅ Renamed {renamed_count} files")
    return renamed_count


def convert_stl_to_glb_placeholder(parts_dir: Path, models_dir: Path):
    """
    Create placeholder instructions for STL to GLB conversion.

    Note: Actual STL to GLB conversion requires external tools like:
    - Blender (with Python scripting)
    - Online converters
    - trimesh library (complex for multiple meshes)
    """
    print("\n🔧 Step 2: GLB Conversion Instructions...")
    print("="*60)

    instructions_file = models_dir.parent / "scripts" / "GLB_CONVERSION_INSTRUCTIONS.md"

    instructions = """# GLB Conversion Instructions

## Current Status
STL files have been renamed in `assets/models/parts/`

## Option 1: Use Blender (Recommended)

### Automated Blender Script:
1. Install Blender: https://www.blender.org/download/
2. Use the provided `convert_stl_to_glb_blender.py` script
3. Run: `blender --background --python scripts/convert_stl_to_glb_blender.py`

### Manual in Blender:
1. Open Blender
2. Delete default cube (X key)
3. For each GLB group below:
   - File → Import → STL → Select all STLs for that group
   - Select all imported objects (A key)
   - File → Export → glTF 2.0 (.glb)
   - Save with the group name

## Option 2: Online Converter
- Use: https://products.aspose.app/3d/conversion/stl-to-glb
- Upload multiple STLs for each group
- Download as GLB

## Option 3: Python with trimesh
- Install: `pip install trimesh pygltflib`
- Use the provided script (experimental)

## GLB Groups to Create:

"""

    for glb_name, stl_files in GLB_GROUPS.items():
        instructions += f"\n### {glb_name}\n"
        instructions += "Files to combine:\n"
        for stl in stl_files:
            instructions += f"- {stl}\n"

    instructions += """
## After Conversion:
1. Place generated GLB files in `assets/models/`
2. Keep `kenny.glb` unchanged (main model)
3. Update `model_config.json` if needed
4. Run `flutter clean` and rebuild
"""

    instructions_file.parent.mkdir(parents=True, exist_ok=True)
    instructions_file.write_text(instructions)

    print(f"📄 Instructions saved to: {instructions_file}")
    print("\n⚠️  Note: Actual GLB conversion requires external tools")
    print("See GLB_CONVERSION_INSTRUCTIONS.md for details")


def main():
    project_root = Path(__file__).parent.parent
    parts_dir = project_root / "assets" / "models" / "parts"
    models_dir = project_root / "assets" / "models"

    print("🎯 Kenny Model Organization Tool")
    print(f"Parts directory: {parts_dir}")

    if not parts_dir.exists():
        print(f"❌ Error: Parts directory not found: {parts_dir}")
        return

    # Step 1: Rename files
    renamed_count = rename_stl_files(parts_dir)

    if renamed_count == 0:
        print("\n⚠️  No files were renamed. Check if files already exist or paths are correct.")

    # Step 2: Generate conversion instructions
    convert_stl_to_glb_placeholder(parts_dir, models_dir)

    print("\n" + "="*60)
    print("✅ Organization complete!")
    print("="*60)
    print("\nNext steps:")
    print("1. Check renamed files in assets/models/parts/")
    print("2. Follow GLB_CONVERSION_INSTRUCTIONS.md to create GLB files")
    print("3. Place GLB files in assets/models/")
    print("\n")


if __name__ == "__main__":
    main()
