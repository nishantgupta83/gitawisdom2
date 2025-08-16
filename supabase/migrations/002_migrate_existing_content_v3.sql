-- ===================================================================
-- GitaWisdom Content Migration Script v3 (Column-Safe Version)
-- File: 002_migrate_existing_content_v3.sql
-- Purpose: Migrate existing English content to new multilingual translation tables
-- Author: Claude Code Assistant
-- Date: 2025-08-16
-- Note: Fixed column references that don't exist in source tables
-- ===================================================================

-- ===================================================================
-- DROP EXISTING FUNCTIONS FIRST
-- ===================================================================

-- Drop all existing migration functions to avoid conflicts
DROP FUNCTION IF EXISTS validate_migration_prerequisites();
DROP FUNCTION IF EXISTS validate_migration_success();
DROP FUNCTION IF EXISTS migrate_chapters_to_translations();
DROP FUNCTION IF EXISTS migrate_scenarios_to_translations();
DROP FUNCTION IF EXISTS migrate_verses_to_translations();
DROP FUNCTION IF EXISTS migrate_daily_quotes_to_translations();
DROP FUNCTION IF EXISTS migrate_all_content_to_translations();
DROP FUNCTION IF EXISTS rollback_migration();

-- ===================================================================
-- INSPECT TABLE STRUCTURES
-- ===================================================================

DO $$
BEGIN
    RAISE NOTICE '🔍 Inspecting table structures for migration...';
    
    -- Check chapters table columns
    RAISE NOTICE '📖 Chapters table columns:';
    FOR rec IN 
        SELECT column_name, data_type 
        FROM information_schema.columns 
        WHERE table_name = 'chapters' 
        ORDER BY ordinal_position
    LOOP
        RAISE NOTICE '   - %: %', rec.column_name, rec.data_type;
    END LOOP;
    
    -- Check scenarios table columns
    RAISE NOTICE '🎭 Scenarios table columns:';
    FOR rec IN 
        SELECT column_name, data_type 
        FROM information_schema.columns 
        WHERE table_name = 'scenarios' 
        ORDER BY ordinal_position
    LOOP
        RAISE NOTICE '   - %: %', rec.column_name, rec.data_type;
    END LOOP;
    
    -- Check verses table columns
    RAISE NOTICE '📜 Gita_verses table columns:';
    FOR rec IN 
        SELECT column_name, data_type 
        FROM information_schema.columns 
        WHERE table_name = 'gita_verses' 
        ORDER BY ordinal_position
    LOOP
        RAISE NOTICE '   - %: %', rec.column_name, rec.data_type;
    END LOOP;
END;
$$;

-- ===================================================================
-- BACKUP PROCEDURES
-- ===================================================================

-- Create backup tables before migration
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'backup_chapters') THEN
        CREATE TABLE backup_chapters AS TABLE chapters;
        RAISE NOTICE '✅ Created backup_chapters table';
    ELSE
        RAISE NOTICE '📋 backup_chapters table already exists';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'backup_scenarios') THEN
        CREATE TABLE backup_scenarios AS TABLE scenarios;
        RAISE NOTICE '✅ Created backup_scenarios table';
    ELSE
        RAISE NOTICE '📋 backup_scenarios table already exists';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'backup_gita_verses') THEN
        CREATE TABLE backup_gita_verses AS TABLE gita_verses;
        RAISE NOTICE '✅ Created backup_gita_verses table';
    ELSE
        RAISE NOTICE '📋 backup_gita_verses table already exists';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'daily_quote') THEN
        IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'backup_daily_quote') THEN
            CREATE TABLE backup_daily_quote AS TABLE daily_quote;
            RAISE NOTICE '✅ Created backup_daily_quote table';
        ELSE
            RAISE NOTICE '📋 backup_daily_quote table already exists';
        END IF;
    END IF;
END;
$$;

-- ===================================================================
-- MIGRATION VALIDATION FUNCTIONS
-- ===================================================================

