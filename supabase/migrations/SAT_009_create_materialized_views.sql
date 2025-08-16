-- Create materialized views for better performance
CREATE MATERIALIZED VIEW chapter_summary_multilingual AS
SELECT 
    c.ch_chapter_id,
    sl.lang_code,
    COALESCE(ct.title, c.ch_title) as title,
    COALESCE(ct.subtitle, c.ch_subtitle) as subtitle,
    c.ch_verse_count,
    (SELECT COUNT(*) FROM scenarios s WHERE s.sc_chapter = c.ch_chapter_id) as scenario_count,
    c.created_at
FROM chapters c
CROSS JOIN supported_languages sl
LEFT JOIN chapter_translations ct ON c.ch_chapter_id = ct.chapter_id AND sl.lang_code = ct.lang_code
WHERE sl.is_active = TRUE
ORDER BY c.ch_chapter_id, sl.sort_order;

CREATE UNIQUE INDEX idx_chapter_summary_multilingual_unique 
ON chapter_summary_multilingual(ch_chapter_id, lang_code);

CREATE MATERIALIZED VIEW scenario_summary_multilingual AS
SELECT 
    s.scenario_id,
    s.sc_chapter,
    sl.lang_code,
    COALESCE(st.title, s.sc_title) as title,
    COALESCE(st.description, s.sc_description) as description,
    COALESCE(st.category, s.sc_category) as category,
    s.created_at
FROM scenarios s
CROSS JOIN supported_languages sl
LEFT JOIN scenario_translations st ON s.scenario_id = st.scenario_id AND sl.lang_code = st.lang_code
WHERE sl.is_active = TRUE
ORDER BY s.created_at DESC, sl.sort_order;

CREATE UNIQUE INDEX idx_scenario_summary_multilingual_unique 
ON scenario_summary_multilingual(scenario_id, lang_code);