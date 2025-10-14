"""
Special Character Validator - Detects dangerous characters that could cause runtime errors
"""

import unicodedata
from typing import List, Dict


class SpecialCharValidator:
    """Validates text for dangerous special characters."""

    # Dangerous characters that can cause runtime errors in Dart/Flutter
    DANGEROUS_CHARS = {
        '\x00': 'null_byte',
        '\ufffe': 'invalid_unicode',
        '\uffff': 'invalid_unicode',
        '\ufeff': 'bom',  # Byte Order Mark
        '\u200b': 'zero_width_space',
        '\u200c': 'zero_width_non_joiner',
        '\u200d': 'zero_width_joiner',
        '\u2028': 'line_separator',
        '\u2029': 'paragraph_separator',
        '\r\r': 'double_carriage_return',
    }

    # Smart quotes and problematic punctuation
    SMART_QUOTES = {
        '\u2018': 'left_single_quote',  # '
        '\u2019': 'right_single_quote',  # '
        '\u201c': 'left_double_quote',  # "
        '\u201d': 'right_double_quote',  # "
        '\u201a': 'single_low_quote',  # ‚
        '\u201e': 'double_low_quote',  # „
    }

    def __init__(self):
        pass

    def validate_text(self, text: str) -> List[Dict]:
        """
        Validate text for dangerous characters.

        Args:
            text: Text to validate

        Returns:
            List of issues found, each containing:
            - char: The problematic character
            - type: Type of issue
            - position: Position in text
            - unicode_code: Unicode code point
        """
        if not text:
            return []

        issues = []

        # Check for dangerous characters
        for dangerous_char, char_type in self.DANGEROUS_CHARS.items():
            if dangerous_char in text:
                positions = [i for i, c in enumerate(text) if c == dangerous_char or text[i:i+2] == dangerous_char]
                for pos in positions:
                    issues.append({
                        'char': dangerous_char,
                        'type': char_type,
                        'position': pos,
                        'unicode_code': f'U+{ord(dangerous_char):04X}',
                        'severity': 'critical'
                    })

        # Check for smart quotes (warnings, not critical)
        for smart_char, char_type in self.SMART_QUOTES.items():
            if smart_char in text:
                positions = [i for i, c in enumerate(text) if c == smart_char]
                for pos in positions:
                    issues.append({
                        'char': smart_char,
                        'type': char_type,
                        'position': pos,
                        'unicode_code': f'U+{ord(smart_char):04X}',
                        'severity': 'warning'
                    })

        # Check for invalid Unicode combining marks
        for i, char in enumerate(text):
            if unicodedata.category(char) == 'Mn':  # Mark, nonspacing
                # Check if it's standalone (not preceded by a base character)
                if i == 0 or unicodedata.category(text[i-1]) in ['Zs', 'Cc']:
                    issues.append({
                        'char': char,
                        'type': 'standalone_combining_mark',
                        'position': i,
                        'unicode_code': f'U+{ord(char):04X}',
                        'severity': 'warning'
                    })

        # Check for unescaped backslashes (potential JSON/SQL issues)
        if '\\' in text:
            positions = [i for i, c in enumerate(text) if c == '\\']
            for pos in positions:
                # Check if it's not properly escaped
                if pos == 0 or text[pos-1] != '\\':
                    issues.append({
                        'char': '\\',
                        'type': 'unescaped_backslash',
                        'position': pos,
                        'unicode_code': 'U+005C',
                        'severity': 'warning'
                    })

        return issues

    def sanitize_text(self, text: str) -> str:
        """
        Sanitize text by fixing common issues.

        Args:
            text: Text to sanitize

        Returns:
            Sanitized text
        """
        if not text:
            return text

        sanitized = text

        # Remove null bytes and invalid Unicode
        sanitized = sanitized.replace('\x00', '')
        sanitized = sanitized.replace('\ufffe', '')
        sanitized = sanitized.replace('\uffff', '')

        # Remove BOM
        sanitized = sanitized.replace('\ufeff', '')

        # Remove zero-width spaces
        sanitized = sanitized.replace('\u200b', '')
        sanitized = sanitized.replace('\u200c', '')
        sanitized = sanitized.replace('\u200d', '')

        # Replace line/paragraph separators with standard newlines
        sanitized = sanitized.replace('\u2028', '\n')
        sanitized = sanitized.replace('\u2029', '\n\n')

        # Fix double carriage returns
        sanitized = sanitized.replace('\r\r', '\n')

        # Replace smart quotes with standard ASCII quotes
        sanitized = sanitized.replace('\u2018', "'")  # '
        sanitized = sanitized.replace('\u2019', "'")  # '
        sanitized = sanitized.replace('\u201c', '"')  # "
        sanitized = sanitized.replace('\u201d', '"')  # "
        sanitized = sanitized.replace('\u201a', "'")  # ‚
        sanitized = sanitized.replace('\u201e', '"')  # „

        # Normalize Unicode (NFC normalization)
        sanitized = unicodedata.normalize('NFC', sanitized)

        return sanitized

    def get_sanitization_sql(self, table: str, field: str, issues: List[Dict]) -> str:
        """
        Generate SQL to fix special character issues.

        Args:
            table: Table name
            field: Field name
            issues: List of issues from validate_text()

        Returns:
            SQL UPDATE statement
        """
        sql_lines = []

        # Get unique character types to fix
        char_types = set(issue['type'] for issue in issues)

        for char_type in char_types:
            if char_type == 'bom':
                sql_lines.append(
                    f"UPDATE {table} SET {field} = REPLACE({field}, '\ufeff', '') WHERE {field} ~ '\ufeff';"
                )
            elif char_type == 'null_byte':
                sql_lines.append(
                    f"UPDATE {table} SET {field} = REPLACE({field}, '\x00', '') WHERE {field} ~ '\x00';"
                )
            elif char_type in ['left_single_quote', 'right_single_quote']:
                sql_lines.append(
                    f"UPDATE {table} SET {field} = REPLACE(REPLACE({field}, '\u2018', ''''), '\u2019', '''') "
                    f"WHERE {field} ~ '[\u2018\u2019]';"
                )
            elif char_type in ['left_double_quote', 'right_double_quote']:
                sql_lines.append(
                    f"UPDATE {table} SET {field} = REPLACE(REPLACE({field}, '\u201c', '\"'), '\u201d', '\"') "
                    f"WHERE {field} ~ '[\u201c\u201d]';"
                )
            elif char_type.startswith('zero_width'):
                sql_lines.append(
                    f"UPDATE {table} SET {field} = REPLACE(REPLACE(REPLACE({field}, '\u200b', ''), '\u200c', ''), '\u200d', '') "
                    f"WHERE {field} ~ '[\u200b\u200c\u200d]';"
                )

        return '\n'.join(sql_lines)
