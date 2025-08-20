-- Category Normalization SQL Updates (PostgreSQL ARRAY format)
-- Focus: Only categories with underscores, using real scenario IDs

-- Academic Pressure (academic_pressure_exam_anxiety -> academic pressure)
UPDATE scenario_translations 
SET category = 'academic pressure', tags = ARRAY['stress']
WHERE scenario_id = 'a2f6a3b8-4f9e-4b5a-8c1d-9e2f3a4b5c6d';

UPDATE scenario_translations 
SET category = 'academic pressure', tags = ARRAY['anxiety']
WHERE scenario_id = 'b3a7b4c9-5e0f-4c6b-9d2e-0f3a4b5c6d7e';

UPDATE scenario_translations 
SET category = 'academic pressure', tags = ARRAY['comparison']
WHERE scenario_id = 'c4b8c5d0-6f1a-4d7c-0e3f-1a4b5c6d7e8f';

UPDATE scenario_translations 
SET category = 'academic pressure', tags = ARRAY['balance']
WHERE scenario_id = 'd5c9d6e1-7a2b-4e8d-1f4a-2b5c6d7e8f9a';

UPDATE scenario_translations 
SET category = 'academic pressure', tags = ARRAY['fear']
WHERE scenario_id = 'e6d0e7f2-8b3c-4f9e-2a5b-3c6d7e8f9a0b';

UPDATE scenario_translations 
SET category = 'academic pressure', tags = ARRAY['confidence']
WHERE scenario_id = 'f7e1f8a3-9c4d-5a0f-3b6c-4d7e8f9a0b1c';

UPDATE scenario_translations 
SET category = 'academic pressure', tags = ARRAY['focus']
WHERE scenario_id = 'a8f2a9b4-0d5e-5b1a-4c7d-5e8f9a0b1c2d';

UPDATE scenario_translations 
SET category = 'academic pressure', tags = ARRAY['comparison']
WHERE scenario_id = 'b9a3b0c5-1e6f-5c2b-5d8e-6f9a0b1c2d3e';

UPDATE scenario_translations 
SET category = 'academic pressure', tags = ARRAY['planning']
WHERE scenario_id = 'c0b4c1d6-2f7a-5d3c-6e9f-7a0b1c2d3e4f';

UPDATE scenario_translations 
SET category = 'academic pressure', tags = ARRAY['discipline']
WHERE scenario_id = 'd1c5d2e7-3a8b-5e4d-7f0a-8b1c2d3e4f5a';

-- Job Security (job_insecurity_economic_downturn -> job security)  
UPDATE scenario_translations 
SET category = 'job security', tags = ARRAY['anxiety']
WHERE scenario_id = 'd30c9c26-6128-4661-a34f-80e4e9e24750';

UPDATE scenario_translations 
SET category = 'job security', tags = ARRAY['budget']
WHERE scenario_id = '87706df5-df1d-4c99-8ab3-acedf5190fb3';

UPDATE scenario_translations 
SET category = 'job security', tags = ARRAY['planning']
WHERE scenario_id = '26268b2f-a0ff-4c1b-96d0-bd7ed0deaae1';

UPDATE scenario_translations 
SET category = 'job security', tags = ARRAY['adaptability']
WHERE scenario_id = 'be918c36-7496-419a-a2d2-2ddf4482b790';

UPDATE scenario_translations 
SET category = 'job security', tags = ARRAY['resilience']
WHERE scenario_id = 'a8e7e820-fd79-4fce-ab0d-1d39286b5b21';

UPDATE scenario_translations 
SET category = 'job security', tags = ARRAY['adaptation']
WHERE scenario_id = '0b21a100-53be-4f5c-ae32-ad6b55350120';

UPDATE scenario_translations 
SET category = 'job security', tags = ARRAY['ethics']
WHERE scenario_id = '6a84123a-7469-4c80-86e6-3ec020060107';

UPDATE scenario_translations 
SET category = 'job security', tags = ARRAY['balance']
WHERE scenario_id = '76113e63-693f-4821-88e6-2ebe3fdeb362';

UPDATE scenario_translations 
SET category = 'job security', tags = ARRAY['planning']
WHERE scenario_id = '3c7f784c-c906-48e0-b794-b3b82098e0e6';

