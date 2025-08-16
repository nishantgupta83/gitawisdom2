-- Add missing unique constraints on translation tables
ALTER TABLE chapter_translations 
ADD CONSTRAINT uq_chapter_translations_lang 
UNIQUE (chapter_id, lang_code);

ALTER TABLE scenario_translations 
ADD CONSTRAINT uq_scenario_translations_lang 
UNIQUE (scenario_id, lang_code);

ALTER TABLE verse_translations 
ADD CONSTRAINT uq_verse_translations_lang 
UNIQUE (verse_id, chapter_id, lang_code);

ALTER TABLE daily_quote_translations 
ADD CONSTRAINT uq_daily_quote_translations_lang 
UNIQUE (quote_id, lang_code);

-- Add foreign key for chapter_translations
ALTER TABLE chapter_translations 
ADD CONSTRAINT fk_chapter_translations_chapter 
FOREIGN KEY (chapter_id) REFERENCES chapters(ch_chapter_id);

-- Add foreign key for scenario_translations
ALTER TABLE scenario_translations 
ADD CONSTRAINT fk_scenario_translations_scenario 
FOREIGN KEY (scenario_id) REFERENCES scenarios(scenario_id);

-- Add foreign key for verse_translations
ALTER TABLE verse_translations 
ADD CONSTRAINT fk_verse_translations_verse 
FOREIGN KEY (verse_id, chapter_id) REFERENCES gita_verses(gv_verses_id, gv_chapter_id);

-- Add foreign key for daily_quote_translations
ALTER TABLE daily_quote_translations 
ADD CONSTRAINT fk_daily_quote_translations_quote 
FOREIGN KEY (quote_id) REFERENCES daily_quote(dq_id);