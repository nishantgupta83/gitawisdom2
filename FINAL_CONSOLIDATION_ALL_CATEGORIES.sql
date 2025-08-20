-- FINAL CATEGORY CONSOLIDATION - STEP 2
-- Execute this after UPDATE_227_UNDERSCORE_CATEGORIES.sql
-- This consolidates ALL remaining categories to our 10 target categories

BEGIN;

-- ===========================================
-- CONSOLIDATE TO PERSONAL GROWTH
-- ===========================================

-- personal: 112 -> Personal Growth
UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['personal-development', 'self-improvement']
WHERE category = 'personal';

-- spiritual: 25 -> Personal Growth  
UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['spiritual-growth', 'inner-development']
WHERE category = 'spiritual';

-- ethics: 22 -> Personal Growth
UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['ethics', 'moral-decisions']
WHERE category = 'ethics';

-- faith_crisis_spiritual_search: 9 -> Personal Growth
UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['spiritual-crisis', 'faith-exploration']
WHERE category = 'faith_crisis_spiritual_search';

-- ===========================================
-- CONSOLIDATE TO HEALTH & WELLNESS
-- ===========================================

-- neurodiversity: 97 -> Health & Wellness
UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['neurodiversity', 'mental-health']
WHERE category = 'neurodiversity';

-- mentalHealth: 43 -> Health & Wellness
UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['mental-health', 'emotional-wellness']
WHERE category = 'mentalHealth';

-- mental health: 11 -> Health & Wellness
UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['mental-health', 'emotional-wellness']
WHERE category = 'mental health';

-- lifestyle: 12 -> Health & Wellness
UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['lifestyle', 'wellness']
WHERE category = 'lifestyle';

-- ===========================================
-- CONSOLIDATE TO RELATIONSHIPS
-- ===========================================

-- relationships: 97 -> Relationships (fix lowercase)
UPDATE scenario_translations 
SET category = 'Relationships', tags = ARRAY['relationships', 'connections']
WHERE category = 'relationships';

-- friendships: 22 -> Relationships
UPDATE scenario_translations 
SET category = 'Relationships', tags = ARRAY['friendships', 'social-bonds']
WHERE category = 'friendships';

-- ===========================================
-- CONSOLIDATE TO WORK & CAREER
-- ===========================================

-- work: 94 -> Work & Career
UPDATE scenario_translations 
SET category = 'Work & Career', tags = ARRAY['work', 'professional-life']
WHERE category = 'work';

-- workplace: 19 -> Work & Career
UPDATE scenario_translations 
SET category = 'Work & Career', tags = ARRAY['workplace', 'office-dynamics']
WHERE category = 'workplace';

-- ===========================================
-- CONSOLIDATE TO PARENTING & FAMILY
-- ===========================================

-- family: 88 -> Parenting & Family
UPDATE scenario_translations 
SET category = 'Parenting & Family', tags = ARRAY['family-dynamics', 'family-relationships']
WHERE category = 'family';

-- new parents: 24 -> Parenting & Family
UPDATE scenario_translations 
SET category = 'Parenting & Family', tags = ARRAY['new-parents', 'early-parenting']
WHERE category = 'new parents';

-- pregnancy: 13 -> Parenting & Family
UPDATE scenario_translations 
SET category = 'Parenting & Family', tags = ARRAY['pregnancy', 'expecting']
WHERE category = 'pregnancy';

-- caregiving_for_aging_parents: 9 -> Parenting & Family
UPDATE scenario_translations 
SET category = 'Parenting & Family', tags = ARRAY['elder-care', 'aging-parents']
WHERE category = 'caregiving_for_aging_parents';

-- ===========================================
-- CONSOLIDATE TO SOCIAL & COMMUNITY
-- ===========================================

-- social pressure: 26 -> Social & Community
UPDATE scenario_translations 
SET category = 'Social & Community', tags = ARRAY['social-pressure', 'peer-pressure']
WHERE category = 'social pressure';

-- social: 20 -> Social & Community
UPDATE scenario_translations 
SET category = 'Social & Community', tags = ARRAY['social-life', 'community']
WHERE category = 'social';

-- ===========================================
-- CONSOLIDATE TO FINANCIAL
-- ===========================================

-- finances: 15 -> Financial
UPDATE scenario_translations 
SET category = 'Financial', tags = ARRAY['finances', 'money-management']
WHERE category = 'finances';

-- ===========================================
-- CONSOLIDATE TO EDUCATION & LEARNING
-- ===========================================

-- education: 31 -> Education & Learning
UPDATE scenario_translations 
SET category = 'Education & Learning', tags = ARRAY['education', 'learning']
WHERE category = 'education';

-- ===========================================
-- CONSOLIDATE TO MODERN LIVING
-- ===========================================

-- digital: 15 -> Modern Living
UPDATE scenario_translations 
SET category = 'Modern Living', tags = ARRAY['digital-life', 'technology']
WHERE category = 'digital';

