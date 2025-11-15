#!/bin/bash

# Integration Test Runner for GitaWisdom
# Runs all integration tests with optional device selection and coverage

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   GitaWisdom Integration Test Runner      ║${NC}"
echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo ""

# Function to print colored output
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed or not in PATH"
    exit 1
fi

print_success "Flutter found: $(flutter --version | head -n 1)"
echo ""

# Parse command line arguments
DEVICE_ID=""
COVERAGE=false
TEST_FILE=""
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--device)
            DEVICE_ID="$2"
            shift 2
            ;;
        -c|--coverage)
            COVERAGE=true
            shift
            ;;
        -t|--test)
            TEST_FILE="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            echo "Usage: ./run_integration_tests.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  -d, --device <id>    Device ID to run tests on"
            echo "  -c, --coverage       Generate coverage report"
            echo "  -t, --test <file>    Run specific test file"
            echo "  -v, --verbose        Verbose output"
            echo "  -h, --help           Show this help message"
            echo ""
            echo "Examples:"
            echo "  ./run_integration_tests.sh                           # Run all tests"
            echo "  ./run_integration_tests.sh -c                        # Run with coverage"
            echo "  ./run_integration_tests.sh -d emulator-5554          # Run on specific device"
            echo "  ./run_integration_tests.sh -t auth_flow_test.dart    # Run specific test"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

# List available devices
print_info "Checking available devices..."
flutter devices

echo ""

# Select device if not specified
if [ -z "$DEVICE_ID" ]; then
    print_warning "No device specified. Attempting to auto-detect..."

    # Try to find a running device
    DEVICE_LIST=$(flutter devices | grep -E "•.*•" | grep -v "No devices detected")

    if [ -z "$DEVICE_LIST" ]; then
        print_error "No devices found. Please connect a device or start an emulator."
        exit 1
    fi

    # Get first available device
    DEVICE_ID=$(echo "$DEVICE_LIST" | head -n 1 | awk '{print $2}')
    print_info "Auto-selected device: $DEVICE_ID"
else
    print_info "Using device: $DEVICE_ID"
fi

echo ""

# Determine test path
if [ -n "$TEST_FILE" ]; then
    if [[ "$TEST_FILE" == integration_test/* ]]; then
        TEST_PATH="$TEST_FILE"
    else
        TEST_PATH="integration_test/$TEST_FILE"
    fi
    print_info "Running specific test: $TEST_PATH"
else
    TEST_PATH="integration_test/"
    print_info "Running all integration tests"
fi

echo ""

# Build test command
TEST_CMD="flutter test $TEST_PATH -d $DEVICE_ID"

if [ "$COVERAGE" = true ]; then
    TEST_CMD="$TEST_CMD --coverage"
    print_info "Coverage reporting enabled"
fi

if [ "$VERBOSE" = true ]; then
    TEST_CMD="$TEST_CMD --verbose"
    print_info "Verbose output enabled"
fi

echo ""
print_info "Test command: $TEST_CMD"
echo ""
print_info "Starting tests..."
echo "════════════════════════════════════════════"
echo ""

# Run tests
if $TEST_CMD; then
    echo ""
    echo "════════════════════════════════════════════"
    print_success "All tests passed!"

    # Generate coverage report if enabled
    if [ "$COVERAGE" = true ]; then
        echo ""
        print_info "Generating coverage report..."

        if command -v lcov &> /dev/null && command -v genhtml &> /dev/null; then
            genhtml coverage/lcov.info -o coverage/html
            print_success "Coverage HTML report generated at: coverage/html/index.html"

            # Calculate coverage percentage
            COVERAGE_PCT=$(lcov --summary coverage/lcov.info 2>&1 | grep "lines" | awk '{print $2}')
            print_info "Line coverage: $COVERAGE_PCT"

            # Open coverage report (macOS)
            if [[ "$OSTYPE" == "darwin"* ]]; then
                read -p "Open coverage report in browser? (y/n) " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    open coverage/html/index.html
                fi
            fi
        else
            print_warning "lcov/genhtml not installed. Install with: brew install lcov (macOS)"
            print_info "Raw coverage data available at: coverage/lcov.info"
        fi
    fi

    echo ""
    print_success "Integration tests completed successfully!"
    exit 0
else
    echo ""
    echo "════════════════════════════════════════════"
    print_error "Tests failed!"

    print_info "Check the output above for details"
    print_info "Screenshots saved in: build/app/outputs/screenshots/"

    exit 1
fi
