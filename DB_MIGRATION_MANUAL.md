# Database Migration Manual Steps

## Phase 1: Performance Indexes & Data Integrity

The SQL migration script is located at: `supabase/migrations/004_quality_fixes.sql`

### Option 1: Execute via Supabase Dashboard (Recommended)

1. Go to https://supabase.com/dashboard
2. Navigate to your project: `wlfwdtdtiedlcczfoslt`
3. Go to SQL Editor
4. Copy and paste the contents of `004_quality_fixes.sql`
5. Click "Run" to execute

### Option 2: Execute via psql (if installed)

```bash
PGPASSWORD="xbQUKAWHkkcaV7Q@" psql \
  -h db.jnzzwknjzigvupwfzfhq.supabase.co \
  -p 5432 \
  -U postgres \
  -d postgres \
  -f supabase/migrations/004_quality_fixes.sql
```

### What This Migration Does:

#### Performance Indexes Created:
1. **idx_scenarios_created_at** - Speeds up pagination queries
2. **idx_scenarios_chapter** - Speeds up chapter filtering
3. **idx_scenarios_chapter_created_at** - Composite index for chapter + sorting
4. **idx_scenarios_category** - Speeds up category filtering

#### Data Integrity Constraints Added:
1. **check_valid_chapter** - Ensures chapter is between 1-18
2. **fk_scenarios_chapter** - Foreign key reference to chapters table

### Expected Performance Improvements:
- **5-10x** faster paginated queries
- **3-5x** faster chapter-specific queries
- Instant category filtering
- Better query planning by PostgreSQL

### Verification:

After running the migration, verify with:

```sql
-- Check indexes
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'scenarios';

-- Check constraints
SELECT conname, pg_get_constraintdef(oid)
FROM pg_constraint
WHERE conrelid = 'scenarios'::regclass;
```

## Status

✅ SQL migration file created: `supabase/migrations/004_quality_fixes.sql`
⏳ **ACTION REQUIRED**: Execute the migration via Supabase Dashboard SQL Editor

The app will continue to work without these optimizations, but performance will improve significantly once applied.