-- modern life: 14 -> Modern Living
UPDATE scenario_translations 
SET category = 'Modern Living', tags = ARRAY['modern-lifestyle', 'contemporary-living']
WHERE category = 'modern life';

-- living situation: 11 -> Modern Living
UPDATE scenario_translations 
SET category = 'Modern Living', tags = ARRAY['housing', 'living-arrangements']
WHERE category = 'living situation';

-- ===========================================
-- CONSOLIDATE TO LIFE TRANSITIONS
-- ===========================================

-- life direction: 12 -> Life Transitions
UPDATE scenario_translations 
SET category = 'Life Transitions', tags = ARRAY['life-direction', 'major-decisions']
WHERE category = 'life direction';

-- ===========================================
-- VERIFICATION QUERIES
-- ===========================================

-- Check final category distribution (should show only our 10 categories)
SELECT 'FINAL CONSOLIDATED CATEGORIES:' as info, '' as category, 0 as count WHERE false
UNION ALL
SELECT '', category, COUNT(*) as count 
FROM scenario_translations 
GROUP BY category 
ORDER BY count DESC;

-- Verify we have all 10 expected categories
SELECT 'EXPECTED CATEGORIES CHECK:' as info, 
CASE 
  WHEN EXISTS (SELECT 1 FROM scenario_translations WHERE category = 'Work & Career') THEN '✅ Work & Career: ' || (SELECT COUNT(*) FROM scenario_translations WHERE category = 'Work & Career')
  ELSE '❌ Work & Career MISSING'
END as status
UNION ALL
SELECT '', CASE 
  WHEN EXISTS (SELECT 1 FROM scenario_translations WHERE category = 'Relationships') THEN '✅ Relationships: ' || (SELECT COUNT(*) FROM scenario_translations WHERE category = 'Relationships')
  ELSE '❌ Relationships MISSING'
END
UNION ALL
SELECT '', CASE 
  WHEN EXISTS (SELECT 1 FROM scenario_translations WHERE category = 'Parenting & Family') THEN '✅ Parenting & Family: ' || (SELECT COUNT(*) FROM scenario_translations WHERE category = 'Parenting & Family')
  ELSE '❌ Parenting & Family MISSING'
END
UNION ALL
SELECT '', CASE 
  WHEN EXISTS (SELECT 1 FROM scenario_translations WHERE category = 'Personal Growth') THEN '✅ Personal Growth: ' || (SELECT COUNT(*) FROM scenario_translations WHERE category = 'Personal Growth')
  ELSE '❌ Personal Growth MISSING'
END
UNION ALL
SELECT '', CASE 
  WHEN EXISTS (SELECT 1 FROM scenario_translations WHERE category = 'Life Transitions') THEN '✅ Life Transitions: ' || (SELECT COUNT(*) FROM scenario_translations WHERE category = 'Life Transitions')
  ELSE '❌ Life Transitions MISSING'
END
UNION ALL
SELECT '', CASE 
  WHEN EXISTS (SELECT 1 FROM scenario_translations WHERE category = 'Social & Community') THEN '✅ Social & Community: ' || (SELECT COUNT(*) FROM scenario_translations WHERE category = 'Social & Community')
  ELSE '❌ Social & Community MISSING'
END
UNION ALL
SELECT '', CASE 
  WHEN EXISTS (SELECT 1 FROM scenario_translations WHERE category = 'Health & Wellness') THEN '✅ Health & Wellness: ' || (SELECT COUNT(*) FROM scenario_translations WHERE category = 'Health & Wellness')
  ELSE '❌ Health & Wellness MISSING'
END
UNION ALL
SELECT '', CASE 
  WHEN EXISTS (SELECT 1 FROM scenario_translations WHERE category = 'Financial') THEN '✅ Financial: ' || (SELECT COUNT(*) FROM scenario_translations WHERE category = 'Financial')
  ELSE '❌ Financial MISSING'
END
UNION ALL
SELECT '', CASE 
  WHEN EXISTS (SELECT 1 FROM scenario_translations WHERE category = 'Education & Learning') THEN '✅ Education & Learning: ' || (SELECT COUNT(*) FROM scenario_translations WHERE category = 'Education & Learning')
  ELSE '❌ Education & Learning MISSING'
END
UNION ALL
SELECT '', CASE 
  WHEN EXISTS (SELECT 1 FROM scenario_translations WHERE category = 'Modern Living') THEN '✅ Modern Living: ' || (SELECT COUNT(*) FROM scenario_translations WHERE category = 'Modern Living')
  ELSE '❌ Modern Living MISSING'
END;

-- Check for any remaining unconsolidated categories
SELECT 'REMAINING UNCONSOLIDATED CATEGORIES:' as info, '' as category, 0 as count WHERE false
UNION ALL
SELECT '', category, COUNT(*) as count 
FROM scenario_translations 
WHERE category NOT IN (
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

COMMIT;

SELECT '🎉 FINAL CONSOLIDATION COMPLETE! Categories should now match Flutter app expectations.' as result;