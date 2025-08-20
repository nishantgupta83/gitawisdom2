-- CATEGORY CONSOLIDATION - Reduce to 10 Main Categories
-- PostgreSQL ARRAY syntax with enhanced tag mapping
-- Preserves all scenario context through specific tags

BEGIN;

-- ========================================
-- 1. WORK & CAREER CONSOLIDATION
-- ========================================

-- Academic Pressure -> Work & Career (academic-stress tag)
UPDATE scenario_translations 
SET category = 'Work & Career', tags = ARRAY['academic-stress', 'stress']
WHERE scenario_id = '222bf63e-c6c6-462d-a61f-95d698ec48bf';

UPDATE scenario_translations 
SET category = 'Work & Career', tags = ARRAY['academic-stress', 'anxiety']
WHERE scenario_id = 'f76c8f9b-2fa1-4424-9850-376f47c8e73a';

UPDATE scenario_translations 
SET category = 'Work & Career', tags = ARRAY['academic-stress', 'comparison']
WHERE scenario_id = 'c57d185f-daee-458c-aba0-dc6e7a2abdbe';

UPDATE scenario_translations 
SET category = 'Work & Career', tags = ARRAY['academic-stress', 'balance']
WHERE scenario_id = '4550b448-f17d-4a81-a273-b8b3261a9d32';

UPDATE scenario_translations 
SET category = 'Work & Career', tags = ARRAY['academic-stress', 'fear']
WHERE scenario_id = 'c6b2c731-acba-4ae2-8096-59cba82831fb';

UPDATE scenario_translations 
SET category = 'Work & Career', tags = ARRAY['academic-stress', 'confidence']
WHERE scenario_id = 'a38ed891-002e-4f6e-b34d-1533b585c022';

UPDATE scenario_translations 
SET category = 'Work & Career', tags = ARRAY['academic-stress', 'focus']
WHERE scenario_id = '1f6192e4-419d-419e-81e9-c2d6a9481af4';

UPDATE scenario_translations 
SET category = 'Work & Career', tags = ARRAY['academic-stress', 'comparison']
WHERE scenario_id = '6e55e1c4-f0aa-46b0-aa1d-827c527eaf10';

UPDATE scenario_translations 
SET category = 'Work & Career', tags = ARRAY['academic-stress', 'planning']
WHERE scenario_id = 'd2f2b5ef-a1a7-4b5e-b55d-400942570674';

UPDATE scenario_translations 
SET category = 'Work & Career', tags = ARRAY['academic-stress', 'discipline']
WHERE scenario_id = 'f3206105-68eb-4d66-bf66-455dfd405ea1';

-- Job Security -> Work & Career (job-security tag)
UPDATE scenario_translations 
SET category = 'Work & Career', tags = ARRAY['job-security', 'anxiety']
WHERE scenario_id = 'd30c9c26-6128-4661-a34f-80e4e9e24750';

UPDATE scenario_translations 
SET category = 'Work & Career', tags = ARRAY['job-security', 'budget']
WHERE scenario_id = '87706df5-df1d-4c99-8ab3-acedf5190fb3';

UPDATE scenario_translations 
SET category = 'Work & Career', tags = ARRAY['job-security', 'planning']
WHERE scenario_id = '26268b2f-a0ff-4c1b-96d0-bd7ed0deaae1';

UPDATE scenario_translations 
SET category = 'Work & Career', tags = ARRAY['job-security', 'adaptability']
WHERE scenario_id = 'be918c36-7496-419a-a2d2-2ddf4482b790';

UPDATE scenario_translations 
SET category = 'Work & Career', tags = ARRAY['job-security', 'resilience']
WHERE scenario_id = 'a8e7e820-fd79-4fce-ab0d-1d39286b5b21';

UPDATE scenario_translations 
SET category = 'Work & Career', tags = ARRAY['job-security', 'adaptation']
WHERE scenario_id = '0b21a100-53be-4f5c-ae32-ad6b55350120';

