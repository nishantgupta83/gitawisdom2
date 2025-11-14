#!/usr/bin/env python3
"""
Extract high-priority scenarios for manual AI review.
Gets full context for scenarios needing improvement.
"""

import json
from supabase import create_client, Client

# Supabase credentials
SUPABASE_URL = "https://wlfwdtdtiedlcczfoslt.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndsZndkdGR0aWVkbGNjemZvc2x0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE4NjQ5MDAsImV4cCI6MjA2NzQ0MDkwMH0.OiWhZled2trJ7eTd8lpQ658B4p-IVsRp2HXHcgAUoFU"

def main():
    """Extract scenarios for review."""

    # Load analysis results
    with open('gita_scholar_agent/output/action_steps_analysis.json', 'r') as f:
        analysis = json.load(f)

    # Filter high severity problems
    high_severity = [p for p in analysis['problems'] if p['severity'] == 'high']
    print(f"Found {len(high_severity)} high severity scenarios")

    # Initialize Supabase
    supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

    # Get top 20 worst scenarios for detailed review
    top_scenarios = high_severity[:20]
    scenario_ids = [s['scenario_id'] for s in top_scenarios]

    print(f"\nFetching full context for top 20 scenarios...")

    # Fetch from database
    response = supabase.table('scenarios').select('*').in_('scenario_id', scenario_ids).execute()

    # Combine analysis with full data
    scenarios_for_review = []
    for scenario_data in response.data:
        scenario_id = scenario_data['scenario_id']

        # Find matching analysis
        analysis_data = next((s for s in top_scenarios if s['scenario_id'] == scenario_id), None)

        scenarios_for_review.append({
            'scenario_id': scenario_id,
            'title': scenario_data['sc_title'],
            'description': scenario_data['sc_description'],
            'category': scenario_data['sc_category'],
            'chapter': scenario_data['sc_chapter'],
            'heart_response': scenario_data['sc_heart_response'],
            'duty_response': scenario_data['sc_duty_response'],
            'gita_wisdom': scenario_data['sc_gita_wisdom'],
            'verse': scenario_data.get('sc_verse'),
            'verse_number': scenario_data.get('sc_verse_number'),
            'current_action_steps': scenario_data['sc_action_steps'],
            'issues': analysis_data['issues'] if analysis_data else [],
            'severity': 'high'
        })

    # Save for review
    output_file = 'gita_scholar_agent/output/scenarios_for_ai_review.json'
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(scenarios_for_review, f, indent=2, ensure_ascii=False)

    print(f"✅ Extracted {len(scenarios_for_review)} scenarios to: {output_file}")

    # Print first scenario as example
    if scenarios_for_review:
        print(f"\n{'='*80}")
        print(f"EXAMPLE SCENARIO FOR REVIEW")
        print(f"{'='*80}")
        example = scenarios_for_review[0]
        print(f"\nID: {example['scenario_id']}")
        print(f"Title: {example['title']}")
        print(f"Category: {example['category']} | Chapter: {example['chapter']}")
        print(f"\nDescription: {example['description'][:150]}...")
        print(f"\nHeart Response: {example['heart_response'][:100]}...")
        print(f"\nDuty Response: {example['duty_response'][:100]}...")
        print(f"\nCurrent Action Steps:")
        for i, step in enumerate(example['current_action_steps'], 1):
            print(f"  {i}. {step}")
        print(f"\nIssues: {', '.join(example['issues'])}")

if __name__ == "__main__":
    main()
