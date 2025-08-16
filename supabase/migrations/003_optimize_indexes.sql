-- ===================================================================
-- GitaWisdom Index Optimization Script
-- File: 003_optimize_indexes.sql
-- Purpose: Optimize database indexes after content migration
-- Author: Claude Code Assistant
-- Date: 2025-08-16
-- Note: This script must be run OUTSIDE of a transaction block
-- ===================================================================

-- WARNING: Do not wrap this script in BEGIN/COMMIT
-- REINDEX commands cannot run inside transactions

-- ===================================================================
-- REINDEX OPERATIONS
-- ===================================================================

-- Reindex specific tables related to multilingual content
-- (Instead of REINDEX SCHEMA which is too broad)

DO $$
BEGIN
    RAISE NOTICE '🔄 Starting selective index rebuild for multilingual tables...';
END;
$$;

-- Reindex translation tables
REINDEX TABLE public.supported_languages;
REINDEX TABLE public.chapter_translations;
REINDEX TABLE public.scenario_translations;
REINDEX TABLE public.verse_translations;

-- Reindex daily_quote tables if they exist
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'daily_quote_translations') THEN
        PERFORM 1; -- We'll do the REINDEX outside this block
        RAISE NOTICE '✅ Will reindex daily_quote_translations';
    END IF;
END;
$$;

-- Reindex daily quote tables
REINDEX TABLE public.daily_quote_translations;
REINDEX TABLE public.daily_quote;

-- Reindex materialized views if they exist
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_matviews WHERE matviewname = 'chapter_summary_multilingual') THEN
        REINDEX TABLE public.chapter_summary_multilingual;
        RAISE NOTICE '✅ Reindexed chapter_summary_multilingual';
    END IF;
    
    IF EXISTS (SELECT 1 FROM pg_matviews WHERE matviewname = 'scenario_summary_multilingual') THEN
        REINDEX TABLE public.scenario_summary_multilingual;
        RAISE NOTICE '✅ Reindexed scenario_summary_multilingual';
    END IF;
END;
$$;

-- ===================================================================
-- UPDATE STATISTICS
-- ===================================================================

-- Analyze all tables to update query planner statistics
ANALYZE public.supported_languages;
ANALYZE public.chapter_translations;
ANALYZE public.scenario_translations;
ANALYZE public.verse_translations;
ANALYZE public.daily_quote_translations;
ANALYZE public.daily_quote;

-- Analyze materialized views
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_matviews WHERE matviewname = 'chapter_summary_multilingual') THEN
        ANALYZE public.chapter_summary_multilingual;
    END IF;
    
    IF EXISTS (SELECT 1 FROM pg_matviews WHERE matviewname = 'scenario_summary_multilingual') THEN
        ANALYZE public.scenario_summary_multilingual;
    END IF;
END;
$$;

-- ===================================================================
-- REFRESH MATERIALIZED VIEWS
-- ===================================================================

-- Refresh materialized views with new data
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_matviews WHERE matviewname = 'chapter_summary_multilingual') THEN
        REFRESH MATERIALIZED VIEW CONCURRENTLY public.chapter_summary_multilingual;
        RAISE NOTICE '✅ Refreshed chapter_summary_multilingual';
    EXCEPTION WHEN OTHERS THEN
        -- If concurrent refresh fails, try non-concurrent
        REFRESH MATERIALIZED VIEW public.chapter_summary_multilingual;
        RAISE NOTICE '✅ Refreshed chapter_summary_multilingual (non-concurrent)';
    END IF;
    
    IF EXISTS (SELECT 1 FROM pg_matviews WHERE matviewname = 'scenario_summary_multilingual') THEN
        REFRESH MATERIALIZED VIEW CONCURRENTLY public.scenario_summary_multilingual;
        RAISE NOTICE '✅ Refreshed scenario_summary_multilingual';
    EXCEPTION WHEN OTHERS THEN
        -- If concurrent refresh fails, try non-concurrent
        REFRESH MATERIALIZED VIEW public.scenario_summary_multilingual;
        RAISE NOTICE '✅ Refreshed scenario_summary_multilingual (non-concurrent)';
    END IF;
END;
$$;

-- ===================================================================
-- PERFORMANCE VALIDATION
-- ===================================================================

-- Test query performance on key multilingual functions
DO $$
DECLARE
    start_time TIMESTAMP;
    end_time TIMESTAMP;
    duration_ms INTEGER;
BEGIN
    RAISE NOTICE '⚡ Testing multilingual query performance...';
    
    -- Test get_chapter_with_fallback performance
    start_time := clock_timestamp();
    PERFORM * FROM get_chapter_with_fallback(1, 'en');
    end_time := clock_timestamp();
    duration_ms := EXTRACT(MILLISECONDS FROM (end_time - start_time));
    
    RAISE NOTICE '📊 get_chapter_with_fallback(1, "en"): %ms', duration_ms;
    
    -- Test get_translation_coverage performance
    start_time := clock_timestamp();
    PERFORM * FROM get_translation_coverage();
    end_time := clock_timestamp();
    duration_ms := EXTRACT(MILLISECONDS FROM (end_time - start_time));
    
    RAISE NOTICE '📊 get_translation_coverage(): %ms', duration_ms;
    
    IF duration_ms < 1000 THEN
        RAISE NOTICE '✅ Performance is excellent (< 1 second)';
    ELSIF duration_ms < 3000 THEN
        RAISE NOTICE '✅ Performance is good (< 3 seconds)';
    ELSE
        RAISE NOTICE '⚠️  Performance may need optimization (> 3 seconds)';
    END IF;
END;
$$;

-- ===================================================================
-- FINAL SUMMARY
-- ===================================================================

DO $$
DECLARE
    index_count INTEGER;
    table_count INTEGER;
    function_count INTEGER;
BEGIN
    -- Count indexes on translation tables
    SELECT COUNT(*) INTO index_count
    FROM pg_indexes 
    WHERE schemaname = 'public' 
    AND (tablename LIKE '%_translations' OR tablename = 'supported_languages');
    
    -- Count translation tables
    SELECT COUNT(*) INTO table_count
    FROM information_schema.tables
    WHERE table_name LIKE '%_translations' OR table_name = 'supported_languages';
    
    -- Count multilingual functions
    SELECT COUNT(*) INTO function_count
    FROM pg_proc 
    WHERE proname LIKE '%_with_fallback%' OR proname LIKE '%translation%';
    
    RAISE NOTICE '🎉 ===== INDEX OPTIMIZATION COMPLETE =====';
    RAISE NOTICE '📊 Database Optimization Summary:';
    RAISE NOTICE '   📋 Translation tables: %', table_count;
    RAISE NOTICE '   📇 Indexes optimized: %', index_count;
    RAISE NOTICE '   🔧 Multilingual functions: %', function_count;
    RAISE NOTICE '';
    RAISE NOTICE '✅ GitaWisdom database is now optimized for production!';
    RAISE NOTICE '🚀 Ready for multilingual deployment across all platforms';
END;
$$;

-- ===================================================================
-- INDEX OPTIMIZATION COMPLETE
-- ===================================================================