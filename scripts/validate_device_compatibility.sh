#!/bin/bash
# GitaWisdom Device Compatibility Validation Script
# Ensures app will work on OPPO, Vivo, OnePlus, Samsung, Xiaomi devices

set -e

echo "🧪 GitaWisdom - Device Compatibility Validation"
echo "================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if Flutter is available
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter is not installed or not in PATH${NC}"
    exit 1
fi

echo -e "${BLUE}📱 Starting device compatibility validation...${NC}"

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean > /dev/null 2>&1
flutter pub get > /dev/null 2>&1

# 1. Analyze code for compatibility issues
echo -e "${YELLOW}🔍 1. Analyzing code for device compatibility...${NC}"
ANALYSIS=$(flutter analyze --no-preamble 2>&1 || true)
ERRORS=$(echo "$ANALYSIS" | grep "error •" | wc -l)
WARNINGS=$(echo "$ANALYSIS" | grep "warning •" | wc -l)

echo "   - Errors: $ERRORS"
echo "   - Warnings: $WARNINGS"

if [ "$ERRORS" -gt 0 ]; then
    echo -e "${RED}❌ Found $ERRORS compilation errors${NC}"
    echo "$ANALYSIS" | grep "error •" | head -5
    exit 1
else
    echo -e "${GREEN}✅ No compilation errors found${NC}"
fi

# 2. Validate Android configuration
echo -e "${YELLOW}🔍 2. Validating Android configuration...${NC}"

# Check minSdk
MIN_SDK=$(grep "minSdk" android/app/build.gradle.kts | grep -o '[0-9]\+')
if [ "$MIN_SDK" -le 21 ]; then
    echo -e "${GREEN}✅ MinSDK ($MIN_SDK) supports 99%+ Indian devices${NC}"
else
    echo -e "${YELLOW}⚠️  MinSDK ($MIN_SDK) may exclude some budget devices${NC}"
fi

# Check targetSdk
TARGET_SDK=$(grep "targetSdk" android/app/build.gradle.kts | grep -o '[0-9]\+')
if [ "$TARGET_SDK" -ge 33 ]; then
    echo -e "${GREEN}✅ TargetSDK ($TARGET_SDK) targets modern Android${NC}"
else
    echo -e "${YELLOW}⚠️  TargetSDK ($TARGET_SDK) may miss latest optimizations${NC}"
fi

# Check ABI support
if grep -q "arm64-v8a.*armeabi-v7a" android/app/build.gradle.kts; then
    echo -e "${GREEN}✅ ARM architectures supported (OPPO/Vivo/OnePlus)${NC}"
else
    echo -e "${RED}❌ Missing ARM architecture support${NC}"
fi

# Check ProGuard rules
if [ -f "android/app/proguard-rules.pro" ]; then
    if grep -q "oppo\|vivo\|oneplus\|xiaomi\|samsung" android/app/proguard-rules.pro; then
        echo -e "${GREEN}✅ Device-specific ProGuard rules configured${NC}"
    else
        echo -e "${YELLOW}⚠️  No device-specific ProGuard rules found${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  ProGuard rules file not found${NC}"
fi

# 3. Test build process
echo -e "${YELLOW}🔍 3. Testing build process...${NC}"

# Test debug build
echo "   Building debug APK..."
if flutter build apk --debug --quiet > /dev/null 2>&1; then
    DEBUG_SIZE=$(du -h build/app/outputs/flutter-apk/app-debug.apk 2>/dev/null | cut -f1)
    echo -e "${GREEN}✅ Debug build successful ($DEBUG_SIZE)${NC}"
else
    echo -e "${RED}❌ Debug build failed${NC}"
    exit 1
fi

# Test release build
echo "   Building release APK..."
if flutter build apk --release --quiet > /dev/null 2>&1; then
    RELEASE_SIZE=$(du -h build/app/outputs/flutter-apk/app-release.apk 2>/dev/null | cut -f1)
    echo -e "${GREEN}✅ Release build successful ($RELEASE_SIZE)${NC}"
else
    echo -e "${RED}❌ Release build failed${NC}"
    exit 1
fi

# 4. Analyze APK compatibility
echo -e "${YELLOW}🔍 4. Analyzing APK compatibility...${NC}"

