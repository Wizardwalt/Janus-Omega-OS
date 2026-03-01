#!/bin/bash
# build-all.sh — Master build script for Janus Omega OS (ISO + APK)

echo "=== JANUS OMEGA OS BUILD SYSTEM v7.0 ==="

# ==================== BUILD APK ====================
echo "Building Android APK..."
if [ -d "android" ]; then
  cd android
  ./gradlew assembleDebug
  if [ $? -eq 0 ]; then
    echo "✅ APK built successfully: android/app/build/outputs/apk/debug/app-debug.apk"
  else
    echo "❌ APK build failed. Check Gradle errors above."
  fi
  cd ..
else
  echo "❌ android/ folder not found. APK build skipped."
fi

# ==================== BUILD ISO ====================
echo "Building Arch ISO..."
if [ -d "airootfs" ]; then
  # Install archiso if not present
  if ! command -v mkarchiso &> /dev/null; then
    echo "Installing archiso tool..."
    sudo pacman -S archiso --noconfirm
  fi

  # Clean previous build
  rm -rf work/ out/ 2>/dev/null || true

  # Build the ISO
  mkarchiso -v -w work/ -o out/ airootfs/

  if [ $? -eq 0 ]; then
    echo "✅ ISO built successfully: out/*.iso"
  else
    echo "❌ ISO build failed. Check mkarchiso errors above."
  fi
else
  echo "❌ airootfs/ folder not found. ISO build skipped."
fi

echo ""
echo "Build summary:"
ls -lh out/ 2>/dev/null || echo "No ISO found"
ls -lh android/app/build/outputs/apk/debug/ 2>/dev/null || echo "No APK found"
