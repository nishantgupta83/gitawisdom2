-- STEP 1: Explore Current Database State
-- Run this first in Supabase Dashboard → SQL Editor

-- Check total scenario count
SELECT 'Total scenarios in database:' as info, COUNT(*) as count FROM scenario_translations;

-- Check current category distribution  
SELECT 'Current categories (top 20):' as info;
SELECT category, COUNT(*) as count 
FROM scenario_translations 
GROUP BY category 
ORDER BY count DESC 
LIMIT 20;

-- Check if we have scenarios with underscores (original problem categories)
SELECT 'Categories with underscores:' as info;
SELECT category, COUNT(*) as count 
FROM scenario_translations 
WHERE category LIKE '%_%' 
GROUP BY category 
ORDER BY count DESC;

-- Check tag format (should be PostgreSQL arrays)
SELECT 'Sample tags format:' as info;
SELECT scenario_id, category, tags 
FROM scenario_translations 
WHERE tags IS NOT NULL 
LIMIT 10;

-- Check if consolidated categories already exist
SELECT 'Consolidated categories (if any):' as info;
SELECT category, COUNT(*) as count 
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