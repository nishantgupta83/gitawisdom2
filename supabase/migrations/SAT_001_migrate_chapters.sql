-- Migrate chapters to English translations
INSERT INTO chapter_translations (
    chapter_id, lang_code, title, subtitle, summary, theme, key_teachings,
    created_at, updated_at
)
SELECT 
    ch_chapter_id,
    'en' as lang_code,
    ch_title,
    ch_subtitle,
    ch_summary,
    ch_theme,
    ch_key_teachings,
    COALESCE(created_at, NOW()),
    NOW()
FROM chapters
WHERE NOT EXISTS (
    SELECT 1 FROM chapter_translations 
    WHERE chapter_id = chapters.ch_chapter_id AND lang_code = 'en'
);

SELECT COUNT(*) as migrated_chapters FROM chapter_translations WHERE lang_code = 'en';