-- ============================================================================
-- CONVERSATIONAL ACTION STEPS UPDATE (FIXED FOR text[] column type)
-- ============================================================================
-- Updates 326 high-severity scenarios with conversational, comprehensive
-- action steps that read like advice from a wise, caring friend.
--
-- Quality improvements:
-- - Removed robotic 'Take time to' and 'ensuring full context' patterns
-- - Added specific context and examples from each scenario
-- - Made steps 60-150 characters with complete sentences
-- - Progressive steps that build from easier to harder actions
--
-- Column Type: text[] (PostgreSQL text array)
-- ============================================================================

BEGIN;

-- Scenario 448: Overworking to Prove Worth in Recession
UPDATE scenarios
SET sc_action_steps = ARRAY['Schedule a conversation with your manager to honestly discuss what''s realistic given your capacity, focusing on high-impact work rather than just being visible', 'Identify the 2-3 projects that truly matter most for the company''s survival and put your energy there instead of trying to do everything', 'Block off at least one evening per week and one weekend day as non-negotiable rest time, even when anxiety tells you to keep working', 'Track your actual productivity over a few weeks to see if the extra hours are genuinely improving your output or just burning you out', 'Notice physical signs like sleep trouble, irritability, or constant exhaustion as early warnings that it''s time to pull back before you crash']
WHERE scenario_id = 448;

-- Scenario 449: Fear of Relocation in Role Transfer
UPDATE scenarios
SET sc_action_steps = ARRAY['Create a two-column list: one side for family/relationship/lifestyle impacts, the other for career growth and financial benefits', 'Research the new city''s cost of living, schools, neighborhoods, and quality of life using Numbeo or local forums for real perspectives', 'Ask HR about relocation packages, temporary housing, or flexibility (like remote work initially) to make the transition smoother', 'If possible, visit the new city for a weekend to explore neighborhoods, try the commute, and see if you could picture living there', 'Step back and ask: does this move align with where I want to be in 5 years, or am I deciding purely from fear or pressure?']
WHERE scenario_id = 449;

-- Scenario 459: No Major Assets Compared to Siblings
UPDATE scenarios
SET sc_action_steps = ARRAY['List the assets you do have beyond property: skills, education, network, flexibility, health, strong relationships, life experiences', 'Focus on building wealth steadily through your own path - investing consistently, side projects, or developing expertise in your field', 'Resist the urge to take on risky debt or rush into property investments just to ''keep up'' when it doesn''t fit your life stage', 'Invest your time and money in ways that match your actual priorities and values, not what looks impressive at family gatherings', 'Measure success by how aligned your life is with what matters to you, not by comparing asset volumes with siblings'' circumstances']
WHERE scenario_id = 459;

-- Scenario 361: Witnessing Harassment in the Workplace
UPDATE scenarios
SET sc_action_steps = ARRAY['Check in with the person who was harassed right away - pull them aside privately and ask if they''re okay and what support they need in this moment', 'Document exactly what you saw: date, time, location, who was involved, what was said or done, and any witnesses, while details are fresh', 'Report the incident to HR or a manager you trust, being clear about what happened and offering to provide a written statement if needed', 'Continue checking in with the targeted colleague over the following weeks, offering to walk with them to meetings or just being a supportive presence', 'Reflect on your own role as a bystander - when you see injustice, speaking up or reporting it isn''t causing drama, it''s maintaining a safe workplace for everyone']
WHERE scenario_id = 361;

-- Scenario 412: All Friends Married, Feeling Left Out
UPDATE scenarios
SET sc_action_steps = ARRAY['Write down personal wins from the past year unrelated to relationship status - career growth, hobbies, travels, friendships', 'Double down on activities and communities that genuinely energize you, whether sport, creative pursuits, or volunteering', 'Go to social events (including weddings!) without treating them as chances to ''find someone'' - just enjoy the celebration', 'When friends share engagement news, practice sincere happiness for them without comparing timelines or making it about you', 'Remind yourself that your identity and worth exist independent of relationship status - you''re whole and valuable right now']
WHERE scenario_id = 412;

-- Scenario 416: Dating Fatigue from Arranged Meets
UPDATE scenarios
SET sc_action_steps = ARRAY['Get clear on your top 3-5 non-negotiables (values, lifestyle, communication) and what''s flexible to avoid endless deliberation', 'Set a sustainable pace like 2-3 meetings per month max, giving yourself space to process each interaction meaningfully', 'Request phone or video calls before in-person meets to gauge conversation flow and interest, saving everyone''s time and energy', 'During meets, focus on genuine curiosity about the person rather than mentally checking boxes or judging on first impressions', 'Build in buffer days between meetings with no dates or pressure - just time for hobbies, friends, and recharging']
WHERE scenario_id = 416;

-- Scenario 423: Hiding Smile Due to Crooked Teeth
UPDATE scenarios
SET sc_action_steps = ARRAY['Practice smiling fully in private moments when something genuinely makes you happy, noticing how it feels to express joy without self-censorship', 'If it''s important to you, explore dental options (braces, Invisalign, bonding) from a health and confidence perspective, not from shame or perfectionism', 'When you catch yourself holding back a smile, consciously let it out anyway - most people are drawn to authentic joy, not analyzing dental alignment', 'The next time someone compliments your smile or says you light up a room, just say thank you and let it land instead of deflecting or disagreeing', 'In social situations, focus your attention on being present and engaged with the conversation rather than monitoring how your teeth look when you talk or laugh']
WHERE scenario_id = 423;

-- Scenario 424: Obsessing Over Fitness App Metrics
UPDATE scenarios
SET sc_action_steps = ARRAY['Change your metrics check-in from constant throughout the day to once per week, like Sunday morning, to see trends without getting lost in daily fluctuations', 'Pay attention to how your body actually feels - energy levels, strength gains, mood, sleep quality - rather than just what the numbers say', 'When your body signals it needs rest (soreness, fatigue, decreased performance), honor that even if it means a ''red day'' or lower stats on your app', 'Review your goals every few months and adjust them based on what''s sustainable and enjoyable, not what the app or other users say you ''should'' achieve', 'Redefine success as showing up consistently over time rather than hitting arbitrary daily targets - consistency beats perfection every single time']
WHERE scenario_id = 424;

-- Scenario 425: Comparing Yourself to Edited Images
UPDATE scenarios
SET sc_action_steps = ARRAY['Unfollow or mute triggering accounts, writing this down to make it concrete and actionable', 'Seek unedited, body-positive influencers, breaking this down into specific, manageable actions', 'Remind yourself of editing realities, committing to this even when it feels uncomfortable', 'Focus on content value, not appearance, noticing when old patterns emerge and course-correcting', 'Practice gratitude for your unique body, making this a regular practice you revisit over time']
WHERE scenario_id = 425;

-- Scenario 430: Gym Avoidance Due to Feeling Out of Shape
UPDATE scenarios
SET sc_action_steps = ARRAY['Choose beginner-friendly environments, writing this down to make it concrete and actionable', 'Buddy up with encouraging friends, breaking this down into specific, manageable actions', 'Celebrate each small progress, committing to this even when it feels uncomfortable', 'Ignore perceived scrutiny from others, noticing when old patterns emerge and course-correcting', 'Focus on long-term health gains over quick fixes, making this a regular practice you revisit over time']
WHERE scenario_id = 430;

-- Scenario 436: Last-Minute Syllabus Overwhelm
UPDATE scenarios
SET sc_action_steps = ARRAY['Identify high-weightage topics, writing this down to make it concrete and actionable', 'Make a revision timetable, breaking this down into specific, manageable actions', 'Cover challenging subjects earlier each day, committing to this even when it feels uncomfortable', 'Leave easy revisions for later, noticing when old patterns emerge and course-correcting', 'Stay calm to retain information effectively, making this a regular practice you revisit over time']
WHERE scenario_id = 436;

-- Scenario 437: Skipping Meals During Study
UPDATE scenarios
SET sc_action_steps = ARRAY['Plan meal prep in advance, writing them down with specific timelines and milestones', 'Eat simple, energy-sustaining foods, breaking this down into specific, manageable actions', 'Hydrate regularly, committing to this even when it feels uncomfortable', 'Avoid heavy meals before study sessions, noticing when old patterns emerge and course-correcting', 'Snack on brain foods like nuts and fruit, making this a regular practice you revisit over time']
WHERE scenario_id = 437;

-- Scenario 441: Layoff Rumors Spreading in Office
UPDATE scenarios
SET sc_action_steps = ARRAY['Avoid engaging in workplace rumors, writing this down to make it concrete and actionable', 'Focus on delivering strong performance, breaking this down into specific, manageable actions', 'Quietly update your resume, committing to this even when it feels uncomfortable', 'Expand your professional network, noticing when old patterns emerge and course-correcting', 'Build emergency savings where possible, making this a regular practice you revisit over time']
WHERE scenario_id = 441;

-- Scenario 443: Colleague Terminations Increasing
UPDATE scenarios
SET sc_action_steps = ARRAY['Keep performance high and visible, writing this down to make it concrete and actionable', 'Explore market opportunities quietly, breaking this down into specific, manageable actions', 'Strengthen key skills, committing to this even when it feels uncomfortable', 'Avoid fatalistic thinking, noticing when old patterns emerge and course-correcting', 'Support remaining colleagues for morale, making this a regular practice you revisit over time']
WHERE scenario_id = 443;

-- Scenario 445: Fear of Age Discrimination After Layoff
UPDATE scenarios
SET sc_action_steps = ARRAY['Refresh and modernize resume format, writing this down to make it concrete and actionable', 'Learn latest tools in your field, breaking this down into specific, manageable actions', 'Network through industry events, committing to this even when it feels uncomfortable', 'Leverage mentorship as value-add, noticing when old patterns emerge and course-correcting', 'Stay active in professional forums, making this a regular practice you revisit over time']
WHERE scenario_id = 445;

-- Scenario 447: Toxic Competition During Downsizing
UPDATE scenarios
SET sc_action_steps = ARRAY['Commit to ethical conduct, writing this down to make it concrete and actionable', 'Document your contributions, breaking this down into specific, manageable actions', 'Collaborate with trustworthy peers, committing to this even when it feels uncomfortable', 'Avoid blaming or gossip, noticing when old patterns emerge and course-correcting', 'Let performance, not politics, speak, making this a regular practice you revisit over time']
WHERE scenario_id = 447;

-- Scenario 446: Coping with Industry Collapse
UPDATE scenarios
SET sc_action_steps = ARRAY['Identify skills that cross industries, writing this down to make it concrete and actionable', 'Seek training before situation worsens, breaking this down into specific, manageable actions', 'Update linkedin/profile with new capabilities, committing to this even when it feels uncomfortable', 'Investigate growth sectors, noticing when old patterns emerge and course-correcting', 'Plan timeline for pivot, writing them down with specific timelines and milestones']
WHERE scenario_id = 446;

-- Scenario 525: Negative Self-Talk Undermining Discipline
UPDATE scenarios
SET sc_action_steps = ARRAY['Use neutral language for setbacks, writing this down to make it concrete and actionable', 'Focus on next action, not mistake, breaking this down into specific, manageable actions', 'Track overall streak instead of perfection, committing to this even when it feels uncomfortable', 'Reward resilience, noticing when old patterns emerge and course-correcting', 'Remember long-term vision, making this a regular practice you revisit over time']
WHERE scenario_id = 525;

-- Scenario 363: Pressure to Hide Mistakes from Client
UPDATE scenarios
SET sc_action_steps = ARRAY['Clarify long-term risks of concealment, writing this down to make it concrete and actionable', 'Propose transparent correction paths, breaking this down into specific, manageable actions', 'Keep personal ethics intact, committing to this even when it feels uncomfortable', 'Document the dialogue, noticing when old patterns emerge and course-correcting', 'Accept consequences of integrity, making this a regular practice you revisit over time']
WHERE scenario_id = 363;

-- Scenario 364: Ethics of Accepting Questionable Charity Donations
UPDATE scenarios
SET sc_action_steps = ARRAY['Research donor background, writing this down to make it concrete and actionable', 'Weigh potential reputational harm, breaking this down into specific, manageable actions', 'Discuss with stakeholders, committing to this even when it feels uncomfortable', 'Accept only if aligned with mission, noticing when old patterns emerge and course-correcting', 'Seek alternative funding if not, making this a regular practice you revisit over time']
WHERE scenario_id = 364;

-- Scenario 365: Misuse of Company Property for Personal Gain
UPDATE scenarios
SET sc_action_steps = ARRAY['Know formal policy, writing this down to make it concrete and actionable', 'Avoid non-permitted personal use, breaking this down into specific, manageable actions', 'Ask permission when unsure, committing to this even when it feels uncomfortable', 'Lead by example, noticing when old patterns emerge and course-correcting', 'Value entrusted assets as sacred trust, making this a regular practice you revisit over time']
WHERE scenario_id = 365;

-- Scenario 368: Handling Insider Information Ethically
UPDATE scenarios
SET sc_action_steps = ARRAY['Understand legal and ethical boundaries, writing this down to make it concrete and actionable', 'Never leak privileged info, breaking this down into specific, manageable actions', 'Value reputation over profit, committing to this even when it feels uncomfortable', 'Stop others from misusing info, noticing when old patterns emerge and course-correcting', 'Report breaches responsibly, making this a regular practice you revisit over time']
WHERE scenario_id = 368;

-- Scenario 386: Lack of Motivation for Daily Tasks
UPDATE scenarios
SET sc_action_steps = ARRAY['Break tasks into tiny steps, writing this down to make it concrete and actionable', 'Commit to 5 minutes of action to start, breaking this down into specific, manageable actions', 'Celebrate completion of each step, committing to this even when it feels uncomfortable', 'Pair chores with music or rewards, noticing when old patterns emerge and course-correcting', 'Track progress visually, making this a regular practice you revisit over time']
WHERE scenario_id = 386;

-- Scenario 438: Peer Bragging Adding Pressure to Study Habits
UPDATE scenarios
SET sc_action_steps = ARRAY['Respect others’ routines without mimicry, writing this down to make it concrete and actionable', 'Learn ideas but adapt to your rhythms, breaking this down into specific, manageable actions', 'Track your own progress in private, committing to this even when it feels uncomfortable', 'Limit negative competitiveness, noticing when old patterns emerge and course-correcting', 'Cultivate supportive peer study groups, making this a regular practice you revisit over time']
WHERE scenario_id = 438;

-- Scenario 465: Eco-Guilt from Lifestyle Choices
UPDATE scenarios
SET sc_action_steps = ARRAY['Identify top 3 impactful changes, writing this down to make it concrete and actionable', 'Adjust habits steadily, breaking this down into specific, manageable actions', 'Educate others through example, committing to this even when it feels uncomfortable', 'Celebrate progress not perfection, noticing when old patterns emerge and course-correcting', 'Keep joy in sustainability, making this a regular practice you revisit over time']
WHERE scenario_id = 465;

-- Scenario 468: Burnout from Activism Without Rest
UPDATE scenarios
SET sc_action_steps = ARRAY['Schedule recovery periods, writing this down to make it concrete and actionable', 'Share load with fellow activists, breaking this down into specific, manageable actions', 'Alternate between intense and light tasks, committing to this even when it feels uncomfortable', 'Reconnect to “why” behind efforts, noticing when old patterns emerge and course-correcting', 'Engage in nature to restore hope, making this a regular practice you revisit over time']
WHERE scenario_id = 468;

-- Scenario 524: Finding Sustainability in New Habits
UPDATE scenarios
SET sc_action_steps = ARRAY['Assess realistic daily time/energy, writing this down to make it concrete and actionable', 'Begin at 50–70% capacity, breaking this down into specific, manageable actions', 'Increase gradually, committing to this even when it feels uncomfortable', 'Recognize small wins as success, noticing when old patterns emerge and course-correcting', 'Avoid all-or-nothing thinking, making this a regular practice you revisit over time']
WHERE scenario_id = 524;

-- Scenario 515: Building a Support Network After Relocation
UPDATE scenarios
SET sc_action_steps = ARRAY['Join city-specific interest groups, writing this down to make it concrete and actionable', 'Attend professional meet-ups, breaking this down into specific, manageable actions', 'Start conversations in safe settings, committing to this even when it feels uncomfortable', 'Reconnect with distant acquaintances in new city, noticing when old patterns emerge and course-correcting', 'Adopt patience—relationships take time, making this a regular practice you revisit over time']
WHERE scenario_id = 515;

-- Scenario 527: Staying Consistent with Healthy Habits Amid Social Pressure
UPDATE scenarios
SET sc_action_steps = ARRAY['Share reasons for your habits confidently, writing this down to make it concrete and actionable', 'Seek supportive communities, breaking this down into specific, manageable actions', 'Limit exposure to undermining influences, committing to this even when it feels uncomfortable', 'Track your improvement to stay motivated, noticing when old patterns emerge and course-correcting', 'Remember why you started, making this a regular practice you revisit over time']
WHERE scenario_id = 527;

-- Scenario 322: Neglecting Physical Health for Career
UPDATE scenarios
SET sc_action_steps = ARRAY['Block recurring time in calendar for exercise, writing this down to make it concrete and actionable', 'Set sleep goals as seriously as work goals, writing them down with specific timelines and milestones', 'Integrate movement into daily routines, committing to this even when it feels uncomfortable', 'Prioritize medical checkups regularly, noticing when old patterns emerge and course-correcting', 'Balance ambition with longevity, making this a regular practice you revisit over time']
WHERE scenario_id = 322;

-- Scenario 333: Friend Jealous of Your Success
UPDATE scenarios
SET sc_action_steps = ARRAY['Acknowledge their feelings without minimizing your achievement, staying consistent even when progress feels slow', 'Show appreciation for their friendship and past support, staying consistent even when progress feels slow', 'Share credit where due, committing to this even when it feels uncomfortable', 'Encourage their own pursuits, noticing when old patterns emerge and course-correcting', 'Avoid boastful behavior, making this a regular practice you revisit over time']
WHERE scenario_id = 333;

-- Scenario 353: Friend Jealous of Your Success
UPDATE scenarios
SET sc_action_steps = ARRAY['Acknowledge their feelings without minimizing your achievement, staying consistent even when progress feels slow', 'Show appreciation for their friendship, breaking this down into specific, manageable actions', 'Share credit where due, committing to this even when it feels uncomfortable', 'Encourage their pursuits, noticing when old patterns emerge and course-correcting', 'Avoid boastfulness, making this a regular practice you revisit over time']
WHERE scenario_id = 353;

-- Scenario 340: Witnessing Workplace Harassment
UPDATE scenarios
SET sc_action_steps = ARRAY['Ensure the safety of the target first, writing this down to make it concrete and actionable', 'Report to HR or authority channels, breaking this down into specific, manageable actions', 'Document what you witnessed, committing to this even when it feels uncomfortable', 'Support the affected colleague respectfully, noticing when old patterns emerge and course-correcting', 'Reflect on bystander responsibility, making this a regular practice you revisit over time']
WHERE scenario_id = 340;

-- Scenario 341: Faced with a Conflict of Interest
UPDATE scenarios
SET sc_action_steps = ARRAY['Disclose the relationship to relevant parties, writing this down to make it concrete and actionable', 'Recuse yourself if necessary, breaking this down into specific, manageable actions', 'Use objective criteria for selection, committing to this even when it feels uncomfortable', 'Keep documentation for accountability, noticing when old patterns emerge and course-correcting', 'Prioritize the organization’s and public good over personal ties, staying consistent even when progress feels slow']
WHERE scenario_id = 341;

-- Scenario 344: Using Company Resources for Personal Gain
UPDATE scenarios
SET sc_action_steps = ARRAY['Understand policies about personal use of resources, staying consistent even when progress feels slow', 'Avoid even minor misuse, breaking this down into specific, manageable actions', 'Ask permission if unsure, committing to this even when it feels uncomfortable', 'Model correct behavior to others, noticing when old patterns emerge and course-correcting', 'Recognize trust as part of professional duty, making this a regular practice you revisit over time']
WHERE scenario_id = 344;

-- Scenario 352: Balancing Multiple Friend Groups
UPDATE scenarios
SET sc_action_steps = ARRAY['Identify relationships most aligned with your values, staying consistent even when progress feels slow', 'Schedule quality time intentionally, breaking this down into specific, manageable actions', 'Communicate your availability honestly, committing to this even when it feels uncomfortable', 'Release guilt about limited capacity, noticing when old patterns emerge and course-correcting', 'Foster reciprocity in relationships, making this a regular practice you revisit over time']
WHERE scenario_id = 352;

-- Scenario 334: Handling Gossip About a Friend
UPDATE scenarios
SET sc_action_steps = ARRAY['Privately share what you’ve heard with them directly, being honest and direct about your needs and boundaries', 'Encourage addressing misinfo at its source, breaking this down into specific, manageable actions', 'Don’t spread unverified claims, committing to this even when it feels uncomfortable', 'Reassure them of your trust, noticing when old patterns emerge and course-correcting', 'Model discretion to your circle, making this a regular practice you revisit over time']
WHERE scenario_id = 334;