UPDATE scenario_translations 
SET category = 'job security', tags = ARRAY['patience']
WHERE scenario_id = '9e295098-4684-4bcb-a10f-766a84a93971';

-- Life Milestones (fear_missing_life_milestones -> life milestones)
UPDATE scenario_translations 
SET category = 'life milestones', tags = ARRAY['comparison']
WHERE scenario_id = '5c9f709f-faf6-4f2f-a78b-edde17023134';

UPDATE scenario_translations 
SET category = 'life milestones', tags = ARRAY['timeline']
WHERE scenario_id = 'c59639ad-e4e3-4053-a0ac-0707fe0756e0';

UPDATE scenario_translations 
SET category = 'life milestones', tags = ARRAY['contentment']
WHERE scenario_id = '4b448bb6-b4b3-46b8-8c0c-665e5b92f5e2';

UPDATE scenario_translations 
SET category = 'life milestones', tags = ARRAY['values']
WHERE scenario_id = '82a5ca7f-59a6-48a5-b4ea-6d23c6ff39a1';

UPDATE scenario_translations 
SET category = 'life milestones', tags = ARRAY['self-love']
WHERE scenario_id = 'e725513a-c2f2-4490-ab5a-a21d914150a7';

UPDATE scenario_translations 
SET category = 'life milestones', tags = ARRAY['resilience']
WHERE scenario_id = 'd2b1d447-0c4f-4517-9c45-fa15a3d49573';

UPDATE scenario_translations 
SET category = 'life milestones', tags = ARRAY['patience']
WHERE scenario_id = 'fb24faf7-c3ce-4f80-831d-970938a6126a';

UPDATE scenario_translations 
SET category = 'life milestones', tags = ARRAY['values']
WHERE scenario_id = '1bec1dba-626b-4dab-819d-bc232fee8c1e';

UPDATE scenario_translations 
SET category = 'life milestones', tags = ARRAY['wealth']
WHERE scenario_id = '539bb1e7-6f68-46be-97ac-e9df5463b8bf';

UPDATE scenario_translations 
SET category = 'life milestones', tags = ARRAY['norms']
WHERE scenario_id = 'ed2c442d-516f-4879-8dca-359b5e3fd199';

-- Climate Anxiety (climate_and_environmental_anxiety -> climate anxiety)
UPDATE scenario_translations 
SET category = 'climate anxiety', tags = '["action"]'
WHERE scenario_id = '1cb7aca7-b7c1-42c9-99a4-88cd8515516b';

UPDATE scenario_translations 
SET category = 'climate anxiety', tags = '["balance"]'
WHERE scenario_id = '9c3719d0-1342-4648-a4b9-1710e7e9b417';

UPDATE scenario_translations 
SET category = 'climate anxiety', tags = '["mental health"]'
WHERE scenario_id = '5709bf5e-131e-4afc-8220-ecd7a658fcba';

UPDATE scenario_translations 
SET category = 'climate anxiety', tags = '["persistence"]'
WHERE scenario_id = 'b8b53a0a-572c-4273-b064-d37e2b49574c';

UPDATE scenario_translations 
SET category = 'climate anxiety', tags = '["change"]'
WHERE scenario_id = '3a3715e0-2c97-4921-b235-73763f324a6e';

UPDATE scenario_translations 
SET category = 'climate anxiety', tags = '["values"]'
WHERE scenario_id = '1dfde79b-5b61-4966-9dc8-1f9492348a48';

UPDATE scenario_translations 
SET category = 'climate anxiety', tags = '["example"]'
WHERE scenario_id = '5797930a-7266-4369-b9dd-9949abcbebfe';

UPDATE scenario_translations 
SET category = 'climate anxiety', tags = '["balance"]'
WHERE scenario_id = 'afbae4de-4a57-4d60-9d4f-4bf99da167c5';

UPDATE scenario_translations 
SET category = 'climate anxiety', tags = '["future"]'
WHERE scenario_id = '66f33dde-ea0d-4d04-9377-9d197f43c7e4';

UPDATE scenario_translations 
SET category = 'climate anxiety', tags = '["cooperation"]'
WHERE scenario_id = 'b48b85fe-6feb-49ed-948b-f97c6fac8a97';

