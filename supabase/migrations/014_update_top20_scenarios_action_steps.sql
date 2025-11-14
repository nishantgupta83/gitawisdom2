-- Migration: Update top 20 scenarios with high-quality action steps
-- Date: 2025-11-13
-- Purpose: Replace repetitive action steps with specific, actionable guidance
-- Context: These 20 scenarios had the most problematic repetitive patterns

-- Run this migration AFTER 013_fix_repetitive_action_steps.sql

-- =============================================================================
-- Top 20 Scenario Updates
-- =============================================================================

-- Scenario 831: Eating Out Causes Anxiety and Isolation
UPDATE public.scenarios
SET sc_action_steps = jsonb_build_array(
  'Check restaurant menus online before accepting invitations to identify safe options that align with your dietary needs.',
  'Call the restaurant during off-peak hours to ask about ingredient lists, preparation methods, or possible accommodations.',
  'When friends plan outings, volunteer to suggest a restaurant you''ve researched, framing it as your treat or enthusiasm to share a new spot.',
  'Eat a small, satisfying snack before going out so hunger doesn''t pressure you into uncomfortable choices.',
  'Choose one menu item outside your usual comfort zone each month to gradually build confidence and reduce food-related anxiety.'
)
WHERE scenario_id = 831;

-- Scenario 836: Over-Exercising to Compensate for Food Choices
UPDATE public.scenarios
SET sc_action_steps = jsonb_build_array(
  'Design a weekly workout schedule based on fitness goals (strength, endurance, flexibility), not on what you ate.',
  'Work with a certified trainer or physiotherapist to establish appropriate exercise volume and rest days for your body type and goals.',
  'Track your energy levels, mood, and sleep quality to identify signs of overtraining like persistent fatigue or irritability.',
  'Mentally separate eating occasions from exercise by journaling three positive aspects of each meal unrelated to calories burned.',
  'Celebrate non-aesthetic fitness achievements weekly, such as running longer distances, lifting heavier weights, or improved flexibility.'
)
WHERE scenario_id = 836;

-- Scenario 832: Judging Others' Food Choices
UPDATE public.scenarios
SET sc_action_steps = jsonb_build_array(
  'Redirect your attention to your own plate whenever you notice judgment arising about someone else''s food.',
  'Refrain from commenting on portion sizes, ingredients, or nutritional value of others'' meals, even if asked for your opinion.',
  'Practice giving genuine compliments about the variety, colors, or presentation of different foods at shared meals.',
  'If hosting or organizing group meals, provide diverse options without pressuring anyone toward specific choices.',
  'Remind yourself that everyone''s relationship with food is shaped by unique health needs, cultural backgrounds, and personal preferences.'
)
WHERE scenario_id = 832;

-- Scenario 829: Travel Anxiety Around Food
UPDATE public.scenarios
SET sc_action_steps = jsonb_build_array(
  'Research your destination''s local cuisine and identify 3-5 restaurants or markets with menu options that match your dietary requirements.',
  'Pack non-perishable snacks like nuts, dried fruit, or protein bars to have familiar options during transit or between meals.',
  'Use travel apps or Google Maps to save locations of grocery stores, health food shops, or restaurants near your accommodation.',
  'Choose travel companions who respect your food needs and won''t pressure you to eat things that make you uncomfortable.',
  'Plan one meal during your trip where you intentionally try a local dish outside your routine, viewing it as part of the travel experience rather than a dietary failure.'
)
WHERE scenario_id = 829;

-- Scenario 858: Workplace Potlucks Excluding Your Cuisine
UPDATE public.scenarios
SET sc_action_steps = jsonb_build_array(
  'Bring a dish from your culture that has broad appeal, like samosas, spring rolls, or baklava, to introduce colleagues gently to new flavors.',
  'Include a small card with the dish name, key ingredients, and a one-sentence description of its cultural significance.',
  'Ask colleagues what they think after tasting, showing genuine interest in their feedback and creating conversation.',
  'Offer small portions and encourage people to try it alongside familiar foods to reduce hesitation.',
  'Rotate between traditional cultural dishes and fusion versions over different potlucks to build familiarity and appreciation gradually.'
)
WHERE scenario_id = 858;

