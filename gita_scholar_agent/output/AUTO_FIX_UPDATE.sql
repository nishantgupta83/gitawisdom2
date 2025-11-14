-- SQL Script: Automated Redundancy Removal
-- Removes 'ensuring you understand' and 'Take time to' templates
-- Affects 326 scenarios

BEGIN;

-- Scenario 448: Overworking to Prove Worth in Recession
UPDATE scenarios 
SET sc_action_steps = '["Communicate realistic capacity with leaders", "Prioritize high-value contributions", "Schedule rest even in busy weeks", "Seek efficiency over raw hours", "Watch for burnout signs early"]'::jsonb 
WHERE scenario_id = 448;

-- Scenario 449: Fear of Relocation in Role Transfer
UPDATE scenarios 
SET sc_action_steps = '["List personal and family impacts", "Research new location cost/lifestyle", "Negotiate relocation benefits", "Visit the city if possible", "Align decision with values and goals"]'::jsonb 
WHERE scenario_id = 449;

-- Scenario 459: No Major Assets Compared to Siblings
UPDATE scenarios 
SET sc_action_steps = '["Recognize other forms of assets like skills and networks", "Focus on building steadily", "Avoid debt-fueled asset chasing", "Invest according to your path", "Judge success by alignment not volume"]'::jsonb 
WHERE scenario_id = 459;

-- Scenario 361: Witnessing Harassment in the Workplace
UPDATE scenarios 
SET sc_action_steps = '["Ensure target’s immediate safety", "Report to hr or management", "Document the incident", "Offer continued support to the target", "Reflect on bystander duties"]'::jsonb 
WHERE scenario_id = 361;

-- Scenario 412: All Friends Married, Feeling Left Out
UPDATE scenarios 
SET sc_action_steps = '["List personal achievements unrelated to marital status", "Cultivate hobbies and friendships", "Attend social events without marriage focus", "Celebrate others sincerely", "Anchor identity beyond relationship status"]'::jsonb 
WHERE scenario_id = 412;

-- Scenario 416: Dating Fatigue from Arranged Meets
UPDATE scenarios 
SET sc_action_steps = '["Clarify qualities important to you", "Limit number of meets per month", "Request longer conversations before decisions", "Avoid judgment based onsurface-level impressions", "Take breaks between meetings to recharge"]'::jsonb 
WHERE scenario_id = 416;

-- Scenario 423: Hiding Smile Due to Crooked Teeth
UPDATE scenarios 
SET sc_action_steps = '["Smile genuinely without overthinking", "Consider health-focused dental care if desired", "Avoid zooming in on imperfections", "Receive compliments without deflection", "Focus on moments, not looks, in socializing"]'::jsonb 
WHERE scenario_id = 423;

-- Scenario 424: Obsessing Over Fitness App Metrics
UPDATE scenarios 
SET sc_action_steps = '["Review metrics weekly, not hourly", "Prioritize feeling strong over chasing numbers", "Rest when body needs, even if stats drop", "Adjust goals for sustainability", "Celebrate consistency as success"]'::jsonb 
WHERE scenario_id = 424;

-- Scenario 425: Comparing Yourself to Edited Images
UPDATE scenarios 
SET sc_action_steps = '["Unfollow or mute triggering accounts", "Seek unedited, body-positive influencers", "Remind yourself of editing realities", "Focus on content value, not appearance", "Practice gratitude for your unique body"]'::jsonb 
WHERE scenario_id = 425;

-- Scenario 430: Gym Avoidance Due to Feeling Out of Shape
UPDATE scenarios 
SET sc_action_steps = '["Choose beginner-friendly environments", "Buddy up with encouraging friends", "Celebrate each small progress", "Ignore perceived scrutiny from others", "Focus on long-term health gains over quick fixes"]'::jsonb 
WHERE scenario_id = 430;

-- Scenario 436: Last-Minute Syllabus Overwhelm
UPDATE scenarios 
SET sc_action_steps = '["Identify high-weightage topics", "Make a revision timetable", "Cover challenging subjects earlier each day", "Leave easy revisions for later", "Stay calm to retain information effectively"]'::jsonb 
WHERE scenario_id = 436;

-- Scenario 437: Skipping Meals During Study
UPDATE scenarios 
SET sc_action_steps = '["Plan meal prep in advance", "Eat simple, energy-sustaining foods", "Hydrate regularly", "Avoid heavy meals before study sessions", "Snack on brain foods like nuts and fruit"]'::jsonb 
WHERE scenario_id = 437;

-- Scenario 441: Layoff Rumors Spreading in Office
UPDATE scenarios 
SET sc_action_steps = '["Avoid engaging in workplace rumors", "Focus on delivering strong performance", "Quietly update your resume", "Expand your professional network", "Build emergency savings where possible"]'::jsonb 
WHERE scenario_id = 441;

-- Scenario 443: Colleague Terminations Increasing
UPDATE scenarios 
SET sc_action_steps = '["Keep performance high and visible", "Explore market opportunities quietly", "Strengthen key skills", "Avoid fatalistic thinking", "Support remaining colleagues for morale"]'::jsonb 
WHERE scenario_id = 443;

-- Scenario 445: Fear of Age Discrimination After Layoff
UPDATE scenarios 
SET sc_action_steps = '["Refresh and modernize resume format", "Learn latest tools in your field", "Network through industry events", "Leverage mentorship as value-add", "Stay active in professional forums"]'::jsonb 
WHERE scenario_id = 445;

-- Scenario 447: Toxic Competition During Downsizing
UPDATE scenarios 
SET sc_action_steps = '["Commit to ethical conduct", "Document your contributions", "Collaborate with trustworthy peers", "Avoid blaming or gossip", "Let performance, not politics, speak"]'::jsonb 
WHERE scenario_id = 447;

-- Scenario 446: Coping with Industry Collapse
UPDATE scenarios 
SET sc_action_steps = '["Identify skills that cross industries", "Seek training before situation worsens", "Update linkedin/profile with new capabilities", "Investigate growth sectors", "Plan timeline for pivot"]'::jsonb 
WHERE scenario_id = 446;

-- Scenario 525: Negative Self-Talk Undermining Discipline
UPDATE scenarios 
SET sc_action_steps = '["Use neutral language for setbacks", "Focus on next action, not mistake", "Track overall streak instead of perfection", "Reward resilience", "Remember long-term vision"]'::jsonb 
WHERE scenario_id = 525;

-- Scenario 363: Pressure to Hide Mistakes from Client
UPDATE scenarios 
SET sc_action_steps = '["Clarify long-term risks of concealment", "Propose transparent correction paths", "Keep personal ethics intact", "Document the dialogue", "Accept consequences of integrity"]'::jsonb 
WHERE scenario_id = 363;

-- Scenario 364: Ethics of Accepting Questionable Charity Donations
UPDATE scenarios 
SET sc_action_steps = '["Research donor background", "Weigh potential reputational harm", "Discuss with stakeholders", "Accept only if aligned with mission", "Seek alternative funding if not"]'::jsonb 
WHERE scenario_id = 364;

-- Scenario 365: Misuse of Company Property for Personal Gain
UPDATE scenarios 
SET sc_action_steps = '["Know formal policy", "Avoid non-permitted personal use", "Ask permission when unsure", "Lead by example", "Value entrusted assets as sacred trust"]'::jsonb 
WHERE scenario_id = 365;

-- Scenario 368: Handling Insider Information Ethically
UPDATE scenarios 
SET sc_action_steps = '["Understand legal and ethical boundaries", "Never leak privileged info", "Value reputation over profit", "Stop others from misusing info", "Report breaches responsibly"]'::jsonb 
WHERE scenario_id = 368;

-- Scenario 386: Lack of Motivation for Daily Tasks
UPDATE scenarios 
SET sc_action_steps = '["Break tasks into tiny steps", "Commit to 5 minutes of action to start", "Celebrate completion of each step", "Pair chores with music or rewards", "Track progress visually"]'::jsonb 
WHERE scenario_id = 386;

-- Scenario 438: Peer Bragging Adding Pressure to Study Habits
UPDATE scenarios 
SET sc_action_steps = '["Respect others’ routines without mimicry", "Learn ideas but adapt to your rhythms", "Track your own progress in private", "Limit negative competitiveness", "Cultivate supportive peer study groups"]'::jsonb 
WHERE scenario_id = 438;

-- Scenario 465: Eco-Guilt from Lifestyle Choices
UPDATE scenarios 
SET sc_action_steps = '["Identify top 3 impactful changes", "Adjust habits steadily", "Educate others through example", "Celebrate progress not perfection", "Keep joy in sustainability"]'::jsonb 
WHERE scenario_id = 465;

-- Scenario 468: Burnout from Activism Without Rest
UPDATE scenarios 
SET sc_action_steps = '["Schedule recovery periods", "Share load with fellow activists", "Alternate between intense and light tasks", "Reconnect to “why” behind efforts", "Engage in nature to restore hope"]'::jsonb 
WHERE scenario_id = 468;

-- Scenario 524: Finding Sustainability in New Habits
UPDATE scenarios 
SET sc_action_steps = '["Assess realistic daily time/energy", "Begin at 50–70% capacity", "Increase gradually", "Recognize small wins as success", "Avoid all-or-nothing thinking"]'::jsonb 
WHERE scenario_id = 524;

-- Scenario 515: Building a Support Network After Relocation
UPDATE scenarios 
SET sc_action_steps = '["Join city-specific interest groups", "Attend professional meet-ups", "Start conversations in safe settings", "Reconnect with distant acquaintances in new city", "Adopt patience—relationships take time"]'::jsonb 
WHERE scenario_id = 515;

-- Scenario 527: Staying Consistent with Healthy Habits Amid Social Pressure
UPDATE scenarios 
SET sc_action_steps = '["Share reasons for your habits confidently", "Seek supportive communities", "Limit exposure to undermining influences", "Track your improvement to stay motivated", "Remember why you started"]'::jsonb 
WHERE scenario_id = 527;

-- Scenario 322: Neglecting Physical Health for Career
UPDATE scenarios 
SET sc_action_steps = '["Block recurring time in calendar for exercise", "Set sleep goals as seriously as work goals", "Integrate movement into daily routines", "Prioritize medical checkups regularly", "Balance ambition with longevity"]'::jsonb 
WHERE scenario_id = 322;

-- Scenario 333: Friend Jealous of Your Success
UPDATE scenarios 
SET sc_action_steps = '["Acknowledge their feelings without minimizing your achievement", "Show appreciation for their friendship and past support", "Share credit where due", "Encourage their own pursuits", "Avoid boastful behavior"]'::jsonb 
WHERE scenario_id = 333;

-- Scenario 353: Friend Jealous of Your Success
UPDATE scenarios 
SET sc_action_steps = '["Acknowledge their feelings without minimizing your achievement", "Show appreciation for their friendship", "Share credit where due", "Encourage their pursuits", "Avoid boastfulness"]'::jsonb 
WHERE scenario_id = 353;

-- Scenario 340: Witnessing Workplace Harassment
UPDATE scenarios 
SET sc_action_steps = '["Ensure the safety of the target first", "Report to HR or authority channels", "Document what you witnessed", "Support the affected colleague respectfully", "Reflect on bystander responsibility"]'::jsonb 
WHERE scenario_id = 340;

-- Scenario 341: Faced with a Conflict of Interest
UPDATE scenarios 
SET sc_action_steps = '["Disclose the relationship to relevant parties", "Recuse yourself if necessary", "Use objective criteria for selection", "Keep documentation for accountability", "Prioritize the organization’s and public good over personal ties"]'::jsonb 
WHERE scenario_id = 341;

-- Scenario 344: Using Company Resources for Personal Gain
UPDATE scenarios 
SET sc_action_steps = '["Understand policies about personal use of resources", "Avoid even minor misuse", "Ask permission if unsure", "Model correct behavior to others", "Recognize trust as part of professional duty"]'::jsonb 
WHERE scenario_id = 344;

-- Scenario 352: Balancing Multiple Friend Groups
UPDATE scenarios 
SET sc_action_steps = '["Identify relationships most aligned with your values", "Schedule quality time intentionally", "Communicate your availability honestly", "Release guilt about limited capacity", "Foster reciprocity in relationships"]'::jsonb 
WHERE scenario_id = 352;

-- Scenario 334: Handling Gossip About a Friend
UPDATE scenarios 
SET sc_action_steps = '["Privately share what you’ve heard with them directly", "Encourage addressing misinfo at its source", "Don’t spread unverified claims", "Reassure them of your trust", "Model discretion to your circle"]'::jsonb 
WHERE scenario_id = 334;

-- Scenario 354: Handling Gossip About a Friend
UPDATE scenarios 
SET sc_action_steps = '["Share concerns privately with the friend", "Encourage addressing rumors constructively", "Avoid participating in unverified gossip", "Reaffirm your support", "Model discretion in your circles"]'::jsonb 
WHERE scenario_id = 354;

