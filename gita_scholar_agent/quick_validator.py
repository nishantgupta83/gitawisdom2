#!/usr/bin/env python3
"""
Quick Gita Validator - Fast validation focusing on critical issues
Validates sample of verses + all chapters + special characters
"""

import os
import json
from datetime import datetime
from dotenv import load_dotenv
from supabase import create_client
from validators.special_char_validator import SpecialCharValidator

# Load environment
load_dotenv()

supabase_url = os.getenv('SUPABASE_URL')
supabase_key = os.getenv('SUPABASE_KEY')

print("="*80)
print("QUICK GITA VALIDATION - Critical Issues Check")
print("="*80)
print()

# Initialize
client = create_client(supabase_url, supabase_key)
char_validator = SpecialCharValidator()

# Fetch all data
print("📊 Fetching data from Supabase...")
verses_response = client.table('gita_verses').select('*').order('gv_chapter_id, gv_verses_id').execute()
chapters_response = client.table('chapters').select('*').order('ch_chapter_id').execute()

verses = verses_response.data
chapters = chapters_response.data

print(f"✓ Fetched {len(verses)} verses")
print(f"✓ Fetched {len(chapters)} chapters")
print()

# Critical checks
results = {
    'validation_date': datetime.now().isoformat(),
    'critical_issues': [],
    'warnings': [],
    'verse_count': len(verses),
    'chapter_count': len(chapters),
    'special_chars': {
        'verses_with_issues': [],
        'chapters_with_issues': [],
        'total_dangerous_chars': 0
    },
    'verse_samples': []
}

# Check 1: Verse count
print("🔍 Check 1: Verse Count")
if len(verses) != 700:
    results['critical_issues'].append(f"Verse count mismatch: Expected 700, found {len(verses)}")
    print(f"❌ CRITICAL: Expected 700 verses, found {len(verses)}")
else:
    print(f"✅ Correct verse count: 700")
print()

# Check 2: Chapter count
print("🔍 Check 2: Chapter Count")
if len(chapters) != 18:
    results['critical_issues'].append(f"Chapter count mismatch: Expected 18, found {len(chapters)}")
    print(f"❌ CRITICAL: Expected 18 chapters, found {len(chapters)}")
else:
    print(f"✅ Correct chapter count: 18")
print()

# Check 3: Special characters in ALL verses
print("🔍 Check 3: Scanning ALL verses for dangerous characters...")
verses_with_issues = 0
for verse in verses:
    verse_text = verse.get('gv_verses', '')
    issues = char_validator.validate_text(verse_text)
    if issues:
        verses_with_issues += 1
        verse_key = f"{verse['gv_chapter_id']}.{verse['gv_verses_id']}"
        results['special_chars']['verses_with_issues'].append({
            'verse': verse_key,
            'issues': issues
        })
        results['special_chars']['total_dangerous_chars'] += len(issues)

if verses_with_issues > 0:
    print(f"⚠️  Found dangerous characters in {verses_with_issues} verses")
    results['warnings'].append(f"{verses_with_issues} verses have dangerous characters")
else:
    print(f"✅ No dangerous characters in verses")
print()

# Check 4: Special characters in ALL chapters
print("🔍 Check 4: Scanning ALL chapters for dangerous characters...")
chapters_with_issues = 0
for chapter in chapters:
    fields = [
        chapter.get('ch_title', ''),
        chapter.get('ch_subtitle', ''),
        chapter.get('ch_summary', ''),
        chapter.get('ch_theme', '')
    ]

    chapter_issues = []
    for field_value in fields:
        if field_value:
            issues = char_validator.validate_text(field_value)
            chapter_issues.extend(issues)

    if chapter_issues:
        chapters_with_issues += 1
        results['special_chars']['chapters_with_issues'].append({
            'chapter_id': chapter['ch_chapter_id'],
            'issues': chapter_issues
        })
        results['special_chars']['total_dangerous_chars'] += len(chapter_issues)

if chapters_with_issues > 0:
    print(f"⚠️  Found dangerous characters in {chapters_with_issues} chapters")
    results['warnings'].append(f"{chapters_with_issues} chapters have dangerous characters")
else:
    print(f"✅ No dangerous characters in chapters")
print()

# Check 5: Verse length validation (sample every 10th verse)
print("🔍 Check 5: Checking verse lengths (sample)...")
short_verses = 0
long_verses = 0
for i, verse in enumerate(verses):
    if i % 10 == 0:  # Sample every 10th verse
        length = len(verse.get('gv_verses', ''))
        verse_key = f"{verse['gv_chapter_id']}.{verse['gv_verses_id']}"

        status = "ok"
        if length < 30:
            short_verses += 1
            status = "too_short"
            results['warnings'].append(f"Verse {verse_key} too short: {length} chars")
        elif length > 600:
            long_verses += 1
            status = "too_long"
            results['warnings'].append(f"Verse {verse_key} too long: {length} chars")

        results['verse_samples'].append({
            'verse': verse_key,
            'length': length,
            'status': status
        })