UPDATE scenario_translations 
SET category = 'Work & Career', tags = ARRAY['job-security', 'ethics']
WHERE scenario_id = '6a84123a-7469-4c80-86e6-3ec020060107';

UPDATE scenario_translations 
SET category = 'Work & Career', tags = ARRAY['job-security', 'balance']
WHERE scenario_id = '76113e63-693f-4821-88e6-2ebe3fdeb362';

UPDATE scenario_translations 
SET category = 'Work & Career', tags = ARRAY['job-security', 'planning']
WHERE scenario_id = '3c7f784c-c906-48e0-b794-b3b82098e0e6';

UPDATE scenario_translations 
SET category = 'Work & Career', tags = ARRAY['job-security', 'patience']
WHERE scenario_id = '9e295098-4684-4bcb-a10f-766a84a93971';

-- Side Hustles -> Work & Career (side-hustle tag)
UPDATE scenario_translations 
SET category = 'Work & Career', tags = ARRAY['side-hustle', 'balance']
WHERE scenario_id = '496fa4a4-1348-4f37-97d7-c51929fd189e';

UPDATE scenario_translations 
SET category = 'Work & Career', tags = ARRAY['side-hustle', 'patience']
WHERE scenario_id = '7236d94c-6cb2-42f2-9712-c98770e0cebe';

UPDATE scenario_translations 
SET category = 'Work & Career', tags = ARRAY['side-hustle', 'health']
WHERE scenario_id = '5357943b-787d-4317-83c9-af75ec422e97';

UPDATE scenario_translations 
SET category = 'Work & Career', tags = ARRAY['side-hustle', 'cashflow']
WHERE scenario_id = '3d430705-2a85-42bf-84e5-0eebaf489e30';

UPDATE scenario_translations 
SET category = 'Work & Career', tags = ARRAY['side-hustle', 'responsibility']
WHERE scenario_id = 'afe3d70f-392f-486f-b5d8-19cd9d06881d';

UPDATE scenario_translations 
SET category = 'Work & Career', tags = ARRAY['side-hustle', 'growth']
WHERE scenario_id = '892eb827-db9b-42fe-a3f3-32652cac092e';

UPDATE scenario_translations 
SET category = 'Work & Career', tags = ARRAY['side-hustle', 'value']
WHERE scenario_id = 'b3246c6a-06bf-45ee-b722-999edf055b96';

UPDATE scenario_translations 
SET category = 'Work & Career', tags = ARRAY['side-hustle', 'support']
WHERE scenario_id = '610f7e93-df21-4b26-b8d2-e4532b07173f';

UPDATE scenario_translations 
SET category = 'Work & Career', tags = ARRAY['side-hustle', 'discipline']
WHERE scenario_id = 'b05d50a4-3e27-4c38-9905-7bf56ab96085';

UPDATE scenario_translations 
SET category = 'Work & Career', tags = ARRAY['side-hustle', 'burnout']
WHERE scenario_id = 'c2508d03-1117-4fec-90cb-1b5adc434dc1';

-- ========================================
-- 2. RELATIONSHIPS CONSOLIDATION
-- ========================================

-- Dating Apps -> Relationships (dating tag)
UPDATE scenario_translations 
SET category = 'Relationships', tags = ARRAY['dating', 'intention']
WHERE scenario_id = 'f3462909-3b9d-4d07-8419-d0d8c198751d';

UPDATE scenario_translations 
SET category = 'Relationships', tags = ARRAY['dating', 'self-worth']
WHERE scenario_id = '45c32239-b504-461a-9992-46671602e3d8';

UPDATE scenario_translations 
SET category = 'Relationships', tags = ARRAY['dating', 'depth']
WHERE scenario_id = '2f8d0873-09c0-4401-8917-34d3d7fdc8a3';

UPDATE scenario_translations 
SET category = 'Relationships', tags = ARRAY['dating', 'focus']
WHERE scenario_id = '9e49c8e7-d68e-425e-80a4-3bdaaef35856';

