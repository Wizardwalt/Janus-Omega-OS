#!/bin/bash
echo "=== JANUS OMEGA OS BUILD SYSTEM v7.0 ==="

# Build APK
echo "Building APK..."
cd android
./gradlew assembleDebug
if [ $? -eq 0 ]; then
  echo "✅ APK built: android/app/build/outputs/apk/debug/app-debug.apk"
else
  echo "❌ APK build failed."
fi
cd ..

# Build ISO using Docker
echo "Building ISO using Docker..."
docker run --rm -v "$(pwd)":/build --privileged archlinux \
  bash -c '
    pacman -Syu --noconfirm archiso &&
    cd /build &&
    rm -rf work/ out/ 2>/dev/null || true &&
    mkarchiso -v -w work/ -o out/ airootfs/
  '

if [ $? -eq 0 ]; then
  echo "✅ ISO built: out/*.iso"
else
  echo "❌ ISO build failed."
fi
