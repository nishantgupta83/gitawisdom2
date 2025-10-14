import os
from dotenv import load_dotenv
from supabase import create_client
from collections import Counter

load_dotenv()
client = create_client(os.getenv('SUPABASE_URL'), os.getenv('SUPABASE_KEY'))

# Get all verses
verses = client.table('gita_verses').select('gv_chapter_id, gv_verses_id, gv_verses').order('gv_chapter_id, gv_verses_id').execute()

print("🔍 Searching for duplicate verses...")
print("="*60)

# Check for duplicate (chapter_id, verse_id) combinations
verse_keys = []
for verse in verses.data:
    key = (verse['gv_chapter_id'], verse['gv_verses_id'])
    verse_keys.append(key)

# Count occurrences
key_counts = Counter(verse_keys)

# Find duplicates
duplicates = [(key, count) for key, count in key_counts.items() if count > 1]

if duplicates:
    print(f"❌ Found {len(duplicates)} duplicate verse(s):")
    print()
    for (ch, v), count in duplicates:
        print(f"   Verse {ch}.{v} appears {count} times")
        print(f"   Fetching details...")

        # Get all instances of this verse
        dup_verses = [verse for verse in verses.data
                     if verse['gv_chapter_id'] == ch and verse['gv_verses_id'] == v]

        for i, dup in enumerate(dup_verses, 1):
            text_preview = dup['gv_verses'][:100] + "..." if len(dup['gv_verses']) > 100 else dup['gv_verses']
            print(f"      Instance {i}: \"{text_preview}\"")
        print()
else:
    print("✅ No duplicate (chapter, verse) combinations found")
    print()
    print("Checking for gaps in verse numbering...")

    # Check each chapter for gaps
    for ch in range(1, 19):
        chapter_verses = sorted([v['gv_verses_id'] for v in verses.data if v['gv_chapter_id'] == ch])
        expected_range = list(range(1, len(chapter_verses) + 1))

        if chapter_verses != expected_range:
            print(f"\n❌ Chapter {ch} has irregular verse numbering:")
            print(f"   Found: {chapter_verses}")
            print(f"   Expected: {expected_range}")

            # Find the extra verse
            for v in chapter_verses:
                if chapter_verses.count(v) > 1:
                    print(f"   ⚠️ Verse {v} appears multiple times!")

print("="*60)
