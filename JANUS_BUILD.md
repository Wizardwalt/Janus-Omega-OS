# JANUS_BUILD.md

## Build Instructions

### Rust Target

1. **Prerequisites**:
   - Install Rust: Follow the instructions at [rustup.rs](https://rustup.rs).
   - Ensure that you have the latest version of Rust by running:
     ```bash
     rustup update
     ```

2. **Building the Project**:
   - Clone the repository:
     ```bash
     git clone https://github.com/Wizardwalt/Janus-Omega-OS.git
     cd Janus-Omega-OS
     ```
   - Build the project:
     ```bash
     cargo build --release
     ```

3. **Running the Project**:
   - You can run the project using:
     ```bash
     cargo run
     ```

### Android Target

1. **Prerequisites**:
   - Install Android Studio: Follow the installation guide at [developer.android.com/studio](https://developer.android.com/studio).
   - Set up the Android NDK and SDK.

2. **Building for Android**:
   - Make sure to open the Android project in Android Studio.
   - Use Gradle to build the project:
     ```bash
     ./gradlew assembleRelease
     ```

3. **Deploying to a Device**:
   - Connect your Android device or start an emulator.
   - Install the APK created in the `app/build/outputs/apk/release/` directory:
     ```bash
     adb install app/build/outputs/apk/release/app-release.apk
     ```

## Troubleshooting

- Ensure you have all the necessary dependencies installed for both Rust and Android.
- Check for any compatibility issues, especially when building for Android targets.
