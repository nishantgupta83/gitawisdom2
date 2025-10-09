-- Migration: Fix RLS Policies for User Data Security
-- Date: 2025-10-07
-- Purpose: Prevent users from accessing each other's journal entries, bookmarks, progress, and settings
-- CRITICAL SECURITY FIX: Current USING(true) policies allow anyone to access anyone's data

-- ==================================================================
-- JOURNAL ENTRIES - Fix RLS Policies
-- ==================================================================

-- Drop insecure policies
DROP POLICY IF EXISTS "Users can access their own journal entries" ON public.journal_entries;
DROP POLICY IF EXISTS "Anonymous users can access their own journal entries" ON public.journal_entries;

-- Create secure policies for authenticated users
CREATE POLICY "Authenticated users can manage their own journal entries"
  ON public.journal_entries
  FOR ALL
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Create secure policies for anonymous users (using device_id)
-- Note: device_id must be set in request context via set_config
CREATE POLICY "Anonymous users can manage their own journal entries"
  ON public.journal_entries
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

-- ==================================================================
-- USER BOOKMARKS - Fix RLS Policies
-- ==================================================================

-- Drop insecure policies
DROP POLICY IF EXISTS "Users can access their own bookmarks" ON public.user_bookmarks;
DROP POLICY IF EXISTS "Anonymous users can access their own bookmarks" ON public.user_bookmarks;

-- Create secure policies for authenticated users
CREATE POLICY "Authenticated users can manage their own bookmarks"
  ON public.user_bookmarks
  FOR ALL
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Create secure policies for anonymous users
CREATE POLICY "Anonymous users can manage their own bookmarks"
  ON public.user_bookmarks
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

-- ==================================================================
-- USER PROGRESS - Fix RLS Policies
-- ==================================================================

-- Drop insecure policies
DROP POLICY IF EXISTS "Users can access their own progress" ON public.user_progress;
DROP POLICY IF EXISTS "Anonymous users can access their own progress" ON public.user_progress;

-- Create secure policies for authenticated users
CREATE POLICY "Authenticated users can manage their own progress"
  ON public.user_progress
  FOR ALL
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Create secure policies for anonymous users
CREATE POLICY "Anonymous users can manage their own progress"
  ON public.user_progress
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

-- ==================================================================
-- USER SETTINGS - Fix RLS Policies
-- ==================================================================

-- Drop insecure policies
DROP POLICY IF EXISTS "Users can access their own settings" ON public.user_settings;
DROP POLICY IF EXISTS "Anonymous users can access their own settings" ON public.user_settings;

-- Create secure policies for authenticated users
CREATE POLICY "Authenticated users can manage their own settings"
  ON public.user_settings
  FOR ALL
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Create secure policies for anonymous users
CREATE POLICY "Anonymous users can manage their own settings"
  ON public.user_settings
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

-- ==================================================================
-- VERIFICATION QUERIES
-- ==================================================================
-- Run these after migration to verify policies are working:

-- Test 1: Authenticated user can only see their own journal entries
-- SELECT * FROM journal_entries;  -- Should only return entries for current user

-- Test 2: Check policy definitions
-- SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
-- FROM pg_policies
-- WHERE tablename IN ('journal_entries', 'user_bookmarks', 'user_progress', 'user_settings')
-- ORDER BY tablename, policyname;

-- Test 3: Verify RLS is enabled
-- SELECT tablename, rowsecurity
-- FROM pg_tables
-- WHERE schemaname = 'public'
--   AND tablename IN ('journal_entries', 'user_bookmarks', 'user_progress', 'user_settings');