-- Function to validate migration prerequisites
CREATE FUNCTION validate_migration_prerequisites()
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    chapter_count INTEGER;
    scenario_count INTEGER;
    verse_count INTEGER;
    quote_count INTEGER;
    lang_exists BOOLEAN;
BEGIN
    -- Check if English language exists
    SELECT EXISTS(SELECT 1 FROM supported_languages WHERE lang_code = 'en') INTO lang_exists;
    IF NOT lang_exists THEN
        RAISE EXCEPTION 'English language (en) not found in supported_languages table';
    END IF;

    -- Get counts of existing data
    SELECT COUNT(*) INTO chapter_count FROM chapters;
    SELECT COUNT(*) INTO scenario_count FROM scenarios;
    SELECT COUNT(*) INTO verse_count FROM gita_verses;
    
    -- Check daily_quote table existence
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'daily_quote') THEN
        SELECT COUNT(*) INTO quote_count FROM daily_quote;
    ELSE
        quote_count := 0;
    END IF;
    
    RAISE NOTICE '🔍 Migration prerequisites check:';
    RAISE NOTICE '   📖 Chapters: %', chapter_count;
    RAISE NOTICE '   🎭 Scenarios: %', scenario_count;
    RAISE NOTICE '   📜 Verses: %', verse_count;
    RAISE NOTICE '   💬 Daily Quotes: %', quote_count;
    RAISE NOTICE '   🇺🇸 English language support: %', CASE WHEN lang_exists THEN 'YES' ELSE 'NO' END;
    
    RETURN TRUE;
END;
$$;

-- Function to validate migration success
CREATE FUNCTION validate_migration_success()
RETURNS TABLE (
    content_type TEXT,
    original_count INTEGER,
    migrated_count INTEGER,
    success BOOLEAN,
    details TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    chapters_orig INTEGER;
    chapters_migr INTEGER;
    scenarios_orig INTEGER;
    scenarios_migr INTEGER;
    verses_orig INTEGER;
    verses_migr INTEGER;
    quotes_orig INTEGER;
    quotes_migr INTEGER;
BEGIN
    -- Get original counts
    SELECT COUNT(*) INTO chapters_orig FROM chapters;
    SELECT COUNT(*) INTO scenarios_orig FROM scenarios;
    SELECT COUNT(*) INTO verses_orig FROM gita_verses;
    
    -- Check daily_quote table
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'daily_quote') THEN
        SELECT COUNT(*) INTO quotes_orig FROM daily_quote;
    ELSE
        quotes_orig := 0;
    END IF;
    
    -- Get migrated counts (English translations)
    SELECT COUNT(*) INTO chapters_migr FROM chapter_translations WHERE lang_code = 'en';
    SELECT COUNT(*) INTO scenarios_migr FROM scenario_translations WHERE lang_code = 'en';
    SELECT COUNT(*) INTO verses_migr FROM verse_translations WHERE lang_code = 'en';
    
    -- Check daily_quote_translations table
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'daily_quote_translations') THEN
        SELECT COUNT(*) INTO quotes_migr FROM daily_quote_translations WHERE lang_code = 'en';
    ELSE
        quotes_migr := 0;
    END IF;
    
    -- Return validation results
    RETURN QUERY VALUES
        ('chapters', chapters_orig, chapters_migr, chapters_orig = chapters_migr, 
         CASE WHEN chapters_orig = chapters_migr THEN 'Perfect match' 
              ELSE 'Mismatch: ' || (chapters_orig - chapters_migr)::TEXT || ' missing' END),
        ('scenarios', scenarios_orig, scenarios_migr, scenarios_orig = scenarios_migr,
         CASE WHEN scenarios_orig = scenarios_migr THEN 'Perfect match'
              ELSE 'Mismatch: ' || (scenarios_orig - scenarios_migr)::TEXT || ' missing' END),
        ('verses', verses_orig, verses_migr, verses_orig = verses_migr,
         CASE WHEN verses_orig = verses_migr THEN 'Perfect match'
              ELSE 'Mismatch: ' || (verses_orig - verses_migr)::TEXT || ' missing' END),
        ('daily_quotes', quotes_orig, quotes_migr, quotes_orig = quotes_migr,
         CASE WHEN quotes_orig = quotes_migr THEN 'Perfect match'
              ELSE 'Mismatch: ' || (quotes_orig - quotes_migr)::TEXT || ' missing' END);
