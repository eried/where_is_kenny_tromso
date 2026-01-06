#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Regenerate app icons and splash screens from kenny_splash_icon.png

This script automatically generates:
1. High-quality scaled splash images for each Android density
2. High-quality scaled launcher icons for each density
3. Flutter launcher icons (all platforms)
4. Flutter native splash screens (all platforms)

Usage:
    python scripts/regenerate_icons.py
"""

import subprocess
import sys
import os
from pathlib import Path

# Fix Windows encoding for emojis
if sys.platform == 'win32':
    os.system('chcp 65001 >nul')

# Try to import PIL for high-quality scaling
try:
    from PIL import Image
    HAS_PIL = True
except ImportError:
    HAS_PIL = False
    print("[WARN] Pillow not installed. Run: pip install Pillow")
    print("[WARN] Falling back to flutter_native_splash default scaling")


# Android density multipliers and sizes
ANDROID_DENSITIES = {
    'mdpi': 1.0,
    'hdpi': 1.5,
    'xhdpi': 2.0,
    'xxhdpi': 3.0,
    'xxxhdpi': 4.0,
}

# Base sizes
SPLASH_BASE_SIZE = 512  # mdpi splash base
LAUNCHER_BASE_SIZE = 48  # mdpi launcher base
LAUNCHER_FOREGROUND_BASE = 108  # mdpi adaptive icon foreground


def scale_image_high_quality(source_path, output_path, target_size):
    """Scale image using Lanczos resampling for sharpest results."""
    if not HAS_PIL:
        return False

    try:
        img = Image.open(source_path)

        # Use LANCZOS (best for downscaling)
        scaled = img.resize((target_size, target_size), Image.Resampling.LANCZOS)

        # Save with maximum quality
        scaled.save(output_path, 'PNG', optimize=True)
        return True
    except Exception as e:
        print(f"[ERROR] Failed to scale image: {e}")
        return False


def generate_splash_images(project_root, source_path):
    """Generate high-quality splash images for all Android densities."""
    if not HAS_PIL:
        return False

    print("\n" + "="*60)
    print("[*] Generating high-quality splash images")
    print("="*60)

    android_res = project_root / "android" / "app" / "src" / "main" / "res"

    for density, multiplier in ANDROID_DENSITIES.items():
        target_size = int(SPLASH_BASE_SIZE * multiplier)
        output_dir = android_res / f"drawable-{density}"
        output_dir.mkdir(parents=True, exist_ok=True)
        output_path = output_dir / "splash.png"

        if scale_image_high_quality(source_path, output_path, target_size):
            print(f"  [OK] {density}: {target_size}x{target_size}")
        else:
            print(f"  [FAIL] {density}")

    return True


def generate_launcher_icons(project_root, source_path):
    """Generate high-quality launcher icons for all Android densities."""
    if not HAS_PIL:
        return False

    print("\n" + "="*60)
    print("[*] Generating high-quality launcher icons")
    print("="*60)

    android_res = project_root / "android" / "app" / "src" / "main" / "res"

    # Generate mipmap icons (standard launcher icons)
    for density, multiplier in ANDROID_DENSITIES.items():
        target_size = int(LAUNCHER_BASE_SIZE * multiplier)
        output_dir = android_res / f"mipmap-{density}"
        output_dir.mkdir(parents=True, exist_ok=True)
        output_path = output_dir / "ic_launcher.png"

        if scale_image_high_quality(source_path, output_path, target_size):
            print(f"  [OK] mipmap-{density}: {target_size}x{target_size}")
        else:
            print(f"  [FAIL] mipmap-{density}")

    # Generate adaptive icon foregrounds
    for density, multiplier in ANDROID_DENSITIES.items():
        target_size = int(LAUNCHER_FOREGROUND_BASE * multiplier)
        output_dir = android_res / f"drawable-{density}"
        output_dir.mkdir(parents=True, exist_ok=True)
        output_path = output_dir / "ic_launcher_foreground.png"

        if scale_image_high_quality(source_path, output_path, target_size):
            print(f"  [OK] drawable-{density} foreground: {target_size}x{target_size}")
        else:
            print(f"  [FAIL] drawable-{density} foreground")

    return True


def safe_print(text):
    """Print text, handling encoding errors gracefully."""
    try:
        print(text)
    except UnicodeEncodeError:
        # Replace problematic characters
        print(text.encode('ascii', 'replace').decode('ascii'))


def run_command(cmd, description):
    """Run a shell command and print status."""
    safe_print(f"\n{'='*60}")
    safe_print(f"[*] {description}")
    safe_print(f"{'='*60}")

    try:
        result = subprocess.run(
            cmd,
            shell=True,
            check=True,
            capture_output=True,
            text=True,
            encoding='utf-8',
            errors='replace'  # Replace problematic characters
        )
        if result.stdout:
            safe_print(result.stdout)
        if result.stderr:
            safe_print(result.stderr)
        safe_print(f"[OK] {description} completed successfully!")
        return True
    except subprocess.CalledProcessError as e:
        safe_print(f"[ERROR] {e}")
        return False


def main():
    # Check if we're in the right directory
    project_root = Path(__file__).parent.parent
    icon_path = project_root / "assets" / "images" / "kenny_splash_icon.png"

    if not icon_path.exists():
        # Fall back to original
        icon_path = project_root / "assets" / "images" / "kenny_splash_icon.png"

    if not icon_path.exists():
        print(f"[ERROR] Icon not found at {icon_path}")
        print("Please ensure kenny_splash_icon.png exists in assets/images/")
        sys.exit(1)

    print("\n" + "="*60)
    print("Kenny Icon & Splash Regeneration Tool")
    print("="*60)
    print(f"Using icon: {icon_path}")

    if HAS_PIL:
        # Step 1: Generate high-quality splash images with Lanczos
        generate_splash_images(project_root, icon_path)

        # Step 2: Generate high-quality launcher icons with Lanczos
        generate_launcher_icons(project_root, icon_path)
        print("\n[INFO] High-quality images generated with Lanczos resampling")

    # Step 3: Run flutter tools for iOS/Web and other platform-specific setup
    if not run_command(
        "dart run flutter_launcher_icons",
        "Generating launcher icons (iOS, Web, Android XML configs)"
    ):
        print("\n[WARN] Failed to generate launcher icons")

    # Step 4: Regenerate splash screens (for iOS/Web)
    if not run_command(
        "dart run flutter_native_splash:create",
        "Generating native splash screens (iOS, Web)"
    ):
        print("\n[WARN] Failed to generate splash screens")

    # Step 5: If we have PIL, re-apply our high-quality Android images
    # (flutter tools may have overwritten them)
    if HAS_PIL:
        print("\n[INFO] Re-applying high-quality Android images...")
        generate_splash_images(project_root, icon_path)
        generate_launcher_icons(project_root, icon_path)

    print("\n" + "="*60)
    print("COMPLETE! Icons and splash screens regenerated!")
    print("="*60)
    print("\nGenerated with Lanczos resampling for maximum sharpness:")
    print("  - Android splash: 512-2048px per density")
    print("  - Android launcher icons: 48-192px per density")
    print("  - iOS/Web icons and splash via Flutter tools")
    print("\nNext steps:")
    print("  1. Run 'flutter clean' if you encounter issues")
    print("  2. Rebuild your app to see the changes")
    print("\n")

if __name__ == "__main__":
    main()
