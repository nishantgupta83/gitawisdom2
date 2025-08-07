#!/bin/bash
# clean.sh - Clean GitaWisdom build artifacts

echo "🧹 Cleaning GitaWisdom..."

# Navigate to project root
cd "$(dirname "$0")/.."

# Flutter clean
flutter clean

# Clear pub cache
flutter pub get

echo "✅ Clean complete!"
