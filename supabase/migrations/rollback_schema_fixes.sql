-- ===================================================================
-- GitaWisdom Schema Rollback Script
-- File: rollback_schema_fixes.sql
-- Purpose: Safely rollback multilingual schema changes if needed
-- Author: Claude Code Assistant 
-- Date: 2025-08-16
-- ===================================================================

-- WARNING: This script will remove multilingual functionality
-- Only run this if you need to rollback to the original schema

BEGIN;

DO $$
BEGIN
    RAISE NOTICE '⚠️  Starting rollback of GitaWisdom multilingual schema changes...';
    RAISE NOTICE '⚠️  This will remove translation tables and multilingual functionality!';
END;
$$;

-- ===================================================================
-- STEP 1: DROP MATERIALIZED VIEWS
-- ===================================================================

DROP MATERIALIZED VIEW IF EXISTS public.chapter_summary_multilingual CASCADE;
DROP MATERIALIZED VIEW IF EXISTS public.scenario_summary_multilingual CASCADE;

-- ===================================================================
-- STEP 2: DROP RPC FUNCTIONS
-- ===================================================================

DROP FUNCTION IF EXISTS public.get_chapter_with_fallback(INTEGER, VARCHAR);
DROP FUNCTION IF EXISTS public.get_scenario_with_fallback(INTEGER, VARCHAR);
DROP FUNCTION IF EXISTS public.get_verses_with_fallback(INTEGER, VARCHAR);
DROP FUNCTION IF EXISTS public.get_daily_quote_with_fallback(VARCHAR, VARCHAR);
DROP FUNCTION IF EXISTS public.get_translation_coverage();
DROP FUNCTION IF EXISTS public.refresh_multilingual_views();
DROP FUNCTION IF EXISTS public.update_updated_at();

-- ===================================================================
-- STEP 3: DROP TRANSLATION TABLES
-- ===================================================================

DROP TABLE IF EXISTS public.daily_quote_translations CASCADE;
DROP TABLE IF EXISTS public.verse_translations CASCADE;
DROP TABLE IF EXISTS public.scenario_translations CASCADE;
DROP TABLE IF EXISTS public.chapter_translations CASCADE;

-- ===================================================================
-- STEP 4: DROP SUPPORTING TABLES
-- ===================================================================

DROP TABLE IF EXISTS public.daily_quote CASCADE;
DROP TABLE IF EXISTS public.chapter_summary CASCADE;
DROP TABLE IF EXISTS public.supported_languages CASCADE;

-- ===================================================================
-- STEP 5: DROP ANALYTICS TABLES (if they exist)
-- ===================================================================

DROP TABLE IF EXISTS public.language_usage_analytics CASCADE;
DROP VIEW IF EXISTS public.daily_language_usage CASCADE;
DROP VIEW IF EXISTS public.content_performance_by_language CASCADE;
DROP VIEW IF EXISTS public.translation_coverage_with_usage CASCADE;
DROP VIEW IF EXISTS public.daily_performance_summary CASCADE;
DROP VIEW IF EXISTS public.language_popularity_ranking CASCADE;

-- Drop analytics functions
DROP FUNCTION IF EXISTS public.log_language_usage(VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, INTEGER, BOOLEAN, BOOLEAN);
DROP FUNCTION IF EXISTS public.get_language_performance_insights(VARCHAR, INTEGER);
DROP FUNCTION IF EXISTS public.identify_slow_queries(INTEGER, INTEGER);
DROP FUNCTION IF EXISTS public.cleanup_old_analytics(INTEGER);
DROP FUNCTION IF EXISTS public.refresh_performance_stats();
DROP FUNCTION IF EXISTS public.check_performance_alerts();

-- ===================================================================
-- FINAL VALIDATION
-- ===================================================================

DO $$
DECLARE
    remaining_tables INTEGER;
BEGIN
    -- Check if any multilingual tables remain
    SELECT COUNT(*) INTO remaining_tables
    FROM information_schema.tables
    WHERE table_name LIKE '%_translations' 
       OR table_name IN ('supported_languages', 'language_usage_analytics', 'daily_quote');
    
    IF remaining_tables = 0 THEN
        RAISE NOTICE '✅ Rollback completed successfully - all multilingual components removed';
    ELSE
        RAISE WARNING '⚠️  Some multilingual tables may still exist (%). Manual cleanup may be needed.', remaining_tables;
    END IF;
    
    RAISE NOTICE '📋 Rollback complete. Your database is back to the original schema.';
    RAISE NOTICE '📋 Note: You may need to update your Flutter app to remove multilingual dependencies.';
END;
$$;

COMMIT;

-- ===================================================================
-- ROLLBACK COMPLETE
-- ===================================================================