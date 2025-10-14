import os
from dotenv import load_dotenv
from supabase import create_client

load_dotenv()
client = create_client(os.getenv('SUPABASE_URL'), os.getenv('SUPABASE_KEY'))

# Get verse counts per chapter
verses = client.table('gita_verses').select('gv_chapter_id, gv_verses_id').order('gv_chapter_id, gv_verses_id').execute()

# Expected verse counts per chapter (standard Bhagavad Gita)
expected = [47, 72, 43, 42, 29, 47, 30, 28, 34, 42, 55, 20, 35, 27, 20, 24, 28, 78]

print("Chapter-wise Verse Count Analysis:")
print("="*60)

chapter_counts = {}
for verse in verses.data:
    ch = verse['gv_chapter_id']
    chapter_counts[ch] = chapter_counts.get(ch, 0) + 1

total_verses = 0
issues_found = []

for ch in range(1, 19):
    actual = chapter_counts.get(ch, 0)
    expect = expected[ch - 1]
    total_verses += actual

    status = "✅" if actual == expect else "❌"
    print(f"Chapter {ch:2d}: {actual:2d} verses (expected {expect:2d}) {status}")

    if actual != expect:
        issues_found.append({
            'chapter': ch,
            'actual': actual,
            'expected': expect,
            'difference': actual - expect
        })

print("="*60)
print(f"Total: {total_verses} verses (expected 700)")
print()

if issues_found:
    print("🔍 Chapters with verse count discrepancies:")
    for issue in issues_found:
        print(f"   Chapter {issue['chapter']}: {issue['actual']} verses (expected {issue['expected']}, difference: {issue['difference']:+d})")
    print()

    # Find duplicate or extra verses in problematic chapters
    for issue in issues_found:
        ch = issue['chapter']
        print(f"\n📋 All verses in Chapter {ch}:")
        chapter_verses = [v for v in verses.data if v['gv_chapter_id'] == ch]
        for v in chapter_verses:
            print(f"   {ch}.{v['gv_verses_id']}")
