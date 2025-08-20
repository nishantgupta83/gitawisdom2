-- ===================================================================
-- GitaWisdom Schema Fixes for Multilingual Implementation
-- File: 003_fix_schema_issues.sql
-- Purpose: Fix critical issues in the existing schema
-- Date: 2025-08-16
-- ===================================================================

-- ===================================================================
-- STEP 1: ADD MISSING TABLES
-- ===================================================================

-- Create daily_quote table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.daily_quote (
    dq_id VARCHAR(50) PRIMARY KEY,
    dq_description TEXT NOT NULL,
    dq_reference TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create chapter_summary table if it doesn't exist (or view)
CREATE TABLE IF NOT EXISTS public.chapter_summary (
    cs_chapter_id INTEGER PRIMARY KEY,
    cs_title VARCHAR(200) NOT NULL,
    cs_subtitle TEXT,
    cs_verse_count INTEGER,
    cs_scenario_count INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT fk_chapter_summary_chapter 
        FOREIGN KEY (cs_chapter_id) REFERENCES public.chapters(ch_chapter_id)
);

-- ===================================================================
-- STEP 2: ADD MISSING CONSTRAINTS
-- ===================================================================

-- Add unique constraints to translation tables
ALTER TABLE public.chapter_translations 
DROP CONSTRAINT IF EXISTS uq_chapter_translations_lang;

ALTER TABLE public.chapter_translations 
ADD CONSTRAINT uq_chapter_translations_lang 
UNIQUE (chapter_id, lang_code);

ALTER TABLE public.scenario_translations 
DROP CONSTRAINT IF EXISTS uq_scenario_translations_lang;

ALTER TABLE public.scenario_translations 
ADD CONSTRAINT uq_scenario_translations_lang 
UNIQUE (scenario_id, lang_code);

ALTER TABLE public.verse_translations 
DROP CONSTRAINT IF EXISTS uq_verse_translations_lang;

ALTER TABLE public.verse_translations 
ADD CONSTRAINT uq_verse_translations_lang 
UNIQUE (verse_id, chapter_id, lang_code);

ALTER TABLE public.daily_quote_translations 
DROP CONSTRAINT IF EXISTS uq_daily_quote_translations_lang;

ALTER TABLE public.daily_quote_translations 
ADD CONSTRAINT uq_daily_quote_translations_lang 
UNIQUE (quote_id, lang_code);

-- ===================================================================
-- STEP 3: DROP EXISTING MATERIALIZED VIEWS (if they exist)
-- ===================================================================

-- Drop existing materialized views that depend on lang_code columns
DROP MATERIALIZED VIEW IF EXISTS public.chapter_summary_multilingual;
DROP MATERIALIZED VIEW IF EXISTS public.scenario_summary_multilingual;

-- ===================================================================
-- STEP 4: FIX DATA TYPES AND CONSTRAINTS
-- ===================================================================

-- Ensure consistent data types (now safe after dropping views)
ALTER TABLE public.supported_languages 
ALTER COLUMN lang_code TYPE VARCHAR(5);

ALTER TABLE public.chapter_translations 
ALTER COLUMN lang_code TYPE VARCHAR(5);

ALTER TABLE public.scenario_translations 
ALTER COLUMN lang_code TYPE VARCHAR(5);

ALTER TABLE public.verse_translations 
ALTER COLUMN lang_code TYPE VARCHAR(5);

ALTER TABLE public.daily_quote_translations 
ALTER COLUMN lang_code TYPE VARCHAR(5);

-- Add proper foreign key for scenarios in scenario_translations
ALTER TABLE public.scenario_translations 
DROP CONSTRAINT IF EXISTS fk_scenario_translations_scenario;

-- First, we need to add a proper integer ID to scenarios table if it doesn't exist
DO $$
BEGIN
    -- Check if scenarios table has an integer id column
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'scenarios' 
        AND column_name = 'scenario_id' 
        AND data_type = 'integer'
    ) THEN
        -- Add auto-incrementing integer ID
        ALTER TABLE public.scenarios ADD COLUMN scenario_id SERIAL;
        
        -- Update scenario_translations to use the new integer IDs
        UPDATE public.scenario_translations st
        SET scenario_id = s.scenario_id
        FROM public.scenarios s
        WHERE st.scenario_id::text = s.id::text;
    END IF;
