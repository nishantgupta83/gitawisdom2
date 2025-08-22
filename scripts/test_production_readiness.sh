#!/bin/bash

# scripts/test_production_readiness.sh
# Production Readiness Test Suite for GitaWisdom
# Run this before every release to catch production issues

set -e  # Exit on any error

echo "🧪 GitaWisdom Production Readiness Test Suite"
echo "=============================================="

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test results tracking
TESTS_PASSED=0
TESTS_FAILED=0
CRITICAL_FAILURES=()

# Function to log test results
log_test_result() {
    local test_name="$1"
    local status="$2"
    local message="$3"
    
    if [ "$status" = "PASS" ]; then
        echo -e "${GREEN}✅ $test_name: PASSED${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}❌ $test_name: FAILED${NC}"
        echo -e "${RED}   Error: $message${NC}"
        ((TESTS_FAILED++))
        CRITICAL_FAILURES+=("$test_name: $message")
    fi
}

# Function to run command and capture result
run_test_command() {
    local test_name="$1"
    local command="$2"
    local critical="$3"  # "true" for critical tests
    
    echo -e "${YELLOW}🔄 Running: $test_name${NC}"
    
    if eval "$command" > /tmp/test_output 2>&1; then
        log_test_result "$test_name" "PASS" ""
    else
        local error_msg=$(cat /tmp/test_output | tail -5)
        log_test_result "$test_name" "FAIL" "$error_msg"
        
        if [ "$critical" = "true" ]; then
            echo -e "${RED}💥 CRITICAL TEST FAILED: $test_name${NC}"
            echo -e "${RED}This must be fixed before release!${NC}"
        fi
    fi
}

echo ""
echo "📋 Pre-flight Checks"
echo "===================="

# Check Flutter environment
run_test_command "Flutter Environment" "flutter doctor --android-licenses" "false"
run_test_command "Flutter Dependencies" "flutter pub get" "true"

# Check build configuration
echo ""
echo "🏗️ Build Configuration Tests"
echo "============================"

run_test_command "Android Manifest Validation" "grep -q 'android.permission.INTERNET' android/app/src/main/AndroidManifest.xml" "true"
run_test_command "Supabase Config Check" "grep -q 'Environment.supabaseUrl' lib/main.dart" "true"
run_test_command "No Duplicate Supabase Init" "! grep -n 'Supabase.initialize' lib/main.dart | grep -v 'Environment'" "true"

echo ""
echo "🧪 Unit & Integration Tests"
echo "=========================="

# Run unit tests
run_test_command "Unit Tests" "flutter test test/ --coverage" "true"

# Run production readiness integration tests
run_test_command "Production Readiness Tests" "flutter test test/integration/production_readiness_test.dart" "true"

# Run widget tests
run_test_command "Widget Tests" "flutter test test/widget_test.dart" "false"

echo ""
echo "🏗️ Build Tests"
echo "=============="

# Test debug build
run_test_command "Debug Build" "flutter build apk --debug" "false"

# Test release build
run_test_command "Release Build" "flutter build apk --release" "true"

# Test app bundle build
run_test_command "App Bundle Build" "flutter build appbundle --release" "true"

echo ""
echo "🔍 Static Analysis"
echo "=================="

# Analyze code
run_test_command "Flutter Analyze" "flutter analyze --no-fatal-infos" "false"

# Check for any TODO/FIXME in critical files
run_test_command "Critical TODOs Check" "! grep -r 'TODO.*CRITICAL\\|FIXME.*CRITICAL' lib/" "false"

echo ""
echo "📱 Release Artifact Validation"
echo "=============================="

# Check if release files exist and have reasonable sizes
if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    APK_SIZE=$(stat -f%z build/app/outputs/flutter-apk/app-release.apk 2>/dev/null || stat -c%s build/app/outputs/flutter-apk/app-release.apk 2>/dev/null)
    if [ "$APK_SIZE" -gt 50000000 ] && [ "$APK_SIZE" -lt 100000000 ]; then  # 50MB - 100MB
        log_test_result "APK Size Validation" "PASS" ""
    else
        log_test_result "APK Size Validation" "FAIL" "APK size $APK_SIZE bytes seems unusual"
    fi
else
    log_test_result "APK Exists" "FAIL" "APK file not found"
fi

if [ -f "build/app/outputs/bundle/release/app-release.aab" ]; then
    AAB_SIZE=$(stat -f%z build/app/outputs/bundle/release/app-release.aab 2>/dev/null || stat -c%s build/app/outputs/bundle/release/app-release.aab 2>/dev/null)
    if [ "$AAB_SIZE" -gt 40000000 ] && [ "$AAB_SIZE" -lt 80000000 ]; then  # 40MB - 80MB
        log_test_result "AAB Size Validation" "PASS" ""
    else
        log_test_result "AAB Size Validation" "FAIL" "AAB size $AAB_SIZE bytes seems unusual"
    fi
else
    log_test_result "AAB Exists" "FAIL" "AAB file not found"
fi

echo ""
echo "📊 Test Results Summary"
echo "======================"
echo -e "${GREEN}Tests Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Tests Failed: $TESTS_FAILED${NC}"

if [ ${#CRITICAL_FAILURES[@]} -gt 0 ]; then
    echo ""
    echo -e "${RED}💥 CRITICAL FAILURES:${NC}"
    for failure in "${CRITICAL_FAILURES[@]}"; do
        echo -e "${RED}   - $failure${NC}"
    done
fi

echo ""
if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 ALL TESTS PASSED! App is ready for release.${NC}"
    echo ""
    echo "📦 Release artifacts:"
    echo "   APK: build/app/outputs/flutter-apk/app-release.apk"
    echo "   AAB: build/app/outputs/bundle/release/app-release.aab"
    exit 0
else
    echo -e "${RED}❌ $TESTS_FAILED tests failed. Fix issues before release.${NC}"
    
    if [ ${#CRITICAL_FAILURES[@]} -gt 0 ]; then
        echo -e "${RED}⚠️  CRITICAL failures must be resolved!${NC}"
        exit 2  # Critical failure exit code
    else
        exit 1  # Non-critical failure exit code
    fi
fi