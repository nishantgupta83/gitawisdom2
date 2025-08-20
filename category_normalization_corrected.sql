-- CORRECTED Category Normalization SQL Updates
-- PostgreSQL ARRAY format with real scenario IDs
-- Focus: Only scenarios with underscore categories from actual database

-- Instructions for execution:
-- 1. Review actual scenario_translations table 
-- 2. Identify rows where category contains underscores
-- 3. Execute updates for those specific scenario_ids only
-- 4. Use PostgreSQL ARRAY syntax: ARRAY['single_tag'] or '{single_tag}'

-- Template for updates (replace with real scenario_ids):
-- UPDATE scenario_translations 
-- SET category = 'normalized_category', tags = ARRAY['single_meaningful_tag']
-- WHERE scenario_id = 'real-scenario-id-from-database';

-- Example patterns for common categories with underscores:
-- academic_pressure_exam_anxiety -> academic pressure
-- job_insecurity_economic_downturn -> job security  
-- fear_missing_life_milestones -> life milestones
-- climate_and_environmental_anxiety -> climate anxiety
-- rediscovering_identity -> identity
-- digital_detox_focus -> digital wellness
-- side_hustle_struggles -> side hustles
-- dating_app_fatigue -> dating apps
-- loneliness_in_crowded_cities -> urban loneliness
-- habit_building_discipline -> habits

-- NOTE: Real scenario_ids needed from database query:
-- SELECT scenario_id, category, tags FROM scenario_translations 
-- WHERE category LIKE '%_%';