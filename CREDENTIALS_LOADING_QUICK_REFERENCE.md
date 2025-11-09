# Credentials & Chapters Loading - Quick Reference

## TL;DR

**Chapters won't load if:**
- Credentials are empty (`SUPABASE_URL=''` or `SUPABASE_ANON_KEY=''`)
- Missing `--dart-define` flags at build time
- Supabase client initialization fails

**Fix:**
```bash
flutter run -d <device> \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your_key
```

---

## File Paths & Line Numbers

### 1. CREDENTIALS DEFINED
**File**: `/Users/nishantgupta/Documents/GitaGyan/OldWisdom/lib/config/environment.dart`

| What | Lines | Details |
|------|-------|---------|
| supabaseUrl constant | 12-15 | `String.fromEnvironment('SUPABASE_URL')` |
| supabaseAnonKey constant | 17-20 | `String.fromEnvironment('SUPABASE_ANON_KEY')` |
| isConfigured getter | 51-53 | Returns `true` only if both non-empty |
| validateConfiguration() | 60-74 | Throws if not configured |

### 2. SUPABASE INITIALIZED
**File**: `/Users/nishantgupta/Documents/GitaGyan/OldWisdom/lib/core/app_initializer.dart`

| What | Lines | Details |
|------|-------|---------|
| Validation called | 61 | `Environment.validateConfiguration()` |
| Supabase.initialize() | 64-67 | Uses Environment.supabaseUrl/supabaseAnonKey |
| Called from | main.dart:15 | In `AppInitializer.initializeCriticalServices()` |

### 3. CHAPTERS FETCHED
**File**: `/Users/nishantgupta/Documents/GitaGyan/OldWisdom/lib/services/enhanced_supabase_service.dart`

| Method | Lines | Purpose |
|--------|-------|---------|
| fetchChapterSummaries() | 333-394 | Get all 18 chapters + scenario counts |
| fetchAllChapters() | 460-515 | Get all 18 chapters (used by home) |
| fetchChapterById(id) | 397-457 | Get single chapter by ID |
| _fetchChaptersFromNetwork() | 518-541 | Parallel fetch all 18 chapters |
| testConnection() | 43-54 | Test Supabase connectivity |

### 4. CHAPTERS DISPLAYED
**File**: `/Users/nishantgupta/Documents/GitaGyan/OldWisdom/lib/screens/chapters_screen.dart`

| What | Lines | Details |
|------|-------|---------|
| Service initialized | 22 | `ServiceLocator.instance.enhancedSupabaseService` |
| Load chapters | 30 | Called in initState() |
| Fetch called | 42 | `_service.fetchChapterSummaries()` |
| Loading state | 86 | Shows spinner while loading |
| Error state | 88-104 | Shows error message with retry button |
| Empty state | 106-112 | Shows "No chapters available" |
| Display chapters | 113+ | ListView shows all chapters |

---

## Supabase Client Access Chain

```
Environment.supabaseUrl
Environment.supabaseAnonKey
    ↓
Supabase.initialize() [app_initializer.dart:64-67]
    ↓
Supabase.instance.client [singleton]
    ↓
enhanced_supabase_service.dart:28
    final SupabaseClient client = Supabase.instance.client;
    ↓
Used in all database queries:
    - client.from('chapters')
    - client.from('scenarios')
    - client.from('gita_verses')
```

---

## Caching Strategy

### Cache Layer 1: Permanent (fetchChapterSummaries)
```dart
Box<ChapterSummary> 'chapter_summaries_permanent'
├─ Checked first [line 343-346]
├─ Returns instantly if available
└─ Saved after network fetch [line 382-385]
```

### Cache Layer 2: Session (fetchAllChapters)
```dart
Box<Chapter> 'chapters'
├─ Checked first [line 468-476]
├─ Used if exactly 18 chapters cached [line 477]
├─ Background refresh triggered [line 481-490]
└─ Saved after network fetch [line 505-507]
```

### Cache Layer 3: Network
```dart
Direct Supabase queries
├─ chapters table [line 352-355]
├─ scenarios count per chapter [line 363-367]
└─ Returned as empty list if fails [line 390-392]
```

---

## Database Queries

### Query 1: Get All Chapter Summaries
```sql
SELECT ch_chapter_id, ch_title, ch_subtitle, ch_verse_count
FROM chapters
ORDER BY ch_chapter_id ASC
```
**Called in**: `fetchChapterSummaries()` line 352-355

### Query 2: Count Scenarios per Chapter
```sql
SELECT COUNT(*) as count
FROM scenarios
WHERE sc_chapter = ?
```
**Called in**: `fetchChapterSummaries()` line 363-367
**Issue**: N+1 pattern (18 queries for 18 chapters)

### Query 3: Get Full Chapter Detail
```sql
SELECT ch_chapter_id, ch_title, ch_subtitle, ch_summary, 
       ch_verse_count, ch_theme, ch_key_teachings, created_at
FROM chapters
WHERE ch_chapter_id = ?
```
**Called in**: `fetchChapterById()` line 403-416

