#!/usr/bin/env python3
"""
Generate conversational, comprehensive action steps for all high-severity scenarios.
Uses AI to create helpful, detailed guidance that reads like advice from a friend.
"""

import json
import os
from anthropic import Anthropic

def generate_conversational_steps(scenario, client):
    """Generate improved action steps using Claude API."""

    scenario_id = scenario['scenario_id']
    title = scenario['title']
    description = scenario['description']
    category = scenario['category']
    heart = scenario['heart_response']
    duty = scenario['duty_response']
    gita_wisdom = scenario['gita_wisdom']
    current_steps = scenario['current_action_steps']

    prompt = f"""You are improving action steps for a Bhagavad Gita wisdom app. The current steps are too robotic and have redundant phrases.

**Scenario #{scenario_id}: {title}**

**Situation:** {description}

**Category:** {category}

**Heart Response (emotional/easy path):** {heart}

**Duty Response (dharmic/right path):** {duty}

**Gita Wisdom:** {gita_wisdom}

**Current Action Steps (NEED IMPROVEMENT - too terse/redundant):**
{json.dumps(current_steps, indent=2)}

**Your Task:**
Rewrite these 5 action steps to be:

1. **Conversational** - like advice from a wise, caring friend
2. **Comprehensive** - include context, examples, specific details (aim for 60-150 characters each)
3. **Complete sentences** - not commands or fragments
4. **Actionable** - concrete steps someone can actually do
5. **Progressive** - build from easier to harder actions
6. **Specific to this scenario** - reference the actual situation

**Good Example Style:**
"Identify your top 3-5 spending categories (like groceries, clothing, tech) and create simple decision rules for each to cut through analysis paralysis"

**Bad Example Style (avoid):**
"Identify top categories" (too terse)
"Take time to identify categories, ensuring you understand the context" (redundant)

**CRITICAL:** Return ONLY a JSON array of 5 strings, nothing else:
["Step 1 text here", "Step 2 text here", "Step 3 text here", "Step 4 text here", "Step 5 text here"]"""

    try:
        message = client.messages.create(
            model="claude-sonnet-4-20250514",
            max_tokens=1500,
            temperature=0.7,
            messages=[{"role": "user", "content": prompt}]
        )

        response_text = message.content[0].text.strip()

        # Remove markdown if present
        if response_text.startswith('```'):
            lines = response_text.split('\n')
            response_text = '\n'.join(lines[1:-1])
            if response_text.startswith('json'):
                response_text = response_text[4:].strip()

        improved_steps = json.loads(response_text)

        if not isinstance(improved_steps, list) or len(improved_steps) != 5:
            print(f"⚠️  Scenario {scenario_id}: Got {len(improved_steps) if isinstance(improved_steps, list) else 'invalid'} steps, expected 5")
            return None

        return {
            'scenario_id': scenario_id,
            'title': title,
            'improved_steps': improved_steps,
            'old_steps': current_steps
        }

    except Exception as e:
        print(f"❌ Error processing scenario {scenario_id}: {e}")
        return None

def main():
    """Main processing function."""

    # Check for API key
    api_key = os.getenv('ANTHROPIC_API_KEY')
    if not api_key:
        print("❌ ANTHROPIC_API_KEY environment variable not set")
        print("   Set it with: export ANTHROPIC_API_KEY='your-key-here'")
        return

    print("🔍 Loading scenarios...")
    with open('gita_scholar_agent/output/ALL_HIGH_SEVERITY_SCENARIOS.json', 'r') as f:
        scenarios = json.load(f)

    print(f"✅ Loaded {len(scenarios)} high-severity scenarios")
    print(f"\n🤖 Generating conversational action steps using Claude API...")
    print(f"   This will use API credits but produce much better quality")

    # Initialize Anthropic client
    client = Anthropic(api_key=api_key)

    improvements = []
    errors = []

    # Process all scenarios
    for i, scenario in enumerate(scenarios, 1):
        result = generate_conversational_steps(scenario, client)

        if result:
            improvements.append(result)

            if i % 10 == 0:
                print(f"   Progress: {i}/{len(scenarios)} scenarios processed...")
                # Show example
                if len(improvements) >= 1:
                    ex = improvements[-1]
                    print(f"   Latest: Scenario {ex['scenario_id']} - {ex['title']}")
                    print(f"            {ex['improved_steps'][0][:80]}...")
        else:
            errors.append(scenario['scenario_id'])

    print(f"\n{'='*80}")
    print(f"📊 GENERATION SUMMARY")
    print(f"{'='*80}")
    print(f"Total scenarios: {len(scenarios)}")
    print(f"Successfully improved: {len(improvements)}")
    print(f"Errors: {len(errors)}")

    # Save improvements
    output_file = 'gita_scholar_agent/output/CONVERSATIONAL_IMPROVEMENTS.json'
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(improvements, f, indent=2, ensure_ascii=False)

    print(f"\n✅ Saved to: {output_file}")

    # Generate SQL
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

    # Show examples
    print(f"\n📋 SAMPLE IMPROVEMENTS:\n")
    for i, improvement in enumerate(improvements[:3], 1):
        print(f"{i}. Scenario {improvement['scenario_id']}: {improvement['title']}")
        print(f"   New steps:")
        for j, step in enumerate(improvement['improved_steps'], 1):
            print(f"      {j}. {step}")
        print()

    print(f"\n🎉 All done! {len(improvements)} scenarios improved with conversational action steps.")
    print(f"\n📁 Next steps:")
    print(f"   1. Review: {output_file}")
    print(f"   2. Apply SQL via Supabase Dashboard: {sql_file}")

if __name__ == "__main__":
    main()
