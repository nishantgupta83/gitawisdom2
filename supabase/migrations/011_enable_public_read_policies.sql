-- Migration: Enable Public Read Access for Content Tables
-- Date: 2025-11-13
-- Purpose: Allow anonymous users to read chapters, verses, and scenarios with anon key

-- ==================================================================
-- CHAPTERS TABLE - Enable Public Read
-- ==================================================================
ALTER TABLE public.chapters ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read chapters"
  ON public.chapters
  FOR SELECT
  TO public
  USING (true);

-- ==================================================================
-- GITA_VERSES TABLE - Enable Public Read
-- ==================================================================
ALTER TABLE public.gita_verses ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read verses"
  ON public.gita_verses
  FOR SELECT
  TO public
  USING (true);

-- ==================================================================
-- SCENARIOS TABLE - Enable Public Read
-- ==================================================================
ALTER TABLE public.scenarios ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read scenarios"
  ON public.scenarios
  FOR SELECT
  TO public
  USING (true);

-- ==================================================================
-- DAILY_QUOTE TABLE - Enable Public Read
-- ==================================================================
ALTER TABLE public.daily_quote ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read daily quotes"
  ON public.daily_quote
  FOR SELECT
  TO public
  USING (true);

-- ==================================================================
-- CHAPTER_TRANSLATIONS TABLE - Enable Public Read
-- ==================================================================
ALTER TABLE public.chapter_translations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read chapter translations"
  ON public.chapter_translations
  FOR SELECT
  TO public
  USING (true);

-- ==================================================================
-- VERSE_TRANSLATIONS TABLE - Enable Public Read
-- ==================================================================
ALTER TABLE public.verse_translations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read verse translations"
  ON public.verse_translations
  FOR SELECT
  TO public
  USING (true);

-- ==================================================================
-- SCENARIO_TRANSLATIONS TABLE - Enable Public Read
-- ==================================================================
ALTER TABLE public.scenario_translations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read scenario translations"
  ON public.scenario_translations
  FOR SELECT
  TO public
  USING (true);