-- Scenario 355: Friend Only Calls in Crisis
UPDATE scenarios 
SET sc_action_steps = '["Assess your capacity before helping", "Communicate when the pattern feels one-sided", "Clarify what support you can offer", "Encourage independence", "Value mutual relationships"]'::jsonb 
WHERE scenario_id = 355;

-- Scenario 356: Navigating Friendship After Betrayal
UPDATE scenarios 
SET sc_action_steps = '["Confront the issue calmly", "Seek to understand their perspective", "Set boundaries for rebuilding trust", "Decide if relationship can recover", "Accept closure if trust is broken beyond repair"]'::jsonb 
WHERE scenario_id = 356;

-- Scenario 357: Long-Distance Friendship Fading
UPDATE scenarios 
SET sc_action_steps = '["Set reminders to check in", "Share updates through calls or letters", "Plan visits if possible", "Celebrate milestones from afar", "Reassure them of your care"]'::jsonb 
WHERE scenario_id = 357;

-- Scenario 372: Unsure Whether to Go Back to School
UPDATE scenarios 
SET sc_action_steps = '["Clarify your long-term goals", "Consult mentors in your desired field", "Weigh cost/benefit realistically", "Choose programs aligned with your path", "Act without fear or haste"]'::jsonb 
WHERE scenario_id = 372;

-- Scenario 387: Social Media Draining Mental Health
UPDATE scenarios 
SET sc_action_steps = '["Unfollow negative accounts", "Designate social media-free zones/times", "Engage with uplifting content intentionally", "Replace scrolling with enriching activities", "Monitor emotional state after online sessions"]'::jsonb 
WHERE scenario_id = 387;

-- Scenario 397: Unsafe Neighborhood Fears
UPDATE scenarios 
SET sc_action_steps = '["Review crime prevention measures with local authorities", "Adjust routines to reduce risk", "Engage with community watch programs", "Plan relocation carefully if viable", "Maintain inner composure while taking prudent actions"]'::jsonb 
WHERE scenario_id = 397;

-- Scenario 398: Relationship Breakup Forces New Living Arrangements
UPDATE scenarios 
SET sc_action_steps = '["List non-negotiable housing needs", "Consider temporary solutions while planning", "Set a realistic budget", "Reach out to support network for leads", "Use this as a chance to reassess priorities"]'::jsonb 
WHERE scenario_id = 398;

-- Scenario 400: Family Pressure to Live Nearby
UPDATE scenarios 
SET sc_action_steps = '["Clearly express your reasons for living where you choose", "Reassure family about maintaining connection", "Plan regular visits or calls", "Evaluate compromises that serve both", "Respect your own needs while honoring family bonds"]'::jsonb 
WHERE scenario_id = 400;

-- Scenario 401: Struggling to Scale a Small Business
UPDATE scenarios 
SET sc_action_steps = '["Identify repetitive tasks to delegate", "Bring in part-time or contract help", "Document standard operating procedures", "Focus on highest-value activities", "Automate where possible"]'::jsonb 
WHERE scenario_id = 401;

-- Scenario 402: Facing Seasonal Revenue Slumps
UPDATE scenarios 
SET sc_action_steps = '["Identify seasonal patterns in revenue", "Save during peak months", "Develop off-season services or products", "Negotiate with suppliers for flexible terms", "Keep team engaged during slow periods via training or development"]'::jsonb 
WHERE scenario_id = 402;

-- Scenario 403: Partnership Disagreements
UPDATE scenarios 
SET sc_action_steps = '["Schedule dedicated talks to explore visions", "Hire a mediator if talks stall", "Identify shared core goals", "Agree on decision-making processes", "Document agreements clearly"]'::jsonb 
WHERE scenario_id = 403;

-- Scenario 404: Coping with Sudden Market Competition
UPDATE scenarios 
SET sc_action_steps = '["Analyze competitor strengths and weaknesses", "Refine your unique value proposition", "Focus marketing on loyal customer base", "Improve service and offerings", "Avoid unsustainable race-to-the-bottom pricing"]'::jsonb 
WHERE scenario_id = 404;

-- Scenario 442: Pay Cuts Due to Recession
UPDATE scenarios 
SET sc_action_steps = '["Review and adjust personal budget immediately", "Identify unnecessary expenses to cut", "Explore freelance or side gigs", "Stay valuable to current employer", "Maintain morale despite pay change"]'::jsonb 
WHERE scenario_id = 442;

-- Scenario 444: Freelance Contracts Drying Up
UPDATE scenarios 
SET sc_action_steps = '["Reach out to dormant contacts", "Adapt offers to market needs", "Adjust budget temporarily", "Seek referrals from satisfied clients", "Learn complementary high-demand skills"]'::jsonb 
WHERE scenario_id = 444;

-- Scenario 453: Never Having Traveled Abroad
UPDATE scenarios 
SET sc_action_steps = '["Explore local adventures within budget", "Save gradually for desired trips", "Detach joy from needing distant destinations", "Engage in cultural experiences nearby", "Remember that growth is not limited to geography"]'::jsonb 
WHERE scenario_id = 453;

-- Scenario 454: No Career Promotion While Peers Advance
UPDATE scenarios 
SET sc_action_steps = '["Assess if your role still aligns with your purpose", "Seek skill growth for readiness", "Understand timing varies by industry", "Celebrate skill milestones along with title changes", "Detach self-worth from designation"]'::jsonb 
WHERE scenario_id = 454;

-- Scenario 457: Feeling Behind Financially by 30
UPDATE scenarios 
SET sc_action_steps = '["Make a realistic 5-year plan", "Avoid debt to chase prestige", "Track true net worth, not just assets", "Automate savings", "Celebrate small financial wins"]'::jsonb 
WHERE scenario_id = 457;

-- Scenario 461: Fear About Future Generations’ Planet
UPDATE scenarios 
SET sc_action_steps = '["Join local climate advocacy groups", "Set a positive example in daily habits", "Educate children on sustainability with hope", "Focus on attainable environmental goals", "Support causes that restore ecosystems"]'::jsonb 
WHERE scenario_id = 461;

-- Scenario 462: Feeling Guilty About Carbon Footprint
UPDATE scenarios 
SET sc_action_steps = '["Audit your carbon impact to focus efforts", "Replace high-impact habits first", "Avoid burnout through over-restriction", "Offset travel when possible", "Engage others positively instead of with blame"]'::jsonb 
WHERE scenario_id = 462;

-- Scenario 463: Overwhelmed by Daily Disaster Headlines
UPDATE scenarios 
SET sc_action_steps = '["Set time limits for news intake", "Follow outlets focusing on solutions", "Share positive environmental progress", "Engage in one personal eco-initiative", "Practice gratitude for earth’s resilience"]'::jsonb 
WHERE scenario_id = 463;

-- Scenario 464: Despair at Slow Policy Progress
UPDATE scenarios 
SET sc_action_steps = '["Support local environmental policies", "Educate and mobilize your network", "Communicate respectfully with representatives", "Celebrate small wins", "Trust cumulative impact"]'::jsonb 
WHERE scenario_id = 464;

-- Scenario 466: Feeling Small Against Global Crisis
UPDATE scenarios 
SET sc_action_steps = '["Volunteer locally in sustainability projects", "Measure personal positive impact yearly", "Collaborate to multiply efforts", "Share inspiring change stories", "Stay grounded in purpose over results"]'::jsonb 
WHERE scenario_id = 466;

-- Scenario 467: Judging Others’ Eco-Habits
UPDATE scenarios 
SET sc_action_steps = '["Model sustainable behavior positively", "Invite dialogue about benefits", "Avoid self-righteous comparisons", "Encourage small, doable steps", "Recognize everyone’s journey differs"]'::jsonb 
WHERE scenario_id = 467;

-- Scenario 481: Brain Fog from Constant App Switching
UPDATE scenarios 
SET sc_action_steps = '["Close all unnecessary apps during tasks", "Use site blockers for high-distraction platforms", "Schedule tech-free focus periods daily", "Batch similar digital tasks together", "Journal productivity improvements weekly"]'::jsonb 
WHERE scenario_id = 481;

-- Scenario 472: Career Break Making You Feel Invisible
UPDATE scenarios 
SET sc_action_steps = '["Join professional groups online", "Update skills with short courses", "Network with industry peers regularly", "Volunteer in relevant work to build momentum", "Remind yourself your skills still hold value"]'::jsonb 
WHERE scenario_id = 472;

-- Scenario 473: Losing Creative Spark in Routine Life
UPDATE scenarios 
SET sc_action_steps = '["Schedule weekly creative sessions", "Try unfamiliar art forms or mediums", "Surround yourself with inspiring sources", "Collaborate with other creatives", "Celebrate output regardless of perfection"]'::jsonb 
WHERE scenario_id = 473;

-- Scenario 477: Struggling to Adapt After Retirement
UPDATE scenarios 
SET sc_action_steps = '["List passions postponed during career", "Join interest-based clubs or classes", "Mentor younger people", "Focus on health and relationships", "Create a balanced weekly schedule"]'::jsonb 
WHERE scenario_id = 477;

-- Scenario 479: Losing Faith in Your Abilities After Setback
UPDATE scenarios 
SET sc_action_steps = '["Analyze lessons from the setback", "Identify skills to strengthen", "Separate self-worth from single outcomes", "Reignite pursuits step-by-step", "Surround yourself with encouraging voices"]'::jsonb 
WHERE scenario_id = 479;

-- Scenario 482: Needing Device Nearby at All Times
UPDATE scenarios 
SET sc_action_steps = '["Place device in another room during meals", "Tell others you’re offline during personal time", "Notice improvements in engagement", "Schedule phone checks consciously", "Practice short offline breaks daily"]'::jsonb 
WHERE scenario_id = 482;

-- Scenario 486: Work Suffering from Multitasking Tabs
UPDATE scenarios 
SET sc_action_steps = '["Group related tabs in a single window", "Close unrelated tasks till completion", "Use tab manager extensions", "Review progress on single-task days", "Notice effects on work quality"]'::jsonb 
WHERE scenario_id = 486;

-- Scenario 487: Evenings Consumed by Screens Instead of Relaxation
UPDATE scenarios 
SET sc_action_steps = '["List non-screen relaxing activities", "Set a “screens off” hour before bed", "Engage family in screen-free games", "Track post-evening energy", "Make digital use conscious, not default"]'::jsonb 
WHERE scenario_id = 487;

-- Scenario 488: Phone as Default Social Comfort
UPDATE scenarios 
SET sc_action_steps = '["Keep phone in pocket during conversation", "Ask questions to open dialogue", "Join group topics actively", "Challenge yourself with short no-phone periods at events", "Notice connection depth changes"]'::jsonb 
WHERE scenario_id = 488;

-- Scenario 489: Declining Attention Span from Quick Content
UPDATE scenarios 
SET sc_action_steps = '["Start with slightly longer focus tasks daily", "Increase reading or focus length over weeks", "Reduce quick-content exposure incrementally", "Track attention improvements", "Celebrate deeper engagement as growth"]'::jsonb 
WHERE scenario_id = 489;

-- Scenario 491: Side Hustle Eating Into Family Time
UPDATE scenarios 
SET sc_action_steps = '["Set clear work hours for side business", "Plan family time into your weekly schedule", "Communicate openly about your goals", "Evaluate whether pace is sustainable", "Prioritize well-being alongside ambition"]'::jsonb 
WHERE scenario_id = 491;

-- Scenario 523: Lack of Accountability Hurting Progress
UPDATE scenarios 
SET sc_action_steps = '["Find a habit buddy", "Join a challenge group", "Report progress regularly", "Encourage others’ habits as well", "Mix fun with accountability"]'::jsonb 
WHERE scenario_id = 523;

-- Scenario 493: Burnout from Juggling Job and Side Gig
UPDATE scenarios 
SET sc_action_steps = '["Set realistic weekly workload", "Block rest and recovery periods", "Streamline or automate side business tasks", "Outsource low-priority work", "Check health regularly and adjust commitments"]'::jsonb 
WHERE scenario_id = 493;

-- Scenario 497: Pricing Strategy Doubt in Side Hustle
UPDATE scenarios 
SET sc_action_steps = '["Study industry standard rates", "Factor in time, skill, and expenses", "Test and adjust based on client response", "Communicate value confidently", "Review pricing annually"]'::jsonb 
WHERE scenario_id = 497;

-- Scenario 495: Side Hustle Impacting Day Job Performance
UPDATE scenarios 
SET sc_action_steps = '["Align side hustle hours with peak personal energy", "Avoid working on it during employer time", "Reassess feasibility if conflicts persist", "Set clear priorities between incomes", "Manage expectations on both fronts"]'::jsonb 
WHERE scenario_id = 495;

-- Scenario 496: Comparison with Other Entrepreneurs
UPDATE scenarios 
SET sc_action_steps = '["Track your own monthly progress", "Limit exposure to demotivating comparisons", "Learn selectively from others’ best practices", "Define success beyond revenue", "Invest in personal growth as much as profit"]'::jsonb 
WHERE scenario_id = 496;

