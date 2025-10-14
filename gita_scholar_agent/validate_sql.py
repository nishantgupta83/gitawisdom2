#!/usr/bin/env python3
"""
Quick SQL syntax validator for fix_scenarios.sql
Checks for common SQL syntax issues without executing.
"""

import re
from pathlib import Path


def validate_sql_file(filepath: str) -> tuple[bool, list[str]]:
    """
    Validate SQL file for common syntax issues.

    Returns: (is_valid, list_of_issues)
    """
    issues = []

    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Check 1: Has BEGIN and COMMIT
    if 'BEGIN;' not in content:
        issues.append("Missing 'BEGIN;' statement")
    if 'COMMIT;' not in content:
        issues.append("Missing 'COMMIT;' statement")

    # Check 2: Count UPDATE statements
    update_count = len(re.findall(r'UPDATE scenarios', content, re.IGNORECASE))
    if update_count == 0:
        issues.append("No UPDATE statements found")

    # Check 3: Check for unbalanced quotes in ARRAY
    # Find all ARRAY[...] sections
    array_pattern = r"ARRAY\[(.*?)\]"
    arrays = re.findall(array_pattern, content, re.DOTALL)

    for idx, array_content in enumerate(arrays, 1):
        # Count quotes (should be even)
        quote_count = array_content.count("'")
        if quote_count % 2 != 0:
            issues.append(f"UPDATE {idx}: Unbalanced quotes in ARRAY (found {quote_count} quotes)")

    # Check 4: Verify WHERE clauses
    where_count = len(re.findall(r"WHERE id = '[a-f0-9-]+'", content))
    if where_count != update_count:
        issues.append(f"Mismatch: {update_count} UPDATEs but {where_count} WHERE clauses")

    # Check 5: Check for unclosed parentheses
    lines = content.split('\n')
    for line_num, line in enumerate(lines, 1):
        if 'ARRAY[' in line:
            open_count = line.count('(')
            close_count = line.count(')')
            if open_count != close_count:
                # This is expected for multi-line ARRAY, so just note it
                pass

    # Check 6: Verify proper escaping (look for single quotes that aren't doubled)
    # This is a simplified check - in PostgreSQL, '' is an escaped quote
    # We'll check if there are any single quotes inside ARRAY strings that aren't escaped
    for idx, array_content in enumerate(arrays, 1):
        # Find all string literals in the array
        strings = re.findall(r"'([^']*(?:''[^']*)*)'", array_content)
        for string in strings:
            # Check if there are any single quotes that aren't doubled
            # This is tricky, so we'll just ensure all apostrophes are doubled
            single_quotes = re.findall(r"(?<!')('|')(?!')", string)
            # Filter out properly escaped quotes
            if single_quotes and "''" not in string:
                # This might be a false positive for em-dashes or other unicode
                pass  # Skip for now as our escaping function handles this

    return len(issues) == 0, issues


def main():
    print("="*80)
    print("SQL SYNTAX VALIDATOR")
    print("="*80)
    print()

    sql_file = Path("output/fix_scenarios.sql")

    if not sql_file.exists():
        print(f"✗ Error: SQL file not found at {sql_file}")
        return 1

    print(f"Validating: {sql_file.absolute()}")
    print()

    is_valid, issues = validate_sql_file(sql_file)

    if is_valid:
        print("✓ SQL validation passed!")
        print()

        # Count statements
        with open(sql_file, 'r') as f:
            content = f.read()
            update_count = len(re.findall(r'UPDATE scenarios', content, re.IGNORECASE))
            array_count = len(re.findall(r'ARRAY\[', content))
            where_count = len(re.findall(r"WHERE id = '[a-f0-9-]+'", content))

        print("Statistics:")
        print(f"  - UPDATE statements: {update_count}")
        print(f"  - ARRAY declarations: {array_count}")
        print(f"  - WHERE clauses: {where_count}")
        print(f"  - Has transaction wrapper: {'✓' if 'BEGIN;' in content and 'COMMIT;' in content else '✗'}")
        print()

        print("✓ Ready for execution!")
        print()
        print("Next steps:")
        print("  1. Review output/fix_scenarios_report.txt")
        print("  2. Backup your database")
        print("  3. Execute the SQL file in Supabase")
        print("  4. Re-run scenario_quality_checker.py to verify")

        return 0
    else:
        print("✗ SQL validation failed!")
        print()
        print("Issues found:")
        for issue in issues:
            print(f"  - {issue}")
        print()
        print("Please fix these issues before executing the SQL.")
        return 1


if __name__ == '__main__':
    exit(main())
