#!/bin/bash

# Production Build and Run Script for Physical iPhone
# Usage: ./scripts/run_production_iphone.sh <device-id>
# Example: ./scripts/run_production_iphone.sh 00008030-001234567890ABCD

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}GitaWisdom Production iPhone Builder${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if device ID provided
if [ -z "$1" ]; then
    echo -e "${YELLOW}No device ID provided. Listing available devices...${NC}"
    echo ""
    flutter devices
    echo ""
    echo -e "${YELLOW}Usage: ./scripts/run_production_iphone.sh <device-id>${NC}"
    echo -e "${YELLOW}Example: ./scripts/run_production_iphone.sh 00008030-001234567890ABCD${NC}"
    exit 1
fi

DEVICE_ID=$1

# Load environment variables
if [ -f ".env.development" ]; then
    export $(cat .env.development | grep -v '^#' | xargs)
    echo -e "${GREEN}✅ Loaded credentials from .env.development${NC}"
else
    echo -e "${RED}❌ Error: .env.development file not found${NC}"
    exit 1
fi

# Validate environment variables
if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_ANON_KEY" ]; then
    echo -e "${RED}❌ Error: SUPABASE_URL or SUPABASE_ANON_KEY not set${NC}"
    exit 1
fi

echo -e "${BLUE}📱 Target Device: ${DEVICE_ID}${NC}"
echo -e "${BLUE}🔧 Environment: PRODUCTION${NC}"
echo -e "${BLUE}🌐 Supabase URL: ${SUPABASE_URL}${NC}"
echo ""

# Clean build
echo -e "${YELLOW}🧹 Cleaning previous build...${NC}"
flutter clean
flutter pub get

# Build for release with obfuscation
echo -e "${YELLOW}🔨 Building production release with obfuscation...${NC}"
echo -e "${BLUE}🔐 Security: Code obfuscation enabled${NC}"
flutter build ios --release \
  -d "$DEVICE_ID" \
  --obfuscate \
  --split-debug-info=build/ios-debug-symbols \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY" \
  --dart-define=APP_ENV=production

# Run on device
echo -e "${YELLOW}🚀 Installing on iPhone...${NC}"
flutter run --release \
  -d "$DEVICE_ID" \
  --obfuscate \
  --split-debug-info=build/ios-debug-symbols \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY" \
  --dart-define=APP_ENV=production

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✅ Production build running on iPhone!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}Testing Checklist:${NC}"
echo -e "  ${BLUE}[ ]${NC} Apple Sign-In works"
echo -e "  ${BLUE}[ ]${NC} Facebook Sign-In works"
echo -e "  ${BLUE}[ ]${NC} No test accounts displayed"
echo -e "  ${BLUE}[ ]${NC} App feels production-ready"
echo -e "  ${BLUE}[ ]${NC} Performance is smooth"
echo ""
