# Codebase Analysis: Chapters Loading Architecture

## Executive Summary

This document provides exact file paths and line numbers for understanding how chapters are loaded from Supabase and where credentials are used.

---

## Answer to Your Research Questions

### 1. How are chapters loaded from Supabase?

**Answer**: Three methods, all in one file:

**File**: `/Users/nishantgupta/Documents/GitaGyan/OldWisdom/lib/services/enhanced_supabase_service.dart`

1. **`fetchChapterSummaries()` (Lines 333-394)**
   - Used by: ChapterScreen 
   - Does: Fetch 18 chapter summaries + scenario counts
   - Returns: `List<ChapterSummary>` 
   - Caching: Permanent Hive cache
   - Network query: Line 352-355 (chapters table) + Line 363-367 (scenarios count)

2. **`fetchAllChapters()` (Lines 460-515)**
   - Used by: HomeScreen
   - Does: Fetch all 18 full chapters
   - Returns: `List<Chapter>`
   - Caching: Session cache + background refresh
   - Network query: Line 502 (calls _fetchChaptersFromNetwork)

3. **`fetchChapterById(id)` (Lines 397-457)**
   - Used by: Parallel loading within _fetchChaptersFromNetwork
   - Does: Fetch single chapter by ID
   - Returns: `Chapter?`
   - Network query: Line 403-416

---

### 2. How is Supabase client initialized with credentials?

**Answer**: Two-step process in two files:

**Step 1: Credentials Defined**
**File**: `/Users/nishantgupta/Documents/GitaGyan/OldWisdom/lib/config/environment.dart`

- Line 12-15: `supabaseUrl` = `String.fromEnvironment('SUPABASE_URL', defaultValue: '')`
- Line 17-20: `supabaseAnonKey` = `String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '')`
- Line 51-53: `isConfigured` getter validates both are non-empty

**Step 2: Client Initialized**
**File**: `/Users/nishantgupta/Documents/GitaGyan/OldWisdom/lib/core/app_initializer.dart`

- Line 61: `Environment.validateConfiguration()` checks credentials
- Line 64-67: `Supabase.initialize(url: Environment.supabaseUrl, anonKey: Environment.supabaseAnonKey)`
- Line 65: Uses `Environment.supabaseUrl`
- Line 66: Uses `Environment.supabaseAnonKey`
- Called from: `lib/main.dart` line 15

---

### 3. Where are Environment.supabaseUrl and Environment.supabaseAnonKey used?

**Answer**: In three places:

**Usage 1: Validation**
**File**: `/Users/nishantgupta/Documents/GitaGyan/OldWisdom/lib/config/environment.dart`
- Line 52: `supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty`

**Usage 2: Initialization**
**File**: `/Users/nishantgupta/Documents/GitaGyan/OldWisdom/lib/core/app_initializer.dart`
- Line 65: `url: Environment.supabaseUrl,`
- Line 66: `anonKey: Environment.supabaseAnonKey,`

**Usage 3: Debug Logging** (optional)
**File**: `/Users/nishantgupta/Documents/GitaGyan/OldWisdom/lib/config/environment.dart`
- Line 69-70: Logs whether credentials are configured

---

### 4. Why chapters might not load if credentials are correct but empty

**Answer**: Credentials must be provided at BUILD TIME (not runtime):

**Root Cause**:
- Line 12 & 17 in `environment.dart`: `String.fromEnvironment()` reads from build environment
- Line 14 & 19: Default value is empty string `''`
- If no `--dart-define` flag provided: Constants default to `''`
- Even if "correct" credentials exist elsewhere, they won't be used unless passed at build time

**Failure Chain**:
1. Build without `--dart-define` flags
   - `Environment.supabaseUrl == ''`
   - `Environment.supabaseAnonKey == ''`

2. App startup (main.dart:15)
   - Calls `AppInitializer.initializeCriticalServices()`
   - Line 61: `Environment.validateConfiguration()` throws if empty

3. If validation is bypassed:
   - Line 64: `Supabase.initialize('', '')` fails silently
   - Client becomes invalid

4. When fetching chapters:
   - Line 352-355 (queries on invalid client)
   - Supabase throws authentication error
   - Line 390-392: Returns empty list

