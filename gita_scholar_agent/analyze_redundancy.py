#!/usr/bin/env python3
"""
Analyze and report on redundant action steps across all scenarios.
Generates a comprehensive report and list of scenarios needing review.
"""

import json
from supabase import create_client, Client
from collections import defaultdict

# Supabase credentials
SUPABASE_URL = "https://wlfwdtdtiedlcczfoslt.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndsZndkdGR0aWVkbGNjemZvc2x0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE4NjQ5MDAsImV4cCI6MjA2NzQ0MDkwMH0.OiWhZled2trJ7eTd8lpQ658B4p-IVsRp2HXHcgAUoFU"

def analyze_action_steps(scenario):
    """Analyze action steps for quality issues."""
    scenario_id = scenario.get('scenario_id')
    action_steps = scenario.get('sc_action_steps', [])

    if not action_steps:
        return {
            'scenario_id': scenario_id,
            'title': scenario.get('sc_title', ''),
            'issues': ['Missing action steps'],
            'severity': 'high'
        }

    issues = []
    severity = 'low'

    # Pattern detection
    redundant_patterns = {
        'ensuring_full_context': 0,
        'take_time_to': 0,
        'understand_implications': 0,
        'make_default_choices': 0,
        'research_thoroughly': 0
    }

    for step in action_steps:
        if not isinstance(step, str):
            continue

        step_lower = step.lower()

        # Check for common redundant phrases
        if 'ensuring you understand the full context and implications' in step_lower:
            redundant_patterns['ensuring_full_context'] += 1
        if step.startswith('Take time to'):
            redundant_patterns['take_time_to'] += 1
        if 'understand the implications' in step_lower or 'understand implications' in step_lower:
            redundant_patterns['understand_implications'] += 1
        if 'make default choices' in step_lower:
            redundant_patterns['make_default_choices'] += 1
        if 'research' in step_lower and 'thoroughly' in step_lower:
            redundant_patterns['research_thoroughly'] += 1

        # Check for too short/vague
        if len(step) < 20:
            issues.append(f"Very short step: '{step}'")

        # Check for too long/complex
        if len(step) > 200 or step.count(',') > 4:
            issues.append(f"Overly complex step: '{step[:60]}...'")

    # Report redundancy
    total_redundant = 0
    for pattern, count in redundant_patterns.items():
        if count >= 3:  # 3 or more steps use same pattern
            total_redundant += count
            pattern_name = pattern.replace('_', ' ').title()
            issues.append(f"{count}/{len(action_steps)} steps use '{pattern_name}' pattern")
            severity = 'high'
        elif count >= 2:
            total_redundant += count
            pattern_name = pattern.replace('_', ' ').title()
            issues.append(f"{count}/{len(action_steps)} steps use '{pattern_name}' pattern")
            if severity == 'low':
                severity = 'medium'

    if not issues:
        return None

    return {
        'scenario_id': scenario_id,
        'title': scenario.get('sc_title', ''),
        'category': scenario.get('sc_category', ''),
        'chapter': scenario.get('sc_chapter', 0),
        'issues': issues,
        'severity': severity,
        'redundant_count': total_redundant,
        'total_steps': len(action_steps),
        'current_steps': action_steps
    }

