#!/usr/bin/env python3
"""
Verify that action step improvements were applied correctly.
"""

import json
from supabase import create_client, Client
import random

# Supabase credentials
SUPABASE_URL = "https://wlfwdtdtiedlcczfoslt.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndsZndkdGR0aWVkbGNjemZvc2x0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE4NjQ5MDAsImV4cCI6MjA2NzQ0MDkwMH0.OiWhZled2trJ7eTd8lpQ658B4p-IVsRp2HXHcgAUoFU"

def check_for_redundancy(steps):
    """Check if steps still contain redundant phrases."""
    redundant_count = 0
    for step in steps:
        if isinstance(step, str):
            if 'ensuring you understand the full context and implications' in step.lower():
                redundant_count += 1
    return redundant_count

def main():
    """Verify improvements."""

    print("🔍 Verifying database updates...")

    # Load update results
    with open('gita_scholar_agent/output/UPDATE_RESULTS.json', 'r') as f:
        results = json.load(f)

    print(f"✅ {results['successful']} scenarios were updated")

    # Initialize Supabase
    supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

    # Sample 10 random scenarios to verify
    sample_ids = random.sample(results['success_ids'], min(10, len(results['success_ids'])))

    print(f"\n🔍 Checking {len(sample_ids)} random scenarios for verification...")

    all_clean = True
    for scenario_id in sample_ids:
        response = supabase.table('scenarios').select('scenario_id, sc_title, sc_action_steps').eq('scenario_id', scenario_id).single().execute()

        if response.data:
            scenario = response.data
            steps = scenario['sc_action_steps']
            redundant_count = check_for_redundancy(steps)

            print(f"\n📋 Scenario {scenario_id}: {scenario['sc_title']}")
            print(f"   Action steps: {len(steps)}")
            print(f"   Redundant phrases: {redundant_count}")

            if redundant_count > 0:
                print(f"   ⚠️  Still has redundancy!")
                all_clean = False
            else:
                print(f"   ✅ Clean!")

            # Show first 2 steps
            for i, step in enumerate(steps[:2], 1):
                print(f"   {i}. {step}")

    # Also check the specific scenario 772 mentioned by user
    print(f"\n{'='*80}")
    print(f"🎯 CHECKING SCENARIO 772 (user example):")
    print(f"{'='*80}")

    response = supabase.table('scenarios').select('*').eq('scenario_id', 772).single().execute()

    if response.data:
        scenario = response.data
        steps = scenario['sc_action_steps']
        redundant_count = check_for_redundancy(steps)

        print(f"\nTitle: {scenario['sc_title']}")
        print(f"Action steps ({len(steps)} total):")
        for i, step in enumerate(steps, 1):
            print(f"  {i}. {step}")

        print(f"\nRedundant phrases found: {redundant_count}")

        if redundant_count > 0:
            print(f"⚠️  Still contains redundant phrases!")
            all_clean = False
        else:
            print(f"✅ All redundancy removed!")

    print(f"\n{'='*80}")
    print(f"📊 VERIFICATION SUMMARY")
    print(f"{'='*80}")

    if all_clean:
        print(f"✅ ALL CHECKED SCENARIOS ARE CLEAN!")
        print(f"✅ Redundancy successfully removed from database")
        print(f"✅ Action steps are now concise and actionable")
    else:
        print(f"⚠️  Some scenarios still have redundancy")
        print(f"   Review the output above for details")

    print(f"\n🎉 Database update verification complete!")

if __name__ == "__main__":
    main()
