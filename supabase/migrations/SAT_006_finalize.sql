-- Update statistics
ANALYZE public.chapter_translations;
ANALYZE public.scenario_translations;
ANALYZE public.verse_translations;
ANALYZE public.daily_quote_translations;

-- Refresh materialized views if they exist
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_matviews WHERE matviewname = 'chapter_summary_multilingual') THEN
        REFRESH MATERIALIZED VIEW public.chapter_summary_multilingual;
    END IF;
    
    IF EXISTS (SELECT 1 FROM pg_matviews WHERE matviewname = 'scenario_summary_multilingual') THEN
        REFRESH MATERIALIZED VIEW public.scenario_summary_multilingual;
    END IF;
END;
$$;

-- Final summary
DO $$
DECLARE
    ch_count INTEGER;
    sc_count INTEGER;
    v_count INTEGER;
    q_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO ch_count FROM chapter_translations WHERE lang_code = 'en';
    SELECT COUNT(*) INTO sc_count FROM scenario_translations WHERE lang_code = 'en';
    SELECT COUNT(*) INTO v_count FROM verse_translations WHERE lang_code = 'en';
    SELECT COUNT(*) INTO q_count FROM daily_quote_translations WHERE lang_code = 'en';
    
    RAISE NOTICE '🎉 Migration Complete!';
    RAISE NOTICE '📖 Chapters: %', ch_count;
    RAISE NOTICE '🎭 Scenarios: %', sc_count;
    RAISE NOTICE '📜 Verses: %', v_count;
    RAISE NOTICE '💬 Quotes: %', q_count;
END;
$$;