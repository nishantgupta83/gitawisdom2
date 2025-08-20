-- ===================================================================
-- GitaWisdom Content Migration Script
-- File: 002_migrate_existing_content.sql
-- Purpose: Migrate existing English content to new multilingual translation tables
-- Date: 2025-08-15
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
        ('quotes', quotes_orig, quotes_migr, quotes_orig = quotes_migr,
         CASE WHEN quotes_orig = quotes_migr THEN 'Perfect match'
              ELSE 'Mismatch: ' || (quotes_orig - quotes_migr)::TEXT || ' missing' END);
END;
$$;

-- ===================================================================
-- MIGRATION FUNCTIONS
-- ===================================================================

-- Function to migrate chapter content
CREATE OR REPLACE FUNCTION migrate_chapters_to_translations()
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    migrated_count INTEGER := 0;
    chapter_record RECORD;
BEGIN
    RAISE NOTICE 'Starting chapter migration to English translations...';
    
    -- Clear existing English chapter translations (for re-runs)
    DELETE FROM chapter_translations WHERE lang_code = 'en';
    
    -- Migrate each chapter
    FOR chapter_record IN 
        SELECT ch_chapter_id, ch_title, ch_subtitle, ch_summary, ch_theme, ch_key_teachings
        FROM chapters 
        ORDER BY ch_chapter_id
    LOOP
        INSERT INTO chapter_translations (
            chapter_id,
            lang_code,
            title,
            subtitle,
            summary,
            theme,
            key_teachings
        ) VALUES (
            chapter_record.ch_chapter_id,
            'en',
            chapter_record.ch_title,
            chapter_record.ch_subtitle,
            chapter_record.ch_summary,
            chapter_record.ch_theme,
            chapter_record.ch_key_teachings
        );
        
        migrated_count := migrated_count + 1;
    END LOOP;
    
    RAISE NOTICE 'Chapter migration complete: % chapters migrated', migrated_count;
    RETURN migrated_count;
END;
$$;

-- Function to migrate scenario content
CREATE OR REPLACE FUNCTION migrate_scenarios_to_translations()
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    migrated_count INTEGER := 0;
    scenario_record RECORD;
BEGIN
    RAISE NOTICE 'Starting scenario migration to English translations...';
    
    -- Clear existing English scenario translations (for re-runs)
    DELETE FROM scenario_translations WHERE lang_code = 'en';
    
    -- Migrate each scenario
    FOR scenario_record IN 
        SELECT id, sc_title, sc_description, sc_category, sc_heart_response, 
               sc_duty_response, sc_gita_wisdom, sc_verse, sc_verse_number, 
               sc_tags, sc_action_steps
        FROM scenarios 
        ORDER BY id
    LOOP
        INSERT INTO scenario_translations (
            scenario_id,
            lang_code,
            title,
            description,
            category,
            heart_response,
            duty_response,
            gita_wisdom,
            verse,
            verse_number,
            tags,
            action_steps
        ) VALUES (
            scenario_record.id,
            'en',
            scenario_record.sc_title,
            scenario_record.sc_description,
            scenario_record.sc_category,
            scenario_record.sc_heart_response,
            scenario_record.sc_duty_response,
            scenario_record.sc_gita_wisdom,
            scenario_record.sc_verse,
            scenario_record.sc_verse_number,
            scenario_record.sc_tags,
            scenario_record.sc_action_steps
        );
        
        migrated_count := migrated_count + 1;
    END LOOP;
    
    RAISE NOTICE 'Scenario migration complete: % scenarios migrated', migrated_count;
    RETURN migrated_count;
END;
$$;

-- Function to migrate verse content
CREATE OR REPLACE FUNCTION migrate_verses_to_translations()
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    migrated_count INTEGER := 0;
    verse_record RECORD;
BEGIN
    RAISE NOTICE 'Starting verse migration to English translations...';
    
    -- Clear existing English verse translations (for re-runs)
    DELETE FROM verse_translations WHERE lang_code = 'en';
    
    -- Migrate each verse
    FOR verse_record IN 
        SELECT gv_verses_id, gv_chapter_id, gv_verses
        FROM gita_verses 
        ORDER BY gv_chapter_id, gv_verses_id
    LOOP
        INSERT INTO verse_translations (
            verse_id,
            chapter_id,
            lang_code,
            description
        ) VALUES (
            verse_record.gv_verses_id,
            verse_record.gv_chapter_id,
            'en',
            verse_record.gv_verses
        );
        
        migrated_count := migrated_count + 1;
    END LOOP;
    
    RAISE NOTICE 'Verse migration complete: % verses migrated', migrated_count;
    RETURN migrated_count;
END;
$$;

-- Function to migrate daily quote content
CREATE OR REPLACE FUNCTION migrate_daily_quotes_to_translations()
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    migrated_count INTEGER := 0;
    quote_record RECORD;
