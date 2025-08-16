-- Simple content migration without complex loops
-- Drop existing functions
DROP FUNCTION IF EXISTS validate_migration_prerequisites();
DROP FUNCTION IF EXISTS validate_migration_success();

-- Create simple validation function
CREATE FUNCTION validate_migration_prerequisites()
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    lang_exists BOOLEAN;
BEGIN
    SELECT EXISTS(SELECT 1 FROM supported_languages WHERE lang_code = 'en') INTO lang_exists;
    IF NOT lang_exists THEN
        RAISE EXCEPTION 'English language (en) not found in supported_languages table';
    END IF;
    RETURN TRUE;
END;
$$;

-- Validate prerequisites
SELECT validate_migration_prerequisites();

-- Migrate chapters
INSERT INTO chapter_translations (
    chapter_id, lang_code, title, subtitle, summary, theme, key_teachings,
    created_at, updated_at
)
SELECT 
    ch_chapter_id,
    'en' as lang_code,
    ch_title,
    ch_subtitle,
    ch_summary,
    ch_theme,
    ch_key_teachings,
    NOW(),
    NOW()
FROM chapters
WHERE NOT EXISTS (
    SELECT 1 FROM chapter_translations 
    WHERE chapter_id = chapters.ch_chapter_id AND lang_code = 'en'
);

-- Migrate scenarios
INSERT INTO scenario_translations (
    scenario_id, lang_code, title, description, category,
    heart_response, duty_response, gita_wisdom, verse, verse_number,
    tags, action_steps, created_at, updated_at
)
SELECT 
    id,
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
    NOW(),
    NOW()
FROM scenarios
WHERE NOT EXISTS (
    SELECT 1 FROM scenario_translations 
    WHERE scenario_id = scenarios.id AND lang_code = 'en'
);

-- Migrate verses
INSERT INTO verse_translations (
    verse_id, chapter_id, lang_code, description,
    created_at, updated_at
)
SELECT 
    gv_verses_id,
    gv_chapter_id,
    'en' as lang_code,
    gv_verses,
    NOW(),
    NOW()
FROM gita_verses
WHERE NOT EXISTS (
    SELECT 1 FROM verse_translations 
    WHERE verse_id = gita_verses.gv_verses_id 
    AND chapter_id = gita_verses.gv_chapter_id 
    AND lang_code = 'en'
);

-- Migrate daily quotes (if table exists)
INSERT INTO daily_quote_translations (
    quote_id, lang_code, description, reference,
    created_at, updated_at
)
SELECT 
    dq_id,
    'en' as lang_code,
    dq_description,
    dq_reference,
    NOW(),
    NOW()
FROM daily_quote
WHERE EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'daily_quote')
AND NOT EXISTS (
    SELECT 1 FROM daily_quote_translations 
    WHERE quote_id = daily_quote.dq_id AND lang_code = 'en'
);

-- Update statistics
ANALYZE;

-- Simple validation
DO $$
DECLARE
    ch_count INTEGER;
    sc_count INTEGER;
    v_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO ch_count FROM chapter_translations WHERE lang_code = 'en';
    SELECT COUNT(*) INTO sc_count FROM scenario_translations WHERE lang_code = 'en';
    SELECT COUNT(*) INTO v_count FROM verse_translations WHERE lang_code = 'en';
    
    RAISE NOTICE 'Migration complete: Chapters=%, Scenarios=%, Verses=%', ch_count, sc_count, v_count;
END;
$$;