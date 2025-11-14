#!/usr/bin/env python3
"""
AI-powered review and fix of redundant/low-quality action steps in scenarios table.
Uses Claude API to analyze action steps in context and generate specific, actionable improvements.
"""

import os
import json
from supabase import create_client, Client
from anthropic import Anthropic

# Supabase credentials
SUPABASE_URL = "https://wlfwdtdtiedlcczfoslt.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndsZndkdGR0aWVkbGNjemZvc2x0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE4NjQ5MDAsImV4cCI6MjA2NzQ0MDkwMH0.OiWhZled2trJ7eTd8lpQ658B4p-IVsRp2HXHcgAUoFU"

def detect_action_step_issues(action_steps):
    """Detect common quality issues in action steps."""
    if not action_steps or len(action_steps) == 0:
        return ["Missing action steps"]

    issues = []

    # Check for redundancy
    repeated_phrases = {}
    for step in action_steps:
        if isinstance(step, str):
            # Check for repeated phrases
            if "ensuring you understand the full context and implications" in step:
                repeated_phrases.setdefault("generic_ensuring", []).append(step)
            if "Take time to" in step and step.count("Take time to") > 0:
                repeated_phrases.setdefault("take_time", []).append(step)
            if len(step) < 20:
                issues.append(f"Too short: {step}")
            if step.count(',') > 3:
                issues.append(f"Too complex/run-on: {step[:50]}...")

    # Report redundancy
    for phrase_type, steps in repeated_phrases.items():
        if len(steps) > 2:
            issues.append(f"Redundant pattern '{phrase_type}': {len(steps)} steps use same template")

    return issues

def review_scenario_with_ai(scenario, client: Anthropic):
    """Use Claude API to review and improve action steps."""

    scenario_id = scenario.get('scenario_id')
    title = scenario.get('sc_title', '')
    description = scenario.get('sc_description', '')
    category = scenario.get('sc_category', '')
    heart = scenario.get('sc_heart_response', '')
    duty = scenario.get('sc_duty_response', '')
    gita_wisdom = scenario.get('sc_gita_wisdom', '')
    current_steps = scenario.get('sc_action_steps', [])

    # Skip if action steps are already good (no obvious issues)
    issues = detect_action_step_issues(current_steps)
    if not issues or len(current_steps) == 0:
        return None

    print(f"\n{'='*80}")
    print(f"Scenario {scenario_id}: {title}")
    print(f"Issues detected: {', '.join(issues)}")
    print(f"Current steps: {len(current_steps)}")
    print(f"{'='*80}")

    # Prepare AI prompt
    prompt = f"""You are reviewing action steps for a Bhagavad Gita wisdom application scenario.

**Scenario Context:**
- **Title:** {title}
- **Description:** {description}
- **Category:** {category}

**Heart Response (Emotional/Easy Path):**
{heart}

**Duty Response (Dharmic/Right Path):**
{duty}

**Gita Wisdom:**
{gita_wisdom}

**Current Action Steps (THESE NEED IMPROVEMENT):**
{json.dumps(current_steps, indent=2)}

**Issues Detected:**
{chr(10).join(f'- {issue}' for issue in issues)}

**Your Task:**
Generate 4-5 SPECIFIC, ACTIONABLE steps that help someone follow the duty response path. Each step should be:
1. Concrete and specific (not generic advice like "understand context")
2. Directly tied to the scenario situation
3. Progressive (building from easier to harder actions)
4. Unique (no repetitive templates or phrases)
5. Between 50-150 characters each

**Bad Examples (avoid these):**
- "Take time to [X], ensuring you understand the full context and implications"
- "Research options thoroughly before deciding"
- "Reflect on your values"

**Good Examples:**
- "Schedule a one-on-one meeting with your manager to discuss the situation openly"
- "Document your concerns in writing before the conversation for clarity"
- "Research 3 similar cases and how they were resolved in your industry"

**Output Format:**
Return ONLY a JSON array of strings, nothing else. Example:
["Step 1 text here", "Step 2 text here", "Step 3 text here", "Step 4 text here"]

Generate improved action steps now:"""

    try:
        # Call Claude API
        message = client.messages.create(
            model="claude-sonnet-4-20250514",
            max_tokens=1000,
            temperature=0.7,
            messages=[{
                "role": "user",
                "content": prompt
            }]
        )

        # Extract response
        response_text = message.content[0].text.strip()

        # Parse JSON array
        # Remove markdown code blocks if present
        if response_text.startswith('```'):
            response_text = response_text.split('```')[1]
            if response_text.startswith('json'):
                response_text = response_text[4:]
            response_text = response_text.strip()

        improved_steps = json.loads(response_text)

        if not isinstance(improved_steps, list):
            print(f"❌ Invalid response format for scenario {scenario_id}")
            return None

        print(f"\n✅ Generated {len(improved_steps)} improved steps:")
        for i, step in enumerate(improved_steps, 1):
            print(f"  {i}. {step}")

        return {
            'scenario_id': scenario_id,
            'title': title,
            'old_steps': current_steps,
            'new_steps': improved_steps,
            'issues': issues
        }

    except Exception as e:
        print(f"❌ Error processing scenario {scenario_id}: {e}")
        return None

