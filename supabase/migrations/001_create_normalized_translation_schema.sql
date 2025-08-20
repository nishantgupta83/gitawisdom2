-- ===================================================================
-- GitaWisdom Multilingual Database Schema Migration
-- File: 001_create_normalized_translation_schema.sql
-- Purpose: Create normalized multilingual architecture to eliminate 100+ column problem
-- Date: 2025-08-15
-- ===================================================================

-- Drop existing objects if they exist (for safe re-runs)
DROP VIEW IF EXISTS chapter_summary_multilingual CASCADE;
DROP VIEW IF EXISTS scenario_summary_multilingual CASCADE;
DROP VIEW IF EXISTS verse_summary_multilingual CASCADE;
DROP VIEW IF EXISTS daily_quote_summary_multilingual CASCADE;

DROP TABLE IF EXISTS chapter_translations CASCADE;
DROP TABLE IF EXISTS scenario_translations CASCADE;
DROP TABLE IF EXISTS verse_translations CASCADE;
DROP TABLE IF EXISTS daily_quote_translations CASCADE;
DROP TABLE IF EXISTS supported_languages CASCADE;

-- ===================================================================
-- SUPPORTED LANGUAGES TABLE
-- ===================================================================
CREATE TABLE supported_languages (
    lang_code VARCHAR(5) PRIMARY KEY,  -- ISO 639-1 (en, hi, es) or custom
    native_name VARCHAR(100) NOT NULL, -- "हिन्दी", "Español", "English"
    english_name VARCHAR(100) NOT NULL, -- "Hindi", "Spanish", "English"
    flag_emoji VARCHAR(10),             -- "🇮🇳", "🇪🇸", "🇺🇸"
    is_rtl BOOLEAN DEFAULT FALSE,       -- Right-to-left languages (Arabic, Hebrew)
    is_active BOOLEAN DEFAULT TRUE,     -- Enable/disable languages
    sort_order INTEGER DEFAULT 100,     -- Display order in UI
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Add primary supported languages
INSERT INTO supported_languages (lang_code, native_name, english_name, flag_emoji, is_rtl, sort_order) VALUES
('en', 'English', 'English', '🇺🇸', FALSE, 1),
('hi', 'हिन्दी', 'Hindi', '🇮🇳', FALSE, 2),
('es', 'Español', 'Spanish', '🇪🇸', FALSE, 3),
('fr', 'Français', 'French', '🇫🇷', FALSE, 4),
('de', 'Deutsch', 'German', '🇩🇪', FALSE, 5),
('pt', 'Português', 'Portuguese', '🇧🇷', FALSE, 6),
('it', 'Italiano', 'Italian', '🇮🇹', FALSE, 7),
('ru', 'Русский', 'Russian', '🇷🇺', FALSE, 8),
('bn', 'বাংলা', 'Bengali', '🇧🇩', FALSE, 9),
('gu', 'ગુજરાતી', 'Gujarati', '🇮🇳', FALSE, 10),
('kn', 'ಕನ್ನಡ', 'Kannada', '🇮🇳', FALSE, 11),
('mr', 'मराठी', 'Marathi', '🇮🇳', FALSE, 12),
('ta', 'தமிழ்', 'Tamil', '🇮🇳', FALSE, 13),
('te', 'తెలుగు', 'Telugu', '🇮🇳', FALSE, 14),
('sa', 'संस्कृतम्', 'Sanskrit', '🕉️', FALSE, 15);

-- ===================================================================
-- CHAPTER TRANSLATIONS TABLE
-- ===================================================================
CREATE TABLE chapter_translations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    chapter_id INTEGER NOT NULL,       -- References chapters.ch_chapter_id
    lang_code VARCHAR(5) NOT NULL,     -- References supported_languages.lang_code
    title VARCHAR(200) NOT NULL,
    subtitle TEXT,
    summary TEXT,
    theme TEXT,
    key_teachings TEXT[],              -- Array of key teachings
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT fk_chapter_translations_lang 
        FOREIGN KEY (lang_code) REFERENCES supported_languages(lang_code) ON DELETE CASCADE,
    CONSTRAINT uq_chapter_translations_lang 
        UNIQUE (chapter_id, lang_code)
);

