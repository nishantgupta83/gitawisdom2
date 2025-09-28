-- GitaWisdom Test Users Creation - PostgreSQL Script
-- Run this directly in your Supabase SQL Editor

-- =================================================================
-- IMPORTANT: SUPABASE AUTH USERS CREATION
-- =================================================================
-- Since Supabase Auth users must be created through the Auth API,
-- we'll simulate them using temporary UUIDs that you can replace
-- with real ones after creating users in Supabase Dashboard

-- First, let's create temporary auth-like user IDs for testing
-- In production, replace these with actual Supabase Auth user UUIDs

-- Test User UUIDs (replace with real ones from Supabase Dashboard)
-- test1@gitawisdom.com -> 11111111-1111-1111-1111-111111111111
-- test2@gitawisdom.com -> 22222222-2222-2222-2222-222222222222
-- test3@gitawisdom.com -> 33333333-3333-3333-3333-333333333333
-- test4@gitawisdom.com -> 44444444-4444-4444-4444-444444444444
-- test5@gitawisdom.com -> 55555555-5555-5555-5555-555555555555

-- =================================================================
-- 1. CREATE TEST USER SETTINGS
-- =================================================================

-- Test User 1: Beginner Reader (3-day streak, 5 bookmarks)
INSERT INTO public.user_settings (
  id,
  user_device_id,
  reading_goal_minutes,
  notification_time,
  notification_enabled,
  preferred_font_size,
  reading_streak,
  longest_streak,
  last_read_date,
  total_reading_time_minutes,
  chapters_completed,
  verses_read,
  scenarios_explored,
  total_bookmarks,
  total_journal_entries,
  achievements_unlocked,
  widget_daily_verse_enabled,
  widget_progress_enabled,
  widget_bookmarks_enabled,
  theme_preference,
  audio_enabled,
  haptic_feedback_enabled,
  created_at,
  updated_at
) VALUES (
  '11111111-1111-1111-1111-111111111111',
  '11111111-1111-1111-1111-111111111111',
  15,
  '08:00',
  true,
  'medium',
  3,
  7,
  CURRENT_DATE - INTERVAL '1 day',
  45,
  ARRAY[1, 2],
  ARRAY[1, 2, 3, 4, 5, 10, 11, 12, 47, 20],
  ARRAY[1, 2, 3],
  5,
  3,
  ARRAY['first_bookmark', 'week_streak'],
  true,
  true,
  true,
  'light',
  true,
  true,
  NOW() - INTERVAL '7 days',
  NOW()
) ON CONFLICT (user_device_id) DO UPDATE SET
  updated_at = NOW();

-- Test User 2: Advanced Reader (21-day streak, 25 bookmarks)
INSERT INTO public.user_settings (
  id,
  user_device_id,
  reading_goal_minutes,
  notification_time,
  notification_enabled,
  preferred_font_size,
  reading_streak,
  longest_streak,
  last_read_date,
  total_reading_time_minutes,
  chapters_completed,
  verses_read,
  scenarios_explored,
  total_bookmarks,
  total_journal_entries,
  achievements_unlocked,
  widget_daily_verse_enabled,
  widget_progress_enabled,
  widget_bookmarks_enabled,
  theme_preference,
  audio_enabled,
  haptic_feedback_enabled,
  created_at,
  updated_at
) VALUES (
  '22222222-2222-2222-2222-222222222222',
  '22222222-2222-2222-2222-222222222222',
  30,
  '06:30',
  true,
  'large',
  21,
  30,
  CURRENT_DATE,
  450,
  ARRAY[1, 2, 3, 4, 5, 6, 7, 8],
  (SELECT ARRAY(SELECT generate_series(1, 100))),
  (SELECT ARRAY(SELECT generate_series(1, 20))),
  25,
  15,
  ARRAY['first_bookmark', 'week_streak', 'month_streak', 'hundred_verses'],
  true,
  true,
  true,
  'dark',
  false,
  true,
  NOW() - INTERVAL '30 days',
  NOW()
) ON CONFLICT (user_device_id) DO UPDATE SET
  updated_at = NOW();

