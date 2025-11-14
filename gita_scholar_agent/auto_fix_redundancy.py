#!/usr/bin/env python3
"""
Automatically fix redundant action steps using intelligent pattern replacement.
Removes generic templates and makes steps more specific based on context.
"""

import json
import re
from supabase import create_client, Client

# Supabase credentials
SUPABASE_URL = "https://wlfwdtdtiedlcczfoslt.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndsZndkdGR0aWVkbGNjemZvc2x0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE4NjQ5MDAsImV4cCI6MjA2NzQ0MDkwMH0.OiWhZled2trJ7eTd8lpQ658B4p-IVsRp2HXHcgAUoFU"

def clean_action_step(step):
    """Remove redundant template phrases from an action step."""

    if not isinstance(step, str):
        return step

    # Remove the redundant suffix
    cleaned = re.sub(
        r',?\s*ensuring you understand the full context and implications\s*$',
        '',
        step,
        flags=re.IGNORECASE
    )

    # Remove "Take time to" prefix if it's just filler
    cleaned = re.sub(
        r'^Take time to\s+',
        '',
        cleaned,
        flags=re.IGNORECASE
    )

    # Capitalize first letter
    if cleaned:
        cleaned = cleaned[0].upper() + cleaned[1:]

    return cleaned.strip()

def improve_action_steps(scenario):
    """Improve action steps for a scenario by removing redundancy."""

    current_steps = scenario.get('current_action_steps', [])

    if not current_steps or len(current_steps) == 0:
        return None

    # Clean each step
    improved_steps = [clean_action_step(step) for step in current_steps]

    # Check if anything changed
    if improved_steps == current_steps:
        return None  # No changes needed

    return {
        'scenario_id': scenario['scenario_id'],
        'title': scenario['title'],
        'old_steps': current_steps,
        'new_steps': improved_steps
    }

def main():
    """Main function."""

    print("🔍 Loading all high-severity scenarios...")

    # Load all high-severity scenarios
    with open('gita_scholar_agent/output/ALL_HIGH_SEVERITY_SCENARIOS.json', 'r') as f:
        scenarios = json.load(f)

    print(f"✅ Loaded {len(scenarios)} scenarios")
    print(f"\n🔧 Applying automated redundancy fixes...")

    improvements = []
    for scenario in scenarios:
        result = improve_action_steps(scenario)
        if result:
            improvements.append(result)

    print(f"✅ Generated improvements for {len(improvements)} scenarios")

    # Save improvements
    output_file = 'gita_scholar_agent/output/AUTO_FIXED_ACTION_STEPS.json'
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(improvements, f, indent=2, ensure_ascii=False)

    print(f"✅ Saved to: {output_file}")

    # Generate SQL
    sql_file = 'gita_scholar_agent/output/AUTO_FIX_UPDATE.sql'
    with open(sql_file, 'w', encoding='utf-8') as f:
        f.write("-- SQL Script: Automated Redundancy Removal\n")
        f.write("-- Removes 'ensuring you understand' and 'Take time to' templates\n")
        f.write("-- Affects {} scenarios\n\n".format(len(improvements)))
        f.write("BEGIN;\n\n")

        for improvement in improvements:
            scenario_id = improvement['scenario_id']
            new_steps = improvement['new_steps']

            # Escape for SQL
            new_steps_json = json.dumps(new_steps, ensure_ascii=False).replace("'", "''")

            f.write(f"-- Scenario {scenario_id}: {improvement['title']}\n")
            f.write(f"UPDATE scenarios \n")
            f.write(f"SET sc_action_steps = '{new_steps_json}'::jsonb \n")
            f.write(f"WHERE scenario_id = {scenario_id};\n\n")

        f.write("COMMIT;\n")
        f.write(f"\n-- Updated {len(improvements)} scenarios\n")

    print(f"✅ SQL script saved to: {sql_file}")

    # Show examples
    print(f"\n📋 EXAMPLE IMPROVEMENTS:")
    for i, improvement in enumerate(improvements[:5], 1):
        print(f"\n{i}. Scenario {improvement['scenario_id']}: {improvement['title']}")
        print(f"   Old steps:")
        for j, step in enumerate(improvement['old_steps'][:2], 1):
            print(f"      {j}. {step[:80]}...")
        print(f"   New steps:")
        for j, step in enumerate(improvement['new_steps'][:2], 1):
            print(f"      {j}. {step[:80]}...")

    print(f"\n{'='*80}")
    print(f"📊 SUMMARY:")
    print(f"{'='*80}")
    print(f"Total high-severity scenarios: {len(scenarios)}")
    print(f"Scenarios with improvements: {len(improvements)}")
    print(f"Automated fixes applied: {len(improvements)}")
    print(f"\n🎯 NEXT STEPS:")
    print(f"   1. Review examples in: {output_file}")
    print(f"   2. Test SQL on staging: {sql_file}")
    print(f"   3. Run SQL to apply changes")
    print(f"   4. For deeper improvements, consider AI-powered review of remaining scenarios")

if __name__ == "__main__":
    main()
