#!/usr/bin/env python3
"""
Semantic Content Validator - Validates meanings and accuracy of Gita content
Compares sample verses and all chapters against authoritative sources
"""

import os
import json
import asyncio
from datetime import datetime
from dotenv import load_dotenv
from supabase import create_client
from fuzzywuzzy import fuzz
import random

# Import sources
from sources.vedabase_source import VedabaseSource
from sources.holy_bhagavad_gita_source import HolyBhagavadGitaSource

# Load environment
load_dotenv()

print("="*80)
print("SEMANTIC CONTENT VALIDATION - Meaning & Accuracy Check")
print("="*80)
print()

# Initialize
supabase_url = os.getenv('SUPABASE_URL')
supabase_key = os.getenv('SUPABASE_KEY')
client = create_client(supabase_url, supabase_key)

# Initialize validation sources
print("🌐 Initializing validation sources...")
vedabase = VedabaseSource()
holy_gita = HolyBhagavadGitaSource()
print("   ✓ Vedabase (ISKCON - Prabhupada)")
print("   ✓ Holy-Bhagavad-Gita.org (Mukundananda)")
print()

# Fetch data
print("📊 Fetching data from Supabase...")
verses_response = client.table('gita_verses').select('*').order('gv_chapter_id, gv_verses_id').execute()
chapters_response = client.table('chapters').select('*').order('ch_chapter_id').execute()

verses = verses_response.data
chapters = chapters_response.data

print(f"✓ Fetched {len(verses)} verses")
print(f"✓ Fetched {len(chapters)} chapters")
print()

# Results
results = {
    'validation_date': datetime.now().isoformat(),
    'sources': ['Vedabase (Prabhupada)', 'Holy-Bhagavad-Gita.org (Mukundananda)'],
    'verse_samples': [],
    'chapter_validations': [],
    'semantic_issues': [],
    'warnings': [],
    'quality_summary': {}
}

# Sample verses strategically (important verses from each chapter)
print("🔍 Semantic Validation of Key Verses")
print("="*80)

# Key verses to validate (famous verses from each chapter)
key_verses = [
    (1, 1),   # Chapter 1, Verse 1 - Opening
    (2, 47),  # Chapter 2, Verse 47 - Famous "right to action" verse
    (3, 35),  # Chapter 3, Verse 35 - Better one's own dharma
    (4, 7),   # Chapter 4, Verse 7 - Avatar appearance
    (5, 10),  # Chapter 5, Verse 10 - Detached action
    (6, 5),   # Chapter 6, Verse 5 - Mind is friend/enemy
    (7, 19),  # Chapter 7, Verse 19 - Vasudeva is all
    (8, 5),   # Chapter 8, Verse 5 - Remember at death
    (9, 22),  # Chapter 9, Verse 22 - I preserve what they have
    (10, 20), # Chapter 10, Verse 20 - I am the Self
    (11, 32), # Chapter 11, Verse 32 - Time I am
    (12, 13), # Chapter 12, Verse 13 - Qualities of devotee
    (13, 2),  # Chapter 13, Verse 2 - Knower of the field
    (14, 4),  # Chapter 14, Verse 4 - Great Brahma my womb
    (15, 15), # Chapter 15, Verse 15 - I am in hearts of all
    (16, 24), # Chapter 16, Verse 24 - Scriptures as guide
    (17, 3),  # Chapter 17, Verse 3 - Nature according to faith
    (18, 66)  # Chapter 18, Verse 66 - Surrender unto Me
]

