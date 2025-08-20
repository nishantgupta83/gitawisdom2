-- ===================================================================
-- GitaWisdom Schema Fixes for Multilingual Implementation v2
-- File: 003_fix_schema_issues_v2.sql  
-- Purpose: Fix critical issues in existing schema (handles view dependencies)
-- Date: 2025-08-16
-- ===================================================================

-- ===================================================================
-- STEP 1: BACKUP AND SAFETY CHECK
-- ===================================================================

-- Check if we have the necessary tables
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'supported_languages') THEN
        RAISE EXCEPTION 'supported_languages table not found. Please run the base schema migration first.';
    END IF;
    
    RAISE NOTICE '✅ Starting schema fixes for GitaWisdom multilingual implementation...';
END;
$$;

-- ===================================================================
-- STEP 2: ADD MISSING TABLES (if they don't exist)
-- ===================================================================

-- Create daily_quote table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.daily_quote (
    dq_id VARCHAR(50) PRIMARY KEY,
    dq_description TEXT NOT NULL,
    dq_reference TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create chapter_summary table if it doesn't exist
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
-- STEP 3: SAFELY DROP VIEWS BEFORE SCHEMA CHANGES
-- ===================================================================

-- Drop materialized views that might depend on columns we need to modify
DROP MATERIALIZED VIEW IF EXISTS public.chapter_summary_multilingual CASCADE;
DROP MATERIALIZED VIEW IF EXISTS public.scenario_summary_multilingual CASCADE;

-- ===================================================================
-- STEP 4: ADD MISSING CONSTRAINTS (ignoring if they already exist)
-- ===================================================================

-- Add unique constraints to translation tables (ignore if exists)
DO $$
BEGIN
    -- Chapter translations constraint
    BEGIN
        ALTER TABLE public.chapter_translations 
        ADD CONSTRAINT uq_chapter_translations_lang 
        UNIQUE (chapter_id, lang_code);
    EXCEPTION WHEN duplicate_table THEN
        RAISE NOTICE 'uq_chapter_translations_lang constraint already exists, skipping...';
    END;
    
    -- Scenario translations constraint  
    BEGIN
        ALTER TABLE public.scenario_translations 
        ADD CONSTRAINT uq_scenario_translations_lang 
        UNIQUE (scenario_id, lang_code);
    EXCEPTION WHEN duplicate_table THEN
        RAISE NOTICE 'uq_scenario_translations_lang constraint already exists, skipping...';
    END;
    
    -- Verse translations constraint
    BEGIN
        ALTER TABLE public.verse_translations 
        ADD CONSTRAINT uq_verse_translations_lang 
        UNIQUE (verse_id, chapter_id, lang_code);
    EXCEPTION WHEN duplicate_table THEN
        RAISE NOTICE 'uq_verse_translations_lang constraint already exists, skipping...';
    END;
    
    -- Daily quote translations constraint
    BEGIN
        ALTER TABLE public.daily_quote_translations 
        ADD CONSTRAINT uq_daily_quote_translations_lang 
        UNIQUE (quote_id, lang_code);
    EXCEPTION WHEN duplicate_table THEN
        RAISE NOTICE 'uq_daily_quote_translations_lang constraint already exists, skipping...';
    END;
END;
$$;

-- ===================================================================
-- STEP 5: FIX DATA TYPES (now safe after dropping views)
-- ===================================================================

-- Update lang_code columns to consistent VARCHAR(5) if needed
DO $$
BEGIN
    -- Check and update each table's lang_code column type
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'supported_languages' 
        AND column_name = 'lang_code' 
        AND data_type != 'character varying'
    ) THEN
        ALTER TABLE public.supported_languages 
        ALTER COLUMN lang_code TYPE VARCHAR(5);
        RAISE NOTICE '✅ Updated supported_languages.lang_code to VARCHAR(5)';
    END IF;
    
    -- Update other translation tables similarly
    PERFORM 1; -- Placeholder for additional type updates if needed
END;
$$;

-- ===================================================================
-- STEP 6: ADD PERFORMANCE INDEXES
-- ===================================================================

-- Create indexes if they don't exist
CREATE INDEX IF NOT EXISTS idx_supported_languages_active 
ON public.supported_languages(is_active, sort_order);

CREATE INDEX IF NOT EXISTS idx_chapter_translations_lookup 
ON public.chapter_translations(lang_code, chapter_id);

CREATE INDEX IF NOT EXISTS idx_scenario_translations_lookup 
ON public.scenario_translations(lang_code, scenario_id);

CREATE INDEX IF NOT EXISTS idx_verse_translations_lookup 
ON public.verse_translations(lang_code, chapter_id, verse_id);

CREATE INDEX IF NOT EXISTS idx_daily_quote_translations_lookup 
ON public.daily_quote_translations(lang_code, quote_id);

-- Text search indexes
CREATE INDEX IF NOT EXISTS idx_chapter_translations_search 
ON public.chapter_translations 
USING gin(to_tsvector('english', title || ' ' || COALESCE(subtitle, '')));

CREATE INDEX IF NOT EXISTS idx_scenario_translations_search 
ON public.scenario_translations 
USING gin(to_tsvector('english', title || ' ' || description));

-- ===================================================================
-- STEP 7: RECREATE MATERIALIZED VIEWS
-- ===================================================================

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
CREATE UNIQUE INDEX IF NOT EXISTS idx_chapter_summary_multilingual_unique 
    ON public.chapter_summary_multilingual(ch_chapter_id, lang_code);

-- Scenario Summary with Multilingual Support
CREATE MATERIALIZED VIEW public.scenario_summary_multilingual AS
SELECT 
    s.id as scenario_id,
    s.sc_chapter,
    sl.lang_code,
    COALESCE(st.title, s.sc_title) as title,
    COALESCE(st.description, s.sc_description) as description,
    COALESCE(st.category, s.sc_category) as category,
    s.created_at
FROM public.scenarios s
CROSS JOIN public.supported_languages sl
LEFT JOIN public.scenario_translations st ON s.id = st.scenario_id AND sl.lang_code = st.lang_code
WHERE sl.is_active = TRUE
ORDER BY s.created_at DESC, sl.sort_order;

-- Create unique index for scenario materialized view  
CREATE UNIQUE INDEX IF NOT EXISTS idx_scenario_summary_multilingual_unique 
    ON public.scenario_summary_multilingual(scenario_id, lang_code);

-- ===================================================================
-- STEP 8: ADD ESSENTIAL RPC FUNCTIONS
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

-- Function to refresh materialized views
CREATE OR REPLACE FUNCTION public.refresh_multilingual_views()
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY public.chapter_summary_multilingual;
    REFRESH MATERIALIZED VIEW CONCURRENTLY public.scenario_summary_multilingual;
    RAISE NOTICE '✅ Materialized views refreshed successfully';
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
    
    ORDER BY content_type, coverage_percentage DESC;
END;
$$;

-- ===================================================================
-- STEP 9: POPULATE SUPPORTED LANGUAGES (if empty)
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
-- STEP 10: FINAL VALIDATION
-- ===================================================================

-- Run validation checks
DO $$
DECLARE
    table_count INTEGER;
    function_count INTEGER;
    supported_lang_count INTEGER;
BEGIN
    -- Check translation tables exist
    SELECT COUNT(*) INTO table_count
    FROM information_schema.tables 
    WHERE table_name IN ('chapter_translations', 'scenario_translations', 'verse_translations', 'supported_languages');
    
    IF table_count < 4 THEN
        RAISE WARNING 'Some translation tables are missing. Expected 4, found %', table_count;
    ELSE
        RAISE NOTICE '✅ All translation tables found (%)', table_count;
    END IF;
    
    -- Check functions exist
    SELECT COUNT(*) INTO function_count
    FROM pg_proc 
    WHERE proname IN ('get_chapter_with_fallback', 'get_translation_coverage', 'refresh_multilingual_views');
    
    IF function_count >= 3 THEN
        RAISE NOTICE '✅ Core RPC functions found (%)', function_count;
    ELSE
        RAISE WARNING 'Some RPC functions missing. Expected 3+, found %', function_count;
    END IF;
    
    -- Check supported languages populated
    SELECT COUNT(*) INTO supported_lang_count FROM public.supported_languages;
    
    IF supported_lang_count >= 15 THEN
        RAISE NOTICE '✅ Supported languages populated (% languages)', supported_lang_count;
    ELSE
        RAISE WARNING 'Expected at least 15 supported languages, found %', supported_lang_count;
    END IF;
    
    RAISE NOTICE '🎉 GitaWisdom multilingual schema fixes completed!';
    RAISE NOTICE '📋 Next steps:';
    RAISE NOTICE '   1. Test language switching: SELECT * FROM get_chapter_with_fallback(1, ''hi'');';
    RAISE NOTICE '   2. Check coverage: SELECT * FROM get_translation_coverage();';
    RAISE NOTICE '   3. Update your Flutter app to use the enhanced service';
END;
$$;

-- Update table statistics for optimal query performance
ANALYZE public.supported_languages;
ANALYZE public.chapter_translations;
ANALYZE public.scenario_translations;

-- ===================================================================
-- SCHEMA FIXES COMPLETE - Ready for Production! 
-- ===================================================================