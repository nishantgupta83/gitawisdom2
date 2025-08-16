-- ===================================================================
-- Fix Function Type Mismatch in get_translation_coverage
-- File: fix_function_type_mismatch.sql
-- Purpose: Fix return type mismatch in get_translation_coverage function
-- Author: Claude Code Assistant
-- Date: 2025-08-16
-- ===================================================================

-- Drop and recreate the function with correct return types
DROP FUNCTION IF EXISTS public.get_translation_coverage();

-- Recreate function with VARCHAR types that match the actual column types
CREATE OR REPLACE FUNCTION public.get_translation_coverage()
RETURNS TABLE (
    content_type TEXT,
    lang_code VARCHAR(5),
    native_name VARCHAR(100),  -- Changed from TEXT to VARCHAR(100) to match column type
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
        'chapters'::TEXT as content_type,
        sl.lang_code,
        sl.native_name,
        (SELECT COUNT(*) FROM public.chapters)::INTEGER as total_items,
        COUNT(ct.id)::INTEGER as translated_items,
        ROUND((COUNT(ct.id)::NUMERIC / NULLIF((SELECT COUNT(*) FROM public.chapters), 0)) * 100, 2) as coverage_percentage
    FROM public.supported_languages sl
    LEFT JOIN public.chapter_translations ct ON sl.lang_code = ct.lang_code
    WHERE sl.is_active = TRUE
    GROUP BY sl.lang_code, sl.native_name, sl.sort_order
    
    UNION ALL
    
    -- Scenario coverage
    SELECT 
        'scenarios'::TEXT as content_type,
        sl.lang_code,
        sl.native_name,
        (SELECT COUNT(*) FROM public.scenarios)::INTEGER as total_items,
        COUNT(st.id)::INTEGER as translated_items,
        ROUND((COUNT(st.id)::NUMERIC / NULLIF((SELECT COUNT(*) FROM public.scenarios), 0)) * 100, 2) as coverage_percentage
    FROM public.supported_languages sl
    LEFT JOIN public.scenario_translations st ON sl.lang_code = st.lang_code
    WHERE sl.is_active = TRUE
    GROUP BY sl.lang_code, sl.native_name, sl.sort_order
    
    UNION ALL
    
    -- Verses coverage
    SELECT 
        'verses'::TEXT as content_type,
        sl.lang_code,
        sl.native_name,
        (SELECT COUNT(*) FROM public.gita_verses)::INTEGER as total_items,
        COUNT(vt.id)::INTEGER as translated_items,
        ROUND((COUNT(vt.id)::NUMERIC / NULLIF((SELECT COUNT(*) FROM public.gita_verses), 0)) * 100, 2) as coverage_percentage
    FROM public.supported_languages sl
    LEFT JOIN public.verse_translations vt ON sl.lang_code = vt.lang_code
    WHERE sl.is_active = TRUE
    GROUP BY sl.lang_code, sl.native_name, sl.sort_order
    
    UNION ALL
    
    -- Daily quotes coverage
    SELECT 
        'daily_quotes'::TEXT as content_type,
        sl.lang_code,
        sl.native_name,
        (SELECT COUNT(*) FROM public.daily_quote)::INTEGER as total_items,
        COUNT(dqt.id)::INTEGER as translated_items,
        ROUND((COUNT(dqt.id)::NUMERIC / NULLIF((SELECT COUNT(*) FROM public.daily_quote), 0)) * 100, 2) as coverage_percentage
    FROM public.supported_languages sl
    LEFT JOIN public.daily_quote_translations dqt ON sl.lang_code = dqt.lang_code
    WHERE sl.is_active = TRUE
    GROUP BY sl.lang_code, sl.native_name, sl.sort_order
    
    ORDER BY content_type, coverage_percentage DESC;
END;
$$;

-- Test the function to make sure it works
DO $$
BEGIN
    RAISE NOTICE '✅ Testing get_translation_coverage function...';
    PERFORM * FROM get_translation_coverage() LIMIT 1;
    RAISE NOTICE '✅ Function works correctly!';
EXCEPTION WHEN OTHERS THEN
    RAISE WARNING '⚠️  Function test failed: %', SQLERRM;
END;
$$;

RAISE NOTICE '🎉 Function type mismatch fixed! You can now continue with the migration.';