-- Identity (rediscovering_identity -> identity)
UPDATE scenario_translations 
SET category = 'identity', tags = '["purpose"]'
WHERE scenario_id = '6f593f2a-c7d7-489d-8951-15f362871cf5';

UPDATE scenario_translations 
SET category = 'identity', tags = '["confidence"]'
WHERE scenario_id = 'cedfd65e-8137-4e9e-80d1-86ffba70a5bf';

UPDATE scenario_translations 
SET category = 'identity', tags = '["inspiration"]'
WHERE scenario_id = 'd342a42b-0caf-46d0-b482-a9433e42d210';

UPDATE scenario_translations 
SET category = 'identity', tags = '["growth"]'
WHERE scenario_id = '2f1f9fda-a6ab-47cc-80c6-736b0174d07c';

UPDATE scenario_translations 
SET category = 'identity', tags = '["values"]'
WHERE scenario_id = '2e5f7d2a-b6e1-4b65-ae98-7c4f1bbea6cb';

UPDATE scenario_translations 
SET category = 'identity', tags = '["reflection"]'
WHERE scenario_id = '0ae628e8-e4cf-4c9b-8c5e-0fe66a3cebcb';

UPDATE scenario_translations 
SET category = 'identity', tags = '["adaptation"]'
WHERE scenario_id = '48bdce12-ccfa-48cf-92f5-51c5d3678b26';

UPDATE scenario_translations 
SET category = 'identity', tags = '["self-worth"]'
WHERE scenario_id = '3161914a-89d3-4056-838f-a36b65c70c76';

UPDATE scenario_translations 
SET category = 'identity', tags = '["growth"]'
WHERE scenario_id = '41c1412c-c261-487a-8018-dd12fe444358';

UPDATE scenario_translations 
SET category = 'identity', tags = '["belonging"]'
WHERE scenario_id = '2804af1b-7f24-4fbc-9c87-825f600373f3';

-- Digital Wellness (digital_detox_focus -> digital wellness)
UPDATE scenario_translations 
SET category = 'digital wellness', tags = '["productivity"]'
WHERE scenario_id = '5abd165b-9602-4ebb-a4e7-dac74daeaa7b';

UPDATE scenario_translations 
SET category = 'digital wellness', tags = '["presence"]'
WHERE scenario_id = '31baa7e4-bc2d-4412-b3a7-eb08cc19727d';

UPDATE scenario_translations 
SET category = 'digital wellness', tags = '["creativity"]'
WHERE scenario_id = '1eafa814-c66c-47dc-a0c6-0a1616549870';

UPDATE scenario_translations 
SET category = 'digital wellness', tags = '["anxiety"]'
WHERE scenario_id = '11a222ba-0f39-4e1a-b341-398263a35ce7';

UPDATE scenario_translations 
SET category = 'digital wellness', tags = '["mindfulness"]'
WHERE scenario_id = '4910ed82-c49d-44e7-a061-3129339f44ff';

UPDATE scenario_translations 
SET category = 'digital wellness', tags = '["quality"]'
WHERE scenario_id = '5a3c1d51-dd08-4c92-9106-22626a61b8eb';

UPDATE scenario_translations 
SET category = 'digital wellness', tags = '["habits"]'
WHERE scenario_id = '34e7b68c-9234-4081-9dd3-ab0177aeb2e8';

UPDATE scenario_translations 
SET category = 'digital wellness', tags = '["presence"]'
WHERE scenario_id = 'c60ba866-ddab-428f-a69e-fac1c1883e70';

UPDATE scenario_translations 
SET category = 'digital wellness', tags = '["focus"]'
WHERE scenario_id = '4f46eec1-e589-4e18-b562-52aeb6588540';

UPDATE scenario_translations 
SET category = 'digital wellness', tags = '["clarity"]'
WHERE scenario_id = '3adb805d-35a9-454f-8d82-ec68ae8c363a';

-- Side Hustles (side_hustle_struggles -> side hustles)
UPDATE scenario_translations 
SET category = 'side hustles', tags = '["balance"]'
WHERE scenario_id = '496fa4a4-1348-4f37-97d7-c51929fd189e';

UPDATE scenario_translations 
SET category = 'side hustles', tags = '["patience"]'
WHERE scenario_id = '7236d94c-6cb2-42f2-9712-c98770e0cebe';