def main():
    """Main review function."""

    # Initialize clients
    supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
    anthropic_client = Anthropic()  # Uses ANTHROPIC_API_KEY env var

    print("🔍 Fetching scenarios from database...")

    # Fetch all scenarios
    response = supabase.table('scenarios').select('*').order('scenario_id').execute()

    if not response.data:
        print("❌ No scenarios found")
        return

    scenarios = response.data
    print(f"✅ Found {len(scenarios)} scenarios")

    # Review scenarios
    improvements = []
    reviewed_count = 0
    issue_count = 0

    for scenario in scenarios:
        scenario_id = scenario.get('scenario_id')
        action_steps = scenario.get('sc_action_steps', [])

        # Quick check for issues
        issues = detect_action_step_issues(action_steps)

        if issues and len(action_steps) > 0:
            issue_count += 1
            print(f"\n⚠️  Scenario {scenario_id}: {scenario.get('sc_title', 'Untitled')}")
            print(f"   Issues: {', '.join(issues[:2])}")  # Show first 2 issues

            # Review with AI (limit to avoid excessive API calls)
            if reviewed_count < 50:  # Process first 50 with issues
                improvement = review_scenario_with_ai(scenario, anthropic_client)
                if improvement:
                    improvements.append(improvement)
                    reviewed_count += 1

    print(f"\n{'='*80}")
    print(f"📊 REVIEW SUMMARY")
    print(f"{'='*80}")
    print(f"Total scenarios: {len(scenarios)}")
    print(f"Scenarios with issues: {issue_count}")
    print(f"Scenarios reviewed by AI: {reviewed_count}")
    print(f"Improvements generated: {len(improvements)}")

    # Save improvements to JSON
    output_file = 'gita_scholar_agent/output/action_steps_improvements.json'
    os.makedirs('gita_scholar_agent/output', exist_ok=True)

    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(improvements, f, indent=2, ensure_ascii=False)

    print(f"\n✅ Improvements saved to: {output_file}")

    # Generate SQL update script
    sql_file = 'gita_scholar_agent/output/update_action_steps.sql'
    with open(sql_file, 'w', encoding='utf-8') as f:
        f.write("-- SQL to update improved action steps\n")
        f.write("-- Generated by review_action_steps.py\n\n")

        for improvement in improvements:
            scenario_id = improvement['scenario_id']
            new_steps = improvement['new_steps']

            # Escape single quotes in SQL
            new_steps_json = json.dumps(new_steps).replace("'", "''")

            f.write(f"-- Scenario {scenario_id}: {improvement['title']}\n")
            f.write(f"UPDATE scenarios SET sc_action_steps = '{new_steps_json}'::jsonb WHERE scenario_id = {scenario_id};\n\n")

    print(f"✅ SQL script saved to: {sql_file}")
    print(f"\n🎯 Next steps:")
    print(f"   1. Review improvements in: {output_file}")
    print(f"   2. Test SQL updates: {sql_file}")
    print(f"   3. Apply to database if satisfied")

if __name__ == "__main__":
    main()
