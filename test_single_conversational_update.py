#!/usr/bin/env python3
"""
Test a single scenario update to verify the text[] array syntax works.
"""
from supabase import create_client
import time

supabase = create_client(
    "https://wlfwdtdtiedlcczfoslt.supabase.co",
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndsZndkdGR0aWVkbGNjemZvc2x0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE4NjQ5MDAsImV4cCI6MjA2NzQ0MDkwMH0.OiWhZled2trJ7eTd8lpQ658B4p-IVsRp2HXHcgAUoFU"
)

print("🔍 Testing conversational update on scenario 772...\n")

# Read before
before = supabase.table('scenarios').select('sc_action_steps, sc_title').eq('scenario_id', 772).single().execute()
print(f"BEFORE UPDATE - Scenario 772: {before.data['sc_title']}")
for i, step in enumerate(before.data['sc_action_steps'], 1):
    print(f"  {i}. {step}")

# New conversational steps
new_steps = [
    "Identify your top 3-5 spending categories (like groceries, clothing, tech) where you consistently agonize over decisions",
    "Create simple decision rules for each category - like 'groceries under $50 need no deliberation' or 'always buy the mid-tier option for tech'",
    "Set a research time limit of 15-20 minutes max for purchases under $100, using a timer to force yourself to decide",
    "Accept that most purchases won't be perfect - aim for 'good enough' rather than 'best possible' to cut through analysis paralysis",
    "Review your spending decisions once a year to see if your rules need tweaking, but trust them in the moment rather than second-guessing every time"
]

print("\n🔄 UPDATING with conversational steps...")
result = supabase.table('scenarios').update({'sc_action_steps': new_steps}).eq('scenario_id', 772).execute()

# Wait a moment
time.sleep(2)

# Read after
after = supabase.table('scenarios').select('sc_action_steps, sc_title').eq('scenario_id', 772).single().execute()
print(f"\nAFTER UPDATE - Scenario 772: {after.data['sc_title']}")
for i, step in enumerate(after.data['sc_action_steps'], 1):
    print(f"  {i}. {step}")
    print(f"     (Length: {len(step)} chars)")

# Check if it worked
if after.data['sc_action_steps'] == new_steps:
    print("\n✅ UPDATE SUCCESSFUL!")
    print("   - Text array format works correctly")
    print("   - Conversational steps applied")
    print("   - Ready to apply all 326 scenarios")
else:
    print("\n❌ UPDATE FAILED - Database not changed")