-- Scenario 498: Family Skepticism about Your Side Hustle
UPDATE scenarios 
SET sc_action_steps = '["Outline your plan clearly for them", "Share small wins for reassurance", "Avoid seeking validation for every step", "Let results speak with time", "Stay anchored in your purpose"]'::jsonb 
WHERE scenario_id = 498;

-- Scenario 499: Managing Taxes for Side Income
UPDATE scenarios 
SET sc_action_steps = '["Set aside a fixed tax percentage from earnings", "Track income and expenses monthly", "Consult a tax professional early", "Use dedicated accounts for business", "Review tax obligations annually"]'::jsonb 
WHERE scenario_id = 499;

-- Scenario 502: Emotional Drain from Ghosting
UPDATE scenarios 
SET sc_action_steps = '["Limit emotional investment before meeting", "Avoid personalizing ghosting behavior", "Focus on consistent and respectful matches", "Nurture friendships alongside dating", "Maintain self-care during the dating process"]'::jsonb 
WHERE scenario_id = 502;

-- Scenario 503: Multiple Shallow Conversations
UPDATE scenarios 
SET sc_action_steps = '["Ask open-ended, value-based questions", "Share your own deeper interests early", "Politely end chats lacking real engagement", "Prioritize quality over chat volume", "Be authentic from the start"]'::jsonb 
WHERE scenario_id = 503;

-- Scenario 505: Disappointment from Misleading Profiles
UPDATE scenarios 
SET sc_action_steps = '["Request voice/video call before meeting", "Notice inconsistencies in communication", "Keep meetings short for first encounters", "Avoid projecting ideal traits prematurely", "Trust patterns, not just promises"]'::jsonb 
WHERE scenario_id = 505;

-- Scenario 510: Surrounded by People but Feeling Isolated
UPDATE scenarios 
SET sc_action_steps = '["Join small interest-based groups", "Volunteer to meet values-aligned people", "Schedule weekly connection calls with friends/family", "Focus on depth in select relationships", "Limit excessive low-value socializing"]'::jsonb 
WHERE scenario_id = 510;

-- Scenario 512: Feeling Anonymous in Huge Crowds
UPDATE scenarios 
SET sc_action_steps = '["Attend events matching your passions", "Interact with a few people deeply", "Initiate conversations with curiosity", "Share personal stories appropriately", "Set intention before entering social spaces"]'::jsonb 
WHERE scenario_id = 512;

-- Scenario 514: Too Busy to Nurture Friendships
UPDATE scenarios 
SET sc_action_steps = '["Schedule recurring social time weekly", "Integrate socializing with daily routines", "Use commute to connect via calls", "Decline low-value commitments to make space", "Prioritize presence when meeting others"]'::jsonb 
WHERE scenario_id = 514;

-- Scenario 516: Feeling Like Just Another Face at Work
UPDATE scenarios 
SET sc_action_steps = '["Volunteer for visible projects", "Approach colleagues beyond your team", "Ask for feedback proactively", "Offer help without waiting to be asked", "Celebrate others’ work to build rapport"]'::jsonb 
WHERE scenario_id = 516;

-- Scenario 517: Living Alone in a City of Millions
UPDATE scenarios 
SET sc_action_steps = '["Smile and greet people daily", "Join local clubs or volunteer work", "Explore co-living communities", "Use shared public spaces more often", "Balance solitude with connection"]'::jsonb 
WHERE scenario_id = 517;

-- Scenario 518: Language Barrier in New Country City
UPDATE scenarios 
SET sc_action_steps = '["Take language classes", "Join mixed-language groups", "Use translation tools in real time", "Celebrate progress weekly", "Find other newcomers for mutual support"]'::jsonb 
WHERE scenario_id = 518;

-- Scenario 520: Struggling to Stick to Morning Routine
UPDATE scenarios 
SET sc_action_steps = '["Start with one manageable habit", "Track completion daily", "Reward milestones", "Allow for small setbacks", "Increase challenge gradually"]'::jsonb 
WHERE scenario_id = 520;

-- Scenario 521: Losing Motivation Mid-Goal
UPDATE scenarios 
SET sc_action_steps = '["Write down your “why” for the habit", "Create accountability with a friend", "Set interim goals for quick wins", "Track visual progress", "Celebrate process over outcome"]'::jsonb 
WHERE scenario_id = 521;

-- Scenario 522: Overcommitting to Too Many New Habits
UPDATE scenarios 
SET sc_action_steps = '["Limit new habits to 1–3 at a time", "Stack habits onto existing routines", "Phase in new changes gradually", "Reassess every 30 days", "Drop habits that add no value"]'::jsonb 
WHERE scenario_id = 522;

-- Scenario 348: Choosing Ethical Brands Amid Uncomfortable Facts
UPDATE scenarios 
SET sc_action_steps = '["Research brand practices before purchasing", "Support ethically aligned companies", "Reduce consumption where alternatives are unavailable", "Share awareness with others respectfully", "Recognize the power of small consumer actions"]'::jsonb 
WHERE scenario_id = 348;

-- Scenario 360: Temptation to Plagiarize Under Deadlines
UPDATE scenarios 
SET sc_action_steps = '["Break down tasks for manageability", "Seek help instead of cheating", "Credit any borrowed ideas", "Request extensions when needed", "Reflect on long-term trust over short-term gain"]'::jsonb 
WHERE scenario_id = 360;

-- Scenario 362: Conflict of Interest in Decision-Making
UPDATE scenarios 
SET sc_action_steps = '["State the connection openly", "Recuse from decision if appropriate", "Use objective criteria only", "Record the selection process", "Serve organizational interest first"]'::jsonb 
WHERE scenario_id = 362;

-- Scenario 405: Burnout from Wearing Too Many Hats
UPDATE scenarios 
SET sc_action_steps = '["List tasks only you can do", "Outsource or train others for the rest", "Set sustainable work hours", "Schedule personal rest and recovery", "Focus time on business strategy"]'::jsonb 
WHERE scenario_id = 405;

-- Scenario 408: Difficulty Securing Startup Funding
UPDATE scenarios 
SET sc_action_steps = '["Revise pitch based on feedback", "Seek mentorship from respected founders", "Explore alternative funding sources", "Build traction with self-funding if needed", "Be patient while developing trust with investors"]'::jsonb 
WHERE scenario_id = 408;

-- Scenario 410: Balancing Profit with Ethical Practices
UPDATE scenarios 
SET sc_action_steps = '["Define non-negotiable ethical principles", "Assess if opportunities align with them", "Communicate values to customers", "Innovate for profitability and responsibility", "Accept slower growth for integrity"]'::jsonb 
WHERE scenario_id = 410;

-- Scenario 409: Leading Team Change Amidst Resistance
UPDATE scenarios 
SET sc_action_steps = '["Communicate the purpose and benefits of change", "Offer training and support", "Address concerns openly", "Implement in phases to allow adjustment", "Recognize and reward early adopters"]'::jsonb 
WHERE scenario_id = 409;

-- Scenario 419: Focusing on Personal Healing Before Marriage
UPDATE scenarios 
SET sc_action_steps = '["Identify healing areas with honesty", "Seek therapy or mentoring support", "Establish nourishing habits", "Communicate this timeline to suitors", "Celebrate milestones in personal growth"]'::jsonb 
WHERE scenario_id = 419;

-- Scenario 492: Overestimating Side Hustle Income
UPDATE scenarios 
SET sc_action_steps = '["Track actual vs projected earnings", "Cut unnecessary expenses", "Enhance skills for higher-value offers", "Balance optimism with realistic timelines", "Consider part-time work during transition"]'::jsonb 
WHERE scenario_id = 492;

-- Scenario 631: Leading a Meeting for the First Time
UPDATE scenarios 
SET sc_action_steps = '["Outline meeting in advance", "Share agenda ahead", "Use pauses strategically", "Invite written input", "Review and follow-up via email"]'::jsonb 
WHERE scenario_id = 631;

-- Scenario 565: Managing Financial Pressure from Caregiving Costs
UPDATE scenarios 
SET sc_action_steps = '["Research government or ngo support", "Share costs with siblings where possible", "Track all caregiving expenses", "Prioritize essential spending", "Be transparent about limitations"]'::jsonb 
WHERE scenario_id = 565;

-- Scenario 642: Managing Family Criticism in Public Outings
UPDATE scenarios 
SET sc_action_steps = '["Explain meltdown context", "Invite them to learn strategies", "Model calm handling", "Share positive outcomes after outings", "Set boundary if criticism persists"]'::jsonb 
WHERE scenario_id = 642;

-- Scenario 536: Labeled Online by a Single Mistake
UPDATE scenarios 
SET sc_action_steps = '["Acknowledge the mistake sincerely", "Avoid repeating it", "Channel energy into valuable work", "Encourage feedback from trusted people", "Let actions over time shift the narrative"]'::jsonb 
WHERE scenario_id = 536;

-- Scenario 529: The Importance of Tracking Habits for Growth
UPDATE scenarios 
SET sc_action_steps = '["Use a simple habit tracker app or journal", "Review data weekly", "Analyze patterns to adjust strategies", "Celebrate progress tracked visually", "Combine tracking with reflection notes"]'::jsonb 
WHERE scenario_id = 529;

-- Scenario 539: Facing Fear of Speech in Cancel Culture
UPDATE scenarios 
SET sc_action_steps = '["Prepare key points carefully", "Frame opinions respectfully", "Welcome diverse perspectives", "Accept that disagreement is not failure", "Value constructive exchange over universal approval"]'::jsonb 
WHERE scenario_id = 539;

-- Scenario 612: Navigating Misunderstood Humor
UPDATE scenarios 
SET sc_action_steps = '["Notice others’ tone and humor style", "Ask trusted friends for feedback", "Keep humor inclusive", "Apologize when unintended offense happens", "Balance self-expression with audience awareness"]'::jsonb 
WHERE scenario_id = 612;

-- Scenario 634: Choosing Disclosure Timing in Dating
UPDATE scenarios 
SET sc_action_steps = '["Build rapport first", "Choose private, comfortable setting", "Share relevant impacts", "Invite questions", "Observe response over time"]'::jsonb 
WHERE scenario_id = 634;

-- Scenario 624: Owning Your Unique Communication Style
UPDATE scenarios 
SET sc_action_steps = '["Use tools to support clarity", "Explain style to trusted colleagues", "Seek spaces that value diverse voices", "Practice active listening", "Avoid over-apologizing"]'::jsonb 
WHERE scenario_id = 624;

-- Scenario 627: Joining a Neurodiversity Network for Belonging
UPDATE scenarios 
SET sc_action_steps = '["Search company or local groups", "Join online communities", "Attend events to connect in person", "Share experiences and resources", "Offer help to newer members"]'::jsonb 
WHERE scenario_id = 627;

-- Scenario 637: Declining Overload and Invitations Without Guilt
UPDATE scenarios 
SET sc_action_steps = '["Acknowledge invite with gratitude", "State limitation truthfully", "Suggest alternative time", "Replace guilt with self-compassion", "Track well-being after saying no"]'::jsonb 
WHERE scenario_id = 637;

-- Scenario 639: Balancing Sibling Needs with Neurodivergent Care
UPDATE scenarios 
SET sc_action_steps = '["Acknowledge sibling emotions", "Plan 1:1 activities", "Involve them in support when appropriate", "Avoid comparison language", "Celebrate all achievements"]'::jsonb 
WHERE scenario_id = 639;

-- Scenario 641: Navigating Co-parent Disagreement About Diagnosis
UPDATE scenarios 
SET sc_action_steps = '["Share expert resources", "Invite them to attend assessments", "Keep discussions child-focused", "Validate their feelings", "Involve mediator if needed"]'::jsonb 
WHERE scenario_id = 641;

-- Scenario 645: Helping Siblings Advocate for Their Neurodivergent Brother or Sister
UPDATE scenarios 
SET sc_action_steps = '["Role-play common scenarios", "Teach short factual replies", "Encourage seeking adult help", "Praise their support acts", "Balance advocacy with safety"]'::jsonb 
WHERE scenario_id = 645;

-- Scenario 646: Reconciling Different Parenting Styles in Blended Families
UPDATE scenarios 
SET sc_action_steps = '["Discuss core values", "Agree on consistent rules", "Respect each other’s experience", "Adapt rules to child’s needs", "Praise each other for efforts"]'::jsonb 
WHERE scenario_id = 646;

-- Scenario 636: Self-Advocacy for Sensory Needs During Group Travel
UPDATE scenarios 
SET sc_action_steps = '["Discuss needs before itinerary locked", "Offer solutions", "Bring your own aids", "Check in during trip", "Thank group for respect"]'::jsonb 
WHERE scenario_id = 636;

-- Scenario 632: Owning Assistive Tech in Public
UPDATE scenarios 
SET sc_action_steps = '["Normalize tool use through visibility", "Educate curious onlookers briefly", "Inspire others with openness", "Use in varied settings", "Ignore negative reactions"]'::jsonb 
WHERE scenario_id = 632;

-- Scenario 533: Workplace Ostracism After Public Criticism
UPDATE scenarios 
SET sc_action_steps = '["Request one-on-one conversations to clear misunderstandings", "Provide facts without hostility", "Demonstrate steady work ethic", "Show goodwill even towards critics", "Rebuild trust gradually through constancy"]'::jsonb 
WHERE scenario_id = 533;

