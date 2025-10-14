#!/bin/bash
# Quick Start Script for Gita Scholar Validation Agent

set -e

echo "========================================="
echo "Gita Scholar Validation Agent"
echo "========================================="
echo ""

# Check if .env file exists
if [ ! -f .env ]; then
    echo "⚠️  .env file not found!"
    echo "Creating .env from .env.example..."
    cp .env.example .env
    echo ""
    echo "📝 Please edit .env file and add your credentials:"
    echo "   - SUPABASE_URL"
    echo "   - SUPABASE_KEY"
    echo ""
    echo "Then run this script again."
    exit 1
fi

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is not installed!"
    echo "Please install Python 3.9 or higher."
    exit 1
fi

# Check if dependencies are installed
if ! python3 -c "import supabase" 2>/dev/null; then
    echo "📦 Installing dependencies..."
    pip install -r requirements.txt
    echo ""
fi

# Run validation
echo "🚀 Starting validation..."
echo ""
python3 gita_scholar_agent.py --mode full

echo ""
echo "========================================="
echo "✅ Validation Complete!"
echo "========================================="
echo ""
echo "📊 View results:"
echo "   - Quality Dashboard: open output/quality_dashboard.html"
echo "   - Detailed Report: output/validation_report.json"
echo "   - Fix Script: output/fix_script.sql"
echo "   - Special Chars: output/special_chars_report.json"
echo ""
echo "📖 For more information, see USAGE_GUIDE.md"
echo ""
