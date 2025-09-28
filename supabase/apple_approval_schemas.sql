-- GitaWisdom Apple Approval Database Schemas
-- Created to address Apple's minimum functionality rejection
-- Focus: Interactive features, native iOS integration, user engagement

-- =================================================================
-- 1. BOOKMARKED CONTENT TABLE
-- =================================================================
-- Stores user bookmarks for verses, chapters, and scenarios
-- Supports offline sync and iOS widget integration

CREATE TABLE public.user_bookmarks (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_device_id TEXT NOT NULL, -- Device identifier for offline sync
  bookmark_type TEXT NOT NULL CHECK (bookmark_type IN ('verse', 'chapter', 'scenario')),
  reference_id INTEGER NOT NULL, -- verse_id, chapter_id, or scenario_id
  chapter_id INTEGER NOT NULL, -- Always include for grouping and widget display
  title TEXT NOT NULL, -- Display title for quick reference
  content_preview TEXT, -- First 100 chars for iOS widget and quick display
  notes TEXT, -- User's personal notes on the bookmark
  tags TEXT[], -- User-defined tags for organization
  is_highlighted BOOLEAN DEFAULT false, -- Whether text is highlighted
  highlight_color TEXT DEFAULT 'yellow' CHECK (highlight_color IN ('yellow', 'green', 'blue', 'pink', 'purple')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  sync_status TEXT DEFAULT 'synced' CHECK (sync_status IN ('synced', 'pending', 'offline')),
  
  -- Constraints
  CONSTRAINT unique_user_bookmark UNIQUE (user_device_id, bookmark_type, reference_id)
);

-- Indexes for performance
CREATE INDEX idx_user_bookmarks_device ON user_bookmarks(user_device_id);
CREATE INDEX idx_user_bookmarks_type ON user_bookmarks(bookmark_type);
CREATE INDEX idx_user_bookmarks_chapter ON user_bookmarks(chapter_id);
CREATE INDEX idx_user_bookmarks_created ON user_bookmarks(created_at DESC);

-- =================================================================
-- 2. READING PROGRESS TRACKING TABLE
-- =================================================================
-- Tracks user reading progress, time spent, achievements
-- Essential for Apple's engagement requirements

CREATE TABLE public.user_progress (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_device_id TEXT NOT NULL,
  chapter_id INTEGER NOT NULL,
  verse_id INTEGER, -- Optional, for verse-level tracking
  progress_type TEXT NOT NULL CHECK (progress_type IN (
    'chapter_started', 
    'chapter_completed', 
    'verse_read', 
    'session_time',
    'daily_goal_met',
    'streak_milestone'
  )),
  progress_value NUMERIC, -- percentage, time in minutes, streak count, etc.
  session_date DATE DEFAULT CURRENT_DATE,
  session_duration_minutes INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Additional metadata for rich progress tracking
  metadata JSONB DEFAULT '{}' -- Store additional context
);

-- Indexes for analytics and widget performance
CREATE INDEX idx_user_progress_device ON user_progress(user_device_id);
CREATE INDEX idx_user_progress_date ON user_progress(session_date DESC);
CREATE INDEX idx_user_progress_type ON user_progress(progress_type);
CREATE INDEX idx_user_progress_chapter ON user_progress(chapter_id);

-- =================================================================
-- 3. USER SETTINGS & PREFERENCES TABLE
-- =================================================================
-- Central storage for user preferences, goals, and app settings
-- Enables personalized experience and iOS widget configuration

CREATE TABLE public.user_settings (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_device_id TEXT NOT NULL UNIQUE,
  
  -- Reading Goals & Preferences
  reading_goal_minutes INTEGER DEFAULT 10,
  notification_time TIME DEFAULT '08:00',
  notification_enabled BOOLEAN DEFAULT true,
  preferred_font_size TEXT DEFAULT 'medium' CHECK (preferred_font_size IN ('small', 'medium', 'large')),
  
  -- Progress Tracking
  reading_streak INTEGER DEFAULT 0,
  longest_streak INTEGER DEFAULT 0,
  last_read_date DATE,
  total_reading_time_minutes INTEGER DEFAULT 0,
  
  -- Completed Content Tracking
  chapters_completed INTEGER[] DEFAULT '{}',
  verses_read INTEGER[] DEFAULT '{}',
  scenarios_explored INTEGER[] DEFAULT '{}',
  
  -- Personal Achievement Data
  total_bookmarks INTEGER DEFAULT 0,
  total_journal_entries INTEGER DEFAULT 0,
  achievements_unlocked TEXT[] DEFAULT '{}',
  
  -- Widget Configuration
  widget_daily_verse_enabled BOOLEAN DEFAULT true,
  widget_progress_enabled BOOLEAN DEFAULT true,
  widget_bookmarks_enabled BOOLEAN DEFAULT true,
  
  -- App Customization
  theme_preference TEXT DEFAULT 'system' CHECK (theme_preference IN ('light', 'dark', 'system')),
  audio_enabled BOOLEAN DEFAULT true,
  haptic_feedback_enabled BOOLEAN DEFAULT true,
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_user_settings_device ON user_settings(user_device_id);

-- =================================================================
-- 4. SEARCH INDEX TABLE FOR FAST CONTENT DISCOVERY
-- =================================================================
-- Full-text search across all content types
-- Critical for Apple's functionality requirements

CREATE TABLE public.content_search_index (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  content_type TEXT NOT NULL CHECK (content_type IN ('verse', 'chapter', 'scenario')),
  reference_id INTEGER NOT NULL,
  chapter_id INTEGER NOT NULL,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  subtitle TEXT,
  tags TEXT[],
  search_vector TSVECTOR, -- PostgreSQL full-text search
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Ensure unique content entries
  CONSTRAINT unique_content_entry UNIQUE (content_type, reference_id)
);

-- Full-text search index (PostgreSQL native)
CREATE INDEX idx_content_search_vector ON content_search_index USING GIN(search_vector);
CREATE INDEX idx_content_search_type ON content_search_index(content_type);
CREATE INDEX idx_content_search_chapter ON content_search_index(chapter_id);

-- =================================================================
-- 5. USER ACTIVITY LOG FOR ENGAGEMENT ANALYTICS
-- =================================================================
-- Track user interactions for Apple's engagement requirements

CREATE TABLE public.user_activity_log (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_device_id TEXT NOT NULL,
  activity_type TEXT NOT NULL CHECK (activity_type IN (
    'app_open',
    'verse_read',
    'chapter_completed',
    'bookmark_created',
    'search_performed',
    'journal_entry_created',
    'widget_interaction',
    'notification_received',
    'sharing_action',
    'audio_played',
    'practice_session',
    'achievement_unlocked'
  )),
  content_reference TEXT, -- Reference to specific content (chapter_1, verse_2_3, etc.)
  session_id TEXT, -- Group activities by app session
  activity_metadata JSONB DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for analytics
CREATE INDEX idx_activity_device ON user_activity_log(user_device_id);
CREATE INDEX idx_activity_type ON user_activity_log(activity_type);
CREATE INDEX idx_activity_date ON user_activity_log(created_at DESC);

-- =================================================================
-- 6. DAILY PRACTICE & HABIT TRACKING
-- =================================================================
-- Track daily spiritual practices and habits
-- Essential for Apple's user engagement requirements

CREATE TABLE public.daily_practice_log (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_device_id TEXT NOT NULL,
  practice_date DATE DEFAULT CURRENT_DATE,
  practice_type TEXT NOT NULL CHECK (practice_type IN (
    'morning_verse',
    'evening_reflection',
    'meditation_timer',
    'gratitude_journal',
    'verse_contemplation',
    'chapter_study'
  )),
  duration_minutes INTEGER DEFAULT 0,
  completion_status TEXT DEFAULT 'completed' CHECK (completion_status IN ('completed', 'partial', 'skipped')),
  notes TEXT,
  verse_reference TEXT, -- Which verse was used for practice
  mood_before TEXT CHECK (mood_before IN ('stressed', 'neutral', 'peaceful', 'excited', 'anxious')),
  mood_after TEXT CHECK (mood_after IN ('stressed', 'neutral', 'peaceful', 'excited', 'anxious')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Ensure one practice per type per day per user
  CONSTRAINT unique_daily_practice UNIQUE (user_device_id, practice_date, practice_type)
);

-- Indexes for habit tracking and widgets
CREATE INDEX idx_practice_device ON daily_practice_log(user_device_id);
CREATE INDEX idx_practice_date ON daily_practice_log(practice_date DESC);
CREATE INDEX idx_practice_type ON daily_practice_log(practice_type);

-- =================================================================
-- 7. ENHANCED USER FAVORITES (EXTEND EXISTING)
-- =================================================================
-- Add columns to existing user_favorites table for richer functionality

-- Add new columns to existing user_favorites table
ALTER TABLE public.user_favorites 
ADD COLUMN IF NOT EXISTS user_device_id TEXT,
ADD COLUMN IF NOT EXISTS favorite_type TEXT DEFAULT 'scenario' CHECK (favorite_type IN ('verse', 'chapter', 'scenario')),
ADD COLUMN IF NOT EXISTS notes TEXT,
ADD COLUMN IF NOT EXISTS tags TEXT[],
ADD COLUMN IF NOT EXISTS last_accessed_at TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS access_count INTEGER DEFAULT 1;

-- Update existing records to have favorite_type = 'scenario'
UPDATE public.user_favorites SET favorite_type = 'scenario' WHERE favorite_type IS NULL;

-- =================================================================
-- 8. NOTIFICATION HISTORY FOR ENGAGEMENT TRACKING
-- =================================================================
-- Track notification delivery and interaction
-- Important for Apple's user engagement assessment

CREATE TABLE public.notification_history (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_device_id TEXT NOT NULL,
  notification_type TEXT NOT NULL CHECK (notification_type IN (
    'daily_verse',
    'reading_reminder',
    'streak_milestone',
    'practice_reminder',
    'weekly_summary',
    'achievement_unlocked'
  )),
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  sent_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  opened_at TIMESTAMP WITH TIME ZONE,
  action_taken TEXT, -- 'opened', 'dismissed', 'interacted'
  content_reference TEXT, -- Which verse/chapter was featured
  
  -- Track effectiveness
  delivered BOOLEAN DEFAULT true,
  engagement_score NUMERIC DEFAULT 0 -- 0-1 based on user interaction
);

-- Indexes for notification analytics
CREATE INDEX idx_notification_device ON notification_history(user_device_id);
CREATE INDEX idx_notification_type ON notification_history(notification_type);
CREATE INDEX idx_notification_sent ON notification_history(sent_at DESC);

-- =================================================================
-- 9. TRIGGERS FOR AUTOMATIC UPDATES
-- =================================================================

-- Update search vector when content changes
CREATE OR REPLACE FUNCTION update_search_vector() RETURNS TRIGGER AS $$
BEGIN
  NEW.search_vector := to_tsvector('english', 
    COALESCE(NEW.title, '') || ' ' || 
    COALESCE(NEW.content, '') || ' ' ||
    COALESCE(NEW.subtitle, '') || ' ' ||
    COALESCE(array_to_string(NEW.tags, ' '), '')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_search_vector
  BEFORE INSERT OR UPDATE ON content_search_index
  FOR EACH ROW EXECUTE FUNCTION update_search_vector();

-- Update timestamps
CREATE OR REPLACE FUNCTION update_updated_at() RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at := NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_user_bookmarks_updated_at
  BEFORE UPDATE ON user_bookmarks
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trigger_user_settings_updated_at
  BEFORE UPDATE ON user_settings
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- =================================================================
-- 10. POPULATE SEARCH INDEX FROM EXISTING DATA
-- =================================================================

-- Populate search index with existing verses
INSERT INTO content_search_index (content_type, reference_id, chapter_id, title, content)
SELECT 
  'verse' as content_type,
  gv_verses_id as reference_id,
  gv_chapter_id as chapter_id,
  CONCAT('Verse ', gv_verses_id) as title,
  gv_verses as content
FROM gita_verses
ON CONFLICT (content_type, reference_id) DO NOTHING;

-- Populate search index with existing chapters
INSERT INTO content_search_index (content_type, reference_id, chapter_id, title, content, subtitle)
SELECT 
  'chapter' as content_type,
  ch_chapter_id as reference_id,
  ch_chapter_id as chapter_id,
  ch_title as title,
  COALESCE(ch_summary, '') as content,
  ch_subtitle as subtitle
FROM chapters
ON CONFLICT (content_type, reference_id) DO NOTHING;

-- Populate search index with existing scenarios
INSERT INTO content_search_index (content_type, reference_id, chapter_id, title, content)
SELECT 
  'scenario' as content_type,
  CAST(SUBSTRING(id::text FROM 1 FOR 8) AS INTEGER) as reference_id, -- Use first 8 chars as int
  sc_chapter as chapter_id,
  sc_title as title,
  sc_description as content
FROM scenarios
WHERE sc_chapter IS NOT NULL
ON CONFLICT (content_type, reference_id) DO NOTHING;

-- =================================================================
-- 11. CREATE VIEWS FOR COMMON QUERIES
-- =================================================================

-- User dashboard data view
CREATE OR REPLACE VIEW user_dashboard_data AS
SELECT 
  us.user_device_id,
  us.reading_streak,
  us.total_reading_time_minutes,
  us.total_bookmarks,
  us.total_journal_entries,
  COUNT(DISTINCT ub.id) as current_bookmarks,
  COUNT(DISTINCT CASE WHEN up.session_date = CURRENT_DATE THEN up.id END) as today_progress_entries,
  MAX(up.session_date) as last_activity_date
FROM user_settings us
LEFT JOIN user_bookmarks ub ON us.user_device_id = ub.user_device_id
LEFT JOIN user_progress up ON us.user_device_id = up.user_device_id
GROUP BY us.user_device_id, us.reading_streak, us.total_reading_time_minutes, us.total_bookmarks, us.total_journal_entries;

-- Recent bookmarks view for widgets
CREATE OR REPLACE VIEW recent_bookmarks_widget AS
SELECT 
  user_device_id,
  title,
  content_preview,
  bookmark_type,
  reference_id,
  chapter_id,
  created_at
FROM user_bookmarks
ORDER BY created_at DESC
LIMIT 10;

-- Reading progress summary view
CREATE OR REPLACE VIEW reading_progress_summary AS
SELECT 
  user_device_id,
  COUNT(DISTINCT chapter_id) as chapters_visited,
  SUM(CASE WHEN progress_type = 'chapter_completed' THEN 1 ELSE 0 END) as chapters_completed,
  SUM(session_duration_minutes) as total_reading_minutes,
  MAX(session_date) as last_read_date,
  COUNT(DISTINCT session_date) as reading_days
FROM user_progress
GROUP BY user_device_id;

-- =================================================================
-- SCHEMA CREATION COMPLETE
-- =================================================================

-- Grant necessary permissions
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO anon, authenticated;

-- Add RLS policies if needed (simplified for MVP)
ALTER TABLE user_bookmarks ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_practice_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE notification_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_activity_log ENABLE ROW LEVEL SECURITY;

-- Simple RLS policy - users can only access their own data
CREATE POLICY user_data_policy ON user_bookmarks FOR ALL USING (true); -- Simplified for MVP
CREATE POLICY user_progress_policy ON user_progress FOR ALL USING (true);
CREATE POLICY user_settings_policy ON user_settings FOR ALL USING (true);
CREATE POLICY user_practice_policy ON daily_practice_log FOR ALL USING (true);
CREATE POLICY user_notification_policy ON notification_history FOR ALL USING (true);
CREATE POLICY user_activity_policy ON user_activity_log FOR ALL USING (true);

-- Create indexes for optimal performance
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_user_bookmarks_widget_data 
ON user_bookmarks(user_device_id, created_at DESC) 
WHERE sync_status = 'synced';

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_user_progress_dashboard 
ON user_progress(user_device_id, session_date DESC, progress_type);

-- Final comment
COMMENT ON SCHEMA public IS 'GitaWisdom Apple Approval Schema - Addresses minimum functionality requirements with interactive features, progress tracking, bookmarking, and iOS native integration capabilities';