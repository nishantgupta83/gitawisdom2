#!/bin/bash

echo "🧪 Running OldWisdom Test Suite..."

# Clean previous test results
echo "🧹 Cleaning previous test results..."
rm -rf coverage/
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Run unit tests with coverage
echo "🔬 Running unit tests..."
flutter test --coverage

# Run integration tests
echo "🔗 Running integration tests..."
flutter test integration_test/

# Generate coverage report (optional - requires lcov)
if command -v lcov &> /dev/null; then
    echo "📊 Generating coverage report..."
    genhtml coverage/lcov.info -o coverage/html
    echo "Coverage report generated at coverage/html/index.html"
fi

echo "✅ Test suite completed!"
