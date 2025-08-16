-- ===================================================================
-- GitaWisdom Content Migration Script (Fixed Version)
-- File: 002_migrate_existing_content_fixed.sql
-- Purpose: Migrate existing English content to new multilingual translation tables
-- Author: Claude Code Assistant
-- Date: 2025-08-16
-- Note: Fixed REINDEX issue that prevents running inside transaction
-- ===================================================================

-- ===================================================================
-- BACKUP PROCEDURES
-- ===================================================================

-- Create backup tables before migration
CREATE TABLE IF NOT EXISTS backup_chapters AS TABLE chapters;
CREATE TABLE IF NOT EXISTS backup_scenarios AS TABLE scenarios;
CREATE TABLE IF NOT EXISTS backup_gita_verses AS TABLE gita_verses;
CREATE TABLE IF NOT EXISTS backup_daily_quote AS TABLE daily_quote;

-- ===================================================================
-- MIGRATION VALIDATION FUNCTIONS
-- ===================================================================

-- Function to validate migration prerequisites
CREATE OR REPLACE FUNCTION validate_migration_prerequisites()
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
    SELECT COUNT(*) INTO quote_count FROM daily_quote;
    
    RAISE NOTICE 'Migration prerequisites check:';
    RAISE NOTICE '- Chapters: %', chapter_count;
    RAISE NOTICE '- Scenarios: %', scenario_count;
    RAISE NOTICE '- Verses: %', verse_count;
    RAISE NOTICE '- Daily Quotes: %', quote_count;
    RAISE NOTICE '- English language support: %', CASE WHEN lang_exists THEN 'YES' ELSE 'NO' END;
    
    RETURN TRUE;
END;
$$;

-- Function to validate migration success
CREATE OR REPLACE FUNCTION validate_migration_success()
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
    SELECT COUNT(*) INTO quotes_orig FROM daily_quote;
    
    -- Get migrated counts (English translations)
    SELECT COUNT(*) INTO chapters_migr FROM chapter_translations WHERE lang_code = 'en';
    SELECT COUNT(*) INTO scenarios_migr FROM scenario_translations WHERE lang_code = 'en';
    SELECT COUNT(*) INTO verses_migr FROM verse_translations WHERE lang_code = 'en';
    SELECT COUNT(*) INTO quotes_migr FROM daily_quote_translations WHERE lang_code = 'en';
    
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
-- CONTENT MIGRATION PROCEDURES
-- ===================================================================

-- Function to migrate chapters to English translations
CREATE OR REPLACE FUNCTION migrate_chapters_to_translations()
RETURNS TABLE (migrated_count INTEGER, success BOOLEAN, message TEXT)
LANGUAGE plpgsql
AS $$
DECLARE
    total_chapters INTEGER;
    migrated_chapters INTEGER;
BEGIN
    -- Get total chapter count
    SELECT COUNT(*) INTO total_chapters FROM chapters;
    
    -- Insert chapters as English translations
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
    
    GET DIAGNOSTICS migrated_chapters = ROW_COUNT;
    
    RETURN QUERY SELECT 
        migrated_chapters,
        migrated_chapters > 0,
        'Migrated ' || migrated_chapters || ' chapters out of ' || total_chapters || ' total chapters';
END;
$$;

-- Function to migrate scenarios to English translations
CREATE OR REPLACE FUNCTION migrate_scenarios_to_translations()
RETURNS TABLE (migrated_count INTEGER, success BOOLEAN, message TEXT)
LANGUAGE plpgsql
AS $$
DECLARE
    total_scenarios INTEGER;
    migrated_scenarios INTEGER;
BEGIN
    -- Get total scenario count
    SELECT COUNT(*) INTO total_scenarios FROM scenarios;
    
    -- Insert scenarios as English translations
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
    
    GET DIAGNOSTICS migrated_scenarios = ROW_COUNT;
    
    RETURN QUERY SELECT 
        migrated_scenarios,
        migrated_scenarios > 0,
        'Migrated ' || migrated_scenarios || ' scenarios out of ' || total_scenarios || ' total scenarios';
END;
$$;

-- Function to migrate verses to English translations
CREATE OR REPLACE FUNCTION migrate_verses_to_translations()
RETURNS TABLE (migrated_count INTEGER, success BOOLEAN, message TEXT)
LANGUAGE plpgsql
AS $$
DECLARE
    total_verses INTEGER;
    migrated_verses INTEGER;
BEGIN
    -- Get total verse count
    SELECT COUNT(*) INTO total_verses FROM gita_verses;
    
    -- Insert verses as English translations
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
    
    GET DIAGNOSTICS migrated_verses = ROW_COUNT;
    
    RETURN QUERY SELECT 
        migrated_verses,
        migrated_verses > 0,
        'Migrated ' || migrated_verses || ' verses out of ' || total_verses || ' total verses';
END;
$$;

-- Function to migrate daily quotes to English translations
CREATE OR REPLACE FUNCTION migrate_daily_quotes_to_translations()
RETURNS TABLE (migrated_count INTEGER, success BOOLEAN, message TEXT)
LANGUAGE plpgsql
AS $$
DECLARE
    total_quotes INTEGER;
    migrated_quotes INTEGER;