END
$$;

-- ===================================================================
-- STEP 5: ADD MISSING INDEXES FOR PERFORMANCE
-- ===================================================================

-- Supported Languages Indexes
CREATE INDEX IF NOT EXISTS idx_supported_languages_active 
ON public.supported_languages(is_active, sort_order);

-- Chapter Translations Indexes
CREATE INDEX IF NOT EXISTS idx_chapter_translations_lookup 
ON public.chapter_translations(lang_code, chapter_id);

CREATE INDEX IF NOT EXISTS idx_chapter_translations_chapter 
ON public.chapter_translations(chapter_id);

CREATE INDEX IF NOT EXISTS idx_chapter_translations_lang 
ON public.chapter_translations(lang_code);

CREATE INDEX IF NOT EXISTS idx_chapter_translations_search 
ON public.chapter_translations 
USING gin(to_tsvector('english', title || ' ' || COALESCE(subtitle, '')));

-- Scenario Translations Indexes
CREATE INDEX IF NOT EXISTS idx_scenario_translations_lookup 
ON public.scenario_translations(lang_code, scenario_id);

CREATE INDEX IF NOT EXISTS idx_scenario_translations_scenario 
ON public.scenario_translations(scenario_id);

CREATE INDEX IF NOT EXISTS idx_scenario_translations_lang 
ON public.scenario_translations(lang_code);

CREATE INDEX IF NOT EXISTS idx_scenario_translations_category 
ON public.scenario_translations(lang_code, category);

CREATE INDEX IF NOT EXISTS idx_scenario_translations_search 
ON public.scenario_translations 
USING gin(to_tsvector('english', title || ' ' || description));

CREATE INDEX IF NOT EXISTS idx_scenario_translations_tags 
ON public.scenario_translations USING gin(tags);

-- Verse Translations Indexes
CREATE INDEX IF NOT EXISTS idx_verse_translations_lookup 
ON public.verse_translations(lang_code, chapter_id, verse_id);

CREATE INDEX IF NOT EXISTS idx_verse_translations_chapter 
ON public.verse_translations(chapter_id, lang_code);

CREATE INDEX IF NOT EXISTS idx_verse_translations_verse 
ON public.verse_translations(verse_id, lang_code);

CREATE INDEX IF NOT EXISTS idx_verse_translations_search 
ON public.verse_translations 
USING gin(to_tsvector('english', description));

-- Daily Quote Translations Indexes
CREATE INDEX IF NOT EXISTS idx_daily_quote_translations_lookup 
ON public.daily_quote_translations(lang_code, quote_id);

CREATE INDEX IF NOT EXISTS idx_daily_quote_translations_quote 
ON public.daily_quote_translations(quote_id);

CREATE INDEX IF NOT EXISTS idx_daily_quote_translations_lang 
ON public.daily_quote_translations(lang_code);

-- ===================================================================
-- STEP 6: CREATE MATERIALIZED VIEWS
-- ===================================================================

-- Note: Views were already dropped in STEP 3 before data type changes

-- Chapter Summary with Multilingual Support
CREATE MATERIALIZED VIEW public.chapter_summary_multilingual AS
SELECT 
    c.ch_chapter_id,
    sl.lang_code,
    COALESCE(ct.title, c.ch_title) as title,
    COALESCE(ct.subtitle, c.ch_subtitle) as subtitle,
    c.ch_verse_count,
    -- Calculate scenario count from actual scenarios table
    (SELECT COUNT(*) FROM public.scenarios s WHERE s.sc_chapter = c.ch_chapter_id) as scenario_count,
    c.created_at
FROM public.chapters c
CROSS JOIN public.supported_languages sl
LEFT JOIN public.chapter_translations ct ON c.ch_chapter_id = ct.chapter_id AND sl.lang_code = ct.lang_code
WHERE sl.is_active = TRUE
ORDER BY c.ch_chapter_id, sl.sort_order;

-- Create unique index for materialized view
CREATE UNIQUE INDEX idx_chapter_summary_multilingual_unique 
    ON public.chapter_summary_multilingual(ch_chapter_id, lang_code);

