-- FIX: Update main scenarios table sc_category field to match scenario_translations
-- This fixes the issue where English language queries use outdated categories

BEGIN;

-- Update main scenarios table to match the consolidated categories from scenario_translations
-- We'll copy the category values from scenario_translations to scenarios.sc_category

UPDATE scenarios 
SET sc_category = st.category
FROM scenario_translations st 
WHERE scenarios.scenario_id = st.scenario_id 
AND st.lang_code = 'en';

-- Verify the update worked
SELECT 'MAIN SCENARIOS TABLE CATEGORIES:' as info, '' as category, 0 as count WHERE false
UNION ALL
SELECT '', sc_category, COUNT(*) as count 
FROM scenarios 
GROUP BY sc_category 
ORDER BY count DESC;

-- Verify consistency between tables
SELECT 'CONSISTENCY CHECK:' as info, 
  CASE 
    WHEN s.sc_category = st.category THEN '✅ CONSISTENT'
    ELSE '❌ MISMATCH: scenarios.sc_category=' || s.sc_category || ' vs scenario_translations.category=' || st.category
  END as status
FROM scenarios s
JOIN scenario_translations st ON s.scenario_id = st.scenario_id AND st.lang_code = 'en'
WHERE s.sc_category != st.category
LIMIT 10;

COMMIT;

SELECT '🎉 Main scenarios table updated! Flutter app should now show correct category counts.' as result;