BEGIN
    -- Get total quote count
    SELECT COUNT(*) INTO total_quotes FROM daily_quote;
    
    -- Insert daily quotes as English translations
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
    
    GET DIAGNOSTICS migrated_quotes = ROW_COUNT;
    
    RETURN QUERY SELECT 
        migrated_quotes,
        migrated_quotes > 0,
        'Migrated ' || migrated_quotes || ' quotes out of ' || total_quotes || ' total quotes';
END;
$$;

-- Master migration function
CREATE OR REPLACE FUNCTION migrate_all_content_to_translations()
RETURNS TABLE (content_type TEXT, migrated_count INTEGER, success BOOLEAN, message TEXT)
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE NOTICE '🚀 Starting migration of all content to translation tables...';
    
    -- Validate prerequisites
    PERFORM validate_migration_prerequisites();
    
    -- Migrate each content type
    RETURN QUERY SELECT 'chapters' as content_type, * FROM migrate_chapters_to_translations();
    RETURN QUERY SELECT 'scenarios' as content_type, * FROM migrate_scenarios_to_translations();
    RETURN QUERY SELECT 'verses' as content_type, * FROM migrate_verses_to_translations();
    RETURN QUERY SELECT 'daily_quotes' as content_type, * FROM migrate_daily_quotes_to_translations();
    
    RAISE NOTICE '✅ Content migration completed!';
END;
$$;

-- ===================================================================
-- ROLLBACK FUNCTIONS
-- ===================================================================

-- Function to rollback migration (if needed)
CREATE OR REPLACE FUNCTION rollback_migration()
RETURNS TEXT
LANGUAGE plpgsql
AS $$
BEGIN
    -- Delete all English translations
    DELETE FROM chapter_translations WHERE lang_code = 'en';
    DELETE FROM scenario_translations WHERE lang_code = 'en';
    DELETE FROM verse_translations WHERE lang_code = 'en';
    DELETE FROM daily_quote_translations WHERE lang_code = 'en';
    
    RETURN 'Migration rolled back - all English translations removed';
END;
$$;

-- ===================================================================
-- EXECUTE MIGRATION
-- ===================================================================

-- Validate prerequisites before starting
SELECT validate_migration_prerequisites();

-- Execute the migration
SELECT * FROM migrate_all_content_to_translations();

-- ===================================================================
-- POST-MIGRATION OPTIMIZATION (Without REINDEX SCHEMA)
-- ===================================================================

-- Update statistics for query planner (this is safe in transaction)
ANALYZE;

-- ===================================================================
-- VALIDATION AND REPORTING
-- ===================================================================

-- Validate migration results
SELECT * FROM validate_migration_success();

-- Check translation coverage
SELECT * FROM get_translation_coverage() ORDER BY content_type, coverage_percentage DESC;

-- Test fallback functions
SELECT * FROM get_chapter_with_fallback(1, 'en');

-- ===================================================================
-- POST-MIGRATION SUMMARY
-- ===================================================================

DO $$
DECLARE
    validation_results RECORD;
    total_coverage NUMERIC := 0;
    content_types INTEGER := 0;
BEGIN
    RAISE NOTICE '🎉 ===== GITAWISDOM CONTENT MIGRATION COMPLETE =====';
    RAISE NOTICE '';
    RAISE NOTICE '📊 Migration Summary:';
    
    FOR validation_results IN 
        SELECT content_type, original_count, migrated_count, success, details
        FROM validate_migration_success()
    LOOP
        RAISE NOTICE '  % | Original: % | Migrated: % | Success: % | %',
            UPPER(validation_results.content_type),
            validation_results.original_count,
            validation_results.migrated_count,
            CASE WHEN validation_results.success THEN '✅' ELSE '❌' END,
            validation_results.details;
    END LOOP;
    
    RAISE NOTICE '';
    RAISE NOTICE '🌍 Translation Coverage for English:';
    
    FOR validation_results IN 
        SELECT content_type, coverage_percentage 
        FROM get_translation_coverage() 
        WHERE lang_code = 'en'
    LOOP
        RAISE NOTICE '  % | %% coverage',
            UPPER(validation_results.content_type),
            validation_results.coverage_percentage;
        total_coverage := total_coverage + validation_results.coverage_percentage;
        content_types := content_types + 1;
    END LOOP;
    
    IF content_types > 0 THEN
        RAISE NOTICE '';
        RAISE NOTICE '📈 Overall English Coverage: %% (avg across % content types)', 
            ROUND(total_coverage / content_types, 2), content_types;
    END IF;
    
    RAISE NOTICE '';
    RAISE NOTICE '📋 Next Steps:';
    RAISE NOTICE '   1. ✅ Run indexes optimization script (outside transaction)';
    RAISE NOTICE '   2. ✅ Test language switching in Flutter app';
    RAISE NOTICE '   3. ✅ Add translations for other languages';
    RAISE NOTICE '   4. ✅ Monitor performance with get_translation_coverage()';
    RAISE NOTICE '';
    RAISE NOTICE '🎯 GitaWisdom multilingual content migration successful!';
END;
$$;

-- ===================================================================
-- MIGRATION COMPLETE
-- ===================================================================