-- Test User 3: Casual Browser (inactive, notifications off)
INSERT INTO public.user_settings (
  id,
  user_device_id,
  reading_goal_minutes,
  notification_time,
  notification_enabled,
  preferred_font_size,
  reading_streak,
  longest_streak,
  last_read_date,
  total_reading_time_minutes,
  chapters_completed,
  verses_read,
  scenarios_explored,
  total_bookmarks,
  total_journal_entries,
  achievements_unlocked,
  widget_daily_verse_enabled,
  widget_progress_enabled,
  widget_bookmarks_enabled,
  theme_preference,
  audio_enabled,
  haptic_feedback_enabled,
  created_at,
  updated_at
) VALUES (
  '33333333-3333-3333-3333-333333333333',
  '33333333-3333-3333-3333-333333333333',
  10,
  '20:00',
  false,
  'small',
  0,
  2,
  CURRENT_DATE - INTERVAL '5 days',
  15,
  ARRAY[1],
  ARRAY[1, 2, 3],
  ARRAY[1],
  2,
  1,
  ARRAY['first_bookmark'],
  false,
  true,
  true,
  'system',
  true,
  false,
  NOW() - INTERVAL '15 days',
  NOW()
) ON CONFLICT (user_device_id) DO UPDATE SET
  updated_at = NOW();

-- Test User 4: Power User (90-day streak, all chapters completed)
INSERT INTO public.user_settings (
  id,
  user_device_id,
  reading_goal_minutes,
  notification_time,
  notification_enabled,
  preferred_font_size,
  reading_streak,
  longest_streak,
  last_read_date,
  total_reading_time_minutes,
  chapters_completed,
  verses_read,
  scenarios_explored,
  total_bookmarks,
  total_journal_entries,
  achievements_unlocked,
  widget_daily_verse_enabled,
  widget_progress_enabled,
  widget_bookmarks_enabled,
  theme_preference,
  audio_enabled,
  haptic_feedback_enabled,
  created_at,
  updated_at
) VALUES (
  '44444444-4444-4444-4444-444444444444',
  '44444444-4444-4444-4444-444444444444',
  60,
  '05:00',
  true,
  'medium',
  90,
  90,
  CURRENT_DATE,
  1500,
  (SELECT ARRAY(SELECT generate_series(1, 18))),
  (SELECT ARRAY(SELECT generate_series(1, 500))),
  (SELECT ARRAY(SELECT generate_series(1, 50))),
  100,
  50,
  ARRAY['first_bookmark', 'week_streak', 'month_streak', 'hundred_verses', 'all_chapters', 'meditation_master', 'year_streak'],
  true,
  true,
  true,
  'dark',
  true,
  true,
  NOW() - INTERVAL '100 days',
  NOW()
) ON CONFLICT (user_device_id) DO UPDATE SET
  updated_at = NOW();

-- Test User 5: New User (just started)
INSERT INTO public.user_settings (
  id,
  user_device_id,
  reading_goal_minutes,
  notification_time,
  notification_enabled,
  preferred_font_size,
  reading_streak,
  longest_streak,
  last_read_date,
  total_reading_time_minutes,
  chapters_completed,
  verses_read,
  scenarios_explored,
  total_bookmarks,
  total_journal_entries,
  achievements_unlocked,
  widget_daily_verse_enabled,
  widget_progress_enabled,
  widget_bookmarks_enabled,
  theme_preference,
  audio_enabled,
  haptic_feedback_enabled,
  created_at,
  updated_at
) VALUES (
  '55555555-5555-5555-5555-555555555555',
  '55555555-5555-5555-5555-555555555555',
  10,
  '08:00',
  true,
  'medium',
  1,
  1,
  CURRENT_DATE,
  5,
  ARRAY[]::INTEGER[],
  ARRAY[1],
  ARRAY[]::INTEGER[],
  0,
  0,
  ARRAY[]::TEXT[],
  true,
  true,
  true,
  'system',
  true,
  true,
  NOW() - INTERVAL '1 day',
  NOW()
) ON CONFLICT (user_device_id) DO UPDATE SET
  updated_at = NOW();

