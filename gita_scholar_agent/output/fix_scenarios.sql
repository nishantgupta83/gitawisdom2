-- ============================================================================
-- SCENARIO QUALITY FIX SQL STATEMENTS
-- ============================================================================
-- Generated: 2025-10-13 22:44:41
-- Purpose: Fix fragmented sc_action_steps in scenarios table
-- Issues Fixed: Unbalanced parentheses, fragmented steps, incomplete sentences
--
-- IMPORTANT: Review each UPDATE statement before executing!
-- ============================================================================

BEGIN;

-- Fix: Being Told You're 'Too Sensitive'
-- Scenario ID: c1d1fd47-ae94-4bd2-99df-4bdc54998abf
-- Fixed steps: 4
UPDATE scenarios
SET sc_action_steps = ARRAY['Acknowledge your emotions as valid signals, not flaws', 'Set gentle boundaries without apology', 'Engage in practices that channel your emotions—like journaling or art', 'Connect with others who value emotional awareness'],
    updated_at = NOW()
WHERE id = 'c1d1fd47-ae94-4bd2-99df-4bdc54998abf';

-- Fix: Debilitating Exam Failure Anxiety
-- Scenario ID: f0bdf74c-0e24-4e0b-9006-c07777d59014
-- Fixed steps: 4
UPDATE scenarios
SET sc_action_steps = ARRAY['Revise with focused effort and avoid comparison', 'Prioritize rest and clarity over cramming', 'Reflect on what''s in your control (study, mindset)', 'Surrender anxiety through prayer or meditation'],
    updated_at = NOW()
WHERE id = 'f0bdf74c-0e24-4e0b-9006-c07777d59014';

-- Fix: Struggling with Self-Harm Thoughts
-- Scenario ID: 843ff513-7ae4-4a26-9d95-39f24db56bfa
-- Fixed steps: 5
UPDATE scenarios
SET sc_action_steps = ARRAY['Talk to a counselor, teacher, or loved one immediately', 'Create a safety plan and distraction list', 'Remember that emotions change—this moment will pass', 'Engage in activities that uplift your spirit', 'even if slowly'],
    updated_at = NOW()
WHERE id = '843ff513-7ae4-4a26-9d95-39f24db56bfa';

-- Fix: Social Media Comparison and Validation Seeking
-- Scenario ID: 353ff17d-4c05-4fab-ba8a-71cccfa28e7f
-- Fixed steps: 4
UPDATE scenarios
SET sc_action_steps = ARRAY['Limit social media use with clear time boundaries.', 'Reflect on your inner qualities and growth.', 'Celebrate others without comparing yourself.', 'Practice silence, journaling, or meditation daily.'],
    updated_at = NOW()
WHERE id = '353ff17d-4c05-4fab-ba8a-71cccfa28e7f';

-- Fix: Logistics of Managing Two Toddlers
-- Scenario ID: 6894a94a-6759-4aea-a02e-95d93b14dab0
-- Fixed steps: 5
UPDATE scenarios
SET sc_action_steps = ARRAY['Prepare as much as possible the night before outings', 'Use tools like double strollers, shopping cart covers, etc.', 'Lower your expectations for speed and efficiency', 'Accept help from strangers when offered', 'Plan shorter trips and have realistic timelines'],
    updated_at = NOW()
WHERE id = '6894a94a-6759-4aea-a02e-95d93b14dab0';

-- Fix: Exam Pressure and Fear of Disappointing Others
-- Scenario ID: c2027e66-bfdc-4c85-a06a-48066e34a2d3
-- Fixed steps: 4
UPDATE scenarios
SET sc_action_steps = ARRAY['Create a realistic study plan to reduce overwhelm.', 'Focus on learning, not perfection.', 'Practice self-care through rest, food, and faith.', 'Surrender anxiety through prayer or breathing exercises.'],
    updated_at = NOW()
WHERE id = 'c2027e66-bfdc-4c85-a06a-48066e34a2d3';

-- Fix: Developing Underperforming Team Member
-- Scenario ID: 16afa435-374f-43fe-9e76-8e237bc3bf7e
-- Fixed steps: 4
UPDATE scenarios
SET sc_action_steps = ARRAY['Identify specific skills gaps and create a development plan', 'Provide mentoring, training, and regular feedback', 'Set clear milestones and timelines for improvement', 'Balance support for their growth with fairness to other team members'],
    updated_at = NOW()
WHERE id = '16afa435-374f-43fe-9e76-8e237bc3bf7e';