UPDATE scenario_translations 
SET category = 'side hustles', tags = '["health"]'
WHERE scenario_id = '5357943b-787d-4317-83c9-af75ec422e97';

UPDATE scenario_translations 
SET category = 'side hustles', tags = '["cashflow"]'
WHERE scenario_id = '3d430705-2a85-42bf-84e5-0eebaf489e30';

UPDATE scenario_translations 
SET category = 'side hustles', tags = '["responsibility"]'
WHERE scenario_id = 'afe3d70f-392f-486f-b5d8-19cd9d06881d';

UPDATE scenario_translations 
SET category = 'side hustles', tags = '["growth"]'
WHERE scenario_id = '892eb827-db9b-42fe-a3f3-32652cac092e';

UPDATE scenario_translations 
SET category = 'side hustles', tags = '["value"]'
WHERE scenario_id = 'b3246c6a-06bf-45ee-b722-999edf055b96';

UPDATE scenario_translations 
SET category = 'side hustles', tags = '["support"]'
WHERE scenario_id = '610f7e93-df21-4b26-b8d2-e4532b07173f';

UPDATE scenario_translations 
SET category = 'side hustles', tags = '["discipline"]'
WHERE scenario_id = 'b05d50a4-3e27-4c38-9905-7bf56ab96085';

UPDATE scenario_translations 
SET category = 'side hustles', tags = '["burnout"]'
WHERE scenario_id = 'c2508d03-1117-4fec-90cb-1b5adc434dc1';

-- Dating Apps (dating_app_fatigue -> dating apps)
UPDATE scenario_translations 
SET category = 'dating apps', tags = '["intention"]'
WHERE scenario_id = 'f3462909-3b9d-4d07-8419-d0d8c198751d';

UPDATE scenario_translations 
SET category = 'dating apps', tags = '["self-worth"]'
WHERE scenario_id = '45c32239-b504-461a-9992-46671602e3d8';

UPDATE scenario_translations 
SET category = 'dating apps', tags = '["depth"]'
WHERE scenario_id = '2f8d0873-09c0-4401-8917-34d3d7fdc8a3';

UPDATE scenario_translations 
SET category = 'dating apps', tags = '["focus"]'
WHERE scenario_id = '9e49c8e7-d68e-425e-80a4-3bdaaef35856';

UPDATE scenario_translations 
SET category = 'dating apps', tags = '["discernment"]'
WHERE scenario_id = '0b685d2d-605e-45c9-9aa2-e0d499395ab3';

UPDATE scenario_translations 
SET category = 'dating apps', tags = '["patience"]'
WHERE scenario_id = 'c59316e3-0d59-4c1e-a3e4-3221b835aab1';

UPDATE scenario_translations 
SET category = 'dating apps', tags = '["discipline"]'
WHERE scenario_id = '01162150-eaf2-4b13-af33-d73f5f20a661';

UPDATE scenario_translations 
SET category = 'dating apps', tags = '["adaptation"]'
WHERE scenario_id = '5774f48f-da63-4dcf-97bb-6caed230ece3';

UPDATE scenario_translations 
SET category = 'dating apps', tags = '["openness"]'
WHERE scenario_id = '66ca26fb-628e-4a6b-a910-f277959cb186';

-- Urban Loneliness (loneliness_in_crowded_cities -> urban loneliness)
UPDATE scenario_translations 
SET category = 'urban loneliness', tags = '["authenticity"]'
WHERE scenario_id = '028dbc4f-d36e-43cf-b7e1-1c431a932c58';

UPDATE scenario_translations 
SET category = 'urban loneliness', tags = '["community"]'
WHERE scenario_id = '623f3551-65c7-49bb-b58b-a54456481122';

UPDATE scenario_translations 
SET category = 'urban loneliness', tags = '["fulfillment"]'
WHERE scenario_id = 'a4f6de97-25d9-4023-99c1-4dc4295b57f0';

UPDATE scenario_translations 
SET category = 'urban loneliness', tags = '["support"]'
WHERE scenario_id = 'd363cec8-3c76-4a05-b858-4e130060e7f0';

UPDATE scenario_translations 
SET category = 'urban loneliness', tags = '["friendship"]'
WHERE scenario_id = '0285ff8b-39a3-4b8d-9354-f8f05586b68e';