UPDATE scenario_translations 
SET category = 'Relationships', tags = ARRAY['dating', 'discernment']
WHERE scenario_id = '0b685d2d-605e-45c9-9aa2-e0d499395ab3';

UPDATE scenario_translations 
SET category = 'Relationships', tags = ARRAY['dating', 'patience']
WHERE scenario_id = 'c59316e3-0d59-4c1e-a3e4-3221b835aab1';

UPDATE scenario_translations 
SET category = 'Relationships', tags = ARRAY['dating', 'discipline']
WHERE scenario_id = '01162150-eaf2-4b13-af33-d73f5f20a661';

UPDATE scenario_translations 
SET category = 'Relationships', tags = ARRAY['dating', 'adaptation']
WHERE scenario_id = '5774f48f-da63-4dcf-97bb-6caed230ece3';

UPDATE scenario_translations 
SET category = 'Relationships', tags = ARRAY['dating', 'openness']
WHERE scenario_id = '66ca26fb-628e-4a6b-a910-f277959cb186';

-- Marriage Expectations -> Relationships (marriage tag)
UPDATE scenario_translations 
SET category = 'Relationships', tags = ARRAY['marriage', 'timing']
WHERE scenario_id = '55654578-f297-4ddc-a905-ac03d22af6a4';

UPDATE scenario_translations 
SET category = 'Relationships', tags = ARRAY['marriage', 'comparison']
WHERE scenario_id = '41b05299-b47c-4e75-932c-55a17743286d';

UPDATE scenario_translations 
SET category = 'Relationships', tags = ARRAY['marriage', 'balance']
WHERE scenario_id = '130730f4-7deb-44c5-b0ed-bccf823b78b4';

UPDATE scenario_translations 
SET category = 'Relationships', tags = ARRAY['marriage', 'truth']
WHERE scenario_id = '48ad756f-af1d-4a9c-a5bc-ae0b415ad553';

UPDATE scenario_translations 
SET category = 'Relationships', tags = ARRAY['marriage', 'judgment']
WHERE scenario_id = 'aa0e1a0c-ad5f-4c7f-9956-02be8c4891c7';

UPDATE scenario_translations 
SET category = 'Relationships', tags = ARRAY['marriage', 'patience']
WHERE scenario_id = '12935186-eecf-43fb-a92b-6b46c56265ab';

UPDATE scenario_translations 
SET category = 'Relationships', tags = ARRAY['marriage', 'authenticity']
WHERE scenario_id = '0fc3859f-2e0a-466f-9f02-a1619aed4a73';

UPDATE scenario_translations 
SET category = 'Relationships', tags = ARRAY['marriage', 'education']
WHERE scenario_id = '1060f003-06c8-44b8-9530-f63b11c22cf2';

UPDATE scenario_translations 
SET category = 'Relationships', tags = ARRAY['marriage', 'timing']
WHERE scenario_id = 'ef6955b4-f40f-43ee-82d2-7e0d19d5e5f7';

UPDATE scenario_translations 
SET category = 'Relationships', tags = ARRAY['marriage', 'patience']
WHERE scenario_id = '33f4cd31-e146-4bc1-8453-0607f8044ebc';

-- ========================================
-- 3. PERSONAL GROWTH CONSOLIDATION
-- ========================================

-- Identity -> Personal Growth (self-discovery tag)
UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['self-discovery', 'purpose']
WHERE scenario_id = '6f593f2a-c7d7-489d-8951-15f362871cf5';

UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['self-discovery', 'confidence']
WHERE scenario_id = 'cedfd65e-8137-4e9e-80d1-86ffba70a5bf';

UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['self-discovery', 'inspiration']
WHERE scenario_id = 'd342a42b-0caf-46d0-b482-a9433e42d210';

UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['self-discovery', 'growth']
WHERE scenario_id = '2f1f9fda-a6ab-47cc-80c6-736b0174d07c';

UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['self-discovery', 'values']
WHERE scenario_id = '2e5f7d2a-b6e1-4b65-ae98-7c4f1bbea6cb';

UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['self-discovery', 'reflection']
WHERE scenario_id = '0ae628e8-e4cf-4c9b-8c5e-0fe66a3cebcb';

UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['self-discovery', 'adaptation']
WHERE scenario_id = '48bdce12-ccfa-48cf-92f5-51c5d3678b26';

UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['self-discovery', 'self-worth']
WHERE scenario_id = '3161914a-89d3-4056-838f-a36b65c70c76';

UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['self-discovery', 'growth']
WHERE scenario_id = '41c1412c-c261-487a-8018-dd12fe444358';

UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['self-discovery', 'belonging']
WHERE scenario_id = '2804af1b-7f24-4fbc-9c87-825f600373f3';

-- Habits -> Personal Growth (habits tag)
UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['habits', 'consistency']
WHERE scenario_id = 'e9de589c-3171-410c-a535-c62ed62d43bc';

UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['habits', 'support']
WHERE scenario_id = '7107b729-92ea-4400-b523-d9eec67b1730';

UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['habits', 'goals']
WHERE scenario_id = '42498989-bec4-4f84-9313-5813a37fab55';

UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['habits', 'balance']
WHERE scenario_id = '0a0f0c0d-d7a7-40d5-a60c-8bf92b9c251d';

UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['habits', 'progress']
WHERE scenario_id = '95b351a4-4b95-4ec5-86e9-6e7ba7ee2d62';

UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['habits', 'resilience']
WHERE scenario_id = '419687bc-67a6-427b-b6d4-d39be775323c';

UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['habits', 'persistence']
WHERE scenario_id = 'ce023018-1a2d-4a45-8292-9fd170776aaa';

UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['habits', 'values']
WHERE scenario_id = '27992e55-15c4-4f54-9e81-a6672542f19d';

UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['habits', 'motivation']
WHERE scenario_id = 'b3caf0ca-7359-41a1-b46b-e2521fb5573c';

UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['habits', 'tracking']
WHERE scenario_id = '76fba76d-ecaf-419b-93ed-36cfafa84c1e';

-- ========================================
-- 4. LIFE TRANSITIONS CONSOLIDATION
-- ========================================

-- Life Milestones -> Life Transitions (milestones tag)
UPDATE scenario_translations 
SET category = 'Life Transitions', tags = ARRAY['milestones', 'comparison']
WHERE scenario_id = '5c9f709f-faf6-4f2f-a78b-edde17023134';

UPDATE scenario_translations 
SET category = 'Life Transitions', tags = ARRAY['milestones', 'timeline']
WHERE scenario_id = 'c59639ad-e4e3-4053-a0ac-0707fe0756e0';

UPDATE scenario_translations 
SET category = 'Life Transitions', tags = ARRAY['milestones', 'contentment']
WHERE scenario_id = '4b448bb6-b4b3-46b8-8c0c-665e5b92f5e2';

UPDATE scenario_translations 
SET category = 'Life Transitions', tags = ARRAY['milestones', 'values']
WHERE scenario_id = '82a5ca7f-59a6-48a5-b4ea-6d23c6ff39a1';

UPDATE scenario_translations 
SET category = 'Life Transitions', tags = ARRAY['milestones', 'self-love']
WHERE scenario_id = 'e725513a-c2f2-4490-ab5a-a21d914150a7';

UPDATE scenario_translations 
SET category = 'Life Transitions', tags = ARRAY['milestones', 'resilience']
WHERE scenario_id = 'd2b1d447-0c4f-4517-9c45-fa15a3d49573';

UPDATE scenario_translations 
SET category = 'Life Transitions', tags = ARRAY['milestones', 'patience']
WHERE scenario_id = 'fb24faf7-c3ce-4f80-831d-970938a6126a';

