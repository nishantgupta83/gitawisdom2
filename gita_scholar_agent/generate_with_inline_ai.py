#!/usr/bin/env python3
"""
Generate conversational action steps improvements.
This script will be run in an AI environment where improvements are generated inline.
"""

import json
import os

def load_scenarios():
    """Load all high-severity scenarios."""
    with open('gita_scholar_agent/output/ALL_HIGH_SEVERITY_SCENARIOS.json', 'r') as f:
        return json.load(f)

def save_improvements(improvements):
    """Save improvements to JSON file."""
    output_file = 'gita_scholar_agent/output/CONVERSATIONAL_IMPROVEMENTS.json'
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(improvements, f, indent=2, ensure_ascii=False)
    print(f"\n✅ Saved {len(improvements)} improvements to: {output_file}")
    return output_file

def generate_sql(improvements):
    """Generate SQL script from improvements."""
    sql_file = 'gita_scholar_agent/output/CONVERSATIONAL_UPDATE.sql'
    with open(sql_file, 'w', encoding='utf-8') as f:
        f.write("-- SQL Script: Conversational Action Steps Improvements\n")
        f.write("-- AI-generated comprehensive, conversational guidance\n")
        f.write(f"-- Affects {len(improvements)} scenarios\n\n")
        f.write("BEGIN;\n\n")

        for improvement in improvements:
            scenario_id = improvement['scenario_id']
            steps = improvement['improved_steps']

            steps_json = json.dumps(steps, ensure_ascii=False).replace("'", "''")

            f.write(f"-- Scenario {scenario_id}: {improvement['title']}\n")
            f.write(f"UPDATE scenarios \n")
            f.write(f"SET sc_action_steps = '{steps_json}'::jsonb \n")
            f.write(f"WHERE scenario_id = {scenario_id};\n\n")

        f.write("COMMIT;\n")

    print(f"✅ SQL script: {sql_file}")
    return sql_file

def main():
    """Main processing function."""
    print("🔍 Loading scenarios...")
    scenarios = load_scenarios()
    print(f"✅ Loaded {len(scenarios)} high-severity scenarios\n")

    print("📊 Scenario Summary:")
    print(f"   Total to improve: {len(scenarios)}")
    print(f"   Example scenario: {scenarios[0]['scenario_id']} - {scenarios[0]['title']}")
    print(f"\n   Current steps (before):")
    for i, step in enumerate(scenarios[0]['current_action_steps'], 1):
        print(f"      {i}. {step}")

    print(f"\n{'='*80}")
    print("📝 Ready for AI-powered improvements")
    print(f"{'='*80}")
    print("\nNext: AI will generate conversational improvements for all scenarios")
    print("Format: Complete sentences, 60-150 characters, conversational tone")

if __name__ == "__main__":
    main()
