#!/bin/bash

# GitaWisdom Development Launch Script
# Automatically loads credentials from .env.development and runs the app

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 GitaWisdom Development Launcher${NC}"
echo ""

# Check if .env exists
if [ ! -f ".env" ]; then
    echo -e "${RED}❌ Error: .env not found${NC}"
    echo "Please create .env with your Supabase credentials"
    exit 1
fi

# Load environment variables
source .env

# Validate required variables
if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_ANON_KEY" ]; then
    echo -e "${RED}❌ Error: Missing SUPABASE_URL or SUPABASE_ANON_KEY in .env${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Credentials loaded from .env${NC}"
echo ""

# Build dart-define flags
DART_DEFINES=(
    "--dart-define=SUPABASE_URL=$SUPABASE_URL"
    "--dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY"
    "--dart-define=APP_ENV=${APP_ENV:-development}"
    "--dart-define=ENABLE_ANALYTICS=${ENABLE_ANALYTICS:-false}"
    "--dart-define=ENABLE_LOGGING=${ENABLE_LOGGING:-true}"
)

# Check for device argument
DEVICE_ARG=""
if [ ! -z "$1" ]; then
    DEVICE_ARG="-d $1"
    echo -e "${YELLOW}📱 Running on device: $1${NC}"
else
    echo -e "${YELLOW}📱 No device specified, Flutter will prompt if multiple devices available${NC}"
fi

echo ""
echo -e "${GREEN}🔧 Starting Flutter...${NC}"
echo ""

# Run flutter with all dart-define flags
flutter run $DEVICE_ARG "${DART_DEFINES[@]}"