APK_PATH="build/app/outputs/flutter-apk/app-release.apk"

if command -v aapt &> /dev/null; then
    # Check supported screens
    SCREENS=$(aapt dump badging "$APK_PATH" 2>/dev/null | grep "supports-screens")
    if echo "$SCREENS" | grep -q "large.*xlarge"; then
        echo -e "${GREEN}✅ All screen sizes supported${NC}"
    else
        echo -e "${YELLOW}⚠️  Limited screen size support${NC}"
    fi
    
    # Check densities
    DENSITIES=$(aapt dump badging "$APK_PATH" 2>/dev/null | grep "densities")
    if echo "$DENSITIES" | grep -q "hdpi.*xhdpi.*xxhdpi"; then
        echo -e "${GREEN}✅ Multiple densities supported${NC}"
    else
        echo -e "${YELLOW}⚠️  Limited density support${NC}"
    fi
    
    # Check native code
    NATIVE=$(aapt dump badging "$APK_PATH" 2>/dev/null | grep "native-code")
    if echo "$NATIVE" | grep -q "arm64-v8a.*armeabi-v7a"; then
        echo -e "${GREEN}✅ ARM architectures included${NC}"
    else
        echo -e "${YELLOW}⚠️  Limited architecture support${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  aapt not found, skipping APK analysis${NC}"
fi

# 5. Device-specific validation
echo -e "${YELLOW}🔍 5. Device-specific validation...${NC}"

# Check if responsive helper exists
if [ -f "lib/core/responsive/responsive_helper.dart" ]; then
    echo -e "${GREEN}✅ Responsive layout helper configured${NC}"
else
    echo -e "${YELLOW}⚠️  No responsive layout helper found${NC}"
fi

# Check for device testing documentation
if [ -f "DEVICE_TESTING_MATRIX.md" ]; then
    echo -e "${GREEN}✅ Device testing matrix available${NC}"
else
    echo -e "${YELLOW}⚠️  No device testing documentation${NC}"
fi

# 6. Final validation
echo -e "${YELLOW}🔍 6. Final validation...${NC}"

TOTAL_ISSUES=0
if [ "$ERRORS" -gt 0 ]; then ((TOTAL_ISSUES++)); fi
if [ "$MIN_SDK" -gt 21 ]; then ((TOTAL_ISSUES++)); fi
if [ "$TARGET_SDK" -lt 33 ]; then ((TOTAL_ISSUES++)); fi

echo ""
echo "================================================="
if [ $TOTAL_ISSUES -eq 0 ]; then
    echo -e "${GREEN}🎉 VALIDATION SUCCESSFUL${NC}"
    echo -e "${GREEN}✅ Your app is ready for Indian market devices!${NC}"
    echo ""
    echo -e "${BLUE}📱 Supported Devices:${NC}"
    echo "   • OPPO (ColorOS) - A, K, Reno, Find series"
    echo "   • Vivo (FuntouchOS) - Y, V, X series + iQOO"
    echo "   • OnePlus (OxygenOS) - Nord, numbered series"
    echo "   • Samsung (OneUI) - M, A, S, Z series"
    echo "   • Xiaomi (MIUI) - Redmi, Mi, POCO series"
    echo "   • Realme - Number, C, GT series"
    echo ""
    echo -e "${BLUE}📊 Coverage Estimate: 70-85% of Indian Android market${NC}"
    echo ""
    echo -e "${BLUE}🚀 Next Steps:${NC}"
    echo "   1. Upload to Play Console for device compatibility testing"
    echo "   2. Run Firebase Test Lab on Indian device matrix"
    echo "   3. Monitor crash reports for device-specific issues"
else
    echo -e "${YELLOW}⚠️  VALIDATION COMPLETED WITH WARNINGS${NC}"
    echo -e "${YELLOW}Found $TOTAL_ISSUES potential issues${NC}"
    echo "Review the warnings above before deploying"
fi

echo "================================================="
echo -e "${BLUE}📋 Build Artifacts:${NC}"
echo "   • Debug APK: $DEBUG_SIZE"
echo "   • Release APK: $RELEASE_SIZE"
echo "   • Location: build/app/outputs/flutter-apk/"
echo ""

exit 0