#!/bin/bash

echo "🔧 Fixing chapter RPC function return types..."

PGPASSWORD=ZpCK6wU4XQCR9DdP psql \
  -h aws-0-ap-south-1.pooler.supabase.com \
  -p 6543 \
  -d postgres \
  -U postgres.wlfwdtdtiedlcczfoslt \
  -f supabase/migrations/SAT_010_fix_chapter_function_types.sql

if [ $? -eq 0 ]; then
    echo "✅ Chapter function types fixed successfully!"
else
    echo "❌ Failed to fix chapter function types"
    exit 1
fi