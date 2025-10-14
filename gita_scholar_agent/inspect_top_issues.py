#!/usr/bin/env python3
"""
Inspect the top scenarios with quality issues in detail.
"""

from supabase import create_client, Client
import json

# Supabase credentials
SUPABASE_URL = "https://wlfwdtdtiedlcczfoslt.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndsZndkdGR0aWVkbGNjemZvc2x0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE4NjQ5MDAsImV4cCI6MjA2NzQ0MDkwMH0.OiWhZled2trJ7eTd8lpQ658B4p-IVsRp2HXHcgAUoFU"

# Top 5 scenarios with most issues
TOP_ISSUES = [
    ("3f5eddb5-384e-4868-8c4f-956700424037", "Child with Learning Differences", 6),
    ("f0bdf74c-0e24-4e0b-9006-c07777d59014", "Debilitating Exam Failure Anxiety", 4),
    ("843ff513-7ae4-4a26-9d95-39f24db56bfa", "Struggling with Self-Harm Thoughts", 2),
    ("c2027e66-bfdc-4c85-a06a-48066e34a2d3", "Exam Pressure and Fear of Disappointing Others", 2),
    ("16afa435-374f-43fe-9e76-8e237bc3bf7e", "Developing Underperforming Team Member", 2),
]


def inspect_scenario(scenario_id: str, title: str, issue_count: int):
    """Inspect a specific scenario in detail."""
    supabase = create_client(SUPABASE_URL, SUPABASE_KEY)

    response = supabase.table('scenarios').select('*').eq('id', scenario_id).execute()

    if not response.data:
        print(f"Scenario {scenario_id} not found!")
        return

    scenario = response.data[0]

    print(f"\n{'='*80}")
    print(f"Scenario: {title}")
    print(f"ID: {scenario_id}")
    print(f"Issues Found: {issue_count}")
    print(f"{'='*80}\n")

    print("ACTION STEPS (sc_action_steps):")
    print("-" * 80)
    action_steps = scenario.get('sc_action_steps', [])

    if action_steps:
        for idx, step in enumerate(action_steps, 1):
            print(f"{idx}. [{len(step):2d} chars] {step}")
    else:
        print("No action steps")

    print("\n" + "=" * 80)


def main():
    """Main entry point."""
    print("DETAILED INSPECTION OF TOP 5 SCENARIOS WITH ISSUES")
    print("=" * 80)

    for scenario_id, title, issue_count in TOP_ISSUES:
        inspect_scenario(scenario_id, title, issue_count)


if __name__ == "__main__":
    main()