-- Fix: Child with Learning Differences
-- Scenario ID: 3f5eddb5-384e-4868-8c4f-956700424037
-- Fixed steps: 4
UPDATE scenarios
SET sc_action_steps = ARRAY['Use learning tools suited to your style', 'Celebrate your strengths (creativity, kindness, etc.)', 'Talk openly with parents and teachers', 'Remember that your path is divine too'],
    updated_at = NOW()
WHERE id = '3f5eddb5-384e-4868-8c4f-956700424037';

-- Fix: Cyberbullying and Identity Crisis
-- Scenario ID: 67f27ac6-00a3-44c3-ba97-02b29be3912f
-- Fixed steps: 4
UPDATE scenarios
SET sc_action_steps = ARRAY['Limit time on toxic platforms and report abusive behavior', 'Spend time with friends and communities that affirm your worth', 'Reflect daily on your deeper identity beyond appearances', 'Seek support from parents, counselors, or spiritual mentors'],
    updated_at = NOW()
WHERE id = '67f27ac6-00a3-44c3-ba97-02b29be3912f';

-- Fix: Child Grieving Grandparent's Death
-- Scenario ID: 77933762-6eaa-4d43-bba0-7e6fc8e58cc1
-- Fixed steps: 4
UPDATE scenarios
SET sc_action_steps = ARRAY['Talk to parents or elders about what happened', 'Create art, prayers, or memories to honor them', 'Ask spiritual questions when you''re ready', 'Feel your sadness without shame'],
    updated_at = NOW()
WHERE id = '77933762-6eaa-4d43-bba0-7e6fc8e58cc1';

-- Fix: Managing Anxiety About Team Performance Results
-- Scenario ID: 65f52ff3-82b0-4509-9f25-31d304d555aa
-- Fixed steps: 4
UPDATE scenarios
SET sc_action_steps = ARRAY['Define excellent process and effort rather than just focusing on results', 'Trust your team''s capabilities and avoid micromanaging from anxiety', 'Focus on what you can control: preparation, support, and quality of action', 'Practice surrendering results while maintaining full commitment to excellence'],
    updated_at = NOW()
WHERE id = '65f52ff3-82b0-4509-9f25-31d304d555aa';

-- Fix: Different Spiritual Paths Creating Family Tension
-- Scenario ID: 706aab64-6929-43ec-829b-8a38c3021927
-- Fixed steps: 4
UPDATE scenarios
SET sc_action_steps = ARRAY['Focus on shared spiritual values like love, compassion, and service', 'Create inclusive practices that honor different traditions', 'Educate family members about the universality of spiritual truth', 'Demonstrate through example that different paths can coexist harmoniously'],
    updated_at = NOW()
WHERE id = '706aab64-6929-43ec-829b-8a38c3021927';

-- Fix: Letting Go of Control Over Critical Project
-- Scenario ID: f93d4527-0a77-43c4-b0be-2eb4cf18a60c
-- Fixed steps: 4
UPDATE scenarios
SET sc_action_steps = ARRAY['Clearly communicate expectations, deadlines, and success criteria', 'Provide necessary resources and access to information', 'Schedule regular check-ins without micromanaging daily activities', 'Focus on developing their capabilities rather than controlling their methods'],
    updated_at = NOW()
WHERE id = 'f93d4527-0a77-43c4-b0be-2eb4cf18a60c';

-- Fix: Dealing with Pet Loss as a Child
-- Scenario ID: 26a6861a-70f2-4274-ac30-5eb6164f30d5
-- Fixed steps: 4
UPDATE scenarios
SET sc_action_steps = ARRAY['Encourage the child to express feelings through art, writing, or talking', 'Reassure them that the pet''s soul continues its journey', 'Share simple verses or stories from the Gita about life and death', 'Create a remembrance ritual to honor the pet''s life'],
    updated_at = NOW()
WHERE id = '26a6861a-70f2-4274-ac30-5eb6164f30d5';

-- Fix: Interfaith Marriage Creating Family Tension
-- Scenario ID: ba759226-a808-47e9-b791-a9c8072a6135
-- Fixed steps: 4
UPDATE scenarios
SET sc_action_steps = ARRAY['Focus on shared spiritual values like love, compassion, and service', 'Create inclusive practices that honor the essence of both traditions', 'Educate family members about the universal principles underlying all religions', 'Demonstrate through your relationship that different faiths can coexist harmoniously'],
    updated_at = NOW()
WHERE id = 'ba759226-a808-47e9-b791-a9c8072a6135';


COMMIT;

-- ============================================================================
-- END OF FIX STATEMENTS
-- ============================================================================
-- Successfully generated 15 UPDATE statements
-- Scenarios fixed: 15 out of 15
-- Review the fix_scenarios_report.txt file for before/after comparison
-- ============================================================================