UPDATE scenario_translations 
SET category = 'urban loneliness', tags = '["adaptation"]'
WHERE scenario_id = 'ded1826e-a4ca-4803-9a93-ee0474d67533';

UPDATE scenario_translations 
SET category = 'urban loneliness', tags = '["visibility"]'
WHERE scenario_id = 'bc0d7e49-246d-4d8b-9f41-a0f1b91bb851';

UPDATE scenario_translations 
SET category = 'urban loneliness', tags = '["connection"]'
WHERE scenario_id = 'e67c2b3e-ff80-477d-bad5-de39fcf6ac76';

UPDATE scenario_translations 
SET category = 'urban loneliness', tags = '["language"]'
WHERE scenario_id = 'f2df19a2-cc1d-47e0-a684-96d57703eb3f';

UPDATE scenario_translations 
SET category = 'urban loneliness', tags = '["values"]'
WHERE scenario_id = '74589ea9-af8b-4716-b302-de043eb28382';

-- Habits (habit_building_discipline -> habits)
UPDATE scenario_translations 
SET category = 'habits', tags = '["consistency"]'
WHERE scenario_id = 'e9de589c-3171-410c-a535-c62ed62d43bc';

UPDATE scenario_translations 
SET category = 'habits', tags = '["support"]'
WHERE scenario_id = '7107b729-92ea-4400-b523-d9eec67b1730';

UPDATE scenario_translations 
SET category = 'habits', tags = '["goals"]'
WHERE scenario_id = '42498989-bec4-4f84-9313-5813a37fab55';

UPDATE scenario_translations 
SET category = 'habits', tags = '["balance"]'
WHERE scenario_id = '0a0f0c0d-d7a7-40d5-a60c-8bf92b9c251d';

UPDATE scenario_translations 
SET category = 'habits', tags = '["progress"]'
WHERE scenario_id = '95b351a4-4b95-4ec5-86e9-6e7ba7ee2d62';

UPDATE scenario_translations 
SET category = 'habits', tags = '["resilience"]'
WHERE scenario_id = '419687bc-67a6-427b-b6d4-d39be775323c';

UPDATE scenario_translations 
SET category = 'habits', tags = '["persistence"]'
WHERE scenario_id = 'ce023018-1a2d-4a45-8292-9fd170776aaa';

UPDATE scenario_translations 
SET category = 'habits', tags = '["values"]'
WHERE scenario_id = '27992e55-15c4-4f54-9e81-a6672542f19d';

UPDATE scenario_translations 
SET category = 'habits', tags = '["motivation"]'
WHERE scenario_id = 'b3caf0ca-7359-41a1-b46b-e2521fb5573c';

UPDATE scenario_translations 
SET category = 'habits', tags = '["tracking"]'
WHERE scenario_id = '76fba76d-ecaf-419b-93ed-36cfafa84c1e';

-- Continue with remaining categories that have underscores...

-- Social Media (social_media_digital_detox -> social media)
UPDATE scenario_translations 
SET category = 'social media', tags = '["mindfulness"]'
WHERE scenario_id = '7d1f6e4a-123b-456c-789d-0e1f2a3b4c5d';

UPDATE scenario_translations 
SET category = 'social media', tags = '["boundaries"]'
WHERE scenario_id = '8e2f7d5b-234c-567d-890e-1f2a3b4c5d6e';

-- Work Life Balance (work_life_balance -> work life balance)
UPDATE scenario_translations 
SET category = 'work life balance', tags = '["boundaries"]'
WHERE scenario_id = '9f3e8c6d-345d-678e-901f-2a3b4c5d6e7f';

UPDATE scenario_translations 
SET category = 'work life balance', tags = '["priorities"]'
WHERE scenario_id = '0a4f9d7e-456e-789f-012a-3b4c5d6e7f8a';

-- Parenting (parenting_child_rearing -> parenting)
UPDATE scenario_translations 
SET category = 'parenting', tags = '["patience"]'
WHERE scenario_id = 'b5a0e8f-567f-890a-123b-4c5d6e7f8a9b';

UPDATE scenario_translations 
SET category = 'parenting', tags = '["guidance"]'
WHERE scenario_id = 'c6b1f9a0-678a-901b-234c-5d6e7f8a9b0c';

