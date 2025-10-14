"""
Report Generator - Generates SQL fix scripts and HTML dashboards
"""

from typing import Dict
from datetime import datetime


class ReportGenerator:
    """Generates validation reports and fix scripts."""

    def generate_fix_script(self, validation_results: Dict) -> str:
        """
        Generate SQL script to fix detected issues.

        Args:
            validation_results: Full validation results

        Returns:
            SQL script as string
        """
        sql_lines = []

        sql_lines.append("-- GitaWisdom Database Fix Script")
        sql_lines.append(f"-- Generated: {datetime.now().isoformat()}")
        sql_lines.append(f"-- Validation Date: {validation_results['validation_date']}")
        sql_lines.append("")
        sql_lines.append("-- IMPORTANT: Review this script before executing!")
        sql_lines.append("-- Always backup your database first.")
        sql_lines.append("")
        sql_lines.append("BEGIN;")
        sql_lines.append("")

        # Special character fixes
        special_chars = validation_results.get('special_chars', {})

        if special_chars.get('verses_with_issues'):
            sql_lines.append("-- ======================")
            sql_lines.append("-- VERSE SPECIAL CHARACTER FIXES")
            sql_lines.append("-- ======================")
            sql_lines.append("")

            # Group by character type
            char_types = special_chars.get('char_types', {})

            if char_types.get('bom', 0) > 0:
                sql_lines.append("-- Remove BOM (Byte Order Mark) characters")
                sql_lines.append("UPDATE gita_verses SET gv_verses = REPLACE(gv_verses, E'\\ufeff', '') WHERE gv_verses LIKE '%' || E'\\ufeff' || '%';")
                sql_lines.append("")

            if char_types.get('null_byte', 0) > 0:
                sql_lines.append("-- Remove null bytes")
                sql_lines.append("UPDATE gita_verses SET gv_verses = REPLACE(gv_verses, E'\\x00', '') WHERE gv_verses LIKE '%' || E'\\x00' || '%';")
                sql_lines.append("")

            if char_types.get('zero_width_space', 0) > 0 or char_types.get('zero_width_non_joiner', 0) > 0:
                sql_lines.append("-- Remove zero-width spaces")
                sql_lines.append("UPDATE gita_verses SET gv_verses = REPLACE(REPLACE(REPLACE(gv_verses, E'\\u200b', ''), E'\\u200c', ''), E'\\u200d', '') WHERE gv_verses ~ '[\\u200b\\u200c\\u200d]';")
                sql_lines.append("")

            if char_types.get('left_single_quote', 0) > 0 or char_types.get('right_single_quote', 0) > 0:
                sql_lines.append("-- Replace smart single quotes with standard quotes")
                sql_lines.append("UPDATE gita_verses SET gv_verses = REPLACE(REPLACE(gv_verses, E'\\u2018', ''''), E'\\u2019', '''') WHERE gv_verses ~ '[\\u2018\\u2019]';")
                sql_lines.append("")

            if char_types.get('left_double_quote', 0) > 0 or char_types.get('right_double_quote', 0) > 0:
                sql_lines.append("-- Replace smart double quotes with standard quotes")
                sql_lines.append("UPDATE gita_verses SET gv_verses = REPLACE(REPLACE(gv_verses, E'\\u201c', '\"'), E'\\u201d', '\"') WHERE gv_verses ~ '[\\u201c\\u201d]';")
                sql_lines.append("")

        if special_chars.get('chapters_with_issues'):
            sql_lines.append("-- ======================")
            sql_lines.append("-- CHAPTER SPECIAL CHARACTER FIXES")
            sql_lines.append("-- ======================")
            sql_lines.append("")

            # Apply same fixes to chapter fields
            if char_types.get('bom', 0) > 0:
                sql_lines.append("-- Remove BOM from chapter titles")
                sql_lines.append("UPDATE chapters SET ch_title = REPLACE(ch_title, E'\\ufeff', '') WHERE ch_title LIKE '%' || E'\\ufeff' || '%';")
                sql_lines.append("UPDATE chapters SET ch_subtitle = REPLACE(ch_subtitle, E'\\ufeff', '') WHERE ch_subtitle LIKE '%' || E'\\ufeff' || '%';")
                sql_lines.append("UPDATE chapters SET ch_summary = REPLACE(ch_summary, E'\\ufeff', '') WHERE ch_summary LIKE '%' || E'\\ufeff' || '%';")
                sql_lines.append("")

            if char_types.get('left_single_quote', 0) > 0 or char_types.get('right_single_quote', 0) > 0:
                sql_lines.append("-- Replace smart quotes in chapters")
                sql_lines.append("UPDATE chapters SET ch_summary = REPLACE(REPLACE(ch_summary, E'\\u2018', ''''), E'\\u2019', '''') WHERE ch_summary ~ '[\\u2018\\u2019]';")
                sql_lines.append("")

            if char_types.get('left_double_quote', 0) > 0 or char_types.get('right_double_quote', 0) > 0:
                sql_lines.append("UPDATE chapters SET ch_summary = REPLACE(REPLACE(ch_summary, E'\\u201c', '\"'), E'\\u201d', '\"') WHERE ch_summary ~ '[\\u201c\\u201d]';")
                sql_lines.append("")

        # Critical verse issues
        critical_verses = []
        for verse_key, verse_result in validation_results.get('verses', {}).items():
            if verse_result.get('critical_issues'):
                critical_verses.append((verse_key, verse_result))

        if critical_verses:
            sql_lines.append("-- ======================")
            sql_lines.append("-- CRITICAL VERSE ISSUES (Manual Review Required)")
            sql_lines.append("-- ======================")
            sql_lines.append("")

            for verse_key, verse_result in critical_verses[:10]:  # Limit to first 10
                sql_lines.append(f"-- Verse {verse_key}:")
                for issue in verse_result['critical_issues']:
                    sql_lines.append(f"--   ISSUE: {issue}")
                sql_lines.append(f"-- SELECT * FROM gita_verses WHERE gv_chapter_id = {verse_result['chapter_id']} AND gv_verses_id = {verse_result['verse_id']};")
                sql_lines.append("")

        # Critical chapter issues
        critical_chapters = []
        for chapter_id, chapter_result in validation_results.get('chapters', {}).items():
            if chapter_result.get('critical_issues'):
                critical_chapters.append((chapter_id, chapter_result))

        if critical_chapters:
            sql_lines.append("-- ======================")
            sql_lines.append("-- CRITICAL CHAPTER ISSUES (Manual Review Required)")
            sql_lines.append("-- ======================")
            sql_lines.append("")

            for chapter_id, chapter_result in critical_chapters:
                sql_lines.append(f"-- Chapter {chapter_id}:")
                for issue in chapter_result['critical_issues']:
                    sql_lines.append(f"--   ISSUE: {issue}")
                sql_lines.append(f"-- SELECT * FROM chapters WHERE ch_chapter_id = {chapter_id};")
                sql_lines.append("")

        sql_lines.append("-- ======================")
        sql_lines.append("-- VERIFICATION QUERIES")
        sql_lines.append("-- ======================")
        sql_lines.append("")
        sql_lines.append("-- Verify verse count (should be 700)")
        sql_lines.append("SELECT COUNT(*) as verse_count FROM gita_verses;")
        sql_lines.append("")
        sql_lines.append("-- Verify chapter count (should be 18)")
        sql_lines.append("SELECT COUNT(*) as chapter_count FROM chapters;")
        sql_lines.append("")
        sql_lines.append("-- Check for remaining special characters")
        sql_lines.append("SELECT gv_chapter_id, gv_verses_id FROM gita_verses WHERE gv_verses ~ '[\\u200b\\u200c\\u200d\\ufeff]';")
        sql_lines.append("")

        sql_lines.append("COMMIT;")
        sql_lines.append("")
        sql_lines.append("-- END OF FIX SCRIPT")

        return '\n'.join(sql_lines)

    def generate_html_dashboard(self, validation_results: Dict) -> str:
        """
        Generate HTML quality dashboard.

        Args:
            validation_results: Full validation results

        Returns:
            HTML content as string
        """
        summary = validation_results.get('summary', {})
        quality_scores = validation_results.get('quality_scores', {})
        overall_score = quality_scores.get('overall_score', 0)

        # Determine status color
        if overall_score >= 85:
            status_color = '#4CAF50'  # Green
            status_text = 'EXCELLENT'
        elif overall_score >= 70:
            status_color = '#FFC107'  # Yellow
            status_text = 'GOOD'
        else:
            status_color = '#F44336'  # Red
            status_text = 'NEEDS IMPROVEMENT'

        html = f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gita Scholar Validation Report</title>
    <style>
        * {{ margin: 0; padding: 0; box-sizing: border-box; }}
        body {{
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 20px;
            min-height: 100vh;
        }}
        .container {{
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 15px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            overflow: hidden;
        }}
        .header {{
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            text-align: center;
        }}
        .header h1 {{
            font-size: 2.5em;
            margin-bottom: 10px;
        }}
        .header p {{
            font-size: 1.1em;
            opacity: 0.9;
        }}
        .overall-score {{
            background: {status_color};
            color: white;
            padding: 40px;
            text-align: center;
        }}
        .score-number {{
            font-size: 4em;
            font-weight: bold;
            margin: 20px 0;
        }}
        .score-status {{
            font-size: 1.5em;
            letter-spacing: 3px;
        }}
        .metrics {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            padding: 30px;
        }}
        .metric-card {{
            background: #f8f9fa;
            border-radius: 10px;
            padding: 20px;
            border-left: 4px solid #667eea;
        }}
        .metric-card h3 {{
            color: #333;
            margin-bottom: 10px;
            font-size: 0.9em;
            text-transform: uppercase;
            letter-spacing: 1px;
        }}
        .metric-card .value {{
            font-size: 2em;
            font-weight: bold;
            color: #667eea;
        }}
        .issues-section {{
            padding: 30px;
            background: #fff3cd;
            border-top: 3px solid #ffc107;
        }}
        .issues-section.critical {{
            background: #f8d7da;
            border-top: 3px solid #f44336;
        }}
        .issues-section.success {{
            background: #d4edda;
            border-top: 3px solid #4CAF50;
        }}
        .issues-section h2 {{
            margin-bottom: 15px;
            color: #333;
        }}
        .issue-list {{
            list-style: none;
        }}
        .issue-list li {{
            padding: 10px;
            margin: 5px 0;
            background: white;
            border-radius: 5px;
            border-left: 3px solid #667eea;
        }}
        .breakdown {{
            padding: 30px;
            background: #f8f9fa;
        }}
        .breakdown h2 {{
            margin-bottom: 20px;
            color: #333;
        }}
        .breakdown-grid {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
        }}
        .breakdown-item {{
            background: white;
            padding: 15px;
            border-radius: 8px;
            border: 1px solid #ddd;
        }}
        .breakdown-item strong {{
            display: block;
            margin-bottom: 5px;
            color: #667eea;
        }}
        .footer {{
            padding: 20px;
            text-align: center;
            background: #f8f9fa;
            color: #666;
            font-size: 0.9em;
        }}
        .progress-bar {{
            background: #e0e0e0;
            border-radius: 10px;
            height: 20px;
            overflow: hidden;
            margin-top: 10px;
        }}
        .progress-fill {{
            background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
            height: 100%;
            transition: width 0.3s ease;
        }}
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🕉️ Gita Scholar Validation Report</h1>
            <p>Comprehensive Quality Analysis of Bhagavad Gita Database</p>
            <p style="font-size: 0.9em; opacity: 0.8; margin-top: 10px;">
                Generated: {datetime.now().strftime('%B %d, %Y at %I:%M %p')}
            </p>
        </div>

        <div class="overall-score">
            <div class="score-status">{status_text}</div>
            <div class="score-number">{overall_score:.1f}/100</div>
            <div class="progress-bar">
                <div class="progress-fill" style="width: {overall_score}%"></div>
            </div>
        </div>

        <div class="metrics">
            <div class="metric-card">
                <h3>Verses Analyzed</h3>
                <div class="value">{summary.get('total_verses_analyzed', 0)}</div>
                <p style="margin-top: 5px; color: #666;">Expected: 700</p>
            </div>
            <div class="metric-card">
                <h3>Chapters Analyzed</h3>
                <div class="value">{summary.get('total_chapters_analyzed', 0)}</div>
                <p style="margin-top: 5px; color: #666;">Expected: 18</p>
            </div>
            <div class="metric-card">
                <h3>Critical Issues</h3>
                <div class="value" style="color: {'#f44336' if summary.get('critical_issues_count', 0) > 0 else '#4CAF50'};">
                    {summary.get('critical_issues_count', 0)}
                </div>
            </div>
            <div class="metric-card">
                <h3>Warnings</h3>
                <div class="value" style="color: {'#FFC107' if summary.get('warnings_count', 0) > 0 else '#4CAF50'};">
                    {summary.get('warnings_count', 0)}
                </div>
            </div>
            <div class="metric-card">
                <h3>Dangerous Characters</h3>
                <div class="value" style="color: {'#f44336' if summary.get('dangerous_chars_found', 0) > 0 else '#4CAF50'};">
                    {summary.get('dangerous_chars_found', 0)}
                </div>
            </div>
            <div class="metric-card">
                <h3>Validation Sources</h3>
                <div class="value">{len(validation_results.get('sources_used', []))}</div>
                <p style="margin-top: 5px; color: #666;">Authoritative</p>
            </div>
        </div>

        <div class="breakdown">
            <h2>Score Breakdown</h2>
            <div class="breakdown-grid">
                <div class="breakdown-item">
                    <strong>Average Verse Score</strong>
                    {quality_scores.get('breakdown', {}).get('avg_verse_score', 0):.2f}/100
                </div>
                <div class="breakdown-item">
                    <strong>Average Chapter Score</strong>
                    {quality_scores.get('breakdown', {}).get('avg_chapter_score', 0):.2f}/100
                </div>
                <div class="breakdown-item">
                    <strong>Lowest Verse Score</strong>
                    {quality_scores.get('breakdown', {}).get('min_verse_score', 0):.2f}/100
                </div>
                <div class="breakdown-item">
                    <strong>Highest Verse Score</strong>
                    {quality_scores.get('breakdown', {}).get('max_verse_score', 0):.2f}/100
                </div>
            </div>
        </div>

        <div class="issues-section {'critical' if summary.get('critical_issues_count', 0) > 0 else 'success' if summary.get('warnings_count', 0) == 0 else ''}">
            <h2>{'⚠️ Critical Issues' if summary.get('critical_issues_count', 0) > 0 else '✅ Validation Status'}</h2>
            <ul class="issue-list">
                {'<li>All critical checks passed!</li>' if summary.get('critical_issues_count', 0) == 0 else ''}
                {'<li>Verse count verified: 700 verses ✓</li>' if summary.get('verse_count_correct') else '<li style="color: #f44336;">❌ Verse count mismatch - Expected 700, found ' + str(summary.get('total_verses_analyzed', 0)) + '</li>'}
                {'<li>No dangerous characters found ✓</li>' if summary.get('dangerous_chars_found', 0) == 0 else '<li style="color: #f44336;">❌ ' + str(summary.get('dangerous_chars_found', 0)) + ' dangerous characters found</li>'}
                {'<li>All chapters validated ✓</li>' if summary.get('total_chapters_analyzed', 0) == 18 else ''}
            </ul>
        </div>

        <div class="footer">
            <p><strong>Gita Scholar Agent v1.0</strong></p>
            <p>Validation Sources: {', '.join(validation_results.get('sources_used', []))}</p>
            <p style="margin-top: 10px;">For detailed results, see validation_report.json</p>
        </div>
    </div>
</body>
</html>"""

        return html
