#!/bin/bash
# load_env.sh - Helper to load environment variables from .env files

load_env() {
    local env_file="$1"
    
    if [ ! -f "$env_file" ]; then
        echo "❌ Environment file $env_file not found!"
        echo "📁 Available files:"
        ls -la .env* 2>/dev/null || echo "No .env files found"
        exit 1
    fi
    
    echo "📦 Loading environment from $env_file"
    
    # Clear previous dart defines
    export DART_DEFINES=""
    
    # Read each line and convert to dart-define arguments
    while IFS='=' read -r key value || [ -n "$key" ]; do
        # Skip comments and empty lines
        [[ $key =~ ^[[:space:]]*# ]] && continue
        [[ -z "$key" ]] && continue
        
        # Remove leading/trailing whitespace
        key=$(echo "$key" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        value=$(echo "$value" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        
        # Remove quotes if present
        value=$(echo "$value" | sed 's/^"//;s/"$//')
        
        # Skip empty values
        [[ -z "$value" ]] && continue
        
        # Add to dart defines
        if [ -n "$DART_DEFINES" ]; then
            DART_DEFINES="$DART_DEFINES --dart-define=$key=$value"
        else
            DART_DEFINES="--dart-define=$key=$value"
        fi
        
        echo "  ✅ $key=***"
    done < "$env_file"
    
    echo "🔧 Generated dart defines: $DART_DEFINES"
}
