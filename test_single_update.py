#!/usr/bin/env python3
from supabase import create_client
import time

supabase = create_client(
    "https://wlfwdtdtiedlcczfoslt.supabase.co",
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndsZndkdGR0aWVkbGNjemZvc2x0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE4NjQ5MDAsImV4cCI6MjA2NzQ0MDkwMH0.OiWhZled2trJ7eTd8lpQ658B4p-IVsRp2HXHcgAUoFU"
)

# Read before
before = supabase.table('scenarios').select('sc_action_steps').eq('scenario_id', 772).single().execute()
print("BEFORE UPDATE:")
for i, step in enumerate(before.data['sc_action_steps'], 1):
    print(f"{i}. {step}")

# Update
new_steps = [
    "Identify top categories",
    "Make default choices",
    "Limit research time",
    "Accept imperfection",
    "Review changes yearly"
]

print("\nUPDATING...")
result = supabase.table('scenarios').update({'sc_action_steps': new_steps}).eq('scenario_id', 772).execute()
print(f"Update response: {result}")

# Wait a moment
time.sleep(2)

# Read after
after = supabase.table('scenarios').select('sc_action_steps').eq('scenario_id', 772).single().execute()
print("\nAFTER UPDATE:")
for i, step in enumerate(after.data['sc_action_steps'], 1):
    print(f"{i}. {step}")

# Check if it worked
if after.data['sc_action_steps'] == new_steps:
    print("\n✅ UPDATE SUCCESSFUL!")
else:
    print("\n❌ UPDATE FAILED - Database not changed")
