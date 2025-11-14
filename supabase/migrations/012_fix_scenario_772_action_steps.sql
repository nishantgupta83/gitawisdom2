-- Migration: Fix scenario 772 action steps - remove repetition
-- Date: 2025-11-13
-- Purpose: Update repetitive action steps to be distinct and actionable

UPDATE public.scenarios
SET sc_action_steps = jsonb_build_array(
  'Identify your top 3 spending categories by environmental impact to focus your efforts effectively',
  'Set decision rules for each category (e.g., "sustainable option if <10% more expensive") to reduce analysis paralysis',
  'Limit research time per purchase decision to 15 minutes maximum',
  'Accept that 80% sustainable choices are better than 0% perfect choices',
  'Review and refine your sustainable habits quarterly based on actual impact'
)
WHERE scenario_id = 772;

-- Verify update
SELECT
  scenario_id,
  sc_title,
  jsonb_array_length(sc_action_steps) as action_count,
  sc_action_steps
FROM public.scenarios
WHERE scenario_id = 772;
