-- Verification script for database normalization
-- Run this after executing the normalization to verify changes

-- 1. Check for any remaining categories with underscores
SELECT 'Categories with underscores (should be empty):' as check_type;
SELECT category, COUNT(*) as count 
FROM scenario_translations 
WHERE category LIKE '%_%' 
GROUP BY category 
ORDER BY count DESC;

-- 2. Count scenarios by normalized categories (Top 10)
SELECT 'Top 10 normalized categories:' as check_type;
SELECT category, COUNT(*) as count 
FROM scenario_translations 
GROUP BY category 
ORDER BY count DESC 
LIMIT 10;

-- 3. Check specific normalized categories
SELECT 'Normalized categories created:' as check_type;
SELECT category, COUNT(*) as count 
FROM scenario_translations 
WHERE category IN (
  'academic pressure',
  'job security', 
  'life milestones',
  'climate anxiety',
  'identity',
  'digital wellness',
  'side hustles',
  'dating apps',
  'urban loneliness',
  'habits',
  'marriage expectations',
  'body confidence'
)
GROUP BY category 
ORDER BY count DESC;

-- 4. Verify PostgreSQL ARRAY format for tags
SELECT 'Sample tags format verification:' as check_type;
SELECT scenario_id, category, tags 
FROM scenario_translations 
WHERE category = 'academic pressure' 
LIMIT 5;

-- 5. Check tag uniqueness and format
SELECT 'Tag format analysis:' as check_type;
SELECT 
  category,
  COUNT(DISTINCT tags[1]) as unique_first_tags,
  COUNT(*) as total_scenarios
FROM scenario_translations 
WHERE category IN ('academic pressure', 'job security', 'climate anxiety')
GROUP BY category;