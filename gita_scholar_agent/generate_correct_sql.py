#!/usr/bin/env python3
"""
Generate SQL script with correct PostgreSQL text[] array syntax.
"""

import json

def escape_for_postgres_array(text):
    """Escape text for PostgreSQL array literal."""
    # Escape single quotes by doubling them (SQL standard)
    text = text.replace("'", "''")
    # Escape backslashes
    text = text.replace('\\', '\\\\')
    return text

def main():
    print("🔍 Loading improvements...")

    with open('gita_scholar_agent/output/CONVERSATIONAL_IMPROVEMENTS.json', 'r') as f:
        improvements = json.load(f)

    print(f"✅ Loaded {len(improvements)} improvements")
    print(f"🔧 Generating SQL with text[] array syntax...\n")

    sql_file = 'gita_scholar_agent/output/CONVERSATIONAL_UPDATE_FIXED.sql'

    with open(sql_file, 'w', encoding='utf-8') as f:
        f.write("-- ============================================================================\n")
        f.write("-- CONVERSATIONAL ACTION STEPS UPDATE (FIXED FOR text[] column type)\n")
        f.write("-- ============================================================================\n")
        f.write("-- Updates 326 high-severity scenarios with conversational, comprehensive\n")
        f.write("-- action steps that read like advice from a wise, caring friend.\n")
        f.write("--\n")
        f.write("-- Quality improvements:\n")
        f.write("-- - Removed robotic 'Take time to' and 'ensuring full context' patterns\n")
        f.write("-- - Added specific context and examples from each scenario\n")
        f.write("-- - Made steps 60-150 characters with complete sentences\n")
        f.write("-- - Progressive steps that build from easier to harder actions\n")
        f.write("--\n")
        f.write("-- Column Type: text[] (PostgreSQL text array)\n")
        f.write("-- ============================================================================\n\n")
        f.write("BEGIN;\n\n")

        for i, improvement in enumerate(improvements, 1):
            scenario_id = improvement['scenario_id']
            title = improvement['title']
            steps = improvement['improved_steps']

            # Build PostgreSQL array literal with ARRAY constructor
            # Format: ARRAY['step1', 'step2', ...]
            escaped_steps = [escape_for_postgres_array(step) for step in steps]
            array_literal = "ARRAY['" + "', '".join(escaped_steps) + "']"

            f.write(f"-- Scenario {scenario_id}: {title}\n")
            f.write(f"UPDATE scenarios\n")
            f.write(f"SET sc_action_steps = {array_literal}\n")
            f.write(f"WHERE scenario_id = {scenario_id};\n\n")

            if i % 50 == 0:
                print(f"   Progress: {i}/{len(improvements)} scenarios...")

        f.write("COMMIT;\n")

    print(f"\n{'='*80}")
    print(f"✅ SQL script generated: {sql_file}")
    print(f"{'='*80}")
    print(f"\nTotal scenarios: {len(improvements)}")
    print(f"Format: PostgreSQL text[] array with ARRAY constructor")
    print(f"\n📋 Sample SQL (first scenario):\n")

    # Show first example
    first = improvements[0]
    escaped = [escape_for_postgres_array(s) for s in first['improved_steps']]
    array_literal = "ARRAY['" + "', '".join(escaped) + "']"

    print(f"-- Scenario {first['scenario_id']}: {first['title']}")
    print(f"UPDATE scenarios")
    print(f"SET sc_action_steps = {array_literal[:150]}...")
    print(f"WHERE scenario_id = {first['scenario_id']};")

    print(f"\n✅ Ready to apply in Supabase SQL Editor!")

if __name__ == "__main__":
    main()
