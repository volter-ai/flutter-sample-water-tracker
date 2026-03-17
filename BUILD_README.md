# Flutter Android APK Build Instructions

This document explains how to build the Android APK for this Flutter application.

## Quick Start

Simply run the build script:

```bash
./build.sh
```

The script will automatically:
1. Install Flutter SDK (if not already installed)
2. Install OpenJDK 17 (if not already installed)
3. Install Android SDK and required components (if not already installed)
4. Set up the Android platform for the project
5. Install Flutter dependencies
6. Build the APK

## Output

The built APK will be located at:
```
build/app/outputs/flutter-apk/app-release.apk
```

## What Gets Installed

If components are not already present, the script will install:

### Flutter SDK
- **Version:** 3.27.3 (stable)
- **Location:** `/workspace/flutter/`
- **Includes:** Dart SDK, Flutter framework, and dev tools

### OpenJDK
- **Version:** 17.0.2
- **Location:** `/workspace/jdk-17.0.2/`
- **Purpose:** Required for Android build tools

### Android SDK
- **Location:** `/workspace/android-sdk/`
- **Components:**
  - Platform Tools (adb, fastboot)
  - Android Platform 34
  - Build Tools 34.0.0
  - Command Line Tools

## System Requirements

- Linux x86_64 system
- Internet connection for downloading dependencies
- Approximately 2-3 GB of disk space for all components
- Python 3 (for extracting zip files)

## Build Types

The script builds a **release APK** by default. The APK is:
- Optimized for size and performance
- Tree-shaken (unused code removed)
- Signed with debug keys (suitable for testing)

### For Production Release

To create a production-signed APK:

1. Create a keystore:
```bash
keytool -genkey -v -keystore ~/release-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias release
```

2. Create `android/key.properties`:
```properties
storePassword=<password>
keyPassword=<password>
keyAlias=release
storeFile=<path-to-keystore>
```

3. Update `android/app/build.gradle` to use the keystore

4. Run the build script again

## Troubleshooting

### Script Fails with "No pubspec.yaml found"
- Make sure you're running the script from the Flutter project root directory

### Build Fails Due to Missing Dependencies
- The script should handle this automatically
- If issues persist, delete `/workspace/flutter`, `/workspace/jdk-17.0.2`, and `/workspace/android-sdk` directories and run the script again

### APK Won't Install on Device
- For production deployment, you need to sign with a production keystore
- The debug-signed APK may not install over a production-signed version

### Gradle Build Errors
- Ensure you have sufficient disk space
- Check that Java and Android SDK are properly configured
- Try cleaning the build: `flutter clean` then run the script again

## Manual Build

If you prefer to build manually after running the script once:

```bash
# Set environment variables
export JAVA_HOME=/workspace/jdk-17.0.2
export ANDROID_HOME=/workspace/android-sdk
export PATH="/workspace/flutter/bin:$ANDROID_HOME/platform-tools:$JAVA_HOME/bin:$PATH"

# Build APK
flutter build apk
```

## Additional Build Options

### Debug APK
For a debug APK with debugging symbols:
```bash
flutter build apk --debug
```

### Split APKs by ABI
For smaller APK files split by architecture:
```bash
flutter build apk --split-per-abi
```

This creates separate APKs for different CPU architectures (arm64-v8a, armeabi-v7a, x86_64).

## More Information

- [Flutter Documentation](https://docs.flutter.dev/)
- [Android App Bundle](https://developer.android.com/guide/app-bundle)
- [Flutter Build Modes](https://docs.flutter.dev/testing/build-modes)