print(f"   Sampled {len(results['verse_samples'])} verses")
if short_verses > 0:
    print(f"   ⚠️  {short_verses} verses too short (<30 chars)")
if long_verses > 0:
    print(f"   ⚠️  {long_verses} verses too long (>600 chars)")
if short_verses == 0 and long_verses == 0:
    print(f"   ✅ All sampled verses have appropriate length")
print()

# Check 6: Chapter metadata completeness
print("🔍 Check 6: Checking chapter metadata...")
missing_summaries = 0
missing_teachings = 0
for chapter in chapters:
    ch_id = chapter['ch_chapter_id']

    if not chapter.get('ch_summary') or len(chapter.get('ch_summary', '')) < 200:
        missing_summaries += 1
        results['warnings'].append(f"Chapter {ch_id} has short/missing summary")

    teachings = chapter.get('ch_key_teachings', [])
    if not teachings or len(teachings) < 3:
        missing_teachings += 1
        results['warnings'].append(f"Chapter {ch_id} has too few key teachings ({len(teachings)})")

if missing_summaries > 0:
    print(f"   ⚠️  {missing_summaries} chapters have short/missing summaries")
if missing_teachings > 0:
    print(f"   ⚠️  {missing_teachings} chapters have too few key teachings")
if missing_summaries == 0 and missing_teachings == 0:
    print(f"   ✅ All chapters have complete metadata")
print()

# Summary
print("="*80)
print("VALIDATION SUMMARY")
print("="*80)
print()

if len(results['critical_issues']) == 0:
    print("✅ No critical issues found!")
else:
    print(f"❌ {len(results['critical_issues'])} CRITICAL ISSUES:")
    for issue in results['critical_issues']:
        print(f"   • {issue}")
print()

if len(results['warnings']) == 0:
    print("✅ No warnings!")
else:
    print(f"⚠️  {len(results['warnings'])} WARNINGS:")
    for i, warning in enumerate(results['warnings'][:10], 1):  # Show first 10
        print(f"   {i}. {warning}")
    if len(results['warnings']) > 10:
        print(f"   ... and {len(results['warnings']) - 10} more warnings")
print()

# Special characters summary
if results['special_chars']['total_dangerous_chars'] > 0:
    print(f"⚠️  DANGEROUS CHARACTERS: {results['special_chars']['total_dangerous_chars']} found")
    print(f"   • {len(results['special_chars']['verses_with_issues'])} verses affected")
    print(f"   • {len(results['special_chars']['chapters_with_issues'])} chapters affected")
else:
    print(f"✅ NO DANGEROUS CHARACTERS FOUND")
print()

# Save results
os.makedirs('output', exist_ok=True)
output_file = 'output/quick_validation_report.json'
with open(output_file, 'w', encoding='utf-8') as f:
    json.dump(results, f, indent=2, ensure_ascii=False)

print(f"📄 Full report saved to: {output_file}")
print()

# Generate fix script if needed
if results['special_chars']['total_dangerous_chars'] > 0:
    fix_script = []
    fix_script.append("-- Quick Fix Script for Special Characters")
    fix_script.append(f"-- Generated: {datetime.now().isoformat()}")
    fix_script.append("")
    fix_script.append("BEGIN;")
    fix_script.append("")
    fix_script.append("-- Remove BOM characters")
    fix_script.append("UPDATE gita_verses SET gv_verses = REPLACE(gv_verses, E'\\ufeff', '') WHERE gv_verses LIKE '%' || E'\\ufeff' || '%';")
    fix_script.append("UPDATE chapters SET ch_summary = REPLACE(ch_summary, E'\\ufeff', '') WHERE ch_summary LIKE '%' || E'\\ufeff' || '%';")
    fix_script.append("")
    fix_script.append("-- Replace smart quotes")
    fix_script.append("UPDATE gita_verses SET gv_verses = REPLACE(REPLACE(gv_verses, E'\\u2018', ''''), E'\\u2019', '''') WHERE gv_verses ~ '[\\u2018\\u2019]';")
    fix_script.append("UPDATE gita_verses SET gv_verses = REPLACE(REPLACE(gv_verses, E'\\u201c', '\"'), E'\\u201d', '\"') WHERE gv_verses ~ '[\\u201c\\u201d]';")
    fix_script.append("")
    fix_script.append("-- Remove zero-width spaces")
    fix_script.append("UPDATE gita_verses SET gv_verses = REPLACE(REPLACE(REPLACE(gv_verses, E'\\u200b', ''), E'\\u200c', ''), E'\\u200d', '') WHERE gv_verses ~ '[\\u200b\\u200c\\u200d]';")
    fix_script.append("")
    fix_script.append("COMMIT;")

    fix_file = 'output/quick_fix_script.sql'
    with open(fix_file, 'w', encoding='utf-8') as f:
        f.write('\n'.join(fix_script))

    print(f"🔧 Fix script saved to: {fix_file}")
    print()

print("="*80)
print("✅ Quick validation complete!")
print("="*80)