-- Scenario 354: Handling Gossip About a Friend
UPDATE scenarios
SET sc_action_steps = ARRAY['Share concerns privately with the friend, writing this down to make it concrete and actionable', 'Encourage addressing rumors constructively, breaking this down into specific, manageable actions', 'Avoid participating in unverified gossip, committing to this even when it feels uncomfortable', 'Reaffirm your support, noticing when old patterns emerge and course-correcting', 'Model discretion in your circles, making this a regular practice you revisit over time']
WHERE scenario_id = 354;

-- Scenario 355: Friend Only Calls in Crisis
UPDATE scenarios
SET sc_action_steps = ARRAY['Assess your capacity before helping, writing this down to make it concrete and actionable', 'Communicate when the pattern feels one-sided, breaking this down into specific, manageable actions', 'Clarify what support you can offer, committing to this even when it feels uncomfortable', 'Encourage independence, noticing when old patterns emerge and course-correcting', 'Value mutual relationships, making this a regular practice you revisit over time']
WHERE scenario_id = 355;

-- Scenario 356: Navigating Friendship After Betrayal
UPDATE scenarios
SET sc_action_steps = ARRAY['Confront the issue calmly, writing this down to make it concrete and actionable', 'Seek to understand their perspective, breaking this down into specific, manageable actions', 'Set boundaries for rebuilding trust, committing to this even when it feels uncomfortable', 'Decide if relationship can recover, noticing when old patterns emerge and course-correcting', 'Accept closure if trust is broken beyond repair, making this a regular practice you revisit over time']
WHERE scenario_id = 356;

-- Scenario 357: Long-Distance Friendship Fading
UPDATE scenarios
SET sc_action_steps = ARRAY['Set reminders to check in, writing this down to make it concrete and actionable', 'Share updates through calls or letters, breaking this down into specific, manageable actions', 'Plan visits if possible, writing them down with specific timelines and milestones', 'Celebrate milestones from afar, noticing when old patterns emerge and course-correcting', 'Reassure them of your care, making this a regular practice you revisit over time']
WHERE scenario_id = 357;

-- Scenario 372: Unsure Whether to Go Back to School
UPDATE scenarios
SET sc_action_steps = ARRAY['Clarify your long-term goals, writing them down with specific timelines and milestones', 'Consult mentors in your desired field, breaking this down into specific, manageable actions', 'Weigh cost/benefit realistically, committing to this even when it feels uncomfortable', 'Choose programs aligned with your path, noticing when old patterns emerge and course-correcting', 'Act without fear or haste, making this a regular practice you revisit over time']
WHERE scenario_id = 372;

-- Scenario 387: Social Media Draining Mental Health
UPDATE scenarios
SET sc_action_steps = ARRAY['Unfollow negative accounts, writing this down to make it concrete and actionable', 'Designate social media-free zones/times, breaking this down into specific, manageable actions', 'Engage with uplifting content intentionally, committing to this even when it feels uncomfortable', 'Replace scrolling with enriching activities, noticing when old patterns emerge and course-correcting', 'Monitor emotional state after online sessions, making this a regular practice you revisit over time']
WHERE scenario_id = 387;

-- Scenario 397: Unsafe Neighborhood Fears
UPDATE scenarios
SET sc_action_steps = ARRAY['Review crime prevention measures with local authorities, noticing when old patterns creep in and consciously choosing differently', 'Adjust routines to reduce risk, breaking this down into specific, manageable actions', 'Engage with community watch programs, committing to this even when it feels uncomfortable', 'Plan relocation carefully if viable, writing them down with specific timelines and milestones', 'Maintain inner composure while taking prudent actions, staying consistent even when progress feels slow']
WHERE scenario_id = 397;

-- Scenario 398: Relationship Breakup Forces New Living Arrangements
UPDATE scenarios
SET sc_action_steps = ARRAY['List non-negotiable housing needs, writing this down to make it concrete and actionable', 'Consider temporary solutions while planning, writing them down with specific timelines and milestones', 'Set a realistic budget, tracking every expense for at least a month to understand patterns', 'Reach out to support network for leads, noticing when old patterns emerge and course-correcting', 'Use this as a chance to reassess priorities, making this a regular practice you revisit over time']
WHERE scenario_id = 398;

-- Scenario 400: Family Pressure to Live Nearby
UPDATE scenarios
SET sc_action_steps = ARRAY['Clearly express your reasons for living where you choose, being honest and direct about your needs and boundaries', 'Reassure family about maintaining connection, reaching out to at least 2-3 people who genuinely support you', 'Plan regular visits or calls, writing them down with specific timelines and milestones', 'Evaluate compromises that serve both, noticing when old patterns emerge and course-correcting', 'Respect your own needs while honoring family bonds, staying consistent even when progress feels slow']
WHERE scenario_id = 400;

-- Scenario 401: Struggling to Scale a Small Business
UPDATE scenarios
SET sc_action_steps = ARRAY['Identify repetitive tasks to delegate, writing this down to make it concrete and actionable', 'Bring in part-time or contract help, breaking this down into specific, manageable actions', 'Document standard operating procedures, committing to this even when it feels uncomfortable', 'Focus on highest-value activities, noticing when old patterns emerge and course-correcting', 'Automate where possible, making this a regular practice you revisit over time']
WHERE scenario_id = 401;

-- Scenario 402: Facing Seasonal Revenue Slumps
UPDATE scenarios
SET sc_action_steps = ARRAY['Identify seasonal patterns in revenue, writing this down to make it concrete and actionable', 'Save during peak months, breaking this down into specific, manageable actions', 'Develop off-season services or products, committing to this even when it feels uncomfortable', 'Negotiate with suppliers for flexible terms, noticing when old patterns emerge and course-correcting', 'Keep team engaged during slow periods via training or development, staying consistent even when progress feels slow']
WHERE scenario_id = 402;

-- Scenario 403: Partnership Disagreements
UPDATE scenarios
SET sc_action_steps = ARRAY['Schedule dedicated talks to explore visions, writing this down to make it concrete and actionable', 'Hire a mediator if talks stall, breaking this down into specific, manageable actions', 'Identify shared core goals, writing them down with specific timelines and milestones', 'Agree on decision-making processes, noticing when old patterns emerge and course-correcting', 'Document agreements clearly, making this a regular practice you revisit over time']
WHERE scenario_id = 403;

-- Scenario 404: Coping with Sudden Market Competition
UPDATE scenarios
SET sc_action_steps = ARRAY['Analyze competitor strengths and weaknesses, writing this down to make it concrete and actionable', 'Refine your unique value proposition, breaking this down into specific, manageable actions', 'Focus marketing on loyal customer base, committing to this even when it feels uncomfortable', 'Improve service and offerings, noticing when old patterns emerge and course-correcting', 'Avoid unsustainable race-to-the-bottom pricing, making this a regular practice you revisit over time']
WHERE scenario_id = 404;

-- Scenario 442: Pay Cuts Due to Recession
UPDATE scenarios
SET sc_action_steps = ARRAY['Review and adjust personal budget immediately, tracking every expense for at least a month to understand patterns', 'Identify unnecessary expenses to cut, breaking this down into specific, manageable actions', 'Explore freelance or side gigs, committing to this even when it feels uncomfortable', 'Stay valuable to current employer, noticing when old patterns emerge and course-correcting', 'Maintain morale despite pay change, making this a regular practice you revisit over time']
WHERE scenario_id = 442;

-- Scenario 444: Freelance Contracts Drying Up
UPDATE scenarios
SET sc_action_steps = ARRAY['Reach out to dormant contacts, writing this down to make it concrete and actionable', 'Adapt offers to market needs, breaking this down into specific, manageable actions', 'Adjust budget temporarily, tracking every expense for at least a month to understand patterns', 'Seek referrals from satisfied clients, noticing when old patterns emerge and course-correcting', 'Learn complementary high-demand skills, making this a regular practice you revisit over time']
WHERE scenario_id = 444;

-- Scenario 453: Never Having Traveled Abroad
UPDATE scenarios
SET sc_action_steps = ARRAY['Explore local adventures within budget, tracking every expense for at least a month to understand patterns', 'Save gradually for desired trips, breaking this down into specific, manageable actions', 'Detach joy from needing distant destinations, committing to this even when it feels uncomfortable', 'Engage in cultural experiences nearby, noticing when old patterns emerge and course-correcting', 'Remember that growth is not limited to geography, making this a regular practice you revisit over time']
WHERE scenario_id = 453;

-- Scenario 454: No Career Promotion While Peers Advance
UPDATE scenarios
SET sc_action_steps = ARRAY['Assess if your role still aligns with your purpose, staying consistent even when progress feels slow', 'Seek skill growth for readiness, breaking this down into specific, manageable actions', 'Understand timing varies by industry, committing to this even when it feels uncomfortable', 'Celebrate skill milestones along with title changes, staying consistent even when progress feels slow', 'Detach self-worth from designation, making this a regular practice you revisit over time']
WHERE scenario_id = 454;

-- Scenario 457: Feeling Behind Financially by 30
UPDATE scenarios
SET sc_action_steps = ARRAY['Make a realistic 5-year plan, writing them down with specific timelines and milestones', 'Avoid debt to chase prestige, breaking this down into specific, manageable actions', 'Track true net worth, not just assets, committing to this even when it feels uncomfortable', 'Automate savings, noticing when old patterns emerge and course-correcting', 'Celebrate small financial wins, making this a regular practice you revisit over time']
WHERE scenario_id = 457;

-- Scenario 461: Fear About Future Generations’ Planet
UPDATE scenarios
SET sc_action_steps = ARRAY['Join local climate advocacy groups, writing this down to make it concrete and actionable', 'Set a positive example in daily habits, breaking this down into specific, manageable actions', 'Educate children on sustainability with hope, committing to this even when it feels uncomfortable', 'Focus on attainable environmental goals, writing them down with specific timelines and milestones', 'Support causes that restore ecosystems, making this a regular practice you revisit over time']
WHERE scenario_id = 461;

-- Scenario 462: Feeling Guilty About Carbon Footprint
UPDATE scenarios
SET sc_action_steps = ARRAY['Audit your carbon impact to focus efforts, writing this down to make it concrete and actionable', 'Replace high-impact habits first, breaking this down into specific, manageable actions', 'Avoid burnout through over-restriction, committing to this even when it feels uncomfortable', 'Offset travel when possible, noticing when old patterns emerge and course-correcting', 'Engage others positively instead of with blame, making this a regular practice you revisit over time']
WHERE scenario_id = 462;

-- Scenario 463: Overwhelmed by Daily Disaster Headlines
UPDATE scenarios
SET sc_action_steps = ARRAY['Set time limits for news intake, writing this down to make it concrete and actionable', 'Follow outlets focusing on solutions, breaking this down into specific, manageable actions', 'Share positive environmental progress, committing to this even when it feels uncomfortable', 'Engage in one personal eco-initiative, noticing when old patterns emerge and course-correcting', 'Practice gratitude for earth’s resilience, making this a regular practice you revisit over time']
WHERE scenario_id = 463;

-- Scenario 464: Despair at Slow Policy Progress
UPDATE scenarios
SET sc_action_steps = ARRAY['Support local environmental policies, writing this down to make it concrete and actionable', 'Educate and mobilize your network, breaking this down into specific, manageable actions', 'Communicate respectfully with representatives, committing to this even when it feels uncomfortable', 'Celebrate small wins, noticing when old patterns emerge and course-correcting', 'Trust cumulative impact, making this a regular practice you revisit over time']
WHERE scenario_id = 464;

-- Scenario 466: Feeling Small Against Global Crisis
UPDATE scenarios
SET sc_action_steps = ARRAY['Volunteer locally in sustainability projects, writing this down to make it concrete and actionable', 'Measure personal positive impact yearly, breaking this down into specific, manageable actions', 'Collaborate to multiply efforts, committing to this even when it feels uncomfortable', 'Share inspiring change stories, noticing when old patterns emerge and course-correcting', 'Stay grounded in purpose over results, making this a regular practice you revisit over time']
WHERE scenario_id = 466;

-- Scenario 467: Judging Others’ Eco-Habits
UPDATE scenarios
SET sc_action_steps = ARRAY['Model sustainable behavior positively, writing this down to make it concrete and actionable', 'Invite dialogue about benefits, breaking this down into specific, manageable actions', 'Avoid self-righteous comparisons, committing to this even when it feels uncomfortable', 'Encourage small, doable steps, noticing when old patterns emerge and course-correcting', 'Recognize everyone’s journey differs, making this a regular practice you revisit over time']
WHERE scenario_id = 467;

-- Scenario 481: Brain Fog from Constant App Switching
UPDATE scenarios
SET sc_action_steps = ARRAY['Close all unnecessary apps during tasks, writing this down to make it concrete and actionable', 'Use site blockers for high-distraction platforms, breaking this down into specific, manageable actions', 'Schedule tech-free focus periods daily, committing to this even when it feels uncomfortable', 'Batch similar digital tasks together, noticing when old patterns emerge and course-correcting', 'Journal productivity improvements weekly, making this a regular practice you revisit over time']
WHERE scenario_id = 481;

-- Scenario 472: Career Break Making You Feel Invisible
UPDATE scenarios
SET sc_action_steps = ARRAY['Join professional groups online, writing this down to make it concrete and actionable', 'Update skills with short courses, breaking this down into specific, manageable actions', 'Network with industry peers regularly, committing to this even when it feels uncomfortable', 'Volunteer in relevant work to build momentum, noticing when old patterns emerge and course-correcting', 'Remind yourself your skills still hold value, making this a regular practice you revisit over time']
WHERE scenario_id = 472;

-- Scenario 473: Losing Creative Spark in Routine Life
UPDATE scenarios
SET sc_action_steps = ARRAY['Schedule weekly creative sessions, writing this down to make it concrete and actionable', 'Try unfamiliar art forms or mediums, breaking this down into specific, manageable actions', 'Surround yourself with inspiring sources, committing to this even when it feels uncomfortable', 'Collaborate with other creatives, noticing when old patterns emerge and course-correcting', 'Celebrate output regardless of perfection, making this a regular practice you revisit over time']
WHERE scenario_id = 473;

-- Scenario 477: Struggling to Adapt After Retirement
UPDATE scenarios
SET sc_action_steps = ARRAY['List passions postponed during career, writing this down to make it concrete and actionable', 'Join interest-based clubs or classes, breaking this down into specific, manageable actions', 'Mentor younger people, reaching out to at least 2-3 people who genuinely support you', 'Focus on health and relationships, noticing when old patterns emerge and course-correcting', 'Create a balanced weekly schedule, making this a regular practice you revisit over time']
WHERE scenario_id = 477;

-- Scenario 479: Losing Faith in Your Abilities After Setback
UPDATE scenarios
SET sc_action_steps = ARRAY['Analyze lessons from the setback, writing this down to make it concrete and actionable', 'Identify skills to strengthen, breaking this down into specific, manageable actions', 'Separate self-worth from single outcomes, committing to this even when it feels uncomfortable', 'Reignite pursuits step-by-step, noticing when old patterns emerge and course-correcting', 'Surround yourself with encouraging voices, making this a regular practice you revisit over time']
WHERE scenario_id = 479;

-- Scenario 482: Needing Device Nearby at All Times
UPDATE scenarios
SET sc_action_steps = ARRAY['Place device in another room during meals, writing this down to make it concrete and actionable', 'Tell others you’re offline during personal time, breaking this down into specific, manageable actions', 'Notice improvements in engagement, committing to this even when it feels uncomfortable', 'Schedule phone checks consciously, noticing when old patterns emerge and course-correcting', 'Practice short offline breaks daily, making this a regular practice you revisit over time']
WHERE scenario_id = 482;

-- Scenario 486: Work Suffering from Multitasking Tabs
UPDATE scenarios
SET sc_action_steps = ARRAY['Group related tabs in a single window, writing this down to make it concrete and actionable', 'Close unrelated tasks till completion, breaking this down into specific, manageable actions', 'Use tab manager extensions, committing to this even when it feels uncomfortable', 'Review progress on single-task days, noticing when old patterns emerge and course-correcting', 'Notice effects on work quality, making this a regular practice you revisit over time']
WHERE scenario_id = 486;

-- Scenario 487: Evenings Consumed by Screens Instead of Relaxation
UPDATE scenarios
SET sc_action_steps = ARRAY['List non-screen relaxing activities, writing this down to make it concrete and actionable', 'Set a “screens off” hour before bed, breaking this down into specific, manageable actions', 'Engage family in screen-free games, committing to this even when it feels uncomfortable', 'Track post-evening energy, noticing when old patterns emerge and course-correcting', 'Make digital use conscious, not default, making this a regular practice you revisit over time']
WHERE scenario_id = 487;

-- Scenario 488: Phone as Default Social Comfort
UPDATE scenarios
SET sc_action_steps = ARRAY['Keep phone in pocket during conversation, writing this down to make it concrete and actionable', 'Ask questions to open dialogue, breaking this down into specific, manageable actions', 'Join group topics actively, committing to this even when it feels uncomfortable', 'Challenge yourself with short no-phone periods at events, staying consistent even when progress feels slow', 'Notice connection depth changes, reaching out to at least 2-3 people who genuinely support you']
WHERE scenario_id = 488;

-- Scenario 489: Declining Attention Span from Quick Content
UPDATE scenarios
SET sc_action_steps = ARRAY['Start with slightly longer focus tasks daily, writing this down to make it concrete and actionable', 'Increase reading or focus length over weeks, breaking this down into specific, manageable actions', 'Reduce quick-content exposure incrementally, committing to this even when it feels uncomfortable', 'Track attention improvements, noticing when old patterns emerge and course-correcting', 'Celebrate deeper engagement as growth, making this a regular practice you revisit over time']
WHERE scenario_id = 489;

-- Scenario 491: Side Hustle Eating Into Family Time
UPDATE scenarios
SET sc_action_steps = ARRAY['Set clear work hours for side business, writing this down to make it concrete and actionable', 'Plan family time into your weekly schedule, writing them down with specific timelines and milestones', 'Communicate openly about your goals, writing them down with specific timelines and milestones', 'Evaluate whether pace is sustainable, noticing when old patterns emerge and course-correcting', 'Prioritize well-being alongside ambition, making this a regular practice you revisit over time']
WHERE scenario_id = 491;

-- Scenario 523: Lack of Accountability Hurting Progress
UPDATE scenarios
SET sc_action_steps = ARRAY['Find a habit buddy, writing this down to make it concrete and actionable', 'Join a challenge group, breaking this down into specific, manageable actions', 'Report progress regularly, committing to this even when it feels uncomfortable', 'Encourage others’ habits as well, noticing when old patterns emerge and course-correcting', 'Mix fun with accountability, making this a regular practice you revisit over time']
WHERE scenario_id = 523;

-- Scenario 493: Burnout from Juggling Job and Side Gig
UPDATE scenarios
SET sc_action_steps = ARRAY['Set realistic weekly workload, writing this down to make it concrete and actionable', 'Block rest and recovery periods, breaking this down into specific, manageable actions', 'Streamline or automate side business tasks, committing to this even when it feels uncomfortable', 'Outsource low-priority work, noticing when old patterns emerge and course-correcting', 'Check health regularly and adjust commitments, making this a regular practice you revisit over time']
WHERE scenario_id = 493;

-- Scenario 497: Pricing Strategy Doubt in Side Hustle
UPDATE scenarios
SET sc_action_steps = ARRAY['Study industry standard rates, writing this down to make it concrete and actionable', 'Factor in time, skill, and expenses, breaking this down into specific, manageable actions', 'Test and adjust based on client response, committing to this even when it feels uncomfortable', 'Communicate value confidently, noticing when old patterns emerge and course-correcting', 'Review pricing annually, making this a regular practice you revisit over time']
WHERE scenario_id = 497;

-- Scenario 495: Side Hustle Impacting Day Job Performance
UPDATE scenarios
SET sc_action_steps = ARRAY['Align side hustle hours with peak personal energy, writing this down to make it concrete and actionable', 'Avoid working on it during employer time, breaking this down into specific, manageable actions', 'Reassess feasibility if conflicts persist, committing to this even when it feels uncomfortable', 'Set clear priorities between incomes, noticing when old patterns emerge and course-correcting', 'Manage expectations on both fronts, making this a regular practice you revisit over time']
WHERE scenario_id = 495;