-- Scenario Summary with Multilingual Support
CREATE MATERIALIZED VIEW public.scenario_summary_multilingual AS
SELECT 
    s.scenario_id,
    s.sc_chapter,
    sl.lang_code,
    COALESCE(st.title, s.sc_title) as title,
    COALESCE(st.description, s.sc_description) as description,
    COALESCE(st.category, s.sc_category) as category,
    s.created_at
FROM public.scenarios s
CROSS JOIN public.supported_languages sl
LEFT JOIN public.scenario_translations st ON s.scenario_id = st.scenario_id AND sl.lang_code = st.lang_code
WHERE sl.is_active = TRUE
ORDER BY s.created_at DESC, sl.sort_order;

-- Create unique index for scenario materialized view
CREATE UNIQUE INDEX idx_scenario_summary_multilingual_unique 
    ON public.scenario_summary_multilingual(scenario_id, lang_code);

-- ===================================================================
-- STEP 7: ADD RPC FUNCTIONS FOR FALLBACK LOGIC
-- ===================================================================

-- Function to get chapter with language fallback
CREATE OR REPLACE FUNCTION public.get_chapter_with_fallback(
    p_chapter_id INTEGER,
    p_lang_code VARCHAR(5) DEFAULT 'en'
)
RETURNS TABLE (
    ch_chapter_id INTEGER,
    ch_title TEXT,
    ch_subtitle TEXT,
    ch_summary TEXT,
    ch_verse_count INTEGER,
    ch_theme TEXT,
    ch_key_teachings TEXT[],
    lang_code VARCHAR(5),
    has_translation BOOLEAN
) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.ch_chapter_id,
        COALESCE(ct.title, c.ch_title) as ch_title,
        COALESCE(ct.subtitle, c.ch_subtitle) as ch_subtitle,
        COALESCE(ct.summary, c.ch_summary) as ch_summary,
        c.ch_verse_count,
        COALESCE(ct.theme, c.ch_theme) as ch_theme,
        COALESCE(ct.key_teachings, c.ch_key_teachings) as ch_key_teachings,
        p_lang_code as lang_code,
        (ct.id IS NOT NULL) as has_translation
    FROM public.chapters c
    LEFT JOIN public.chapter_translations ct ON c.ch_chapter_id = ct.chapter_id AND ct.lang_code = p_lang_code
    WHERE c.ch_chapter_id = p_chapter_id;
END;
$$;