BEGIN
    RAISE NOTICE 'Starting daily quote migration to English translations...';
    
    -- Clear existing English daily quote translations (for re-runs)
    DELETE FROM daily_quote_translations WHERE lang_code = 'en';
    
    -- Migrate each daily quote
    FOR quote_record IN 
        SELECT dq_id, dq_description, dq_reference
        FROM daily_quote 
        ORDER BY created_at
    LOOP
        INSERT INTO daily_quote_translations (
            quote_id,
            lang_code,
            description,
            reference
        ) VALUES (
            quote_record.dq_id,
            'en',
            quote_record.dq_description,
            quote_record.dq_reference
        );
        
        migrated_count := migrated_count + 1;
    END LOOP;
    
    RAISE NOTICE 'Daily quote migration complete: % quotes migrated', migrated_count;
    RETURN migrated_count;
END;
$$;

-- Master migration function
CREATE OR REPLACE FUNCTION migrate_all_content_to_translations()
RETURNS TABLE (
    content_type TEXT,
    migrated_count INTEGER,
    success BOOLEAN,
    message TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    chapters_migrated INTEGER;
    scenarios_migrated INTEGER;
    verses_migrated INTEGER;
    quotes_migrated INTEGER;
    total_operations INTEGER := 0;
    successful_operations INTEGER := 0;
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Starting complete content migration...';
    RAISE NOTICE '========================================';
    
    -- Validate prerequisites
    PERFORM validate_migration_prerequisites();
    
    -- Migrate chapters
    BEGIN
        chapters_migrated := migrate_chapters_to_translations();
        successful_operations := successful_operations + 1;
        total_operations := total_operations + 1;
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Chapter migration failed: %', SQLERRM;
        chapters_migrated := -1;
        total_operations := total_operations + 1;
    END;
    
    -- Migrate scenarios
    BEGIN
        scenarios_migrated := migrate_scenarios_to_translations();
        successful_operations := successful_operations + 1;
        total_operations := total_operations + 1;
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Scenario migration failed: %', SQLERRM;
        scenarios_migrated := -1;
        total_operations := total_operations + 1;
    END;
    
    -- Migrate verses
    BEGIN
        verses_migrated := migrate_verses_to_translations();
        successful_operations := successful_operations + 1;
        total_operations := total_operations + 1;
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Verse migration failed: %', SQLERRM;
        verses_migrated := -1;
        total_operations := total_operations + 1;
    END;
    
    -- Migrate daily quotes
    BEGIN
        quotes_migrated := migrate_daily_quotes_to_translations();
        successful_operations := successful_operations + 1;
        total_operations := total_operations + 1;
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Daily quote migration failed: %', SQLERRM;
        quotes_migrated := -1;
        total_operations := total_operations + 1;
    END;
    
    -- Refresh materialized views
    BEGIN
        PERFORM refresh_multilingual_views();
        RAISE NOTICE 'Materialized views refreshed successfully';
    EXCEPTION WHEN OTHERS THEN
        RAISE WARNING 'Failed to refresh materialized views: %', SQLERRM;
    END;
    
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Migration Summary:';
    RAISE NOTICE '- Successful operations: %/%', successful_operations, total_operations;
    RAISE NOTICE '- Chapters: %', CASE WHEN chapters_migrated >= 0 THEN chapters_migrated::TEXT ELSE 'FAILED' END;
    RAISE NOTICE '- Scenarios: %', CASE WHEN scenarios_migrated >= 0 THEN scenarios_migrated::TEXT ELSE 'FAILED' END;
    RAISE NOTICE '- Verses: %', CASE WHEN verses_migrated >= 0 THEN verses_migrated::TEXT ELSE 'FAILED' END;
    RAISE NOTICE '- Daily Quotes: %', CASE WHEN quotes_migrated >= 0 THEN quotes_migrated::TEXT ELSE 'FAILED' END;
    RAISE NOTICE '========================================';
    
    -- Return summary results
    RETURN QUERY VALUES
        ('chapters', chapters_migrated, chapters_migrated >= 0, 
         CASE WHEN chapters_migrated >= 0 THEN 'Success' ELSE 'Failed' END),
        ('scenarios', scenarios_migrated, scenarios_migrated >= 0,
         CASE WHEN scenarios_migrated >= 0 THEN 'Success' ELSE 'Failed' END),
        ('verses', verses_migrated, verses_migrated >= 0,
         CASE WHEN verses_migrated >= 0 THEN 'Success' ELSE 'Failed' END),
        ('quotes', quotes_migrated, quotes_migrated >= 0,
         CASE WHEN quotes_migrated >= 0 THEN 'Success' ELSE 'Failed' END);
END;
$$;

-- ===================================================================
-- ROLLBACK PROCEDURES
-- ===================================================================

-- Function to rollback migration (restore from backups)
CREATE OR REPLACE FUNCTION rollback_migration()
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    backup_exists BOOLEAN;
BEGIN
    RAISE NOTICE 'Starting migration rollback...';
    
    -- Check if backup tables exist
    SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_name IN ('backup_chapters', 'backup_scenarios', 'backup_gita_verses', 'backup_daily_quote')
    ) INTO backup_exists;
    
    IF NOT backup_exists THEN
        RAISE EXCEPTION 'Backup tables not found. Cannot rollback migration.';
    END IF;
    
    -- Clear translation tables
    TRUNCATE chapter_translations;
    TRUNCATE scenario_translations;
    TRUNCATE verse_translations;
    TRUNCATE daily_quote_translations;
    
    -- Note: We don't restore original tables as they should remain unchanged
    -- This function primarily clears the translation tables
    
    RAISE NOTICE 'Migration rollback completed. Translation tables cleared.';
    RETURN TRUE;