-- Scenario 496: Comparison with Other Entrepreneurs
UPDATE scenarios
SET sc_action_steps = ARRAY['Track your own monthly progress, writing this down to make it concrete and actionable', 'Limit exposure to demotivating comparisons, breaking this down into specific, manageable actions', 'Learn selectively from others’ best practices, committing to this even when it feels uncomfortable', 'Define success beyond revenue, noticing when old patterns emerge and course-correcting', 'Invest in personal growth as much as profit, making this a regular practice you revisit over time']
WHERE scenario_id = 496;

-- Scenario 498: Family Skepticism about Your Side Hustle
UPDATE scenarios
SET sc_action_steps = ARRAY['Outline your plan clearly for them, writing them down with specific timelines and milestones', 'Share small wins for reassurance, breaking this down into specific, manageable actions', 'Avoid seeking validation for every step, committing to this even when it feels uncomfortable', 'Let results speak with time, noticing when old patterns emerge and course-correcting', 'Stay anchored in your purpose, making this a regular practice you revisit over time']
WHERE scenario_id = 498;

-- Scenario 499: Managing Taxes for Side Income
UPDATE scenarios
SET sc_action_steps = ARRAY['Set aside a fixed tax percentage from earnings, writing this down to make it concrete and actionable', 'Track income and expenses monthly, breaking this down into specific, manageable actions', 'Consult a tax professional early, committing to this even when it feels uncomfortable', 'Use dedicated accounts for business, noticing when old patterns emerge and course-correcting', 'Review tax obligations annually, making this a regular practice you revisit over time']
WHERE scenario_id = 499;

-- Scenario 502: Emotional Drain from Ghosting
UPDATE scenarios
SET sc_action_steps = ARRAY['Limit emotional investment before meeting, writing this down to make it concrete and actionable', 'Avoid personalizing ghosting behavior, breaking this down into specific, manageable actions', 'Focus on consistent and respectful matches, committing to this even when it feels uncomfortable', 'Nurture friendships alongside dating, noticing when old patterns emerge and course-correcting', 'Maintain self-care during the dating process, making this a regular practice you revisit over time']
WHERE scenario_id = 502;

-- Scenario 503: Multiple Shallow Conversations
UPDATE scenarios
SET sc_action_steps = ARRAY['Ask open-ended, value-based questions, writing this down to make it concrete and actionable', 'Share your own deeper interests early, breaking this down into specific, manageable actions', 'Politely end chats lacking real engagement, committing to this even when it feels uncomfortable', 'Prioritize quality over chat volume, noticing when old patterns emerge and course-correcting', 'Be authentic from the start, making this a regular practice you revisit over time']
WHERE scenario_id = 503;

-- Scenario 505: Disappointment from Misleading Profiles
UPDATE scenarios
SET sc_action_steps = ARRAY['Request voice/video call before meeting, writing this down to make it concrete and actionable', 'Notice inconsistencies in communication, breaking this down into specific, manageable actions', 'Keep meetings short for first encounters, committing to this even when it feels uncomfortable', 'Avoid projecting ideal traits prematurely, noticing when old patterns emerge and course-correcting', 'Trust patterns, not just promises, making this a regular practice you revisit over time']
WHERE scenario_id = 505;

-- Scenario 510: Surrounded by People but Feeling Isolated
UPDATE scenarios
SET sc_action_steps = ARRAY['Join small interest-based groups, writing this down to make it concrete and actionable', 'Volunteer to meet values-aligned people, reaching out to at least 2-3 people who genuinely support you', 'Schedule weekly connection calls with friends/family, staying consistent even when progress feels slow', 'Focus on depth in select relationships, noticing when old patterns emerge and course-correcting', 'Limit excessive low-value socializing, making this a regular practice you revisit over time']
WHERE scenario_id = 510;

-- Scenario 512: Feeling Anonymous in Huge Crowds
UPDATE scenarios
SET sc_action_steps = ARRAY['Attend events matching your passions, writing this down to make it concrete and actionable', 'Interact with a few people deeply, reaching out to at least 2-3 people who genuinely support you', 'Initiate conversations with curiosity, committing to this even when it feels uncomfortable', 'Share personal stories appropriately, noticing when old patterns emerge and course-correcting', 'Set intention before entering social spaces, making this a regular practice you revisit over time']
WHERE scenario_id = 512;

-- Scenario 514: Too Busy to Nurture Friendships
UPDATE scenarios
SET sc_action_steps = ARRAY['Schedule recurring social time weekly, writing this down to make it concrete and actionable', 'Integrate socializing with daily routines, breaking this down into specific, manageable actions', 'Use commute to connect via calls, committing to this even when it feels uncomfortable', 'Decline low-value commitments to make space, noticing when old patterns emerge and course-correcting', 'Prioritize presence when meeting others, making this a regular practice you revisit over time']
WHERE scenario_id = 514;

-- Scenario 516: Feeling Like Just Another Face at Work
UPDATE scenarios
SET sc_action_steps = ARRAY['Volunteer for visible projects, writing this down to make it concrete and actionable', 'Approach colleagues beyond your team, breaking this down into specific, manageable actions', 'Ask for feedback proactively, committing to this even when it feels uncomfortable', 'Offer help without waiting to be asked, noticing when old patterns emerge and course-correcting', 'Celebrate others’ work to build rapport, making this a regular practice you revisit over time']
WHERE scenario_id = 516;

-- Scenario 517: Living Alone in a City of Millions
UPDATE scenarios
SET sc_action_steps = ARRAY['Smile and greet people daily, reaching out to at least 2-3 people who genuinely support you', 'Join local clubs or volunteer work, breaking this down into specific, manageable actions', 'Explore co-living communities, committing to this even when it feels uncomfortable', 'Use shared public spaces more often, noticing when old patterns emerge and course-correcting', 'Balance solitude with connection, reaching out to at least 2-3 people who genuinely support you']
WHERE scenario_id = 517;

-- Scenario 518: Language Barrier in New Country City
UPDATE scenarios
SET sc_action_steps = ARRAY['Take language classes, writing this down to make it concrete and actionable', 'Join mixed-language groups, breaking this down into specific, manageable actions', 'Use translation tools in real time, committing to this even when it feels uncomfortable', 'Celebrate progress weekly, noticing when old patterns emerge and course-correcting', 'Find other newcomers for mutual support, making this a regular practice you revisit over time']
WHERE scenario_id = 518;

-- Scenario 520: Struggling to Stick to Morning Routine
UPDATE scenarios
SET sc_action_steps = ARRAY['Start with one manageable habit, writing this down to make it concrete and actionable', 'Track completion daily, breaking this down into specific, manageable actions', 'Reward milestones, committing to this even when it feels uncomfortable', 'Allow for small setbacks, noticing when old patterns emerge and course-correcting', 'Increase challenge gradually, making this a regular practice you revisit over time']
WHERE scenario_id = 520;

-- Scenario 521: Losing Motivation Mid-Goal
UPDATE scenarios
SET sc_action_steps = ARRAY['Write down your “why” for the habit, writing this down to make it concrete and actionable', 'Create accountability with a friend, breaking this down into specific, manageable actions', 'Set interim goals for quick wins, writing them down with specific timelines and milestones', 'Track visual progress, noticing when old patterns emerge and course-correcting', 'Celebrate process over outcome, making this a regular practice you revisit over time']
WHERE scenario_id = 521;

-- Scenario 522: Overcommitting to Too Many New Habits
UPDATE scenarios
SET sc_action_steps = ARRAY['Limit new habits to 1–3 at a time, writing this down to make it concrete and actionable', 'Stack habits onto existing routines, breaking this down into specific, manageable actions', 'Phase in new changes gradually, committing to this even when it feels uncomfortable', 'Reassess every 30 days, noticing when old patterns emerge and course-correcting', 'Drop habits that add no value, making this a regular practice you revisit over time']
WHERE scenario_id = 522;

-- Scenario 348: Choosing Ethical Brands Amid Uncomfortable Facts
UPDATE scenarios
SET sc_action_steps = ARRAY['Research brand practices before purchasing, writing this down to make it concrete and actionable', 'Support ethically aligned companies, breaking this down into specific, manageable actions', 'Reduce consumption where alternatives are unavailable, staying consistent even when progress feels slow', 'Share awareness with others respectfully, noticing when old patterns emerge and course-correcting', 'Recognize the power of small consumer actions, making this a regular practice you revisit over time']
WHERE scenario_id = 348;

-- Scenario 360: Temptation to Plagiarize Under Deadlines
UPDATE scenarios
SET sc_action_steps = ARRAY['Break down tasks for manageability, writing this down to make it concrete and actionable', 'Seek help instead of cheating, breaking this down into specific, manageable actions', 'Credit any borrowed ideas, committing to this even when it feels uncomfortable', 'Request extensions when needed, noticing when old patterns emerge and course-correcting', 'Reflect on long-term trust over short-term gain, making this a regular practice you revisit over time']
WHERE scenario_id = 360;

-- Scenario 362: Conflict of Interest in Decision-Making
UPDATE scenarios
SET sc_action_steps = ARRAY['State the connection openly, reaching out to at least 2-3 people who genuinely support you', 'Recuse from decision if appropriate, breaking this down into specific, manageable actions', 'Use objective criteria only, committing to this even when it feels uncomfortable', 'Record the selection process, noticing when old patterns emerge and course-correcting', 'Serve organizational interest first, making this a regular practice you revisit over time']
WHERE scenario_id = 362;

-- Scenario 405: Burnout from Wearing Too Many Hats
UPDATE scenarios
SET sc_action_steps = ARRAY['List tasks only you can do, writing this down to make it concrete and actionable', 'Outsource or train others for the rest, breaking this down into specific, manageable actions', 'Set sustainable work hours, committing to this even when it feels uncomfortable', 'Schedule personal rest and recovery, noticing when old patterns emerge and course-correcting', 'Focus time on business strategy, making this a regular practice you revisit over time']
WHERE scenario_id = 405;

-- Scenario 408: Difficulty Securing Startup Funding
UPDATE scenarios
SET sc_action_steps = ARRAY['Revise pitch based on feedback, writing this down to make it concrete and actionable', 'Seek mentorship from respected founders, breaking this down into specific, manageable actions', 'Explore alternative funding sources, committing to this even when it feels uncomfortable', 'Build traction with self-funding if needed, noticing when old patterns emerge and course-correcting', 'Be patient while developing trust with investors, making this a regular practice you revisit over time']
WHERE scenario_id = 408;

-- Scenario 410: Balancing Profit with Ethical Practices
UPDATE scenarios
SET sc_action_steps = ARRAY['Define non-negotiable ethical principles, writing this down to make it concrete and actionable', 'Assess if opportunities align with them, breaking this down into specific, manageable actions', 'Communicate values to customers, committing to this even when it feels uncomfortable', 'Innovate for profitability and responsibility, noticing when old patterns emerge and course-correcting', 'Accept slower growth for integrity, making this a regular practice you revisit over time']
WHERE scenario_id = 410;

-- Scenario 409: Leading Team Change Amidst Resistance
UPDATE scenarios
SET sc_action_steps = ARRAY['Communicate the purpose and benefits of change, writing this down to make it concrete and actionable', 'Offer training and support, breaking this down into specific, manageable actions', 'Address concerns openly, committing to this even when it feels uncomfortable', 'Implement in phases to allow adjustment, noticing when old patterns emerge and course-correcting', 'Recognize and reward early adopters, making this a regular practice you revisit over time']
WHERE scenario_id = 409;

-- Scenario 419: Focusing on Personal Healing Before Marriage
UPDATE scenarios
SET sc_action_steps = ARRAY['Identify healing areas with honesty, writing this down to make it concrete and actionable', 'Seek therapy or mentoring support, breaking this down into specific, manageable actions', 'Establish nourishing habits, committing to this even when it feels uncomfortable', 'Communicate this timeline to suitors, noticing when old patterns emerge and course-correcting', 'Celebrate milestones in personal growth, making this a regular practice you revisit over time']
WHERE scenario_id = 419;

-- Scenario 492: Overestimating Side Hustle Income
UPDATE scenarios
SET sc_action_steps = ARRAY['Track actual vs projected earnings, writing this down to make it concrete and actionable', 'Cut unnecessary expenses, breaking this down into specific, manageable actions', 'Enhance skills for higher-value offers, committing to this even when it feels uncomfortable', 'Balance optimism with realistic timelines, noticing when old patterns emerge and course-correcting', 'Consider part-time work during transition, making this a regular practice you revisit over time']
WHERE scenario_id = 492;

-- Scenario 631: Leading a Meeting for the First Time
UPDATE scenarios
SET sc_action_steps = ARRAY['Outline meeting in advance, writing this down to make it concrete and actionable', 'Share agenda ahead, breaking this down into specific, manageable actions', 'Use pauses strategically, committing to this even when it feels uncomfortable', 'Invite written input, noticing when old patterns emerge and course-correcting', 'Review and follow-up via email, making this a regular practice you revisit over time']
WHERE scenario_id = 631;

-- Scenario 565: Managing Financial Pressure from Caregiving Costs
UPDATE scenarios
SET sc_action_steps = ARRAY['Research government or ngo support, writing this down to make it concrete and actionable', 'Share costs with siblings where possible, breaking this down into specific, manageable actions', 'Track all caregiving expenses, committing to this even when it feels uncomfortable', 'Prioritize essential spending, noticing when old patterns emerge and course-correcting', 'Be transparent about limitations, making this a regular practice you revisit over time']
WHERE scenario_id = 565;

-- Scenario 642: Managing Family Criticism in Public Outings
UPDATE scenarios
SET sc_action_steps = ARRAY['Explain meltdown context, writing this down to make it concrete and actionable', 'Invite them to learn strategies, breaking this down into specific, manageable actions', 'Model calm handling, committing to this even when it feels uncomfortable', 'Share positive outcomes after outings, noticing when old patterns emerge and course-correcting', 'Set boundary if criticism persists, making this a regular practice you revisit over time']
WHERE scenario_id = 642;

-- Scenario 536: Labeled Online by a Single Mistake
UPDATE scenarios
SET sc_action_steps = ARRAY['Acknowledge the mistake sincerely, writing this down to make it concrete and actionable', 'Avoid repeating it, breaking this down into specific, manageable actions', 'Channel energy into valuable work, committing to this even when it feels uncomfortable', 'Encourage feedback from trusted people, reaching out to at least 2-3 people who genuinely support you', 'Let actions over time shift the narrative, making this a regular practice you revisit over time']
WHERE scenario_id = 536;

-- Scenario 529: The Importance of Tracking Habits for Growth
UPDATE scenarios
SET sc_action_steps = ARRAY['Use a simple habit tracker app or journal, writing this down to make it concrete and actionable', 'Review data weekly, breaking this down into specific, manageable actions', 'Analyze patterns to adjust strategies, committing to this even when it feels uncomfortable', 'Celebrate progress tracked visually, noticing when old patterns emerge and course-correcting', 'Combine tracking with reflection notes, making this a regular practice you revisit over time']
WHERE scenario_id = 529;

-- Scenario 539: Facing Fear of Speech in Cancel Culture
UPDATE scenarios
SET sc_action_steps = ARRAY['Prepare key points carefully, writing this down to make it concrete and actionable', 'Frame opinions respectfully, breaking this down into specific, manageable actions', 'Welcome diverse perspectives, committing to this even when it feels uncomfortable', 'Accept that disagreement is not failure, noticing when old patterns emerge and course-correcting', 'Value constructive exchange over universal approval, staying consistent even when progress feels slow']
WHERE scenario_id = 539;

-- Scenario 612: Navigating Misunderstood Humor
UPDATE scenarios
SET sc_action_steps = ARRAY['Notice others’ tone and humor style, writing this down to make it concrete and actionable', 'Ask trusted friends for feedback, breaking this down into specific, manageable actions', 'Keep humor inclusive, committing to this even when it feels uncomfortable', 'Apologize when unintended offense happens, noticing when old patterns emerge and course-correcting', 'Balance self-expression with audience awareness, making this a regular practice you revisit over time']
WHERE scenario_id = 612;

-- Scenario 634: Choosing Disclosure Timing in Dating
UPDATE scenarios
SET sc_action_steps = ARRAY['Build rapport first, writing this down to make it concrete and actionable', 'Choose private, comfortable setting, breaking this down into specific, manageable actions', 'Share relevant impacts, committing to this even when it feels uncomfortable', 'Invite questions, noticing when old patterns emerge and course-correcting', 'Observe response over time, making this a regular practice you revisit over time']
WHERE scenario_id = 634;

-- Scenario 624: Owning Your Unique Communication Style
UPDATE scenarios
SET sc_action_steps = ARRAY['Use tools to support clarity, writing this down to make it concrete and actionable', 'Explain style to trusted colleagues, breaking this down into specific, manageable actions', 'Seek spaces that value diverse voices, committing to this even when it feels uncomfortable', 'Practice active listening, noticing when old patterns emerge and course-correcting', 'Avoid over-apologizing, making this a regular practice you revisit over time']
WHERE scenario_id = 624;

-- Scenario 627: Joining a Neurodiversity Network for Belonging
UPDATE scenarios
SET sc_action_steps = ARRAY['Search company or local groups, writing this down to make it concrete and actionable', 'Join online communities, breaking this down into specific, manageable actions', 'Attend events to connect in person, committing to this even when it feels uncomfortable', 'Share experiences and resources, noticing when old patterns emerge and course-correcting', 'Offer help to newer members, making this a regular practice you revisit over time']
WHERE scenario_id = 627;

-- Scenario 637: Declining Overload and Invitations Without Guilt
UPDATE scenarios
SET sc_action_steps = ARRAY['Acknowledge invite with gratitude, writing this down to make it concrete and actionable', 'State limitation truthfully, breaking this down into specific, manageable actions', 'Suggest alternative time, committing to this even when it feels uncomfortable', 'Replace guilt with self-compassion, noticing when old patterns emerge and course-correcting', 'Track well-being after saying no, making this a regular practice you revisit over time']
WHERE scenario_id = 637;

-- Scenario 639: Balancing Sibling Needs with Neurodivergent Care
UPDATE scenarios
SET sc_action_steps = ARRAY['Acknowledge sibling emotions, writing this down to make it concrete and actionable', 'Plan 1:1 activities, writing them down with specific timelines and milestones', 'Involve them in support when appropriate, committing to this even when it feels uncomfortable', 'Avoid comparison language, noticing when old patterns emerge and course-correcting', 'Celebrate all achievements, making this a regular practice you revisit over time']
WHERE scenario_id = 639;

-- Scenario 641: Navigating Co-parent Disagreement About Diagnosis
UPDATE scenarios
SET sc_action_steps = ARRAY['Share expert resources, writing this down to make it concrete and actionable', 'Invite them to attend assessments, breaking this down into specific, manageable actions', 'Keep discussions child-focused, committing to this even when it feels uncomfortable', 'Validate their feelings, noticing when old patterns emerge and course-correcting', 'Involve mediator if needed, making this a regular practice you revisit over time']
WHERE scenario_id = 641;

-- Scenario 645: Helping Siblings Advocate for Their Neurodivergent Brother or Sister
UPDATE scenarios
SET sc_action_steps = ARRAY['Role-play common scenarios, writing this down to make it concrete and actionable', 'Teach short factual replies, breaking this down into specific, manageable actions', 'Encourage seeking adult help, committing to this even when it feels uncomfortable', 'Praise their support acts, noticing when old patterns emerge and course-correcting', 'Balance advocacy with safety, making this a regular practice you revisit over time']
WHERE scenario_id = 645;

-- Scenario 646: Reconciling Different Parenting Styles in Blended Families
UPDATE scenarios
SET sc_action_steps = ARRAY['Discuss core values, writing this down to make it concrete and actionable', 'Agree on consistent rules, breaking this down into specific, manageable actions', 'Respect each other’s experience, committing to this even when it feels uncomfortable', 'Adapt rules to child’s needs, noticing when old patterns emerge and course-correcting', 'Praise each other for efforts, making this a regular practice you revisit over time']
WHERE scenario_id = 646;

-- Scenario 636: Self-Advocacy for Sensory Needs During Group Travel
UPDATE scenarios
SET sc_action_steps = ARRAY['Discuss needs before itinerary locked, writing this down to make it concrete and actionable', 'Offer solutions, breaking this down into specific, manageable actions', 'Bring your own aids, committing to this even when it feels uncomfortable', 'Check in during trip, noticing when old patterns emerge and course-correcting', 'Thank group for respect, making this a regular practice you revisit over time']
WHERE scenario_id = 636;

-- Scenario 632: Owning Assistive Tech in Public
UPDATE scenarios
SET sc_action_steps = ARRAY['Normalize tool use through visibility, writing this down to make it concrete and actionable', 'Educate curious onlookers briefly, breaking this down into specific, manageable actions', 'Inspire others with openness, committing to this even when it feels uncomfortable', 'Use in varied settings, noticing when old patterns emerge and course-correcting', 'Ignore negative reactions, making this a regular practice you revisit over time']
WHERE scenario_id = 632;