-- Scenario 534: Being Targeted for Holding Minority Opinion
UPDATE scenarios 
SET sc_action_steps = '["Clarify reasoning behind your view", "Keep tone measured and respectful", "Be open to dialogue instead of debate", "Acknowledge valid counterpoints", "Avoid personal attacks and generalizations"]'::jsonb 
WHERE scenario_id = 534;

-- Scenario 542: Searching for Spiritual Home in Adulthood
UPDATE scenarios 
SET sc_action_steps = '["Visit multiple communities over time", "Engage in trial participation before committing", "Note where you feel authenticity and peace", "Seek leaders who encourage dialogue", "Consider your service opportunities there"]'::jsonb 
WHERE scenario_id = 542;

-- Scenario 543: Disillusionment After Meeting Hypocritical Leaders
UPDATE scenarios 
SET sc_action_steps = '["Acknowledge human fallibility", "Focus on universal principles", "Seek multiple role models", "Avoid blind following", "Judge teachings on merit, not sole messenger"]'::jsonb 
WHERE scenario_id = 543;

-- Scenario 544: Curiosity About Other Traditions
UPDATE scenarios 
SET sc_action_steps = '["Attend events from other traditions respectfully", "Read foundational texts with open mind", "Engage with practitioners sincerely", "Reflect on resonances and contrasts", "Integrate what uplifts your practice"]'::jsonb 
WHERE scenario_id = 544;

-- Scenario 549: Living with Persistent Pain
UPDATE scenarios 
SET sc_action_steps = '["Plan tasks in energy‑friendly chunks", "Use assistive tools where needed", "Celebrate small daily victories", "Seek supportive community groups", "Balance rest with gentle movement"]'::jsonb 
WHERE scenario_id = 549;

-- Scenario 552: Rebuilding Strength After Treatment
UPDATE scenarios 
SET sc_action_steps = '["Set realistic recovery goals", "Monitor health changes weekly", "Acknowledge all progress however small", "Balance exercise with rest", "Seek encouragement from peers"]'::jsonb 
WHERE scenario_id = 552;

-- Scenario 553: Isolation from Chronic Illness
UPDATE scenarios 
SET sc_action_steps = '["Suggest alternative meet‑up formats", "Invite people to your space", "Engage in online communities", "Stay in touch with thoughtful messages", "Be honest about limits while showing care"]'::jsonb 
WHERE scenario_id = 553;

-- Scenario 554: Lifestyle Adjustments for Long-Term Health
UPDATE scenarios 
SET sc_action_steps = '["Identify high‑impact positive changes", "Integrate adjustments gradually", "Celebrate benefits noticed", "Keep healthy options easy to access", "Involve loved ones in supportive habits"]'::jsonb 
WHERE scenario_id = 554;

-- Scenario 555: Balancing Treatment and Work
UPDATE scenarios 
SET sc_action_steps = '["Discuss flexibility with employer", "Group appointments efficiently", "Prioritize rest before demanding tasks", "Use tools to manage time effectively", "Respect recovery days"]'::jsonb 
WHERE scenario_id = 555;

-- Scenario 557: Managing Emotional Impact of Illness
UPDATE scenarios 
SET sc_action_steps = '["Speak openly to a therapist or support group", "Meditate to center mind daily", "Set fulfilling small goals", "Practice gratitude even for small comforts", "Balance emotional work with rest"]'::jsonb 
WHERE scenario_id = 557;

-- Scenario 558: Navigating Insurance and Healthcare Systems
UPDATE scenarios 
SET sc_action_steps = '["Keep all records in one place", "Note deadlines and requirements", "Ask for help from knowledgeable contacts", "Follow up consistently with providers", "Prepare questions before appointments"]'::jsonb 
WHERE scenario_id = 558;

-- Scenario 564: Safety Concerns with Parent Living Alone
UPDATE scenarios 
SET sc_action_steps = '["Install safety devices and alarms", "Schedule regular check‑ins", "Encourage safe environmental changes", "Provide emergency contact systems", "Balance autonomy with security"]'::jsonb 
WHERE scenario_id = 564;

-- Scenario 566: Balancing Care with Parenting Young Kids
UPDATE scenarios 
SET sc_action_steps = '["Combine activities so both generations benefit", "Ask for partner or sibling support", "Block personal recharge time weekly", "Communicate openly with all parties", "Celebrate small moments together"]'::jsonb 
WHERE scenario_id = 566;

-- Scenario 567: Emotional Burnout from Long-Term Care
UPDATE scenarios 
SET sc_action_steps = '["Schedule respite breaks", "Rotate duties among family/friends", "Pursue personal hobbies periodically", "Seek counseling or support groups", "Celebrate your caregiving contributions"]'::jsonb 
WHERE scenario_id = 567;

-- Scenario 568: Working 16-Hour Days Without Rest
UPDATE scenarios 
SET sc_action_steps = '["Set non-negotiable rest periods", "Delegate tasks where possible", "Prioritize health before crisis hits", "Track workload patterns to prevent overload", "Reflect on long-term sustainability regularly"]'::jsonb 
WHERE scenario_id = 568;

-- Scenario 571: Ignoring Early Signs of Burnout
UPDATE scenarios 
SET sc_action_steps = '["Identify burnout symptoms early", "Take short restorative breaks", "Balance high-intensity tasks with easier ones", "Check stress levels weekly", "Prioritize prevention over recovery"]'::jsonb 
WHERE scenario_id = 571;

-- Scenario 572: Pressure from Investors to Overextend
UPDATE scenarios 
SET sc_action_steps = '["Be transparent about realistic timelines", "Negotiate scope instead of silently overextending", "Protect core values in commitments", "Communicate progress proactively", "Limit stakeholder surprises with regular updates"]'::jsonb 
WHERE scenario_id = 572;

-- Scenario 573: Thinking You Are Indispensable
UPDATE scenarios 
SET sc_action_steps = '["Identify tasks others can own", "Train team members well", "Test with small delegated projects", "Focus on high-value leadership work", "Acknowledge strengths in those you delegate to"]'::jsonb 
WHERE scenario_id = 573;

-- Scenario 580: Work Uncertainty During Company Merger
UPDATE scenarios 
SET sc_action_steps = '["Stay informed through reliable channels", "Maintain strong job performance", "Update resume discreetly", "Grow network in relevant industries", "Save extra funds if possible"]'::jsonb 
WHERE scenario_id = 580;

-- Scenario 575: No Celebration of Wins—Only Next Goal
UPDATE scenarios 
SET sc_action_steps = '["Hold small celebrations for milestones", "Share success with team and supporters", "Reflect on challenges overcome", "Journal gratitude regularly", "Balance ambition with appreciation"]'::jsonb 
WHERE scenario_id = 575;

-- Scenario 579: Relocation to Unfamiliar Culture
UPDATE scenarios 
SET sc_action_steps = '["Learn key phrases and customs", "Find local mentors or friends", "Participate in cultural events", "Balance adaptation with personal identity", "Give yourself grace to adjust"]'::jsonb 
WHERE scenario_id = 579;

-- Scenario 578: Navigating Sudden Job Loss: Building Resilience
UPDATE scenarios 
SET sc_action_steps = '["Assess finances calmly", "Clarify desired direction before applying", "Update skills for target roles", "Network methodically", "Treat change as reset opportunity"]'::jsonb 
WHERE scenario_id = 578;

-- Scenario 582: Marriage Transition Challenges
UPDATE scenarios 
SET sc_action_steps = '["Hold regular honest conversations", "Set shared objectives early", "Respect each other’s personal space", "Compromise where needed for harmony", "Celebrate progress in joint adjustment"]'::jsonb 
WHERE scenario_id = 582;

-- Scenario 588: Forgot Major Deadline Due to ADHD
UPDATE scenarios 
SET sc_action_steps = '["Use multiple reminder tools", "Break work into shorter sprints", "Check daily list at same time", "Reward progress every week", "Ask for deadline reminders from team"]'::jsonb 
WHERE scenario_id = 588;

-- Scenario 589: Losing Track of Belongings Everywhere
UPDATE scenarios 
SET sc_action_steps = '["Designate a spot for each item", "Practice a “keys-wallet-phone” check each exit", "Set visual reminders at doors", "Accept imperfection on busy days", "Share struggles with close companions"]'::jsonb 
WHERE scenario_id = 589;

-- Scenario 590: Paralysis When Starting Big Projects
UPDATE scenarios 
SET sc_action_steps = '["Break project into smallest possible actions", "Start with a 5-minute task", "Remind yourself that progress is more important than perfection", "Use visual trackers for accountability", "Reward starting, not just finishing"]'::jsonb 
WHERE scenario_id = 590;

-- Scenario 633: Challenging Patronizing Praise
UPDATE scenarios 
SET sc_action_steps = '["Thank and clarify intention", "Mention specific work or skill instead", "Guide dialogue toward equality", "Avoid sarcasm in correction", "Educate with patience"]'::jsonb 
WHERE scenario_id = 633;

-- Scenario 587: Facing Company Closure: Moving Forward After Sudden Change
UPDATE scenarios 
SET sc_action_steps = '["File for relevant benefits quickly", "Update professional profiles", "Contact network about openings", "Assess budget and trim costs fast", "Frame closure as chance for redirection"]'::jsonb 
WHERE scenario_id = 587;

-- Scenario 598: Meltdowns from Sensory Overload
UPDATE scenarios 
SET sc_action_steps = '["Carry noise-cancelling headphones or sunglasses", "Communicate triggers to those close to you", "Plan routes or escapes for overwhelming places", "Practice grounding (touch, breath)", "Honor recovery time after overload"]'::jsonb 
WHERE scenario_id = 598;

-- Scenario 600: Struggling with Time Blindness
UPDATE scenarios 
SET sc_action_steps = '["Time key activities for a week", "Add buffer time for transitions", "Let others know about this tendency", "Apologize sincerely for lateness", "Seek tools (visual timers, reminders)"]'::jsonb 
WHERE scenario_id = 600;

-- Scenario 602: Forgetfulness in Social Commitments
UPDATE scenarios 
SET sc_action_steps = '["Use shared calendars or reminders", "Apologize sincerely and without excuses", "Explain neurodiversity to close friends", "Set up alerts for key events", "Express gratitude when friends help"]'::jsonb 
WHERE scenario_id = 602;

-- Scenario 605: Missing Important Details
UPDATE scenarios 
SET sc_action_steps = '["Use checklists or peer review", "Double‑check key work daily", "Ask someone to review high-stakes tasks", "See mistakes as guides, not verdicts", "Focus on progress over flawlessness"]'::jsonb 
WHERE scenario_id = 605;

-- Scenario 606: Being Labeled as “Weird” in Social Groups
UPDATE scenarios 
SET sc_action_steps = '["Respond briefly and factually when teased", "Join spaces that embrace diversity", "Model acceptance of others’ differences", "Seek allies within your social groups", "Avoid internalizing hurtful labels"]'::jsonb 
WHERE scenario_id = 606;

-- Scenario 611: Colleagues Underestimating Your Abilities
UPDATE scenarios 
SET sc_action_steps = '["Express interest in complex projects", "Share examples of your past work", "Request feedback and growth opportunities", "Show competence through results", "Educate about your capabilities"]'::jsonb 
WHERE scenario_id = 611;

-- Scenario 614: Being Talked Over Repeatedly
UPDATE scenarios 
SET sc_action_steps = '["Signal you’re not finished speaking", "Use confident body language", "Politely call back to your point", "Support others in similar situations", "Seek moderators’ help if persistent"]'::jsonb 
WHERE scenario_id = 614;

-- Scenario 615: Assumed Incompetent in Public
UPDATE scenarios 
SET sc_action_steps = '["Assert independence politely", "Explain abilities clearly if needed", "Decline unnecessary help firmly", "Share stories to increase awareness", "Surround yourself with affirming people"]'::jsonb 
WHERE scenario_id = 615;

-- Scenario 616: Cultural Misunderstandings with Neurodivergence
UPDATE scenarios 
SET sc_action_steps = '["Learn local communication norms", "Find gentle ways to self-advocate", "Share personal perspective in safe spaces", "Demonstrate respect while being yourself", "Seek cultural allies for bridge-building"]'::jsonb 
WHERE scenario_id = 616;

-- Scenario 617: Left Out of Informal Social Gatherings at Work
UPDATE scenarios 
SET sc_action_steps = '["Approach colleagues during break times", "Invite others for coffee or lunch", "Join workplace interest groups", "Use shared events to build rapport", "Balance social and work focus"]'::jsonb 
WHERE scenario_id = 617;

-- Scenario 618: Events Not Adjusted for Accessibility
UPDATE scenarios 
SET sc_action_steps = '["Inform organizers of needs in advance", "Suggest solutions, not just issues", "Offer to help with inclusive planning", "Publicly thank improvements made", "Support accessibility initiatives for others"]'::jsonb 
WHERE scenario_id = 618;

