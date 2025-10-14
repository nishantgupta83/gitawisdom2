#!/usr/bin/env python3
"""
Comprehensive Scenario Quality Checker for Supabase Database.
Scans all scenarios and identifies quality issues across all fields.
"""

from supabase import create_client, Client
import json
import re
from datetime import datetime
from typing import List, Dict, Tuple

# Supabase credentials
SUPABASE_URL = "https://wlfwdtdtiedlcczfoslt.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndsZndkdGR0aWVkbGNjemZvc2x0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE4NjQ5MDAsImV4cCI6MjA2NzQ0MDkwMH0.OiWhZled2trJ7eTd8lpQ658B4p-IVsRp2HXHcgAUoFU"


class ScenarioQualityChecker:
    """Check scenarios for quality issues."""

    def __init__(self):
        self.supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
        self.issues = []
        self.stats = {
            'total_scenarios': 0,
            'scenarios_with_issues': 0,
            'total_issues': 0,
            'issues_by_type': {},
            'issues_by_field': {}
        }

    def check_text_quality(self, text: str, field_name: str, scenario_id: str, scenario_title: str) -> List[Dict]:
        """Check text for quality issues."""
        issues = []

        if not text or text == 'N/A':
            return issues

        lines = text.split('\n')

        for line_num, line in enumerate(lines, 1):
            stripped = line.strip()
            if not stripped:
                continue

            # Check for incomplete sentences ending with etc
            if re.search(r'\betc\b[.]?$', stripped):
                issues.append({
                    'scenario_id': scenario_id,
                    'scenario_title': scenario_title,
                    'field': field_name,
                    'issue_type': 'incomplete_sentence_etc',
                    'severity': 'high',
                    'location': f'line {line_num}',
                    'content': stripped[:100],
                    'full_content': stripped
                })

            # Check for sentences ending with open parenthesis
            if stripped.endswith('('):
                issues.append({
                    'scenario_id': scenario_id,
                    'scenario_title': scenario_title,
                    'field': field_name,
                    'issue_type': 'unclosed_parenthesis',
                    'severity': 'high',
                    'location': f'line {line_num}',
                    'content': stripped[-50:],
                    'full_content': stripped
                })

            # Check for sentences ending with comma or 'and'
            if re.search(r'[,]\s*$', stripped) or re.search(r'\band\s*$', stripped, re.IGNORECASE):
                issues.append({
                    'scenario_id': scenario_id,
                    'scenario_title': scenario_title,
                    'field': field_name,
                    'issue_type': 'incomplete_sentence_ending',
                    'severity': 'medium',
                    'location': f'line {line_num}',
                    'content': stripped[-50:],
                    'full_content': stripped
                })

            # Check for very short lines (< 15 chars) that don't look like proper bullets
            if len(stripped) < 15 and not stripped.endswith(('.', ':', '!', '?')):
                if not re.match(r'^\d+\.', stripped):  # Not a numbered list
                    issues.append({
                        'scenario_id': scenario_id,
                        'scenario_title': scenario_title,
                        'field': field_name,
                        'issue_type': 'very_short_line',
                        'severity': 'medium',
                        'location': f'line {line_num}',
                        'content': stripped,
                        'full_content': stripped
                    })

            # Check for placeholder text
            placeholders = ['TODO', 'TBD', 'FIXME', 'XXX', '[insert', '[add']
            for placeholder in placeholders:
                if placeholder.lower() in stripped.lower():
                    issues.append({
                        'scenario_id': scenario_id,
                        'scenario_title': scenario_title,
                        'field': field_name,
                        'issue_type': 'placeholder_text',
                        'severity': 'critical',
                        'location': f'line {line_num}',
                        'content': stripped[:100],
                        'full_content': stripped
                    })

        return issues

    def check_action_steps(self, action_steps: List, scenario_id: str, scenario_title: str) -> List[Dict]:
        """Check action steps array for quality issues."""
        issues = []

        if not action_steps:
            return issues

        for idx, step in enumerate(action_steps, 1):
            if not isinstance(step, str):
                continue

            stripped = step.strip()

            # Check for very short steps (< 10 chars)
            if len(stripped) < 10:
                issues.append({
                    'scenario_id': scenario_id,
                    'scenario_title': scenario_title,
                    'field': 'sc_action_steps',
                    'issue_type': 'very_short_action_step',
                    'severity': 'high',
                    'location': f'step {idx}',
                    'content': stripped,
                    'full_content': stripped
                })

            # Check for fragments that look like they're part of previous step
            fragment_patterns = [
                r'^etc[.]?\)?\s*$',  # "etc.)" or "etc"
                r'^[a-z]+\)$',  # single word with closing paren like "kindness)"
                r'^[a-z]{3,10}$',  # single short word
                r'^\([a-z]+$',  # starts with open paren
            ]

            for pattern in fragment_patterns:
                if re.match(pattern, stripped):
                    issues.append({
                        'scenario_id': scenario_id,
                        'scenario_title': scenario_title,
                        'field': 'sc_action_steps',
                        'issue_type': 'fragment_action_step',
                        'severity': 'critical',
                        'location': f'step {idx}',
                        'content': stripped,
                        'full_content': stripped,
                        'note': 'Likely a fragment from previous step'
                    })

            # Check for incomplete sentences in steps
            if re.search(r'\betc\b[.]?$', stripped):
                issues.append({
                    'scenario_id': scenario_id,
                    'scenario_title': scenario_title,
                    'field': 'sc_action_steps',
                    'issue_type': 'incomplete_action_step',
                    'severity': 'high',
                    'location': f'step {idx}',
                    'content': stripped,
                    'full_content': stripped
                })

            # Check for unclosed parentheses
            open_count = stripped.count('(')
            close_count = stripped.count(')')
            if open_count != close_count:
                issues.append({
                    'scenario_id': scenario_id,
                    'scenario_title': scenario_title,
                    'field': 'sc_action_steps',
                    'issue_type': 'unbalanced_parentheses',
                    'severity': 'high',
                    'location': f'step {idx}',
                    'content': stripped,
                    'full_content': stripped,
                    'note': f'Open: {open_count}, Close: {close_count}'
                })

        return issues

    def check_scenario(self, scenario: Dict) -> List[Dict]:
        """Check a single scenario for all quality issues."""
        all_issues = []

        scenario_id = scenario.get('id', 'unknown')
        scenario_title = scenario.get('sc_title', 'Untitled')

        # Check main text fields
        text_fields = [
            ('sc_title', scenario.get('sc_title')),
            ('sc_description', scenario.get('sc_description')),
            ('sc_heart_response', scenario.get('sc_heart_response')),
            ('sc_duty_response', scenario.get('sc_duty_response')),
            ('sc_gita_wisdom', scenario.get('sc_gita_wisdom')),
        ]

        for field_name, field_value in text_fields:
            if field_value:
                issues = self.check_text_quality(field_value, field_name, scenario_id, scenario_title)
                all_issues.extend(issues)

        # Check action steps
        action_steps = scenario.get('sc_action_steps', [])
        if action_steps:
            issues = self.check_action_steps(action_steps, scenario_id, scenario_title)
            all_issues.extend(issues)

        return all_issues

    def update_stats(self, issues: List[Dict]):
        """Update statistics with found issues."""
        if issues:
            self.stats['scenarios_with_issues'] += 1
            self.stats['total_issues'] += len(issues)

            for issue in issues:
                issue_type = issue['issue_type']
                field = issue['field']

                self.stats['issues_by_type'][issue_type] = \
                    self.stats['issues_by_type'].get(issue_type, 0) + 1

                self.stats['issues_by_field'][field] = \
                    self.stats['issues_by_field'].get(field, 0) + 1

    def scan_all_scenarios(self, batch_size: int = 100):
        """Scan all scenarios in the database."""
        print("Starting database scan...")
        print(f"Timestamp: {datetime.now().isoformat()}")
        print("=" * 80)

        offset = 0
        total_fetched = 0

        while True:
            try:
                # Fetch batch of scenarios
                response = self.supabase.table('scenarios').select('*').range(offset, offset + batch_size - 1).execute()

                if not response.data:
                    break

                batch_size_actual = len(response.data)
                total_fetched += batch_size_actual

                print(f"\nProcessing scenarios {offset + 1} to {offset + batch_size_actual}...")

                for scenario in response.data:
                    self.stats['total_scenarios'] += 1
                    issues = self.check_scenario(scenario)

                    if issues:
                        self.issues.extend(issues)
                        self.update_stats(issues)

                if batch_size_actual < batch_size:
                    # Last batch
                    break

                offset += batch_size

            except Exception as e:
                print(f"Error fetching scenarios at offset {offset}: {e}")
                break

        print(f"\n✅ Scan complete. Processed {self.stats['total_scenarios']} scenarios")

    def generate_report(self) -> str:
        """Generate quality report."""
        report_lines = []

        # Header
        report_lines.append("=" * 80)
        report_lines.append("SCENARIO QUALITY REPORT")
        report_lines.append("=" * 80)
        report_lines.append(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        report_lines.append("")

        # Summary statistics
        report_lines.append("SUMMARY STATISTICS")
        report_lines.append("-" * 80)
        report_lines.append(f"Total Scenarios Scanned: {self.stats['total_scenarios']}")
        report_lines.append(f"Scenarios with Issues: {self.stats['scenarios_with_issues']}")
        report_lines.append(f"Total Issues Found: {self.stats['total_issues']}")
        report_lines.append(f"Issue Rate: {(self.stats['scenarios_with_issues'] / max(self.stats['total_scenarios'], 1) * 100):.1f}%")
        report_lines.append("")

        # Issues by type
        if self.stats['issues_by_type']:
            report_lines.append("ISSUES BY TYPE")
            report_lines.append("-" * 80)
            sorted_types = sorted(self.stats['issues_by_type'].items(), key=lambda x: x[1], reverse=True)
            for issue_type, count in sorted_types:
                report_lines.append(f"  {issue_type}: {count}")
            report_lines.append("")

        # Issues by field
        if self.stats['issues_by_field']:
            report_lines.append("ISSUES BY FIELD")
            report_lines.append("-" * 80)
            sorted_fields = sorted(self.stats['issues_by_field'].items(), key=lambda x: x[1], reverse=True)
            for field, count in sorted_fields:
                report_lines.append(f"  {field}: {count}")
            report_lines.append("")

        # Detailed issues
        if self.issues:
            report_lines.append("DETAILED ISSUES")
            report_lines.append("=" * 80)

            # Group by scenario
            issues_by_scenario = {}
            for issue in self.issues:
                scenario_id = issue['scenario_id']
                if scenario_id not in issues_by_scenario:
                    issues_by_scenario[scenario_id] = []
                issues_by_scenario[scenario_id].append(issue)

            # Sort by number of issues
            sorted_scenarios = sorted(issues_by_scenario.items(), key=lambda x: len(x[1]), reverse=True)

            for idx, (scenario_id, scenario_issues) in enumerate(sorted_scenarios, 1):
                first_issue = scenario_issues[0]
                report_lines.append(f"\n{idx}. Scenario: {first_issue['scenario_title']}")
                report_lines.append(f"   ID: {scenario_id}")
                report_lines.append(f"   Issues: {len(scenario_issues)}")
                report_lines.append("")

                for issue in scenario_issues:
                    severity_emoji = {
                        'critical': '🔴',
                        'high': '🟠',
                        'medium': '🟡',
                        'low': '🟢'
                    }.get(issue['severity'], '⚪')

                    report_lines.append(f"   {severity_emoji} [{issue['severity'].upper()}] {issue['issue_type']}")
                    report_lines.append(f"      Field: {issue['field']}")
                    report_lines.append(f"      Location: {issue['location']}")
                    report_lines.append(f"      Content: {issue['content']}")
                    if issue.get('note'):
                        report_lines.append(f"      Note: {issue['note']}")
                    report_lines.append("")

        return "\n".join(report_lines)

    def save_report(self, filename: str = "output/scenario_quality_report.txt"):
        """Save report to file."""
        report = self.generate_report()

        with open(filename, 'w', encoding='utf-8') as f:
            f.write(report)

        print(f"\n✅ Report saved to: {filename}")

        # Also save JSON for programmatic access
        json_filename = filename.replace('.txt', '.json')
        with open(json_filename, 'w', encoding='utf-8') as f:
            json.dump({
                'stats': self.stats,
                'issues': self.issues
            }, f, indent=2, ensure_ascii=False)

        print(f"✅ JSON data saved to: {json_filename}")

        return report

    def get_top_issues(self, limit: int = 10) -> List[Tuple[str, str, int]]:
        """Get top N scenarios with most issues."""
        issues_by_scenario = {}

        for issue in self.issues:
            scenario_id = issue['scenario_id']
            scenario_title = issue['scenario_title']

            if scenario_id not in issues_by_scenario:
                issues_by_scenario[scenario_id] = {
                    'title': scenario_title,
                    'count': 0
                }

            issues_by_scenario[scenario_id]['count'] += 1

        # Sort by count
        sorted_scenarios = sorted(
            issues_by_scenario.items(),
            key=lambda x: x[1]['count'],
            reverse=True
        )

        return [(sid, data['title'], data['count']) for sid, data in sorted_scenarios[:limit]]


def main():
    """Main entry point."""
    print("Scenario Quality Checker")
    print("=" * 80)

    checker = ScenarioQualityChecker()

    # Scan all scenarios
    checker.scan_all_scenarios()

    # Generate and save report
    report = checker.save_report()

    # Print summary
    print("\n" + "=" * 80)
    print("SCAN SUMMARY")
    print("=" * 80)
    print(f"Total Scenarios: {checker.stats['total_scenarios']}")
    print(f"Scenarios with Issues: {checker.stats['scenarios_with_issues']}")
    print(f"Total Issues: {checker.stats['total_issues']}")

    # Print top issues
    print("\nTOP 10 SCENARIOS WITH MOST ISSUES:")
    print("-" * 80)
    top_issues = checker.get_top_issues(10)
    for idx, (scenario_id, title, count) in enumerate(top_issues, 1):
        print(f"{idx}. {title}")
        print(f"   ID: {scenario_id}")
        print(f"   Issues: {count}")
        print()


if __name__ == "__main__":
    main()
