#!/usr/bin/env python3
"""
Extract ALL high-severity scenarios (not just top 20) for AI review.
"""

import json
import os
from supabase import create_client, Client

# Supabase credentials
SUPABASE_URL = "https://wlfwdtdtiedlcczfoslt.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndsZndkdGR0aWVkbGNjemZvc2x0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE4NjQ5MDAsImV4cCI6MjA2NzQ0MDkwMH0.OiWhZled2trJ7eTd8lpQ658B4p-IVsRp2HXHcgAUoFU"

def main():
    """Extract ALL high-severity scenarios."""

    # Load analysis results
    with open('gita_scholar_agent/output/action_steps_analysis.json', 'r') as f:
        analysis = json.load(f)

    # Filter ALL high severity problems
    high_severity = [p for p in analysis['problems'] if p['severity'] == 'high']
    print(f"📊 Found {len(high_severity)} high severity scenarios")

    # Get all scenario IDs
    scenario_ids = [s['scenario_id'] for s in high_severity]
    print(f"🔍 Fetching full context for all {len(scenario_ids)} scenarios...")

    # Initialize Supabase
    supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

    # Fetch from database in batches (Supabase has query limits)
    batch_size = 100
    all_scenarios = []

    for i in range(0, len(scenario_ids), batch_size):
        batch_ids = scenario_ids[i:i+batch_size]
        print(f"  Fetching batch {i//batch_size + 1}/{(len(scenario_ids)-1)//batch_size + 1}...")

        response = supabase.table('scenarios').select('*').in_('scenario_id', batch_ids).execute()
        all_scenarios.extend(response.data)

    print(f"✅ Fetched {len(all_scenarios)} scenarios from database")

    # Combine analysis with full data
    scenarios_for_review = []
    for scenario_data in all_scenarios:
        scenario_id = scenario_data['scenario_id']

        # Find matching analysis
        analysis_data = next((s for s in high_severity if s['scenario_id'] == scenario_id), None)

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
            'severity': 'high',
            'redundant_count': analysis_data.get('redundant_count', 0) if analysis_data else 0,
            'total_steps': analysis_data.get('total_steps', 0) if analysis_data else 0
        })

    # Save for review
    output_file = 'gita_scholar_agent/output/ALL_HIGH_SEVERITY_SCENARIOS.json'
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(scenarios_for_review, f, indent=2, ensure_ascii=False)

    print(f"\n✅ Extracted {len(scenarios_for_review)} scenarios to: {output_file}")
    print(f"📊 File size: {os.path.getsize(output_file) / 1024:.1f} KB")

    # Generate statistics by category
    from collections import defaultdict
    category_counts = defaultdict(int)
    chapter_counts = defaultdict(int)

    for s in scenarios_for_review:
        category_counts[s['category']] += 1
        chapter_counts[s['chapter']] += 1

    print(f"\n📊 BREAKDOWN BY CATEGORY:")
    for category, count in sorted(category_counts.items(), key=lambda x: x[1], reverse=True):
        print(f"   {category}: {count}")

    print(f"\n📊 BREAKDOWN BY CHAPTER:")
    for chapter, count in sorted(chapter_counts.items()):
        print(f"   Chapter {chapter}: {count}")

    print(f"\n✅ Ready for AI batch review of {len(scenarios_for_review)} scenarios")

if __name__ == "__main__":
    main()
