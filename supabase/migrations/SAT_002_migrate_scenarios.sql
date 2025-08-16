-- Migrate scenarios to English translations
INSERT INTO scenario_translations (
    scenario_id, lang_code, title, description, category,
    heart_response, duty_response, gita_wisdom, verse, verse_number,
    tags, action_steps, created_at, updated_at
)
SELECT 
    scenario_id,
    'en' as lang_code,
    sc_title,
    sc_description,
    sc_category,
    sc_heart_response,
    sc_duty_response,
    sc_gita_wisdom,
    sc_verse,
    sc_verse_number,
    sc_tags,
    sc_action_steps,
    COALESCE(created_at, NOW()),
    NOW()
FROM scenarios
WHERE scenario_id IS NOT NULL
AND NOT EXISTS (
    SELECT 1 FROM scenario_translations 
    WHERE scenario_id = scenarios.scenario_id AND lang_code = 'en'
);

SELECT COUNT(*) as migrated_scenarios FROM scenario_translations WHERE lang_code = 'en';