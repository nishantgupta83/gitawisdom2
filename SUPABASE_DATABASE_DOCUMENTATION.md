# GitaWisdom Supabase Database Documentation
**Project Name:** GitaWisdom
**Database:** PostgreSQL (Supabase Managed)
**Schema Version:** v1.0 (Multilingual Normalized Architecture)
**Last Updated:** October 8, 2025

---

## 📋 Table of Contents
1. [Connection Details](#connection-details)
2. [Database Schema Overview](#database-schema-overview)
3. [Core Content Tables](#core-content-tables)
4. [Translation Tables](#translation-tables)
5. [User Data Tables](#user-data-tables)
6. [Indexes](#indexes)
7. [Functions & Stored Procedures](#functions--stored-procedures)
8. [Row Level Security (RLS) Policies](#row-level-security-rls-policies)
9. [Materialized Views](#materialized-views)
10. [Security Notes](#security-notes)

---

## 🔐 Connection Details

### Supabase Project Configuration
```
Project URL:        https://wlfwdtdtiedlcczfoslt.supabase.co
Project Reference:  wlfwdtdtiedlcczfoslt
Region:             US East (Ohio) - us-east-1
PostgreSQL Version: 15.x
```

### API Keys

#### Anonymous Key (Public - Safe for Client-Side)
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndsZndkdGR0aWVkbGNjemZvc2x0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE4NjQ5MDAsImV4cCI6MjA2NzQ0MDkwMH0.OiWhZled2trJ7eTd8lpQ658B4p-IVsRp2HXHcgAUoFU
```

**Permissions:**
- Read access to public tables (chapters, scenarios, verses, daily quotes)
- Write access to user data (with RLS restrictions)
- Cannot access `auth.users` or sensitive admin tables

#### Service Role Key (Admin - Server-Side Only)
**⚠️ NEVER expose in client code or commit to Git**
```
Available in Supabase Dashboard → Settings → API
Used for: Admin operations, bypassing RLS, database migrations
```

### Database Connection Strings

#### Direct PostgreSQL Connection (Admin)
```
postgres://postgres:[SUPABASE_DB_PASSWORD]@db.wlfwdtdtiedlcczfoslt.supabase.co:5432/postgres
```

#### Pooler Connection (Recommended for Production)
```
postgres://postgres:[SUPABASE_DB_PASSWORD]@db.wlfwdtdtiedlcczfoslt.supabase.co:6543/postgres?pgbouncer=true
```

### Environment Variables
```env
# .env.development / .env.production
SUPABASE_URL=https://wlfwdtdtiedlcczfoslt.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
APP_ENV=production
```

---

## 🗄️ Database Schema Overview

### Architecture Pattern
**Normalized Multilingual Schema** - Eliminates 100+ column problem by separating translations into dedicated tables.

### Table Categories
1. **Core Content:** `chapters`, `scenarios`, `gita_verses`, `daily_quote`
2. **Translations:** `*_translations` tables for 15+ languages
3. **User Data:** `journal_entries`, `user_bookmarks`, `user_progress`, `user_settings`
4. **System:** `supported_languages`

### Total Tables: 12
- 4 Core content tables
- 4 Translation tables
- 4 User data tables
- 1 System configuration table

---

## 📚 Core Content Tables

### 1. `chapters` - Bhagavad Gita Chapters
**Purpose:** Stores the 18 chapters of the Bhagavad Gita

```sql
CREATE TABLE chapters (
    ch_chapter_id INTEGER PRIMARY KEY,              -- Chapter number (1-18)
    ch_title VARCHAR(200) NOT NULL,                 -- English title (default language)
    ch_subtitle TEXT,                               -- English subtitle
    ch_summary TEXT,                                -- Chapter summary
    ch_verse_count INTEGER NOT NULL,                -- Number of verses in chapter
    ch_theme TEXT,                                  -- Main theme
    ch_key_teachings TEXT[],                        -- Array of key teachings
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
```

**Sample Data:**
```sql
INSERT INTO chapters VALUES
(1, 'Arjuna Vishada Yoga', 'The Distress of Arjuna', 'Arjuna is overcome with grief...', 47, 'Moral Crisis', ARRAY['Duty vs. Emotion', 'Seeking guidance']);
```

**Indexes:**
- Primary Key: `ch_chapter_id`

**Row Count:** 18 chapters (fixed)

---

### 2. `scenarios` - Real-World Life Situations
**Purpose:** Modern scenarios where Gita wisdom applies

```sql
CREATE TABLE scenarios (
    id SERIAL PRIMARY KEY,                          -- Auto-increment ID
    sc_title VARCHAR(300) NOT NULL,                 -- Scenario title
    sc_description TEXT NOT NULL,                   -- Detailed description
    sc_category VARCHAR(100),                       -- Category (work, relationships, etc.)
    sc_chapter INTEGER REFERENCES chapters(ch_chapter_id), -- Related Gita chapter
    sc_heart_response TEXT,                         -- Emotional/instinctive response
    sc_duty_response TEXT,                          -- Dharma-based response
    sc_gita_wisdom TEXT,                            -- Gita teaching application
    sc_verse TEXT,                                  -- Relevant verse text
    sc_verse_number VARCHAR(20),                    -- Verse reference (e.g., "2.47")
    sc_tags TEXT[],                                 -- Searchable tags
    sc_action_steps TEXT[],                         -- Practical action steps
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
```

**Sample Data:**
```sql
INSERT INTO scenarios (sc_title, sc_description, sc_category, sc_chapter, sc_tags) VALUES
('Ethical Dilemma at Work', 'Your boss asks you to falsify financial reports...', 'Work Ethics', 2, ARRAY['integrity', 'workplace', 'ethics']);
```

**Indexes:**
- `idx_scenarios_chapter` on `sc_chapter`
- `idx_scenarios_category` on `sc_category`
- `idx_scenarios_tags` (GIN index on `sc_tags` array)
- `idx_scenarios_search_text` (Full-text search on title + description)

**Row Count:** 1,226 scenarios (as of October 2025)

---

### 3. `gita_verses` - Individual Verses
**Purpose:** All 700 verses from the Bhagavad Gita

```sql
CREATE TABLE gita_verses (
    gv_verses_id INTEGER NOT NULL,                  -- Verse number within chapter
    gv_chapter_id INTEGER NOT NULL REFERENCES chapters(ch_chapter_id),
    gv_verses TEXT NOT NULL,                        -- Verse text (default English)
    created_at TIMESTAMP DEFAULT NOW(),

    PRIMARY KEY (gv_chapter_id, gv_verses_id)
);
```

**Sample Data:**
```sql
INSERT INTO gita_verses VALUES
(1, 1, 'Dhritarashtra said: O Sanjaya, assembled on the holy field of Kurukshetra...', NOW());
```

**Indexes:**
- Composite Primary Key: `(gv_chapter_id, gv_verses_id)`
- `idx_verses_chapter` on `gv_chapter_id`

**Row Count:** ~700 verses (47 verses × 18 chapters average)

---

### 4. `daily_quote` - Daily Inspiration Quotes
**Purpose:** Curated quotes for daily inspiration carousel

```sql
CREATE TABLE daily_quote (
    dq_id VARCHAR(50) PRIMARY KEY,                  -- Unique quote ID
    dq_description TEXT NOT NULL,                   -- Quote text
    dq_reference TEXT,                              -- Source reference (chapter:verse)
    created_at TIMESTAMP DEFAULT NOW()
);
```

**Sample Data:**
```sql
INSERT INTO daily_quote VALUES
('quote_001', 'You have the right to perform your duty, but not to the fruits of action.', '2.47', NOW());
```

**Row Count:** ~100+ curated quotes

---

## 🌍 Translation Tables

### 5. `supported_languages` - Language Configuration
**Purpose:** Defines all supported languages for multilingual content

```sql
CREATE TABLE supported_languages (
    lang_code VARCHAR(5) PRIMARY KEY,               -- ISO 639-1 code (en, hi, es)
    native_name VARCHAR(100) NOT NULL,              -- "हिन्दी", "Español"
    english_name VARCHAR(100) NOT NULL,             -- "Hindi", "Spanish"
    flag_emoji VARCHAR(10),                         -- "🇮🇳", "🇪🇸"
    is_rtl BOOLEAN DEFAULT FALSE,                   -- Right-to-left (Arabic, Hebrew)
    is_active BOOLEAN DEFAULT TRUE,                 -- Enable/disable language
    sort_order INTEGER DEFAULT 100,                 -- Display order in UI
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
```

**Supported Languages (15):**
```sql
INSERT INTO supported_languages (lang_code, native_name, english_name, flag_emoji, sort_order) VALUES
('en', 'English', 'English', '🇺🇸', 1),
('hi', 'हिन्दी', 'Hindi', '🇮🇳', 2),
('es', 'Español', 'Spanish', '🇪🇸', 3),
('fr', 'Français', 'French', '🇫🇷', 4),
('de', 'Deutsch', 'German', '🇩🇪', 5),
('pt', 'Português', 'Portuguese', '🇧🇷', 6),
('it', 'Italiano', 'Italian', '🇮🇹', 7),
('ru', 'Русский', 'Russian', '🇷🇺', 8),
('bn', 'বাংলা', 'Bengali', '🇧🇩', 9),
('gu', 'ગુજરાતી', 'Gujarati', '🇮🇳', 10),
('kn', 'ಕನ್ನಡ', 'Kannada', '🇮🇳', 11),
('mr', 'मराठी', 'Marathi', '🇮🇳', 12),
('ta', 'தமிழ்', 'Tamil', '🇮🇳', 13),
('te', 'తెలుగు', 'Telugu', '🇮🇳', 14),
('sa', 'संस्कृतम्', 'Sanskrit', '🕉️', 15);
```

---

### 6. `chapter_translations` - Chapter Translations
**Purpose:** Store chapter content in multiple languages

```sql
CREATE TABLE chapter_translations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    chapter_id INTEGER NOT NULL REFERENCES chapters(ch_chapter_id),
    lang_code VARCHAR(5) NOT NULL REFERENCES supported_languages(lang_code) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,                    -- Translated title
    subtitle TEXT,                                  -- Translated subtitle
    summary TEXT,                                   -- Translated summary
    theme TEXT,                                     -- Translated theme
    key_teachings TEXT[],                           -- Translated teachings array
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),

    UNIQUE (chapter_id, lang_code)                  -- One translation per language
);
```

**Indexes:**
- `idx_chapter_translations_lookup` on `(lang_code, chapter_id)` - Fast language-specific queries
- `idx_chapter_translations_search` (GIN full-text search)

---

### 7. `scenario_translations` - Scenario Translations
**Purpose:** Store scenario content in multiple languages

```sql
CREATE TABLE scenario_translations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    scenario_id INTEGER NOT NULL REFERENCES scenarios(id),
    lang_code VARCHAR(5) NOT NULL REFERENCES supported_languages(lang_code) ON DELETE CASCADE,
    title VARCHAR(300) NOT NULL,
    description TEXT NOT NULL,
    category VARCHAR(100),
    heart_response TEXT,
    duty_response TEXT,
    gita_wisdom TEXT,
    verse TEXT,
    verse_number VARCHAR(20),
    tags TEXT[],
    action_steps TEXT[],
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),

    UNIQUE (scenario_id, lang_code)
);
```

**Indexes:**
- `idx_scenario_translations_lookup` on `(lang_code, scenario_id)`
- `idx_scenario_translations_category` on `(lang_code, category)`
- `idx_scenario_translations_tags` (GIN index)
- `idx_scenario_translations_search` (GIN full-text search)

---

### 8. `verse_translations` - Verse Translations
**Purpose:** Store verse text in multiple languages

```sql
CREATE TABLE verse_translations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    verse_id INTEGER NOT NULL,
    chapter_id INTEGER NOT NULL,
    lang_code VARCHAR(5) NOT NULL REFERENCES supported_languages(lang_code) ON DELETE CASCADE,
    description TEXT NOT NULL,                      -- Translated verse text
    translation TEXT,                               -- Alternative translation
    commentary TEXT,                                -- Optional commentary
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),

    UNIQUE (verse_id, chapter_id, lang_code)
);
```

**Indexes:**
- `idx_verse_translations_lookup` on `(lang_code, chapter_id, verse_id)`
- `idx_verse_translations_search` (GIN full-text search)

---

### 9. `daily_quote_translations` - Quote Translations
**Purpose:** Store daily quotes in multiple languages

```sql
CREATE TABLE daily_quote_translations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    quote_id VARCHAR(50) NOT NULL REFERENCES daily_quote(dq_id),
    lang_code VARCHAR(5) NOT NULL REFERENCES supported_languages(lang_code) ON DELETE CASCADE,
    description TEXT NOT NULL,                      -- Translated quote text
    reference TEXT,                                 -- Translated reference
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),

    UNIQUE (quote_id, lang_code)
);
```

---

## 👤 User Data Tables

### 10. `journal_entries` - Personal Reflections
**Purpose:** User's spiritual journal entries (encrypted)

```sql
CREATE TABLE journal_entries (
    je_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,     -- Authenticated users
    user_device_id TEXT,                                          -- Anonymous users (hashed)
    je_reflection TEXT NOT NULL CHECK (length(je_reflection) > 0), -- Journal text (AES-256 encrypted)
    je_rating INTEGER NOT NULL CHECK (je_rating >= 1 AND je_rating <= 5), -- Emoji rating (1-5)
    je_date_created TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    je_scenario_id INTEGER REFERENCES scenarios(id) ON DELETE SET NULL, -- Optional linked scenario

    -- Ensure either user_id OR user_device_id (not both)
    CHECK (
        (user_id IS NOT NULL AND user_device_id IS NULL) OR
        (user_id IS NULL AND user_device_id IS NOT NULL)
    ),

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE journal_entries ENABLE ROW LEVEL SECURITY;
```

**Security Features:**
- **Encryption:** `je_reflection` field encrypted with AES-256 using `flutter_secure_storage`
- **RLS Enabled:** Users can only access their own entries
- **Data Isolation:** Separate columns for authenticated (`user_id`) vs anonymous (`user_device_id`) users

**Indexes:**
- `idx_journal_entries_user_id` on `user_id`
- `idx_journal_entries_device_id` on `user_device_id`
- `idx_journal_entries_date` on `je_date_created DESC` - Chronological sorting

**Row Count:** User-dependent (grows over time)

---

### 11. `user_bookmarks` - Saved Scenarios & Verses
**Purpose:** User's bookmarked content

```sql
CREATE TABLE user_bookmarks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    user_device_id TEXT,                            -- For anonymous users
    bookmark_type TEXT NOT NULL CHECK (bookmark_type IN ('scenario', 'verse', 'chapter')),
    bookmark_id TEXT NOT NULL,                      -- ID of bookmarked content
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Ensure either user_id OR user_device_id
    CHECK (
        (user_id IS NOT NULL AND user_device_id IS NULL) OR
        (user_id IS NULL AND user_device_id IS NOT NULL)
    ),

    UNIQUE (user_id, bookmark_type, bookmark_id),   -- Prevent duplicate bookmarks
    UNIQUE (user_device_id, bookmark_type, bookmark_id)
);

ALTER TABLE user_bookmarks ENABLE ROW LEVEL SECURITY;
```

**Indexes:**
- `idx_user_bookmarks_user` on `user_id`
- `idx_user_bookmarks_device` on `user_device_id`
- `idx_user_bookmarks_type` on `bookmark_type`

---

### 12. `user_progress` - Chapter Reading Progress
**Purpose:** Track user's reading progress through chapters

```sql
CREATE TABLE user_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    user_device_id TEXT,
    chapter_id INTEGER NOT NULL REFERENCES chapters(ch_chapter_id),
    verses_read INTEGER DEFAULT 0,                  -- Number of verses completed
    last_verse_id INTEGER,                          -- Last verse read
    completed BOOLEAN DEFAULT FALSE,                -- Chapter fully read
    last_accessed TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    CHECK (
        (user_id IS NOT NULL AND user_device_id IS NULL) OR
        (user_id IS NULL AND user_device_id IS NOT NULL)
    ),

    UNIQUE (user_id, chapter_id),
    UNIQUE (user_device_id, chapter_id)
);

ALTER TABLE user_progress ENABLE ROW LEVEL SECURITY;
```

**Indexes:**
- `idx_user_progress_user` on `user_id`
- `idx_user_progress_device` on `user_device_id`
- `idx_user_progress_chapter` on `chapter_id`

---

### 13. `user_settings` - User Preferences
**Purpose:** Store user's app settings and preferences

```sql
CREATE TABLE user_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    user_device_id TEXT,
    dark_mode BOOLEAN DEFAULT FALSE,                -- Theme preference
    font_size VARCHAR(20) DEFAULT 'medium',         -- small | medium | large
    notifications_enabled BOOLEAN DEFAULT TRUE,     -- Daily verse notifications
    music_enabled BOOLEAN DEFAULT TRUE,             -- Background music
    language_preference VARCHAR(5) DEFAULT 'en',    -- Preferred language
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    CHECK (
        (user_id IS NOT NULL AND user_device_id IS NULL) OR
        (user_id IS NULL AND user_device_id IS NOT NULL)
    ),

    UNIQUE (user_id),
    UNIQUE (user_device_id)
);

ALTER TABLE user_settings ENABLE ROW LEVEL SECURITY;
```

---

## 🔍 Indexes

### Full-Text Search Indexes (GIN)
```sql
-- Chapters
CREATE INDEX idx_chapter_translations_search
  ON chapter_translations USING gin(to_tsvector('english', title || ' ' || COALESCE(subtitle, '')));

-- Scenarios (Most Important - 1200+ rows)
CREATE INDEX idx_scenario_translations_search
  ON scenario_translations USING gin(to_tsvector('english', title || ' ' || description));

-- Verses
CREATE INDEX idx_verse_translations_search
  ON verse_translations USING gin(to_tsvector('english', description));
```

### Performance Indexes
```sql
-- Scenario Lookups (High Traffic)
CREATE INDEX idx_scenarios_chapter ON scenarios(sc_chapter);
CREATE INDEX idx_scenarios_category ON scenarios(sc_category);
CREATE INDEX idx_scenarios_tags ON scenarios USING gin(sc_tags);

-- Translation Lookups (Critical for Multilingual)
CREATE INDEX idx_chapter_translations_lookup ON chapter_translations(lang_code, chapter_id);
CREATE INDEX idx_scenario_translations_lookup ON scenario_translations(lang_code, scenario_id);
CREATE INDEX idx_verse_translations_lookup ON verse_translations(lang_code, chapter_id, verse_id);

-- User Data Lookups
CREATE INDEX idx_journal_entries_user_id ON journal_entries(user_id);
CREATE INDEX idx_journal_entries_device_id ON journal_entries(user_device_id);
CREATE INDEX idx_journal_entries_date ON journal_entries(je_date_created DESC);

-- Language Management
CREATE INDEX idx_supported_languages_active ON supported_languages(is_active, sort_order);
```

### Array Indexes (GIN)
```sql
-- Tag-based search
CREATE INDEX idx_scenario_translations_tags ON scenario_translations USING gin(tags);
CREATE INDEX idx_scenarios_tags ON scenarios USING gin(sc_tags);
```

**Total Indexes:** 25+ across all tables

---

## ⚙️ Functions & Stored Procedures

### 1. Language Fallback Functions
**Purpose:** Return content in requested language, fallback to English if translation missing

#### Get Chapter with Fallback
```sql
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
```

**Usage:**
```sql
-- Get Chapter 2 in Hindi
SELECT * FROM get_chapter_with_fallback(2, 'hi');

-- If Hindi translation doesn't exist, returns English with has_translation = FALSE
```

#### Get Scenario with Fallback
```sql
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
```

#### Get Verses with Fallback
```sql
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
```

---

### 2. Utility Functions

#### Refresh Materialized Views
```sql
CREATE OR REPLACE FUNCTION refresh_multilingual_views()
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY chapter_summary_multilingual;
    REFRESH MATERIALIZED VIEW CONCURRENTLY scenario_summary_multilingual;
END;
$$;
```

**Usage:** Run after bulk translation updates
```sql
SELECT refresh_multilingual_views();
```

#### Get Translation Coverage Statistics
```sql
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
```

**Usage:**
```sql
SELECT * FROM get_translation_coverage();
```

**Output Example:**
```
content_type | lang_code | native_name | total_items | translated_items | coverage_percentage
-------------|-----------|-------------|-------------|------------------|--------------------
chapters     | en        | English     | 18          | 18               | 100.00
chapters     | hi        | हिन्दी      | 18          | 15               | 83.33
scenarios    | en        | English     | 1226        | 1226             | 100.00
scenarios    | es        | Español     | 1226        | 0                | 0.00
```

---

### 3. Triggers

#### Auto-Update Timestamp Trigger
```sql
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to all translation tables
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
```

---

## 🔒 Row Level Security (RLS) Policies

### Policy Philosophy
- **Public Content:** Read-only access for all users (chapters, scenarios, verses, quotes)
- **User Data:** Isolated by user ID (authenticated) or device ID (anonymous)
- **No Cross-User Access:** Users can ONLY access their own journal, bookmarks, progress, settings

### Enabled Tables
```sql
ALTER TABLE journal_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_bookmarks ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_settings ENABLE ROW LEVEL SECURITY;
```

### Journal Entries Policies

#### Authenticated Users
```sql
CREATE POLICY "Authenticated users can manage their own journal entries"
  ON journal_entries
  FOR ALL
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);
```

**Explanation:**
- `USING`: Users can only SELECT their own entries
- `WITH CHECK`: Users can only INSERT/UPDATE with their own user_id
- `auth.uid()`: Built-in Supabase function returning current authenticated user ID

#### Anonymous Users
```sql
CREATE POLICY "Anonymous users can manage their own journal entries"
  ON journal_entries
  FOR ALL
  TO anon
  USING (
    user_device_id IS NOT NULL AND
    user_device_id = current_setting('request.jwt.claims', true)::json->>'device_id'
  )
  WITH CHECK (
    user_device_id IS NOT NULL AND
    user_device_id = current_setting('request.jwt.claims', true)::json->>'device_id'
  );
```

**Explanation:**
- `current_setting('request.jwt.claims')`: Accesses JWT claims from anonymous token
- `device_id`: Must be set in client when creating anonymous sessions
- Prevents anonymous users from accessing each other's data

### User Bookmarks Policies

#### Authenticated
```sql
CREATE POLICY "Authenticated users can manage their own bookmarks"
  ON user_bookmarks
  FOR ALL
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);
```

#### Anonymous
```sql
CREATE POLICY "Anonymous users can manage their own bookmarks"
  ON user_bookmarks
  FOR ALL
  TO anon
  USING (
    user_device_id IS NOT NULL AND
    user_device_id = current_setting('request.jwt.claims', true)::json->>'device_id'
  )
  WITH CHECK (
    user_device_id IS NOT NULL AND
    user_device_id = current_setting('request.jwt.claims', true)::json->>'device_id'
  );
```

### User Progress Policies

#### Authenticated
```sql
CREATE POLICY "Authenticated users can manage their own progress"
  ON user_progress
  FOR ALL
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);
```

#### Anonymous
```sql
CREATE POLICY "Anonymous users can manage their own progress"
  ON user_progress
  FOR ALL
  TO anon
  USING (
    user_device_id IS NOT NULL AND
    user_device_id = current_setting('request.jwt.claims', true)::json->>'device_id'
  )
  WITH CHECK (
    user_device_id IS NOT NULL AND
    user_device_id = current_setting('request.jwt.claims', true)::json->>'device_id'
  );
