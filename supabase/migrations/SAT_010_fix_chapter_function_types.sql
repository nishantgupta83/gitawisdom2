-- Fix RPC function return types for chapter fetching
-- The error indicates VARCHAR vs TEXT type mismatch

-- Drop existing functions that have type mismatches
DROP FUNCTION IF EXISTS get_chapter_multilingual(INTEGER, VARCHAR);
DROP FUNCTION IF EXISTS get_chapter_with_fallback(INTEGER, VARCHAR);

-- Recreate with proper return types matching actual column types
CREATE OR REPLACE FUNCTION get_chapter_multilingual(
    p_chapter_id INTEGER,
    p_lang_code TEXT DEFAULT 'en'
)
RETURNS TABLE (
    ch_chapter_id INTEGER,
    ch_title TEXT,
    ch_subtitle TEXT,
    ch_description TEXT,
    ch_verse_count INTEGER,
    ch_image_url TEXT,
    ch_intro TEXT,
    ch_key_concepts TEXT,
    ch_practical_applications TEXT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Try to get translated version first
    RETURN QUERY
    SELECT 
        c.ch_chapter_id,
        COALESCE(ct.title, c.ch_title) as ch_title,
        COALESCE(ct.subtitle, c.ch_subtitle) as ch_subtitle,
        COALESCE(ct.description, c.ch_description) as ch_description,
        c.ch_verse_count,
        c.ch_image_url,
        COALESCE(ct.intro, c.ch_intro) as ch_intro,
        COALESCE(ct.key_concepts, c.ch_key_concepts) as ch_key_concepts,
        COALESCE(ct.practical_applications, c.ch_practical_applications) as ch_practical_applications,
        c.created_at,
        c.updated_at
    FROM chapters c
    LEFT JOIN chapter_translations ct ON c.ch_chapter_id = ct.chapter_id AND ct.lang_code = p_lang_code
    WHERE c.ch_chapter_id = p_chapter_id;
    
    -- If no result found, this will return empty table
    IF NOT FOUND THEN
        RAISE NOTICE 'Chapter % not found for language %', p_chapter_id, p_lang_code;
    END IF;
END;
$$;

-- Create fallback function for English when translation fails
CREATE OR REPLACE FUNCTION get_chapter_english_fallback(
    p_chapter_id INTEGER
)
RETURNS TABLE (
    ch_chapter_id INTEGER,
    ch_title TEXT,
    ch_subtitle TEXT,
    ch_description TEXT,
    ch_verse_count INTEGER,
    ch_image_url TEXT,
    ch_intro TEXT,
    ch_key_concepts TEXT,
    ch_practical_applications TEXT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.ch_chapter_id,
        c.ch_title,
        c.ch_subtitle,
        c.ch_description,
        c.ch_verse_count,
        c.ch_image_url,
        c.ch_intro,
        c.ch_key_concepts,
        c.ch_practical_applications,
        c.created_at,
        c.updated_at
    FROM chapters c
    WHERE c.ch_chapter_id = p_chapter_id;
END;
$$;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION get_chapter_multilingual(INTEGER, TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION get_chapter_english_fallback(INTEGER) TO anon, authenticated;