-- =================================================================
-- 2. CREATE TEST USER BOOKMARKS
-- =================================================================

-- Bookmarks for Test User 1 (Beginner - 5 bookmarks)
INSERT INTO public.user_bookmarks (
  id,
  user_device_id,
  bookmark_type,
  reference_id,
  chapter_id,
  title,
  content_preview,
  notes,
  tags,
  is_highlighted,
  highlight_color,
  created_at,
  updated_at,
  sync_status
) VALUES
  -- Verse bookmarks
  (gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'verse', 1, 1, 'Bhagavad Gita 1.1', 
   'Dhritarashtra said: O Sanjaya, what did my sons and the sons of Pandu do when they assembled...', 
   'Beginning of the epic dialogue', ARRAY['beginning', 'kurukshetra', 'important'], true, 'yellow', 
   NOW() - INTERVAL '5 days', NOW(), 'synced'),
  
  (gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'verse', 47, 2, 'Bhagavad Gita 2.47', 
   'You have the right to perform your duty, but never to the fruits of action. Never let the fruits...', 
   'Key teaching on karma yoga - very important!', ARRAY['karma', 'duty', 'fundamental'], true, 'green', 
   NOW() - INTERVAL '3 days', NOW(), 'synced'),
  
  (gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'verse', 20, 2, 'Bhagavad Gita 2.20', 
   'The soul is neither born, nor does it die. It is not slain when the body is slain...', 
   'Beautiful explanation of the eternal soul', ARRAY['soul', 'eternal', 'philosophy'], true, 'purple', 
   NOW() - INTERVAL '2 days', NOW(), 'synced'),
  
  -- Chapter bookmark
  (gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'chapter', 3, 3, 'Chapter 3: Karma Yoga', 
   'The Yoga of Action - This chapter explains the principles of selfless action and how to act...', 
   'Must study this chapter deeply', ARRAY['karma', 'action', 'yoga'], false, 'blue', 
   NOW() - INTERVAL '1 day', NOW(), 'synced'),
  
  -- Scenario bookmark
  (gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'scenario', 1, 1, 'Work-Life Balance Dilemma', 
   'How to balance professional responsibilities with personal spiritual growth and family time...', 
   'Very relevant to my current situation at work', ARRAY['work', 'balance', 'relevant'], true, 'pink', 
   NOW() - INTERVAL '6 hours', NOW(), 'synced');

-- Bookmarks for Test User 2 (Advanced - 25 bookmarks)
INSERT INTO public.user_bookmarks (
  user_device_id,
  bookmark_type,
  reference_id,
  chapter_id,
  title,
  content_preview,
  notes,
  tags,
  is_highlighted,
  highlight_color,
  created_at,
  sync_status
) 
SELECT 
  '22222222-2222-2222-2222-222222222222',
  CASE 
    WHEN s % 3 = 0 THEN 'verse'
    WHEN s % 3 = 1 THEN 'chapter' 
    ELSE 'scenario'
  END,
  s,
  ((s - 1) % 18) + 1,
  CASE 
    WHEN s % 3 = 0 THEN 'Bhagavad Gita ' || ((s - 1) % 18 + 1) || '.' || s
    WHEN s % 3 = 1 THEN 'Chapter ' || s || ': Advanced Study'
    ELSE 'Modern Scenario ' || s
  END,
  'Advanced user bookmark content preview for reference ' || s || '. This contains deeper insights...',
  CASE WHEN s % 4 = 0 THEN 'Deep study note for bookmark ' || s ELSE NULL END,
  ARRAY['advanced', 'study', 'bookmark' || s],
  (s % 3 = 0),
  (ARRAY['yellow', 'green', 'blue', 'pink', 'purple'])[((s - 1) % 5) + 1],
  NOW() - INTERVAL (s || ' hours'),
  'synced'
