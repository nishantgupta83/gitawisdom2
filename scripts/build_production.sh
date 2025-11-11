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

# Check if .env exists (production uses same Supabase)
if [ ! -f ".env" ]; then
    echo -e "${RED}❌ Error: .env not found${NC}"
    echo "Please create .env with your Supabase credentials"
    exit 1
fi

# Load environment variables
source .env

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
        echo -e "${BLUE}🔨 Building production APK (with split-per-abi)...${NC}"
        echo -e "${YELLOW}📦 Optimization: Creating device-specific APKs to reduce download size${NC}"
        flutter build apk --release \
            --split-per-abi \
            --obfuscate \
            --split-debug-info=build/debug-symbols \
            "${DART_DEFINES[@]}"

        echo ""
        echo -e "${GREEN}✅ APK built successfully!${NC}"
        echo ""

        # Report split APK sizes
        for abi in arm64-v8a armeabi-v7a x86_64; do
            APK_PATH="build/app/outputs/flutter-apk/app-${abi}-release.apk"
            if [ -f "$APK_PATH" ]; then
                APK_SIZE=$(du -h "$APK_PATH" | cut -f1)
                echo -e "${YELLOW}📱 $abi${NC}: $APK_SIZE"
            fi
        done

        SYMBOLS_PATH="build/debug-symbols"
        if [ -d "$SYMBOLS_PATH" ]; then
            SYMBOLS_SIZE=$(du -sh "$SYMBOLS_PATH" | cut -f1)
            echo -e "${YELLOW}🔍 Debug symbols${NC}: $SYMBOLS_SIZE (${SYMBOLS_PATH})"
        fi
        ;;

    aab)
        echo -e "${BLUE}🔨 Building production App Bundle (AAB)...${NC}"
        echo -e "${YELLOW}🔐 Optimizations: Obfuscation enabled for security${NC}"
        flutter build appbundle --release \
            --obfuscate \
            --split-debug-info=build/debug-symbols \
            "${DART_DEFINES[@]}"

        AAB_PATH="build/app/outputs/bundle/release/app-release.aab"
        if [ -f "$AAB_PATH" ]; then
            AAB_SIZE=$(du -h "$AAB_PATH" | cut -f1)
            echo ""
            echo -e "${GREEN}✅ AAB built successfully: $AAB_SIZE${NC}"
            echo -e "${YELLOW}📍 Location: $AAB_PATH${NC}"
            echo -e "${BLUE}ℹ️  Ready for Google Play Store upload${NC}"
        fi

        SYMBOLS_PATH="build/debug-symbols"
        if [ -d "$SYMBOLS_PATH" ]; then
            SYMBOLS_SIZE=$(du -sh "$SYMBOLS_PATH" | cut -f1)
            echo -e "${YELLOW}🔍 Debug symbols${NC}: $SYMBOLS_SIZE (${SYMBOLS_PATH})"
        fi
        ;;

    all)
        echo -e "${BLUE}🔨 Building production APK and AAB...${NC}"
        echo -e "${YELLOW}🔐 Applying optimizations: split-per-abi, obfuscation, split debug info${NC}"
        echo ""

        # Build APK with split-per-abi
        echo -e "${YELLOW}📦 Building optimized APK (split-per-abi)...${NC}"
        flutter build apk --release \
            --split-per-abi \
            --obfuscate \
            --split-debug-info=build/debug-symbols \
            "${DART_DEFINES[@]}"

        echo -e "${GREEN}✅ Split APKs created:${NC}"
        for abi in arm64-v8a armeabi-v7a x86_64; do
            APK_PATH="build/app/outputs/flutter-apk/app-${abi}-release.apk"
            if [ -f "$APK_PATH" ]; then
                APK_SIZE=$(du -h "$APK_PATH" | cut -f1)
                echo -e "  📱 $abi: $APK_SIZE"
            fi
        done

        echo ""

        # Build AAB
        echo -e "${YELLOW}📦 Building optimized AAB...${NC}"
        flutter build appbundle --release \
            --obfuscate \
            --split-debug-info=build/debug-symbols \
            "${DART_DEFINES[@]}"

        AAB_PATH="build/app/outputs/bundle/release/app-release.aab"
        if [ -f "$AAB_PATH" ]; then
            AAB_SIZE=$(du -h "$AAB_PATH" | cut -f1)
            echo -e "${GREEN}✅ AAB: $AAB_SIZE${NC}"
        fi

        SYMBOLS_PATH="build/debug-symbols"
        if [ -d "$SYMBOLS_PATH" ]; then
            SYMBOLS_SIZE=$(du -sh "$SYMBOLS_PATH" | cut -f1)
            echo -e "${YELLOW}🔍 Debug symbols: $SYMBOLS_SIZE${NC}"
        fi

        echo ""
        echo -e "${GREEN}✅ Production builds complete!${NC}"
        echo ""
        echo -e "${YELLOW}📦 Build artifacts:${NC}"
        echo -e "  APK (split-per-abi): build/app/outputs/flutter-apk/"
        echo -e "  AAB: $AAB_PATH"
        echo -e "  Debug symbols: $SYMBOLS_PATH"
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
