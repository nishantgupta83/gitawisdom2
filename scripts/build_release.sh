#!/bin/bash
# build_release.sh - Build GitaWisdom for production

echo "🔨 Building GitaWisdom for PRODUCTION..."

# Navigate to project root
cd "$(dirname "$0")/.."

# Check if production env exists
if [ ! -f ".env.production" ]; then
    echo "⚠️  .env.production not found, using development config"
    ENV_FILE=".env.development"
else
    ENV_FILE=".env.production"
fi

# Load environment
source ./scripts/load_env.sh
load_env "$ENV_FILE"

# Build release APK and App Bundle
echo "📱 Building release APK..."
flutter build apk --release $DART_DEFINES

echo "📱 Building App Bundle..."
flutter build appbundle --release $DART_DEFINES

echo "✅ Production build complete!"
echo "📦 APK: build/app/outputs/flutter-apk/app-release.apk"
echo "📦 Bundle: build/app/outputs/bundle/release/app-release.aab"