FROM generate_series(1, 25) s;

-- Bookmarks for Test User 3 (Casual - 2 bookmarks)
INSERT INTO public.user_bookmarks (
  user_device_id,
  bookmark_type,
  reference_id,
  chapter_id,
  title,
  content_preview,
  notes,
  tags,
  is_highlighted,
  highlight_color,
  created_at,
  sync_status
) VALUES
  (gen_random_uuid(), '33333333-3333-3333-3333-333333333333', 'verse', 47, 2, 'Bhagavad Gita 2.47',
   'You have the right to perform your duty, but never to the fruits of action...',
   NULL, ARRAY['basic'], false, 'yellow',
   NOW() - INTERVAL '10 days', 'synced'),
   
  (gen_random_uuid(), '33333333-3333-3333-3333-333333333333', 'chapter', 1, 1, 'Chapter 1: The Yoga of Arjuna''s Dejection',
   'The first chapter sets the scene for the great dialogue between Arjuna and Krishna...',
   'Interesting introduction', ARRAY['intro'], false, 'blue',
   NOW() - INTERVAL '8 days', 'synced');

-- Bookmarks for Test User 4 (Power User - 100 bookmarks, but we'll create 50 for demo)
INSERT INTO public.user_bookmarks (
  user_device_id,
  bookmark_type,
  reference_id,
  chapter_id,
  title,
  content_preview,
  notes,
  tags,
  is_highlighted,
  highlight_color,
  created_at,
  sync_status
)
SELECT 
  '44444444-4444-4444-4444-444444444444',
  CASE 
    WHEN s % 4 = 0 THEN 'verse'
    WHEN s % 4 = 1 THEN 'chapter'
    WHEN s % 4 = 2 THEN 'scenario'
    ELSE 'verse'
  END,
  s,
  ((s - 1) % 18) + 1,
  'Power User Bookmark ' || s,
  'Comprehensive study material for advanced spiritual seeker. Reference ' || s || ' contains...',
  'Power user detailed analysis note for ' || s,
  ARRAY['power', 'advanced', 'comprehensive', 'chapter' || ((s - 1) % 18) + 1],
  (s % 2 = 0),
  (ARRAY['yellow', 'green', 'blue', 'pink', 'purple'])[((s - 1) % 5) + 1],
  NOW() - INTERVAL (s || ' days'),
  'synced'
FROM generate_series(1, 50) s;

-- =================================================================
-- 3. CREATE TEST USER PROGRESS DATA
-- =================================================================

-- Progress for Test User 1 (Beginner)
INSERT INTO public.user_progress (
  user_device_id,
  chapter_id,
  verse_id,
  progress_type,
  progress_value,
  session_date,
  session_duration_minutes,
  created_at,
  metadata
) VALUES
  -- Chapter completions
  ('11111111-1111-1111-1111-111111111111', 1, NULL, 'chapter_completed', 100, CURRENT_DATE - INTERVAL '7 days', 15, NOW() - INTERVAL '7 days', '{"difficulty": "beginner", "engagement": "high"}'),
  ('11111111-1111-1111-1111-111111111111', 2, NULL, 'chapter_completed', 100, CURRENT_DATE - INTERVAL '3 days', 20, NOW() - INTERVAL '3 days', '{"difficulty": "beginner", "engagement": "high"}'),
  ('11111111-1111-1111-1111-111111111111', 3, NULL, 'chapter_started', 40, CURRENT_DATE - INTERVAL '1 day', 10, NOW() - INTERVAL '1 day', '{"difficulty": "beginner", "engagement": "medium"}'),
  
  -- Verse readings
  ('11111111-1111-1111-1111-111111111111', 1, 1, 'verse_read', 1, CURRENT_DATE, 2, NOW(), '{"first_time": true}'),
  ('11111111-1111-1111-1111-111111111111', 1, 2, 'verse_read', 1, CURRENT_DATE, 2, NOW(), '{"first_time": true}'),
  ('11111111-1111-1111-1111-111111111111', 2, 47, 'verse_read', 1, CURRENT_DATE, 3, NOW(), '{"bookmarked": true, "highlighted": true}'),
  
  -- Daily goals and streaks
  ('11111111-1111-1111-1111-111111111111', 1, NULL, 'daily_goal_met', 1, CURRENT_DATE - INTERVAL '2 days', 15, NOW() - INTERVAL '2 days', '{"goal_minutes": 15, "actual_minutes": 18}'),
  ('11111111-1111-1111-1111-111111111111', 2, NULL, 'daily_goal_met', 1, CURRENT_DATE - INTERVAL '1 day', 12, NOW() - INTERVAL '1 day', '{"goal_minutes": 15, "actual_minutes": 12}'),
  ('11111111-1111-1111-1111-111111111111', 3, NULL, 'streak_milestone', 3, CURRENT_DATE, 10, NOW(), '{"milestone": "3_days", "achievement": "first_streak"}');

-- Progress for Test User 2 (Advanced)
INSERT INTO public.user_progress (
  user_device_id,
  chapter_id,
  progress_type,
  progress_value,
  session_date,
  session_duration_minutes,
  created_at,
  metadata
)
SELECT 
  '22222222-2222-2222-2222-222222222222',
  s,
  'chapter_completed',
  100,
  CURRENT_DATE - INTERVAL (30 - s || ' days'),
  25 + (s % 20),
  NOW() - INTERVAL (30 - s || ' days'),
  ('{"completion_order": ' || s || ', "difficulty": "advanced", "rating": ' || (4.0 + (s % 10) * 0.1) || '}')::jsonb
FROM generate_series(1, 8) s;

-- Add streak milestones for advanced user
INSERT INTO public.user_progress (
  user_device_id,
  chapter_id,
  progress_type,
  progress_value,
  session_date,
  session_duration_minutes,
  created_at,
  metadata
) VALUES
  ('22222222-2222-2222-2222-222222222222', 1, 'streak_milestone', 7, CURRENT_DATE - INTERVAL '14 days', 0, NOW() - INTERVAL '14 days', '{"milestone": "week_streak", "achievement": "consistent_reader"}'),
  ('22222222-2222-2222-2222-222222222222', 1, 'streak_milestone', 21, CURRENT_DATE, 0, NOW(), '{"milestone": "21_days", "achievement": "habit_formed"}');

-- Progress for Test User 4 (Power User)
INSERT INTO public.user_progress (
  user_device_id,
  chapter_id,
  progress_type,
  progress_value,
  session_date,
  session_duration_minutes,
  created_at,
  metadata
)
SELECT 
  '44444444-4444-4444-4444-444444444444',
  s,
  'chapter_completed',
  100,
  CURRENT_DATE - INTERVAL (100 - s * 3 || ' days'),
  45 + (s % 30),
  NOW() - INTERVAL (100 - s * 3 || ' days'),
  ('{"completion_order": ' || s || ', "difficulty": "mastery", "rating": 5.0, "notes": "Complete mastery of chapter"}')::jsonb
FROM generate_series(1, 18) s;

-- Add major milestones for power user
INSERT INTO public.user_progress (
  user_device_id,
  chapter_id,
  progress_type,
  progress_value,
  session_date,
  session_duration_minutes,
  created_at,
  metadata
) VALUES
  ('44444444-4444-4444-4444-444444444444', 18, 'streak_milestone', 30, CURRENT_DATE - INTERVAL '60 days', 0, NOW() - INTERVAL '60 days', '{"milestone": "month_streak", "achievement": "dedicated_seeker"}'),
  ('44444444-4444-4444-4444-444444444444', 18, 'streak_milestone', 90, CURRENT_DATE, 0, NOW(), '{"milestone": "90_days", "achievement": "spiritual_warrior"}');

-- =================================================================
-- 4. CREATE DAILY PRACTICE LOGS
-- =================================================================

-- Daily practice for Test User 1
INSERT INTO public.daily_practice_log (
  user_device_id,
  practice_date,
  practice_type,
  duration_minutes,
  completion_status,
  notes,
  verse_reference,
  mood_before,
  mood_after,
  created_at
) VALUES
  ('11111111-1111-1111-1111-111111111111', CURRENT_DATE, 'morning_verse', 10, 'completed', 'Felt peaceful reading about duty', '2.47', 'neutral', 'peaceful', NOW()),
  ('11111111-1111-1111-1111-111111111111', CURRENT_DATE - INTERVAL '1 day', 'morning_verse', 8, 'completed', 'Good start to the day', '1.1', 'stressed', 'neutral', NOW() - INTERVAL '1 day'),
  ('11111111-1111-1111-1111-111111111111', CURRENT_DATE - INTERVAL '2 days', 'evening_reflection', 12, 'completed', 'Deep contemplation on karma', '3.5', 'neutral', 'peaceful', NOW() - INTERVAL '2 days');

-- Daily practice for Test User 2 (Advanced)
INSERT INTO public.daily_practice_log (
  user_device_id,
  practice_date,
  practice_type,
  duration_minutes,
  completion_status,
  notes,
  verse_reference,
  mood_before,
  mood_after,
  created_at
) 
SELECT
  '22222222-2222-2222-2222-222222222222',
  CURRENT_DATE - INTERVAL (s || ' days'),
  (ARRAY['morning_verse', 'evening_reflection', 'meditation_timer', 'verse_contemplation'])[((s % 4) + 1)],
  20 + (s % 25),
  'completed',
  'Advanced practice session ' || s,
  (ARRAY['2.47', '3.5', '6.5', '9.22', '18.66'])[((s % 5) + 1)],
  (ARRAY['neutral', 'peaceful', 'stressed', 'excited'])[((s % 4) + 1)],
  'peaceful',
  NOW() - INTERVAL (s || ' days')
FROM generate_series(0, 20) s;

-- Daily practice for Test User 4 (Power User)
INSERT INTO public.daily_practice_log (
  user_device_id,
  practice_date,
  practice_type,
  duration_minutes,
  completion_status,
  notes,
  verse_reference,
  mood_before,
  mood_after,
  created_at
)
SELECT
  '44444444-4444-4444-4444-444444444444',
  CURRENT_DATE - INTERVAL (s || ' days'),
  (ARRAY['morning_verse', 'evening_reflection', 'meditation_timer', 'verse_contemplation', 'chapter_study'])[((s % 5) + 1)],
  30 + (s % 40),
  'completed',
  'Power user intensive practice - session ' || s,
  (ARRAY['2.47', '3.5', '6.5', '9.22', '18.66', '4.7', '15.15'])[((s % 7) + 1)],
  (ARRAY['neutral', 'peaceful', 'excited'])[((s % 3) + 1)],
  'peaceful',
  NOW() - INTERVAL (s || ' days')
FROM generate_series(0, 89) s;

-- =================================================================
-- 5. CREATE NOTIFICATION HISTORY
-- =================================================================

-- Notification history for Test User 1
INSERT INTO public.notification_history (
  user_device_id,
  notification_type,
  title,
  body,
  sent_at,
  opened_at,
  action_taken,
  content_reference,
  delivered,
  engagement_score
) VALUES
  ('11111111-1111-1111-1111-111111111111', 'daily_verse', 'Daily Gita Wisdom 🕉️', 'Discover today''s verse for guidance: Chapter 2, Verse 47', NOW() - INTERVAL '1 day', NOW() - INTERVAL '23 hours', 'opened', '2.47', true, 0.8),
  ('11111111-1111-1111-1111-111111111111', 'reading_reminder', 'Keep Your Reading Streak! 🔥', 'Don''t break your 3-day streak. Read a verse today!', NOW() - INTERVAL '6 hours', NOW() - INTERVAL '5 hours', 'opened', null, true, 0.9),
  ('11111111-1111-1111-1111-111111111111', 'achievement_unlocked', '🏆 Achievement Unlocked!', 'Week Streak - You''ve maintained a 7-day reading habit!', NOW() - INTERVAL '4 days', NOW() - INTERVAL '4 days', 'opened', 'achievement:week_streak', true, 1.0);

-- Notification history for Test User 2 (Advanced)
INSERT INTO public.notification_history (
  user_device_id,
  notification_type,
  title,
  body,
  sent_at,
  opened_at,
  action_taken,
  content_reference,
  delivered,
  engagement_score
)
SELECT
  '22222222-2222-2222-2222-222222222222',
  (ARRAY['daily_verse', 'reading_reminder', 'weekly_summary', 'achievement_unlocked'])[((s % 4) + 1)],
  'Notification Title ' || s,
  'Advanced user notification body ' || s,
  NOW() - INTERVAL (s || ' days'),
  CASE WHEN s % 3 = 0 THEN NOW() - INTERVAL (s || ' days') + INTERVAL '1 hour' ELSE NULL END,
  CASE WHEN s % 3 = 0 THEN 'opened' WHEN s % 3 = 1 THEN 'dismissed' ELSE NULL END,
  'reference_' || s,
  true,
  0.7 + (s % 3) * 0.1
FROM generate_series(1, 21) s;

-- =================================================================
-- 6. CREATE USER ACTIVITY LOGS
-- =================================================================

-- Activity logs for Test User 1
INSERT INTO public.user_activity_log (
  user_device_id,
  activity_type,
  content_reference,
  session_id,
  activity_metadata,
  created_at
) VALUES
  ('11111111-1111-1111-1111-111111111111', 'app_open', null, 'session_1', '{"platform": "android", "version": "2.2.8"}', NOW()),
  ('11111111-1111-1111-1111-111111111111', 'verse_read', 'verse_2_47', 'session_1', '{"reading_time_seconds": 45, "bookmarked": true}', NOW() - INTERVAL '30 minutes'),
  ('11111111-1111-1111-1111-111111111111', 'bookmark_created', 'verse_2_47', 'session_1', '{"highlight_color": "green", "notes_added": true}', NOW() - INTERVAL '25 minutes'),
  ('11111111-1111-1111-1111-111111111111', 'chapter_completed', 'chapter_2', 'session_2', '{"completion_time_minutes": 20, "engagement": "high"}', NOW() - INTERVAL '3 days'),
  ('11111111-1111-1111-1111-111111111111', 'achievement_unlocked', 'streak_3_days', 'session_3', '{"milestone": "3_days", "celebration_viewed": true}', NOW() - INTERVAL '1 day');

-- Activity logs for Test User 2 (lots of activity)
INSERT INTO public.user_activity_log (
  user_device_id,
  activity_type,
  content_reference,
  session_id,
  activity_metadata,
  created_at
)
SELECT
  '22222222-2222-2222-2222-222222222222',
  (ARRAY['app_open', 'verse_read', 'bookmark_created', 'chapter_completed', 'search_performed', 'sharing_action'])[((s % 6) + 1)],
  'content_ref_' || s,
  'session_' || ((s % 10) + 1),
  ('{"activity_number": ' || s || ', "user_type": "advanced", "engagement": "high"}')::jsonb,
  NOW() - INTERVAL (s || ' hours')
FROM generate_series(1, 50) s;

-- =================================================================
-- 7. VERIFICATION QUERIES
-- =================================================================

-- Verify user settings
SELECT 
  user_device_id,
  reading_streak,
  total_reading_time_minutes,
  total_bookmarks,
  array_length(chapters_completed, 1) as chapters_completed_count,
  array_length(achievements_unlocked, 1) as achievements_count
FROM user_settings 
ORDER BY reading_streak DESC;

-- Verify bookmarks count per user
SELECT 
  user_device_id,
  bookmark_type,
  COUNT(*) as count
FROM user_bookmarks 
GROUP BY user_device_id, bookmark_type
ORDER BY user_device_id, bookmark_type;

-- Verify progress entries
SELECT 
  user_device_id,
  progress_type,
  COUNT(*) as count,
  SUM(session_duration_minutes) as total_minutes
FROM user_progress 
GROUP BY user_device_id, progress_type
ORDER BY user_device_id, progress_type;

-- Verify daily practice
SELECT 
  user_device_id,
  practice_type,
  COUNT(*) as practice_sessions,
  AVG(duration_minutes) as avg_duration
FROM daily_practice_log
GROUP BY user_device_id, practice_type
ORDER BY user_device_id, practice_type;

-- Create a summary view for easy testing
CREATE OR REPLACE VIEW test_users_summary AS
SELECT 
  us.user_device_id,
  us.reading_streak,
  us.total_reading_time_minutes,
  COALESCE(bookmark_counts.total_bookmarks, 0) as actual_bookmarks,
  COALESCE(progress_counts.chapters_read, 0) as chapters_with_progress,
  COALESCE(practice_counts.practice_days, 0) as practice_days,
  us.theme_preference,
  us.notification_enabled,
  us.created_at::date as account_created
FROM user_settings us
LEFT JOIN (
  SELECT user_device_id, COUNT(*) as total_bookmarks
  FROM user_bookmarks 
  GROUP BY user_device_id
) bookmark_counts ON us.user_device_id = bookmark_counts.user_device_id
LEFT JOIN (
  SELECT user_device_id, COUNT(DISTINCT chapter_id) as chapters_read
  FROM user_progress 
  GROUP BY user_device_id
) progress_counts ON us.user_device_id = progress_counts.user_device_id
LEFT JOIN (
  SELECT user_device_id, COUNT(DISTINCT practice_date) as practice_days
  FROM daily_practice_log 
  GROUP BY user_device_id
) practice_counts ON us.user_device_id = practice_counts.user_device_id
ORDER BY us.reading_streak DESC;

-- View the summary
SELECT * FROM test_users_summary;

-- =================================================================
-- INSTRUCTIONS FOR SUPABASE AUTH USER CREATION
-- =================================================================

/*
TO COMPLETE THE TEST SETUP:

1. Go to your Supabase Dashboard > Authentication > Users
2. Create 5 new users with these emails and password "TestUser@2024":
   - test1@gitawisdom.com
   - test2@gitawisdom.com  
   - test3@gitawisdom.com
   - test4@gitawisdom.com
   - test5@gitawisdom.com

3. After creating each user, note down their UUID from the auth.users table

4. Update this script by replacing the placeholder UUIDs:
   - 11111111-1111-1111-1111-111111111111 -> Real UUID for test1@gitawisdom.com
   - 22222222-2222-2222-2222-222222222222 -> Real UUID for test2@gitawisdom.com
   - etc.

5. Re-run this script with the real UUIDs

ALTERNATIVELY: Use the Supabase Auth API or create users programmatically
and then run this script with the returned UUIDs.
*/

-- Final confirmation message
DO $$
BEGIN
    RAISE NOTICE 'Test users data created successfully!';
    RAISE NOTICE 'Remember to create the actual auth users in Supabase Dashboard';
    RAISE NOTICE 'Then update the UUIDs in this script and re-run';
END $$;