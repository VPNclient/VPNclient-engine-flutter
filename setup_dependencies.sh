#!/bin/bash
# setup_dependencies.sh

echo "Setting up binary dependencies for VPNclient Engine Flutter..."

# Create directories
mkdir -p android/libs
mkdir -p android/src/main/assets
mkdir -p ios/Resources/dat
mkdir -p ios/Frameworks

# Check if libXray.aar exists
if [ ! -f "android/libs/libXray.aar" ]; then
    echo "❌ libXray.aar not found!"
    echo "Please download libXray.aar manually from libXray releases and place it in android/libs/"
    echo "Visit: https://github.com/2dust/AndroidLibXrayLite/releases"
else
    echo "✅ libXray.aar found"
fi

# Check if LibXray.xcframework exists
if [ ! -d "ios/Frameworks/LibXray.xcframework" ]; then
    echo "❌ LibXray.xcframework not found!"
    echo "Please download LibXray.xcframework manually from libXray releases and place it in ios/Frameworks/"
    echo "Visit: https://github.com/2dust/AndroidLibXrayLite/releases"
else
    echo "✅ LibXray.xcframework found"
fi

# Download geo data files if they don't exist
if [ ! -f "android/src/main/assets/geoip.dat" ]; then
    echo "📥 Downloading geoip.dat..."
    curl -L -o android/src/main/assets/geoip.dat https://github.com/v2fly/geoip/releases/latest/download/geoip.dat
else
    echo "✅ geoip.dat found"
fi

if [ ! -f "android/src/main/assets/geosite.dat" ]; then
    echo "📥 Downloading geosite.dat..."
    curl -L -o android/src/main/assets/geosite.dat https://github.com/v2fly/domain-list-community/releases/latest/download/dlc.dat
else
    echo "✅ geosite.dat found"
fi

# Copy to iOS location
echo "📁 Copying files to iOS Resources..."
cp android/src/main/assets/geoip.dat ios/Resources/dat/ 2>/dev/null || echo "⚠️  Could not copy geoip.dat to iOS"
cp android/src/main/assets/geosite.dat ios/Resources/dat/ 2>/dev/null || echo "⚠️  Could not copy geosite.dat to iOS"

echo "🎉 Binary dependencies setup complete!"
echo ""
echo "Next steps:"
echo "1. Run 'flutter pub get'"
echo "2. Build your project as usual"