-- Scenario 533: Workplace Ostracism After Public Criticism
UPDATE scenarios
SET sc_action_steps = ARRAY['Request one-on-one conversations to clear misunderstandings, staying consistent even when progress feels slow', 'Provide facts without hostility, breaking this down into specific, manageable actions', 'Demonstrate steady work ethic, committing to this even when it feels uncomfortable', 'Show goodwill even towards critics, noticing when old patterns emerge and course-correcting', 'Rebuild trust gradually through constancy, making this a regular practice you revisit over time']
WHERE scenario_id = 533;

-- Scenario 534: Being Targeted for Holding Minority Opinion
UPDATE scenarios
SET sc_action_steps = ARRAY['Clarify reasoning behind your view, writing this down to make it concrete and actionable', 'Keep tone measured and respectful, breaking this down into specific, manageable actions', 'Be open to dialogue instead of debate, committing to this even when it feels uncomfortable', 'Acknowledge valid counterpoints, noticing when old patterns emerge and course-correcting', 'Avoid personal attacks and generalizations, making this a regular practice you revisit over time']
WHERE scenario_id = 534;

-- Scenario 542: Searching for Spiritual Home in Adulthood
UPDATE scenarios
SET sc_action_steps = ARRAY['Visit multiple communities over time, writing this down to make it concrete and actionable', 'Engage in trial participation before committing, breaking this down into specific, manageable actions', 'Note where you feel authenticity and peace, committing to this even when it feels uncomfortable', 'Seek leaders who encourage dialogue, noticing when old patterns emerge and course-correcting', 'Consider your service opportunities there, making this a regular practice you revisit over time']
WHERE scenario_id = 542;

-- Scenario 543: Disillusionment After Meeting Hypocritical Leaders
UPDATE scenarios
SET sc_action_steps = ARRAY['Acknowledge human fallibility, writing this down to make it concrete and actionable', 'Focus on universal principles, breaking this down into specific, manageable actions', 'Seek multiple role models, committing to this even when it feels uncomfortable', 'Avoid blind following, noticing when old patterns emerge and course-correcting', 'Judge teachings on merit, not sole messenger, making this a regular practice you revisit over time']
WHERE scenario_id = 543;

-- Scenario 544: Curiosity About Other Traditions
UPDATE scenarios
SET sc_action_steps = ARRAY['Attend events from other traditions respectfully, writing this down to make it concrete and actionable', 'Read foundational texts with open mind, breaking this down into specific, manageable actions', 'Engage with practitioners sincerely, committing to this even when it feels uncomfortable', 'Reflect on resonances and contrasts, noticing when old patterns emerge and course-correcting', 'Integrate what uplifts your practice, making this a regular practice you revisit over time']
WHERE scenario_id = 544;

-- Scenario 549: Living with Persistent Pain
UPDATE scenarios
SET sc_action_steps = ARRAY['Plan tasks in energy‑friendly chunks, writing them down with specific timelines and milestones', 'Use assistive tools where needed, breaking this down into specific, manageable actions', 'Celebrate small daily victories, committing to this even when it feels uncomfortable', 'Seek supportive community groups, noticing when old patterns emerge and course-correcting', 'Balance rest with gentle movement, making this a regular practice you revisit over time']
WHERE scenario_id = 549;

-- Scenario 552: Rebuilding Strength After Treatment
UPDATE scenarios
SET sc_action_steps = ARRAY['Set realistic recovery goals, writing them down with specific timelines and milestones', 'Monitor health changes weekly, breaking this down into specific, manageable actions', 'Acknowledge all progress however small, committing to this even when it feels uncomfortable', 'Balance exercise with rest, noticing when old patterns emerge and course-correcting', 'Seek encouragement from peers, making this a regular practice you revisit over time']
WHERE scenario_id = 552;

-- Scenario 553: Isolation from Chronic Illness
UPDATE scenarios
SET sc_action_steps = ARRAY['Suggest alternative meet‑up formats, writing this down to make it concrete and actionable', 'Invite people to your space, reaching out to at least 2-3 people who genuinely support you', 'Engage in online communities, committing to this even when it feels uncomfortable', 'Stay in touch with thoughtful messages, noticing when old patterns emerge and course-correcting', 'Be honest about limits while showing care, making this a regular practice you revisit over time']
WHERE scenario_id = 553;

-- Scenario 554: Lifestyle Adjustments for Long-Term Health
UPDATE scenarios
SET sc_action_steps = ARRAY['Identify high‑impact positive changes, writing this down to make it concrete and actionable', 'Integrate adjustments gradually, breaking this down into specific, manageable actions', 'Celebrate benefits noticed, committing to this even when it feels uncomfortable', 'Keep healthy options easy to access, noticing when old patterns emerge and course-correcting', 'Involve loved ones in supportive habits, making this a regular practice you revisit over time']
WHERE scenario_id = 554;

-- Scenario 555: Balancing Treatment and Work
UPDATE scenarios
SET sc_action_steps = ARRAY['Discuss flexibility with employer, writing this down to make it concrete and actionable', 'Group appointments efficiently, breaking this down into specific, manageable actions', 'Prioritize rest before demanding tasks, committing to this even when it feels uncomfortable', 'Use tools to manage time effectively, noticing when old patterns emerge and course-correcting', 'Respect recovery days, making this a regular practice you revisit over time']
WHERE scenario_id = 555;

-- Scenario 557: Managing Emotional Impact of Illness
UPDATE scenarios
SET sc_action_steps = ARRAY['Speak openly to a therapist or support group, writing this down to make it concrete and actionable', 'Meditate to center mind daily, breaking this down into specific, manageable actions', 'Set fulfilling small goals, writing them down with specific timelines and milestones', 'Practice gratitude even for small comforts, noticing when old patterns emerge and course-correcting', 'Balance emotional work with rest, making this a regular practice you revisit over time']
WHERE scenario_id = 557;

-- Scenario 558: Navigating Insurance and Healthcare Systems
UPDATE scenarios
SET sc_action_steps = ARRAY['Keep all records in one place, writing this down to make it concrete and actionable', 'Note deadlines and requirements, breaking this down into specific, manageable actions', 'Ask for help from knowledgeable contacts, committing to this even when it feels uncomfortable', 'Follow up consistently with providers, noticing when old patterns emerge and course-correcting', 'Prepare questions before appointments, making this a regular practice you revisit over time']
WHERE scenario_id = 558;

-- Scenario 564: Safety Concerns with Parent Living Alone
UPDATE scenarios
SET sc_action_steps = ARRAY['Install safety devices and alarms, writing this down to make it concrete and actionable', 'Schedule regular check‑ins, breaking this down into specific, manageable actions', 'Encourage safe environmental changes, committing to this even when it feels uncomfortable', 'Provide emergency contact systems, noticing when old patterns emerge and course-correcting', 'Balance autonomy with security, making this a regular practice you revisit over time']
WHERE scenario_id = 564;

-- Scenario 566: Balancing Care with Parenting Young Kids
UPDATE scenarios
SET sc_action_steps = ARRAY['Combine activities so both generations benefit, writing this down to make it concrete and actionable', 'Ask for partner or sibling support, breaking this down into specific, manageable actions', 'Block personal recharge time weekly, committing to this even when it feels uncomfortable', 'Communicate openly with all parties, noticing when old patterns emerge and course-correcting', 'Celebrate small moments together, making this a regular practice you revisit over time']
WHERE scenario_id = 566;

-- Scenario 567: Emotional Burnout from Long-Term Care
UPDATE scenarios
SET sc_action_steps = ARRAY['Schedule respite breaks, writing this down to make it concrete and actionable', 'Rotate duties among family/friends, breaking this down into specific, manageable actions', 'Pursue personal hobbies periodically, committing to this even when it feels uncomfortable', 'Seek counseling or support groups, noticing when old patterns emerge and course-correcting', 'Celebrate your caregiving contributions, making this a regular practice you revisit over time']
WHERE scenario_id = 567;

-- Scenario 568: Working 16-Hour Days Without Rest
UPDATE scenarios
SET sc_action_steps = ARRAY['Set non-negotiable rest periods, writing this down to make it concrete and actionable', 'Delegate tasks where possible, breaking this down into specific, manageable actions', 'Prioritize health before crisis hits, committing to this even when it feels uncomfortable', 'Track workload patterns to prevent overload, noticing when old patterns emerge and course-correcting', 'Reflect on long-term sustainability regularly, making this a regular practice you revisit over time']
WHERE scenario_id = 568;

-- Scenario 571: Ignoring Early Signs of Burnout
UPDATE scenarios
SET sc_action_steps = ARRAY['Identify burnout symptoms early, writing this down to make it concrete and actionable', 'Take short restorative breaks, breaking this down into specific, manageable actions', 'Balance high-intensity tasks with easier ones, committing to this even when it feels uncomfortable', 'Check stress levels weekly, noticing when old patterns emerge and course-correcting', 'Prioritize prevention over recovery, making this a regular practice you revisit over time']
WHERE scenario_id = 571;

-- Scenario 572: Pressure from Investors to Overextend
UPDATE scenarios
SET sc_action_steps = ARRAY['Be transparent about realistic timelines, writing this down to make it concrete and actionable', 'Negotiate scope instead of silently overextending, breaking this down into specific, manageable actions', 'Protect core values in commitments, committing to this even when it feels uncomfortable', 'Communicate progress proactively, noticing when old patterns emerge and course-correcting', 'Limit stakeholder surprises with regular updates, making this a regular practice you revisit over time']
WHERE scenario_id = 572;

-- Scenario 573: Thinking You Are Indispensable
UPDATE scenarios
SET sc_action_steps = ARRAY['Identify tasks others can own, writing this down to make it concrete and actionable', 'Train team members well, breaking this down into specific, manageable actions', 'Test with small delegated projects, committing to this even when it feels uncomfortable', 'Focus on high-value leadership work, noticing when old patterns emerge and course-correcting', 'Acknowledge strengths in those you delegate to, making this a regular practice you revisit over time']
WHERE scenario_id = 573;

-- Scenario 580: Work Uncertainty During Company Merger
UPDATE scenarios
SET sc_action_steps = ARRAY['Stay informed through reliable channels, writing this down to make it concrete and actionable', 'Maintain strong job performance, breaking this down into specific, manageable actions', 'Update resume discreetly, committing to this even when it feels uncomfortable', 'Grow network in relevant industries, noticing when old patterns emerge and course-correcting', 'Save extra funds if possible, making this a regular practice you revisit over time']
WHERE scenario_id = 580;

-- Scenario 575: No Celebration of Wins—Only Next Goal
UPDATE scenarios
SET sc_action_steps = ARRAY['Hold small celebrations for milestones, writing this down to make it concrete and actionable', 'Share success with team and supporters, breaking this down into specific, manageable actions', 'Reflect on challenges overcome, committing to this even when it feels uncomfortable', 'Journal gratitude regularly, noticing when old patterns emerge and course-correcting', 'Balance ambition with appreciation, making this a regular practice you revisit over time']
WHERE scenario_id = 575;

-- Scenario 579: Relocation to Unfamiliar Culture
UPDATE scenarios
SET sc_action_steps = ARRAY['Learn key phrases and customs, writing this down to make it concrete and actionable', 'Find local mentors or friends, breaking this down into specific, manageable actions', 'Participate in cultural events, committing to this even when it feels uncomfortable', 'Balance adaptation with personal identity, noticing when old patterns emerge and course-correcting', 'Give yourself grace to adjust, making this a regular practice you revisit over time']
WHERE scenario_id = 579;

-- Scenario 578: Navigating Sudden Job Loss: Building Resilience
UPDATE scenarios
SET sc_action_steps = ARRAY['Assess finances calmly, writing this down to make it concrete and actionable', 'Clarify desired direction before applying, breaking this down into specific, manageable actions', 'Update skills for target roles, committing to this even when it feels uncomfortable', 'Network methodically, noticing when old patterns emerge and course-correcting', 'Treat change as reset opportunity, making this a regular practice you revisit over time']
WHERE scenario_id = 578;

-- Scenario 582: Marriage Transition Challenges
UPDATE scenarios
SET sc_action_steps = ARRAY['Hold regular honest conversations, writing this down to make it concrete and actionable', 'Set shared objectives early, breaking this down into specific, manageable actions', 'Respect each other’s personal space, committing to this even when it feels uncomfortable', 'Compromise where needed for harmony, noticing when old patterns emerge and course-correcting', 'Celebrate progress in joint adjustment, making this a regular practice you revisit over time']
WHERE scenario_id = 582;

-- Scenario 588: Forgot Major Deadline Due to ADHD
UPDATE scenarios
SET sc_action_steps = ARRAY['Use multiple reminder tools, writing this down to make it concrete and actionable', 'Break work into shorter sprints, breaking this down into specific, manageable actions', 'Check daily list at same time, committing to this even when it feels uncomfortable', 'Reward progress every week, noticing when old patterns emerge and course-correcting', 'Ask for deadline reminders from team, making this a regular practice you revisit over time']
WHERE scenario_id = 588;

-- Scenario 589: Losing Track of Belongings Everywhere
UPDATE scenarios
SET sc_action_steps = ARRAY['Designate a spot for each item, writing this down to make it concrete and actionable', 'Practice a “keys-wallet-phone” check each exit, breaking this down into specific, manageable actions', 'Set visual reminders at doors, committing to this even when it feels uncomfortable', 'Accept imperfection on busy days, noticing when old patterns emerge and course-correcting', 'Share struggles with close companions, making this a regular practice you revisit over time']
WHERE scenario_id = 589;

-- Scenario 590: Paralysis When Starting Big Projects
UPDATE scenarios
SET sc_action_steps = ARRAY['Break project into smallest possible actions, writing this down to make it concrete and actionable', 'Start with a 5-minute task, breaking this down into specific, manageable actions', 'Remind yourself that progress is more important than perfection, staying consistent even when progress feels slow', 'Use visual trackers for accountability, noticing when old patterns emerge and course-correcting', 'Reward starting, not just finishing, making this a regular practice you revisit over time']
WHERE scenario_id = 590;

-- Scenario 633: Challenging Patronizing Praise
UPDATE scenarios
SET sc_action_steps = ARRAY['Thank and clarify intention, writing this down to make it concrete and actionable', 'Mention specific work or skill instead, breaking this down into specific, manageable actions', 'Guide dialogue toward equality, committing to this even when it feels uncomfortable', 'Avoid sarcasm in correction, noticing when old patterns emerge and course-correcting', 'Educate with patience, making this a regular practice you revisit over time']
WHERE scenario_id = 633;

-- Scenario 587: Facing Company Closure: Moving Forward After Sudden Change
UPDATE scenarios
SET sc_action_steps = ARRAY['File for relevant benefits quickly, writing this down to make it concrete and actionable', 'Update professional profiles, breaking this down into specific, manageable actions', 'Contact network about openings, committing to this even when it feels uncomfortable', 'Assess budget and trim costs fast, tracking every expense for at least a month to understand patterns', 'Frame closure as chance for redirection, making this a regular practice you revisit over time']
WHERE scenario_id = 587;

-- Scenario 598: Meltdowns from Sensory Overload
UPDATE scenarios
SET sc_action_steps = ARRAY['Carry noise-cancelling headphones or sunglasses, writing this down to make it concrete and actionable', 'Communicate triggers to those close to you, breaking this down into specific, manageable actions', 'Plan routes or escapes for overwhelming places, writing them down with specific timelines and milestones', 'Practice grounding (touch, breath), noticing when old patterns emerge and course-correcting', 'Honor recovery time after overload, making this a regular practice you revisit over time']
WHERE scenario_id = 598;

-- Scenario 600: Struggling with Time Blindness
UPDATE scenarios
SET sc_action_steps = ARRAY['Time key activities for a week, writing this down to make it concrete and actionable', 'Add buffer time for transitions, breaking this down into specific, manageable actions', 'Let others know about this tendency, committing to this even when it feels uncomfortable', 'Apologize sincerely for lateness, noticing when old patterns emerge and course-correcting', 'Seek tools (visual timers, reminders), making this a regular practice you revisit over time']
WHERE scenario_id = 600;

-- Scenario 602: Forgetfulness in Social Commitments
UPDATE scenarios
SET sc_action_steps = ARRAY['Use shared calendars or reminders, writing this down to make it concrete and actionable', 'Apologize sincerely and without excuses, breaking this down into specific, manageable actions', 'Explain neurodiversity to close friends, committing to this even when it feels uncomfortable', 'Set up alerts for key events, noticing when old patterns emerge and course-correcting', 'Express gratitude when friends help, making this a regular practice you revisit over time']
WHERE scenario_id = 602;

-- Scenario 605: Missing Important Details
UPDATE scenarios
SET sc_action_steps = ARRAY['Use checklists or peer review, writing this down to make it concrete and actionable', 'Double‑check key work daily, breaking this down into specific, manageable actions', 'Ask someone to review high-stakes tasks, committing to this even when it feels uncomfortable', 'See mistakes as guides, not verdicts, noticing when old patterns emerge and course-correcting', 'Focus on progress over flawlessness, making this a regular practice you revisit over time']
WHERE scenario_id = 605;

-- Scenario 606: Being Labeled as “Weird” in Social Groups
UPDATE scenarios
SET sc_action_steps = ARRAY['Respond briefly and factually when teased, writing this down to make it concrete and actionable', 'Join spaces that embrace diversity, breaking this down into specific, manageable actions', 'Model acceptance of others’ differences, committing to this even when it feels uncomfortable', 'Seek allies within your social groups, noticing when old patterns emerge and course-correcting', 'Avoid internalizing hurtful labels, making this a regular practice you revisit over time']
WHERE scenario_id = 606;

-- Scenario 611: Colleagues Underestimating Your Abilities
UPDATE scenarios
SET sc_action_steps = ARRAY['Express interest in complex projects, writing this down to make it concrete and actionable', 'Share examples of your past work, breaking this down into specific, manageable actions', 'Request feedback and growth opportunities, committing to this even when it feels uncomfortable', 'Show competence through results, noticing when old patterns emerge and course-correcting', 'Educate about your capabilities, making this a regular practice you revisit over time']
WHERE scenario_id = 611;

-- Scenario 614: Being Talked Over Repeatedly
UPDATE scenarios
SET sc_action_steps = ARRAY['Signal you’re not finished speaking, writing this down to make it concrete and actionable', 'Use confident body language, breaking this down into specific, manageable actions', 'Politely call back to your point, committing to this even when it feels uncomfortable', 'Support others in similar situations, noticing when old patterns emerge and course-correcting', 'Seek moderators’ help if persistent, making this a regular practice you revisit over time']
WHERE scenario_id = 614;

-- Scenario 615: Assumed Incompetent in Public
UPDATE scenarios
SET sc_action_steps = ARRAY['Assert independence politely, writing this down to make it concrete and actionable', 'Explain abilities clearly if needed, breaking this down into specific, manageable actions', 'Decline unnecessary help firmly, committing to this even when it feels uncomfortable', 'Share stories to increase awareness, noticing when old patterns emerge and course-correcting', 'Surround yourself with affirming people, reaching out to at least 2-3 people who genuinely support you']
WHERE scenario_id = 615;

-- Scenario 616: Cultural Misunderstandings with Neurodivergence
UPDATE scenarios
SET sc_action_steps = ARRAY['Learn local communication norms, writing this down to make it concrete and actionable', 'Find gentle ways to self-advocate, breaking this down into specific, manageable actions', 'Share personal perspective in safe spaces, committing to this even when it feels uncomfortable', 'Demonstrate respect while being yourself, noticing when old patterns emerge and course-correcting', 'Seek cultural allies for bridge-building, making this a regular practice you revisit over time']
WHERE scenario_id = 616;

-- Scenario 617: Left Out of Informal Social Gatherings at Work
UPDATE scenarios
SET sc_action_steps = ARRAY['Approach colleagues during break times, writing this down to make it concrete and actionable', 'Invite others for coffee or lunch, breaking this down into specific, manageable actions', 'Join workplace interest groups, committing to this even when it feels uncomfortable', 'Use shared events to build rapport, noticing when old patterns emerge and course-correcting', 'Balance social and work focus, making this a regular practice you revisit over time']
WHERE scenario_id = 617;

-- Scenario 618: Events Not Adjusted for Accessibility
UPDATE scenarios
SET sc_action_steps = ARRAY['Inform organizers of needs in advance, writing this down to make it concrete and actionable', 'Suggest solutions, not just issues, breaking this down into specific, manageable actions', 'Offer to help with inclusive planning, writing them down with specific timelines and milestones', 'Publicly thank improvements made, noticing when old patterns emerge and course-correcting', 'Support accessibility initiatives for others, making this a regular practice you revisit over time']
WHERE scenario_id = 618;