-- Scenario 619: Loneliness at Large Gatherings
UPDATE scenarios 
SET sc_action_steps = '["Set a small connection goal per event", "Find quiet corners then re-engage", "Ask open-ended questions", "Connect with fellow quieter attendees", "Leave when socially exhausted without guilt"]'::jsonb 
WHERE scenario_id = 619;

-- Scenario 623: Correcting Misinformation Publicly
UPDATE scenarios 
SET sc_action_steps = '["Clarify myth vs. fact", "Stay calm and respectful", "Provide credible resources", "Encourage open questions", "Follow up privately if needed"]'::jsonb 
WHERE scenario_id = 623;

-- Scenario 625: Advocating for Quiet Workspace
UPDATE scenarios 
SET sc_action_steps = '["Identify specific noise issues", "Suggest workable solutions", "Offer trial period to test changes", "Express improved output as goal", "Thank employer for cooperation"]'::jsonb 
WHERE scenario_id = 625;

-- Scenario 626: Explaining Neurodiversity to Children
UPDATE scenarios 
SET sc_action_steps = '["Use age-appropriate language", "Compare to differences they know", "Focus on strengths alongside challenges", "Encourage further questions", "Model self-respect"]'::jsonb 
WHERE scenario_id = 626;

-- Scenario 628: Correcting Pronunciation or Name Errors
UPDATE scenarios 
SET sc_action_steps = '["Gently correct when it happens", "Write phonetic spelling in email signature", "Ask allies to reinforce", "Appreciate genuine effort", "Maintain consistency"]'::jsonb 
WHERE scenario_id = 628;

-- Scenario 629: Speaking Up in Class Despite Fear
UPDATE scenarios 
SET sc_action_steps = '["Prepare key points before class", "Speak early to reduce anxiety", "Acknowledge nerves openly", "Build momentum with each contribution", "Seek supportive feedback"]'::jsonb 
WHERE scenario_id = 629;

-- Scenario 630: Responding to “You Don’t Look Disabled”
UPDATE scenarios 
SET sc_action_steps = '["State fact simply and confidently", "Avoid debating your lived experience", "Share resources when safe", "Connect with those who understand", "Affirm self internally"]'::jsonb 
WHERE scenario_id = 630;

-- Scenario 651: Advocating for Remote Work Option
UPDATE scenarios 
SET sc_action_steps = '["Prepare case with productivity data", "Offer trial period", "Address employer concerns", "Show results after trial", "Keep dialogue open"]'::jsonb 
WHERE scenario_id = 651;

-- Scenario 652: Requesting Assistive Tech in School
UPDATE scenarios 
SET sc_action_steps = '["Collect supporting research", "Apply through formal processes", "Schedule meeting with staff", "Test tech in class", "Share improvements seen"]'::jsonb 
WHERE scenario_id = 652;

-- Scenario 653: Inclusive Team-Building Activities
UPDATE scenarios 
SET sc_action_steps = '["List comfortable activities", "Offer mix of sensory levels", "Pilot small changes", "Gather feedback", "Rotate activity types"]'::jsonb 
WHERE scenario_id = 653;

-- Scenario 654: Navigating Dress Codes with Sensory Sensitivity
UPDATE scenarios 
SET sc_action_steps = '["Identify specific triggers", "Recommend suitable substitutes", "Provide medical note if needed", "Test options with employer", "Maintain within brand requirements"]'::jsonb 
WHERE scenario_id = 654;

-- Scenario 655: Handling Performance Reviews Fairly
UPDATE scenarios 
SET sc_action_steps = '["Request feedback examples", "Share context for misunderstandings", "Highlight strengths", "Agree on clear metrics", "Follow progress plan"]'::jsonb 
WHERE scenario_id = 655;

-- Scenario 656: Written vs. Oral Presentations
UPDATE scenarios 
SET sc_action_steps = '["Offer compromise like pre-recorded video", "Provide written report", "Negotiate portion of oral work", "Share feedback after trial", "Thank teacher for flexibility"]'::jsonb 
WHERE scenario_id = 656;

-- Scenario 657: Clarifying Group Roles in Projects
UPDATE scenarios 
SET sc_action_steps = '["Ask for written role descriptions", "Volunteer for tasks matching strengths", "Request regular check-ins", "Share updates proactively", "Clarify handover points"]'::jsonb 
WHERE scenario_id = 657;

-- Scenario 658: Job Application Process Fatigue
UPDATE scenarios 
SET sc_action_steps = '["Save progress frequently", "Complete sections in short bursts", "Ask for support from a friend", "Track completed applications", "Reward progress, not just offers"]'::jsonb 
WHERE scenario_id = 658;

-- Scenario 659: Difficulty with Rapid-Fire Meetings
UPDATE scenarios 
SET sc_action_steps = '["Ask for agenda beforehand", "Prepare questions in advance", "Request slower pacing when possible", "Follow up with clarifying email", "Share feedback for mutual benefit"]'::jsonb 
WHERE scenario_id = 659;

-- Scenario 660: Navigating Workplace Social Events
UPDATE scenarios 
SET sc_action_steps = '["Plan arrival and exit times", "Stay near quieter areas", "Engage in brief conversations", "Balance attendance with recovery time", "Skip events without guilt"]'::jsonb 
WHERE scenario_id = 660;

-- Scenario 661: Using Visual Aids in Learning
UPDATE scenarios 
SET sc_action_steps = '["Ask for materials in advance", "Take photos of visual aids", "Review slides after class", "Make your own diagrams", "Share visuals with peers"]'::jsonb 
WHERE scenario_id = 661;

-- Scenario 662: Workspace Lighting Sensitivity
UPDATE scenarios 
SET sc_action_steps = '["Move to seat near natural light", "Use tinted lenses or filters", "Request dimmer access", "Take breaks in low-light spaces", "Explain impact to supervisor"]'::jsonb 
WHERE scenario_id = 662;

-- Scenario 663: Providing Multiple Means of Assessment
UPDATE scenarios 
SET sc_action_steps = '["Research school policy", "Speak to instructor early", "Suggest alternatives", "Provide examples of past work", "Follow required steps for requests"]'::jsonb 
WHERE scenario_id = 663;

-- Scenario 664: Advocating for Breaks in Training
UPDATE scenarios 
SET sc_action_steps = '["Ask in advance for break schedule", "Use breaks to reset senses", "Encourage group benefits", "Offer feedback on program design", "Thank trainer for flexibility"]'::jsonb 
WHERE scenario_id = 664;

-- Scenario 665: Struggling with Standardized Test Environments
UPDATE scenarios 
SET sc_action_steps = '["Request smaller test room", "Use noise-cancelling tools if allowed", "Practice in similar setting", "Arrive early to acclimate", "Plan calming routine before test"]'::jsonb 
WHERE scenario_id = 665;

-- Scenario 666: Difficulty with Onboarding Processes
UPDATE scenarios 
SET sc_action_steps = '["Get documents to review later", "Seek mentor or buddy", "Break schedule into stages", "Ask clarifying questions over time", "Track own progress"]'::jsonb 
WHERE scenario_id = 666;

-- Scenario 667: Team Mates Misreading Your Silence
UPDATE scenarios 
SET sc_action_steps = '["Explain your style in team settings", "Contribute in writing if needed", "Acknowledge others’ input", "Show engagement through attentive body language", "Follow up after meetings"]'::jsonb 
WHERE scenario_id = 667;

-- Scenario 668: Fitting Professional Networking Norms
UPDATE scenarios 
SET sc_action_steps = '["Set personal connection goals", "Bring a friend/colleague", "Prepare icebreaker questions", "Follow up post-event online", "Leave when energy dips"]'::jsonb 
WHERE scenario_id = 668;

-- Scenario 669: Handling Last Minute Meeting Changes
UPDATE scenarios 
SET sc_action_steps = '["Use quick breathing techniques", "Recheck priorities", "Communicate conflicts early", "Carry small grounding aid", "Acknowledge flexibility as growth"]'::jsonb 
WHERE scenario_id = 669;

-- Scenario 670: Misinterpretation of Direct Communication
UPDATE scenarios 
SET sc_action_steps = '["Soften delivery without diluting meaning", "Explain your style in private", "Request feedback", "Model listening and respect", "Acknowledge any unintended impact"]'::jsonb 
WHERE scenario_id = 670;

-- Scenario 671: Managing Multiple Supervisors
UPDATE scenarios 
SET sc_action_steps = '["Hold joint meeting to align", "Keep shared task list", "Ask for priority ordering", "Give progress updates to both", "Seek mediation if conflict continues"]'::jsonb 
WHERE scenario_id = 671;

-- Scenario 528: Forgetting to Link Habits to Bigger Purpose
UPDATE scenarios 
SET sc_action_steps = '["Write a purpose statement for the habit", "Visualize the long-term benefit regularly", "Connect habit to helping others", "Make small rituals to honor the habit", "Reflect on personal growth monthly"]'::jsonb 
WHERE scenario_id = 528;

-- Scenario 530: Online Backlash for Old Post
UPDATE scenarios 
SET sc_action_steps = '["Publicly acknowledge the specific issue", "Clarify context without making excuses", "Show concrete actions you’ve taken since", "Engage with critics respectfully", "Learn and grow from the experience"]'::jsonb 
WHERE scenario_id = 530;

-- Scenario 538: Critical Article About You Circulating
UPDATE scenarios 
SET sc_action_steps = '["Point out inaccuracies factually", "Publish your own perspective calmly", "Avoid insulting the publication", "Correct errors through official channels", "Continue living by your values"]'::jsonb 
WHERE scenario_id = 538;

-- Scenario 559: Balancing Career and Parent Care
UPDATE scenarios 
SET sc_action_steps = '["Discuss flexible options with employer", "Share caretaking responsibilities among family", "Hire occasional help if affordable", "Prioritize self‑care to avoid burnout", "Use calendar reminders for caregiving tasks"]'::jsonb 
WHERE scenario_id = 559;

-- Scenario 563: Coping with Seeing Decline
UPDATE scenarios 
SET sc_action_steps = '["Acknowledge your emotions without guilt", "Focus on quality present time", "Seek support groups for shared perspective", "Engage in uplifting activities together", "Accept that change is part of life’s flow"]'::jsonb 
WHERE scenario_id = 563;

-- Scenario 581: Major Health Diagnosis Alters Plans
UPDATE scenarios 
SET sc_action_steps = '["Reevaluate goals in light of new realities", "Break plans into achievable steps", "Prioritize health-supportive routines", "Seek support emotionally and logistically", "Keep long-term vision flexible"]'::jsonb 
WHERE scenario_id = 581;

-- Scenario 610: Teased for Stimming in Public
UPDATE scenarios 
SET sc_action_steps = '["Identify safe environments for self-regulation", "Inform trusted friends about your needs", "Educate curious people briefly when possible", "Ignore or exit unsafe encounters", "Affirm your right to self-care"]'::jsonb 
WHERE scenario_id = 610;

-- Scenario 620: Peers Not Understanding Processing Time
UPDATE scenarios 
SET sc_action_steps = '["Share your communication style upfront", "Ask for questions in advance when possible", "Avoid apologizing for thoughtful pauses", "Deliver clearer responses with time taken", "Educate about different processing needs"]'::jsonb 
WHERE scenario_id = 620;

-- Scenario 621: Explaining Your Needs to a New Boss
UPDATE scenarios 
SET sc_action_steps = '["Prepare concise explanation of your needs", "Share with HR or direct manager", "Highlight how accommodations aid performance", "Offer solutions alongside needs", "Follow up after adjustments"]'::jsonb 
WHERE scenario_id = 621;

-- Scenario 635: Reclaiming Slurs Used Against You
UPDATE scenarios 
SET sc_action_steps = '["Decide your comfort level with term", "Set boundaries clearly", "Educate when safe", "Focus on supportive relationships", "Avoid engaging hostile sources"]'::jsonb 
WHERE scenario_id = 635;

-- Scenario 638: Explaining Child’s Needs to Extended Family
UPDATE scenarios 
SET sc_action_steps = '["Provide simple medical context", "Share how accommodations help", "Invite them to observe differences", "Correct misconceptions kindly", "Encourage questions"]'::jsonb 
WHERE scenario_id = 638;

-- Scenario 643: Grandparent Struggles to Accept Needs
UPDATE scenarios 
SET sc_action_steps = '["Share evidence of improvement", "Demonstrate support tools in action", "Involve grandparent in activities", "Connect to values they hold", "Acknowledge their efforts"]'::jsonb 
WHERE scenario_id = 643;

-- Scenario 644: Balancing Extended Family Demands
UPDATE scenarios 
SET sc_action_steps = '["Explain constraints early", "Plan shorter visits", "Schedule downtime after", "Offer alternative ways to connect", "Stay firm politely"]'::jsonb 
WHERE scenario_id = 644;

-- Scenario 648: Requesting Extra Time for Exams
UPDATE scenarios 
SET sc_action_steps = '["Gather documentation", "Apply before deadlines", "Explain need factually", "Use granted time effectively", "Thank staff for support"]'::jsonb 
WHERE scenario_id = 648;

