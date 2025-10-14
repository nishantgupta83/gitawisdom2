import os
from dotenv import load_dotenv
from supabase import create_client

load_dotenv()
client = create_client(os.getenv('SUPABASE_URL'), os.getenv('SUPABASE_KEY'))

print("🔍 Investigating the 701st verse mystery...")
print("="*60)

# Standard verse counts according to most authoritative sources
standard_counts = {
    1: 47, 2: 72, 3: 43, 4: 42, 5: 29, 6: 47, 7: 30, 8: 28, 9: 34,
    10: 42, 11: 55, 12: 20, 13: 34, 14: 27, 15: 20, 16: 24, 17: 28, 18: 78
}

# Alternative count (some traditions)
alternative_counts = {
    1: 47, 2: 72, 3: 43, 4: 42, 5: 29, 6: 47, 7: 30, 8: 28, 9: 34,
    10: 42, 11: 55, 12: 20, 13: 35, 14: 27, 15: 20, 16: 24, 17: 28, 18: 78
}

print(f"Standard total (most sources): {sum(standard_counts.values())}")
print(f"Alternative total (some sources): {sum(alternative_counts.values())}")
print()

# Get actual counts
result = client.table('gita_verses').select('gv_chapter_id').execute()
from collections import Counter
actual_counts = dict(Counter(v['gv_chapter_id'] for v in result.data))

print("Comparison:")
print(f"{'Chapter':<10} {'Standard':<12} {'Alternative':<15} {'Your DB':<10} {'Status'}")
print("-"*60)

issues = []
for ch in range(1, 19):
    standard = standard_counts[ch]
    alternative = alternative_counts.get(ch, standard)
    actual = actual_counts[ch]

    if actual == standard:
        status = "✅ Standard"
    elif actual == alternative and alternative != standard:
        status = "⚠️ Alternative"
        issues.append(f"Chapter {ch}: Using alternative count")
    else:
        status = "❌ Mismatch"
        issues.append(f"Chapter {ch}: Unexpected count {actual}")

    print(f"Chapter {ch:<3} {standard:<12} {alternative:<15} {actual:<10} {status}")

print("-"*60)
print(f"{'Total':<10} {sum(standard_counts.values()):<12} {sum(alternative_counts.values()):<15} {sum(actual_counts.values()):<10}")
print()

if issues:
    print("🔍 Issues found:")
    for issue in issues:
        print(f"   • {issue}")

# Check Chapter 13 specifically
print("\n" + "="*60)
print("📖 Chapter 13 Analysis")
print("="*60)
ch13_verses = client.table('gita_verses').select('*').eq('gv_chapter_id', 13).order('gv_verses_id').execute()

print(f"\nChapter 13 has {len(ch13_verses.data)} verses in your database")
print("\nVerse IDs:")
verse_ids = [v['gv_verses_id'] for v in ch13_verses.data]
print(f"  {verse_ids}")

if 0 in verse_ids:
    print("\n⚠️ Note: Verse 0 detected! Some traditions include an introductory verse numbered as 0.")
    v0 = [v for v in ch13_verses.data if v['gv_verses_id'] == 0][0]
    print(f"  Verse 13.0 text: \"{v0['gv_verses'][:100]}...\"")