async def validate_verse_semantics(ch, v):
    """Validate a verse against authoritative sources"""
    # Get our verse
    our_verse = [verse for verse in verses
                 if verse['gv_chapter_id'] == ch and verse['gv_verses_id'] == v]

    if not our_verse:
        return {
            'verse': f"{ch}.{v}",
            'status': 'missing',
            'similarity_scores': {},
            'issues': ['Verse not found in database']
        }

    our_verse = our_verse[0]
    our_text = our_verse['gv_verses']

    # Fetch from sources
    vedabase_verse = await vedabase.fetch_verse(ch, v)
    holy_verse = await holy_gita.fetch_verse(ch, v)

    # Compare similarities
    similarities = {}

    if vedabase_verse and vedabase_verse.get('translation'):
        sim = fuzz.ratio(our_text.lower(), vedabase_verse['translation'].lower())
        similarities['vedabase'] = sim

    if holy_verse and holy_verse.get('translation'):
        sim = fuzz.ratio(our_text.lower(), holy_verse['translation'].lower())
        similarities['holy_gita'] = sim

    # Determine status
    avg_similarity = sum(similarities.values()) / len(similarities) if similarities else 0

    status = 'excellent' if avg_similarity >= 80 else \
             'good' if avg_similarity >= 70 else \
             'fair' if avg_similarity >= 60 else \
             'poor'

    issues = []
    if avg_similarity < 70:
        issues.append(f"Low similarity with authoritative sources ({avg_similarity:.1f}%)")

    if len(our_text) < 50:
        issues.append(f"Text seems too short ({len(our_text)} chars)")

    return {
        'verse': f"{ch}.{v}",
        'our_text': our_text[:150] + "..." if len(our_text) > 150 else our_text,
        'similarity_scores': similarities,
        'avg_similarity': avg_similarity,
        'status': status,
        'issues': issues,
        'vedabase_text': vedabase_verse.get('translation', '')[:150] + "..." if vedabase_verse else None,
        'holy_gita_text': holy_verse.get('translation', '')[:150] + "..." if holy_verse else None
    }

# Validate key verses
print("Validating key verses against authoritative sources...")
print("(This may take 2-3 minutes due to web scraping)")
print()

async def validate_all_verses():
    for ch, v in key_verses:
        result = await validate_verse_semantics(ch, v)
        results['verse_samples'].append(result)

        status_icon = {
            'excellent': '✅',
            'good': '✓',
            'fair': '⚠️',
            'poor': '❌',
            'missing': '❌'
        }.get(result['status'], '?')

        print(f"{status_icon} Verse {result['verse']}: {result['status']} ({result.get('avg_similarity', 0):.1f}% similarity)")

        if result['issues']:
            for issue in result['issues']:
                print(f"      Issue: {issue}")
                results['warnings'].append(f"Verse {result['verse']}: {issue}")

        # Small delay to avoid overloading servers
        await asyncio.sleep(0.5)

# Run validation
asyncio.run(validate_all_verses())

print()
print("🔍 Semantic Validation of Chapters")
print("="*80)