UPDATE scenario_translations 
SET category = 'Life Transitions', tags = ARRAY['milestones', 'values']
WHERE scenario_id = '1bec1dba-626b-4dab-819d-bc232fee8c1e';

UPDATE scenario_translations 
SET category = 'Life Transitions', tags = ARRAY['milestones', 'wealth']
WHERE scenario_id = '539bb1e7-6f68-46be-97ac-e9df5463b8bf';

UPDATE scenario_translations 
SET category = 'Life Transitions', tags = ARRAY['milestones', 'norms']
WHERE scenario_id = 'ed2c442d-516f-4879-8dca-359b5e3fd199';

-- ========================================
-- 5. SOCIAL & COMMUNITY CONSOLIDATION 
-- ========================================

-- Urban Loneliness -> Social & Community (isolation tag)
UPDATE scenario_translations 
SET category = 'Social & Community', tags = ARRAY['isolation', 'authenticity']
WHERE scenario_id = '028dbc4f-d36e-43cf-b7e1-1c431a932c58';

UPDATE scenario_translations 
SET category = 'Social & Community', tags = ARRAY['isolation', 'community']
WHERE scenario_id = '623f3551-65c7-49bb-b58b-a54456481122';

UPDATE scenario_translations 
SET category = 'Social & Community', tags = ARRAY['isolation', 'fulfillment']
WHERE scenario_id = 'a4f6de97-25d9-4023-99c1-4dc4295b57f0';

UPDATE scenario_translations 
SET category = 'Social & Community', tags = ARRAY['isolation', 'support']
WHERE scenario_id = 'd363cec8-3c76-4a05-b858-4e130060e7f0';

UPDATE scenario_translations 
SET category = 'Social & Community', tags = ARRAY['isolation', 'friendship']
WHERE scenario_id = '0285ff8b-39a3-4b8d-9354-f8f05586b68e';

UPDATE scenario_translations 
SET category = 'Social & Community', tags = ARRAY['isolation', 'adaptation']
WHERE scenario_id = 'ded1826e-a4ca-4803-9a93-ee0474d67533';

UPDATE scenario_translations 
SET category = 'Social & Community', tags = ARRAY['isolation', 'visibility']
WHERE scenario_id = 'bc0d7e49-246d-4d8b-9f41-a0f1b91bb851';

UPDATE scenario_translations 
SET category = 'Social & Community', tags = ARRAY['isolation', 'connection']
WHERE scenario_id = 'e67c2b3e-ff80-477d-bad5-de39fcf6ac76';

UPDATE scenario_translations 
SET category = 'Social & Community', tags = ARRAY['isolation', 'language']
WHERE scenario_id = 'f2df19a2-cc1d-47e0-a684-96d57703eb3f';

UPDATE scenario_translations 
SET category = 'Social & Community', tags = ARRAY['isolation', 'values']
WHERE scenario_id = '74589ea9-af8b-4716-b302-de043eb28382';

-- ========================================
-- 6. HEALTH & WELLNESS CONSOLIDATION
-- ========================================

-- Climate Anxiety -> Health & Wellness (eco-anxiety tag)
UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['eco-anxiety', 'action']
WHERE scenario_id = '1cb7aca7-b7c1-42c9-99a4-88cd8515516b';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['eco-anxiety', 'balance']
WHERE scenario_id = '9c3719d0-1342-4648-a4b9-1710e7e9b417';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['eco-anxiety', 'mental-health']
WHERE scenario_id = '5709bf5e-131e-4afc-8220-ecd7a658fcba';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['eco-anxiety', 'persistence']
WHERE scenario_id = 'b8b53a0a-572c-4273-b064-d37e2b49574c';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['eco-anxiety', 'change']
WHERE scenario_id = '3a3715e0-2c97-4921-b235-73763f324a6e';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['eco-anxiety', 'values']
WHERE scenario_id = '1dfde79b-5b61-4966-9dc8-1f9492348a48';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['eco-anxiety', 'example']
WHERE scenario_id = '5797930a-7266-4369-b9dd-9949abcbebfe';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['eco-anxiety', 'balance']
WHERE scenario_id = 'afbae4de-4a57-4d60-9d4f-4bf99da167c5';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['eco-anxiety', 'future']
WHERE scenario_id = '66f33dde-ea0d-4d04-9377-9d197f43c7e4';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['eco-anxiety', 'cooperation']
WHERE scenario_id = 'b48b85fe-6feb-49ed-948b-f97c6fac8a97';

