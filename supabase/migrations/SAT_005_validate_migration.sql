-- Validate migration results
SELECT 
    'chapters' as content_type,
    (SELECT COUNT(*) FROM chapters) as original_count,
    (SELECT COUNT(*) FROM chapter_translations WHERE lang_code = 'en') as migrated_count
UNION ALL
SELECT 
    'scenarios' as content_type,
    (SELECT COUNT(*) FROM scenarios WHERE scenario_id IS NOT NULL) as original_count,
    (SELECT COUNT(*) FROM scenario_translations WHERE lang_code = 'en') as migrated_count
UNION ALL
SELECT 
    'verses' as content_type,
    (SELECT COUNT(*) FROM gita_verses) as original_count,
    (SELECT COUNT(*) FROM verse_translations WHERE lang_code = 'en') as migrated_count
UNION ALL
SELECT 
    'daily_quotes' as content_type,
    (SELECT COUNT(*) FROM daily_quote) as original_count,
    (SELECT COUNT(*) FROM daily_quote_translations WHERE lang_code = 'en') as migrated_count;

-- Test fallback function
SELECT * FROM get_translation_coverage() ORDER BY content_type, coverage_percentage DESC;