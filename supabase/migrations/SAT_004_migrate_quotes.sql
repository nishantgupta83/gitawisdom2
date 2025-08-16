-- Migrate daily quotes to English translations
INSERT INTO daily_quote_translations (
    quote_id, lang_code, description, reference,
    created_at, updated_at
)
SELECT 
    dq_id,
    'en' as lang_code,
    dq_description,
    dq_reference,
    COALESCE(created_at, NOW()),
    NOW()
FROM daily_quote
WHERE NOT EXISTS (
    SELECT 1 FROM daily_quote_translations 
    WHERE quote_id = daily_quote.dq_id AND lang_code = 'en'
);

SELECT COUNT(*) as migrated_quotes FROM daily_quote_translations WHERE lang_code = 'en';