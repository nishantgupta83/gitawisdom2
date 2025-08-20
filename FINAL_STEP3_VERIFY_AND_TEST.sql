-- STEP 3: VERIFY CONSOLIDATION SUCCESS
-- Run this after STEP 2 to verify everything worked correctly

-- Final category distribution (should show 10 main categories)
SELECT 'FINAL CATEGORY DISTRIBUTION:' as info, '' as category, 0 as count WHERE false
UNION ALL
SELECT '', category, COUNT(*) as count 
FROM scenario_translations 
GROUP BY category 
ORDER BY count DESC;

-- Verify all 10 expected categories exist
SELECT 'EXPECTED CATEGORIES CHECK:' as info, 
CASE 
  WHEN EXISTS (SELECT 1 FROM scenario_translations WHERE category = 'Work & Career') THEN '✅ Work & Career'
  ELSE '❌ Work & Career MISSING'
END as status
UNION ALL
SELECT '', CASE 
  WHEN EXISTS (SELECT 1 FROM scenario_translations WHERE category = 'Relationships') THEN '✅ Relationships'
  ELSE '❌ Relationships MISSING'
END
UNION ALL
SELECT '', CASE 
  WHEN EXISTS (SELECT 1 FROM scenario_translations WHERE category = 'Parenting & Family') THEN '✅ Parenting & Family'
  ELSE '❌ Parenting & Family MISSING'
END
UNION ALL
SELECT '', CASE 
  WHEN EXISTS (SELECT 1 FROM scenario_translations WHERE category = 'Personal Growth') THEN '✅ Personal Growth'
  ELSE '❌ Personal Growth MISSING'
END
UNION ALL
SELECT '', CASE 
  WHEN EXISTS (SELECT 1 FROM scenario_translations WHERE category = 'Life Transitions') THEN '✅ Life Transitions'
  ELSE '❌ Life Transitions MISSING'
END
UNION ALL
SELECT '', CASE 
  WHEN EXISTS (SELECT 1 FROM scenario_translations WHERE category = 'Social & Community') THEN '✅ Social & Community'
  ELSE '❌ Social & Community MISSING'
END
UNION ALL
SELECT '', CASE 
  WHEN EXISTS (SELECT 1 FROM scenario_translations WHERE category = 'Health & Wellness') THEN '✅ Health & Wellness'
  ELSE '❌ Health & Wellness MISSING'
END
UNION ALL
SELECT '', CASE 
  WHEN EXISTS (SELECT 1 FROM scenario_translations WHERE category = 'Financial') THEN '✅ Financial'
  ELSE '❌ Financial MISSING'
END;

-- Check tags are properly formatted (PostgreSQL arrays)
SELECT 'TAGS FORMAT VERIFICATION:' as info, scenario_id, category, tags 
FROM scenario_translations 
WHERE tags IS NOT NULL 
LIMIT 10;

-- Count scenarios by main categories (should match Flutter app expectations)
SELECT 'SCENARIO COUNTS BY CATEGORY:' as info, '' as category, 0 as count WHERE false
UNION ALL
SELECT '', 
  CASE category
    WHEN 'Work & Career' THEN '1. Work & Career'
    WHEN 'Relationships' THEN '2. Relationships'  
    WHEN 'Parenting & Family' THEN '3. Parenting & Family'
    WHEN 'Personal Growth' THEN '4. Personal Growth'
    WHEN 'Life Transitions' THEN '5. Life Transitions'
    WHEN 'Social & Community' THEN '6. Social & Community'
    WHEN 'Health & Wellness' THEN '7. Health & Wellness'
    WHEN 'Financial' THEN '8. Financial'
    ELSE '9. ' || category
  END as category,
  COUNT(*) as count
FROM scenario_translations 
GROUP BY category 
ORDER BY 
  CASE category
    WHEN 'Work & Career' THEN 1
    WHEN 'Relationships' THEN 2
    WHEN 'Parenting & Family' THEN 3
    WHEN 'Personal Growth' THEN 4
    WHEN 'Life Transitions' THEN 5
    WHEN 'Social & Community' THEN 6
    WHEN 'Health & Wellness' THEN 7
    WHEN 'Financial' THEN 8
    ELSE 9
  END;