END;
$$;

-- ===================================================================
-- DIRECT MIGRATION (Fixed Column References)
-- ===================================================================

-- Validate prerequisites before starting
SELECT validate_migration_prerequisites();

-- ===================================================================
-- MIGRATE CHAPTERS (Fixed column references)
-- ===================================================================

DO $$
DECLARE
    total_chapters INTEGER;
    migrated_chapters INTEGER;
    has_created_at BOOLEAN;
    has_updated_at BOOLEAN;
BEGIN
    RAISE NOTICE '📖 Migrating chapters to English translations...';
    
    -- Check if source table has timestamp columns
    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'chapters' AND column_name = 'created_at'
    ) INTO has_created_at;
    
    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'chapters' AND column_name = 'updated_at'
    ) INTO has_updated_at;
    
    RAISE NOTICE '   📋 Chapters table has created_at: %, updated_at: %', has_created_at, has_updated_at;
    
    -- Get total chapter count
    SELECT COUNT(*) INTO total_chapters FROM chapters;
    
    -- Insert chapters as English translations (with conditional timestamp handling)
    IF has_created_at AND has_updated_at THEN
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
            COALESCE(created_at, NOW()),
            COALESCE(updated_at, NOW())
        FROM chapters
        WHERE NOT EXISTS (
            SELECT 1 FROM chapter_translations 
            WHERE chapter_id = chapters.ch_chapter_id AND lang_code = 'en'
        );
    ELSE
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
    END IF;
    
    GET DIAGNOSTICS migrated_chapters = ROW_COUNT;
    
    RAISE NOTICE '✅ Chapters: Migrated % out of % total chapters', migrated_chapters, total_chapters;
END;
$$;

-- ===================================================================
-- MIGRATE SCENARIOS (Fixed column references)
-- ===================================================================

DO $$
DECLARE
    total_scenarios INTEGER;
    migrated_scenarios INTEGER;
    has_created_at BOOLEAN;
    has_updated_at BOOLEAN;
BEGIN
    RAISE NOTICE '🎭 Migrating scenarios to English translations...';
    
    -- Check if source table has timestamp columns
    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'scenarios' AND column_name = 'created_at'
    ) INTO has_created_at;
    
    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'scenarios' AND column_name = 'updated_at'
    ) INTO has_updated_at;
    
    RAISE NOTICE '   📋 Scenarios table has created_at: %, updated_at: %', has_created_at, has_updated_at;
    
    -- Get total scenario count
    SELECT COUNT(*) INTO total_scenarios FROM scenarios;
    
    -- Insert scenarios as English translations (with conditional timestamp handling)
    IF has_created_at AND has_updated_at THEN
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
            COALESCE(created_at, NOW()),
            COALESCE(updated_at, NOW())
        FROM scenarios
        WHERE NOT EXISTS (
            SELECT 1 FROM scenario_translations 
            WHERE scenario_id = scenarios.id AND lang_code = 'en'
        );
    ELSE
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
    END IF;
    
    GET DIAGNOSTICS migrated_scenarios = ROW_COUNT;
    
    RAISE NOTICE '✅ Scenarios: Migrated % out of % total scenarios', migrated_scenarios, total_scenarios;
END;
$$;

-- ===================================================================
-- MIGRATE VERSES (Fixed column references)
-- ===================================================================

DO $$
DECLARE
    total_verses INTEGER;
    migrated_verses INTEGER;
    has_created_at BOOLEAN;
    has_updated_at BOOLEAN;