5. UI result:
   - ChapterScreen line 88-112: Shows error or empty state

---

## File Structure & Dependencies

```
main.dart (Entry point)
    ↓
lib/core/app_initializer.dart (Startup logic)
    ├─ calls Environment.validateConfiguration() [line 61]
    └─ calls Supabase.initialize() [line 64-67]
         └─ uses Environment.supabaseUrl [line 65]
         └─ uses Environment.supabaseAnonKey [line 66]
    ↓
lib/config/environment.dart (Credential definitions)
    ├─ defines supabaseUrl [line 12-15]
    ├─ defines supabaseAnonKey [line 17-20]
    └─ provides isConfigured getter [line 51-53]
    ↓
lib/services/service_locator.dart (Service access)
    └─ provides EnhancedSupabaseService [line 14-17]
    ↓
lib/services/enhanced_supabase_service.dart (Database queries)
    ├─ Line 28: Gets Supabase.instance.client
    ├─ fetchChapterSummaries() [333-394]
    ├─ fetchAllChapters() [460-515]
    ├─ fetchChapterById() [397-457]
    └─ _fetchChaptersFromNetwork() [518-541]
    ↓
lib/screens/chapters_screen.dart (UI display)
    ├─ Line 22: Gets service via ServiceLocator
    ├─ Line 42: Calls fetchChapterSummaries()
    └─ Line 86-112: Displays loading/error/empty/chapters
```

---

## Absolute File Paths

All files are in `/Users/nishantgupta/Documents/GitaGyan/OldWisdom/`

| File | Purpose |
|------|---------|
| `lib/main.dart` | Entry point, calls AppInitializer |
| `lib/config/environment.dart` | Credential constants |
| `lib/core/app_initializer.dart` | Supabase initialization |
| `lib/services/service_locator.dart` | Service provider |
| `lib/services/enhanced_supabase_service.dart` | Database service |
| `lib/screens/chapters_screen.dart` | Chapters UI |
| `lib/screens/home_screen.dart` | Home UI (also fetches chapters) |
| `scripts/run_dev.sh` | Development run script |

---

## Key Code Snippets

### Credentials Definition
```dart
// lib/config/environment.dart:12-20
static const String supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: '',
);

static const String supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: '',
);
```

### Supabase Initialization
```dart
// lib/core/app_initializer.dart:61-67
Environment.validateConfiguration();

await Supabase.initialize(
  url: Environment.supabaseUrl,
  anonKey: Environment.supabaseAnonKey,
);
```

### Chapter Fetching
```dart
// lib/services/enhanced_supabase_service.dart:333-355
Future<List<ChapterSummary>> fetchChapterSummaries([String? langCode]) async {
  try {
    // Check cache first
    if (!Hive.isBoxOpen('chapter_summaries_permanent')) {
      await Hive.openBox<ChapterSummary>('chapter_summaries_permanent');
    }
    final cacheBox = Hive.box<ChapterSummary>('chapter_summaries_permanent');
    
    if (cacheBox.isNotEmpty) {
      final cachedSummaries = cacheBox.values.toList();
      return cachedSummaries;  // Instant return
    }

    // Fetch from network if no cache
    final chaptersResponse = await client
        .from('chapters')
        .select('ch_chapter_id, ch_title, ch_subtitle, ch_verse_count')
        .order('ch_chapter_id', ascending: true);
    
    // ... process and cache results
  }
}
```

### Chapter Display
```dart
// lib/screens/chapters_screen.dart:22-54
class _ChapterScreenState extends State<ChapterScreen> {
  final _service = ServiceLocator.instance.enhancedSupabaseService;

  @override
  void initState() {
    super.initState();
    _loadChapters();
  }

  Future<void> _loadChapters() async {
    try {
      final data = await _service.fetchChapterSummaries();
      setState(() { _chapters = data; });
    } catch (e) {
      setState(() => _errorMessage = 'Failed to load chapters: $e');
    }
  }
}
```

---

## Caching Architecture

### Three Cache Layers:

1. **Permanent Cache** (chapter_summaries_permanent)
   - Box: Hive `'chapter_summaries_permanent'`
   - Type: `Box<ChapterSummary>`
   - Location: `enhanced_supabase_service.dart:337-346`
   - Behavior: Checked first, returned instantly if available
   - Saved: Line 382-385