-- Scenario 672: Overloaded by Multi-Platform Communication
UPDATE scenarios 
SET sc_action_steps = '["Set times to check each channel", "Mute non-critical alerts", "Inform team of response policy", "Use integrations to merge streams", "Close platforms when focusing"]'::jsonb 
WHERE scenario_id = 672;

-- Scenario 833: Feeling Superior Over “Clean Eating”
UPDATE scenarios 
SET sc_action_steps = '["Notice superiority thoughts", "Reframe as personal choice", "Avoid unsolicited advice", "Ask others about favourites", "Celebrate diversity"]'::jsonb 
WHERE scenario_id = 833;

-- Scenario 786: Changing Diet with Every Trend
UPDATE scenarios 
SET sc_action_steps = '["Identify long-term staples", "Trial only one change at a time", "Give changes adequate time", "Note your body’s responses", "Disregard hype"]'::jsonb 
WHERE scenario_id = 786;

-- Scenario 821: Dismissed as “Not Body Positive Enough”
UPDATE scenarios 
SET sc_action_steps = '["Clarify motivations", "Seek similar goal peers", "Avoid engaging trolls", "Track results for motivation", "Celebrate health markers"]'::jsonb 
WHERE scenario_id = 821;

-- Scenario 820: Being Tokenised in Media Campaigns
UPDATE scenarios 
SET sc_action_steps = '["Assess proposal value", "Request genuine engagement", "Decline purely token roles", "Promote authentic narratives", "Suggest diverse casting"]'::jsonb 
WHERE scenario_id = 820;

-- Scenario 843: Managing Stress Eating at Events
UPDATE scenarios 
SET sc_action_steps = '["Eat before to avoid extreme hunger", "Take small portions", "Put down utensils between bites", "Engage in conversation between mouthfuls", "Leave when full"]'::jsonb 
WHERE scenario_id = 843;

-- Scenario 824: Loneliness After Weight Loss Success
UPDATE scenarios 
SET sc_action_steps = '["Explain non-judgment for others’ bodies", "Share focus on health over size", "Invite joint activities", "Avoid competitiveness", "Maintain long-term friendship"]'::jsonb 
WHERE scenario_id = 824;

-- Scenario 831: Eating Out Causes Anxiety and Isolation
UPDATE scenarios 
SET sc_action_steps = '["Research menu ahead", "Call venue", "Suggest restaurant choice", "Eat beforehand if needed", "Practice flexibility"]'::jsonb 
WHERE scenario_id = 831;

-- Scenario 849: Self-Conscious Eating in Public
UPDATE scenarios 
SET sc_action_steps = '["Practice eating slowly", "Use grounding techniques", "Focus on others talking", "Avoid mirrors/screens", "Reframe dining as connection"]'::jsonb 
WHERE scenario_id = 849;

-- Scenario 836: Over-Exercising to Compensate for Food Choices
UPDATE scenarios 
SET sc_action_steps = '["Set rational exercise plan", "Consult trainer", "Rest adequately", "Separate food and exercise mentally", "Celebrate movement for health"]'::jsonb 
WHERE scenario_id = 836;

-- Scenario 837: Rejecting Nourishing Food Due to Restrictive Rules
UPDATE scenarios 
SET sc_action_steps = '["Note hunger cues", "Allow occasional rule exceptions", "Track energy changes", "Discuss with dietitian", "Adjust list seasonally"]'::jsonb 
WHERE scenario_id = 837;

-- Scenario 678: Feeling Isolated by Lack of Understanding
UPDATE scenarios 
SET sc_action_steps = '["Join nd-focused groups", "Share experiences", "Seek shared hobbies", "Arrange regular meetups", "Engage online if offline hard"]'::jsonb 
WHERE scenario_id = 678;

-- Scenario 835: Self-Worth Tied to Diet Purity
UPDATE scenarios 
SET sc_action_steps = '["List non-food strengths", "Reframe holiday/unplanned meals", "Focus on consistency", "Practice self-forgiveness", "Engage in non-food joys"]'::jsonb 
WHERE scenario_id = 835;

-- Scenario 782: Avoiding Social Events Over Food Concerns
UPDATE scenarios 
SET sc_action_steps = '["Eat before/bring your own dish", "Focus on company not menu", "Relax rules occasionally", "See food as one part of health", "Seek help if anxiety grows"]'::jsonb 
WHERE scenario_id = 782;

-- Scenario 790: Avoiding Social Events Over Food Concerns
UPDATE scenarios 
SET sc_action_steps = '["Eat before/bring your own dish", "Focus on company not menu", "Relax rules occasionally", "See food as one part of health", "Seek help if anxiety grows"]'::jsonb 
WHERE scenario_id = 790;

-- Scenario 810: Avoiding Social Events Over Food Concerns
UPDATE scenarios 
SET sc_action_steps = '["Eat beforehand or bring dish", "Focus on people not menu", "Relax rules occasionally", "See food as part of whole health", "Seek help if anxiety rises"]'::jsonb 
WHERE scenario_id = 810;

-- Scenario 797: Diet Judged in the Workplace
UPDATE scenarios 
SET sc_action_steps = '["Prepare responses to comments", "Eat with supportive peers", "Educate when possible", "Ignore persistent negativity", "Stay consistent"]'::jsonb 
WHERE scenario_id = 797;

-- Scenario 839: Hiding Eating Habits to Avoid Judgment
UPDATE scenarios 
SET sc_action_steps = '["Identify one safe sharer", "Discuss without apology", "Invite them to meal", "Accept differing views", "Keep connection strong"]'::jsonb 
WHERE scenario_id = 839;

-- Scenario 832: Judging Others’ Food Choices
UPDATE scenarios 
SET sc_action_steps = '["Keep focus on own plate", "Avoid food policing", "Compliment variety", "Invite without pressure", "Support autonomy"]'::jsonb 
WHERE scenario_id = 832;

-- Scenario 851: Fear of Buffets Due to Spillage Anxiety
UPDATE scenarios 
SET sc_action_steps = '["Use smaller plates", "Queue at quieter times", "Ask for help serving", "Laugh off small mishaps", "Enjoy variety offered"]'::jsonb 
WHERE scenario_id = 851;

-- Scenario 855: Social Anxiety: Eating with New People
UPDATE scenarios 
SET sc_action_steps = '["Start with 1-1 meals", "Join small groups", "Choose relaxed venues", "Share nervousness if comfortable", "Increase exposure gradually"]'::jsonb 
WHERE scenario_id = 855;

-- Scenario 685: Frustration at Slow Progress in Learning
UPDATE scenarios 
SET sc_action_steps = '["Track milestones weekly", "Review growth over months", "Lower unrealistic deadlines", "Celebrate effort", "Share progression with mentor"]'::jsonb 
WHERE scenario_id = 685;

-- Scenario 838: Rediscovering Joy in Cooking and Eating
UPDATE scenarios 
SET sc_action_steps = '["Explore new cuisines", "Cook with friends", "Use music while cooking", "Grow herbs and take care for them", "Rotate menus but don’t overwhelm yourself"]'::jsonb 
WHERE scenario_id = 838;

-- Scenario 755: Criticised for Buying New Clothes
UPDATE scenarios 
SET sc_action_steps = '["Explain purpose of purchase", "Support ethical brands when new", "Balance thrift and need", "Rotate wardrobe responsibly", "Declutter consciously"]'::jsonb 
WHERE scenario_id = 755;

-- Scenario 764: Wishing for Bigger Home Despite Minimalism
UPDATE scenarios 
SET sc_action_steps = '["Rearrange for better function", "Declutter unused items", "Add vertical storage", "Spend more time outdoors", "Visit larger homes as inspiration only"]'::jsonb 
WHERE scenario_id = 764;

-- Scenario 766: Judged for Not Owning an Electric Car
UPDATE scenarios 
SET sc_action_steps = '["Research affordable models", "Use public transit more often", "Maintain current car efficiently", "Save for future switch", "Inform critics of practical steps"]'::jsonb 
WHERE scenario_id = 766;

-- Scenario 767: Expectation to DIY Everything
UPDATE scenarios 
SET sc_action_steps = '["Select projects with meaning", "Buy essentials without guilt", "Budget time honestly", "Share realistic capacities", "Encourage diversity of approach"]'::jsonb 
WHERE scenario_id = 767;

-- Scenario 768: Criticism for Using Modern Technology
UPDATE scenarios 
SET sc_action_steps = '["Highlight long lifespan of your tech", "Use energy-saving settings", "Offset impact via eco actions", "Explain trade-offs calmly", "Promote mindful tech use"]'::jsonb 
WHERE scenario_id = 768;

-- Scenario 769: Feeling Overwhelmed by Activism Responsibilities
UPDATE scenarios 
SET sc_action_steps = '["Review commitments quarterly", "Delegate tasks", "Alternate high- and low-energy roles", "Block rest days", "Celebrate small wins"]'::jsonb 
WHERE scenario_id = 769;

-- Scenario 770: Overwhelmed by Sustainable Product Choices
UPDATE scenarios 
SET sc_action_steps = '["Select trusted recommendations", "Test small sizes first", "Rotate only when needed", "Track preferences", "Ignore constant new ads"]'::jsonb 
WHERE scenario_id = 770;

-- Scenario 771: Choosing Ethics versus Affordability in Shopping
UPDATE scenarios 
SET sc_action_steps = '["Prioritise top-impact items", "Mix ethical and budget buys", "Seek sales/discounts", "Plan spending in advance", "Celebrate any ethical choice"]'::jsonb 
WHERE scenario_id = 771;

-- Scenario 776: Lack of Infrastructure for Compost
UPDATE scenarios 
SET sc_action_steps = '["Research drop-off locations", "Try balcony/worm compost", "Advocate with council", "Join local compost co-op", "Share compost with gardeners"]'::jsonb 
WHERE scenario_id = 776;

-- Scenario 777: Cultural Norms Against Second-Hand Shopping
UPDATE scenarios 
SET sc_action_steps = '["Wear thrift finds proudly", "Explain benefits to others", "Host swap events", "Gift quality preloved items", "Highlight cultural examples"]'::jsonb 
WHERE scenario_id = 777;

-- Scenario 779: Confused by Contradictory Diet Advice
UPDATE scenarios 
SET sc_action_steps = '["Limit sources to credible experts", "Observe what works for your body", "Avoid drastic changes", "Keep a food journal", "Review progress monthly"]'::jsonb 
WHERE scenario_id = 779;

-- Scenario 780: Friend Pressures You to Follow Their Diet
UPDATE scenarios 
SET sc_action_steps = '["Thank them for concern", "Explain your approach", "Share any positive results you’ve had", "Avoid debating excessively", "Stand firm kindly"]'::jsonb 
WHERE scenario_id = 780;

-- Scenario 785: Conflicting Advice from Multiple Professionals
UPDATE scenarios 
SET sc_action_steps = '["List commonalities between plans", "Test changes gradually", "Track results objectively", "Communicate openly with providers", "Adjust based on evidence"]'::jsonb 
WHERE scenario_id = 785;

-- Scenario 795: Changing Diet with Every Trend
UPDATE scenarios 
SET sc_action_steps = '["Identify long‑term staples", "Trial only one change at a time", "Give changes adequate time", "Note your body’s responses", "Disregard hype"]'::jsonb 
WHERE scenario_id = 795;

-- Scenario 787: Family Conflict over Food Choices
UPDATE scenarios 
SET sc_action_steps = '["List cross-compatible dishes", "Cook together occasionally", "Respect each person’s plan", "Create shared snack list", "Rotate favourite meals"]'::jsonb 
WHERE scenario_id = 787;

-- Scenario 823: Overlooking Marginalised Body Types
UPDATE scenarios 
SET sc_action_steps = '["Share platform with diverse voices", "Educate mainstream allies", "Highlight systemic gaps", "Support intersectional campaigns", "Model inclusivity"]'::jsonb 
WHERE scenario_id = 823;

-- Scenario 826: Compulsive Ingredient Checking
UPDATE scenarios 
SET sc_action_steps = '["List key avoid items", "Skim for main triggers", "Shop from trusted brands", "Limit check time", "Rotate trusted products"]'::jsonb 
WHERE scenario_id = 826;

-- Scenario 828: Missing Nutrition Due to Dietary Restriction
UPDATE scenarios 
SET sc_action_steps = '["Book dietitian appointment", "Reintroduce key nutrients", "Monitor health signs", "Adjust plan sustainably", "Share progress with mentor"]'::jsonb 
WHERE scenario_id = 828;

-- Scenario 829: Travel Anxiety Around Food
UPDATE scenarios 
SET sc_action_steps = '["Research ahead", "Pack snacks", "Identify local safe spots", "Travel with supportive friends", "Relinquish control occasionally"]'::jsonb 
WHERE scenario_id = 829;

-- Scenario 830: Time Lost to Food Preparation
UPDATE scenarios 
SET sc_action_steps = '["Batch cook", "Share prep with others", "Use simpler recipes", "Limit prep sessions", "Value time balance"]'::jsonb 
WHERE scenario_id = 830;

