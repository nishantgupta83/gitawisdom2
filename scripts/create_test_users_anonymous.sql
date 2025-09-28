-- GitaWisdom Test Users - Anonymous Mode (Immediate Testing)
-- This creates test data using device IDs for immediate testing
-- No Supabase Auth setup required - works with anonymous users

-- =================================================================
-- ANONYMOUS TEST USERS (Using Device ID Pattern)
-- =================================================================

-- Test Device IDs (simulating the app's device ID generation)
-- device_a1b2c3d4e5f6g7h8 -> test1@gitawisdom.com (Beginner)
-- device_x1y2z3a4b5c6d7e8 -> test2@gitawisdom.com (Advanced) 
-- device_m1n2o3p4q5r6s7t8 -> test3@gitawisdom.com (Casual)
-- device_u1v2w3x4y5z6a7b8 -> test4@gitawisdom.com (Power User)
-- device_k1l2m3n4o5p6q7r8 -> test5@gitawisdom.com (New User)

-- =================================================================
-- 1. CREATE ANONYMOUS TEST USER SETTINGS
-- =================================================================

-- Test User 1: Beginner Reader
INSERT INTO public.user_settings (
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
  theme_preference,
  audio_enabled,
  haptic_feedback_enabled,
  created_at,
  updated_at
) VALUES (
  'device_a1b2c3d4e5f6g7h8',  -- Beginner Reader
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
  'light',
  true,
  true,
  NOW() - INTERVAL '7 days',
  NOW()
) ON CONFLICT (user_device_id) DO UPDATE SET
  reading_streak = EXCLUDED.reading_streak,
  total_bookmarks = EXCLUDED.total_bookmarks,
  updated_at = NOW();

-- Test User 2: Advanced Reader  
INSERT INTO public.user_settings (
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
  theme_preference,
  audio_enabled,
  haptic_feedback_enabled,
  created_at,
  updated_at
) VALUES (
  'device_x1y2z3a4b5c6d7e8',  -- Advanced Reader
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
  'dark',
  false,
  true,
  NOW() - INTERVAL '30 days',
  NOW()
) ON CONFLICT (user_device_id) DO UPDATE SET
  reading_streak = EXCLUDED.reading_streak,
  total_bookmarks = EXCLUDED.total_bookmarks,
  updated_at = NOW();

-- Test User 3: Casual Browser
INSERT INTO public.user_settings (
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
  theme_preference,
  audio_enabled,
  haptic_feedback_enabled,
  created_at,
  updated_at
) VALUES (
  'device_m1n2o3p4q5r6s7t8',  -- Casual Browser
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
  'system',
  true,
  false,
  NOW() - INTERVAL '15 days',
  NOW()
) ON CONFLICT (user_device_id) DO UPDATE SET
  reading_streak = EXCLUDED.reading_streak,
  total_bookmarks = EXCLUDED.total_bookmarks,
  updated_at = NOW();

-- Test User 4: Power User
INSERT INTO public.user_settings (
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
  theme_preference,
  audio_enabled,
  haptic_feedback_enabled,
  created_at,
  updated_at
) VALUES (
  'device_u1v2w3x4y5z6a7b8',  -- Power User
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
  'dark',
  true,
  true,
  NOW() - INTERVAL '100 days',
  NOW()
) ON CONFLICT (user_device_id) DO UPDATE SET
  reading_streak = EXCLUDED.reading_streak,
  total_bookmarks = EXCLUDED.total_bookmarks,
  updated_at = NOW();

-- Test User 5: New User
INSERT INTO public.user_settings (
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
  theme_preference,
  audio_enabled,
  haptic_feedback_enabled,
  created_at,
  updated_at
) VALUES (
  'device_k1l2m3n4o5p6q7r8',  -- New User
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
  'system',
  true,
  true,
  NOW() - INTERVAL '1 day',
  NOW()
) ON CONFLICT (user_device_id) DO UPDATE SET
  reading_streak = EXCLUDED.reading_streak,
  total_bookmarks = EXCLUDED.total_bookmarks,
  updated_at = NOW();

-- =================================================================
-- 2. CREATE BOOKMARKS FOR ANONYMOUS USERS
-- =================================================================

-- Clear existing test bookmarks first
DELETE FROM public.user_bookmarks WHERE user_device_id LIKE 'device_%';

-- Bookmarks for Test User 1 (Beginner)
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
  updated_at,
  sync_status
) VALUES
  -- Essential beginner bookmarks
  ('device_a1b2c3d4e5f6g7h8', 'verse', 1, 1, 'Bhagavad Gita 1.1', 
   'Dhritarashtra said: O Sanjaya, what did my sons and the sons of Pandu do...', 
   'The beginning of this epic dialogue', ARRAY['beginning', 'epic', 'important'], true, 'yellow', 
   NOW() - INTERVAL '5 days', NOW(), 'synced'),
   
  ('device_a1b2c3d4e5f6g7h8', 'verse', 47, 2, 'Bhagavad Gita 2.47', 
   'You have the right to perform your duty, but never to the fruits of action...', 
   'The most important verse about karma yoga!', ARRAY['karma', 'duty', 'fundamental'], true, 'green', 
   NOW() - INTERVAL '3 days', NOW(), 'synced'),
   
  ('device_a1b2c3d4e5f6g7h8', 'verse', 20, 2, 'Bhagavad Gita 2.20', 
   'The soul is neither born, nor does it die. It is not slain when the body is slain...', 
   'Beautiful explanation of the eternal nature of the soul', ARRAY['soul', 'eternal', 'death'], true, 'purple', 
   NOW() - INTERVAL '2 days', NOW(), 'synced'),
   
  ('device_a1b2c3d4e5f6g7h8', 'chapter', 3, 3, 'Chapter 3: Karma Yoga', 
   'The Yoga of Action - This chapter explains the path of selfless action...', 
   'Must study this chapter thoroughly', ARRAY['karma', 'action', 'study'], false, 'blue', 
   NOW() - INTERVAL '1 day', NOW(), 'synced'),
   
  ('device_a1b2c3d4e5f6g7h8', 'scenario', 1, 1, 'Career vs Family Balance', 
   'How to balance professional ambitions with family responsibilities using Gita wisdom...', 
   'Very relevant to my current life situation', ARRAY['work', 'family', 'balance'], true, 'pink', 
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
  'device_x1y2z3a4b5c6d7e8',
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
    ELSE 'Life Scenario ' || s
  END,
  'Advanced bookmark content for reference ' || s || '. Contains deep philosophical insights...',
  CASE WHEN s % 4 = 0 THEN 'Profound insight from advanced study session ' || s ELSE NULL END,
  ARRAY['advanced', 'philosophy', 'study', 'chapter' || ((s - 1) % 18 + 1)],
  (s % 3 = 0),
  (ARRAY['yellow', 'green', 'blue', 'pink', 'purple'])[((s - 1) % 5) + 1],
  NOW() - INTERVAL (s || ' hours'),
  'synced'
FROM generate_series(1, 25) s;

-- Bookmarks for Test User 3 (Casual - just 2 bookmarks)
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
  ('device_m1n2o3p4q5r6s7t8', 'verse', 47, 2, 'Bhagavad Gita 2.47',
   'You have the right to perform your duty, but never to the fruits of action...',
   'Interesting concept', ARRAY['karma'], false, 'yellow',
   NOW() - INTERVAL '10 days', 'synced'),
   
  ('device_m1n2o3p4q5r6s7t8', 'chapter', 1, 1, 'Chapter 1: Arjuna''s Dilemma',
   'The setting and Arjuna''s moral crisis before the great battle...',
   'Good introduction to the story', ARRAY['intro', 'arjuna'], false, 'blue',
   NOW() - INTERVAL '8 days', 'synced');

-- Bookmarks for Test User 4 (Power User - 50 sample bookmarks)
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
  'device_u1v2w3x4y5z6a7b8',
  CASE 
    WHEN s % 4 = 0 THEN 'verse'
    WHEN s % 4 = 1 THEN 'chapter'
    ELSE 'scenario'
  END,
  s,
  ((s - 1) % 18) + 1,
  'Master Study: Reference ' || s,
  'Comprehensive analysis and cross-references for verse/chapter ' || s || '. Deep spiritual insights...',
  'Power user mastery notes: ' || s || ' - Complete understanding achieved',
  ARRAY['mastery', 'comprehensive', 'cross-reference', 'spiritual'],
  (s % 2 = 0),
  (ARRAY['yellow', 'green', 'blue', 'pink', 'purple'])[((s - 1) % 5) + 1],
  NOW() - INTERVAL (s || ' days'),
  'synced'
FROM generate_series(1, 50) s;

-- =================================================================
-- 3. CREATE PROGRESS DATA
-- =================================================================

-- Clear existing test progress
DELETE FROM public.user_progress WHERE user_device_id LIKE 'device_%';

-- Progress for Beginner User
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
  ('device_a1b2c3d4e5f6g7h8', 1, NULL, 'chapter_completed', 100, CURRENT_DATE - INTERVAL '7 days', 15, NOW() - INTERVAL '7 days', '{"engagement": "high", "first_completion": true}'),
  ('device_a1b2c3d4e5f6g7h8', 2, NULL, 'chapter_completed', 100, CURRENT_DATE - INTERVAL '3 days', 20, NOW() - INTERVAL '3 days', '{"engagement": "high", "key_verses_bookmarked": [47, 20]}'),
  ('device_a1b2c3d4e5f6g7h8', 3, NULL, 'chapter_started', 40, CURRENT_DATE - INTERVAL '1 day', 10, NOW() - INTERVAL '1 day', '{"current_verse": 15, "engagement": "medium"}'),
  
  -- Daily streaks
  ('device_a1b2c3d4e5f6g7h8', 1, NULL, 'streak_milestone', 3, CURRENT_DATE, 0, NOW(), '{"milestone": "3_days", "achievement_unlocked": "consistent_reader"}');

-- Progress for Advanced User
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
  'device_x1y2z3a4b5c6d7e8',
  s,
  'chapter_completed',
  100,
  CURRENT_DATE - INTERVAL (25 - s || ' days'),
  25 + (s % 20),
  NOW() - INTERVAL (25 - s || ' days'),
  ('{"completion_order": ' || s || ', "mastery_level": "advanced", "rating": ' || (4.5 + (s % 3) * 0.2) || '}')::jsonb
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
  ('device_x1y2z3a4b5c6d7e8', 1, 'streak_milestone', 7, CURRENT_DATE - INTERVAL '14 days', 0, NOW() - INTERVAL '14 days', '{"milestone": "week_streak"}'),
  ('device_x1y2z3a4b5c6d7e8', 1, 'streak_milestone', 21, CURRENT_DATE, 0, NOW(), '{"milestone": "21_days", "achievement": "habit_master"}');

-- Progress for Power User (all 18 chapters completed)
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
  'device_u1v2w3x4y5z6a7b8',
  s,
  'chapter_completed',
  100,
  CURRENT_DATE - INTERVAL (95 - s * 3 || ' days'),
  45 + (s % 25),
  NOW() - INTERVAL (95 - s * 3 || ' days'),
  ('{"completion_order": ' || s || ', "mastery_level": "expert", "rating": 5.0, "teaching_ready": true}')::jsonb
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
  ('device_u1v2w3x4y5z6a7b8', 18, 'streak_milestone', 30, CURRENT_DATE - INTERVAL '60 days', 0, NOW() - INTERVAL '60 days', '{"milestone": "month_streak"}'),
  ('device_u1v2w3x4y5z6a7b8', 18, 'streak_milestone', 90, CURRENT_DATE, 0, NOW(), '{"milestone": "90_days", "achievement": "spiritual_warrior", "gita_master": true}');

-- =================================================================
-- 4. CREATE SIMPLE TEST LOGIN CREDENTIALS TABLE
-- =================================================================

-- Create a simple table to map device IDs to test login credentials
-- This is just for testing - not used by the actual app
CREATE TABLE IF NOT EXISTS test_user_credentials (
  device_id TEXT PRIMARY KEY,
  test_email TEXT NOT NULL,
  test_password TEXT NOT NULL,
  user_profile TEXT NOT NULL,
  description TEXT
);

-- Insert test credentials mapping
INSERT INTO test_user_credentials (device_id, test_email, test_password, user_profile, description) VALUES
  ('device_a1b2c3d4e5f6g7h8', 'test1@gitawisdom.com', 'TestUser@2024', 'Beginner Reader', '3-day streak, 5 bookmarks, 2 chapters completed'),
  ('device_x1y2z3a4b5c6d7e8', 'test2@gitawisdom.com', 'TestUser@2024', 'Advanced Reader', '21-day streak, 25 bookmarks, 8 chapters completed'),
  ('device_m1n2o3p4q5r6s7t8', 'test3@gitawisdom.com', 'TestUser@2024', 'Casual Browser', 'Inactive 5 days, 2 bookmarks, notifications off'),
  ('device_u1v2w3x4y5z6a7b8', 'test4@gitawisdom.com', 'TestUser@2024', 'Power User', '90-day streak!, 100+ bookmarks, all chapters completed'),
  ('device_k1l2m3n4o5p6q7r8', 'test5@gitawisdom.com', 'TestUser@2024', 'New User', '1-day streak, just started, no bookmarks yet')
ON CONFLICT (device_id) DO UPDATE SET
  description = EXCLUDED.description;

-- =================================================================
-- 5. CREATE VERIFICATION VIEWS AND QUERIES
-- =================================================================

-- Create comprehensive test summary view
CREATE OR REPLACE VIEW anonymous_test_users_summary AS
SELECT 
  us.user_device_id,
  tc.test_email,
  tc.user_profile,
  us.reading_streak,
  us.total_reading_time_minutes,
  COALESCE(bookmark_counts.total_bookmarks, 0) as actual_bookmarks,
  COALESCE(progress_counts.chapters_read, 0) as chapters_with_progress,
  us.theme_preference,
  us.notification_enabled,
  us.last_read_date,
  array_length(us.achievements_unlocked, 1) as achievements_count,
  tc.description
FROM user_settings us
JOIN test_user_credentials tc ON us.user_device_id = tc.device_id
LEFT JOIN (
  SELECT user_device_id, COUNT(*) as total_bookmarks
  FROM user_bookmarks 
  GROUP BY user_device_id
) bookmark_counts ON us.user_device_id = bookmark_counts.user_device_id
LEFT JOIN (
  SELECT user_device_id, COUNT(DISTINCT chapter_id) as chapters_read
  FROM user_progress 
  WHERE progress_type = 'chapter_completed'
  GROUP BY user_device_id
) progress_counts ON us.user_device_id = progress_counts.user_device_id
ORDER BY us.reading_streak DESC;

-- Display the test users summary
SELECT 
  test_email as "Login Email",
  user_profile as "Profile Type", 
  reading_streak as "Streak",
  actual_bookmarks as "Bookmarks",
  chapters_with_progress as "Chapters",
  achievements_count as "Achievements",
  description as "Features"
FROM anonymous_test_users_summary;

-- =================================================================
-- SUCCESS MESSAGE
-- =================================================================

DO $$
BEGIN
    RAISE NOTICE '✅ Anonymous test users created successfully!';
    RAISE NOTICE '';
    RAISE NOTICE '📧 Test Login Credentials:';
    RAISE NOTICE '  test1@gitawisdom.com | TestUser@2024 | Beginner (3-day streak)';
    RAISE NOTICE '  test2@gitawisdom.com | TestUser@2024 | Advanced (21-day streak)';
    RAISE NOTICE '  test3@gitawisdom.com | TestUser@2024 | Casual (inactive)';
    RAISE NOTICE '  test4@gitawisdom.com | TestUser@2024 | Power User (90-day streak!)';
    RAISE NOTICE '  test5@gitawisdom.com | TestUser@2024 | New User (just started)';
    RAISE NOTICE '';
    RAISE NOTICE '🚀 Ready for immediate testing!';
    RAISE NOTICE '   - Data works with anonymous users (device IDs)';
    RAISE NOTICE '   - Create Supabase Auth users later with these emails';
    RAISE NOTICE '   - App will migrate data when users sign up';
END $$;