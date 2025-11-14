#!/usr/bin/env python3
from supabase import create_client

supabase = create_client(
    "https://wlfwdtdtiedlcczfoslt.supabase.co",
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndsZndkdGR0aWVkbGNjemZvc2x0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE4NjQ5MDAsImV4cCI6MjA2NzQ0MDkwMH0.OiWhZled2trJ7eTd8lpQ658B4p-IVsRp2HXHcgAUoFU"
)

result = supabase.table('scenarios').select('scenario_id, sc_title, sc_action_steps').eq('scenario_id', 772).single().execute()

print(f"Scenario {result.data['scenario_id']}: {result.data['sc_title']}")
print(f"\nAction Steps:")
for i, step in enumerate(result.data['sc_action_steps'], 1):
    print(f"{i}. {step}")
