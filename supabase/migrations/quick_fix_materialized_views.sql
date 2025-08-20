-- ===================================================================
-- GitaWisdom Quick Fix for Materialized View Dependency Issue
-- File: quick_fix_materialized_views.sql
-- Purpose: Remove materialized views that block column type changes
-- Date: 2025-08-16
-- ===================================================================

-- This is a minimal script to just fix the immediate materialized view issue
-- Run this FIRST, then run your other migration scripts

BEGIN;

DO $$
BEGIN
    RAISE NOTICE '🧹 Removing materialized views that block schema changes...';
END;
$$;

-- ===================================================================
-- AGGRESSIVE VIEW CLEANUP
-- ===================================================================

-- Drop ALL possible materialized views that could reference translation tables
DROP MATERIALIZED VIEW IF EXISTS public.chapter_summary_multilingual CASCADE;
DROP MATERIALIZED VIEW IF EXISTS public.scenario_summary_multilingual CASCADE;
DROP MATERIALIZED VIEW IF EXISTS public.verse_summary_multilingual CASCADE;
DROP MATERIALIZED VIEW IF EXISTS public.daily_quote_summary_multilingual CASCADE;
DROP MATERIALIZED VIEW IF EXISTS public.translation_summary_multilingual CASCADE;

-- Drop any regular views too
DROP VIEW IF EXISTS public.chapter_summary_multilingual CASCADE;
DROP VIEW IF EXISTS public.scenario_summary_multilingual CASCADE;
DROP VIEW IF EXISTS public.verse_summary_multilingual CASCADE;
DROP VIEW IF EXISTS public.daily_quote_summary_multilingual CASCADE;
DROP VIEW IF EXISTS public.translation_summary_multilingual CASCADE;

-- Drop any other views that reference our translation tables
DROP VIEW IF EXISTS public.multilingual_chapter_view CASCADE;
DROP VIEW IF EXISTS public.multilingual_scenario_view CASCADE;
DROP VIEW IF EXISTS public.multilingual_verse_view CASCADE;
DROP VIEW IF EXISTS public.translation_coverage_view CASCADE;

-- Drop views that might reference lang_code columns
DO $$
DECLARE
    view_record RECORD;
BEGIN
    -- Find and drop any views that reference translation tables
    FOR view_record IN 
        SELECT schemaname, viewname 
        FROM pg_views 
        WHERE schemaname = 'public' 
        AND (definition LIKE '%_translations%' OR definition LIKE '%lang_code%')
    LOOP
        EXECUTE 'DROP VIEW IF EXISTS ' || quote_ident(view_record.schemaname) || '.' || quote_ident(view_record.viewname) || ' CASCADE';
        RAISE NOTICE 'Dropped view: %.%', view_record.schemaname, view_record.viewname;
    END LOOP;
    
    -- Find and drop any materialized views that reference translation tables
    FOR view_record IN 
        SELECT schemaname, matviewname as viewname
        FROM pg_matviews 
        WHERE schemaname = 'public' 
        AND (definition LIKE '%_translations%' OR definition LIKE '%lang_code%')
    LOOP
        EXECUTE 'DROP MATERIALIZED VIEW IF EXISTS ' || quote_ident(view_record.schemaname) || '.' || quote_ident(view_record.viewname) || ' CASCADE';
        RAISE NOTICE 'Dropped materialized view: %.%', view_record.schemaname, view_record.viewname;
    END LOOP;
END;
$$;

-- ===================================================================
-- VERIFICATION
-- ===================================================================

DO $$
DECLARE
    remaining_views INTEGER;
BEGIN
    -- Check for any remaining views that might reference our tables
    SELECT COUNT(*) INTO remaining_views
    FROM pg_matviews 
    WHERE schemaname = 'public' 
    AND (definition LIKE '%_translations%' OR definition LIKE '%lang_code%');
    
    IF remaining_views = 0 THEN
        RAISE NOTICE '✅ SUCCESS: All blocking materialized views removed';
        RAISE NOTICE '📋 You can now safely run your schema modification scripts';
        RAISE NOTICE '📋 After modifications, recreate views using the main migration script';
    ELSE
        RAISE WARNING '⚠️  % materialized views may still reference translation tables', remaining_views;
        RAISE NOTICE '📋 You may need to manually identify and drop them';
    END IF;
    
    -- Also check regular views
    SELECT COUNT(*) INTO remaining_views
    FROM pg_views 
    WHERE schemaname = 'public' 
    AND (definition LIKE '%_translations%' OR definition LIKE '%lang_code%');
    
    IF remaining_views > 0 THEN
        RAISE NOTICE '📋 Note: % regular views still reference translation tables (may be OK)', remaining_views;
    END IF;
END;
$$;

COMMIT;

-- ===================================================================
-- QUICK FIX COMPLETE
-- ===================================================================

-- Next steps:
-- 1. Run this script to remove blocking views
-- 2. Run your main schema modification script  
-- 3. Run content migration script
-- 4. Views will be recreated by the main migration script