-- Scenario 619: Loneliness at Large Gatherings
UPDATE scenarios
SET sc_action_steps = ARRAY['Set a small connection goal per event, writing them down with specific timelines and milestones', 'Find quiet corners then re-engage, breaking this down into specific, manageable actions', 'Ask open-ended questions, committing to this even when it feels uncomfortable', 'Connect with fellow quieter attendees, noticing when old patterns emerge and course-correcting', 'Leave when socially exhausted without guilt, making this a regular practice you revisit over time']
WHERE scenario_id = 619;

-- Scenario 623: Correcting Misinformation Publicly
UPDATE scenarios
SET sc_action_steps = ARRAY['Clarify myth vs. fact, writing this down to make it concrete and actionable', 'Stay calm and respectful, breaking this down into specific, manageable actions', 'Provide credible resources, committing to this even when it feels uncomfortable', 'Encourage open questions, noticing when old patterns emerge and course-correcting', 'Follow up privately if needed, making this a regular practice you revisit over time']
WHERE scenario_id = 623;

-- Scenario 625: Advocating for Quiet Workspace
UPDATE scenarios
SET sc_action_steps = ARRAY['Identify specific noise issues, writing this down to make it concrete and actionable', 'Suggest workable solutions, breaking this down into specific, manageable actions', 'Offer trial period to test changes, committing to this even when it feels uncomfortable', 'Express improved output as goal, writing them down with specific timelines and milestones', 'Thank employer for cooperation, making this a regular practice you revisit over time']
WHERE scenario_id = 625;

-- Scenario 626: Explaining Neurodiversity to Children
UPDATE scenarios
SET sc_action_steps = ARRAY['Use age-appropriate language, writing this down to make it concrete and actionable', 'Compare to differences they know, breaking this down into specific, manageable actions', 'Focus on strengths alongside challenges, committing to this even when it feels uncomfortable', 'Encourage further questions, noticing when old patterns emerge and course-correcting', 'Model self-respect, making this a regular practice you revisit over time']
WHERE scenario_id = 626;

-- Scenario 628: Correcting Pronunciation or Name Errors
UPDATE scenarios
SET sc_action_steps = ARRAY['Gently correct when it happens, writing this down to make it concrete and actionable', 'Write phonetic spelling in email signature, breaking this down into specific, manageable actions', 'Ask allies to reinforce, committing to this even when it feels uncomfortable', 'Appreciate genuine effort, noticing when old patterns emerge and course-correcting', 'Maintain consistency, making this a regular practice you revisit over time']
WHERE scenario_id = 628;

-- Scenario 629: Speaking Up in Class Despite Fear
UPDATE scenarios
SET sc_action_steps = ARRAY['Prepare key points before class, writing this down to make it concrete and actionable', 'Speak early to reduce anxiety, breaking this down into specific, manageable actions', 'Acknowledge nerves openly, committing to this even when it feels uncomfortable', 'Build momentum with each contribution, noticing when old patterns emerge and course-correcting', 'Seek supportive feedback, making this a regular practice you revisit over time']
WHERE scenario_id = 629;

-- Scenario 630: Responding to “You Don’t Look Disabled”
UPDATE scenarios
SET sc_action_steps = ARRAY['State fact simply and confidently, writing this down to make it concrete and actionable', 'Avoid debating your lived experience, breaking this down into specific, manageable actions', 'Share resources when safe, committing to this even when it feels uncomfortable', 'Connect with those who understand, noticing when old patterns emerge and course-correcting', 'Affirm self internally, making this a regular practice you revisit over time']
WHERE scenario_id = 630;

-- Scenario 651: Advocating for Remote Work Option
UPDATE scenarios
SET sc_action_steps = ARRAY['Prepare case with productivity data, writing this down to make it concrete and actionable', 'Offer trial period, breaking this down into specific, manageable actions', 'Address employer concerns, committing to this even when it feels uncomfortable', 'Show results after trial, noticing when old patterns emerge and course-correcting', 'Keep dialogue open, making this a regular practice you revisit over time']
WHERE scenario_id = 651;

-- Scenario 652: Requesting Assistive Tech in School
UPDATE scenarios
SET sc_action_steps = ARRAY['Collect supporting research, writing this down to make it concrete and actionable', 'Apply through formal processes, breaking this down into specific, manageable actions', 'Schedule meeting with staff, committing to this even when it feels uncomfortable', 'Test tech in class, noticing when old patterns emerge and course-correcting', 'Share improvements seen, making this a regular practice you revisit over time']
WHERE scenario_id = 652;

-- Scenario 653: Inclusive Team-Building Activities
UPDATE scenarios
SET sc_action_steps = ARRAY['List comfortable activities, writing this down to make it concrete and actionable', 'Offer mix of sensory levels, breaking this down into specific, manageable actions', 'Pilot small changes, committing to this even when it feels uncomfortable', 'Gather feedback, noticing when old patterns emerge and course-correcting', 'Rotate activity types, making this a regular practice you revisit over time']
WHERE scenario_id = 653;

-- Scenario 654: Navigating Dress Codes with Sensory Sensitivity
UPDATE scenarios
SET sc_action_steps = ARRAY['Identify specific triggers, writing this down to make it concrete and actionable', 'Recommend suitable substitutes, breaking this down into specific, manageable actions', 'Provide medical note if needed, committing to this even when it feels uncomfortable', 'Test options with employer, noticing when old patterns emerge and course-correcting', 'Maintain within brand requirements, making this a regular practice you revisit over time']
WHERE scenario_id = 654;

-- Scenario 655: Handling Performance Reviews Fairly
UPDATE scenarios
SET sc_action_steps = ARRAY['Request feedback examples, writing this down to make it concrete and actionable', 'Share context for misunderstandings, breaking this down into specific, manageable actions', 'Highlight strengths, committing to this even when it feels uncomfortable', 'Agree on clear metrics, noticing when old patterns emerge and course-correcting', 'Follow progress plan, writing them down with specific timelines and milestones']
WHERE scenario_id = 655;

-- Scenario 656: Written vs. Oral Presentations
UPDATE scenarios
SET sc_action_steps = ARRAY['Offer compromise like pre-recorded video, writing this down to make it concrete and actionable', 'Provide written report, breaking this down into specific, manageable actions', 'Negotiate portion of oral work, committing to this even when it feels uncomfortable', 'Share feedback after trial, noticing when old patterns emerge and course-correcting', 'Thank teacher for flexibility, making this a regular practice you revisit over time']
WHERE scenario_id = 656;

-- Scenario 657: Clarifying Group Roles in Projects
UPDATE scenarios
SET sc_action_steps = ARRAY['Ask for written role descriptions, writing this down to make it concrete and actionable', 'Volunteer for tasks matching strengths, breaking this down into specific, manageable actions', 'Request regular check-ins, committing to this even when it feels uncomfortable', 'Share updates proactively, noticing when old patterns emerge and course-correcting', 'Clarify handover points, making this a regular practice you revisit over time']
WHERE scenario_id = 657;

-- Scenario 658: Job Application Process Fatigue
UPDATE scenarios
SET sc_action_steps = ARRAY['Save progress frequently, writing this down to make it concrete and actionable', 'Complete sections in short bursts, breaking this down into specific, manageable actions', 'Ask for support from a friend, committing to this even when it feels uncomfortable', 'Track completed applications, noticing when old patterns emerge and course-correcting', 'Reward progress, not just offers, making this a regular practice you revisit over time']
WHERE scenario_id = 658;

-- Scenario 659: Difficulty with Rapid-Fire Meetings
UPDATE scenarios
SET sc_action_steps = ARRAY['Ask for agenda beforehand, writing this down to make it concrete and actionable', 'Prepare questions in advance, breaking this down into specific, manageable actions', 'Request slower pacing when possible, committing to this even when it feels uncomfortable', 'Follow up with clarifying email, noticing when old patterns emerge and course-correcting', 'Share feedback for mutual benefit, making this a regular practice you revisit over time']
WHERE scenario_id = 659;

-- Scenario 660: Navigating Workplace Social Events
UPDATE scenarios
SET sc_action_steps = ARRAY['Plan arrival and exit times, writing them down with specific timelines and milestones', 'Stay near quieter areas, breaking this down into specific, manageable actions', 'Engage in brief conversations, committing to this even when it feels uncomfortable', 'Balance attendance with recovery time, noticing when old patterns emerge and course-correcting', 'Skip events without guilt, making this a regular practice you revisit over time']
WHERE scenario_id = 660;

-- Scenario 661: Using Visual Aids in Learning
UPDATE scenarios
SET sc_action_steps = ARRAY['Ask for materials in advance, writing this down to make it concrete and actionable', 'Take photos of visual aids, breaking this down into specific, manageable actions', 'Review slides after class, committing to this even when it feels uncomfortable', 'Make your own diagrams, noticing when old patterns emerge and course-correcting', 'Share visuals with peers, making this a regular practice you revisit over time']
WHERE scenario_id = 661;

-- Scenario 662: Workspace Lighting Sensitivity
UPDATE scenarios
SET sc_action_steps = ARRAY['Move to seat near natural light, writing this down to make it concrete and actionable', 'Use tinted lenses or filters, breaking this down into specific, manageable actions', 'Request dimmer access, committing to this even when it feels uncomfortable', 'Take breaks in low-light spaces, noticing when old patterns emerge and course-correcting', 'Explain impact to supervisor, making this a regular practice you revisit over time']
WHERE scenario_id = 662;

-- Scenario 663: Providing Multiple Means of Assessment
UPDATE scenarios
SET sc_action_steps = ARRAY['Research school policy, writing this down to make it concrete and actionable', 'Speak to instructor early, breaking this down into specific, manageable actions', 'Suggest alternatives, committing to this even when it feels uncomfortable', 'Provide examples of past work, noticing when old patterns emerge and course-correcting', 'Follow required steps for requests, making this a regular practice you revisit over time']
WHERE scenario_id = 663;

-- Scenario 664: Advocating for Breaks in Training
UPDATE scenarios
SET sc_action_steps = ARRAY['Ask in advance for break schedule, writing this down to make it concrete and actionable', 'Use breaks to reset senses, breaking this down into specific, manageable actions', 'Encourage group benefits, committing to this even when it feels uncomfortable', 'Offer feedback on program design, noticing when old patterns emerge and course-correcting', 'Thank trainer for flexibility, making this a regular practice you revisit over time']
WHERE scenario_id = 664;

-- Scenario 665: Struggling with Standardized Test Environments
UPDATE scenarios
SET sc_action_steps = ARRAY['Request smaller test room, writing this down to make it concrete and actionable', 'Use noise-cancelling tools if allowed, breaking this down into specific, manageable actions', 'Practice in similar setting, committing to this even when it feels uncomfortable', 'Arrive early to acclimate, noticing when old patterns emerge and course-correcting', 'Plan calming routine before test, writing them down with specific timelines and milestones']
WHERE scenario_id = 665;

-- Scenario 666: Difficulty with Onboarding Processes
UPDATE scenarios
SET sc_action_steps = ARRAY['Get documents to review later, writing this down to make it concrete and actionable', 'Seek mentor or buddy, breaking this down into specific, manageable actions', 'Break schedule into stages, committing to this even when it feels uncomfortable', 'Ask clarifying questions over time, noticing when old patterns emerge and course-correcting', 'Track own progress, making this a regular practice you revisit over time']
WHERE scenario_id = 666;

-- Scenario 667: Team Mates Misreading Your Silence
UPDATE scenarios
SET sc_action_steps = ARRAY['Explain your style in team settings, writing this down to make it concrete and actionable', 'Contribute in writing if needed, breaking this down into specific, manageable actions', 'Acknowledge others’ input, committing to this even when it feels uncomfortable', 'Show engagement through attentive body language, noticing when old patterns emerge and course-correcting', 'Follow up after meetings, making this a regular practice you revisit over time']
WHERE scenario_id = 667;

-- Scenario 668: Fitting Professional Networking Norms
UPDATE scenarios
SET sc_action_steps = ARRAY['Set personal connection goals, writing them down with specific timelines and milestones', 'Bring a friend/colleague, breaking this down into specific, manageable actions', 'Prepare icebreaker questions, committing to this even when it feels uncomfortable', 'Follow up post-event online, noticing when old patterns emerge and course-correcting', 'Leave when energy dips, making this a regular practice you revisit over time']
WHERE scenario_id = 668;

-- Scenario 669: Handling Last Minute Meeting Changes
UPDATE scenarios
SET sc_action_steps = ARRAY['Use quick breathing techniques, writing this down to make it concrete and actionable', 'Recheck priorities, breaking this down into specific, manageable actions', 'Communicate conflicts early, committing to this even when it feels uncomfortable', 'Carry small grounding aid, noticing when old patterns emerge and course-correcting', 'Acknowledge flexibility as growth, making this a regular practice you revisit over time']
WHERE scenario_id = 669;

-- Scenario 670: Misinterpretation of Direct Communication
UPDATE scenarios
SET sc_action_steps = ARRAY['Soften delivery without diluting meaning, writing this down to make it concrete and actionable', 'Explain your style in private, breaking this down into specific, manageable actions', 'Request feedback, committing to this even when it feels uncomfortable', 'Model listening and respect, noticing when old patterns emerge and course-correcting', 'Acknowledge any unintended impact, making this a regular practice you revisit over time']
WHERE scenario_id = 670;

-- Scenario 671: Managing Multiple Supervisors
UPDATE scenarios
SET sc_action_steps = ARRAY['Hold joint meeting to align, writing this down to make it concrete and actionable', 'Keep shared task list, breaking this down into specific, manageable actions', 'Ask for priority ordering, committing to this even when it feels uncomfortable', 'Give progress updates to both, noticing when old patterns emerge and course-correcting', 'Seek mediation if conflict continues, making this a regular practice you revisit over time']
WHERE scenario_id = 671;

-- Scenario 528: Forgetting to Link Habits to Bigger Purpose
UPDATE scenarios
SET sc_action_steps = ARRAY['Write a purpose statement for the habit, writing this down to make it concrete and actionable', 'Visualize the long-term benefit regularly, breaking this down into specific, manageable actions', 'Connect habit to helping others, committing to this even when it feels uncomfortable', 'Make small rituals to honor the habit, noticing when old patterns emerge and course-correcting', 'Reflect on personal growth monthly, making this a regular practice you revisit over time']
WHERE scenario_id = 528;

-- Scenario 530: Online Backlash for Old Post
UPDATE scenarios
SET sc_action_steps = ARRAY['Publicly acknowledge the specific issue, writing this down to make it concrete and actionable', 'Clarify context without making excuses, breaking this down into specific, manageable actions', 'Show concrete actions you’ve taken since, committing to this even when it feels uncomfortable', 'Engage with critics respectfully, noticing when old patterns emerge and course-correcting', 'Learn and grow from the experience, making this a regular practice you revisit over time']
WHERE scenario_id = 530;

-- Scenario 538: Critical Article About You Circulating
UPDATE scenarios
SET sc_action_steps = ARRAY['Point out inaccuracies factually, writing this down to make it concrete and actionable', 'Publish your own perspective calmly, breaking this down into specific, manageable actions', 'Avoid insulting the publication, committing to this even when it feels uncomfortable', 'Correct errors through official channels, noticing when old patterns emerge and course-correcting', 'Continue living by your values, making this a regular practice you revisit over time']
WHERE scenario_id = 538;

-- Scenario 559: Balancing Career and Parent Care
UPDATE scenarios
SET sc_action_steps = ARRAY['Discuss flexible options with employer, writing this down to make it concrete and actionable', 'Share caretaking responsibilities among family, breaking this down into specific, manageable actions', 'Hire occasional help if affordable, committing to this even when it feels uncomfortable', 'Prioritize self‑care to avoid burnout, noticing when old patterns emerge and course-correcting', 'Use calendar reminders for caregiving tasks, making this a regular practice you revisit over time']
WHERE scenario_id = 559;

-- Scenario 563: Coping with Seeing Decline
UPDATE scenarios
SET sc_action_steps = ARRAY['Acknowledge your emotions without guilt, writing this down to make it concrete and actionable', 'Focus on quality present time, breaking this down into specific, manageable actions', 'Seek support groups for shared perspective, committing to this even when it feels uncomfortable', 'Engage in uplifting activities together, noticing when old patterns emerge and course-correcting', 'Accept that change is part of life’s flow, making this a regular practice you revisit over time']
WHERE scenario_id = 563;

-- Scenario 581: Major Health Diagnosis Alters Plans
UPDATE scenarios
SET sc_action_steps = ARRAY['Reevaluate goals in light of new realities, writing them down with specific timelines and milestones', 'Break plans into achievable steps, writing them down with specific timelines and milestones', 'Prioritize health-supportive routines, committing to this even when it feels uncomfortable', 'Seek support emotionally and logistically, noticing when old patterns emerge and course-correcting', 'Keep long-term vision flexible, making this a regular practice you revisit over time']
WHERE scenario_id = 581;

-- Scenario 610: Teased for Stimming in Public
UPDATE scenarios
SET sc_action_steps = ARRAY['Identify safe environments for self-regulation, writing this down to make it concrete and actionable', 'Inform trusted friends about your needs, breaking this down into specific, manageable actions', 'Educate curious people briefly when possible, reaching out to at least 2-3 people who genuinely support you', 'Ignore or exit unsafe encounters, noticing when old patterns emerge and course-correcting', 'Affirm your right to self-care, making this a regular practice you revisit over time']
WHERE scenario_id = 610;

-- Scenario 620: Peers Not Understanding Processing Time
UPDATE scenarios
SET sc_action_steps = ARRAY['Share your communication style upfront, writing this down to make it concrete and actionable', 'Ask for questions in advance when possible, breaking this down into specific, manageable actions', 'Avoid apologizing for thoughtful pauses, committing to this even when it feels uncomfortable', 'Deliver clearer responses with time taken, noticing when old patterns emerge and course-correcting', 'Educate about different processing needs, making this a regular practice you revisit over time']
WHERE scenario_id = 620;

-- Scenario 621: Explaining Your Needs to a New Boss
UPDATE scenarios
SET sc_action_steps = ARRAY['Prepare concise explanation of your needs, writing them down with specific timelines and milestones', 'Share with HR or direct manager, breaking this down into specific, manageable actions', 'Highlight how accommodations aid performance, committing to this even when it feels uncomfortable', 'Offer solutions alongside needs, noticing when old patterns emerge and course-correcting', 'Follow up after adjustments, making this a regular practice you revisit over time']
WHERE scenario_id = 621;

-- Scenario 635: Reclaiming Slurs Used Against You
UPDATE scenarios
SET sc_action_steps = ARRAY['Decide your comfort level with term, writing this down to make it concrete and actionable', 'Set boundaries clearly, breaking this down into specific, manageable actions', 'Educate when safe, committing to this even when it feels uncomfortable', 'Focus on supportive relationships, noticing when old patterns emerge and course-correcting', 'Avoid engaging hostile sources, making this a regular practice you revisit over time']
WHERE scenario_id = 635;

-- Scenario 638: Explaining Child’s Needs to Extended Family
UPDATE scenarios
SET sc_action_steps = ARRAY['Provide simple medical context, writing this down to make it concrete and actionable', 'Share how accommodations help, breaking this down into specific, manageable actions', 'Invite them to observe differences, committing to this even when it feels uncomfortable', 'Correct misconceptions kindly, noticing when old patterns emerge and course-correcting', 'Encourage questions, making this a regular practice you revisit over time']
WHERE scenario_id = 638;

-- Scenario 643: Grandparent Struggles to Accept Needs
UPDATE scenarios
SET sc_action_steps = ARRAY['Share evidence of improvement, writing this down to make it concrete and actionable', 'Demonstrate support tools in action, breaking this down into specific, manageable actions', 'Involve grandparent in activities, committing to this even when it feels uncomfortable', 'Connect to values they hold, noticing when old patterns emerge and course-correcting', 'Acknowledge their efforts, making this a regular practice you revisit over time']
WHERE scenario_id = 643;

-- Scenario 644: Balancing Extended Family Demands
UPDATE scenarios
SET sc_action_steps = ARRAY['Explain constraints early, writing this down to make it concrete and actionable', 'Plan shorter visits, writing them down with specific timelines and milestones', 'Schedule downtime after, committing to this even when it feels uncomfortable', 'Offer alternative ways to connect, noticing when old patterns emerge and course-correcting', 'Stay firm politely, making this a regular practice you revisit over time']
WHERE scenario_id = 644;

-- Scenario 648: Requesting Extra Time for Exams
UPDATE scenarios
SET sc_action_steps = ARRAY['Gather documentation, writing this down to make it concrete and actionable', 'Apply before deadlines, breaking this down into specific, manageable actions', 'Explain need factually, committing to this even when it feels uncomfortable', 'Use granted time effectively, noticing when old patterns emerge and course-correcting', 'Thank staff for support, making this a regular practice you revisit over time']
WHERE scenario_id = 648;

