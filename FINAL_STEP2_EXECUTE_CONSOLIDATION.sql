-- STEP 2: CATEGORY CONSOLIDATION - EXECUTE AFTER STEP 1
-- ⚠️  IMPORTANT: Run STEP 1 first to see current state
-- Copy and paste this into Supabase Dashboard → SQL Editor → Run

-- Start transaction for safety
BEGIN;

-- ===========================================
-- 1. WORK & CAREER CONSOLIDATION
-- ===========================================

-- academic_pressure_exam_anxiety -> Work & Career
UPDATE scenario_translations 
SET category = 'Work & Career', tags = ARRAY['academic-stress', 'exam-anxiety']
WHERE category = 'academic_pressure_exam_anxiety';

-- job_insecurity_economic_downturn -> Work & Career  
UPDATE scenario_translations 
SET category = 'Work & Career', tags = ARRAY['job-security', 'economic-uncertainty']
WHERE category = 'job_insecurity_economic_downturn';

-- side_hustle_struggles -> Work & Career
UPDATE scenario_translations 
SET category = 'Work & Career', tags = ARRAY['side-hustle', 'entrepreneurship']
WHERE category = 'side_hustle_struggles';

-- work_life_balance -> Work & Career
UPDATE scenario_translations 
SET category = 'Work & Career', tags = ARRAY['work-balance', 'time-management']
WHERE category = 'work_life_balance';

-- business -> Work & Career
UPDATE scenario_translations 
SET category = 'Work & Career', tags = ARRAY['business', 'entrepreneurship']
WHERE category = 'business';

-- career -> Work & Career  
UPDATE scenario_translations 
SET category = 'Work & Career', tags = ARRAY['career-growth', 'professional-development']
WHERE category = 'career';

-- ===========================================
-- 2. RELATIONSHIPS CONSOLIDATION  
-- ===========================================

-- dating_app_fatigue -> Relationships
UPDATE scenario_translations 
SET category = 'Relationships', tags = ARRAY['dating', 'modern-dating']
WHERE category = 'dating_app_fatigue';

-- postponed_marriage_expectations -> Relationships
UPDATE scenario_translations 
SET category = 'Relationships', tags = ARRAY['marriage', 'social-expectations']
WHERE category = 'postponed_marriage_expectations';

-- marriage -> Relationships
UPDATE scenario_translations 
SET category = 'Relationships', tags = ARRAY['marriage', 'partnership']
WHERE category = 'marriage';

-- friendship -> Relationships
UPDATE scenario_translations 
SET category = 'Relationships', tags = ARRAY['friendship', 'social-connections']
WHERE category = 'friendship';

-- relationships -> Relationships (already correct, just update tags)
UPDATE scenario_translations 
SET tags = ARRAY['family-dynamics', 'communication']
WHERE category = 'relationships';

-- ===========================================
-- 3. PERSONAL GROWTH CONSOLIDATION
-- ===========================================

-- rediscovering_identity -> Personal Growth
UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['self-discovery', 'identity']
WHERE category = 'rediscovering_identity';

-- habit_building_discipline -> Personal Growth  
UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['habits', 'discipline']
WHERE category = 'habit_building_discipline';

-- mental_health -> Personal Growth
UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['mental-wellness', 'self-care']
WHERE category = 'mental_health';

-- personal_growth -> Personal Growth (already correct, just update tags)
UPDATE scenario_translations 
SET tags = ARRAY['personal-development', 'self-improvement']
WHERE category = 'personal_growth';

-- ===========================================
-- 4. LIFE TRANSITIONS CONSOLIDATION
-- ===========================================

-- fear_missing_life_milestones -> Life Transitions
UPDATE scenario_translations 
SET category = 'Life Transitions', tags = ARRAY['milestones', 'life-stages']
WHERE category = 'fear_missing_life_milestones';

-- decisions -> Life Transitions
UPDATE scenario_translations 
SET category = 'Life Transitions', tags = ARRAY['major-decisions', 'choice-making']
WHERE category = 'decisions';

-- divorce -> Life Transitions
UPDATE scenario_translations 
SET category = 'Life Transitions', tags = ARRAY['separation', 'relationship-endings']
WHERE category = 'divorce';

-- ===========================================
-- 5. SOCIAL & COMMUNITY CONSOLIDATION
-- ===========================================

-- loneliness_in_crowded_cities -> Social & Community
UPDATE scenario_translations 
SET category = 'Social & Community', tags = ARRAY['urban-loneliness', 'isolation']
WHERE category = 'loneliness_in_crowded_cities';

-- ===========================================
-- 6. HEALTH & WELLNESS CONSOLIDATION
-- ===========================================

-- climate_and_environmental_anxiety -> Health & Wellness
UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['climate-anxiety', 'environmental-concerns']
WHERE category = 'climate_and_environmental_anxiety';

-- digital_detox_focus -> Health & Wellness
UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['digital-wellness', 'screen-time']
WHERE category = 'digital_detox_focus';

-- self_image_body_confidence -> Health & Wellness
UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['body-confidence', 'self-image']
WHERE category = 'self_image_body_confidence';

-- ===========================================  
-- 7. PARENTING & FAMILY CONSOLIDATION
-- ===========================================

-- parenting -> Parenting & Family (already good, just update tags)
UPDATE scenario_translations 
SET category = 'Parenting & Family', tags = ARRAY['parenting', 'child-development']
WHERE category = 'parenting';

-- caregiving -> Parenting & Family
UPDATE scenario_translations 
SET category = 'Parenting & Family', tags = ARRAY['elder-care', 'family-responsibility']
WHERE category = 'caregiving';

-- ===========================================
-- 8. FINANCIAL CONSOLIDATION  
-- ===========================================

-- financial -> Financial (already good, just update tags)
UPDATE scenario_translations 
SET tags = ARRAY['financial-planning', 'money-management']
WHERE category = 'financial';

-- ===========================================
-- VERIFICATION QUERIES
-- ===========================================

-- Check results
SELECT 'CONSOLIDATED CATEGORIES RESULT:' as info, '' as category, 0 as count WHERE false
UNION ALL
SELECT '', category, COUNT(*) as count 
FROM scenario_translations 
GROUP BY category 
ORDER BY count DESC;

-- Check for any remaining underscore categories
SELECT 'REMAINING UNDERSCORE CATEGORIES (SHOULD BE EMPTY):' as info, '' as category, 0 as count WHERE false
UNION ALL
SELECT '', category, COUNT(*) as count 
FROM scenario_translations 
WHERE category LIKE '%_%' 
GROUP BY category 
ORDER BY count DESC;

-- Commit the changes
COMMIT;

-- SUCCESS MESSAGE
SELECT '✅ CATEGORY CONSOLIDATION COMPLETE!' as result;