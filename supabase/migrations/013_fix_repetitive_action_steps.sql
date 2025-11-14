-- Migration: Fix repetitive action steps across all scenarios
-- Date: 2025-11-13
-- Purpose: Remove generic "Take time to" prefix and "ensuring you understand the full context and implications" suffix
-- Context: 100+ scenarios have repetitive patterns that reduce actionability and specificity

-- =============================================================================
-- STEP 1: Clean up repetitive prefixes and suffixes
-- =============================================================================

-- This update:
-- 1. Removes "Take time to " prefix (case-insensitive)
-- 2. Removes ", ensuring you understand the full context and implications" suffix
-- 3. Capitalizes the first letter after prefix removal
-- 4. Preserves the cleaned text in each action step

UPDATE public.scenarios
SET sc_action_steps = (
  SELECT jsonb_agg(
    -- Remove prefix and suffix, then capitalize first letter
    CASE
      -- If step starts with "Take time to " (case-insensitive)
      WHEN LOWER(step_text::text) LIKE '"take time to %' THEN
        -- Remove prefix, suffix, capitalize first letter
        to_jsonb(
          UPPER(SUBSTRING(
            REGEXP_REPLACE(
              REGEXP_REPLACE(
                step_text::text,
                '^"[Tt]ake time to ',
                '"',
                'g'
              ),
              ', ensuring you understand the full context and implications"$',
              '"',
              'i'
            ),
            2,
            1
          )) ||
          SUBSTRING(
            REGEXP_REPLACE(
              REGEXP_REPLACE(
                step_text::text,
                '^"[Tt]ake time to ',
                '"',
                'g'
              ),
              ', ensuring you understand the full context and implications"$',
              '"',
              'i'
            ),
            3
          )
        )
      -- If step only has suffix but no prefix
      WHEN step_text::text LIKE '%ensuring you understand the full context and implications"' THEN
        to_jsonb(
          REGEXP_REPLACE(
            step_text::text,
            ', ensuring you understand the full context and implications"$',
            '"',
            'i'
          )
        )
      -- Otherwise keep as is
      ELSE step_text
    END
    ORDER BY step_index
  )
  FROM (
    SELECT
      step_text,
      ordinality - 1 as step_index
    FROM jsonb_array_elements(sc_action_steps) WITH ORDINALITY AS step_text
  ) AS steps
)
WHERE sc_action_steps IS NOT NULL
  AND (
    -- Only update rows that have the repetitive pattern
    EXISTS (
      SELECT 1
      FROM jsonb_array_elements_text(sc_action_steps) AS step
      WHERE LOWER(step) LIKE 'take time to %'
         OR step LIKE '%ensuring you understand the full context and implications'
    )
  );

-- =============================================================================
-- STEP 2: Fix specific malformed scenarios identified in quality report
-- =============================================================================

-- Scenario 1139: Exam Pressure - has fragmented steps
UPDATE public.scenarios
SET sc_action_steps = jsonb_build_array(
  'Create a realistic study plan breaking material into daily 2-hour blocks with specific topics to reduce overwhelm.',
  'Focus on understanding core concepts through active recall and practice problems rather than memorizing every detail.',
  'Practice self-care through adequate rest, balanced meals at regular times, and 7-8 hours of sleep nightly.',
  'Schedule daily 30-minute breaks for walks, stretching, or breathing exercises to prevent burnout and maintain clarity.',
  'Write down three things within your control each morning (study time, rest, effort) and release attachment to outcomes through prayer or meditation.'
)
WHERE scenario_id = 1139;

-- =============================================================================
-- STEP 3: Verification queries
-- =============================================================================

-- Count scenarios affected by the bulk update
SELECT
  COUNT(*) as scenarios_cleaned,
  COUNT(CASE WHEN jsonb_array_length(sc_action_steps) = 5 THEN 1 END) as has_five_steps,
  COUNT(CASE WHEN jsonb_array_length(sc_action_steps) < 5 THEN 1 END) as has_fewer_steps,
  COUNT(CASE WHEN jsonb_array_length(sc_action_steps) > 5 THEN 1 END) as has_more_steps
FROM public.scenarios
WHERE sc_action_steps IS NOT NULL;

-- Sample check: Show random 5 scenarios to verify cleanup
SELECT
  scenario_id,
  sc_title,
  jsonb_array_length(sc_action_steps) as step_count,
  sc_action_steps->0 as first_step,
  sc_action_steps->4 as last_step
FROM public.scenarios
WHERE sc_action_steps IS NOT NULL
ORDER BY RANDOM()
LIMIT 5;

-- Check for remaining repetitive patterns (should return 0 after cleanup)
SELECT
  scenario_id,
  sc_title,
  step_index,
  step_text
FROM public.scenarios,
  jsonb_array_elements_text(sc_action_steps) WITH ORDINALITY AS arr(step_text, step_index)
WHERE LOWER(step_text) LIKE 'take time to %'
   OR step_text LIKE '%ensuring you understand the full context and implications'
ORDER BY scenario_id, step_index;

-- =============================================================================
-- STEP 4: Quality validation
-- =============================================================================

-- Identify scenarios with very short action steps (potential fragments)
SELECT
  scenario_id,
  sc_title,
  step_index,
  step_text,
  LENGTH(step_text) as char_length
FROM public.scenarios,
  jsonb_array_elements_text(sc_action_steps) WITH ORDINALITY AS arr(step_text, step_index)
WHERE LENGTH(step_text) < 20
ORDER BY char_length, scenario_id;

-- Identify scenarios with incomplete action steps (ending with incomplete markers)
SELECT
  scenario_id,
  sc_title,
  step_index,
  step_text
FROM public.scenarios,
  jsonb_array_elements_text(sc_action_steps) WITH ORDINALITY AS arr(step_text, step_index)
WHERE step_text ~ '(etc\.|etc|\.{3}|\.\.)$'
ORDER BY scenario_id, step_index;

-- =============================================================================
-- ROLLBACK PLAN
-- =============================================================================

-- If needed, rollback can be done by restoring from backup or re-running original migration
-- BACKUP COMMAND (run BEFORE this migration):
-- CREATE TABLE scenarios_backup_20251113 AS SELECT * FROM public.scenarios;

-- ROLLBACK COMMAND (if needed):
-- UPDATE public.scenarios
-- SET sc_action_steps = scenarios_backup_20251113.sc_action_steps
-- FROM scenarios_backup_20251113
-- WHERE scenarios.scenario_id = scenarios_backup_20251113.scenario_id;

-- =============================================================================
-- NOTES
-- =============================================================================

-- This migration cleans up systemic repetitive patterns but does NOT:
-- 1. Regenerate entirely new action steps (that requires AI/manual effort)
-- 2. Fix semantic issues (vague or generic advice)
-- 3. Add missing context or specificity

-- For comprehensive action step improvements, see:
-- - /gita_scholar_agent/output/top20_improved_action_steps.json (high-quality examples)
-- - /gita_scholar_agent/output/AI_PROMPT_TEMPLATE_ACTION_STEPS.md (generation template)
-- - /gita_scholar_agent/scenario_quality_checker.py (quality audit tool)

-- After this migration, consider:
-- 1. Running scenario_quality_checker.py to verify improvements
-- 2. Manually updating high-priority scenarios with improved steps
-- 3. Using the AI prompt template for generating new scenarios

-- =============================================================================
-- END OF MIGRATION
-- =============================================================================
