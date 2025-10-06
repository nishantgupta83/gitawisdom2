#!/bin/bash

# GitaWisdom Production Build Script
# Builds signed production APK and AAB with embedded credentials

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}📦 GitaWisdom Production Build Script${NC}"
echo ""

# Check if .env.development exists (production uses same Supabase)
if [ ! -f ".env.development" ]; then
    echo -e "${RED}❌ Error: .env.development not found${NC}"
    echo "Please create .env.development with your Supabase credentials"
    exit 1
fi

# Load environment variables
source .env.development

# Validate required variables
if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_ANON_KEY" ]; then
    echo -e "${RED}❌ Error: Missing SUPABASE_URL or SUPABASE_ANON_KEY${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Credentials loaded${NC}"

# Check for keystore
if [ ! -f "android/keystore.properties" ]; then
    echo -e "${RED}❌ Error: android/keystore.properties not found${NC}"
    echo "Production builds require signing configuration"
    exit 1
fi

if [ ! -f "android/gitawisdom-upload-key.jks" ]; then
    echo -e "${RED}❌ Error: android/gitawisdom-upload-key.jks not found${NC}"
    echo "Production builds require keystore file"
    exit 1
fi

echo -e "${GREEN}✅ Keystore configuration found${NC}"
echo ""

# Build dart-define flags for production
DART_DEFINES=(
    "--dart-define=SUPABASE_URL=$SUPABASE_URL"
    "--dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY"
    "--dart-define=APP_ENV=production"
    "--dart-define=ENABLE_ANALYTICS=true"
    "--dart-define=ENABLE_LOGGING=false"
)

# Determine build target
BUILD_TARGET=${1:-all}

case $BUILD_TARGET in
    apk)
        echo -e "${BLUE}🔨 Building production APK...${NC}"
        flutter build apk --release "${DART_DEFINES[@]}"

        APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
        if [ -f "$APK_PATH" ]; then
            APK_SIZE=$(du -h "$APK_PATH" | cut -f1)
            echo ""
            echo -e "${GREEN}✅ APK built successfully: $APK_SIZE${NC}"
            echo -e "${YELLOW}📍 Location: $APK_PATH${NC}"
        fi
        ;;

    aab)
        echo -e "${BLUE}🔨 Building production App Bundle (AAB)...${NC}"
        flutter build appbundle --release "${DART_DEFINES[@]}"

        AAB_PATH="build/app/outputs/bundle/release/app-release.aab"
        if [ -f "$AAB_PATH" ]; then
            AAB_SIZE=$(du -h "$AAB_PATH" | cut -f1)
            echo ""
            echo -e "${GREEN}✅ AAB built successfully: $AAB_SIZE${NC}"
            echo -e "${YELLOW}📍 Location: $AAB_PATH${NC}"
            echo -e "${BLUE}ℹ️  Ready for Google Play Store upload${NC}"
        fi
        ;;

    all)
        echo -e "${BLUE}🔨 Building production APK and AAB...${NC}"
        echo ""

        # Build APK
        echo -e "${YELLOW}📦 Building APK...${NC}"
        flutter build apk --release "${DART_DEFINES[@]}"

        APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
        if [ -f "$APK_PATH" ]; then
            APK_SIZE=$(du -h "$APK_PATH" | cut -f1)
            echo -e "${GREEN}✅ APK: $APK_SIZE${NC}"
        fi

        echo ""

        # Build AAB
        echo -e "${YELLOW}📦 Building AAB...${NC}"
        flutter build appbundle --release "${DART_DEFINES[@]}"

        AAB_PATH="build/app/outputs/bundle/release/app-release.aab"
        if [ -f "$AAB_PATH" ]; then
            AAB_SIZE=$(du -h "$AAB_PATH" | cut -f1)
            echo -e "${GREEN}✅ AAB: $AAB_SIZE${NC}"
        fi

        echo ""
        echo -e "${GREEN}✅ Production builds complete!${NC}"
        echo ""
        echo -e "${YELLOW}📦 Build artifacts:${NC}"
        echo -e "  APK: $APK_PATH ($APK_SIZE)"
        echo -e "  AAB: $AAB_PATH ($AAB_SIZE)"
        ;;

    *)
        echo -e "${RED}❌ Unknown build target: $BUILD_TARGET${NC}"
        echo ""
        echo "Usage: $0 [apk|aab|all]"
        echo "  apk  - Build APK only"
        echo "  aab  - Build App Bundle only"
        echo "  all  - Build both (default)"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}🎉 Production build completed!${NC}"