-- ===================================================================
-- SCENARIO TRANSLATIONS TABLE  
-- ===================================================================
CREATE TABLE scenario_translations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    scenario_id INTEGER NOT NULL,      -- References scenarios.id (auto-increment primary key)
    lang_code VARCHAR(5) NOT NULL,     -- References supported_languages.lang_code
    title VARCHAR(300) NOT NULL,
    description TEXT NOT NULL,
    category VARCHAR(100),
    heart_response TEXT,
    duty_response TEXT,
    gita_wisdom TEXT,
    verse TEXT,
    verse_number VARCHAR(20),
    tags TEXT[],                       -- Array of tags
    action_steps TEXT[],               -- Array of action steps
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT fk_scenario_translations_lang 
        FOREIGN KEY (lang_code) REFERENCES supported_languages(lang_code) ON DELETE CASCADE,
    CONSTRAINT uq_scenario_translations_lang 
        UNIQUE (scenario_id, lang_code)
);

-- ===================================================================
-- VERSE TRANSLATIONS TABLE
-- ===================================================================
CREATE TABLE verse_translations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    verse_id INTEGER NOT NULL,         -- References gita_verses.gv_verses_id
    chapter_id INTEGER NOT NULL,       -- References gita_verses.gv_chapter_id
    lang_code VARCHAR(5) NOT NULL,     -- References supported_languages.lang_code
    description TEXT NOT NULL,         -- The verse text
    translation TEXT,                  -- Alternative translation
    commentary TEXT,                   -- Optional commentary
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT fk_verse_translations_lang 
        FOREIGN KEY (lang_code) REFERENCES supported_languages(lang_code) ON DELETE CASCADE,
    CONSTRAINT uq_verse_translations_lang 
        UNIQUE (verse_id, chapter_id, lang_code)
);

-- ===================================================================
-- DAILY QUOTE TRANSLATIONS TABLE
-- ===================================================================
CREATE TABLE daily_quote_translations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    quote_id VARCHAR(50) NOT NULL,     -- References daily_quote.dq_id
    lang_code VARCHAR(5) NOT NULL,     -- References supported_languages.lang_code
    description TEXT NOT NULL,         -- The quote text
    reference TEXT,                    -- Source reference
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT fk_daily_quote_translations_lang 
        FOREIGN KEY (lang_code) REFERENCES supported_languages(lang_code) ON DELETE CASCADE,
    CONSTRAINT uq_daily_quote_translations_lang 
        UNIQUE (quote_id, lang_code)
);

-- ===================================================================
-- PERFORMANCE INDEXES
-- ===================================================================

-- Supported Languages Indexes
CREATE INDEX idx_supported_languages_active ON supported_languages(is_active, sort_order);

-- Chapter Translations Indexes
CREATE INDEX idx_chapter_translations_lookup ON chapter_translations(lang_code, chapter_id);
CREATE INDEX idx_chapter_translations_chapter ON chapter_translations(chapter_id);
CREATE INDEX idx_chapter_translations_lang ON chapter_translations(lang_code);
CREATE INDEX idx_chapter_translations_search ON chapter_translations 
    USING gin(to_tsvector('english', title || ' ' || COALESCE(subtitle, '')));

-- Scenario Translations Indexes
CREATE INDEX idx_scenario_translations_lookup ON scenario_translations(lang_code, scenario_id);
CREATE INDEX idx_scenario_translations_scenario ON scenario_translations(scenario_id);
CREATE INDEX idx_scenario_translations_lang ON scenario_translations(lang_code);
CREATE INDEX idx_scenario_translations_category ON scenario_translations(lang_code, category);
CREATE INDEX idx_scenario_translations_search ON scenario_translations 
    USING gin(to_tsvector('english', title || ' ' || description));
CREATE INDEX idx_scenario_translations_tags ON scenario_translations USING gin(tags);

-- Verse Translations Indexes
CREATE INDEX idx_verse_translations_lookup ON verse_translations(lang_code, chapter_id, verse_id);
CREATE INDEX idx_verse_translations_chapter ON verse_translations(chapter_id, lang_code);
CREATE INDEX idx_verse_translations_verse ON verse_translations(verse_id, lang_code);
CREATE INDEX idx_verse_translations_search ON verse_translations 
    USING gin(to_tsvector('english', description));

