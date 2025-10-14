#!/usr/bin/env python3
"""
Enhanced PostgreSQL UPDATE statement generator to fix broken scenario data.

This script:
1. Reads the quality report JSON
2. Fetches current sc_action_steps from Supabase
3. Reconstructs correct arrays by merging fragments
4. Generates SQL UPDATE statements with proper escaping
5. Creates both SQL file and human-readable before/after report
"""

from supabase import create_client, Client
import json
import os
import re
from pathlib import Path
from datetime import datetime
from typing import List, Dict, Tuple

# Supabase credentials
SUPABASE_URL = "https://wlfwdtdtiedlcczfoslt.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndsZndkdGR0aWVkbGNjemZvc2x0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE4NjQ5MDAsImV4cCI6MjA2NzQ0MDkwMH0.OiWhZled2trJ7eTd8lpQ658B4p-IVsRp2HXHcgAUoFU"


class ScenarioFixGenerator:
    """Generate SQL fixes for broken scenario data."""

    def __init__(self):
        self.supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
        self.errors = []

    def load_quality_report(self) -> Dict:
        """Load the quality report JSON."""
        report_path = Path("output/scenario_quality_report.json")
        if not report_path.exists():
            raise FileNotFoundError(
                "Quality report not found at output/scenario_quality_report.json. "
                "Run scenario_quality_checker.py first."
            )

        with open(report_path, 'r', encoding='utf-8') as f:
            return json.load(f)

    def group_issues_by_scenario(self, issues: List[Dict]) -> Dict[str, Dict]:
        """Group issues by scenario_id with metadata."""
        scenarios = {}

        for issue in issues:
            scenario_id = issue['scenario_id']

            if scenario_id not in scenarios:
                scenarios[scenario_id] = {
                    'scenario_id': scenario_id,
                    'scenario_title': issue['scenario_title'],
                    'issues': []
                }

            scenarios[scenario_id]['issues'].append(issue)

        return scenarios

    def fetch_scenario_data(self, scenario_id: str) -> Dict:
        """Fetch current scenario data from Supabase."""
        try:
            response = self.supabase.table('scenarios').select(
                'id, sc_title, sc_action_steps'
            ).eq('id', scenario_id).execute()

            if response.data and len(response.data) > 0:
                return response.data[0]
            else:
                raise ValueError(f"Scenario not found: {scenario_id}")

        except Exception as e:
            error_msg = f"Error fetching scenario {scenario_id}: {e}"
            self.errors.append(error_msg)
            raise

    def reconstruct_action_steps(self, action_steps: List[str], issues: List[Dict]) -> List[str]:
        """
        Reconstruct properly formatted action steps by merging fragments.

        Logic:
        1. Identify problem step indices from issues
        2. Merge steps with unbalanced parentheses with following fragments
        3. Merge very short fragments with previous step
        4. Handle special cases like "etc.)", list continuations ("and X"), etc.
        """
        if not action_steps:
            return []

        # Create a set of problematic step indices (0-based)
        problem_indices = set()
        for issue in issues:
            if 'location' in issue and 'step' in issue['location']:
                # Extract step number from "step N" and convert to 0-based index
                step_num = int(issue['location'].split()[-1])
                problem_indices.add(step_num - 1)

        fixed_steps = []
        i = 0

        while i < len(action_steps):
            step = action_steps[i].strip()

            # Check parentheses balance
            open_count = step.count('(')
            close_count = step.count(')')

            # Case 1: Step has unbalanced opening parenthesis - merge with following
            if open_count > close_count:
                merged = step
                j = i + 1

                # Keep merging until parentheses are balanced or we run out of steps
                while j < len(action_steps) and open_count > close_count:
                    next_step = action_steps[j].strip()

                    # Check if next step is just a fragment
                    if len(next_step) < 15 or next_step.startswith(')'):
                        # It's a fragment, merge it
                        if next_step.startswith(')') or next_step.endswith(')'):
                            # Closing fragment - append directly
                            merged += ', ' + next_step
                        else:
                            # Middle fragment - add with comma
                            merged += ', ' + next_step
                    else:
                        # It's a complete step, merge with comma
                        merged += ', ' + next_step

                    open_count += next_step.count('(')
                    close_count += next_step.count(')')
                    j += 1

                fixed_steps.append(merged)
                i = j

            # Case 2: Step starts with "or" or "and" (list continuation)
            elif re.match(r'^(or|and)\s+', step, re.IGNORECASE):
                # Merge with previous step
                if fixed_steps:
                    # Check if previous step ends with comma
                    if fixed_steps[-1].endswith(','):
                        fixed_steps[-1] = fixed_steps[-1] + ' ' + step
                    else:
                        fixed_steps[-1] = fixed_steps[-1] + ', ' + step
                else:
                    # Can't merge, keep it
                    fixed_steps.append(step)
                i += 1

            # Case 3: Very short step that's likely a fragment
            elif len(step) < 15 and i in problem_indices:
                # Check if it's just a single word or very short phrase
                if fixed_steps and (len(step.split()) <= 2 or step.startswith('not ')):
                    # Merge with previous step
                    # Check if previous step ends with certain patterns
                    prev = fixed_steps[-1]
                    if prev.endswith(':') or prev.endswith('like') or not prev.endswith(('.', '!', '?')):
                        # Likely continuation
                        fixed_steps[-1] = prev + ', ' + step
                    else:
                        # Standalone fragment, keep it
                        fixed_steps.append(step)
                else:
                    fixed_steps.append(step)
                i += 1

            # Case 4: Step starting with closing paren or just punctuation
            elif step.startswith(')') or re.match(r'^[a-z]+\)$', step):
                # Merge with previous step
                if fixed_steps:
                    fixed_steps[-1] = fixed_steps[-1] + ' ' + step
                else:
                    # Can't merge, keep it
                    fixed_steps.append(step)
                i += 1

            # Case 5: Normal step
            else:
                fixed_steps.append(step)
                i += 1

        return fixed_steps

    def escape_sql_string(self, s: str) -> str:
        """Escape string for PostgreSQL."""
        if s is None:
            return 'NULL'
        # Escape single quotes by doubling them
        escaped = s.replace("'", "''")
        return f"'{escaped}'"

    def generate_sql_update(
        self,
        scenario_id: str,
        scenario_title: str,
        fixed_steps: List[str]
    ) -> str:
        """Generate PostgreSQL UPDATE statement."""

        # Build ARRAY[] string
        escaped_steps = [self.escape_sql_string(step) for step in fixed_steps]
        array_str = 'ARRAY[' + ', '.join(escaped_steps) + ']'

        # Generate SQL with comment
        sql = f"""-- Fix: {scenario_title}
-- Scenario ID: {scenario_id}
-- Fixed steps: {len(fixed_steps)}
UPDATE scenarios
SET sc_action_steps = {array_str},
    updated_at = NOW()
WHERE id = '{scenario_id}';

"""
        return sql

    def process_scenario(
        self,
        scenario_id: str,
        scenario_title: str,
        issues: List[Dict]
    ) -> Tuple[str, List[str], List[str]]:
        """
        Process a single scenario and generate fix.

        Returns: (sql_statement, original_steps, fixed_steps)
        """
        # Fetch current data from Supabase
        scenario_data = self.fetch_scenario_data(scenario_id)
        original_steps = scenario_data.get('sc_action_steps', [])

        if not original_steps:
            raise ValueError(f"No action steps found for scenario {scenario_id}")

        # Reconstruct the correct steps
        fixed_steps = self.reconstruct_action_steps(original_steps, issues)

        # Generate SQL
        sql = self.generate_sql_update(scenario_id, scenario_title, fixed_steps)

        return sql, original_steps, fixed_steps

    def generate_fixes(self) -> Tuple[int, int, List[str]]:
        """
        Generate all fix SQL statements.

        Returns: (scenarios_fixed, total_updates, error_list)
        """
        print("="*80)
        print("SCENARIO FIX SQL GENERATOR")
        print("="*80)
        print()

        # Load quality report
        print("Loading quality report...")
        report = self.load_quality_report()

        issues = report.get('issues', [])
        print(f"Found {len(issues)} issues")

        # Group by scenario
        scenarios = self.group_issues_by_scenario(issues)
        print(f"Affecting {len(scenarios)} scenarios")
        print()

        # Create output directory
        output_dir = Path("output")
        output_dir.mkdir(exist_ok=True)

        sql_file = output_dir / "fix_scenarios.sql"
        report_file = output_dir / "fix_scenarios_report.txt"

        scenarios_fixed = 0
        total_updates = 0

        with open(sql_file, 'w', encoding='utf-8') as sql_out, \
             open(report_file, 'w', encoding='utf-8') as report_out:

            # Write SQL header
            sql_out.write(f"""-- ============================================================================
-- SCENARIO QUALITY FIX SQL STATEMENTS
-- ============================================================================
-- Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
-- Purpose: Fix fragmented sc_action_steps in scenarios table
-- Issues Fixed: Unbalanced parentheses, fragmented steps, incomplete sentences
--
-- IMPORTANT: Review each UPDATE statement before executing!
-- ============================================================================

BEGIN;

""")

            # Write report header
            report_out.write("="*80 + "\n")
            report_out.write("SCENARIO FIX REPORT\n")
            report_out.write("="*80 + "\n")
            report_out.write(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
            report_out.write(f"Total scenarios to fix: {len(scenarios)}\n")
            report_out.write("="*80 + "\n\n")

            # Process each scenario
            for idx, (scenario_id, scenario_info) in enumerate(scenarios.items(), 1):
                scenario_title = scenario_info['scenario_title']
                scenario_issues = scenario_info['issues']

                print(f"{idx}. Processing: {scenario_title}")
                print(f"   Issues: {len(scenario_issues)}")

                try:
                    # Generate fix
                    sql, original_steps, fixed_steps = self.process_scenario(
                        scenario_id, scenario_title, scenario_issues
                    )

                    # Write SQL
                    sql_out.write(sql)
                    total_updates += 1

                    # Write report
                    report_out.write(f"\n{'='*80}\n")
                    report_out.write(f"{idx}. {scenario_title}\n")
                    report_out.write(f"{'='*80}\n")
                    report_out.write(f"Scenario ID: {scenario_id}\n")
                    report_out.write(f"Issues: {len(scenario_issues)}\n\n")

                    # List issues
                    report_out.write("ISSUES FOUND:\n")
                    for issue in scenario_issues:
                        report_out.write(f"  - {issue['issue_type']} at {issue['location']}: {issue['content']}\n")

                    report_out.write(f"\nORIGINAL ACTION STEPS ({len(original_steps)}):\n")
                    for i, step in enumerate(original_steps, 1):
                        report_out.write(f"  {i}. {step}\n")

                    report_out.write(f"\nFIXED ACTION STEPS ({len(fixed_steps)}):\n")
                    for i, step in enumerate(fixed_steps, 1):
                        report_out.write(f"  {i}. {step}\n")

                    report_out.write("\n")

                    scenarios_fixed += 1
                    print(f"   ✓ Generated SQL fix")

                except Exception as e:
                    error_msg = f"ERROR processing scenario {scenario_title}: {e}"
                    print(f"   ✗ {error_msg}")
                    self.errors.append(error_msg)

                    sql_out.write(f"-- {error_msg}\n\n")
                    report_out.write(f"\n⚠️ {error_msg}\n\n")

                print()

            # Write SQL footer
            sql_out.write(f"""
COMMIT;

-- ============================================================================
-- END OF FIX STATEMENTS
-- ============================================================================
-- Successfully generated {total_updates} UPDATE statements
-- Scenarios fixed: {scenarios_fixed} out of {len(scenarios)}
-- Review the fix_scenarios_report.txt file for before/after comparison
-- ============================================================================
""")

            # Write report summary
            report_out.write("\n" + "="*80 + "\n")
            report_out.write("SUMMARY\n")
            report_out.write("="*80 + "\n")
            report_out.write(f"Total scenarios processed: {len(scenarios)}\n")
            report_out.write(f"Successfully fixed: {scenarios_fixed}\n")
            report_out.write(f"Errors encountered: {len(self.errors)}\n")
            report_out.write(f"Total UPDATE statements: {total_updates}\n")
            report_out.write(f"Total issues resolved: {len(issues)}\n")

            if self.errors:
                report_out.write("\nERRORS:\n")
                for error in self.errors:
                    report_out.write(f"  - {error}\n")

        print("="*80)
        print("✓ Generation complete!")
        print("="*80)
        print(f"SQL file: {sql_file.absolute()}")
        print(f"Report file: {report_file.absolute()}")
        print(f"Scenarios fixed: {scenarios_fixed}")
        print(f"Total UPDATE statements: {total_updates}")

        if self.errors:
            print(f"\n⚠️  Errors encountered: {len(self.errors)}")
            for error in self.errors:
                print(f"  - {error}")

        print("="*80)

        return scenarios_fixed, total_updates, self.errors


def main():
    """Main entry point."""
    try:
        generator = ScenarioFixGenerator()
        scenarios_fixed, total_updates, errors = generator.generate_fixes()

        # Print summary
        print("\nSUMMARY:")
        print(f"  Scenarios fixed: {scenarios_fixed}")
        print(f"  UPDATE statements generated: {total_updates}")
        print(f"  Errors: {len(errors)}")

        if errors:
            print("\n⚠️  Some scenarios could not be fixed. See output/fix_scenarios_report.txt for details.")
            return 1
        else:
            print("\n✓ All scenarios processed successfully!")
            print("\nNext steps:")
            print("  1. Review output/fix_scenarios_report.txt for before/after comparison")
            print("  2. Review output/fix_scenarios.sql for SQL statements")
            print("  3. Execute the SQL file in your PostgreSQL database")
            print("  4. Re-run scenario_quality_checker.py to verify fixes")
            return 0

    except Exception as e:
        print(f"\n✗ Fatal error: {e}")
        import traceback
        traceback.print_exc()
        return 1


if __name__ == '__main__':
    exit(main())
