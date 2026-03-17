#!/bin/bash

# Flutter Android APK Build Script
# This script installs all necessary dependencies and builds the Android APK

set -e  # Exit on error

echo "======================================"
echo "Flutter Android APK Build Script"
echo "======================================"
echo ""

# Configuration
WORKSPACE_DIR="/workspace"
FLUTTER_VERSION="3.27.3"
FLUTTER_DIR="$WORKSPACE_DIR/flutter"
ANDROID_SDK_DIR="$WORKSPACE_DIR/android-sdk"
JDK_DIR="$WORKSPACE_DIR/jdk-17.0.2"

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Helper functions
print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_step() {
    echo ""
    echo "======================================"
    echo "$1"
    echo "======================================"
}

# Check if Flutter is installed
check_flutter() {
    if [ -f "$FLUTTER_DIR/bin/flutter" ]; then
        print_status "Flutter SDK found at $FLUTTER_DIR"
        return 0
    else
        print_warning "Flutter SDK not found"
        return 1
    fi
}

# Install Flutter SDK
install_flutter() {
    print_step "Installing Flutter SDK $FLUTTER_VERSION"

    if check_flutter; then
        print_status "Flutter already installed, skipping..."
        return 0
    fi

    cd "$WORKSPACE_DIR"

    print_status "Downloading Flutter SDK..."
    curl -L "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" -o flutter.tar.xz

    print_status "Extracting Flutter SDK..."
    tar xf flutter.tar.xz
    rm flutter.tar.xz

    print_status "Configuring Flutter..."
    export PATH="$FLUTTER_DIR/bin:$PATH"
    flutter config --no-analytics

    print_status "Flutter SDK installed successfully"
}

# Check if Java/JDK is installed
check_java() {
    if [ -d "$JDK_DIR" ] && [ -f "$JDK_DIR/bin/java" ]; then
        print_status "JDK found at $JDK_DIR"
        return 0
    else
        print_warning "JDK not found"
        return 1
    fi
}

# Install OpenJDK
install_java() {
    print_step "Installing OpenJDK 17"

    if check_java; then
        print_status "JDK already installed, skipping..."
        return 0
    fi

    cd "$WORKSPACE_DIR"

    print_status "Downloading OpenJDK 17..."
    curl -L https://download.java.net/java/GA/jdk17.0.2/dfd4a8d0985749f896bed50d7138ee7f/8/GPL/openjdk-17.0.2_linux-x64_bin.tar.gz -o jdk17.tar.gz

    print_status "Extracting JDK..."
    tar xzf jdk17.tar.gz
    rm jdk17.tar.gz

    print_status "OpenJDK 17 installed successfully"
}

# Check if Android SDK is installed
check_android_sdk() {
    if [ -d "$ANDROID_SDK_DIR/platform-tools" ] && [ -d "$ANDROID_SDK_DIR/platforms" ]; then
        print_status "Android SDK found at $ANDROID_SDK_DIR"
        return 0
    else
        print_warning "Android SDK not found or incomplete"
        return 1
    fi
}

# Install Android SDK
install_android_sdk() {
    print_step "Installing Android SDK"

    if check_android_sdk; then
        print_status "Android SDK already installed, skipping..."
        return 0
    fi

    cd "$WORKSPACE_DIR"

    # Download command line tools
    print_status "Downloading Android command line tools..."
    mkdir -p "$ANDROID_SDK_DIR/cmdline-tools"
    cd "$ANDROID_SDK_DIR/cmdline-tools"
    curl -L https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -o cmdline-tools.zip

    print_status "Extracting command line tools..."
    python3 -m zipfile -e cmdline-tools.zip .
    mv cmdline-tools latest
    rm cmdline-tools.zip

    # Make tools executable
    chmod +x "$ANDROID_SDK_DIR/cmdline-tools/latest/bin"/*

    # Accept licenses
    print_status "Accepting Android SDK licenses..."
    mkdir -p "$ANDROID_SDK_DIR/licenses"
    echo "24333f8a63b6825ea9c5514f83c2829b004d1fee" > "$ANDROID_SDK_DIR/licenses/android-sdk-license"
    echo "d56f5187479451eabf01fb78af6dfcb131a6481e" >> "$ANDROID_SDK_DIR/licenses/android-sdk-license"
    echo "24333f8a63b6825ea9c5514f83c2829b004d1fee" >> "$ANDROID_SDK_DIR/licenses/android-sdk-license"

    # Install SDK components
    print_status "Installing Android SDK components (this may take a few minutes)..."
    export JAVA_HOME="$JDK_DIR"
    export PATH="$JAVA_HOME/bin:$PATH"

    # Install platform-tools, platforms, and build-tools
    (while true; do echo "y"; sleep 0.5; done) | timeout 240 "$ANDROID_SDK_DIR/cmdline-tools/latest/bin/sdkmanager" \
        "platform-tools" \
        "platforms;android-34" \
        "build-tools;34.0.0" > /dev/null 2>&1 || true

    # Wait for installation to complete
    sleep 5

    if check_android_sdk; then
        print_status "Android SDK installed successfully"
    else
        print_error "Android SDK installation may be incomplete"
    fi
}

# Setup environment variables
setup_environment() {
    print_step "Setting up environment variables"

    export JAVA_HOME="$JDK_DIR"
    export ANDROID_HOME="$ANDROID_SDK_DIR"
    export ANDROID_SDK_ROOT="$ANDROID_SDK_DIR"
    export PATH="$FLUTTER_DIR/bin:$ANDROID_SDK_DIR/platform-tools:$JAVA_HOME/bin:$PATH"

    print_status "JAVA_HOME=$JAVA_HOME"
    print_status "ANDROID_HOME=$ANDROID_HOME"
    print_status "PATH updated"
}

# Ensure Android platform exists in project
setup_android_platform() {
    print_step "Setting up Android platform"

    if [ ! -d "android" ]; then
        print_warning "Android platform not found, creating..."
        flutter create --platforms=android .
        print_status "Android platform created"
    else
        print_status "Android platform already exists"
    fi
}

# Get Flutter dependencies
get_dependencies() {
    print_step "Installing Flutter dependencies"

    flutter pub get
    print_status "Dependencies installed"
}

# Build APK
build_apk() {
    print_step "Building Android APK"

    print_status "Starting APK build (this may take a few minutes)..."
    flutter build apk

    if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
        print_status "APK built successfully!"
        echo ""
        print_status "APK Location: build/app/outputs/flutter-apk/app-release.apk"

        # Get APK size
        APK_SIZE=$(du -h build/app/outputs/flutter-apk/app-release.apk | cut -f1)
        print_status "APK Size: $APK_SIZE"
    else
        print_error "APK build failed!"
        exit 1
    fi
}

# Main execution
main() {
    # Check if we're in a Flutter project
    if [ ! -f "pubspec.yaml" ]; then
        print_error "No pubspec.yaml found. Please run this script from your Flutter project root."
        exit 1
    fi

    print_status "Starting build process..."

    # Install dependencies
    install_flutter
    install_java
    install_android_sdk

    # Setup environment
    setup_environment

    # Configure Flutter to use Android SDK
    flutter config --android-sdk "$ANDROID_SDK_DIR"

    # Setup project
    setup_android_platform
    get_dependencies

    # Build APK
    build_apk

    echo ""
    print_step "Build Complete!"
    echo ""
    print_status "All done! Your APK is ready for distribution."
    echo ""
}

# Run main function
main "$@"