-- Scenario 874: Body Dysmorphia Triggers from Gym Mirrors
UPDATE public.scenarios
SET sc_action_steps = jsonb_build_array(
  'Request a tour of local gyms to find one with minimal mirrors or sections where you can work out without constant reflection.',
  'Position yourself facing away from mirrors during workouts, or use equipment in corners or against walls.',
  'Shift your focus to physical sensations during exercise—muscle engagement, breathing rhythm, heart rate—rather than visual appearance.',
  'Plan outdoor workouts like hiking, cycling, or running in nature to completely remove mirror exposure while staying active.',
  'Develop a pre-workout affirmation routine focusing on what your body can do ("I am building strength," "My body supports me") rather than how it looks.'
)
WHERE scenario_id = 874;

-- Scenario 1139: Exam Pressure and Fear of Disappointing Others
UPDATE public.scenarios
SET sc_action_steps = jsonb_build_array(
  'Break study material into daily 2-hour blocks with specific topics, creating achievable goals rather than vague ''study everything'' plans.',
  'Focus on understanding core concepts through active recall and practice problems, not memorizing every detail perfectly.',
  'Schedule daily 30-minute breaks for walks, stretching, or breathing exercises to prevent burnout and maintain mental clarity.',
  'Eat balanced meals at regular times and get 7-8 hours of sleep nightly, even during exam week, to optimize cognitive performance.',
  'Write down three things within your control each morning (study time, rest, effort) and consciously release attachment to outcomes through prayer or meditation.'
)
WHERE scenario_id = 1139;

-- Scenario 676: Depression from Chronic Misunderstanding
UPDATE public.scenarios
SET sc_action_steps = jsonb_build_array(
  'Make a list of 3-5 people in your life who listen without judgment and prioritize spending time with them weekly.',
  'Set boundaries with people who consistently misunderstand or criticize you by limiting interactions to necessary occasions only.',
  'Engage in activities that give you a sense of purpose and accomplishment, like volunteering, creative projects, or skill-building hobbies.',
  'Schedule an initial appointment with a therapist or counselor who specializes in communication issues or depression to gain professional perspective.',
  'Keep a weekly achievement log where you document even small wins to counter the negative narratives others might impose on you.'
)
WHERE scenario_id = 676;

-- Scenario 682: Health Impact of Chronic Stress
UPDATE public.scenarios
SET sc_action_steps = jsonb_build_array(
  'Identify your personal stress signals (headaches, stomach issues, irritability, sleep problems) and track when they occur.',
  'Establish a daily calming routine such as 10-minute meditation, evening walks, or journaling to create consistent stress-relief anchors.',
  'Prioritize sleep hygiene by maintaining a consistent bedtime, limiting screens before sleep, and creating a dark, cool sleeping environment.',
  'Schedule a comprehensive health check-up to rule out underlying conditions and discuss stress-related symptoms with your doctor.',
  'Review your commitments monthly and actively eliminate or delegate tasks that don''t align with your core values or essential responsibilities.'
)
WHERE scenario_id = 682;

-- Scenario 805: Celebrity Endorsements Swaying Choices
UPDATE public.scenarios
SET sc_action_steps = jsonb_build_array(
  'Search for unbiased product reviews on sites like Consumer Reports, peer-reviewed studies, or independent health blogs before purchasing.',
  'Compare the price and benefits of the celebrity-endorsed product against similar alternatives to assess if it''s genuinely worth the premium.',
  'Test new products in small quantities or trial sizes before committing to expensive bulk purchases.',
  'Consult a registered dietitian or nutritionist for personalized advice rather than following generic celebrity recommendations.',
  'Remind yourself that celebrities are paid for endorsements and their success likely comes from genetics, trainers, and resources unavailable to most people.'
)
WHERE scenario_id = 805;

-- Scenario 864: Crash Dieting Before Events
UPDATE public.scenarios
SET sc_action_steps = jsonb_build_array(
  'Start preparing 3-4 months before major events by setting gradual, sustainable weekly goals like adding more vegetables or walking 30 minutes daily.',
  'Build meals around whole foods—vegetables, lean proteins, whole grains, fruits—rather than restrictive meal replacement products.',
  'Drink 8-10 glasses of water daily and limit alcohol and sugary drinks to support energy and reduce bloating.',
  'Incorporate moderate exercise 4-5 times per week, combining cardio and strength training, rather than extreme last-minute workout binges.',
  'Ignore social media promises of ''10 pounds in 10 days'' diets and focus on feeling energized and confident through consistent healthy habits.'
)
WHERE scenario_id = 864;

