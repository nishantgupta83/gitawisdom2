-- ===================================================================
-- GitaWisdom Scenarios Table - Phase 1 Quality Fixes
-- Migration 004: Critical performance and data integrity fixes
-- ===================================================================

BEGIN;

-- ===================================================================
-- SECTION 1: PERFORMANCE INDEXES (CRITICAL)
-- ===================================================================

-- 1.1: Index for pagination queries (ORDER BY created_at)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_scenarios_created_at
ON scenarios(created_at DESC);

-- 1.2: Index for chapter filtering
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_scenarios_chapter
ON scenarios(sc_chapter);

-- 1.3: Composite index for common pattern: chapter + sorting
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_scenarios_chapter_created_at
ON scenarios(sc_chapter, created_at DESC);

-- 1.4: Index for category filtering
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_scenarios_category
ON scenarios(sc_category);

-- ===================================================================
-- SECTION 2: DATA INTEGRITY CONSTRAINTS
-- ===================================================================

-- 2.1: Add chapter range validation (1-18 for Bhagavad Gita)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'check_valid_chapter'
  ) THEN
    ALTER TABLE scenarios
    ADD CONSTRAINT check_valid_chapter
    CHECK (sc_chapter >= 1 AND sc_chapter <= 18);
  END IF;
END;
$$;

-- 2.2: Add foreign key to chapters table (if not exists)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'fk_scenarios_chapter'
  ) THEN
    ALTER TABLE scenarios
    ADD CONSTRAINT fk_scenarios_chapter
    FOREIGN KEY (sc_chapter) REFERENCES chapters(ch_chapter_id);
  END IF;
END;
$$;

-- ===================================================================
-- SECTION 3: VERIFICATION QUERIES
-- ===================================================================

-- Verify indexes were created
SELECT
  tablename,
  indexname,
  indexdef
FROM pg_indexes
WHERE tablename = 'scenarios'
  AND indexname IN (
    'idx_scenarios_created_at',
    'idx_scenarios_chapter',
    'idx_scenarios_chapter_created_at',
    'idx_scenarios_category'
  )
ORDER BY indexname;

-- Verify constraints were created
SELECT
  conname as constraint_name,
  contype as constraint_type,
  pg_get_constraintdef(oid) as definition
FROM pg_constraint
WHERE conrelid = 'scenarios'::regclass
  AND conname IN ('check_valid_chapter', 'fk_scenarios_chapter');

-- Performance test: Paginated query
EXPLAIN ANALYZE
SELECT * FROM scenarios
ORDER BY created_at DESC
LIMIT 50 OFFSET 0;

-- Performance test: Chapter filter
EXPLAIN ANALYZE
SELECT * FROM scenarios
WHERE sc_chapter = 1
ORDER BY created_at DESC;

COMMIT;

-- ===================================================================
-- ROLLBACK SCRIPT (if needed)
-- ===================================================================
-- DROP INDEX CONCURRENTLY IF EXISTS idx_scenarios_created_at;
-- DROP INDEX CONCURRENTLY IF EXISTS idx_scenarios_chapter;
-- DROP INDEX CONCURRENTLY IF EXISTS idx_scenarios_chapter_created_at;
-- DROP INDEX CONCURRENTLY IF EXISTS idx_scenarios_category;
-- ALTER TABLE scenarios DROP CONSTRAINT IF EXISTS check_valid_chapter;
-- ALTER TABLE scenarios DROP CONSTRAINT IF EXISTS fk_scenarios_chapter;
