#!/usr/bin/env python3
"""
Apply automated action step fixes to Supabase database.
Updates all 326 high-severity scenarios with cleaned action steps.
"""

import json
from supabase import create_client, Client
import time

# Supabase credentials
SUPABASE_URL = "https://wlfwdtdtiedlcczfoslt.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndsZndkdGR0aWVkbGNjemZvc2x0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE4NjQ5MDAsImV4cCI6MjA2NzQ0MDkwMH0.OiWhZled2trJ7eTd8lpQ658B4p-IVsRp2HXHcgAUoFU"

def main():
    """Apply fixes to database."""

    print("🔍 Loading automated fixes...")

    # Load fixes
    with open('gita_scholar_agent/output/AUTO_FIXED_ACTION_STEPS.json', 'r') as f:
        improvements = json.load(f)

    print(f"✅ Loaded {len(improvements)} improvements")

    # Initialize Supabase
    supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

    print(f"\n🚀 Applying fixes to database...")
    print(f"   This will update {len(improvements)} scenarios")

    # Confirm before proceeding
    response = input(f"\nProceed with database update? (yes/no): ")
    if response.lower() != 'yes':
        print("❌ Update cancelled")
        return

    # Track successes and failures
    successes = []
    failures = []

    # Apply each update
    for i, improvement in enumerate(improvements, 1):
        scenario_id = improvement['scenario_id']
        new_steps = improvement['new_steps']

        try:
            # Update the scenario
            result = supabase.table('scenarios').update({
                'sc_action_steps': new_steps
            }).eq('scenario_id', scenario_id).execute()

            successes.append(scenario_id)

            if i % 50 == 0:
                print(f"   Progress: {i}/{len(improvements)} scenarios updated...")

        except Exception as e:
            failures.append({'scenario_id': scenario_id, 'error': str(e)})
            print(f"   ❌ Failed to update scenario {scenario_id}: {e}")

        # Rate limiting - be nice to the API
        if i % 10 == 0:
            time.sleep(0.5)

    print(f"\n{'='*80}")
    print(f"📊 UPDATE SUMMARY")
    print(f"{'='*80}")
    print(f"✅ Successful updates: {len(successes)}")
    print(f"❌ Failed updates: {len(failures)}")

    if failures:
        print(f"\n⚠️  FAILED SCENARIOS:")
        for fail in failures[:10]:  # Show first 10
            print(f"   - Scenario {fail['scenario_id']}: {fail['error']}")
        if len(failures) > 10:
            print(f"   ... and {len(failures) - 10} more")

    # Save results
    result_file = 'gita_scholar_agent/output/UPDATE_RESULTS.json'
    with open(result_file, 'w') as f:
        json.dump({
            'total_attempted': len(improvements),
            'successful': len(successes),
            'failed': len(failures),
            'success_ids': successes,
            'failures': failures
        }, f, indent=2)

    print(f"\n✅ Results saved to: {result_file}")
    print(f"\n🎉 Database update complete!")
    print(f"   {len(successes)}/{len(improvements)} scenarios successfully updated")

if __name__ == "__main__":
    main()
