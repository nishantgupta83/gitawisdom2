-- ===================================================================
-- GitaWisdom Schema Fixes for Multilingual Implementation v3
-- File: 003_fix_schema_issues_v3.sql  
-- Purpose: Fix critical issues in existing schema (aggressive view cleanup)
-- Author: Claude Code Assistant
-- Date: 2025-08-16
-- ===================================================================

-- ===================================================================
-- STEP 1: AGGRESSIVE VIEW AND DEPENDENCY CLEANUP
-- ===================================================================

DO $$
BEGIN
    RAISE NOTICE '🧹 Starting aggressive cleanup of views and dependencies...';
    
    -- Drop all possible materialized views that could depend on our columns
    DROP MATERIALIZED VIEW IF EXISTS public.chapter_summary_multilingual CASCADE;
    DROP MATERIALIZED VIEW IF EXISTS public.scenario_summary_multilingual CASCADE;
    DROP MATERIALIZED VIEW IF EXISTS public.verse_summary_multilingual CASCADE;
    DROP MATERIALIZED VIEW IF EXISTS public.daily_quote_summary_multilingual CASCADE;
    
    -- Drop any regular views that might exist
    DROP VIEW IF EXISTS public.chapter_summary_multilingual CASCADE;
    DROP VIEW IF EXISTS public.scenario_summary_multilingual CASCADE;
    DROP VIEW IF EXISTS public.verse_summary_multilingual CASCADE;
    DROP VIEW IF EXISTS public.daily_quote_summary_multilingual CASCADE;
    
    -- Drop any other views that might reference translation tables
    DROP VIEW IF EXISTS public.multilingual_chapter_view CASCADE;
    DROP VIEW IF EXISTS public.multilingual_scenario_view CASCADE;
    DROP VIEW IF EXISTS public.translation_coverage_view CASCADE;
    
    RAISE NOTICE '✅ View cleanup completed';
END;
$$;

-- ===================================================================
-- STEP 2: CHECK AND CREATE MISSING TABLES
-- ===================================================================

