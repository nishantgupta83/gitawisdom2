-- ============================================================================
-- TEST QUERY: Single Scenario Update to Verify Syntax
-- ============================================================================
-- Run this FIRST to verify the text[] array syntax works correctly
-- If this succeeds, you can run the full CONVERSATIONAL_UPDATE_FIXED.sql
-- ============================================================================

BEGIN;

-- Test with Scenario 448: Overworking to Prove Worth in Recession
UPDATE scenarios
SET sc_action_steps = ARRAY[
  'Schedule a conversation with your manager to honestly discuss what''s realistic given your capacity, focusing on high-impact work rather than just being visible',
  'Identify the 2-3 projects that truly matter most for the company''s survival and put your energy there instead of trying to do everything',
  'Block off at least one evening per week and one weekend day as non-negotiable rest time, even when anxiety tells you to keep working',
  'Track your actual productivity over a few weeks to see if the extra hours are genuinely improving your output or just burning you out',
  'Notice physical signs like sleep trouble, irritability, or constant exhaustion as early warnings that it''s time to pull back before you crash'
]
WHERE scenario_id = 448;

COMMIT;

-- ============================================================================
-- VERIFY: Run this query after to check it worked
-- ============================================================================
-- SELECT scenario_id, sc_title, sc_action_steps
-- FROM scenarios
-- WHERE scenario_id = 448;