2. **Session Cache** (chapters)
   - Box: Hive `'chapters'`
   - Type: `Box<Chapter>`
   - Location: `enhanced_supabase_service.dart:468-492`
   - Behavior: Returns if exactly 18 chapters cached
   - Saved: Line 505-507

3. **Network Fetch**
   - Queries: `chapters` table + `scenarios` count
   - Location: `enhanced_supabase_service.dart:352-355, 363-367`
   - Behavior: Only if cache empty/incomplete
   - Returns: Empty list if fails

---

## Database Queries

### Query 1: All Chapters
```sql
SELECT ch_chapter_id, ch_title, ch_subtitle, ch_verse_count
FROM chapters
ORDER BY ch_chapter_id ASC;
```
**Location**: `enhanced_supabase_service.dart:352-355`
**Method**: `fetchChapterSummaries()` and `_fetchChaptersFromNetwork()`

### Query 2: Scenario Count (Per Chapter)
```sql
SELECT COUNT(*) 
FROM scenarios 
WHERE sc_chapter = ?;
```
**Location**: `enhanced_supabase_service.dart:363-367`
**Issue**: N+1 pattern (18 queries for 18 chapters)

### Query 3: Full Chapter Detail
```sql
SELECT ch_chapter_id, ch_title, ch_subtitle, ch_summary,
       ch_verse_count, ch_theme, ch_key_teachings, created_at
FROM chapters
WHERE ch_chapter_id = ?;
```
**Location**: `enhanced_supabase_service.dart:403-416`
**Method**: `fetchChapterById()`

---

## How to Fix Empty Credentials Issue

### The Problem
```bash
# Build without credentials
flutter run -d emulator-5554
# Result: Environment.supabaseUrl == ''
#         Environment.supabaseAnonKey == ''
#         Chapters won't load
```

### The Solution
```bash
# Build WITH credentials via --dart-define
flutter run -d emulator-5554 \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your_anon_key
```

### Alternative: Use Run Script
```bash
# Copy .env.development with real credentials
cp .env.development.example .env.development
# Edit with real Supabase credentials
# Then run
./scripts/run_dev.sh
# Script auto-injects credentials
```

---

## Verification Checklist

- [ ] `Environment.supabaseUrl` is not empty
- [ ] `Environment.supabaseAnonKey` is not empty
- [ ] `Environment.isConfigured` returns `true`
- [ ] `Supabase.instance.client` exists
- [ ] `testConnection()` returns `true`
- [ ] Hive box 'chapter_summaries_permanent' has 18 entries
- [ ] Hive box 'chapters' has 18 entries
- [ ] `fetchChapterSummaries()` returns 18 chapters
- [ ] UI displays all 18 chapters

---

## Next Steps for Implementation

Based on your CLAUDE.md instructions to compile and run after each step:

1. **Verify credentials are set** (no code change needed)
   - Run: `flutter run -d <device> --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`
   - Check: App launches without crash

2. **Add debug logging** (optional enhancement)
   - File: `lib/config/environment.dart`
   - Add: Print credentials status at startup
   - Run: `flutter run` and check console output

3. **Test cache behavior** (no code change)
   - Run app with credentials
   - Check Hive boxes populated
   - Test offline mode

4. **Optimize N+1 queries** (future enhancement)
   - File: `lib/services/enhanced_supabase_service.dart`
   - Line: 363-367
   - Change: Use batch query instead of per-chapter

---

## Summary

**Chapters load through this flow:**

```
Build with --dart-define flags
    ↓
Environment loads credentials
    ↓
App initializer validates & initializes Supabase
    ↓
User navigates to Chapters screen
    ↓
Screen loads chapters via enhanced_supabase_service
    ↓
Service checks Hive cache (instant) OR fetches from network
    ↓
UI displays 18 chapters or error/empty state
```

**If credentials are empty:**
- Flow breaks at "App initializer validates"
- Supabase never initializes properly
- All chapter queries fail
- UI shows empty/error state

**This analysis covers:**
- Line-by-line chapter loading flow
- Exact file paths and line numbers
- Credential injection mechanism
- Three caching layers
- Database query patterns
- Why empty credentials cause failure
