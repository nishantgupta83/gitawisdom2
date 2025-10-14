#!/usr/bin/env python3
"""
Query specific scenario from Supabase to inspect quality issues.
"""

from supabase import create_client, Client
import json

# Supabase credentials
SUPABASE_URL = "https://wlfwdtdtiedlcczfoslt.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndsZndkdGR0aWVkbGNjemZvc2x0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE4NjQ5MDAsImV4cCI6MjA2NzQ0MDkwMH0.OiWhZled2trJ7eTd8lpQ658B4p-IVsRp2HXHcgAUoFU"

def query_learning_differences_scenario():
    """Query scenario about child with learning differences."""
    try:
        # Create Supabase client
        supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

        # Query for the scenario
        response = supabase.table('scenarios').select('*').ilike('sc_title', '%child%learning%differences%').execute()

        if not response.data:
            print("No scenario found with 'child' and 'learning differences' in title")
            # Try broader search
            print("\nTrying broader search with just 'learning differences'...")
            response = supabase.table('scenarios').select('*').ilike('sc_title', '%learning%differences%').execute()

        if not response.data:
            print("Still no results. Trying just 'learning'...")
            response = supabase.table('scenarios').select('*').ilike('sc_title', '%learning%').limit(5).execute()

        if response.data:
            print(f"\n{'='*80}")
            print(f"Found {len(response.data)} scenario(s)")
            print(f"{'='*80}\n")

            for idx, scenario in enumerate(response.data, 1):
                print(f"\n--- Scenario {idx} ---")
                print(f"ID: {scenario.get('id')}")
                print(f"\nTitle: {scenario.get('sc_title')}")
                print(f"\nDescription: {scenario.get('sc_description', 'N/A')[:200]}...")

                print(f"\n{'='*80}")
                print("HEART SAYS (sc_heart_response):")
                print(f"{'='*80}")
                print(scenario.get('sc_heart_response', 'N/A'))

                print(f"\n{'='*80}")
                print("DUTY SAYS (sc_duty_response):")
                print(f"{'='*80}")
                print(scenario.get('sc_duty_response', 'N/A'))

                print(f"\n{'='*80}")
                print("KEY LEARNINGS (sc_gita_wisdom) - CHECKING FOR ISSUES:")
                print(f"{'='*80}")
                gita_wisdom = scenario.get('sc_gita_wisdom', 'N/A')
                print(gita_wisdom)

                # Analyze for issues
                print(f"\n{'='*80}")
                print("QUALITY ISSUE ANALYSIS:")
                print(f"{'='*80}")

                issues = []

                # Check gita_wisdom for issues
                if gita_wisdom and gita_wisdom != 'N/A':
                    lines = gita_wisdom.split('\n')
                    for line_num, line in enumerate(lines, 1):
                        stripped = line.strip()
                        if stripped:
                            # Check for incomplete sentences
                            if stripped.endswith('etc') or stripped.endswith('etc.'):
                                issues.append(f"Line {line_num}: Ends with 'etc' - {stripped}")
                            elif stripped.endswith('('):
                                issues.append(f"Line {line_num}: Ends with '(' - {stripped}")
                            elif stripped.endswith(',') or stripped.endswith('and'):
                                issues.append(f"Line {line_num}: Incomplete sentence - {stripped}")
                            elif len(stripped) < 20 and not stripped.endswith('.') and not stripped.endswith(':'):
                                issues.append(f"Line {line_num}: Very short, possibly incomplete - {stripped}")

                # Check action steps
                action_steps = scenario.get('sc_action_steps', [])
                print(f"\nAction Steps: {len(action_steps) if action_steps else 0}")
                if action_steps:
                    for i, step in enumerate(action_steps, 1):
                        if isinstance(step, str):
                            if len(step) < 10:
                                issues.append(f"Action step {i}: Too short - {step}")

                # Check tags
                tags = scenario.get('sc_tags', [])
                print(f"Tags: {', '.join(tags) if tags else 'None'}")

                if issues:
                    print(f"\n🔴 FOUND {len(issues)} QUALITY ISSUES:")
                    for issue in issues:
                        print(f"  - {issue}")
                else:
                    print("\n✅ No obvious quality issues detected")

                print(f"\n{'='*80}\n")

                # Save full JSON for reference
                output_file = f"output/scenario_{scenario.get('id')}_full_data.json"
                with open(output_file, 'w', encoding='utf-8') as f:
                    json.dump(scenario, f, indent=2, ensure_ascii=False)
                print(f"Full scenario data saved to: {output_file}")
        else:
            print("No scenarios found matching the search criteria")

    except Exception as e:
        print(f"Error querying Supabase: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    query_learning_differences_scenario()
