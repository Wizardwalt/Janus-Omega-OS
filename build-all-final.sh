#!/bin/bash
# build-all-final.sh — Master build script for ISO + APK

echo "=== JANUS OMEGA OS BUILD SYSTEM v7.0 ==="

# ==================== BUILD APK ====================
echo "Building Android APK..."
if [ -d "android" ]; then
  cd android
  ./gradlew assembleDebug
  if [ $? -eq 0 ]; then
    echo "✅ APK built successfully!"
    echo "Location: android/app/build/outputs/apk/debug/app-debug.apk"
  else
    echo "❌ APK build failed. Check Gradle errors above."
  fi
  cd ..
else
  echo "❌ android/ folder not found. Skipping APK build."
fi

# ==================== BUILD ISO (Using Docker - Works on any OS) ====================
echo "Building Arch ISO using Docker..."
if [ -d "airootfs" ]; then
  docker run --rm -v "$(pwd)":/build --privileged archlinux \
    bash -c '
      pacman -Syu --noconfirm archiso &&
      cd /build &&
      rm -rf work/ out/ 2>/dev/null || true &&
      mkarchiso -v -w work/ -o out/ airootfs/
    '
  if [ $? -eq 0 ]; then
    echo "✅ ISO built successfully!"
    echo "Location: out/ folder (look for .iso file)"
  else
    echo "❌ ISO build failed. Check Docker output above."
  fi
else
  echo "❌ airootfs/ folder not found. Skipping ISO build."
fi

echo ""
echo "Build complete. Check the messages above for success/failure."
