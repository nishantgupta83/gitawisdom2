import os
import sys
from supabase import create_client, Client

# Get Supabase credentials from environment
SUPABASE_URL = os.getenv('SUPABASE_URL', 'https://wlfwdtdtiedlcczfoslt.supabase.co')
SUPABASE_KEY = os.getenv('SUPABASE_ANON_KEY', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndsZndkdGR0aWVkbGNjemZvc2x0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE4NjQ5MDAsImV4cCI6MjA2NzQ0MDkwMH0.OiWhZled2trJ7eTd8lpQ658B4p-IVsRp2HXHcgAUoFU')

# Initialize Supabase client
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

print("🔍 Checking specific scenario: 'child with learning differences'")
print("=" * 80)

# Query for the specific scenario
response = supabase.table('scenarios').select('*').ilike('title', '%child with learning differences%').execute()

if response.data:
    scenario = response.data[0]
    print(f"\n📋 Scenario ID: {scenario['id']}")
    print(f"📝 Title: {scenario['title']}")
    print(f"\n💜 Heart Says:\n{scenario.get('heart_says', 'N/A')}")
    print(f"\n⚔️  Duty Says:\n{scenario.get('duty_says', 'N/A')}")
    print(f"\n🎓 Key Learnings:\n{scenario.get('key_learnings', 'N/A')}")
    print(f"\n🔑 Keywords: {scenario.get('keywords', 'N/A')}")
    
    # Check for quality issues
    issues = []
    key_learnings = scenario.get('key_learnings', '')
    
    if '(etc)' in key_learnings.lower():
        issues.append("⚠️  Contains '(etc)' - incomplete list")
    
    if key_learnings:
        lines = [line.strip() for line in key_learnings.split('\n') if line.strip()]
        for i, line in enumerate(lines, 1):
            # Check for incomplete sentences
            if line.endswith('(') or line.endswith(',') or line.endswith('and'):
                issues.append(f"⚠️  Line {i} appears incomplete: '{line}'")
            
            # Check for very short lines (likely broken)
            if len(line) < 15 and not line.endswith('.'):
                issues.append(f"⚠️  Line {i} is suspiciously short: '{line}'")
    
    if issues:
        print(f"\n🚨 QUALITY ISSUES FOUND:")
        for issue in issues:
            print(f"   {issue}")
    else:
        print(f"\n✅ No obvious quality issues detected")
else:
    print("❌ Scenario not found")

print("\n" + "=" * 80)