-- Scenario 867: Supplements Without True Need
UPDATE public.scenarios
SET sc_action_steps = jsonb_build_array(
  'Research whether the supplement has credible scientific evidence by checking sources like examine.com or consulting peer-reviewed studies.',
  'Schedule a blood test to identify any actual deficiencies (vitamin D, B12, iron) before purchasing supplements.',
  'Avoid taking multiple supplements simultaneously that may interact negatively or provide redundant nutrients.',
  'Prioritize proven essentials like vitamin D (if deficient) and omega-3s, rather than trendy or heavily marketed products.',
  'Redirect money spent on unnecessary supplements toward high-quality whole foods that provide more comprehensive nutrition.'
)
WHERE scenario_id = 867;

-- Scenario 854: Judged for Portion Sizes
UPDATE public.scenarios
SET sc_action_steps = jsonb_build_array(
  'When someone comments on your portions, respond calmly with "This is what works for my body" without further explanation or apology.',
  'Serve yourself at buffets or family meals to maintain control over your portions and avoid pressure from others.',
  'If questioned repeatedly, politely deflect with "I appreciate your concern, but I''m comfortable with my choices" and change the subject.',
  'Shift the conversation to neutral topics like upcoming plans, shared interests, or positive news to move away from food commentary.',
  'Model quiet confidence in your choices by eating mindfully and trusting your body''s hunger and fullness cues without seeking external validation.'
)
WHERE scenario_id = 854;

-- Scenario 833: Feeling Superior Over "Clean Eating"
UPDATE public.scenarios
SET sc_action_steps = jsonb_build_array(
  'When you notice judgmental thoughts about others'' food choices, pause and remind yourself that your diet is a personal preference, not a moral standard.',
  'Reframe your eating habits as a choice that works for you rather than a superior lifestyle everyone should follow.',
  'Practice refraining from giving unsolicited nutrition advice, even when asked casually, unless someone specifically requests your guidance.',
  'Ask people about their favorite foods or family recipes with genuine curiosity, focusing on enjoyment rather than nutritional value.',
  'Appreciate the diversity of food cultures and individual circumstances that shape people''s diets differently from yours.'
)
WHERE scenario_id = 833;

-- Scenario 631: Leading a Meeting for the First Time
UPDATE public.scenarios
SET sc_action_steps = jsonb_build_array(
  'Create a clear agenda 48 hours before the meeting with time allocations for each topic and specific discussion goals.',
  'Share the agenda with all participants at least 24 hours in advance so they can prepare questions or input.',
  'Use intentional pauses after asking questions to give quieter team members time to formulate and share their thoughts.',
  'Invite participants to submit written feedback or ideas via email if they''re uncomfortable speaking up during the meeting.',
  'Send a follow-up email within 24 hours summarizing key decisions, action items, and assigned owners to ensure accountability and clarity.'
)
WHERE scenario_id = 631;

-- Scenario 821: Dismissed as "Not Body Positive Enough"
UPDATE public.scenarios
SET sc_action_steps = jsonb_build_array(
  'Clearly articulate your health or fitness motivations in your bio or posts to distinguish your goals from appearance-focused messaging.',
  'Connect with online communities or local groups whose goals align with yours, such as runners, weightlifters, or wellness enthusiasts.',
  'Ignore or block trolls and negative commenters without engaging in debates that drain your energy.',
  'Track measurable health improvements like running pace, strength gains, or energy levels to reinforce your intrinsic motivation.',
  'Celebrate non-scale victories weekly, such as better sleep, improved mood, or consistent workout habits, sharing these achievements authentically.'
)
WHERE scenario_id = 821;