-- Digital Wellness -> Health & Wellness (digital-balance tag)
UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['digital-balance', 'productivity']
WHERE scenario_id = '5abd165b-9602-4ebb-a4e7-dac74daeaa7b';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['digital-balance', 'presence']
WHERE scenario_id = '31baa7e4-bc2d-4412-b3a7-eb08cc19727d';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['digital-balance', 'creativity']
WHERE scenario_id = '1eafa814-c66c-47dc-a0c6-0a1616549870';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['digital-balance', 'anxiety']
WHERE scenario_id = '11a222ba-0f39-4e1a-b341-398263a35ce7';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['digital-balance', 'mindfulness']
WHERE scenario_id = '4910ed82-c49d-44e7-a061-3129339f44ff';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['digital-balance', 'quality']
WHERE scenario_id = '5a3c1d51-dd08-4c92-9106-22626a61b8eb';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['digital-balance', 'habits']
WHERE scenario_id = '34e7b68c-9234-4081-9dd3-ab0177aeb2e8';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['digital-balance', 'presence']
WHERE scenario_id = 'c60ba866-ddab-428f-a69e-fac1c1883e70';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['digital-balance', 'focus']
WHERE scenario_id = '4f46eec1-e589-4e18-b562-52aeb6588540';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['digital-balance', 'clarity']
WHERE scenario_id = '3adb805d-35a9-454f-8d82-ec68ae8c363a';

-- Body Confidence -> Health & Wellness (body-image tag)
UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['body-image', 'memories']
WHERE scenario_id = '274e46f8-f92b-40d9-a231-03a7d88ad861';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['body-image', 'joy']
WHERE scenario_id = '5618450b-52ba-4110-bc4f-4ed657970b6e';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['body-image', 'joy']
WHERE scenario_id = '8127312c-e512-4e3e-af81-2f2ab9a5a550';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['body-image', 'health']
WHERE scenario_id = 'd9d45834-5194-4513-82c2-8deb7629f07e';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['body-image', 'self-worth']
WHERE scenario_id = '709252c7-d705-4bd5-ab45-0a45fc97330c';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['body-image', 'confidence']
WHERE scenario_id = 'c80aa7b1-83fd-4975-9157-c71a62ecb09b';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['body-image', 'authenticity']
WHERE scenario_id = '158765b1-3e32-48ca-9a26-15bf364c1864';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['body-image', 'confidence']
WHERE scenario_id = 'cc737bd2-57ac-4d36-800c-81b953bc2b0e';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['body-image', 'natural']
WHERE scenario_id = '74fb0b1d-47f9-43c4-b3d9-b7c3ed3217e4';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['body-image', 'start']
WHERE scenario_id = '3e4295dc-4660-4019-a90a-b18f3b2b7af3';

COMMIT;

-- ========================================
-- VERIFICATION QUERIES
-- ========================================

-- Check consolidated category distribution
SELECT 'Consolidated Categories Count:' as info;
SELECT category, COUNT(*) as scenario_count 
FROM scenario_translations 
GROUP BY category 
ORDER BY scenario_count DESC;

-- Check tag diversity within categories  
SELECT 'Tag Distribution by Category:' as info;
SELECT category, tags[1] as primary_tag, COUNT(*) as count
FROM scenario_translations 
WHERE category IN ('Work & Career', 'Relationships', 'Personal Growth', 'Life Transitions', 'Social & Community', 'Health & Wellness')
GROUP BY category, tags[1]
ORDER BY category, count DESC;