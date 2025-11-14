#!/usr/bin/env python3
"""
Query the top 20 scenarios with repetitive action steps to understand the pattern.
"""

from supabase import create_client, Client
import json

# Supabase credentials
SUPABASE_URL = "https://wlfwdtdtiedlcczfoslt.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndsZndkdGR0aWVkbGNjemZvc2x0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE4NjQ5MDAsImV4cCI6MjA2NzQ0MDkwMH0.OiWhZled2trJ7eTd8lpQ658B4p-IVsRp2HXHcgAUoFU"

# Top 20 scenario IDs from user's list
TARGET_SCENARIOS = [
    831, 836, 832, 829, 858, 874, 1139, 676, 682, 805,
    864, 867, 854, 833, 631, 821, 870, 820, 863, 441
]

def query_scenarios():
    """Query specific scenarios to understand repetitive pattern."""
    try:
        # Create Supabase client
        supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

        # Query scenarios by scenario_id
        response = supabase.table('scenarios').select('scenario_id, sc_title, sc_action_steps').in_('scenario_id', TARGET_SCENARIOS).execute()

        if response.data:
            print(f"\n{'='*80}")
            print(f"Found {len(response.data)} scenarios")
            print(f"{'='*80}\n")

            scenarios_data = []
            for scenario in response.data:
                scenario_id = scenario.get('scenario_id')
                title = scenario.get('sc_title')
                action_steps = scenario.get('sc_action_steps', [])

                print(f"\n{'='*80}")
                print(f"Scenario {scenario_id}: {title}")
                print(f"{'='*80}")

                if action_steps and isinstance(action_steps, list):
                    for i, step in enumerate(action_steps, 1):
                        print(f"{i}. {step}")
                else:
                    print("No action steps found")

                scenarios_data.append({
                    'scenario_id': scenario_id,
                    'title': title,
                    'action_steps': action_steps
                })

            # Save to file
            output_file = "output/top20_scenarios_data.json"
            with open(output_file, 'w', encoding='utf-8') as f:
                json.dump(scenarios_data, f, indent=2, ensure_ascii=False)
            print(f"\n{'='*80}")
            print(f"All scenario data saved to: {output_file}")
            print(f"{'='*80}\n")

        else:
            print("No scenarios found")

    except Exception as e:
        print(f"Error querying Supabase: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    query_scenarios()