-- Scenario 870: Obsessive Calorie Tracking Undermines Health
UPDATE public.scenarios
SET sc_action_steps = jsonb_build_array(
  'Switch from exact calorie targets to flexible ranges (e.g., 1800-2200 calories) that allow for daily variation and reduce anxiety.',
  'Take deliberate breaks from tracking one day per week or during social events to practice intuitive eating and trust your body''s signals.',
  'Pay attention to physical hunger and fullness cues (stomach growling, energy levels, satisfaction) rather than relying solely on numbers.',
  'Shift your focus from calorie quantity to nutrient quality by prioritizing fiber, protein, vitamins, and whole foods.',
  'Regularly assess your mental well-being by asking yourself if tracking enhances or harms your relationship with food and seek professional help if it feels controlling.'
)
WHERE scenario_id = 870;

-- Scenario 820: Being Tokenised in Media Campaigns
UPDATE public.scenarios
SET sc_action_steps = jsonb_build_array(
  'Evaluate whether the campaign involves you in meaningful creative decisions or simply uses your image for diversity optics.',
  'Ask for specifics on how your community or identity will be authentically represented beyond surface-level inclusion.',
  'Politely decline roles where you''re the only representative of your identity without substantial input or fair compensation.',
  'Use your platform to amplify authentic narratives and stories that go beyond stereotypes or tokenism.',
  'Recommend other diverse creators or talent to ensure broader representation rather than concentration on a few token figures.'
)
WHERE scenario_id = 820;

-- Scenario 863: Overtraining for Aesthetic Goals
UPDATE public.scenarios
SET sc_action_steps = jsonb_build_array(
  'Shift your focus to performance-based goals like running a 5K faster, deadlifting a specific weight, or holding a plank for 2 minutes.',
  'Build mandatory rest days into your weekly schedule (at least 1-2 days) to allow muscle recovery and prevent injury.',
  'Monitor daily indicators like energy levels, soreness, sleep quality, and mood to catch early signs of overtraining.',
  'Work with a trainer who emphasizes balanced programming—strength, cardio, flexibility, and recovery—rather than aesthetics-only focus.',
  'Each week, celebrate improvements in strength, endurance, or flexibility rather than physical appearance changes.'
)
WHERE scenario_id = 863;

-- Scenario 441: Layoff Rumors Spreading in Office
UPDATE public.scenarios
SET sc_action_steps = jsonb_build_array(
  'Refuse to participate in rumor-spreading conversations; instead, redirect focus to your current work and deliverables.',
  'Document your recent achievements and contributions in a private file to reference during performance reviews or job searches.',
  'Discreetly update your resume, LinkedIn profile, and portfolio to be ready for opportunities if layoffs do occur.',
  'Attend industry networking events or reach out to former colleagues to expand your professional connections proactively.',
  'Set aside a portion of each paycheck into an emergency fund if possible, aiming for 3-6 months of living expenses as a financial buffer.'
)
WHERE scenario_id = 441;

-- =============================================================================
-- Verification
-- =============================================================================

-- Verify all 20 scenarios were updated
SELECT
  scenario_id,
  sc_title,
  jsonb_array_length(sc_action_steps) as step_count,
  LENGTH(sc_action_steps->0::text) as first_step_length,
  LENGTH(sc_action_steps->4::text) as last_step_length
FROM public.scenarios
WHERE scenario_id IN (831, 836, 832, 829, 858, 874, 1139, 676, 682, 805, 864, 867, 854, 833, 631, 821, 870, 820, 863, 441)
ORDER BY scenario_id;

-- Show sample of improved steps
SELECT
  scenario_id,
  sc_title,
  sc_action_steps->0 as step_1,
  sc_action_steps->1 as step_2
FROM public.scenarios
WHERE scenario_id IN (831, 836, 832)
ORDER BY scenario_id;

-- =============================================================================
-- Notes
-- =============================================================================

-- These action steps were manually crafted to be:
-- ✅ Specific and contextually relevant
-- ✅ Immediately actionable with clear timeframes
-- ✅ Progressive (assess → plan → act → review)
-- ✅ Varied in language and structure
-- ✅ 20-40 words per step (1-2 sentences)

-- All steps avoid:
-- ❌ "Take time to..." prefix
-- ❌ "ensuring you understand the full context" suffix
-- ❌ Generic platitudes or motivational filler
-- ❌ Vague or unmeasurable actions

-- =============================================================================
-- END OF MIGRATION
-- =============================================================================