BEGIN
    RAISE NOTICE '📜 Migrating verses to English translations...';
    
    -- Check if source table has timestamp columns
    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'gita_verses' AND column_name = 'created_at'
    ) INTO has_created_at;
    
    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'gita_verses' AND column_name = 'updated_at'
    ) INTO has_updated_at;
    
    RAISE NOTICE '   📋 Gita_verses table has created_at: %, updated_at: %', has_created_at, has_updated_at;
    
    -- Get total verse count
    SELECT COUNT(*) INTO total_verses FROM gita_verses;
    
    -- Insert verses as English translations (with conditional timestamp handling)
    IF has_created_at AND has_updated_at THEN
        INSERT INTO verse_translations (
            verse_id, chapter_id, lang_code, description,
            created_at, updated_at
        )
        SELECT 
            gv_verses_id,
            gv_chapter_id,
            'en' as lang_code,
            gv_verses,
            COALESCE(created_at, NOW()),
            COALESCE(updated_at, NOW())
        FROM gita_verses
        WHERE NOT EXISTS (
            SELECT 1 FROM verse_translations 
            WHERE verse_id = gita_verses.gv_verses_id 
            AND chapter_id = gita_verses.gv_chapter_id 
            AND lang_code = 'en'
        );
    ELSE
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
    END IF;
    
    GET DIAGNOSTICS migrated_verses = ROW_COUNT;
    
    RAISE NOTICE '✅ Verses: Migrated % out of % total verses', migrated_verses, total_verses;
END;
$$;

-- ===================================================================
-- MIGRATE DAILY QUOTES (if table exists)
-- ===================================================================

DO $$
DECLARE
    total_quotes INTEGER;
    migrated_quotes INTEGER;
    has_created_at BOOLEAN;
    has_updated_at BOOLEAN;
BEGIN
    -- Check if daily_quote table exists
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'daily_quote') THEN
        RAISE NOTICE '💬 Migrating daily quotes to English translations...';
        
        -- Check if source table has timestamp columns
        SELECT EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'daily_quote' AND column_name = 'created_at'
        ) INTO has_created_at;
        
        SELECT EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'daily_quote' AND column_name = 'updated_at'
        ) INTO has_updated_at;
        
        RAISE NOTICE '   📋 Daily_quote table has created_at: %, updated_at: %', has_created_at, has_updated_at;
        
        -- Get total quote count
        SELECT COUNT(*) INTO total_quotes FROM daily_quote;
        
        -- Insert daily quotes as English translations (with conditional timestamp handling)
        IF has_created_at AND has_updated_at THEN
            INSERT INTO daily_quote_translations (
                quote_id, lang_code, description, reference,
                created_at, updated_at
            )
            SELECT 
                dq_id,
                'en' as lang_code,
                dq_description,
                dq_reference,
                COALESCE(created_at, NOW()),
                COALESCE(updated_at, NOW())
            FROM daily_quote
            WHERE NOT EXISTS (
                SELECT 1 FROM daily_quote_translations 
                WHERE quote_id = daily_quote.dq_id AND lang_code = 'en'
            );
        ELSE
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
            WHERE NOT EXISTS (
                SELECT 1 FROM daily_quote_translations 
                WHERE quote_id = daily_quote.dq_id AND lang_code = 'en'
            );
        END IF;
        
        GET DIAGNOSTICS migrated_quotes = ROW_COUNT;
        
        RAISE NOTICE '✅ Daily Quotes: Migrated % out of % total quotes', migrated_quotes, total_quotes;
    ELSE
        RAISE NOTICE '📋 Daily quote table not found - skipping migration';
    END IF;
END;
$$;

-- ===================================================================
-- UPDATE STATISTICS (Safe in transaction)
-- ===================================================================

ANALYZE public.chapter_translations;
ANALYZE public.scenario_translations;
ANALYZE public.verse_translations;

-- Analyze daily_quote_translations if it exists
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'daily_quote_translations') THEN
        ANALYZE public.daily_quote_translations;
    END IF;