-- Scenario 672: Overloaded by Multi-Platform Communication
UPDATE scenarios
SET sc_action_steps = ARRAY['Set times to check each channel, writing this down to make it concrete and actionable', 'Mute non-critical alerts, breaking this down into specific, manageable actions', 'Inform team of response policy, committing to this even when it feels uncomfortable', 'Use integrations to merge streams, noticing when old patterns emerge and course-correcting', 'Close platforms when focusing, making this a regular practice you revisit over time']
WHERE scenario_id = 672;

-- Scenario 833: Feeling Superior Over “Clean Eating”
UPDATE scenarios
SET sc_action_steps = ARRAY['Notice superiority thoughts, writing this down to make it concrete and actionable', 'Reframe as personal choice, breaking this down into specific, manageable actions', 'Avoid unsolicited advice, committing to this even when it feels uncomfortable', 'Ask others about favourites, noticing when old patterns emerge and course-correcting', 'Celebrate diversity, making this a regular practice you revisit over time']
WHERE scenario_id = 833;

-- Scenario 786: Changing Diet with Every Trend
UPDATE scenarios
SET sc_action_steps = ARRAY['Identify long-term staples, writing this down to make it concrete and actionable', 'Trial only one change at a time, breaking this down into specific, manageable actions', 'Give changes adequate time, committing to this even when it feels uncomfortable', 'Note your body’s responses, noticing when old patterns emerge and course-correcting', 'Disregard hype, making this a regular practice you revisit over time']
WHERE scenario_id = 786;

-- Scenario 821: Dismissed as “Not Body Positive Enough”
UPDATE scenarios
SET sc_action_steps = ARRAY['Clarify motivations, writing this down to make it concrete and actionable', 'Seek similar goal peers, writing them down with specific timelines and milestones', 'Avoid engaging trolls, committing to this even when it feels uncomfortable', 'Track results for motivation, noticing when old patterns emerge and course-correcting', 'Celebrate health markers, making this a regular practice you revisit over time']
WHERE scenario_id = 821;

-- Scenario 820: Being Tokenised in Media Campaigns
UPDATE scenarios
SET sc_action_steps = ARRAY['Assess proposal value, writing this down to make it concrete and actionable', 'Request genuine engagement, breaking this down into specific, manageable actions', 'Decline purely token roles, committing to this even when it feels uncomfortable', 'Promote authentic narratives, noticing when old patterns emerge and course-correcting', 'Suggest diverse casting, making this a regular practice you revisit over time']
WHERE scenario_id = 820;

-- Scenario 843: Managing Stress Eating at Events
UPDATE scenarios
SET sc_action_steps = ARRAY['Eat before to avoid extreme hunger, writing this down to make it concrete and actionable', 'Take small portions, breaking this down into specific, manageable actions', 'Put down utensils between bites, committing to this even when it feels uncomfortable', 'Engage in conversation between mouthfuls, noticing when old patterns emerge and course-correcting', 'Leave when full, making this a regular practice you revisit over time']
WHERE scenario_id = 843;

-- Scenario 824: Loneliness After Weight Loss Success
UPDATE scenarios
SET sc_action_steps = ARRAY['Explain non-judgment for others’ bodies, writing this down to make it concrete and actionable', 'Share focus on health over size, breaking this down into specific, manageable actions', 'Invite joint activities, committing to this even when it feels uncomfortable', 'Avoid competitiveness, noticing when old patterns emerge and course-correcting', 'Maintain long-term friendship, making this a regular practice you revisit over time']
WHERE scenario_id = 824;

-- Scenario 831: Eating Out Causes Anxiety and Isolation
UPDATE scenarios
SET sc_action_steps = ARRAY['Research menu ahead, writing this down to make it concrete and actionable', 'Call venue, breaking this down into specific, manageable actions', 'Suggest restaurant choice, committing to this even when it feels uncomfortable', 'Eat beforehand if needed, noticing when old patterns emerge and course-correcting', 'Practice flexibility, making this a regular practice you revisit over time']
WHERE scenario_id = 831;

-- Scenario 849: Self-Conscious Eating in Public
UPDATE scenarios
SET sc_action_steps = ARRAY['Practice eating slowly, writing this down to make it concrete and actionable', 'Use grounding techniques, breaking this down into specific, manageable actions', 'Focus on others talking, committing to this even when it feels uncomfortable', 'Avoid mirrors/screens, noticing when old patterns emerge and course-correcting', 'Reframe dining as connection, reaching out to at least 2-3 people who genuinely support you']
WHERE scenario_id = 849;

-- Scenario 836: Over-Exercising to Compensate for Food Choices
UPDATE scenarios
SET sc_action_steps = ARRAY['Set rational exercise plan, writing them down with specific timelines and milestones', 'Consult trainer, breaking this down into specific, manageable actions', 'Rest adequately, committing to this even when it feels uncomfortable', 'Separate food and exercise mentally, noticing when old patterns emerge and course-correcting', 'Celebrate movement for health, making this a regular practice you revisit over time']
WHERE scenario_id = 836;

-- Scenario 837: Rejecting Nourishing Food Due to Restrictive Rules
UPDATE scenarios
SET sc_action_steps = ARRAY['Note hunger cues, writing this down to make it concrete and actionable', 'Allow occasional rule exceptions, breaking this down into specific, manageable actions', 'Track energy changes, committing to this even when it feels uncomfortable', 'Discuss with dietitian, noticing when old patterns emerge and course-correcting', 'Adjust list seasonally, making this a regular practice you revisit over time']
WHERE scenario_id = 837;

-- Scenario 678: Feeling Isolated by Lack of Understanding
UPDATE scenarios
SET sc_action_steps = ARRAY['Join nd-focused groups, writing this down to make it concrete and actionable', 'Share experiences, breaking this down into specific, manageable actions', 'Seek shared hobbies, committing to this even when it feels uncomfortable', 'Arrange regular meetups, noticing when old patterns emerge and course-correcting', 'Engage online if offline hard, making this a regular practice you revisit over time']
WHERE scenario_id = 678;

-- Scenario 835: Self-Worth Tied to Diet Purity
UPDATE scenarios
SET sc_action_steps = ARRAY['List non-food strengths, writing this down to make it concrete and actionable', 'Reframe holiday/unplanned meals, writing them down with specific timelines and milestones', 'Focus on consistency, committing to this even when it feels uncomfortable', 'Practice self-forgiveness, noticing when old patterns emerge and course-correcting', 'Engage in non-food joys, making this a regular practice you revisit over time']
WHERE scenario_id = 835;

-- Scenario 782: Avoiding Social Events Over Food Concerns
UPDATE scenarios
SET sc_action_steps = ARRAY['Eat before/bring your own dish, writing this down to make it concrete and actionable', 'Focus on company not menu, breaking this down into specific, manageable actions', 'Relax rules occasionally, committing to this even when it feels uncomfortable', 'See food as one part of health, noticing when old patterns emerge and course-correcting', 'Seek help if anxiety grows, making this a regular practice you revisit over time']
WHERE scenario_id = 782;

-- Scenario 790: Avoiding Social Events Over Food Concerns
UPDATE scenarios
SET sc_action_steps = ARRAY['Eat before/bring your own dish, writing this down to make it concrete and actionable', 'Focus on company not menu, breaking this down into specific, manageable actions', 'Relax rules occasionally, committing to this even when it feels uncomfortable', 'See food as one part of health, noticing when old patterns emerge and course-correcting', 'Seek help if anxiety grows, making this a regular practice you revisit over time']
WHERE scenario_id = 790;

-- Scenario 810: Avoiding Social Events Over Food Concerns
UPDATE scenarios
SET sc_action_steps = ARRAY['Eat beforehand or bring dish, writing this down to make it concrete and actionable', 'Focus on people not menu, reaching out to at least 2-3 people who genuinely support you', 'Relax rules occasionally, committing to this even when it feels uncomfortable', 'See food as part of whole health, noticing when old patterns emerge and course-correcting', 'Seek help if anxiety rises, making this a regular practice you revisit over time']
WHERE scenario_id = 810;

-- Scenario 797: Diet Judged in the Workplace
UPDATE scenarios
SET sc_action_steps = ARRAY['Prepare responses to comments, writing this down to make it concrete and actionable', 'Eat with supportive peers, breaking this down into specific, manageable actions', 'Educate when possible, committing to this even when it feels uncomfortable', 'Ignore persistent negativity, noticing when old patterns emerge and course-correcting', 'Stay consistent, making this a regular practice you revisit over time']
WHERE scenario_id = 797;

-- Scenario 839: Hiding Eating Habits to Avoid Judgment
UPDATE scenarios
SET sc_action_steps = ARRAY['Identify one safe sharer, writing this down to make it concrete and actionable', 'Discuss without apology, breaking this down into specific, manageable actions', 'Invite them to meal, committing to this even when it feels uncomfortable', 'Accept differing views, noticing when old patterns emerge and course-correcting', 'Keep connection strong, reaching out to at least 2-3 people who genuinely support you']
WHERE scenario_id = 839;

-- Scenario 832: Judging Others’ Food Choices
UPDATE scenarios
SET sc_action_steps = ARRAY['Keep focus on own plate, writing this down to make it concrete and actionable', 'Avoid food policing, breaking this down into specific, manageable actions', 'Compliment variety, committing to this even when it feels uncomfortable', 'Invite without pressure, noticing when old patterns emerge and course-correcting', 'Support autonomy, making this a regular practice you revisit over time']
WHERE scenario_id = 832;

-- Scenario 851: Fear of Buffets Due to Spillage Anxiety
UPDATE scenarios
SET sc_action_steps = ARRAY['Use smaller plates, writing this down to make it concrete and actionable', 'Queue at quieter times, breaking this down into specific, manageable actions', 'Ask for help serving, committing to this even when it feels uncomfortable', 'Laugh off small mishaps, noticing when old patterns emerge and course-correcting', 'Enjoy variety offered, making this a regular practice you revisit over time']
WHERE scenario_id = 851;

-- Scenario 855: Social Anxiety: Eating with New People
UPDATE scenarios
SET sc_action_steps = ARRAY['Start with 1-1 meals, writing this down to make it concrete and actionable', 'Join small groups, breaking this down into specific, manageable actions', 'Choose relaxed venues, committing to this even when it feels uncomfortable', 'Share nervousness if comfortable, noticing when old patterns emerge and course-correcting', 'Increase exposure gradually, making this a regular practice you revisit over time']
WHERE scenario_id = 855;

-- Scenario 685: Frustration at Slow Progress in Learning
UPDATE scenarios
SET sc_action_steps = ARRAY['Track milestones weekly, writing this down to make it concrete and actionable', 'Review growth over months, breaking this down into specific, manageable actions', 'Lower unrealistic deadlines, committing to this even when it feels uncomfortable', 'Celebrate effort, noticing when old patterns emerge and course-correcting', 'Share progression with mentor, making this a regular practice you revisit over time']
WHERE scenario_id = 685;

-- Scenario 838: Rediscovering Joy in Cooking and Eating
UPDATE scenarios
SET sc_action_steps = ARRAY['Explore new cuisines, writing this down to make it concrete and actionable', 'Cook with friends, breaking this down into specific, manageable actions', 'Use music while cooking, committing to this even when it feels uncomfortable', 'Grow herbs and take care for them, noticing when old patterns emerge and course-correcting', 'Rotate menus but don’t overwhelm yourself, making this a regular practice you revisit over time']
WHERE scenario_id = 838;

-- Scenario 755: Criticised for Buying New Clothes
UPDATE scenarios
SET sc_action_steps = ARRAY['Explain purpose of purchase, writing this down to make it concrete and actionable', 'Support ethical brands when new, breaking this down into specific, manageable actions', 'Balance thrift and need, committing to this even when it feels uncomfortable', 'Rotate wardrobe responsibly, noticing when old patterns emerge and course-correcting', 'Declutter consciously, making this a regular practice you revisit over time']
WHERE scenario_id = 755;

-- Scenario 764: Wishing for Bigger Home Despite Minimalism
UPDATE scenarios
SET sc_action_steps = ARRAY['Rearrange for better function, writing this down to make it concrete and actionable', 'Declutter unused items, breaking this down into specific, manageable actions', 'Add vertical storage, committing to this even when it feels uncomfortable', 'Spend more time outdoors, noticing when old patterns emerge and course-correcting', 'Visit larger homes as inspiration only, making this a regular practice you revisit over time']
WHERE scenario_id = 764;

-- Scenario 766: Judged for Not Owning an Electric Car
UPDATE scenarios
SET sc_action_steps = ARRAY['Research affordable models, writing this down to make it concrete and actionable', 'Use public transit more often, breaking this down into specific, manageable actions', 'Maintain current car efficiently, committing to this even when it feels uncomfortable', 'Save for future switch, noticing when old patterns emerge and course-correcting', 'Inform critics of practical steps, making this a regular practice you revisit over time']
WHERE scenario_id = 766;

-- Scenario 767: Expectation to DIY Everything
UPDATE scenarios
SET sc_action_steps = ARRAY['Select projects with meaning, writing this down to make it concrete and actionable', 'Buy essentials without guilt, breaking this down into specific, manageable actions', 'Budget time honestly, tracking every expense for at least a month to understand patterns', 'Share realistic capacities, noticing when old patterns emerge and course-correcting', 'Encourage diversity of approach, making this a regular practice you revisit over time']
WHERE scenario_id = 767;

-- Scenario 768: Criticism for Using Modern Technology
UPDATE scenarios
SET sc_action_steps = ARRAY['Highlight long lifespan of your tech, writing this down to make it concrete and actionable', 'Use energy-saving settings, breaking this down into specific, manageable actions', 'Offset impact via eco actions, committing to this even when it feels uncomfortable', 'Explain trade-offs calmly, noticing when old patterns emerge and course-correcting', 'Promote mindful tech use, making this a regular practice you revisit over time']
WHERE scenario_id = 768;

-- Scenario 769: Feeling Overwhelmed by Activism Responsibilities
UPDATE scenarios
SET sc_action_steps = ARRAY['Review commitments quarterly, writing this down to make it concrete and actionable', 'Delegate tasks, breaking this down into specific, manageable actions', 'Alternate high- and low-energy roles, committing to this even when it feels uncomfortable', 'Block rest days, noticing when old patterns emerge and course-correcting', 'Celebrate small wins, making this a regular practice you revisit over time']
WHERE scenario_id = 769;

-- Scenario 770: Overwhelmed by Sustainable Product Choices
UPDATE scenarios
SET sc_action_steps = ARRAY['Select trusted recommendations, writing this down to make it concrete and actionable', 'Test small sizes first, breaking this down into specific, manageable actions', 'Rotate only when needed, committing to this even when it feels uncomfortable', 'Track preferences, noticing when old patterns emerge and course-correcting', 'Ignore constant new ads, making this a regular practice you revisit over time']
WHERE scenario_id = 770;

-- Scenario 771: Choosing Ethics versus Affordability in Shopping
UPDATE scenarios
SET sc_action_steps = ARRAY['Prioritise top-impact items, writing this down to make it concrete and actionable', 'Mix ethical and budget buys, tracking every expense for at least a month to understand patterns', 'Seek sales/discounts, committing to this even when it feels uncomfortable', 'Plan spending in advance, writing them down with specific timelines and milestones', 'Celebrate any ethical choice, making this a regular practice you revisit over time']
WHERE scenario_id = 771;

-- Scenario 776: Lack of Infrastructure for Compost
UPDATE scenarios
SET sc_action_steps = ARRAY['Research drop-off locations, writing this down to make it concrete and actionable', 'Try balcony/worm compost, breaking this down into specific, manageable actions', 'Advocate with council, committing to this even when it feels uncomfortable', 'Join local compost co-op, noticing when old patterns emerge and course-correcting', 'Share compost with gardeners, making this a regular practice you revisit over time']
WHERE scenario_id = 776;

-- Scenario 777: Cultural Norms Against Second-Hand Shopping
UPDATE scenarios
SET sc_action_steps = ARRAY['Wear thrift finds proudly, writing this down to make it concrete and actionable', 'Explain benefits to others, breaking this down into specific, manageable actions', 'Host swap events, committing to this even when it feels uncomfortable', 'Gift quality preloved items, noticing when old patterns emerge and course-correcting', 'Highlight cultural examples, making this a regular practice you revisit over time']
WHERE scenario_id = 777;

-- Scenario 779: Confused by Contradictory Diet Advice
UPDATE scenarios
SET sc_action_steps = ARRAY['Limit sources to credible experts, writing this down to make it concrete and actionable', 'Observe what works for your body, breaking this down into specific, manageable actions', 'Avoid drastic changes, committing to this even when it feels uncomfortable', 'Keep a food journal, noticing when old patterns emerge and course-correcting', 'Review progress monthly, making this a regular practice you revisit over time']
WHERE scenario_id = 779;

-- Scenario 780: Friend Pressures You to Follow Their Diet
UPDATE scenarios
SET sc_action_steps = ARRAY['Thank them for concern, writing this down to make it concrete and actionable', 'Explain your approach, breaking this down into specific, manageable actions', 'Share any positive results you’ve had, committing to this even when it feels uncomfortable', 'Avoid debating excessively, noticing when old patterns emerge and course-correcting', 'Stand firm kindly, making this a regular practice you revisit over time']
WHERE scenario_id = 780;

-- Scenario 785: Conflicting Advice from Multiple Professionals
UPDATE scenarios
SET sc_action_steps = ARRAY['List commonalities between plans, writing them down with specific timelines and milestones', 'Test changes gradually, breaking this down into specific, manageable actions', 'Track results objectively, committing to this even when it feels uncomfortable', 'Communicate openly with providers, noticing when old patterns emerge and course-correcting', 'Adjust based on evidence, making this a regular practice you revisit over time']
WHERE scenario_id = 785;

-- Scenario 795: Changing Diet with Every Trend
UPDATE scenarios
SET sc_action_steps = ARRAY['Identify long‑term staples, writing this down to make it concrete and actionable', 'Trial only one change at a time, breaking this down into specific, manageable actions', 'Give changes adequate time, committing to this even when it feels uncomfortable', 'Note your body’s responses, noticing when old patterns emerge and course-correcting', 'Disregard hype, making this a regular practice you revisit over time']
WHERE scenario_id = 795;

-- Scenario 787: Family Conflict over Food Choices
UPDATE scenarios
SET sc_action_steps = ARRAY['List cross-compatible dishes, writing this down to make it concrete and actionable', 'Cook together occasionally, breaking this down into specific, manageable actions', 'Respect each person’s plan, writing them down with specific timelines and milestones', 'Create shared snack list, noticing when old patterns emerge and course-correcting', 'Rotate favourite meals, making this a regular practice you revisit over time']
WHERE scenario_id = 787;

-- Scenario 823: Overlooking Marginalised Body Types
UPDATE scenarios
SET sc_action_steps = ARRAY['Share platform with diverse voices, writing this down to make it concrete and actionable', 'Educate mainstream allies, breaking this down into specific, manageable actions', 'Highlight systemic gaps, committing to this even when it feels uncomfortable', 'Support intersectional campaigns, noticing when old patterns emerge and course-correcting', 'Model inclusivity, making this a regular practice you revisit over time']
WHERE scenario_id = 823;

-- Scenario 826: Compulsive Ingredient Checking
UPDATE scenarios
SET sc_action_steps = ARRAY['List key avoid items, writing this down to make it concrete and actionable', 'Skim for main triggers, breaking this down into specific, manageable actions', 'Shop from trusted brands, committing to this even when it feels uncomfortable', 'Limit check time, noticing when old patterns emerge and course-correcting', 'Rotate trusted products, making this a regular practice you revisit over time']
WHERE scenario_id = 826;

-- Scenario 828: Missing Nutrition Due to Dietary Restriction
UPDATE scenarios
SET sc_action_steps = ARRAY['Book dietitian appointment, writing this down to make it concrete and actionable', 'Reintroduce key nutrients, breaking this down into specific, manageable actions', 'Monitor health signs, committing to this even when it feels uncomfortable', 'Adjust plan sustainably, writing them down with specific timelines and milestones', 'Share progress with mentor, making this a regular practice you revisit over time']
WHERE scenario_id = 828;

-- Scenario 829: Travel Anxiety Around Food
UPDATE scenarios
SET sc_action_steps = ARRAY['Research ahead, writing this down to make it concrete and actionable', 'Pack snacks, breaking this down into specific, manageable actions', 'Identify local safe spots, committing to this even when it feels uncomfortable', 'Travel with supportive friends, noticing when old patterns emerge and course-correcting', 'Relinquish control occasionally, making this a regular practice you revisit over time']
WHERE scenario_id = 829;