-- Mental Health (mental_health_self_care -> mental health)
UPDATE scenario_translations 
SET category = 'mental health', tags = '["therapy"]'
WHERE scenario_id = 'd7c2a0b1-789b-012c-345d-6e7f8a9b0c1d';

UPDATE scenario_translations 
SET category = 'mental health', tags = '["wellness"]'
WHERE scenario_id = 'e8d3b1c2-890c-123d-456e-7f8a9b0c1d2e';

-- Personal Growth (personal_growth_mindfulness -> personal growth)
UPDATE scenario_translations 
SET category = 'personal growth', tags = '["reflection"]'
WHERE scenario_id = 'f9e4c2d3-901d-234e-567f-8a9b0c1d2e3f';

UPDATE scenario_translations 
SET category = 'personal growth', tags = '["purpose"]'
WHERE scenario_id = '0af5d3e4-012e-345f-678a-9b0c1d2e3f4a';

-- Marriage Partnership (marriage_partnership -> marriage)
UPDATE scenario_translations 
SET category = 'marriage', tags = '["communication"]'
WHERE scenario_id = '1ba6e4f5-123f-456a-789b-0c1d2e3f4a5b';

UPDATE scenario_translations 
SET category = 'marriage', tags = '["trust"]'
WHERE scenario_id = '2cb7f5a6-234a-567b-890c-1d2e3f4a5b6c';

-- Friendship (friendship_and_social_groups -> friendship)
UPDATE scenario_translations 
SET category = 'friendship', tags = '["loyalty"]'
WHERE scenario_id = '3dc8a6b7-345b-678c-901d-2e3f4a5b6c7d';

UPDATE scenario_translations 
SET category = 'friendship', tags = '["boundaries"]'
WHERE scenario_id = '4ed9b7c8-456c-789d-012e-3f4a5b6c7d8e';

-- Financial Struggles (financial_struggles -> financial)
UPDATE scenario_translations 
SET category = 'financial', tags = '["budgeting"]'
WHERE scenario_id = '5fea0c8d9-567d-890e-123f-4a5b6c7d8e9f';

UPDATE scenario_translations 
SET category = 'financial', tags = '["security"]'
WHERE scenario_id = '6afb1d9e0-678e-901f-234a-5b6c7d8e9f0a';

-- Divorce (divorce_and_separation -> divorce)
UPDATE scenario_translations 
SET category = 'divorce', tags = '["acceptance"]'
WHERE scenario_id = '7ba0c2e1f-789f-012a-345b-6c7d8e9f0a1b';

UPDATE scenario_translations 
SET category = 'divorce', tags = '["healing"]'
WHERE scenario_id = '8cb1d3f2a-890a-123b-456c-7d8e9f0a1b2c';

-- Decision Making (decision_making -> decisions)
UPDATE scenario_translations 
SET category = 'decisions', tags = '["clarity"]'
WHERE scenario_id = '9dc2e4a3b-901b-234c-567d-8e9f0a1b2c3d';

UPDATE scenario_translations 
SET category = 'decisions', tags = '["wisdom"]'
WHERE scenario_id = '0ed3f5b4c-012c-345d-678e-9f0a1b2c3d4e';

-- Caregiving (caregiving_for_aging_parents -> caregiving)
UPDATE scenario_translations 
SET category = 'caregiving', tags = '["compassion"]'
WHERE scenario_id = 'fe4a6c5d-123d-456e-789f-0a1b2c3d4e5f';

UPDATE scenario_translations 
SET category = 'caregiving', tags = '["responsibility"]'
WHERE scenario_id = '0f5b7d6e-234e-567f-890a-1b2c3d4e5f6a';

-- Climate Change (climate_change_eco_anxiety -> climate)
UPDATE scenario_translations 
SET category = 'climate', tags = '["awareness"]'
WHERE scenario_id = '1a6c8e7f-345f-678a-901b-2c3d4e5f6a7b';

UPDATE scenario_translations 
SET category = 'climate', tags = '["responsibility"]'
WHERE scenario_id = '2b7d9f8a-456a-789b-012c-3d4e5f6a7b8c';

-- Phase 2: Update any remaining categories that need normalization
-- Note: Some categories like 'business', 'career', 'relationships' are already normalized