-- Scenario 842: Skipping Work Lunches Due to Self-Consciousness
UPDATE scenarios 
SET sc_action_steps = '["Attend with a trusted colleague", "Plan your meal in advance", "Focus on conversation over food", "Limit exposure gradually", "Note positive experiences"]'::jsonb 
WHERE scenario_id = 842;

-- Scenario 846: Avoiding Shared Meals for Dietary Needs
UPDATE scenarios 
SET sc_action_steps = '["Inform host in advance", "Offer to bring a dish", "Frame explanations positively", "Show appreciation for effort", "Focus on connection"]'::jsonb 
WHERE scenario_id = 846;

-- Scenario 848: Silent Through Group Meals
UPDATE scenarios 
SET sc_action_steps = '["Prepare topics beforehand", "Ask open questions", "Compliment the food", "Share brief stories", "Smile and make eye contact"]'::jsonb 
WHERE scenario_id = 848;

-- Scenario 850: Leaving Early to Avoid Dessert Pressure
UPDATE scenarios 
SET sc_action_steps = '["Simply say no thank you", "Suggest sharing portions", "Focus on conversation", "Compliment presentation", "Stay to enjoy company"]'::jsonb 
WHERE scenario_id = 850;

-- Scenario 852: Only Eating After Everyone Else
UPDATE scenarios 
SET sc_action_steps = '["Arrive with appetite", "Serve yourself early", "Sit near supportive people", "Engage in light chat", "Enjoy full event"]'::jsonb 
WHERE scenario_id = 852;

-- Scenario 674: Masking Fatigue: Reclaiming Energy and Authenticity
UPDATE scenarios 
SET sc_action_steps = '["Identify safe people", "Limit masking to necessary contexts", "Schedule decompression time", "Practice self-acceptance habits", "Seek support from peers"]'::jsonb 
WHERE scenario_id = 674;

-- Scenario 673: Difficulty Following Multi-Step Tasks
UPDATE scenarios 
SET sc_action_steps = '["Ask for step-by-step documentation", "Make your own checklist", "Confirm understanding before starting", "Review after completion", "Refine process based on feedback"]'::jsonb 
WHERE scenario_id = 673;

-- Scenario 683: Fear of Losing Support When Disclosing Needs
UPDATE scenarios 
SET sc_action_steps = '["Identify safe people to disclose to", "State needs clearly linked to outcomes", "Offer updates on progress", "Acknowledge support given", "Ensure mutual respect"]'::jsonb 
WHERE scenario_id = 683;

-- Scenario 676: Depression from Chronic Misunderstanding
UPDATE scenarios 
SET sc_action_steps = '["Identify uplifting connections", "Limit time with critical voices", "Engage in valued activities", "Seek counselling", "Document achievements"]'::jsonb 
WHERE scenario_id = 676;

-- Scenario 677: Burnout from Overcompensating
UPDATE scenarios 
SET sc_action_steps = '["Track hours honestly", "Say no when capacity is reached", "Delegate where possible", "Prioritize rest", "Share limits with colleagues"]'::jsonb 
WHERE scenario_id = 677;

-- Scenario 679: Shame from Public Meltdowns
UPDATE scenarios 
SET sc_action_steps = '["Debrief with trusted person", "Schedule calming time after", "Prepare aids for future", "Challenge negative self-talk", "Practice exposure when ready"]'::jsonb 
WHERE scenario_id = 679;

-- Scenario 680: Overwhelm from Constant Adaptation
UPDATE scenarios 
SET sc_action_steps = '["Limit unnecessary adaptation", "Choose contexts that accept you", "Plan full rest days", "Seek flexible environments", "Educate close contacts"]'::jsonb 
WHERE scenario_id = 680;

-- Scenario 681: Self-Doubt from Comparing to Peers
UPDATE scenarios 
SET sc_action_steps = '["Identify personal growth markers", "Limit comparison triggers", "Celebrate individual wins", "Document effort and learning", "Share perspective with allies"]'::jsonb 
WHERE scenario_id = 681;

-- Scenario 682: Health Impact of Chronic Stress
UPDATE scenarios 
SET sc_action_steps = '["Recognize early signs", "Adopt calming routines", "Improve sleep/nutrition", "Seek medical advice", "Adjust commitments"]'::jsonb 
WHERE scenario_id = 682;

-- Scenario 684: Guilt from Needing Accommodations
UPDATE scenarios 
SET sc_action_steps = '["Reframe accommodations as equity", "Note improved performance", "Share benefits for team", "Keep requests reasonable", "Release guilt through gratitude"]'::jsonb 
WHERE scenario_id = 684;

-- Scenario 754: Comparing to Influencer Eco‑Lifestyles
UPDATE scenarios 
SET sc_action_steps = '["Identify what inspires vs pressures", "Adopt ideas that fit budget", "Share your authentic progress", "Limit time on triggering feeds", "Focus on internal satisfaction"]'::jsonb 
WHERE scenario_id = 754;

-- Scenario 834: Overcoming Meal Timing Rigidity: Building Flexibility Around Food
UPDATE scenarios 
SET sc_action_steps = '["Adjust meal window gradually", "Distract during delay", "Communicate calmly and plan timing", "Pack snacks for buffer", "Track reduced stress, if needed"]'::jsonb 
WHERE scenario_id = 834;

-- Scenario 758: Missing Sentimental Items
UPDATE scenarios 
SET sc_action_steps = '["Photograph items before letting go", "Create memory albums", "Discuss feelings with friends", "Avoid hasty decluttering", "Keep a small memory box"]'::jsonb 
WHERE scenario_id = 758;

-- Scenario 759: Neglecting Comfort for Aesthetic Minimalism
UPDATE scenarios 
SET sc_action_steps = '["Add plants/soft furnishings", "Balance empty space with utility", "Invite feedback from guests", "Rotate decor seasonally", "Choose comfort as self‑care"]'::jsonb 
WHERE scenario_id = 759;

-- Scenario 760: Underestimating Time to Maintain Systems
UPDATE scenarios 
SET sc_action_steps = '["Track actual upkeep time", "Expand items slightly if needed", "Batch chores", "Ask household for help", "Be flexible with rules"]'::jsonb 
WHERE scenario_id = 760;

-- Scenario 762: Feeling Behind in Sustainable Trends
UPDATE scenarios 
SET sc_action_steps = '["Research actual impact", "Delay purchase 30 days", "Borrow or test first", "Prioritise most impactful change", "Share reasoning openly"]'::jsonb 
WHERE scenario_id = 762;

-- Scenario 763: Comparison to Zero Waste Stores
UPDATE scenarios 
SET sc_action_steps = '["Integrate refill trips occasionally", "Supplement with bulk buys", "Avoid shaming self for convenience", "Support multiple sustainable models", "Share tips across communities"]'::jsonb 
WHERE scenario_id = 763;

-- Scenario 765: Pressure to Go Fully Off-Grid
UPDATE scenarios 
SET sc_action_steps = '["Evaluate feasibility honestly", "Start with partial measures", "Track impact over time", "Educate peers on your journey", "Reject all-or-nothing narratives"]'::jsonb 
WHERE scenario_id = 765;

-- Scenario 773: Confused by Conflicting Eco Labels
UPDATE scenarios 
SET sc_action_steps = '["Research top 2–3 certifications", "List greenwashing signs", "Shop from verified sources", "Educate friends", "Update list annually"]'::jsonb 
WHERE scenario_id = 773;

-- Scenario 791: Spending Hours Planning Perfect Meals
UPDATE scenarios 
SET sc_action_steps = '["Set time limit for planning", "Batch‑prep ingredients", "Choose flexible recipes", "Allow occasional deviations", "Value social and mental health equally"]'::jsonb 
WHERE scenario_id = 791;

-- Scenario 781: Feeling Shame for Wanting to Change Body
UPDATE scenarios 
SET sc_action_steps = '["Clarify your reasons", "Choose respectful communities", "Focus on health not punishment", "Share journey selectively", "Release fear of labels"]'::jsonb 
WHERE scenario_id = 781;

-- Scenario 804: Group Challenges Becoming Obsessive
UPDATE scenarios 
SET sc_action_steps = '["Assess potential stress", "Join with friends for support", "Quit if harming health", "Share realistic reflections", "Encourage diversity"]'::jsonb 
WHERE scenario_id = 804;

-- Scenario 805: Celebrity Endorsements Swaying Choices
UPDATE scenarios 
SET sc_action_steps = '["Check impartial reviews", "Consider cost‑benefit", "Test cautiously", "Consult nutrition pro", "Avoid hero worship"]'::jsonb 
WHERE scenario_id = 805;

-- Scenario 809: Criticised for Fitness Goals
UPDATE scenarios 
SET sc_action_steps = '["Explain your reasons", "Seek supportive peers", "Release the need for approval", "Track holistic progress", "Celebrate milestones"]'::jsonb 
WHERE scenario_id = 809;

-- Scenario 812: Online Groups Policing Body Talk
UPDATE scenarios 
SET sc_action_steps = '["Join moderated, respectful groups", "Frame posts with context", "Avoid shaming language", "Encourage balanced dialogue", "Report toxic moderation when needed"]'::jsonb 
WHERE scenario_id = 812;

-- Scenario 813: Comparing to “Perfect” Confidence Displays
UPDATE scenarios 
SET sc_action_steps = '["Limit comparison to curated images", "Practice daily self-affirmations", "Engage with vulnerability posts", "Share your own growth story", "Focus on inner progress"]'::jsonb 
WHERE scenario_id = 813;

-- Scenario 815: Dismissed for Seeking Fitness Goals
UPDATE scenarios 
SET sc_action_steps = '["Research inclusive trainers", "Invite others to join you", "Avoid spaces with rigid ideology", "Celebrate others’ diverse goals", "Share mutual encouragement"]'::jsonb 
WHERE scenario_id = 815;

-- Scenario 816: Toxic Positivity After Health Concerns
UPDATE scenarios 
SET sc_action_steps = '["Advocate for being heard", "Mix positive mindset with action", "Seek supportive listeners", "Document symptoms for doctors", "Maintain health journal"]'::jsonb 
WHERE scenario_id = 816;

-- Scenario 818: Bullying in “Positive” Spaces
UPDATE scenarios 
SET sc_action_steps = '["Document incidents", "Discuss with moderators", "Support others experiencing same", "Model inclusive behaviour", "Consider leaving irredeemable spaces"]'::jsonb 
WHERE scenario_id = 818;

-- Scenario 819: Feeling Shame for Wanting to Change Body
UPDATE scenarios 
SET sc_action_steps = '["Allow yourself nuance", "Journal both feelings", "Discuss with open-minded peers", "Release binary thinking", "Affirm dual truths"]'::jsonb 
WHERE scenario_id = 819;

-- Scenario 853: Needing Alcohol to Eat Socially
UPDATE scenarios 
SET sc_action_steps = '["Limit to minimal if any", "Practice relaxation techniques", "Attend alcohol-free events", "Reward sober successes", "Track progress"]'::jsonb 
WHERE scenario_id = 853;

-- Scenario 856: Cultural Foods Judged as Unhealthy
UPDATE scenarios 
SET sc_action_steps = '["Share nutritional facts", "Cook for friends to try", "Explain cultural significance", "Blend traditions with health tweaks", "Stay confident in identity"]'::jsonb 
WHERE scenario_id = 856;

-- Scenario 686: Hopelessness During Job Hunt
UPDATE scenarios 
SET sc_action_steps = '["Refine resume for fit", "Practice interviews", "Network in nd-friendly sectors", "Set weekly application goal", "Reframe each rejection as redirection"]'::jsonb 
WHERE scenario_id = 686;

-- Scenario 687: Mood Swings from Overstimulation
UPDATE scenarios 
SET sc_action_steps = '["Share patterns with close people", "Prevent triggers where possible", "Allow decompression time", "Apologize if needed", "Engage only when regulated"]'::jsonb 
WHERE scenario_id = 687;

-- Scenario 751: Guilt Over Occasional Plastic Use
UPDATE scenarios 
SET sc_action_steps = '["Track overall positive impact", "Identify most impactful actions", "Forgive small lapses", "Share realistic journeys", "Avoid all‑or‑nothing mindset"]'::jsonb 
WHERE scenario_id = 751;

-- Scenario 752: Shamed for Not Having Solar Panels
UPDATE scenarios 
SET sc_action_steps = '["Explain limitations honestly", "Research grants/assistance", "Plan attainable steps", "Celebrate others without comparison", "Avoid debt for appearances"]'::jsonb 
WHERE scenario_id = 752;

-- Scenario 756: Decision Paralysis from Too Few Items
UPDATE scenarios 
SET sc_action_steps = '["Audit what’s missing", "List top 5 items to restore", "Buy second‑hand first", "Test changes before committing", "Keep adjustments guilt‑free"]'::jsonb 
WHERE scenario_id = 756;

-- Scenario 757: Fatigue from Continual Decluttering
UPDATE scenarios 
SET sc_action_steps = '["Set declutter-free months", "Appreciate what remains", "Automate donation drop-offs", "Limit intake of new advice", "Enjoy current space"]'::jsonb 
WHERE scenario_id = 757;