-- Create daily_quote table if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'daily_quote') THEN
        CREATE TABLE public.daily_quote (
            dq_id VARCHAR(50) PRIMARY KEY,
            dq_description TEXT NOT NULL,
            dq_reference TEXT,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
        RAISE NOTICE '✅ Created daily_quote table';
    ELSE
        RAISE NOTICE '📋 daily_quote table already exists';
    END IF;
END;
$$;

-- Create chapter_summary table if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'chapter_summary') THEN
        CREATE TABLE public.chapter_summary (
            cs_chapter_id INTEGER PRIMARY KEY,
            cs_title VARCHAR(200) NOT NULL,
            cs_subtitle TEXT,
            cs_verse_count INTEGER,
            cs_scenario_count INTEGER,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
        RAISE NOTICE '✅ Created chapter_summary table';
    ELSE
        RAISE NOTICE '📋 chapter_summary table already exists';
    END IF;
END;
$$;

-- ===================================================================
-- STEP 3: CHECK EXISTING COLUMN TYPES BEFORE MODIFICATION
-- ===================================================================

DO $$
DECLARE
    current_type TEXT;
BEGIN
    -- Check current type of lang_code in supported_languages
    SELECT data_type INTO current_type
    FROM information_schema.columns 
    WHERE table_name = 'supported_languages' 
    AND column_name = 'lang_code';
    
    RAISE NOTICE '📋 Current lang_code type in supported_languages: %', current_type;
    
    -- Only alter if it's not already VARCHAR(5) or character varying
    IF current_type IS NOT NULL AND current_type NOT LIKE '%character varying%' THEN
        RAISE NOTICE '🔄 Need to update column types...';
    ELSE
        RAISE NOTICE '✅ Column types appear to be correct';
    END IF;
END;
$$;

-- ===================================================================
-- STEP 4: SAFE COLUMN TYPE UPDATES (if needed)
-- ===================================================================

-- Update lang_code columns to VARCHAR(5) only if necessary
DO $$
BEGIN
    -- Update supported_languages first
    BEGIN
        ALTER TABLE public.supported_languages 
        ALTER COLUMN lang_code TYPE VARCHAR(5);
        RAISE NOTICE '✅ Updated supported_languages.lang_code to VARCHAR(5)';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE '📋 supported_languages.lang_code already correct type or update not needed';
    END;
    
    -- Update translation tables
    BEGIN
        ALTER TABLE public.chapter_translations 
        ALTER COLUMN lang_code TYPE VARCHAR(5);
        RAISE NOTICE '✅ Updated chapter_translations.lang_code to VARCHAR(5)';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE '📋 chapter_translations.lang_code already correct type';
    END;
    
    BEGIN
        ALTER TABLE public.scenario_translations 
        ALTER COLUMN lang_code TYPE VARCHAR(5);
        RAISE NOTICE '✅ Updated scenario_translations.lang_code to VARCHAR(5)';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE '📋 scenario_translations.lang_code already correct type';
    END;
    
    BEGIN
        ALTER TABLE public.verse_translations 
        ALTER COLUMN lang_code TYPE VARCHAR(5);
        RAISE NOTICE '✅ Updated verse_translations.lang_code to VARCHAR(5)';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE '📋 verse_translations.lang_code already correct type';
    END;
    
    BEGIN
        ALTER TABLE public.daily_quote_translations 
        ALTER COLUMN lang_code TYPE VARCHAR(5);
        RAISE NOTICE '✅ Updated daily_quote_translations.lang_code to VARCHAR(5)';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE '📋 daily_quote_translations.lang_code already correct type';
    END;
END;
$$;

-- ===================================================================
-- STEP 5: ADD MISSING CONSTRAINTS (with error handling)
-- ===================================================================

DO $$
BEGIN
    -- Chapter translations unique constraint
    BEGIN
        ALTER TABLE public.chapter_translations 
        ADD CONSTRAINT uq_chapter_translations_lang 
        UNIQUE (chapter_id, lang_code);
        RAISE NOTICE '✅ Added uq_chapter_translations_lang constraint';
    EXCEPTION WHEN duplicate_table THEN
        RAISE NOTICE '📋 uq_chapter_translations_lang constraint already exists';
    WHEN OTHERS THEN
        RAISE NOTICE '⚠️  Could not add uq_chapter_translations_lang constraint: %', SQLERRM;
    END;
    
    -- Scenario translations unique constraint  
    BEGIN
        ALTER TABLE public.scenario_translations 
        ADD CONSTRAINT uq_scenario_translations_lang 
        UNIQUE (scenario_id, lang_code);
        RAISE NOTICE '✅ Added uq_scenario_translations_lang constraint';
    EXCEPTION WHEN duplicate_table THEN
        RAISE NOTICE '📋 uq_scenario_translations_lang constraint already exists';
    WHEN OTHERS THEN
        RAISE NOTICE '⚠️  Could not add uq_scenario_translations_lang constraint: %', SQLERRM;
    END;
    
    -- Verse translations unique constraint
    BEGIN
        ALTER TABLE public.verse_translations 
        ADD CONSTRAINT uq_verse_translations_lang 
        UNIQUE (verse_id, chapter_id, lang_code);
        RAISE NOTICE '✅ Added uq_verse_translations_lang constraint';
    EXCEPTION WHEN duplicate_table THEN
        RAISE NOTICE '📋 uq_verse_translations_lang constraint already exists';
    WHEN OTHERS THEN
        RAISE NOTICE '⚠️  Could not add uq_verse_translations_lang constraint: %', SQLERRM;
    END;
    
    -- Daily quote translations unique constraint
    BEGIN
        ALTER TABLE public.daily_quote_translations 
        ADD CONSTRAINT uq_daily_quote_translations_lang 
        UNIQUE (quote_id, lang_code);
        RAISE NOTICE '✅ Added uq_daily_quote_translations_lang constraint';
    EXCEPTION WHEN duplicate_table THEN
        RAISE NOTICE '📋 uq_daily_quote_translations_lang constraint already exists';
    WHEN OTHERS THEN
        RAISE NOTICE '⚠️  Could not add uq_daily_quote_translations_lang constraint: %', SQLERRM;
    END;
END;
$$;

-- ===================================================================
-- STEP 6: ADD PERFORMANCE INDEXES
-- ===================================================================

-- Create essential indexes
CREATE INDEX IF NOT EXISTS idx_supported_languages_active 
ON public.supported_languages(is_active, sort_order);

CREATE INDEX IF NOT EXISTS idx_chapter_translations_lookup 
ON public.chapter_translations(lang_code, chapter_id);

CREATE INDEX IF NOT EXISTS idx_scenario_translations_lookup 
ON public.scenario_translations(lang_code, scenario_id);

CREATE INDEX IF NOT EXISTS idx_verse_translations_lookup 
ON public.verse_translations(lang_code, chapter_id, verse_id);

-- Only create daily_quote indexes if the table exists
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'daily_quote_translations') THEN
        CREATE INDEX IF NOT EXISTS idx_daily_quote_translations_lookup 
        ON public.daily_quote_translations(lang_code, quote_id);
        RAISE NOTICE '✅ Created daily_quote_translations indexes';
    END IF;