# Validate chapter titles and themes
for chapter in chapters:
    ch_id = chapter['ch_chapter_id']
    title = chapter.get('ch_title', '')
    theme = chapter.get('ch_theme', '')
    summary = chapter.get('ch_summary', '')
    teachings = chapter.get('ch_key_teachings', [])

    chapter_result = {
        'chapter_id': ch_id,
        'title': title,
        'theme': theme,
        'summary_length': len(summary),
        'teachings_count': len(teachings),
        'issues': [],
        'status': 'ok'
    }

    # Check title (should contain key themes)
    traditional_themes = {
        1: ['Distress', 'Arjuna', 'Grief', 'Sorrow'],
        2: ['Sankhya', 'Yoga', 'Knowledge'],
        3: ['Karma', 'Action'],
        4: ['Knowledge', 'Renunciation', 'Wisdom'],
        5: ['Renunciation', 'Action'],
        6: ['Meditation', 'Dhyana'],
        7: ['Knowledge', 'Wisdom', 'Realization'],
        8: ['Imperishable', 'Brahman'],
        9: ['Royal', 'Secret', 'Knowledge'],
        10: ['Opulence', 'Manifestation'],
        11: ['Universal Form', 'Cosmic'],
        12: ['Devotion', 'Bhakti'],
        13: ['Field', 'Knower', 'Ksetra'],
        14: ['Three Gunas', 'Modes', 'Nature'],
        15: ['Supreme Person', 'Purushottama'],
        16: ['Divine', 'Demonic', 'Nature'],
        17: ['Threefold Faith', 'Shraddha'],
        18: ['Liberation', 'Moksha', 'Renunciation']
    }

    # Check if title/theme contains traditional keywords
    theme_keywords = traditional_themes.get(ch_id, [])
    title_lower = title.lower()
    theme_lower = theme.lower()

    has_traditional_theme = any(keyword.lower() in title_lower or keyword.lower() in theme_lower
                                for keyword in theme_keywords)

    if not has_traditional_theme:
        chapter_result['issues'].append(f"Title/theme may not reflect traditional interpretation")
        chapter_result['status'] = 'warning'
        results['warnings'].append(f"Chapter {ch_id}: Title/theme needs verification")

    # Check summary length
    if len(summary) < 200:
        chapter_result['issues'].append(f"Summary too short ({len(summary)} chars)")
        chapter_result['status'] = 'warning'

    # Check key teachings
    if len(teachings) < 3:
        chapter_result['issues'].append(f"Too few key teachings ({len(teachings)})")
        chapter_result['status'] = 'warning'

    results['chapter_validations'].append(chapter_result)

    status_icon = '✅' if chapter_result['status'] == 'ok' else '⚠️'
    print(f"{status_icon} Chapter {ch_id}: {title}")

    if chapter_result['issues']:
        for issue in chapter_result['issues']:
            print(f"      {issue}")

print()
print("="*80)
print("SEMANTIC VALIDATION SUMMARY")
print("="*80)
print()

# Calculate quality metrics
verse_scores = [v['avg_similarity'] for v in results['verse_samples']
                if 'avg_similarity' in v]
avg_verse_quality = sum(verse_scores) / len(verse_scores) if verse_scores else 0

excellent_verses = sum(1 for v in results['verse_samples'] if v['status'] == 'excellent')
good_verses = sum(1 for v in results['verse_samples'] if v['status'] == 'good')
issues_count = sum(1 for v in results['verse_samples'] if v['issues'])

chapter_issues = sum(1 for c in results['chapter_validations'] if c['status'] != 'ok')

results['quality_summary'] = {
    'avg_verse_similarity': avg_verse_quality,
    'excellent_verses': excellent_verses,
    'good_verses': good_verses,
    'verses_with_issues': issues_count,
    'chapters_with_issues': chapter_issues,
    'total_warnings': len(results['warnings'])
}

print(f"Average Verse Similarity: {avg_verse_quality:.1f}%")
print(f"Verses with Excellent Match (≥80%): {excellent_verses}/{len(key_verses)}")
print(f"Verses with Good Match (≥70%): {good_verses}/{len(key_verses)}")
print(f"Verses Needing Review: {issues_count}/{len(key_verses)}")
print()
print(f"Chapters with Issues: {chapter_issues}/18")
print(f"Total Warnings: {len(results['warnings'])}")
print()

if avg_verse_quality >= 80:
    print("✅ SEMANTIC QUALITY: EXCELLENT - Highly accurate content")
elif avg_verse_quality >= 70:
    print("✅ SEMANTIC QUALITY: GOOD - Generally accurate content")
elif avg_verse_quality >= 60:
    print("⚠️ SEMANTIC QUALITY: FAIR - Some accuracy concerns")
else:
    print("❌ SEMANTIC QUALITY: POOR - Significant accuracy issues")

print()

# Save results
os.makedirs('output', exist_ok=True)
output_file = 'output/semantic_validation_report.json'
with open(output_file, 'w', encoding='utf-8') as f:
    json.dump(results, f, indent=2, ensure_ascii=False)

print(f"📄 Full semantic report saved to: {output_file}")
print()
print("="*80)
print("✅ Semantic validation complete!")
print("="*80)
