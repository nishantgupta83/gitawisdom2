#!/bin/bash

# Run All Tests Script for GitaWisdom
# Runs comprehensive test suite with coverage reporting

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}GitaWisdom Test Suite Runner${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if Flutter is available
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Error: Flutter not found${NC}"
    echo "Please install Flutter: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo -e "${GREEN}✅ Flutter found: $(flutter --version | head -1)${NC}"
echo ""

# Clean before testing
echo -e "${YELLOW}🧹 Cleaning build artifacts...${NC}"
flutter clean
flutter pub get
echo ""

# Count test files
TEST_COUNT=$(find test -name "*_test.dart" -type f | wc -l)
echo -e "${BLUE}📊 Found ${TEST_COUNT} test files${NC}"
echo ""

# Run all tests
echo -e "${YELLOW}🧪 Running all tests...${NC}"
echo ""

flutter test --reporter expanded 2>&1 | tee test_results.log

# Check test results
if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}✅ All tests passed!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""

    # Count passed tests
    PASSED=$(grep -c "✓" test_results.log || echo "0")
    echo -e "${BLUE}📈 Test Statistics:${NC}"
    echo -e "  ${GREEN}✓${NC} Passed: $PASSED"
    echo -e "  ${BLUE}📁${NC} Test Files: $TEST_COUNT"
    echo ""

    # Show test coverage summary
    echo -e "${YELLOW}Test Coverage by Category:${NC}"
    echo -e "  ${BLUE}Services:${NC} $(find test/services -name "*_test.dart" | wc -l) test files"
    echo -e "  ${BLUE}Models:${NC} $(find test/models -name "*_test.dart" 2>/dev/null | wc -l) test files"
    echo -e "  ${BLUE}Widgets:${NC} $(find test/widgets -name "*_test.dart" 2>/dev/null | wc -l) test files"
    echo -e "  ${BLUE}Core:${NC} $(find test/core -name "*_test.dart" 2>/dev/null | wc -l) test files"
    echo -e "  ${BLUE}Performance:${NC} $(find test/performance -name "*_test.dart" 2>/dev/null | wc -l) test files"
    echo ""

    exit 0
else
    echo ""
    echo -e "${RED}========================================${NC}"
    echo -e "${RED}❌ Some tests failed${NC}"
    echo -e "${RED}========================================${NC}"
    echo ""

    # Count failures
    FAILED=$(grep -c "✗" test_results.log || echo "0")
    PASSED=$(grep -c "✓" test_results.log || echo "0")

    echo -e "${BLUE}📈 Test Statistics:${NC}"
    echo -e "  ${GREEN}✓${NC} Passed: $PASSED"
    echo -e "  ${RED}✗${NC} Failed: $FAILED"
    echo -e "  ${BLUE}📁${NC} Test Files: $TEST_COUNT"
    echo ""

    echo -e "${YELLOW}Check test_results.log for details${NC}"
    echo ""

    exit 1
fi