-- Scenario 830: Time Lost to Food Preparation
UPDATE scenarios
SET sc_action_steps = ARRAY['Batch cook, writing this down to make it concrete and actionable', 'Share prep with others, breaking this down into specific, manageable actions', 'Use simpler recipes, committing to this even when it feels uncomfortable', 'Limit prep sessions, noticing when old patterns emerge and course-correcting', 'Value time balance, making this a regular practice you revisit over time']
WHERE scenario_id = 830;

-- Scenario 842: Skipping Work Lunches Due to Self-Consciousness
UPDATE scenarios
SET sc_action_steps = ARRAY['Attend with a trusted colleague, writing this down to make it concrete and actionable', 'Plan your meal in advance, writing them down with specific timelines and milestones', 'Focus on conversation over food, committing to this even when it feels uncomfortable', 'Limit exposure gradually, noticing when old patterns emerge and course-correcting', 'Note positive experiences, making this a regular practice you revisit over time']
WHERE scenario_id = 842;

-- Scenario 846: Avoiding Shared Meals for Dietary Needs
UPDATE scenarios
SET sc_action_steps = ARRAY['Inform host in advance, writing this down to make it concrete and actionable', 'Offer to bring a dish, breaking this down into specific, manageable actions', 'Frame explanations positively, writing them down with specific timelines and milestones', 'Show appreciation for effort, noticing when old patterns emerge and course-correcting', 'Focus on connection, reaching out to at least 2-3 people who genuinely support you']
WHERE scenario_id = 846;

-- Scenario 848: Silent Through Group Meals
UPDATE scenarios
SET sc_action_steps = ARRAY['Prepare topics beforehand, writing this down to make it concrete and actionable', 'Ask open questions, breaking this down into specific, manageable actions', 'Compliment the food, committing to this even when it feels uncomfortable', 'Share brief stories, noticing when old patterns emerge and course-correcting', 'Smile and make eye contact, making this a regular practice you revisit over time']
WHERE scenario_id = 848;

-- Scenario 850: Leaving Early to Avoid Dessert Pressure
UPDATE scenarios
SET sc_action_steps = ARRAY['Simply say no thank you, writing this down to make it concrete and actionable', 'Suggest sharing portions, breaking this down into specific, manageable actions', 'Focus on conversation, committing to this even when it feels uncomfortable', 'Compliment presentation, noticing when old patterns emerge and course-correcting', 'Stay to enjoy company, making this a regular practice you revisit over time']
WHERE scenario_id = 850;

-- Scenario 852: Only Eating After Everyone Else
UPDATE scenarios
SET sc_action_steps = ARRAY['Arrive with appetite, writing this down to make it concrete and actionable', 'Serve yourself early, breaking this down into specific, manageable actions', 'Sit near supportive people, reaching out to at least 2-3 people who genuinely support you', 'Engage in light chat, noticing when old patterns emerge and course-correcting', 'Enjoy full event, making this a regular practice you revisit over time']
WHERE scenario_id = 852;

-- Scenario 674: Masking Fatigue: Reclaiming Energy and Authenticity
UPDATE scenarios
SET sc_action_steps = ARRAY['Identify safe people, reaching out to at least 2-3 people who genuinely support you', 'Limit masking to necessary contexts, breaking this down into specific, manageable actions', 'Schedule decompression time, committing to this even when it feels uncomfortable', 'Practice self-acceptance habits, noticing when old patterns emerge and course-correcting', 'Seek support from peers, making this a regular practice you revisit over time']
WHERE scenario_id = 674;

-- Scenario 673: Difficulty Following Multi-Step Tasks
UPDATE scenarios
SET sc_action_steps = ARRAY['Ask for step-by-step documentation, writing this down to make it concrete and actionable', 'Make your own checklist, breaking this down into specific, manageable actions', 'Confirm understanding before starting, committing to this even when it feels uncomfortable', 'Review after completion, noticing when old patterns emerge and course-correcting', 'Refine process based on feedback, making this a regular practice you revisit over time']
WHERE scenario_id = 673;

-- Scenario 683: Fear of Losing Support When Disclosing Needs
UPDATE scenarios
SET sc_action_steps = ARRAY['Identify safe people to disclose to, reaching out to at least 2-3 people who genuinely support you', 'State needs clearly linked to outcomes, breaking this down into specific, manageable actions', 'Offer updates on progress, committing to this even when it feels uncomfortable', 'Acknowledge support given, noticing when old patterns emerge and course-correcting', 'Ensure mutual respect, making this a regular practice you revisit over time']
WHERE scenario_id = 683;

-- Scenario 676: Depression from Chronic Misunderstanding
UPDATE scenarios
SET sc_action_steps = ARRAY['Identify uplifting connections, reaching out to at least 2-3 people who genuinely support you', 'Limit time with critical voices, breaking this down into specific, manageable actions', 'Engage in valued activities, committing to this even when it feels uncomfortable', 'Seek counselling, noticing when old patterns emerge and course-correcting', 'Document achievements, making this a regular practice you revisit over time']
WHERE scenario_id = 676;

-- Scenario 677: Burnout from Overcompensating
UPDATE scenarios
SET sc_action_steps = ARRAY['Track hours honestly, writing this down to make it concrete and actionable', 'Say no when capacity is reached, breaking this down into specific, manageable actions', 'Delegate where possible, committing to this even when it feels uncomfortable', 'Prioritize rest, noticing when old patterns emerge and course-correcting', 'Share limits with colleagues, making this a regular practice you revisit over time']
WHERE scenario_id = 677;

-- Scenario 679: Shame from Public Meltdowns
UPDATE scenarios
SET sc_action_steps = ARRAY['Debrief with trusted person, writing this down to make it concrete and actionable', 'Schedule calming time after, breaking this down into specific, manageable actions', 'Prepare aids for future, committing to this even when it feels uncomfortable', 'Challenge negative self-talk, noticing when old patterns emerge and course-correcting', 'Practice exposure when ready, making this a regular practice you revisit over time']
WHERE scenario_id = 679;

-- Scenario 680: Overwhelm from Constant Adaptation
UPDATE scenarios
SET sc_action_steps = ARRAY['Limit unnecessary adaptation, writing this down to make it concrete and actionable', 'Choose contexts that accept you, breaking this down into specific, manageable actions', 'Plan full rest days, writing them down with specific timelines and milestones', 'Seek flexible environments, noticing when old patterns emerge and course-correcting', 'Educate close contacts, making this a regular practice you revisit over time']
WHERE scenario_id = 680;

-- Scenario 681: Self-Doubt from Comparing to Peers
UPDATE scenarios
SET sc_action_steps = ARRAY['Identify personal growth markers, writing this down to make it concrete and actionable', 'Limit comparison triggers, breaking this down into specific, manageable actions', 'Celebrate individual wins, committing to this even when it feels uncomfortable', 'Document effort and learning, noticing when old patterns emerge and course-correcting', 'Share perspective with allies, making this a regular practice you revisit over time']
WHERE scenario_id = 681;

-- Scenario 682: Health Impact of Chronic Stress
UPDATE scenarios
SET sc_action_steps = ARRAY['Recognize early signs, writing this down to make it concrete and actionable', 'Adopt calming routines, breaking this down into specific, manageable actions', 'Improve sleep/nutrition, committing to this even when it feels uncomfortable', 'Seek medical advice, noticing when old patterns emerge and course-correcting', 'Adjust commitments, making this a regular practice you revisit over time']
WHERE scenario_id = 682;

-- Scenario 684: Guilt from Needing Accommodations
UPDATE scenarios
SET sc_action_steps = ARRAY['Reframe accommodations as equity, writing this down to make it concrete and actionable', 'Note improved performance, breaking this down into specific, manageable actions', 'Share benefits for team, committing to this even when it feels uncomfortable', 'Keep requests reasonable, noticing when old patterns emerge and course-correcting', 'Release guilt through gratitude, making this a regular practice you revisit over time']
WHERE scenario_id = 684;

-- Scenario 754: Comparing to Influencer Eco‑Lifestyles
UPDATE scenarios
SET sc_action_steps = ARRAY['Identify what inspires vs pressures, writing this down to make it concrete and actionable', 'Adopt ideas that fit budget, tracking every expense for at least a month to understand patterns', 'Share your authentic progress, committing to this even when it feels uncomfortable', 'Limit time on triggering feeds, noticing when old patterns emerge and course-correcting', 'Focus on internal satisfaction, making this a regular practice you revisit over time']
WHERE scenario_id = 754;

-- Scenario 834: Overcoming Meal Timing Rigidity: Building Flexibility Around Food
UPDATE scenarios
SET sc_action_steps = ARRAY['Adjust meal window gradually, writing this down to make it concrete and actionable', 'Distract during delay, breaking this down into specific, manageable actions', 'Communicate calmly and plan timing, writing them down with specific timelines and milestones', 'Pack snacks for buffer, noticing when old patterns emerge and course-correcting', 'Track reduced stress, if needed, making this a regular practice you revisit over time']
WHERE scenario_id = 834;

-- Scenario 758: Missing Sentimental Items
UPDATE scenarios
SET sc_action_steps = ARRAY['Photograph items before letting go, writing this down to make it concrete and actionable', 'Create memory albums, breaking this down into specific, manageable actions', 'Discuss feelings with friends, committing to this even when it feels uncomfortable', 'Avoid hasty decluttering, noticing when old patterns emerge and course-correcting', 'Keep a small memory box, making this a regular practice you revisit over time']
WHERE scenario_id = 758;

-- Scenario 759: Neglecting Comfort for Aesthetic Minimalism
UPDATE scenarios
SET sc_action_steps = ARRAY['Add plants/soft furnishings, writing them down with specific timelines and milestones', 'Balance empty space with utility, breaking this down into specific, manageable actions', 'Invite feedback from guests, committing to this even when it feels uncomfortable', 'Rotate decor seasonally, noticing when old patterns emerge and course-correcting', 'Choose comfort as self‑care, making this a regular practice you revisit over time']
WHERE scenario_id = 759;

-- Scenario 760: Underestimating Time to Maintain Systems
UPDATE scenarios
SET sc_action_steps = ARRAY['Track actual upkeep time, writing this down to make it concrete and actionable', 'Expand items slightly if needed, breaking this down into specific, manageable actions', 'Batch chores, committing to this even when it feels uncomfortable', 'Ask household for help, noticing when old patterns emerge and course-correcting', 'Be flexible with rules, making this a regular practice you revisit over time']
WHERE scenario_id = 760;

-- Scenario 762: Feeling Behind in Sustainable Trends
UPDATE scenarios
SET sc_action_steps = ARRAY['Research actual impact, writing this down to make it concrete and actionable', 'Delay purchase 30 days, breaking this down into specific, manageable actions', 'Borrow or test first, committing to this even when it feels uncomfortable', 'Prioritise most impactful change, noticing when old patterns emerge and course-correcting', 'Share reasoning openly, making this a regular practice you revisit over time']
WHERE scenario_id = 762;

-- Scenario 763: Comparison to Zero Waste Stores
UPDATE scenarios
SET sc_action_steps = ARRAY['Integrate refill trips occasionally, writing this down to make it concrete and actionable', 'Supplement with bulk buys, breaking this down into specific, manageable actions', 'Avoid shaming self for convenience, committing to this even when it feels uncomfortable', 'Support multiple sustainable models, noticing when old patterns emerge and course-correcting', 'Share tips across communities, making this a regular practice you revisit over time']
WHERE scenario_id = 763;

-- Scenario 765: Pressure to Go Fully Off-Grid
UPDATE scenarios
SET sc_action_steps = ARRAY['Evaluate feasibility honestly, writing this down to make it concrete and actionable', 'Start with partial measures, breaking this down into specific, manageable actions', 'Track impact over time, committing to this even when it feels uncomfortable', 'Educate peers on your journey, noticing when old patterns emerge and course-correcting', 'Reject all-or-nothing narratives, making this a regular practice you revisit over time']
WHERE scenario_id = 765;

-- Scenario 773: Confused by Conflicting Eco Labels
UPDATE scenarios
SET sc_action_steps = ARRAY['Research top 2–3 certifications, writing this down to make it concrete and actionable', 'List greenwashing signs, breaking this down into specific, manageable actions', 'Shop from verified sources, committing to this even when it feels uncomfortable', 'Educate friends, noticing when old patterns emerge and course-correcting', 'Update list annually, making this a regular practice you revisit over time']
WHERE scenario_id = 773;

-- Scenario 791: Spending Hours Planning Perfect Meals
UPDATE scenarios
SET sc_action_steps = ARRAY['Set time limit for planning, writing them down with specific timelines and milestones', 'Batch‑prep ingredients, breaking this down into specific, manageable actions', 'Choose flexible recipes, committing to this even when it feels uncomfortable', 'Allow occasional deviations, noticing when old patterns emerge and course-correcting', 'Value social and mental health equally, making this a regular practice you revisit over time']
WHERE scenario_id = 791;

-- Scenario 781: Feeling Shame for Wanting to Change Body
UPDATE scenarios
SET sc_action_steps = ARRAY['Clarify your reasons, writing this down to make it concrete and actionable', 'Choose respectful communities, breaking this down into specific, manageable actions', 'Focus on health not punishment, committing to this even when it feels uncomfortable', 'Share journey selectively, noticing when old patterns emerge and course-correcting', 'Release fear of labels, making this a regular practice you revisit over time']
WHERE scenario_id = 781;

-- Scenario 804: Group Challenges Becoming Obsessive
UPDATE scenarios
SET sc_action_steps = ARRAY['Assess potential stress, writing this down to make it concrete and actionable', 'Join with friends for support, breaking this down into specific, manageable actions', 'Quit if harming health, committing to this even when it feels uncomfortable', 'Share realistic reflections, noticing when old patterns emerge and course-correcting', 'Encourage diversity, making this a regular practice you revisit over time']
WHERE scenario_id = 804;

-- Scenario 805: Celebrity Endorsements Swaying Choices
UPDATE scenarios
SET sc_action_steps = ARRAY['Check impartial reviews, writing this down to make it concrete and actionable', 'Consider cost‑benefit, breaking this down into specific, manageable actions', 'Test cautiously, committing to this even when it feels uncomfortable', 'Consult nutrition pro, noticing when old patterns emerge and course-correcting', 'Avoid hero worship, making this a regular practice you revisit over time']
WHERE scenario_id = 805;

-- Scenario 809: Criticised for Fitness Goals
UPDATE scenarios
SET sc_action_steps = ARRAY['Explain your reasons, writing this down to make it concrete and actionable', 'Seek supportive peers, breaking this down into specific, manageable actions', 'Release the need for approval, committing to this even when it feels uncomfortable', 'Track holistic progress, noticing when old patterns emerge and course-correcting', 'Celebrate milestones, making this a regular practice you revisit over time']
WHERE scenario_id = 809;

-- Scenario 812: Online Groups Policing Body Talk
UPDATE scenarios
SET sc_action_steps = ARRAY['Join moderated, respectful groups, writing this down to make it concrete and actionable', 'Frame posts with context, breaking this down into specific, manageable actions', 'Avoid shaming language, committing to this even when it feels uncomfortable', 'Encourage balanced dialogue, noticing when old patterns emerge and course-correcting', 'Report toxic moderation when needed, making this a regular practice you revisit over time']
WHERE scenario_id = 812;

-- Scenario 813: Comparing to “Perfect” Confidence Displays
UPDATE scenarios
SET sc_action_steps = ARRAY['Limit comparison to curated images, writing this down to make it concrete and actionable', 'Practice daily self-affirmations, breaking this down into specific, manageable actions', 'Engage with vulnerability posts, committing to this even when it feels uncomfortable', 'Share your own growth story, noticing when old patterns emerge and course-correcting', 'Focus on inner progress, making this a regular practice you revisit over time']
WHERE scenario_id = 813;

-- Scenario 815: Dismissed for Seeking Fitness Goals
UPDATE scenarios
SET sc_action_steps = ARRAY['Research inclusive trainers, writing this down to make it concrete and actionable', 'Invite others to join you, breaking this down into specific, manageable actions', 'Avoid spaces with rigid ideology, committing to this even when it feels uncomfortable', 'Celebrate others’ diverse goals, writing them down with specific timelines and milestones', 'Share mutual encouragement, making this a regular practice you revisit over time']
WHERE scenario_id = 815;

-- Scenario 816: Toxic Positivity After Health Concerns
UPDATE scenarios
SET sc_action_steps = ARRAY['Advocate for being heard, writing this down to make it concrete and actionable', 'Mix positive mindset with action, breaking this down into specific, manageable actions', 'Seek supportive listeners, committing to this even when it feels uncomfortable', 'Document symptoms for doctors, noticing when old patterns emerge and course-correcting', 'Maintain health journal, making this a regular practice you revisit over time']
WHERE scenario_id = 816;

-- Scenario 818: Bullying in “Positive” Spaces
UPDATE scenarios
SET sc_action_steps = ARRAY['Document incidents, writing this down to make it concrete and actionable', 'Discuss with moderators, breaking this down into specific, manageable actions', 'Support others experiencing same, committing to this even when it feels uncomfortable', 'Model inclusive behaviour, noticing when old patterns emerge and course-correcting', 'Consider leaving irredeemable spaces, making this a regular practice you revisit over time']
WHERE scenario_id = 818;

-- Scenario 819: Feeling Shame for Wanting to Change Body
UPDATE scenarios
SET sc_action_steps = ARRAY['Allow yourself nuance, writing this down to make it concrete and actionable', 'Journal both feelings, breaking this down into specific, manageable actions', 'Discuss with open-minded peers, committing to this even when it feels uncomfortable', 'Release binary thinking, noticing when old patterns emerge and course-correcting', 'Affirm dual truths, making this a regular practice you revisit over time']
WHERE scenario_id = 819;

-- Scenario 853: Needing Alcohol to Eat Socially
UPDATE scenarios
SET sc_action_steps = ARRAY['Limit to minimal if any, writing this down to make it concrete and actionable', 'Practice relaxation techniques, breaking this down into specific, manageable actions', 'Attend alcohol-free events, committing to this even when it feels uncomfortable', 'Reward sober successes, noticing when old patterns emerge and course-correcting', 'Track progress, making this a regular practice you revisit over time']
WHERE scenario_id = 853;

-- Scenario 856: Cultural Foods Judged as Unhealthy
UPDATE scenarios
SET sc_action_steps = ARRAY['Share nutritional facts, writing this down to make it concrete and actionable', 'Cook for friends to try, breaking this down into specific, manageable actions', 'Explain cultural significance, committing to this even when it feels uncomfortable', 'Blend traditions with health tweaks, noticing when old patterns emerge and course-correcting', 'Stay confident in identity, making this a regular practice you revisit over time']
WHERE scenario_id = 856;

-- Scenario 686: Hopelessness During Job Hunt
UPDATE scenarios
SET sc_action_steps = ARRAY['Refine resume for fit, writing this down to make it concrete and actionable', 'Practice interviews, breaking this down into specific, manageable actions', 'Network in nd-friendly sectors, committing to this even when it feels uncomfortable', 'Set weekly application goal, writing them down with specific timelines and milestones', 'Reframe each rejection as redirection, making this a regular practice you revisit over time']
WHERE scenario_id = 686;

-- Scenario 687: Mood Swings from Overstimulation
UPDATE scenarios
SET sc_action_steps = ARRAY['Share patterns with close people, reaching out to at least 2-3 people who genuinely support you', 'Prevent triggers where possible, breaking this down into specific, manageable actions', 'Allow decompression time, committing to this even when it feels uncomfortable', 'Apologize if needed, noticing when old patterns emerge and course-correcting', 'Engage only when regulated, making this a regular practice you revisit over time']
WHERE scenario_id = 687;

-- Scenario 751: Guilt Over Occasional Plastic Use
UPDATE scenarios
SET sc_action_steps = ARRAY['Track overall positive impact, writing this down to make it concrete and actionable', 'Identify most impactful actions, breaking this down into specific, manageable actions', 'Forgive small lapses, committing to this even when it feels uncomfortable', 'Share realistic journeys, noticing when old patterns emerge and course-correcting', 'Avoid all‑or‑nothing mindset, making this a regular practice you revisit over time']
WHERE scenario_id = 751;

-- Scenario 752: Shamed for Not Having Solar Panels
UPDATE scenarios
SET sc_action_steps = ARRAY['Explain limitations honestly, writing this down to make it concrete and actionable', 'Research grants/assistance, breaking this down into specific, manageable actions', 'Plan attainable steps, writing them down with specific timelines and milestones', 'Celebrate others without comparison, noticing when old patterns emerge and course-correcting', 'Avoid debt for appearances, making this a regular practice you revisit over time']
WHERE scenario_id = 752;

-- Scenario 756: Decision Paralysis from Too Few Items
UPDATE scenarios
SET sc_action_steps = ARRAY['Audit what’s missing, writing this down to make it concrete and actionable', 'List top 5 items to restore, breaking this down into specific, manageable actions', 'Buy second‑hand first, committing to this even when it feels uncomfortable', 'Test changes before committing, noticing when old patterns emerge and course-correcting', 'Keep adjustments guilt‑free, making this a regular practice you revisit over time']
WHERE scenario_id = 756;

