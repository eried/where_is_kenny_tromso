#!/usr/bin/env python3
"""
Blender script to convert grouped STL files to GLB

This script must be run with Blender:
    blender --background --python scripts/convert_stl_to_glb_blender.py

It will:
1. Load each group of STL files
2. Combine them into a single scene
3. Export as GLB file

Requirements:
    - Blender 3.0+ installed
"""

import bpy
import sys
from pathlib import Path

# Get project root (assuming script is in scripts/)
project_root = Path(__file__).parent.parent
parts_dir = project_root / "assets" / "models" / "parts"
output_dir = project_root / "assets" / "models"

# GLB groupings using ORIGINAL filenames (before renaming)
# This allows the script to work without running organize_models.py first
GLB_GROUPS = {
    # Head: ONLY the inner head structure (head_branded parts)
    # Does NOT include headfront (parka hood) parts!
    "head.glb": [
        "head_branded.stl_A_A_A_A_A.stl",
        "head_branded.stl_A_A_A_A_B.stl",
        "head_branded.stl_A_A_A_B_B.stl",
        "head_branded.stl_A_A_B_A_A.stl",
        "head_branded.stl_A_A_B_A_B.stl",
        "head_branded.stl_A_A_B_B_B.stl",
        "head_branded.stl_A_B_B_A_A.stl",
        "head_branded.stl_A_B_B_A_B.stl",
        "head_branded.stl_A_B_B_B_B.stl",
        "head_branded.stl_B_A_A_A_A.stl",
        "head_branded.stl_B_A_A_A_B.stl",
        "head_branded.stl_B_A_A_B_B.stl",
        "head_branded.stl_B_A_B_A_A.stl",
        "head_branded.stl_B_A_B_A_B.stl",
        "head_branded.stl_B_A_B_B_B.stl",
        "head_branded.stl_B_B_B_A_A.stl",
        "head_branded.stl_B_B_B_A_B.stl",
        "head_branded.stl_B_B_B_B_B.stl",
    ],
    # Parka Hood Front: The outer hood pieces (headfront parts)
    "parka_hood.glb": [
        "headfront.stl_A.stl",
        "headfront.stl_B.stl",
    ],
    # Legs and torso
    "legs.glb": [
        "legs.stl_A_A_A_A.stl",
        "legs.stl_A_A_A_A (2).stl",
        "legs.stl_A_A_B_A.stl",
        "legs.stl_A_B_A_B.stl",
        "legs.stl_A_B_B_B.stl",
        "legs.stl_B_A_A_A.stl",
        "legs.stl_B_A_B_A.stl",
        "legs.stl_B_B_A_B.stl",
    ],
    # Arms
    "body_left.glb": ["left.stl.stl"],
    "body_right.glb": ["right.stl.stl"],
    # Neck
    "neck.glb": ["neck.stl.stl"],
    # Connectors and pegs
    "connectors.glb": [
        "bigpeg.stl.stl",
        "bigpeg.stl(6).stl",
        "bigpeg.stl(7).stl",
        "headfront.stl-Dowel-Connector-1.stl",
        "headfrontpegs.stl_3.stl",
        "headfrontpegs.stl_3(6).stl",
        "headfrontpegs.stl_3(7).stl",
        "headfrontpegs.stl_3(8).stl",
        "headfrontpegs.stl_3(9).stl",
        "headfrontpegs.stl_3(10).stl",
        "headfrontpegs.stl_3(11).stl",
    ],
}


def clear_scene():
    """Delete all objects in the scene."""
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete()


def import_stl_files(stl_files):
    """Import a list of STL files into the scene."""
    imported_count = 0
    for stl_file in stl_files:
        stl_path = parts_dir / stl_file
        if stl_path.exists():
            bpy.ops.import_mesh.stl(filepath=str(stl_path))
            imported_count += 1
            print(f"  ✓ Imported: {stl_file}")
        else:
            print(f"  ⚠️  Not found: {stl_file}")
    return imported_count


def export_glb(output_path):
    """Export all objects in scene as GLB."""
    bpy.ops.export_scene.gltf(
        filepath=str(output_path),
        export_format='GLB',
        export_selected=False,
    )
    print(f"  ✓ Exported: {output_path.name}")


def main():
    print("="*60)
    print("🎨 Blender STL to GLB Converter")
    print("="*60)

    if not parts_dir.exists():
        print(f"❌ Error: Parts directory not found: {parts_dir}")
        sys.exit(1)

    output_dir.mkdir(parents=True, exist_ok=True)

    total_converted = 0

    for glb_name, stl_files in GLB_GROUPS.items():
        print(f"\n📦 Processing: {glb_name}")
        print("-"*60)

        # Clear scene
        clear_scene()

        # Import STL files
        imported = import_stl_files(stl_files)

        if imported > 0:
            # Export as GLB
            output_path = output_dir / glb_name
            export_glb(output_path)
            total_converted += 1
        else:
            print(f"  ⚠️  Skipped {glb_name} - no files found")

    print("\n" + "="*60)
    print(f"✅ Converted {total_converted}/{len(GLB_GROUPS)} GLB files")
    print("="*60)
    print(f"\nOutput directory: {output_dir}")
    print("Note: kenny.glb was not modified")
    print()


if __name__ == "__main__":
    main()
