-- STEP 1: EXPLORE CURRENT DATABASE STATE
-- Copy and paste this into Supabase Dashboard → SQL Editor → Run

-- Check total scenario count
SELECT 'TOTAL SCENARIOS:' as info, COUNT(*) as count FROM scenario_translations;

-- Check current categories (top 20)
SELECT 'CURRENT CATEGORIES (TOP 20):' as info, '' as category, 0 as count WHERE false
UNION ALL
SELECT '', category, COUNT(*) as count 
FROM scenario_translations 
GROUP BY category 
ORDER BY count DESC 
LIMIT 20;

-- Check categories with underscores (these need to be consolidated)
SELECT 'CATEGORIES WITH UNDERSCORES (NEED FIXING):' as info, '' as category, 0 as count WHERE false
UNION ALL  
SELECT '', category, COUNT(*) as count 
FROM scenario_translations 
WHERE category LIKE '%_%' 
GROUP BY category 
ORDER BY count DESC;

-- Check if consolidated categories already exist
SELECT 'ALREADY CONSOLIDATED CATEGORIES:' as info, '' as category, 0 as count WHERE false
UNION ALL
SELECT '', category, COUNT(*) as count 
FROM scenario_translations 
WHERE category IN (
  'Work & Career',
  'Relationships', 
  'Parenting & Family',
  'Personal Growth',
  'Life Transitions',
  'Social & Community',
  'Health & Wellness',
  'Financial',
  'Education & Learning',
  'Modern Living'
)
GROUP BY category
ORDER BY count DESC;

-- Sample tags format check
SELECT 'SAMPLE TAGS FORMAT:' as info, scenario_id, category, tags 
FROM scenario_translations 
WHERE tags IS NOT NULL 
LIMIT 5;