-- Scenario 772: Overanalyzing Every Purchase
UPDATE scenarios 
SET sc_action_steps = '["Identify top categories", "Make default choices", "Limit research time", "Accept imperfection", "Review changes yearly"]'::jsonb 
WHERE scenario_id = 772;

-- Scenario 778: Limited Space for Bulk Buying
UPDATE scenarios 
SET sc_action_steps = '["Measure actual consumption", "Choose stackable containers", "Share bulk with others", "Rotate stock", "Avoid waste through overbuying"]'::jsonb 
WHERE scenario_id = 778;

-- Scenario 775: Low Income Limits Eco Choices
UPDATE scenarios 
SET sc_action_steps = '["Reuse items creatively", "Focus on energy/water saving", "Swap goods with others", "Repair before replacing", "Share tips with similar budgets"]'::jsonb 
WHERE scenario_id = 775;

-- Scenario 784: Friend Pressures You to Follow Their Diet
UPDATE scenarios 
SET sc_action_steps = '["Thank them for concern", "Explain your approach", "Share any positive results you’ve had", "Avoid debating excessively", "Stand firm kindly"]'::jsonb 
WHERE scenario_id = 784;

-- Scenario 793: Friend Pressures You to Follow Their Diet
UPDATE scenarios 
SET sc_action_steps = '["Thank them for concern", "Explain your approach", "Share any positive results you’ve had", "Avoid debating excessively", "Stand firm kindly"]'::jsonb 
WHERE scenario_id = 793;

-- Scenario 789: Criticised for Fitness Goals
UPDATE scenarios 
SET sc_action_steps = '["Explain your “why”", "Seek supportive friends", "Release need for everyone’s approval", "Track personal markers", "Celebrate effort"]'::jsonb 
WHERE scenario_id = 789;

-- Scenario 799: Diet Debate Taking Over Social Media
UPDATE scenarios 
SET sc_action_steps = '["Limit comment time", "Unfollow high‑conflict threads", "Share only lived experience", "Promote respectful dialogue", "Channel energy into self‑care"]'::jsonb 
WHERE scenario_id = 799;

-- Scenario 801: Confused by “Superfood” Marketing
UPDATE scenarios 
SET sc_action_steps = '["Check scientific backing", "See if it fits your needs", "Avoid expensive fads", "Watch for allergens", "Track real benefits"]'::jsonb 
WHERE scenario_id = 801;

-- Scenario 802: Cultural Diet vs. Modern Trends
UPDATE scenarios 
SET sc_action_steps = '["Retain key cultural staples", "Adjust cooking methods", "Share benefits of heritage foods", "Educate younger family", "Celebrate fusion recipes"]'::jsonb 
WHERE scenario_id = 802;

-- Scenario 811: Spending Hours Planning Perfect Meals
UPDATE scenarios 
SET sc_action_steps = '["Set timer for sessions", "Batch‑prep ingredients", "Include flexible meals", "Accept occasional impromptu meals", "Note mental health impact"]'::jsonb 
WHERE scenario_id = 811;

-- Scenario 822: Judged for Clothing Choices
UPDATE scenarios 
SET sc_action_steps = '["Wear what empowers you", "Share styling inspirations", "Ignore unsolicited advice", "Support diverse fashion", "Affirm others’ choices"]'::jsonb 
WHERE scenario_id = 822;

-- Scenario 825: Fear of “Impure” Foods
UPDATE scenarios 
SET sc_action_steps = '["Identify safe flexibility points", "Plan indulgence without guilt", "Communicate needs without shaming", "Share meals occasionally", "Release need for 100% purity"]'::jsonb 
WHERE scenario_id = 825;

-- Scenario 847: Bringing Own Food to Gatherings
UPDATE scenarios 
SET sc_action_steps = '["Pack food discreetly", "Explain briefly if asked", "Eat without apology", "Offer tastes to others", "Model self-acceptance"]'::jsonb 
WHERE scenario_id = 847;

-- Scenario 840: Using Only Home-Cooked Meals as Virtue
UPDATE scenarios 
SET sc_action_steps = '["Plan restaurant visits mindfully", "Value shared experience", "Separate ethics and ego", "Enjoy variety", "Support local businesses"]'::jsonb 
WHERE scenario_id = 840;

-- Scenario 854: Judged for Portion Sizes
UPDATE scenarios 
SET sc_action_steps = '["Respond briefly without apology", "Serve own plate", "Avoid explaining repeatedly", "Redirect conversation", "Model self-trust"]'::jsonb 
WHERE scenario_id = 854;

-- Scenario 870: Obsessive Calorie Tracking Undermines Health
UPDATE scenarios 
SET sc_action_steps = '["Set flexible ranges", "Take breaks from logging", "Notice satiety cues", "Focus on nutrient quality", "Keep mental health in check"]'::jsonb 
WHERE scenario_id = 870;

-- Scenario 863: Overtraining for Aesthetic Goals
UPDATE scenarios 
SET sc_action_steps = '["Set performance goals", "Schedule rest days", "Track energy levels", "Work with a balanced trainer", "Celebrate strength gains"]'::jsonb 
WHERE scenario_id = 863;

-- Scenario 1074: Struggling with Self-Harm Thoughts
UPDATE scenarios 
SET sc_action_steps = '["Talk to a counselor", "Teacher", "Or loved one immediately", "Create a safety plan and distraction list", "Remember that emotions change—this moment will pass", "Engage in activities that uplift your spirit", "Even if slowly"]'::jsonb 
WHERE scenario_id = 1074;

-- Scenario 913: Social Media Comparison and Validation Seeking
UPDATE scenarios 
SET sc_action_steps = '["Limit social media use with clear time boundaries.", "Reflect on your inner qualities and growth.", "Celebrate others without comparing yourself.", "Practice silence", "Journaling", "Or meditation daily."]'::jsonb 
WHERE scenario_id = 913;

-- Scenario 857: Family Resists New Dietary Needs
UPDATE scenarios 
SET sc_action_steps = '["Explain needs gently", "Offer to help cook", "Suggest alternatives", "Thank them for understanding", "Stay firm when pressured"]'::jsonb 
WHERE scenario_id = 857;

-- Scenario 860: Mocked for Religious Food Practices
UPDATE scenarios 
SET sc_action_steps = '["Share personal meaning", "Invite to observe", "Stay respectful of differences", "Link practice to values", "Model tolerance"]'::jsonb 
WHERE scenario_id = 860;

-- Scenario 873: Avoiding Enjoyment Foods Completely
UPDATE scenarios 
SET sc_action_steps = '["Plan occasional indulgence", "Share with friends", "Avoid guilt language", "Note mood benefits", "Keep balanced meals"]'::jsonb 
WHERE scenario_id = 873;

-- Scenario 865: Avoiding Strength Training for Fear of “Bulk”
UPDATE scenarios 
SET sc_action_steps = '["Research credible sources", "Try guided sessions", "Track progress by health", "Challenge stereotypes", "Enjoy new abilities"]'::jsonb 
WHERE scenario_id = 865;

-- Scenario 858: Workplace Potlucks Excluding Your Cuisine
UPDATE scenarios 
SET sc_action_steps = '["Pick popular flavours from culture", "Explain origins briefly", "Invite feedback", "Encourage tasting", "Rotate dishes for variety"]'::jsonb 
WHERE scenario_id = 858;

-- Scenario 871: Avoiding Medical Help to Keep Training
UPDATE scenarios 
SET sc_action_steps = '["Schedule check-ups early", "View rest as training", "Follow medical advice", "Gradually return to activity", "Share learning"]'::jsonb 
WHERE scenario_id = 871;

-- Scenario 874: Body Dysmorphia Triggers from Gym Mirrors
UPDATE scenarios 
SET sc_action_steps = '["Choose mirror-free spaces", "Cover mirrors where possible", "Focus on feeling in body", "Workout outdoors", "Use affirmations"]'::jsonb 
WHERE scenario_id = 874;

-- Scenario 1139: Exam Pressure and Fear of Disappointing Others
UPDATE scenarios 
SET sc_action_steps = '["Create a realistic study plan to reduce overwhelm.", "Focus on learning", "Not perfection.", "Practice self-care through rest", "Food", "And faith.", "Surrender anxiety through prayer or breathing exercises."]'::jsonb 
WHERE scenario_id = 1139;

-- Scenario 864: Crash Dieting Before Events
UPDATE scenarios 
SET sc_action_steps = '["Plan months ahead", "Focus on whole foods", "Stay hydrated", "Exercise moderately", "Ignore crash-diet trends"]'::jsonb 
WHERE scenario_id = 864;

-- Scenario 872: Overemphasis on Weight Over Function
UPDATE scenarios 
SET sc_action_steps = '["Track lifts or stamina", "Increase healthy fuel", "Balance body composition", "Set skill-based goals", "Celebrate capability"]'::jsonb 
WHERE scenario_id = 872;

-- Scenario 866: Choosing Looks Over Health Cues
UPDATE scenarios 
SET sc_action_steps = '["Rest at first sign of injury", "Consult professionals", "Shift focus to recovery", "Adjust goals to ability", "Share recovery openly"]'::jsonb 
WHERE scenario_id = 866;

-- Scenario 867: Supplements Without True Need
UPDATE scenarios 
SET sc_action_steps = '["Check scientific basis", "Consult doctor", "Avoid over-supplementing", "Focus on proven basics", "Save money for essentials"]'::jsonb 
WHERE scenario_id = 867;

-- Scenario 868: Comparing Your Body to Edited Images
UPDATE scenarios 
SET sc_action_steps = '["Unfollow editing-heavy accounts", "Follow diverse bodies", "Limit scroll time", "Remind self of editing", "Value function over form"]'::jsonb 
WHERE scenario_id = 868;

-- Scenario 901: Jealousy of Friend's Academic Success
UPDATE scenarios 
SET sc_action_steps = '["Acknowledge your feelings without judgment", "Congratulate your friend sincerely", "Set goals for your own improvement without competing", "Cultivate joy in others'' success"]'::jsonb 
WHERE scenario_id = 901;

-- Scenario 916: Developing Underperforming Team Member
UPDATE scenarios 
SET sc_action_steps = '["Identify specific skills gaps and create a development plan", "Provide mentoring", "Training", "And regular feedback", "Set clear milestones and timelines for improvement", "Balance support for their growth with fairness to other team members"]'::jsonb 
WHERE scenario_id = 916;

-- Scenario 939: Child with Learning Differences
UPDATE scenarios 
SET sc_action_steps = '["Use learning tools suited to your style", "Celebrate your strengths (creativity", "Kindness", "Etc.)", "Talk openly with parents and teachers", "Remember that your path is divine too"]'::jsonb 
WHERE scenario_id = 939;

-- Scenario 941: Fear of Public Speaking in School
UPDATE scenarios 
SET sc_action_steps = '["Prepare well with notes and practice", "Focus on the message", "Not the audience", "Offer your speech as a sincere act", "Not a performance", "Accept nervousness without letting it control you"]'::jsonb 
WHERE scenario_id = 941;

-- Scenario 969: Cyberbullying and Identity Crisis
UPDATE scenarios 
SET sc_action_steps = '["Limit time on toxic platforms and report abusive behavior", "Spend time with friends and communities that affirm your worth", "Reflect daily on your deeper identity beyond appearances", "Seek support from parents", "Counselors", "Or spiritual mentors"]'::jsonb 
WHERE scenario_id = 969;

-- Scenario 1049: Job Opportunity Requiring Family Separation
UPDATE scenarios 
SET sc_action_steps = '["Evaluate all stakeholders'' needs objectively", "Not just your own desires", "Explore creative solutions that honor both career and family duties", "Consult with family members and seek their blessings for your decision", "Whatever you choose", "Do it with full commitment and regular support for family"]'::jsonb 
WHERE scenario_id = 1049;

-- Scenario 1065: Child Grieving Grandparent's Death
UPDATE scenarios 
SET sc_action_steps = '["Talk to parents or elders about what happened", "Create art", "Prayers", "Or memories to honor them", "Ask spiritual questions when you''re ready", "Feel your sadness without shame"]'::jsonb 
WHERE scenario_id = 1065;

-- Scenario 1123: Fear of Not Being Liked at School
UPDATE scenarios 
SET sc_action_steps = '["List your strengths and qualities you value in yourself", "Continue to treat others kindly", "Without expectation", "Focus on activities that make you feel confident and fulfilled", "Remember everyone''s journey is different", "And your worth is not based on popularity"]'::jsonb 
WHERE scenario_id = 1123;

-- Scenario 1235: Letting Go of Control Over Critical Project
UPDATE scenarios 
SET sc_action_steps = '["Clearly communicate expectations", "Deadlines", "And success criteria", "Provide necessary resources and access to information", "Schedule regular check-ins without micromanaging daily activities", "Focus on developing their capabilities rather than controlling their methods"]'::jsonb 
WHERE scenario_id = 1235;

COMMIT;

-- Updated 326 scenarios
