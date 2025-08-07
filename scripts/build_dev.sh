#!/bin/bash
# build_dev.sh - Build GitaWisdom for development

echo "🔨 Building GitaWisdom for DEVELOPMENT..."

# Navigate to project root
cd "$(dirname "$0")/.."

# Load development environment
source ./scripts/load_env.sh
load_env ".env.development"

# Build debug APK
echo "📱 Building debug APK..."
flutter build apk --debug $DART_DEFINES

echo "✅ Development build complete!"
echo "📦 APK location: build/app/outputs/flutter-apk/app-debug.apk"