END;
$$;

-- ===================================================================
-- VALIDATION AND REPORTING
-- ===================================================================

-- Validate migration results
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '🔍 ===== MIGRATION VALIDATION RESULTS =====';
END;
$$;

SELECT * FROM validate_migration_success();

-- Check translation coverage
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '🌍 ===== TRANSLATION COVERAGE =====';
END;
$$;

SELECT * FROM get_translation_coverage() ORDER BY content_type, coverage_percentage DESC;

-- Test fallback functions
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '🧪 ===== TESTING FALLBACK FUNCTIONS =====';
END;
$$;

-- Test chapter fallback
DO $$
DECLARE
    test_result RECORD;
BEGIN
    SELECT * INTO test_result FROM get_chapter_with_fallback(1, 'en');
    IF test_result IS NOT NULL THEN
        RAISE NOTICE '✅ Chapter fallback test: SUCCESS - Chapter "%" found', test_result.ch_title;
    ELSE
        RAISE NOTICE '❌ Chapter fallback test: FAILED - No chapter found';
    END IF;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '❌ Chapter fallback test: ERROR - %', SQLERRM;
END;
$$;

-- ===================================================================
-- FINAL SUMMARY
-- ===================================================================

DO $$
DECLARE
    validation_results RECORD;
    total_coverage NUMERIC := 0;
    content_types INTEGER := 0;
    all_success BOOLEAN := TRUE;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '🎉 ===== GITAWISDOM CONTENT MIGRATION COMPLETE =====';
    RAISE NOTICE '';
    RAISE NOTICE '📊 Migration Summary:';
    
    FOR validation_results IN 
        SELECT content_type, original_count, migrated_count, success, details
        FROM validate_migration_success()
    LOOP
        RAISE NOTICE '   % | Original: % | Migrated: % | Status: % | %',
            UPPER(validation_results.content_type),
            validation_results.original_count,
            validation_results.migrated_count,
            CASE WHEN validation_results.success THEN '✅ SUCCESS' ELSE '❌ FAILED' END,
            validation_results.details;
            
        all_success := all_success AND validation_results.success;
    END LOOP;
    
    RAISE NOTICE '';
    RAISE NOTICE '🌍 English Translation Coverage:';
    
    FOR validation_results IN 
        SELECT content_type, coverage_percentage 
        FROM get_translation_coverage() 
        WHERE lang_code = 'en'
    LOOP
        RAISE NOTICE '   % | %% coverage',
            UPPER(validation_results.content_type),
            validation_results.coverage_percentage;
        total_coverage := total_coverage + validation_results.coverage_percentage;
        content_types := content_types + 1;
    END LOOP;
    
    IF content_types > 0 THEN
        RAISE NOTICE '';
        RAISE NOTICE '📈 Overall English Coverage: %% (average across % content types)', 
            ROUND(total_coverage / content_types, 2), content_types;
    END IF;
    
    RAISE NOTICE '';
    IF all_success THEN
        RAISE NOTICE '🎯 MIGRATION STATUS: ✅ SUCCESSFUL';
        RAISE NOTICE '';
        RAISE NOTICE '📋 Next Steps:';
        RAISE NOTICE '   1. Run index optimization: \\i 003_optimize_indexes.sql';
        RAISE NOTICE '   2. Test language switching in Flutter app';
        RAISE NOTICE '   3. Add translations for other languages';
        RAISE NOTICE '   4. Monitor performance and usage';
    ELSE
        RAISE NOTICE '🎯 MIGRATION STATUS: ⚠️  COMPLETED WITH ISSUES';
        RAISE NOTICE '📋 Please review the validation results above';
    END IF;
    
    RAISE NOTICE '';
    RAISE NOTICE '🌟 GitaWisdom is now ready for multilingual global deployment!';
END;
$$;

-- ===================================================================
-- CONTENT MIGRATION COMPLETE
-- ===================================================================