def main():
    """Main analysis function."""
    print("🔍 Analyzing scenarios for action step quality issues...")

    # Initialize Supabase client
    supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

    # Fetch all scenarios
    response = supabase.table('scenarios').select('*').order('scenario_id').execute()

    if not response.data:
        print("❌ No scenarios found")
        return

    scenarios = response.data
    print(f"✅ Found {len(scenarios)} scenarios to analyze\n")

    # Analyze each scenario
    problems = []
    severity_counts = defaultdict(int)

    for scenario in scenarios:
        result = analyze_action_steps(scenario)
        if result:
            problems.append(result)
            severity_counts[result['severity']] += 1

    # Generate statistics
    print(f"\n{'='*80}")
    print(f"📊 ANALYSIS SUMMARY")
    print(f"{'='*80}")
    print(f"Total scenarios analyzed: {len(scenarios)}")
    print(f"Scenarios with issues: {len(problems)}")
    print(f"  - High severity (major redundancy): {severity_counts['high']}")
    print(f"  - Medium severity (some redundancy): {severity_counts['medium']}")
    print(f"  - Low severity (minor issues): {severity_counts['low']}")
    print(f"\n✅ Clean scenarios: {len(scenarios) - len(problems)}")

    # Sort by severity and scenario_id
    severity_order = {'high': 0, 'medium': 1, 'low': 2}
    problems.sort(key=lambda x: (severity_order[x['severity']], x['scenario_id']))

    # Save detailed report
    output_file = 'gita_scholar_agent/output/action_steps_analysis.json'
    import os
    os.makedirs('gita_scholar_agent/output', exist_ok=True)

    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump({
            'summary': {
                'total_scenarios': len(scenarios),
                'problematic_scenarios': len(problems),
                'severity_breakdown': dict(severity_counts)
            },
            'problems': problems
        }, f, indent=2, ensure_ascii=False)

    print(f"\n✅ Full analysis saved to: {output_file}")

    # Generate human-readable report
    report_file = 'gita_scholar_agent/output/REDUNDANCY_REPORT.md'
    with open(report_file, 'w', encoding='utf-8') as f:
        f.write("# Action Steps Redundancy Analysis Report\n\n")
        f.write(f"**Generated:** {json.dumps(problems[0]['title']) if problems else 'No issues found'}\n\n")
        f.write(f"## Summary Statistics\n\n")
        f.write(f"- **Total Scenarios:** {len(scenarios)}\n")
        f.write(f"- **Problematic Scenarios:** {len(problems)}\n")
        f.write(f"- **High Severity:** {severity_counts['high']}\n")
        f.write(f"- **Medium Severity:** {severity_counts['medium']}\n")
        f.write(f"- **Low Severity:** {severity_counts['low']}\n\n")

        # Group by severity
        for severity in ['high', 'medium', 'low']:
            severity_problems = [p for p in problems if p['severity'] == severity]
            if not severity_problems:
                continue

            f.write(f"\n## {severity.upper()} Severity Issues ({len(severity_problems)} scenarios)\n\n")

            for idx, problem in enumerate(severity_problems[:20], 1):  # Show top 20 per severity
                f.write(f"### {idx}. Scenario {problem['scenario_id']}: {problem['title']}\n\n")
                f.write(f"- **Category:** {problem['category']}\n")
                f.write(f"- **Chapter:** {problem['chapter']}\n")
                f.write(f"- **Redundant Steps:** {problem['redundant_count']}/{problem['total_steps']}\n\n")
                f.write(f"**Issues:**\n")
                for issue in problem['issues']:
                    f.write(f"- {issue}\n")
                f.write(f"\n**Current Action Steps:**\n")
                for i, step in enumerate(problem['current_steps'], 1):
                    f.write(f"{i}. {step}\n")
                f.write("\n---\n\n")

            if len(severity_problems) > 20:
                f.write(f"\n*...and {len(severity_problems) - 20} more {severity} severity issues*\n\n")

    print(f"✅ Human-readable report saved to: {report_file}")

    # Print top 10 worst offenders
    print(f"\n{'='*80}")
    print(f"🔴 TOP 10 WORST OFFENDERS")
    print(f"{'='*80}\n")

    for idx, problem in enumerate(problems[:10], 1):
        print(f"{idx}. Scenario {problem['scenario_id']}: {problem['title']}")
        print(f"   Severity: {problem['severity'].upper()} | Redundant: {problem['redundant_count']}/{problem['total_steps']} steps")
        print(f"   Issues: {', '.join(problem['issues'][:2])}")
        if len(problem['current_steps']) > 0:
            print(f"   Example: \"{problem['current_steps'][0][:80]}...\"")
        print()

    print(f"\n{'='*80}")
    print(f"📋 NEXT STEPS:")
    print(f"{'='*80}")
    print(f"1. Review the report: {report_file}")
    print(f"2. Check full data: {output_file}")
    print(f"3. Prioritize fixing HIGH severity issues first ({severity_counts['high']} scenarios)")
    print(f"4. Consider using AI to generate improved action steps")

if __name__ == "__main__":
    main()