---

## Failure Scenarios & Fixes

### Scenario 1: Empty Credentials at Build Time

**Symptoms**: App crashes or chapters list is empty

**Root Cause**: 
- No `--dart-define` flags
- `Environment.supabaseUrl == ''`
- `Environment.supabaseAnonKey == ''`

**Fix**:
```bash
flutter run -d <device> \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your_key
```

### Scenario 2: Supabase Client Not Initialized

**Symptoms**: "Supabase not initialized" error

**Root Cause**:
- Supabase.initialize() at line 64-67 failed
- Invalid credentials provided
- Network unavailable at startup

**Fix**:
1. Check credentials are correct
2. Test network connectivity
3. Check app_initializer.dart line 61-67 runs without error

### Scenario 3: Chapters Load But Empty List

**Symptoms**: User sees "No chapters available"

**Root Cause**:
- Network fetch failed (line 352-355 throws error)
- No cache available (first run)
- Supabase query returned 0 results

**Fix**:
1. Verify Supabase chapters table has data
2. Check Supabase credentials have correct permissions
3. Test with `testConnection()` method

### Scenario 4: Chapters Load Slowly

**Symptoms**: Long loading time on first run

**Root Cause**:
- N+1 query pattern for scenario counts
- Serial database queries instead of parallel
- Network latency

**Fix**:
1. Use cached version (subsequent loads)
2. Optimize scenario count queries in future
3. Consider batch queries instead of N+1

### Scenario 5: Cached Chapters Are Stale

**Symptoms**: Changes in Supabase don't appear in app

**Root Cause**:
- Permanent cache in Hive box not invalidated
- Background refresh failed

**Fix**:
1. Clear app data/cache
2. Reinstall app
3. Or add cache invalidation timestamp

---

## Environment Configuration

### How Credentials Are Stored
```dart
// lib/config/environment.dart:12-20

static const String supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: '', // Empty if not provided
);

static const String supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: '', // Empty if not provided
);
```

### How to Provide Credentials

**Option 1: Direct CLI**
```bash
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your_anon_key
```

**Option 2: Via Script** (scripts/run_dev.sh)
```bash
./scripts/run_dev.sh
# Reads from .env.development and injects credentials
```

**Option 3: Build APK/AAB**
```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your_anon_key
```

---

## Verification Steps

### 1. Check Credentials Are Set
```dart
print(Environment.supabaseUrl);      // Should not be empty
print(Environment.supabaseAnonKey);  // Should not be empty
print(Environment.isConfigured);     // Should be true
```

### 2. Check Supabase Client Exists
```dart
final client = Supabase.instance.client;
print(client);  // Should print SupabaseClient instance
```

### 3. Test Connection
```dart
final service = ServiceLocator.instance.enhancedSupabaseService;
final connected = await service.testConnection();
print(connected);  // Should be true
```

### 4. Check Cache
```dart
if (Hive.isBoxOpen('chapter_summaries_permanent')) {
  final box = Hive.box<ChapterSummary>('chapter_summaries_permanent');
  print(box.length);  // Should be 18 if cached
}
```

### 5. Fetch and Display
```dart
final summaries = await service.fetchChapterSummaries();
print(summaries.length);  // Should be 18
for (var s in summaries) {
  print('Chapter ${s.chapterId}: ${s.title}');
}
```

---

## Key Takeaways

1. **Credentials are build-time constants** - Must provide `--dart-define` flags
2. **Empty credentials cause instant failure** - App crashes or shows empty data
3. **Three caching layers prevent data loss** - Even if network fails later, cache works
4. **18 chapters are always expected** - Any other number means loading failed
5. **Parallel loading is used** - All 18 chapters loaded in parallel via `Future.wait()`
6. **N+1 query pattern exists** - Scenario counts fetched per chapter (not batch)

---

## Related Files

- **Main entry**: `/Users/nishantgupta/Documents/GitaGyan/OldWisdom/lib/main.dart`
- **Initializer**: `/Users/nishantgupta/Documents/GitaGyan/OldWisdom/lib/core/app_initializer.dart`
- **Env config**: `/Users/nishantgupta/Documents/GitaGyan/OldWisdom/lib/config/environment.dart`
- **Service**: `/Users/nishantgupta/Documents/GitaGyan/OldWisdom/lib/services/enhanced_supabase_service.dart`
- **Service locator**: `/Users/nishantgupta/Documents/GitaGyan/OldWisdom/lib/services/service_locator.dart`
- **UI screen**: `/Users/nishantgupta/Documents/GitaGyan/OldWisdom/lib/screens/chapters_screen.dart`
- **Home screen**: `/Users/nishantgupta/Documents/GitaGyan/OldWisdom/lib/screens/home_screen.dart`
- **Run script**: `/Users/nishantgupta/Documents/GitaGyan/OldWisdom/scripts/run_dev.sh`
