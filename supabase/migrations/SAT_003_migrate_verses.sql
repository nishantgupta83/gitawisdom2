-- Migrate verses to English translations
INSERT INTO verse_translations (
    verse_id, chapter_id, lang_code, description,
    created_at, updated_at
)
SELECT 
    gv_verses_id,
    gv_chapter_id,
    'en' as lang_code,
    gv_verses,
    NOW(),
    NOW()
FROM gita_verses
WHERE NOT EXISTS (
    SELECT 1 FROM verse_translations 
    WHERE verse_id = gita_verses.gv_verses_id 
    AND chapter_id = gita_verses.gv_chapter_id 
    AND lang_code = 'en'
);

SELECT COUNT(*) as migrated_verses FROM verse_translations WHERE lang_code = 'en';