-- Daily Quote Translations Indexes
CREATE INDEX idx_daily_quote_translations_lookup ON daily_quote_translations(lang_code, quote_id);
CREATE INDEX idx_daily_quote_translations_quote ON daily_quote_translations(quote_id);
CREATE INDEX idx_daily_quote_translations_lang ON daily_quote_translations(lang_code);

-- ===================================================================
-- MATERIALIZED VIEWS FOR PERFORMANCE
-- ===================================================================

-- Chapter Summary with Multilingual Support
CREATE MATERIALIZED VIEW chapter_summary_multilingual AS
SELECT 
    c.ch_chapter_id,
    ct.lang_code,
    COALESCE(ct.title, c.ch_title) as title,
    COALESCE(ct.subtitle, c.ch_subtitle) as subtitle,
    c.ch_verse_count,
    -- Calculate scenario count from actual scenarios table
    (SELECT COUNT(*) FROM scenarios s WHERE s.sc_chapter = c.ch_chapter_id) as scenario_count,
    c.created_at
FROM chapters c
CROSS JOIN supported_languages sl
LEFT JOIN chapter_translations ct ON c.ch_chapter_id = ct.chapter_id AND sl.lang_code = ct.lang_code
WHERE sl.is_active = TRUE
ORDER BY c.ch_chapter_id, sl.sort_order;

-- Create unique index for materialized view
CREATE UNIQUE INDEX idx_chapter_summary_multilingual_unique 
    ON chapter_summary_multilingual(ch_chapter_id, lang_code);

-- Scenario Summary with Multilingual Support
CREATE MATERIALIZED VIEW scenario_summary_multilingual AS
SELECT 
    s.id as scenario_id,
    s.sc_chapter,
    st.lang_code,
    COALESCE(st.title, s.sc_title) as title,
    COALESCE(st.description, s.sc_description) as description,
    COALESCE(st.category, s.sc_category) as category,
    s.created_at
FROM scenarios s
CROSS JOIN supported_languages sl
LEFT JOIN scenario_translations st ON s.id = st.scenario_id AND sl.lang_code = st.lang_code
WHERE sl.is_active = TRUE
ORDER BY s.created_at DESC, sl.sort_order;

-- Create unique index for scenario materialized view
CREATE UNIQUE INDEX idx_scenario_summary_multilingual_unique 
    ON scenario_summary_multilingual(scenario_id, lang_code);

-- ===================================================================
-- RPC FUNCTIONS FOR FALLBACK LOGIC
-- ===================================================================

-- Function to get chapter with language fallback
CREATE OR REPLACE FUNCTION get_chapter_with_fallback(
    p_chapter_id INTEGER,
    p_lang_code VARCHAR(5) DEFAULT 'en'
)
RETURNS TABLE (
    ch_chapter_id INTEGER,
    ch_title TEXT,
    ch_subtitle TEXT,
    ch_summary TEXT,
    ch_verse_count INTEGER,
    ch_theme TEXT,
    ch_key_teachings TEXT[],
    lang_code VARCHAR(5),
    has_translation BOOLEAN
) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.ch_chapter_id,
        COALESCE(ct.title, c.ch_title) as ch_title,
        COALESCE(ct.subtitle, c.ch_subtitle) as ch_subtitle,
        COALESCE(ct.summary, c.ch_summary) as ch_summary,
        c.ch_verse_count,
        COALESCE(ct.theme, c.ch_theme) as ch_theme,
        COALESCE(ct.key_teachings, c.ch_key_teachings) as ch_key_teachings,
        p_lang_code as lang_code,
        (ct.id IS NOT NULL) as has_translation
    FROM chapters c
    LEFT JOIN chapter_translations ct ON c.ch_chapter_id = ct.chapter_id AND ct.lang_code = p_lang_code
    WHERE c.ch_chapter_id = p_chapter_id;
END;
$$;