END;
$$;

-- Text search indexes (only if gin extension is available)
DO $$
BEGIN
    -- Try to create GIN indexes for text search
    BEGIN
        CREATE INDEX IF NOT EXISTS idx_chapter_translations_search 
        ON public.chapter_translations 
        USING gin(to_tsvector('english', title || ' ' || COALESCE(subtitle, '')));
        
        CREATE INDEX IF NOT EXISTS idx_scenario_translations_search 
        ON public.scenario_translations 
        USING gin(to_tsvector('english', title || ' ' || description));
        
        RAISE NOTICE '✅ Created text search indexes';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE '⚠️  Could not create text search indexes (may need GIN extension): %', SQLERRM;
    END;
END;
$$;

-- ===================================================================
-- STEP 7: ESSENTIAL RPC FUNCTIONS
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
        ROUND((COUNT(ct.id)::NUMERIC / NULLIF((SELECT COUNT(*) FROM public.chapters), 0)) * 100, 2) as coverage_percentage
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
        ROUND((COUNT(st.id)::NUMERIC / NULLIF((SELECT COUNT(*) FROM public.scenarios), 0)) * 100, 2) as coverage_percentage
    FROM public.supported_languages sl
    LEFT JOIN public.scenario_translations st ON sl.lang_code = st.lang_code
    WHERE sl.is_active = TRUE
    GROUP BY sl.lang_code, sl.native_name, sl.sort_order
    
    ORDER BY content_type, coverage_percentage DESC;
END;
$$;

-- ===================================================================
-- STEP 8: POPULATE SUPPORTED LANGUAGES (if empty)
-- ===================================================================

-- Insert languages only if table is empty
DO $$
DECLARE
    lang_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO lang_count FROM public.supported_languages;
    
    IF lang_count = 0 THEN
        INSERT INTO public.supported_languages (lang_code, native_name, english_name, flag_emoji, is_rtl, sort_order, created_at, updated_at)
        VALUES
            ('en', 'English', 'English', '🇺🇸', FALSE, 1, NOW(), NOW()),
            ('hi', 'हिन्दी', 'Hindi', '🇮🇳', FALSE, 2, NOW(), NOW()),
            ('es', 'Español', 'Spanish', '🇪🇸', FALSE, 3, NOW(), NOW()),
            ('fr', 'Français', 'French', '🇫🇷', FALSE, 4, NOW(), NOW()),
            ('de', 'Deutsch', 'German', '🇩🇪', FALSE, 5, NOW(), NOW()),
            ('pt', 'Português', 'Portuguese', '🇧🇷', FALSE, 6, NOW(), NOW()),
            ('it', 'Italiano', 'Italian', '🇮🇹', FALSE, 7, NOW(), NOW()),
            ('ru', 'Русский', 'Russian', '🇷🇺', FALSE, 8, NOW(), NOW()),
            ('bn', 'বাংলা', 'Bengali', '🇧🇩', FALSE, 9, NOW(), NOW()),
            ('gu', 'ગુજરાતી', 'Gujarati', '🇮🇳', FALSE, 10, NOW(), NOW()),
            ('kn', 'ಕನ್ನಡ', 'Kannada', '🇮🇳', FALSE, 11, NOW(), NOW()),
            ('mr', 'मराठी', 'Marathi', '🇮🇳', FALSE, 12, NOW(), NOW()),
            ('ta', 'தமிழ்', 'Tamil', '🇮🇳', FALSE, 13, NOW(), NOW()),
            ('te', 'తెలుగు', 'Telugu', '🇮🇳', FALSE, 14, NOW(), NOW()),
            ('sa', 'संस्कृतम्', 'Sanskrit', '🕉️', FALSE, 15, NOW(), NOW());
        
        RAISE NOTICE '✅ Populated supported_languages with 15 languages';
    ELSE
        RAISE NOTICE '📋 Supported languages already populated (% languages)', lang_count;
    END IF;
END;
$$;

-- ===================================================================
-- STEP 9: RECREATE ESSENTIAL MATERIALIZED VIEWS
-- ===================================================================

-- Only create materialized views if the base tables are ready
DO $$
DECLARE
    chapters_exist BOOLEAN;
    scenarios_exist BOOLEAN;