-- Function to get scenario with language fallback
CREATE OR REPLACE FUNCTION public.get_scenario_with_fallback(
    p_scenario_id INTEGER,
    p_lang_code VARCHAR(5) DEFAULT 'en'
)
RETURNS TABLE (
    id INTEGER,
    sc_title TEXT,
    sc_description TEXT,
    sc_category TEXT,
    sc_chapter INTEGER,
    sc_heart_response TEXT,
    sc_duty_response TEXT,
    sc_gita_wisdom TEXT,
    sc_verse TEXT,
    sc_verse_number TEXT,
    sc_tags TEXT[],
    sc_action_steps TEXT[],
    created_at TIMESTAMP,
    lang_code VARCHAR(5),
    has_translation BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        s.scenario_id as id,
        COALESCE(st.title, s.sc_title) as sc_title,
        COALESCE(st.description, s.sc_description) as sc_description,
        COALESCE(st.category, s.sc_category) as sc_category,
        s.sc_chapter,
        COALESCE(st.heart_response, s.sc_heart_response) as sc_heart_response,
        COALESCE(st.duty_response, s.sc_duty_response) as sc_duty_response,
        COALESCE(st.gita_wisdom, s.sc_gita_wisdom) as sc_gita_wisdom,
        COALESCE(st.verse, s.sc_verse) as sc_verse,
        COALESCE(st.verse_number, s.sc_verse_number) as sc_verse_number,
        COALESCE(st.tags, s.sc_tags) as sc_tags,
        COALESCE(st.action_steps, s.sc_action_steps) as sc_action_steps,
        s.created_at,
        p_lang_code as lang_code,
        (st.id IS NOT NULL) as has_translation
    FROM public.scenarios s
    LEFT JOIN public.scenario_translations st ON s.scenario_id = st.scenario_id AND st.lang_code = p_lang_code
    WHERE s.scenario_id = p_scenario_id;
END;
$$;

-- Function to get verses with language fallback
CREATE OR REPLACE FUNCTION public.get_verses_with_fallback(
    p_chapter_id INTEGER,
    p_lang_code VARCHAR(5) DEFAULT 'en'
)
RETURNS TABLE (
    gv_verses_id INTEGER,
    gv_chapter_id INTEGER,
    gv_verses TEXT,
    lang_code VARCHAR(5),
    has_translation BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        v.gv_verses_id,
        v.gv_chapter_id,
        COALESCE(vt.description, v.gv_verses) as gv_verses,
        p_lang_code as lang_code,
        (vt.id IS NOT NULL) as has_translation
    FROM public.gita_verses v
    LEFT JOIN public.verse_translations vt ON v.gv_verses_id = vt.verse_id 
        AND v.gv_chapter_id = vt.chapter_id 
        AND vt.lang_code = p_lang_code
    WHERE v.gv_chapter_id = p_chapter_id
    ORDER BY v.gv_verses_id;
END;
$$;

-- Function to get daily quote with language fallback
CREATE OR REPLACE FUNCTION public.get_daily_quote_with_fallback(
    p_quote_id VARCHAR(50),
    p_lang_code VARCHAR(5) DEFAULT 'en'
)
RETURNS TABLE (
    dq_id VARCHAR(50),
    dq_description TEXT,
    dq_reference TEXT,
    created_at TIMESTAMP,
    lang_code VARCHAR(5),
    has_translation BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        dq.dq_id,
        COALESCE(dqt.description, dq.dq_description) as dq_description,
        COALESCE(dqt.reference, dq.dq_reference) as dq_reference,
        dq.created_at,
        p_lang_code as lang_code,
        (dqt.id IS NOT NULL) as has_translation
    FROM public.daily_quote dq
    LEFT JOIN public.daily_quote_translations dqt ON dq.dq_id = dqt.quote_id AND dqt.lang_code = p_lang_code
    WHERE dq.dq_id = p_quote_id;
END;
$$;

-- ===================================================================
-- STEP 8: ADD UTILITY FUNCTIONS
-- ===================================================================

-- Function to refresh materialized views
CREATE OR REPLACE FUNCTION public.refresh_multilingual_views()
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY public.chapter_summary_multilingual;
    REFRESH MATERIALIZED VIEW CONCURRENTLY public.scenario_summary_multilingual;
END;
$$;

-- Function to get translation coverage statistics
CREATE OR REPLACE FUNCTION public.get_translation_coverage()
RETURNS TABLE (
    content_type TEXT,
    lang_code VARCHAR(5),
    native_name TEXT,
    total_items INTEGER,
    translated_items INTEGER,
    coverage_percentage NUMERIC(5,2)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    -- Chapter coverage
    SELECT 
        'chapters' as content_type,
        sl.lang_code,
        sl.native_name,
        (SELECT COUNT(*) FROM public.chapters) as total_items,
        COUNT(ct.id)::INTEGER as translated_items,
        ROUND((COUNT(ct.id)::NUMERIC / (SELECT COUNT(*) FROM public.chapters)) * 100, 2) as coverage_percentage
    FROM public.supported_languages sl
    LEFT JOIN public.chapter_translations ct ON sl.lang_code = ct.lang_code
    WHERE sl.is_active = TRUE
    GROUP BY sl.lang_code, sl.native_name, sl.sort_order
    
    UNION ALL
    
    -- Scenario coverage
    SELECT 
        'scenarios' as content_type,
        sl.lang_code,
        sl.native_name,
        (SELECT COUNT(*) FROM public.scenarios) as total_items,
        COUNT(st.id)::INTEGER as translated_items,
        ROUND((COUNT(st.id)::NUMERIC / (SELECT COUNT(*) FROM public.scenarios)) * 100, 2) as coverage_percentage
    FROM public.supported_languages sl
    LEFT JOIN public.scenario_translations st ON sl.lang_code = st.lang_code
    WHERE sl.is_active = TRUE
    GROUP BY sl.lang_code, sl.native_name, sl.sort_order
    
    UNION ALL
    
    -- Verses coverage
    SELECT 
        'verses' as content_type,
        sl.lang_code,
        sl.native_name,
        (SELECT COUNT(*) FROM public.gita_verses) as total_items,
        COUNT(vt.id)::INTEGER as translated_items,
        ROUND((COUNT(vt.id)::NUMERIC / (SELECT COUNT(*) FROM public.gita_verses)) * 100, 2) as coverage_percentage
    FROM public.supported_languages sl
    LEFT JOIN public.verse_translations vt ON sl.lang_code = vt.lang_code
    WHERE sl.is_active = TRUE
    GROUP BY sl.lang_code, sl.native_name, sl.sort_order
    
    UNION ALL
    
    -- Daily quotes coverage
    SELECT 
        'daily_quotes' as content_type,
        sl.lang_code,
        sl.native_name,
        (SELECT COUNT(*) FROM public.daily_quote) as total_items,
        COUNT(dqt.id)::INTEGER as translated_items,
        ROUND((COUNT(dqt.id)::NUMERIC / (SELECT COUNT(*) FROM public.daily_quote)) * 100, 2) as coverage_percentage
    FROM public.supported_languages sl
    LEFT JOIN public.daily_quote_translations dqt ON sl.lang_code = dqt.lang_code
    WHERE sl.is_active = TRUE
    GROUP BY sl.lang_code, sl.native_name, sl.sort_order
    
    ORDER BY content_type, coverage_percentage DESC;
END;
$$;

-- ===================================================================
-- STEP 9: ADD TRIGGERS FOR AUTOMATIC UPDATES
-- ===================================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add triggers to all translation tables (drop first if they exist)
DROP TRIGGER IF EXISTS tr_chapter_translations_updated_at ON public.chapter_translations;
CREATE TRIGGER tr_chapter_translations_updated_at
    BEFORE UPDATE ON public.chapter_translations
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

DROP TRIGGER IF EXISTS tr_scenario_translations_updated_at ON public.scenario_translations;
CREATE TRIGGER tr_scenario_translations_updated_at
    BEFORE UPDATE ON public.scenario_translations
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

DROP TRIGGER IF EXISTS tr_verse_translations_updated_at ON public.verse_translations;
CREATE TRIGGER tr_verse_translations_updated_at
    BEFORE UPDATE ON public.verse_translations
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

DROP TRIGGER IF EXISTS tr_daily_quote_translations_updated_at ON public.daily_quote_translations;
CREATE TRIGGER tr_daily_quote_translations_updated_at
    BEFORE UPDATE ON public.daily_quote_translations
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

-- ===================================================================
-- STEP 10: POPULATE SUPPORTED LANGUAGES (IF EMPTY)
-- ===================================================================

-- Only insert if the table is empty
INSERT INTO public.supported_languages (lang_code, native_name, english_name, flag_emoji, is_rtl, sort_order)
SELECT * FROM (VALUES
    ('en', 'English', 'English', '🇺🇸', FALSE, 1),
    ('hi', 'हिन्दी', 'Hindi', '🇮🇳', FALSE, 2),
    ('es', 'Español', 'Spanish', '🇪🇸', FALSE, 3),
    ('fr', 'Français', 'French', '🇫🇷', FALSE, 4),
    ('de', 'Deutsch', 'German', '🇩🇪', FALSE, 5),
    ('pt', 'Português', 'Portuguese', '🇧🇷', FALSE, 6),
    ('it', 'Italiano', 'Italian', '🇮🇹', FALSE, 7),
    ('ru', 'Русский', 'Russian', '🇷🇺', FALSE, 8),
    ('bn', 'বাংলা', 'Bengali', '🇧🇩', FALSE, 9),
    ('gu', 'ગુજરાતી', 'Gujarati', '🇮🇳', FALSE, 10),
    ('kn', 'ಕನ್ನಡ', 'Kannada', '🇮🇳', FALSE, 11),
    ('mr', 'मराठी', 'Marathi', '🇮🇳', FALSE, 12),
    ('ta', 'தமிழ்', 'Tamil', '🇮🇳', FALSE, 13),
    ('te', 'తెలుగు', 'Telugu', '🇮🇳', FALSE, 14),
    ('sa', 'संस्कृतम्', 'Sanskrit', '🕉️', FALSE, 15)
) AS new_langs(lang_code, native_name, english_name, flag_emoji, is_rtl, sort_order)
WHERE NOT EXISTS (SELECT 1 FROM public.supported_languages WHERE supported_languages.lang_code = new_langs.lang_code);

-- ===================================================================
-- STEP 11: POPULATE SOME SAMPLE DAILY QUOTES (IF EMPTY)
-- ===================================================================

-- Add sample daily quotes if table is empty
INSERT INTO public.daily_quote (dq_id, dq_description, dq_reference)
SELECT * FROM (VALUES
    ('quote_001', 'You have the right to action alone, never to its fruits. Do not be motivated by the fruits of action, nor should you be attached to inaction.', 'Bhagavad Gita 2.47'),
    ('quote_002', 'The mind is everything. What you think you become.', 'Bhagavad Gita 6.5'),
    ('quote_003', 'Set thy heart upon thy work, but never on its reward.', 'Bhagavad Gita 2.47'),
    ('quote_004', 'The soul is neither born, and nor does it die.', 'Bhagavad Gita 2.20'),
    ('quote_005', 'Better is one''s own dharma, though imperfectly performed, than the dharma of another well performed.', 'Bhagavad Gita 3.35')
) AS new_quotes(dq_id, dq_description, dq_reference)
WHERE NOT EXISTS (SELECT 1 FROM public.daily_quote LIMIT 1);

-- ===================================================================
-- STEP 12: VALIDATION AND FINAL CHECKS
-- ===================================================================

-- Run validation checks
DO $$
DECLARE
    table_count INTEGER;
    function_count INTEGER;
    index_count INTEGER;
BEGIN
    -- Check translation tables exist
    SELECT COUNT(*) INTO table_count
    FROM information_schema.tables 
    WHERE table_name IN ('chapter_translations', 'scenario_translations', 'verse_translations', 'daily_quote_translations', 'supported_languages');
    
    IF table_count < 5 THEN
        RAISE EXCEPTION 'Missing translation tables. Expected 5, found %', table_count;
    END IF;
    
    -- Check functions exist
    SELECT COUNT(*) INTO function_count
    FROM pg_proc 
    WHERE proname IN ('get_chapter_with_fallback', 'get_scenario_with_fallback', 'get_verses_with_fallback', 'get_daily_quote_with_fallback', 'get_translation_coverage');
    
    IF function_count < 5 THEN
        RAISE EXCEPTION 'Missing RPC functions. Expected 5, found %', function_count;
    END IF;
    
    -- Check materialized views exist
    SELECT COUNT(*) INTO table_count
    FROM pg_matviews 
    WHERE matviewname IN ('chapter_summary_multilingual', 'scenario_summary_multilingual');
    
    IF table_count < 2 THEN
        RAISE EXCEPTION 'Missing materialized views. Expected 2, found %', table_count;
    END IF;
    
    RAISE NOTICE '✅ Schema validation passed! All required components are present.';
    RAISE NOTICE '📊 Tables: % translation tables found', table_count;
    RAISE NOTICE '🔧 Functions: % RPC functions found', function_count;
    RAISE NOTICE '📈 Views: % materialized views found', table_count;
END;
$$;

-- Update statistics for better query planning
ANALYZE public.supported_languages;
ANALYZE public.chapter_translations;
ANALYZE public.scenario_translations;
ANALYZE public.verse_translations;
ANALYZE public.daily_quote_translations;

-- ===================================================================
-- SCHEMA FIXES COMPLETE
-- ===================================================================

COMMENT ON SCHEMA public IS 'GitaWisdom multilingual database schema - Fixed and optimized v1.1';

-- Final success message
DO $$
BEGIN
    RAISE NOTICE '🎉 Schema fixes completed successfully!';
    RAISE NOTICE '📋 Next steps:';
    RAISE NOTICE '   1. Run the content migration: \i 002_migrate_existing_content.sql';
    RAISE NOTICE '   2. Test the RPC functions: SELECT * FROM get_chapter_with_fallback(1, ''en'');';
    RAISE NOTICE '   3. Check translation coverage: SELECT * FROM get_translation_coverage();';
    RAISE NOTICE '   4. Refresh materialized views: SELECT refresh_multilingual_views();';
END;
$$;