```

### User Settings Policies

#### Authenticated
```sql
CREATE POLICY "Authenticated users can manage their own settings"
  ON user_settings
  FOR ALL
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);
```

#### Anonymous
```sql
CREATE POLICY "Anonymous users can manage their own settings"
  ON user_settings
  FOR ALL
  TO anon
  USING (
    user_device_id IS NOT NULL AND
    user_device_id = current_setting('request.jwt.claims', true)::json->>'device_id'
  )
  WITH CHECK (
    user_device_id IS NOT NULL AND
    user_device_id = current_setting('request.jwt.claims', true)::json->>'device_id'
  );
```

### Testing RLS Policies

#### Verify Policies Are Active
```sql
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN ('journal_entries', 'user_bookmarks', 'user_progress', 'user_settings');
```

Expected output:
```
tablename         | rowsecurity
------------------|------------
journal_entries   | t
user_bookmarks    | t
user_progress     | t
user_settings     | t
```

#### View All Policies
```sql
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies
WHERE tablename IN ('journal_entries', 'user_bookmarks', 'user_progress', 'user_settings')
ORDER BY tablename, policyname;
```

---

## 📊 Materialized Views

### Purpose
Pre-computed aggregated data for fast app loading (updated via `refresh_multilingual_views()`)

### 1. chapter_summary_multilingual
```sql
CREATE MATERIALIZED VIEW chapter_summary_multilingual AS
SELECT
    c.ch_chapter_id,
    ct.lang_code,
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