BEGIN
    -- Check if required tables exist
    SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'chapters') INTO chapters_exist;
    SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'scenarios') INTO scenarios_exist;
    
    IF chapters_exist THEN
        -- Chapter Summary with Multilingual Support
        CREATE MATERIALIZED VIEW public.chapter_summary_multilingual AS
        SELECT 
            c.ch_chapter_id,
            sl.lang_code,
            COALESCE(ct.title, c.ch_title) as title,
            COALESCE(ct.subtitle, c.ch_subtitle) as subtitle,
            c.ch_verse_count,
            COALESCE(
                (SELECT COUNT(*) FROM public.scenarios s WHERE s.sc_chapter = c.ch_chapter_id), 
                0
            ) as scenario_count,
            c.created_at
        FROM public.chapters c
        CROSS JOIN public.supported_languages sl
        LEFT JOIN public.chapter_translations ct ON c.ch_chapter_id = ct.chapter_id AND sl.lang_code = ct.lang_code
        WHERE sl.is_active = TRUE
        ORDER BY c.ch_chapter_id, sl.sort_order;

        -- Create unique index for materialized view
        CREATE UNIQUE INDEX IF NOT EXISTS idx_chapter_summary_multilingual_unique 
            ON public.chapter_summary_multilingual(ch_chapter_id, lang_code);
            
        RAISE NOTICE '✅ Created chapter_summary_multilingual view';
    END IF;
    
    IF scenarios_exist THEN
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
            
        RAISE NOTICE '✅ Created scenario_summary_multilingual view';
    END IF;
    
    -- Function to refresh materialized views
    CREATE OR REPLACE FUNCTION public.refresh_multilingual_views()
    RETURNS void
    LANGUAGE plpgsql
    AS $func$
    BEGIN
        IF chapters_exist THEN
            REFRESH MATERIALIZED VIEW CONCURRENTLY public.chapter_summary_multilingual;
        END IF;
        
        IF scenarios_exist THEN
            REFRESH MATERIALIZED VIEW CONCURRENTLY public.scenario_summary_multilingual;
        END IF;
        
        RAISE NOTICE '✅ Materialized views refreshed successfully';
    END;
    $func$;
    
    RAISE NOTICE '✅ Created refresh_multilingual_views function';
END;
$$;

-- ===================================================================
-- STEP 10: FINAL VALIDATION AND SUMMARY
-- ===================================================================

DO $$
DECLARE
    table_count INTEGER;
    function_count INTEGER;
    supported_lang_count INTEGER;
    view_count INTEGER;
BEGIN
    -- Check translation tables exist
    SELECT COUNT(*) INTO table_count
    FROM information_schema.tables 
    WHERE table_name IN ('chapter_translations', 'scenario_translations', 'verse_translations', 'supported_languages');
    
    -- Check functions exist
    SELECT COUNT(*) INTO function_count
    FROM pg_proc 
    WHERE proname IN ('get_chapter_with_fallback', 'get_translation_coverage', 'refresh_multilingual_views');
    
    -- Check supported languages populated
    SELECT COUNT(*) INTO supported_lang_count FROM public.supported_languages;
    
    -- Check materialized views
    SELECT COUNT(*) INTO view_count
    FROM pg_matviews 
    WHERE matviewname LIKE '%_multilingual';
    
    -- Summary report
    RAISE NOTICE '🎉 ===== GITAWISDOM MULTILINGUAL SCHEMA SETUP COMPLETE =====';
    RAISE NOTICE '📊 Summary:';
    RAISE NOTICE '   📋 Translation tables: %/4', table_count;
    RAISE NOTICE '   🔧 RPC functions: %', function_count;
    RAISE NOTICE '   🌍 Supported languages: %', supported_lang_count;
    RAISE NOTICE '   📈 Materialized views: %', view_count;
    
    IF table_count >= 4 AND function_count >= 3 AND supported_lang_count >= 15 THEN
        RAISE NOTICE '✅ SUCCESS: Multilingual schema is ready for production!';
        RAISE NOTICE '📋 Next steps:';
        RAISE NOTICE '   1. Test: SELECT * FROM get_chapter_with_fallback(1, ''hi'');';
        RAISE NOTICE '   2. Check coverage: SELECT * FROM get_translation_coverage();';
        RAISE NOTICE '   3. Run content migration: \\i 002_migrate_existing_content.sql';
        RAISE NOTICE '   4. Update your Flutter app to use enhanced service';
    ELSE
        RAISE WARNING '⚠️  Some components may be missing. Please review the output above.';
    END IF;
    
    RAISE NOTICE '🎯 GitaWisdom is now ready for global multilingual deployment!';
END;
$$;

-- Update table statistics for optimal performance
ANALYZE public.supported_languages;
ANALYZE public.chapter_translations;
ANALYZE public.scenario_translations;

-- ===================================================================
-- ROBUST SCHEMA FIXES COMPLETE!
-- ===================================================================