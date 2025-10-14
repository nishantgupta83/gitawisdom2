#!/usr/bin/env python3
"""
Test the quality checker on a small sample before running full scan.
"""

from scenario_quality_checker import ScenarioQualityChecker
from supabase import create_client, Client

# Supabase credentials
SUPABASE_URL = "https://wlfwdtdtiedlcczfoslt.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndsZndkdGR0aWVkbGNjemZvc2x0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE4NjQ5MDAsImV4cCI6MjA2NzQ0MDkwMH0.OiWhZled2trJ7eTd8lpQ658B4p-IVsRp2HXHcgAUoFU"


def test_sample():
    """Test on a small sample of 10 scenarios."""
    print("Testing quality checker on sample of 10 scenarios...")
    print("=" * 80)

    checker = ScenarioQualityChecker()

    # Fetch just 10 scenarios
    supabase = create_client(SUPABASE_URL, SUPABASE_KEY)
    response = supabase.table('scenarios').select('*').limit(10).execute()

    if not response.data:
        print("No scenarios found!")
        return

    print(f"Fetched {len(response.data)} scenarios for testing\n")

    for scenario in response.data:
        checker.stats['total_scenarios'] += 1
        issues = checker.check_scenario(scenario)

        if issues:
            checker.issues.extend(issues)
            checker.update_stats(issues)
            print(f"✗ {scenario.get('sc_title')}: {len(issues)} issues")
        else:
            print(f"✓ {scenario.get('sc_title')}: No issues")

    print("\n" + "=" * 80)
    print("SAMPLE TEST RESULTS")
    print("=" * 80)
    print(f"Scenarios checked: {checker.stats['total_scenarios']}")
    print(f"Scenarios with issues: {checker.stats['scenarios_with_issues']}")
    print(f"Total issues: {checker.stats['total_issues']}")

    if checker.issues:
        print("\nSample issues found:")
        for issue in checker.issues[:5]:  # Show first 5 issues
            print(f"\n- {issue['issue_type']} in {issue['field']}")
            print(f"  Scenario: {issue['scenario_title']}")
            print(f"  Content: {issue['content']}")

    print("\n✅ Test complete. Script is working correctly.")
    print("Ready to run full database scan.")


if __name__ == "__main__":
    test_sample()
