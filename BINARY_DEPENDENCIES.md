# Binary Dependencies

This Flutter plugin requires several large binary files that are not included in the repository. You need to download them from the libXray releases before building the project.

## Required Files

### Android

1. **libXray.aar** (81MB)
   - Location: `android/libs/libXray.aar`
   - Download from: [libXray Releases](https://github.com/2dust/AndroidLibXrayLite/releases)

### iOS

4. **LibXray.xcframework** (495MB total)
   - Location: `ios/Frameworks/LibXray.xcframework`
   - Download from: [libXray Releases](https://github.com/2dust/AndroidLibXrayLite/releases)

### Assets (for both Android and iOS)

2. **geoip.dat** (19MB)
   - Android location: `android/src/main/assets/geoip.dat`
   - iOS location: `ios/Resources/dat/geoip.dat`
   - Download from: [v2ray geodata releases](https://github.com/v2fly/domain-list-community/releases)

3. **geosite.dat** (2.2MB)
   - Android location: `android/src/main/assets/geosite.dat`
   - iOS location: `ios/Resources/dat/geosite.dat`
   - Download from: [v2ray geodata releases](https://github.com/v2fly/domain-list-community/releases)

## Setup Script

You can use the following script to download and setup all required files:

```bash
#!/bin/bash
# setup_dependencies.sh

echo "Setting up binary dependencies for VPNclient Engine Flutter..."

# Create directories
mkdir -p android/libs
mkdir -p android/src/main/assets
mkdir -p ios/Resources/dat

# Download libXray.aar (you need to get the latest release)
echo "Please download libXray.aar manually from libXray releases and place it in android/libs/"

# Download geo data files
echo "Downloading geo data files..."
curl -L -o android/src/main/assets/geoip.dat https://github.com/v2fly/geoip/releases/latest/download/geoip.dat
curl -L -o android/src/main/assets/geosite.dat https://github.com/v2fly/domain-list-community/releases/latest/download/dlc.dat

# Copy to iOS location
cp android/src/main/assets/geoip.dat ios/Resources/dat/
cp android/src/main/assets/geosite.dat ios/Resources/dat/

echo "Binary dependencies setup complete!"
```

## Build Instructions

1. Clone this repository
2. Run the setup script or manually download the files as described above
3. Run `flutter pub get`
4. Build your project as usual

## Note

These files are excluded from the repository to:
- Keep the repository size reasonable
- Avoid licensing issues with binary distributions
- Allow users to get the latest versions directly from official sources
