-- Add performance indexes for multilingual queries
CREATE INDEX idx_chapter_translations_lookup 
ON chapter_translations(lang_code, chapter_id);

CREATE INDEX idx_scenario_translations_lookup 
ON scenario_translations(lang_code, scenario_id);

CREATE INDEX idx_verse_translations_lookup 
ON verse_translations(lang_code, chapter_id, verse_id);

CREATE INDEX idx_daily_quote_translations_lookup 
ON daily_quote_translations(lang_code, quote_id);

CREATE INDEX idx_supported_languages_active 
ON supported_languages(is_active, sort_order);

-- Text search indexes (if gin extension available)
CREATE INDEX idx_chapter_translations_search 
ON chapter_translations 
USING gin(to_tsvector('english', title || ' ' || COALESCE(subtitle, '')));

CREATE INDEX idx_scenario_translations_search 
ON scenario_translations 
USING gin(to_tsvector('english', title || ' ' || description));