#!/usr/bin/env python3
"""
Apply SQL updates directly using Supabase RPC to ensure they persist.
"""

import json
from supabase import create_client, Client

# Supabase credentials
SUPABASE_URL = "https://wlfwdtdtiedlcczfoslt.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndsZndkdGR0aWVkbGNjemZvc2x0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE4NjQ5MDAsImV4cCI6MjA2NzQ0MDkwMH0.OiWhZled2trJ7eTd8lpQ658B4p-IVsRp2HXHcgAUoFU"

def main():
    """Apply fixes directly to database with proper commits."""

    print("🔍 Loading automated fixes...")

    # Load fixes
    with open('gita_scholar_agent/output/AUTO_FIXED_ACTION_STEPS.json', 'r') as f:
        improvements = json.load(f)

    print(f"✅ Loaded {len(improvements)} improvements")

    # Initialize Supabase
    supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

    print(f"\n🚀 Applying fixes to database with immediate commits...")

    successes = []
    failures = []

    # Apply each update individually with verification
    for i, improvement in enumerate(improvements, 1):
        scenario_id = improvement['scenario_id']
        new_steps = improvement['new_steps']

        try:
            # Update using Supabase REST API directly
            result = supabase.table('scenarios').update({
                'sc_action_steps': new_steps
            }).eq('scenario_id', scenario_id).execute()

            # Verify the update immediately
            verify = supabase.table('scenarios').select('sc_action_steps').eq('scenario_id', scenario_id).single().execute()

            if verify.data and verify.data['sc_action_steps'] == new_steps:
                successes.append(scenario_id)
            else:
                failures.append({'scenario_id': scenario_id, 'error': 'Update not reflected in database'})

            if i % 50 == 0:
                print(f"   Progress: {i}/{len(improvements)} (verified {len(successes)})...")

        except Exception as e:
            failures.append({'scenario_id': scenario_id, 'error': str(e)})
            print(f"   ❌ Failed scenario {scenario_id}: {e}")

    print(f"\n{'='*80}")
    print(f"📊 UPDATE & VERIFICATION SUMMARY")
    print(f"{'='*80}")
    print(f"✅ Successfully updated & verified: {len(successes)}")
    print(f"❌ Failed or not verified: {len(failures)}")

    if failures:
        print(f"\n⚠️  ISSUES:")
        for fail in failures[:10]:
            print(f"   - Scenario {fail['scenario_id']}: {fail['error']}")

    # Save results
    result_file = 'gita_scholar_agent/output/DIRECT_UPDATE_RESULTS.json'
    with open(result_file, 'w') as f:
        json.dump({
            'total_attempted': len(improvements),
            'successful': len(successes),
            'failed': len(failures),
            'success_ids': successes,
            'failures': failures
        }, f, indent=2)

    print(f"\n✅ Results saved to: {result_file}")

if __name__ == "__main__":
    main()