-- Function to get scenario with language fallback
CREATE OR REPLACE FUNCTION get_scenario_with_fallback(
    p_scenario_id INTEGER,
    p_lang_code VARCHAR(5) DEFAULT 'en'
)
RETURNS TABLE (
    id INTEGER,
    sc_title TEXT,
    sc_description TEXT,
    sc_category TEXT,
    sc_chapter INTEGER,
    sc_heart_response TEXT,
    sc_duty_response TEXT,
    sc_gita_wisdom TEXT,
    sc_verse TEXT,
    sc_verse_number TEXT,
    sc_tags TEXT[],
    sc_action_steps TEXT[],
    created_at TIMESTAMP,
    lang_code VARCHAR(5),
    has_translation BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        s.id,
        COALESCE(st.title, s.sc_title) as sc_title,
        COALESCE(st.description, s.sc_description) as sc_description,
        COALESCE(st.category, s.sc_category) as sc_category,
        s.sc_chapter,
        COALESCE(st.heart_response, s.sc_heart_response) as sc_heart_response,
        COALESCE(st.duty_response, s.sc_duty_response) as sc_duty_response,
        COALESCE(st.gita_wisdom, s.sc_gita_wisdom) as sc_gita_wisdom,
        COALESCE(st.verse, s.sc_verse) as sc_verse,
        COALESCE(st.verse_number, s.sc_verse_number) as sc_verse_number,
        COALESCE(st.tags, s.sc_tags) as sc_tags,
        COALESCE(st.action_steps, s.sc_action_steps) as sc_action_steps,
        s.created_at,
        p_lang_code as lang_code,
        (st.id IS NOT NULL) as has_translation
    FROM scenarios s
    LEFT JOIN scenario_translations st ON s.id = st.scenario_id AND st.lang_code = p_lang_code
    WHERE s.id = p_scenario_id;
END;
$$;

-- Function to get verses with language fallback
CREATE OR REPLACE FUNCTION get_verses_with_fallback(
    p_chapter_id INTEGER,
    p_lang_code VARCHAR(5) DEFAULT 'en'
)
RETURNS TABLE (
    gv_verses_id INTEGER,
    gv_chapter_id INTEGER,
    gv_verses TEXT,
    lang_code VARCHAR(5),
    has_translation BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        v.gv_verses_id,
        v.gv_chapter_id,
        COALESCE(vt.description, v.gv_verses) as gv_verses,
        p_lang_code as lang_code,
        (vt.id IS NOT NULL) as has_translation
    FROM gita_verses v
    LEFT JOIN verse_translations vt ON v.gv_verses_id = vt.verse_id 
        AND v.gv_chapter_id = vt.chapter_id 
        AND vt.lang_code = p_lang_code
    WHERE v.gv_chapter_id = p_chapter_id
    ORDER BY v.gv_verses_id;
END;
$$;

-- Function to get daily quote with language fallback
CREATE OR REPLACE FUNCTION get_daily_quote_with_fallback(
    p_quote_id VARCHAR(50),
    p_lang_code VARCHAR(5) DEFAULT 'en'
)
RETURNS TABLE (
    dq_id VARCHAR(50),
    dq_description TEXT,
    dq_reference TEXT,
    created_at TIMESTAMP,
    lang_code VARCHAR(5),
    has_translation BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        dq.dq_id,
        COALESCE(dqt.description, dq.dq_description) as dq_description,
        COALESCE(dqt.reference, dq.dq_reference) as dq_reference,
        dq.created_at,
        p_lang_code as lang_code,
        (dqt.id IS NOT NULL) as has_translation
    FROM daily_quote dq
    LEFT JOIN daily_quote_translations dqt ON dq.dq_id = dqt.quote_id AND dqt.lang_code = p_lang_code
    WHERE dq.dq_id = p_quote_id;
END;
$$;

-- ===================================================================
-- UTILITY FUNCTIONS
-- ===================================================================

-- Function to refresh materialized views
CREATE OR REPLACE FUNCTION refresh_multilingual_views()
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY chapter_summary_multilingual;
    REFRESH MATERIALIZED VIEW CONCURRENTLY scenario_summary_multilingual;
END;
$$;

-- Function to get translation coverage statistics
CREATE OR REPLACE FUNCTION get_translation_coverage()
RETURNS TABLE (
    content_type TEXT,
    lang_code VARCHAR(5),
    native_name TEXT,
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
        'chapters' as content_type,
        sl.lang_code,
        sl.native_name,
        (SELECT COUNT(*) FROM chapters) as total_items,
        COUNT(ct.id)::INTEGER as translated_items,
        ROUND((COUNT(ct.id)::NUMERIC / (SELECT COUNT(*) FROM chapters)) * 100, 2) as coverage_percentage
    FROM supported_languages sl
    LEFT JOIN chapter_translations ct ON sl.lang_code = ct.lang_code
    WHERE sl.is_active = TRUE
    GROUP BY sl.lang_code, sl.native_name, sl.sort_order
    
    UNION ALL
    
    -- Scenario coverage
    SELECT 
        'scenarios' as content_type,
        sl.lang_code,
        sl.native_name,
        (SELECT COUNT(*) FROM scenarios) as total_items,
        COUNT(st.id)::INTEGER as translated_items,
        ROUND((COUNT(st.id)::NUMERIC / (SELECT COUNT(*) FROM scenarios)) * 100, 2) as coverage_percentage
    FROM supported_languages sl
    LEFT JOIN scenario_translations st ON sl.lang_code = st.lang_code
    WHERE sl.is_active = TRUE
    GROUP BY sl.lang_code, sl.native_name, sl.sort_order
    
    UNION ALL
    
    -- Verses coverage
    SELECT 
        'verses' as content_type,
        sl.lang_code,
        sl.native_name,
        (SELECT COUNT(*) FROM gita_verses) as total_items,
        COUNT(vt.id)::INTEGER as translated_items,
        ROUND((COUNT(vt.id)::NUMERIC / (SELECT COUNT(*) FROM gita_verses)) * 100, 2) as coverage_percentage
    FROM supported_languages sl
    LEFT JOIN verse_translations vt ON sl.lang_code = vt.lang_code
    WHERE sl.is_active = TRUE
    GROUP BY sl.lang_code, sl.native_name, sl.sort_order
    
    ORDER BY content_type, coverage_percentage DESC;
END;
$$;

-- ===================================================================
-- TRIGGERS FOR AUTOMATIC UPDATES
-- ===================================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add triggers to all translation tables
CREATE TRIGGER tr_chapter_translations_updated_at
    BEFORE UPDATE ON chapter_translations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER tr_scenario_translations_updated_at
    BEFORE UPDATE ON scenario_translations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER tr_verse_translations_updated_at
    BEFORE UPDATE ON verse_translations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER tr_daily_quote_translations_updated_at
    BEFORE UPDATE ON daily_quote_translations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ===================================================================
-- SECURITY & PERMISSIONS
-- ===================================================================

-- Enable Row Level Security (if needed)
-- ALTER TABLE chapter_translations ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE scenario_translations ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE verse_translations ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE daily_quote_translations ENABLE ROW LEVEL SECURITY;

-- Grant permissions for app access
-- GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO anon;
-- GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO authenticated;
-- GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO anon;
-- GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO authenticated;

-- ===================================================================
-- VALIDATION QUERIES
-- ===================================================================

-- Test queries to verify schema creation
DO $$
BEGIN
    -- Test supported languages
    ASSERT (SELECT COUNT(*) FROM supported_languages WHERE is_active = TRUE) >= 10, 
        'Expected at least 10 active languages';
    
    -- Test table creation
    ASSERT (SELECT COUNT(*) FROM information_schema.tables WHERE table_name = 'chapter_translations') = 1,
        'chapter_translations table not created';
    
    -- Test indexes
    ASSERT (SELECT COUNT(*) FROM pg_indexes WHERE tablename = 'chapter_translations') >= 3,
        'Expected at least 3 indexes on chapter_translations';
    
    -- Test functions
    ASSERT (SELECT COUNT(*) FROM pg_proc WHERE proname = 'get_chapter_with_fallback') = 1,
        'get_chapter_with_fallback function not created';
        
    RAISE NOTICE 'Schema validation passed successfully!';
END
$$;

-- ===================================================================
-- SCHEMA CREATION COMPLETE
-- ===================================================================
COMMENT ON SCHEMA public IS 'GitaWisdom multilingual database schema - Production ready v1.0';