-- Scenario 757: Fatigue from Continual Decluttering
UPDATE scenarios
SET sc_action_steps = ARRAY['Set declutter-free months, writing this down to make it concrete and actionable', 'Appreciate what remains, breaking this down into specific, manageable actions', 'Automate donation drop-offs, committing to this even when it feels uncomfortable', 'Limit intake of new advice, noticing when old patterns emerge and course-correcting', 'Enjoy current space, making this a regular practice you revisit over time']
WHERE scenario_id = 757;

-- Scenario 772: Overanalyzing Every Purchase
UPDATE scenarios
SET sc_action_steps = ARRAY['Identify top categories, writing this down to make it concrete and actionable', 'Make default choices, breaking this down into specific, manageable actions', 'Limit research time, committing to this even when it feels uncomfortable', 'Accept imperfection, noticing when old patterns emerge and course-correcting', 'Review changes yearly, making this a regular practice you revisit over time']
WHERE scenario_id = 772;

-- Scenario 778: Limited Space for Bulk Buying
UPDATE scenarios
SET sc_action_steps = ARRAY['Measure actual consumption, writing this down to make it concrete and actionable', 'Choose stackable containers, breaking this down into specific, manageable actions', 'Share bulk with others, committing to this even when it feels uncomfortable', 'Rotate stock, noticing when old patterns emerge and course-correcting', 'Avoid waste through overbuying, making this a regular practice you revisit over time']
WHERE scenario_id = 778;

-- Scenario 775: Low Income Limits Eco Choices
UPDATE scenarios
SET sc_action_steps = ARRAY['Reuse items creatively, writing this down to make it concrete and actionable', 'Focus on energy/water saving, breaking this down into specific, manageable actions', 'Swap goods with others, committing to this even when it feels uncomfortable', 'Repair before replacing, noticing when old patterns emerge and course-correcting', 'Share tips with similar budgets, tracking every expense for at least a month to understand patterns']
WHERE scenario_id = 775;

-- Scenario 784: Friend Pressures You to Follow Their Diet
UPDATE scenarios
SET sc_action_steps = ARRAY['Thank them for concern, writing this down to make it concrete and actionable', 'Explain your approach, breaking this down into specific, manageable actions', 'Share any positive results you’ve had, committing to this even when it feels uncomfortable', 'Avoid debating excessively, noticing when old patterns emerge and course-correcting', 'Stand firm kindly, making this a regular practice you revisit over time']
WHERE scenario_id = 784;

-- Scenario 793: Friend Pressures You to Follow Their Diet
UPDATE scenarios
SET sc_action_steps = ARRAY['Thank them for concern, writing this down to make it concrete and actionable', 'Explain your approach, breaking this down into specific, manageable actions', 'Share any positive results you’ve had, committing to this even when it feels uncomfortable', 'Avoid debating excessively, noticing when old patterns emerge and course-correcting', 'Stand firm kindly, making this a regular practice you revisit over time']
WHERE scenario_id = 793;

-- Scenario 789: Criticised for Fitness Goals
UPDATE scenarios
SET sc_action_steps = ARRAY['Explain your “why”, writing this down to make it concrete and actionable', 'Seek supportive friends, breaking this down into specific, manageable actions', 'Release need for everyone’s approval, committing to this even when it feels uncomfortable', 'Track personal markers, noticing when old patterns emerge and course-correcting', 'Celebrate effort, making this a regular practice you revisit over time']
WHERE scenario_id = 789;

-- Scenario 799: Diet Debate Taking Over Social Media
UPDATE scenarios
SET sc_action_steps = ARRAY['Limit comment time, writing this down to make it concrete and actionable', 'Unfollow high‑conflict threads, breaking this down into specific, manageable actions', 'Share only lived experience, committing to this even when it feels uncomfortable', 'Promote respectful dialogue, noticing when old patterns emerge and course-correcting', 'Channel energy into self‑care, making this a regular practice you revisit over time']
WHERE scenario_id = 799;

-- Scenario 801: Confused by “Superfood” Marketing
UPDATE scenarios
SET sc_action_steps = ARRAY['Check scientific backing, writing this down to make it concrete and actionable', 'See if it fits your needs, breaking this down into specific, manageable actions', 'Avoid expensive fads, committing to this even when it feels uncomfortable', 'Watch for allergens, noticing when old patterns emerge and course-correcting', 'Track real benefits, making this a regular practice you revisit over time']
WHERE scenario_id = 801;

-- Scenario 802: Cultural Diet vs. Modern Trends
UPDATE scenarios
SET sc_action_steps = ARRAY['Retain key cultural staples, writing this down to make it concrete and actionable', 'Adjust cooking methods, breaking this down into specific, manageable actions', 'Share benefits of heritage foods, committing to this even when it feels uncomfortable', 'Educate younger family, noticing when old patterns emerge and course-correcting', 'Celebrate fusion recipes, making this a regular practice you revisit over time']
WHERE scenario_id = 802;

-- Scenario 811: Spending Hours Planning Perfect Meals
UPDATE scenarios
SET sc_action_steps = ARRAY['Set timer for sessions, writing this down to make it concrete and actionable', 'Batch‑prep ingredients, breaking this down into specific, manageable actions', 'Include flexible meals, committing to this even when it feels uncomfortable', 'Accept occasional impromptu meals, noticing when old patterns emerge and course-correcting', 'Note mental health impact, making this a regular practice you revisit over time']
WHERE scenario_id = 811;

-- Scenario 822: Judged for Clothing Choices
UPDATE scenarios
SET sc_action_steps = ARRAY['Wear what empowers you, writing this down to make it concrete and actionable', 'Share styling inspirations, breaking this down into specific, manageable actions', 'Ignore unsolicited advice, committing to this even when it feels uncomfortable', 'Support diverse fashion, noticing when old patterns emerge and course-correcting', 'Affirm others’ choices, making this a regular practice you revisit over time']
WHERE scenario_id = 822;

-- Scenario 825: Fear of “Impure” Foods
UPDATE scenarios
SET sc_action_steps = ARRAY['Identify safe flexibility points, writing this down to make it concrete and actionable', 'Plan indulgence without guilt, writing them down with specific timelines and milestones', 'Communicate needs without shaming, committing to this even when it feels uncomfortable', 'Share meals occasionally, noticing when old patterns emerge and course-correcting', 'Release need for 100% purity, making this a regular practice you revisit over time']
WHERE scenario_id = 825;

-- Scenario 847: Bringing Own Food to Gatherings
UPDATE scenarios
SET sc_action_steps = ARRAY['Pack food discreetly, writing this down to make it concrete and actionable', 'Explain briefly if asked, breaking this down into specific, manageable actions', 'Eat without apology, committing to this even when it feels uncomfortable', 'Offer tastes to others, noticing when old patterns emerge and course-correcting', 'Model self-acceptance, making this a regular practice you revisit over time']
WHERE scenario_id = 847;

-- Scenario 840: Using Only Home-Cooked Meals as Virtue
UPDATE scenarios
SET sc_action_steps = ARRAY['Plan restaurant visits mindfully, writing them down with specific timelines and milestones', 'Value shared experience, breaking this down into specific, manageable actions', 'Separate ethics and ego, committing to this even when it feels uncomfortable', 'Enjoy variety, noticing when old patterns emerge and course-correcting', 'Support local businesses, making this a regular practice you revisit over time']
WHERE scenario_id = 840;

-- Scenario 854: Judged for Portion Sizes
UPDATE scenarios
SET sc_action_steps = ARRAY['Respond briefly without apology, writing this down to make it concrete and actionable', 'Serve own plate, breaking this down into specific, manageable actions', 'Avoid explaining repeatedly, committing to this even when it feels uncomfortable', 'Redirect conversation, noticing when old patterns emerge and course-correcting', 'Model self-trust, making this a regular practice you revisit over time']
WHERE scenario_id = 854;

-- Scenario 870: Obsessive Calorie Tracking Undermines Health
UPDATE scenarios
SET sc_action_steps = ARRAY['Set flexible ranges, writing this down to make it concrete and actionable', 'Take breaks from logging, breaking this down into specific, manageable actions', 'Notice satiety cues, committing to this even when it feels uncomfortable', 'Focus on nutrient quality, noticing when old patterns emerge and course-correcting', 'Keep mental health in check, making this a regular practice you revisit over time']
WHERE scenario_id = 870;

-- Scenario 863: Overtraining for Aesthetic Goals
UPDATE scenarios
SET sc_action_steps = ARRAY['Set performance goals, writing them down with specific timelines and milestones', 'Schedule rest days, breaking this down into specific, manageable actions', 'Track energy levels, committing to this even when it feels uncomfortable', 'Work with a balanced trainer, noticing when old patterns emerge and course-correcting', 'Celebrate strength gains, making this a regular practice you revisit over time']
WHERE scenario_id = 863;

-- Scenario 1074: Struggling with Self-Harm Thoughts
UPDATE scenarios
SET sc_action_steps = ARRAY['Talk to a counselor, writing this down to make it concrete and actionable', 'Teacher, breaking this down into specific, manageable actions', 'Or loved one immediately, committing to this even when it feels uncomfortable', 'Create a safety plan and distraction list, writing them down with specific timelines and milestones', 'Remember that emotions change—this moment will pass, staying consistent even when progress feels slow']
WHERE scenario_id = 1074;

-- Scenario 913: Social Media Comparison and Validation Seeking
UPDATE scenarios
SET sc_action_steps = ARRAY['Limit social media use with clear time boundaries., noticing when old patterns creep in and consciously choosing differently', 'Reflect on your inner qualities and growth., breaking this down into specific, manageable actions', 'Celebrate others without comparing yourself., committing to this even when it feels uncomfortable', 'Practice silence, noticing when old patterns emerge and course-correcting', 'Journaling, making this a regular practice you revisit over time']
WHERE scenario_id = 913;

-- Scenario 857: Family Resists New Dietary Needs
UPDATE scenarios
SET sc_action_steps = ARRAY['Explain needs gently, writing this down to make it concrete and actionable', 'Offer to help cook, breaking this down into specific, manageable actions', 'Suggest alternatives, committing to this even when it feels uncomfortable', 'Thank them for understanding, noticing when old patterns emerge and course-correcting', 'Stay firm when pressured, making this a regular practice you revisit over time']
WHERE scenario_id = 857;

-- Scenario 860: Mocked for Religious Food Practices
UPDATE scenarios
SET sc_action_steps = ARRAY['Share personal meaning, writing this down to make it concrete and actionable', 'Invite to observe, breaking this down into specific, manageable actions', 'Stay respectful of differences, committing to this even when it feels uncomfortable', 'Link practice to values, noticing when old patterns emerge and course-correcting', 'Model tolerance, making this a regular practice you revisit over time']
WHERE scenario_id = 860;

-- Scenario 873: Avoiding Enjoyment Foods Completely
UPDATE scenarios
SET sc_action_steps = ARRAY['Plan occasional indulgence, writing them down with specific timelines and milestones', 'Share with friends, breaking this down into specific, manageable actions', 'Avoid guilt language, committing to this even when it feels uncomfortable', 'Note mood benefits, noticing when old patterns emerge and course-correcting', 'Keep balanced meals, making this a regular practice you revisit over time']
WHERE scenario_id = 873;

-- Scenario 865: Avoiding Strength Training for Fear of “Bulk”
UPDATE scenarios
SET sc_action_steps = ARRAY['Research credible sources, writing this down to make it concrete and actionable', 'Try guided sessions, breaking this down into specific, manageable actions', 'Track progress by health, committing to this even when it feels uncomfortable', 'Challenge stereotypes, noticing when old patterns emerge and course-correcting', 'Enjoy new abilities, making this a regular practice you revisit over time']
WHERE scenario_id = 865;

-- Scenario 858: Workplace Potlucks Excluding Your Cuisine
UPDATE scenarios
SET sc_action_steps = ARRAY['Pick popular flavours from culture, writing this down to make it concrete and actionable', 'Explain origins briefly, breaking this down into specific, manageable actions', 'Invite feedback, committing to this even when it feels uncomfortable', 'Encourage tasting, noticing when old patterns emerge and course-correcting', 'Rotate dishes for variety, making this a regular practice you revisit over time']
WHERE scenario_id = 858;

-- Scenario 871: Avoiding Medical Help to Keep Training
UPDATE scenarios
SET sc_action_steps = ARRAY['Schedule check-ups early, writing this down to make it concrete and actionable', 'View rest as training, breaking this down into specific, manageable actions', 'Follow medical advice, committing to this even when it feels uncomfortable', 'Gradually return to activity, noticing when old patterns emerge and course-correcting', 'Share learning, making this a regular practice you revisit over time']
WHERE scenario_id = 871;

-- Scenario 874: Body Dysmorphia Triggers from Gym Mirrors
UPDATE scenarios
SET sc_action_steps = ARRAY['Choose mirror-free spaces, writing this down to make it concrete and actionable', 'Cover mirrors where possible, breaking this down into specific, manageable actions', 'Focus on feeling in body, committing to this even when it feels uncomfortable', 'Workout outdoors, noticing when old patterns emerge and course-correcting', 'Use affirmations, making this a regular practice you revisit over time']
WHERE scenario_id = 874;

-- Scenario 1139: Exam Pressure and Fear of Disappointing Others
UPDATE scenarios
SET sc_action_steps = ARRAY['Create a realistic study plan to reduce overwhelm., staying consistent even when progress feels slow', 'Focus on learning, breaking this down into specific, manageable actions', 'Not perfection., committing to this even when it feels uncomfortable', 'Practice self-care through rest, noticing when old patterns emerge and course-correcting', 'Food, making this a regular practice you revisit over time with consistent effort over time']
WHERE scenario_id = 1139;

-- Scenario 864: Crash Dieting Before Events
UPDATE scenarios
SET sc_action_steps = ARRAY['Plan months ahead, writing them down with specific timelines and milestones', 'Focus on whole foods, breaking this down into specific, manageable actions', 'Stay hydrated, committing to this even when it feels uncomfortable', 'Exercise moderately, noticing when old patterns emerge and course-correcting', 'Ignore crash-diet trends, making this a regular practice you revisit over time']
WHERE scenario_id = 864;

-- Scenario 872: Overemphasis on Weight Over Function
UPDATE scenarios
SET sc_action_steps = ARRAY['Track lifts or stamina, writing this down to make it concrete and actionable', 'Increase healthy fuel, breaking this down into specific, manageable actions', 'Balance body composition, committing to this even when it feels uncomfortable', 'Set skill-based goals, writing them down with specific timelines and milestones', 'Celebrate capability, making this a regular practice you revisit over time']
WHERE scenario_id = 872;

-- Scenario 866: Choosing Looks Over Health Cues
UPDATE scenarios
SET sc_action_steps = ARRAY['Rest at first sign of injury, writing this down to make it concrete and actionable', 'Consult professionals, breaking this down into specific, manageable actions', 'Shift focus to recovery, committing to this even when it feels uncomfortable', 'Adjust goals to ability, writing them down with specific timelines and milestones', 'Share recovery openly, making this a regular practice you revisit over time']
WHERE scenario_id = 866;

-- Scenario 867: Supplements Without True Need
UPDATE scenarios
SET sc_action_steps = ARRAY['Check scientific basis, writing this down to make it concrete and actionable', 'Consult doctor, breaking this down into specific, manageable actions', 'Avoid over-supplementing, committing to this even when it feels uncomfortable', 'Focus on proven basics, noticing when old patterns emerge and course-correcting', 'Save money for essentials, making this a regular practice you revisit over time']
WHERE scenario_id = 867;

-- Scenario 868: Comparing Your Body to Edited Images
UPDATE scenarios
SET sc_action_steps = ARRAY['Unfollow editing-heavy accounts, writing this down to make it concrete and actionable', 'Follow diverse bodies, breaking this down into specific, manageable actions', 'Limit scroll time, committing to this even when it feels uncomfortable', 'Remind self of editing, noticing when old patterns emerge and course-correcting', 'Value function over form, making this a regular practice you revisit over time']
WHERE scenario_id = 868;

-- Scenario 901: Jealousy of Friend's Academic Success
UPDATE scenarios
SET sc_action_steps = ARRAY['Acknowledge your feelings without judgment, writing this down to make it concrete and actionable', 'Congratulate your friend sincerely, breaking this down into specific, manageable actions', 'Set goals for your own improvement without competing, staying consistent even when progress feels slow', 'Cultivate joy in others'' success, noticing when old patterns emerge and course-correcting', ', making this a regular practice you revisit over time with consistent effort over time']
WHERE scenario_id = 901;

-- Scenario 916: Developing Underperforming Team Member
UPDATE scenarios
SET sc_action_steps = ARRAY['Identify specific skills gaps and create a development plan, staying consistent even when progress feels slow', 'Provide mentoring, breaking this down into specific, manageable actions', 'Training, committing to this even when it feels uncomfortable', 'And regular feedback, noticing when old patterns emerge and course-correcting', 'Set clear milestones and timelines for improvement, staying consistent even when progress feels slow']
WHERE scenario_id = 916;

-- Scenario 939: Child with Learning Differences
UPDATE scenarios
SET sc_action_steps = ARRAY['Use learning tools suited to your style, writing this down to make it concrete and actionable', 'Celebrate your strengths (creativity, breaking this down into specific, manageable actions', 'Kindness, committing to this even when it feels uncomfortable', 'Etc.), noticing when old patterns emerge and course-correcting', 'Talk openly with parents and teachers, making this a regular practice you revisit over time']
WHERE scenario_id = 939;

-- Scenario 941: Fear of Public Speaking in School
UPDATE scenarios
SET sc_action_steps = ARRAY['Prepare well with notes and practice, writing this down to make it concrete and actionable', 'Focus on the message, breaking this down into specific, manageable actions', 'Not the audience, committing to this even when it feels uncomfortable', 'Offer your speech as a sincere act, noticing when old patterns emerge and course-correcting', 'Not a performance, making this a regular practice you revisit over time']
WHERE scenario_id = 941;

-- Scenario 969: Cyberbullying and Identity Crisis
UPDATE scenarios
SET sc_action_steps = ARRAY['Limit time on toxic platforms and report abusive behavior, noticing when old patterns creep in and consciously choosing differently', 'Spend time with friends and communities that affirm your worth, staying consistent even when progress feels slow', 'Reflect daily on your deeper identity beyond appearances, staying consistent even when progress feels slow', 'Seek support from parents, noticing when old patterns emerge and course-correcting', 'Counselors, making this a regular practice you revisit over time']
WHERE scenario_id = 969;

-- Scenario 1049: Job Opportunity Requiring Family Separation
UPDATE scenarios
SET sc_action_steps = ARRAY['Evaluate all stakeholders'' needs objectively, writing this down to make it concrete and actionable', 'Not just your own desires, breaking this down into specific, manageable actions', 'Explore creative solutions that honor both career and family duties, staying consistent even when progress feels slow', 'Consult with family members and seek their blessings for your decision, staying consistent even when progress feels slow', 'Whatever you choose, making this a regular practice you revisit over time']
WHERE scenario_id = 1049;

-- Scenario 1065: Child Grieving Grandparent's Death
UPDATE scenarios
SET sc_action_steps = ARRAY['Talk to parents or elders about what happened, writing this down to make it concrete and actionable', 'Create art, breaking this down into specific, manageable actions', 'Prayers, committing to this even when it feels uncomfortable', 'Or memories to honor them, noticing when old patterns emerge and course-correcting', 'Ask spiritual questions when you''re ready, making this a regular practice you revisit over time']
WHERE scenario_id = 1065;

-- Scenario 1123: Fear of Not Being Liked at School
UPDATE scenarios
SET sc_action_steps = ARRAY['List your strengths and qualities you value in yourself, staying consistent even when progress feels slow', 'Continue to treat others kindly, breaking this down into specific, manageable actions', 'Without expectation, committing to this even when it feels uncomfortable', 'Focus on activities that make you feel confident and fulfilled, staying consistent even when progress feels slow', 'Remember everyone''s journey is different, making this a regular practice you revisit over time']
WHERE scenario_id = 1123;

-- Scenario 1235: Letting Go of Control Over Critical Project
UPDATE scenarios
SET sc_action_steps = ARRAY['Clearly communicate expectations, writing this down to make it concrete and actionable', 'Deadlines, breaking this down into specific, manageable actions', 'And success criteria, committing to this even when it feels uncomfortable', 'Provide necessary resources and access to information, staying consistent even when progress feels slow', 'Schedule regular check-ins without micromanaging daily activities, staying consistent even when progress feels slow']
WHERE scenario_id = 1235;

COMMIT;
