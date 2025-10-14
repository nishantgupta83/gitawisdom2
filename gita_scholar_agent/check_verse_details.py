import os
from dotenv import load_dotenv
from supabase import create_client

load_dotenv()
client = create_client(os.getenv('SUPABASE_URL'), os.getenv('SUPABASE_KEY'))

# Get ALL verses without filtering
result = client.table('gita_verses').select('*').execute()

print(f"Total rows in gita_verses table: {len(result.data)}")
print("="*60)

# Check for verses with chapter_id outside 1-18
unusual_verses = [v for v in result.data if v['gv_chapter_id'] < 1 or v['gv_chapter_id'] > 18]

if unusual_verses:
    print(f"\n❌ Found {len(unusual_verses)} verse(s) with unusual chapter_id:")
    for v in unusual_verses:
        print(f"   Chapter {v['gv_chapter_id']}, Verse {v['gv_verses_id']}")
        text_preview = v['gv_verses'][:100] + "..." if len(v['gv_verses']) > 100 else v['gv_verses']
        print(f"   Text: \"{text_preview}\"")
        print()
else:
    print("✅ All verses have chapter_id between 1-18")

# Check for NULL chapter_id
null_chapter = [v for v in result.data if v.get('gv_chapter_id') is None]
if null_chapter:
    print(f"\n❌ Found {len(null_chapter)} verse(s) with NULL chapter_id")

# List all unique chapter_ids
all_chapters = sorted(set(v['gv_chapter_id'] for v in result.data))
print(f"\nUnique chapter_ids in database: {all_chapters}")

# Count verses per chapter ID actually present
print("\nActual verse counts from raw data:")
from collections import Counter
chapter_counts = Counter(v['gv_chapter_id'] for v in result.data)
for ch in sorted(chapter_counts.keys()):
    print(f"  Chapter {ch}: {chapter_counts[ch]} verses")

total = sum(chapter_counts.values())
print(f"\nTotal: {total} verses")