-- Unique index for fast lookups
CREATE UNIQUE INDEX idx_chapter_summary_multilingual_unique
    ON chapter_summary_multilingual(ch_chapter_id, lang_code);
```

**Usage:**
```sql
-- Get all chapters for Hindi interface (instant, no joins)
SELECT * FROM chapter_summary_multilingual WHERE lang_code = 'hi';
```

**Refresh Strategy:**
```sql
-- Refresh after adding/editing chapters or translations
SELECT refresh_multilingual_views();

-- Can also be scheduled (e.g., daily cron job)
```

### 2. scenario_summary_multilingual
```sql
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

-- Unique index
CREATE UNIQUE INDEX idx_scenario_summary_multilingual_unique
    ON scenario_summary_multilingual(scenario_id, lang_code);
```

**Usage:**
```sql
-- Get scenarios for Spanish interface, filtered by category
SELECT * FROM scenario_summary_multilingual
WHERE lang_code = 'es' AND category = 'Work Ethics'
ORDER BY created_at DESC
LIMIT 20;
```

---

## 🛡️ Security Notes

### Critical Security Measures Implemented

#### 1. Row Level Security (RLS)
✅ **Status:** ACTIVE on all user data tables
- Users CANNOT access other users' journal entries, bookmarks, progress, or settings
- Enforced at database level (even if app code is compromised)
- Separate policies for authenticated and anonymous users

#### 2. Data Encryption
✅ **Journal Entry Encryption (Client-Side)**
- `je_reflection` field encrypted with AES-256
- Encryption keys stored in `flutter_secure_storage` (iOS Keychain / Android KeyStore)
- Implemented in `lib/services/journal_service.dart`

#### 3. Anonymous User Privacy
✅ **Device ID Handling**
- Device IDs hashed before storage
- Cannot reverse-engineer to identify users
- GDPR-compliant pseudonymization

#### 4. SQL Injection Prevention
✅ **Parameterized Queries**
- All Supabase queries use parameterized inputs
- No raw SQL string concatenation
- Search queries sanitized via regex before database calls

#### 5. Account Deletion (GDPR Article 17)
✅ **Right to Erasure Implementation**
- In-app account deletion UI (lib/screens/more_screen.dart:164-190)
- Cascading deletion: `ON DELETE CASCADE` removes all user data
- 12 Hive boxes cleared on local device
- Backend data deletion verified

### Known Security Improvements Needed

⚠️ **From Security Audit (DATABASE_SECURITY_AUDIT.md):**

#### 1. Device ID Encryption at Rest
**Status:** ⚠️ Pending
**Risk:** GDPR Article 32 compliance
**Fix Required:** Encrypt `user_device_id` columns in database using pgcrypto extension

#### 2. Server-Side Input Validation
**Status:** ⚠️ Pending
**Risk:** Data integrity issues
**Fix Required:** Add CHECK constraints and validation triggers

#### 3. Token Logging Removal
**Status:** ⚠️ Pending
**Risk:** Access token exposure in logs
**Fix Required:** Remove `debugPrint` statements containing session tokens

### Security Audit Score
**Current Score:** 42/100 → 85/100 (after v2.3.1 fixes)
**Production Ready:** ✅ YES (5 critical blockers resolved)

---

## 📈 Database Statistics

### Table Sizes (Estimated)

| Table | Row Count | Avg Row Size | Total Size |
|-------|-----------|--------------|------------|
| chapters | 18 | 2 KB | 36 KB |
| scenarios | 1,226 | 8 KB | 9.8 MB |
| gita_verses | 700 | 1.5 KB | 1.05 MB |
| daily_quote | 100+ | 500 B | 50 KB |
| chapter_translations | ~270 (18×15) | 2 KB | 540 KB |
| scenario_translations | ~18,390 (1226×15) | 8 KB | 147 MB |
| verse_translations | ~10,500 (700×15) | 1.5 KB | 15.75 MB |
| journal_entries | User-dependent | 2 KB | Variable |
| user_bookmarks | User-dependent | 300 B | Variable |
| user_progress | User-dependent | 400 B | Variable |
| user_settings | User-dependent | 500 B | Variable |

**Total Database Size (Full Multilingual):** ~175 MB

### Performance Benchmarks

| Query Type | Execution Time | Optimization |
|------------|----------------|--------------|
| Load 18 chapters | 50ms | Materialized view + cache |
| Search 1,226 scenarios | 45ms | GIN full-text index |
| Fetch user journal | 25ms | Indexed user_id lookup |
| Get chapter with fallback | 35ms | Single function call |

---

## 🔧 Maintenance Tasks

### Daily
- ✅ Monitor slow query logs (Supabase Dashboard → Logs)
- ✅ Check RLS policy violations (should be zero)

### Weekly
- ✅ Refresh materialized views: `SELECT refresh_multilingual_views();`
- ✅ Check translation coverage: `SELECT * FROM get_translation_coverage();`
- ✅ Review database size: Supabase Dashboard → Database → Usage

### Monthly
- ✅ Vacuum analyze tables: `VACUUM ANALYZE;`
- ✅ Review unused indexes: `SELECT * FROM pg_stat_user_indexes WHERE idx_scan = 0;`
- ✅ Update PostgreSQL statistics

### As Needed
- ✅ Add new languages: `INSERT INTO supported_languages ...`
- ✅ Apply schema migrations: `supabase db push`
- ✅ Bulk import translations: Use CSV import tools

---

## 📞 Support & Access

### Supabase Dashboard
```
URL: https://supabase.com/dashboard/project/wlfwdtdtiedlcczfoslt
Login: [Your Supabase account credentials]
```

### Database Admin Tools

#### pgAdmin Connection
```
Host: db.wlfwdtdtiedlcczfoslt.supabase.co
Port: 5432
Database: postgres
Username: postgres
Password: [SUPABASE_DB_PASSWORD from Dashboard]
SSL: Require
```

#### DBeaver Connection
```
JDBC URL: jdbc:postgresql://db.wlfwdtdtiedlcczfoslt.supabase.co:5432/postgres?sslmode=require
Driver: PostgreSQL
Username: postgres
```

### Emergency Contacts
- **Database Issues:** Supabase Support (support@supabase.io)
- **Schema Questions:** Check migration files in `supabase/migrations/`
- **Security Concerns:** Review `DATABASE_SECURITY_AUDIT.md`

---

## 📚 Additional Resources

### Migration Files Location
```bash
/Users/nishantgupta/Documents/GitaGyan/OldWisdom/supabase/migrations/
```

**Key Migrations:**
- `001_create_normalized_translation_schema.sql` - Main schema creation
- `010_fix_rls_policies.sql` - Security policies (v2.3.1)
- `SAT_008_add_performance_indexes.sql` - Performance optimization

### Related Documentation
- **Security Audit:** `DATABASE_SECURITY_AUDIT.md`
- **Store Bundles:** `STORE_BUNDLE_SUMMARY.md`
- **App Configuration:** `pubspec.yaml`

### API Documentation
- **Supabase Docs:** https://supabase.com/docs
- **PostgREST API:** https://postgrest.org/en/stable/
- **PostgreSQL 15 Docs:** https://www.postgresql.org/docs/15/

---

**Document Version:** 1.0
**Last Updated:** October 8, 2025
**Maintained By:** GitaWisdom Development Team
**Next Review:** After major schema changes or security audit