END;
$$;

-- Function to cleanup backup tables
CREATE OR REPLACE FUNCTION cleanup_migration_backups()
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE NOTICE 'Cleaning up migration backup tables...';
    
    DROP TABLE IF EXISTS backup_chapters;
    DROP TABLE IF EXISTS backup_scenarios;
    DROP TABLE IF EXISTS backup_gita_verses;
    DROP TABLE IF EXISTS backup_daily_quote;
    
    RAISE NOTICE 'Backup cleanup completed.';
    RETURN TRUE;
END;
$$;

-- ===================================================================
-- MAIN EXECUTION BLOCK
-- ===================================================================

DO $$
DECLARE
    migration_results RECORD;
    validation_results RECORD;
    all_successful BOOLEAN := TRUE;
BEGIN
    RAISE NOTICE '============================================================';
    RAISE NOTICE 'GitaWisdom Content Migration Script';
    RAISE NOTICE 'Version: 1.0';
    RAISE NOTICE 'Date: 2025-08-15';
    RAISE NOTICE '============================================================';
    
    -- Run the migration
    RAISE NOTICE 'Executing migration...';
    
    FOR migration_results IN 
        SELECT * FROM migrate_all_content_to_translations()
    LOOP
        IF NOT migration_results.success THEN
            all_successful := FALSE;
        END IF;
        RAISE NOTICE 'Migration result: % - % items - %', 
            migration_results.content_type, 
            migration_results.migrated_count,
            migration_results.message;
    END LOOP;
    
    -- Validate migration results
    RAISE NOTICE '';
    RAISE NOTICE 'Validating migration results...';
    
    FOR validation_results IN 
        SELECT * FROM validate_migration_success()
    LOOP
        RAISE NOTICE 'Validation: % - Original: %, Migrated: %, Success: %, Details: %',
            validation_results.content_type,
            validation_results.original_count,
            validation_results.migrated_count,
            validation_results.success,
            validation_results.details;
            
        IF NOT validation_results.success THEN
            all_successful := FALSE;
        END IF;
    END LOOP;
    
    -- Final status
    RAISE NOTICE '';
    RAISE NOTICE '============================================================';
    IF all_successful THEN
        RAISE NOTICE 'MIGRATION COMPLETED SUCCESSFULLY!';
        RAISE NOTICE 'All content has been migrated to translation tables.';
        RAISE NOTICE 'Original tables remain unchanged for backward compatibility.';
    ELSE
        RAISE WARNING 'MIGRATION COMPLETED WITH ERRORS!';
        RAISE NOTICE 'Please check the logs above for details.';
        RAISE NOTICE 'You may need to run specific migration functions manually.';
    END IF;
    RAISE NOTICE '============================================================';
    
    -- Show translation coverage
    RAISE NOTICE '';
    RAISE NOTICE 'Current translation coverage:';
    RAISE NOTICE 'Content Type | Language | Coverage';
    RAISE NOTICE '-------------|----------|----------';
    
    FOR validation_results IN 
        SELECT content_type, native_name, coverage_percentage 
        FROM get_translation_coverage() 
        WHERE lang_code = 'en'
    LOOP
        RAISE NOTICE '% | % | %%%',
            RPAD(validation_results.content_type, 12),
            RPAD(validation_results.native_name, 8),
            validation_results.coverage_percentage;
    END LOOP;
    
END;
$$;

-- ===================================================================
-- POST-MIGRATION SETUP
-- ===================================================================

-- Create indexes on new translation data
REINDEX SCHEMA public;

-- Update statistics for query planner
ANALYZE;

-- Final cleanup (commented out for safety - run manually if needed)
-- SELECT cleanup_migration_backups();

-- ===================================================================
-- MIGRATION SCRIPT COMPLETE
-- ===================================================================

COMMENT ON SCHEMA public IS 'GitaWisdom multilingual database - Content migrated successfully';

-- Helpful queries for monitoring
/*
-- Check migration status
SELECT * FROM validate_migration_success();

-- Check translation coverage
SELECT * FROM get_translation_coverage() ORDER BY content_type, coverage_percentage DESC;

-- Test fallback functions
SELECT * FROM get_chapter_with_fallback(1, 'en');
SELECT * FROM get_scenario_with_fallback(1, 'en');

-- Rollback if needed (CAUTION!)
-- SELECT rollback_migration();

-- Cleanup backups (CAUTION!)
-- SELECT cleanup_migration_backups();
*/