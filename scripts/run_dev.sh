#!/bin/bash
# run_dev.sh - Run GitaWisdom in development mode

echo "🚀 Starting GitaWisdom in DEVELOPMENT mode..."

# Navigate to project root
cd "$(dirname "$0")/.."

# Load development environment
source ./scripts/load_env.sh
load_env ".env.development"

# Run with hot reload
echo "🔥 Starting with hot reload..."
flutter run --debug $DART_DEFINES

echo "✅ Development session ended"
