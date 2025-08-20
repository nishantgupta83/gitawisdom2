-- UPDATE STATEMENTS FOR 227 UNDERSCORE CATEGORIES
-- Consolidates into 10 main categories with enhanced tags
-- Execute in Supabase Dashboard → SQL Editor

BEGIN;

-- ===========================================
-- 1. CHRONIC_HEALTH_JOURNEY → HEALTH & WELLNESS
-- ===========================================

-- Living with chronic illness scenarios
UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['chronic-illness', 'pain-management', 'adaptation', 'purpose']
WHERE scenario_id = '549';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['chronic-illness', 'medical-diagnosis', 'fear', 'acceptance']
WHERE scenario_id = '550';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['chronic-illness', 'flare-ups', 'adaptability', 'planning']
WHERE scenario_id = '551';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['chronic-illness', 'recovery', 'patience', 'progress']
WHERE scenario_id = '552';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['chronic-illness', 'social-isolation', 'relationships', 'connection']
WHERE scenario_id = '553';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['chronic-illness', 'lifestyle-changes', 'discipline', 'longevity']
WHERE scenario_id = '554';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['chronic-illness', 'work-balance', 'treatment', 'balance']
WHERE scenario_id = '555';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['chronic-illness', 'public-awareness', 'patience', 'education']
WHERE scenario_id = '556';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['chronic-illness', 'emotional-impact', 'resilience', 'mindset']
WHERE scenario_id = '557';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['chronic-illness', 'healthcare-system', 'organization', 'advocacy']
WHERE scenario_id = '558';

-- ===========================================
-- 2. FOOD_CULTURE_AND_BODY_IMAGE → HEALTH & WELLNESS  
-- ===========================================

-- Diet confusion and nutrition
UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['nutrition', 'diet-confusion', 'health-advice', 'balance']
WHERE scenario_id IN ('779', '783', '792');

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['nutrition', 'peer-pressure', 'boundaries', 'diet-trends']
WHERE scenario_id IN ('780', '784', '793');

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['nutrition', 'professional-advice', 'conflicting-info', 'discernment']
WHERE scenario_id IN ('785', '794');

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['nutrition', 'diet-trends', 'stability', 'health-first']
WHERE scenario_id IN ('786', '795');

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['nutrition', 'family-conflict', 'food-choices', 'compromise']
WHERE scenario_id IN ('787', '796');

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['nutrition', 'workplace-challenges', 'social-pressure', 'confidence']
WHERE scenario_id = '797';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['nutrition', 'health-apps', 'information-overload', 'tools']
WHERE scenario_id = '798';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['nutrition', 'social-media', 'diet-debates', 'mental-detachment']
WHERE scenario_id = '799';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['nutrition', 'relationship-conflict', 'diet-differences', 'harmony']
WHERE scenario_id = '800';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['nutrition', 'marketing-influence', 'superfood-trends', 'critical-thinking']
WHERE scenario_id = '801';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['nutrition', 'cultural-heritage', 'modern-trends', 'tradition-balance']
WHERE scenario_id = '802';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['nutrition', 'fear-mongering', 'media-influence', 'discernment']
WHERE scenario_id = '803';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['nutrition', 'diet-challenges', 'moderation', 'mental-health']
WHERE scenario_id = '804';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['nutrition', 'celebrity-influence', 'marketing', 'independent-thinking']
WHERE scenario_id = '805';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['nutrition', 'ancestral-diet', 'tradition', 'modern-adaptation']
WHERE scenario_id = '806';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['nutrition', 'macro-tracking', 'information-overload', 'balance']
WHERE scenario_id = '807';

-- Body positivity scenarios
UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['body-image', 'body-positivity', 'shame', 'health-goals']
WHERE scenario_id IN ('781', '788', '808');

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['body-image', 'fitness-goals', 'criticism', 'wellness-focus']
WHERE scenario_id IN ('789', '809');

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['body-image', 'body-positivity', 'moderation', 'respectful-dialogue']
WHERE scenario_id = '812';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['body-image', 'social-comparison', 'confidence', 'self-worth']
WHERE scenario_id = '813';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['body-image', 'surgery-decisions', 'personal-choice', 'authenticity']
WHERE scenario_id = '814';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['body-image', 'fitness-support', 'community', 'health-goals']
WHERE scenario_id = '815';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['body-image', 'health-concerns', 'body-positivity-balance', 'listening']
WHERE scenario_id = '816';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['body-image', 'activism', 'priorities', 'values-alignment']
WHERE scenario_id = '817';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['body-image', 'community-toxicity', 'bullying', 'integrity']
WHERE scenario_id = '818';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['body-image', 'emotional-complexity', 'mixed-feelings', 'acceptance']
WHERE scenario_id = '819';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['body-image', 'media-representation', 'tokenism', 'authentic-inclusion']
WHERE scenario_id = '820';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['body-image', 'discipline', 'health-goals', 'authenticity']
WHERE scenario_id = '821';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['body-image', 'clothing-choices', 'style', 'personal-freedom']
WHERE scenario_id = '822';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['body-image', 'inclusion', 'equality', 'advocacy']
WHERE scenario_id = '823';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['body-image', 'weight-loss', 'relationships', 'understanding']
WHERE scenario_id = '824';

-- Orthorexia and restrictive eating
UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['eating-disorder', 'orthorexia', 'social-isolation', 'balance']
WHERE scenario_id IN ('782', '790', '810');

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['eating-disorder', 'orthorexia', 'meal-planning', 'time-management']
WHERE scenario_id IN ('791', '811');

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['eating-disorder', 'orthorexia', 'secrecy', 'relationships']
WHERE scenario_id = '839';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['eating-disorder', 'orthorexia', 'food-purity', 'moderation']
WHERE scenario_id = '825';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['eating-disorder', 'orthorexia', 'compulsive-checking', 'flexibility']
WHERE scenario_id = '826';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['eating-disorder', 'orthorexia', 'social-media-triggers', 'mental-health']
WHERE scenario_id = '827';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['eating-disorder', 'orthorexia', 'nutritional-deficiency', 'health-balance']
WHERE scenario_id = '828';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['eating-disorder', 'orthorexia', 'travel-anxiety', 'adaptability']
WHERE scenario_id = '829';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['eating-disorder', 'orthorexia', 'time-obsession', 'efficiency-vs-joy']
WHERE scenario_id = '830';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['eating-disorder', 'orthorexia', 'restaurant-anxiety', 'social-engagement']
WHERE scenario_id = '831';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['eating-disorder', 'orthorexia', 'food-judgment', 'compassion']
WHERE scenario_id = '832';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['eating-disorder', 'orthorexia', 'superiority', 'humility']
WHERE scenario_id = '833';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['eating-disorder', 'orthorexia', 'rigid-schedule', 'flexibility']
WHERE scenario_id = '834';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['eating-disorder', 'orthorexia', 'self-worth-diet', 'identity-beyond-food']
WHERE scenario_id = '835';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['eating-disorder', 'orthorexia', 'exercise-compensation', 'balance']
WHERE scenario_id = '836';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['eating-disorder', 'orthorexia', 'restriction-over-nutrition', 'health-wisdom']
WHERE scenario_id = '837';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['eating-disorder', 'orthorexia', 'cooking-joy', 'food-variety']
WHERE scenario_id = '838';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['eating-disorder', 'orthorexia', 'home-cooking-virtue', 'flexibility']
WHERE scenario_id = '840';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['eating-disorder', 'orthorexia', 'food-origins-anxiety', 'priorities']
WHERE scenario_id = '841';

-- Social eating anxiety
UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['social-anxiety', 'workplace-eating', 'self-consciousness', 'confidence']
WHERE scenario_id = '842';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['social-anxiety', 'stress-eating', 'mindful-eating', 'self-control']
WHERE scenario_id = '843';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['social-anxiety', 'public-eating', 'self-consciousness', 'confidence']
WHERE scenario_id = '844';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['social-anxiety', 'table-manners', 'etiquette-confidence', 'learning']
WHERE scenario_id = '845';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['social-anxiety', 'dietary-needs', 'relationships', 'openness']
WHERE scenario_id = '846';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['social-anxiety', 'food-choices', 'boundaries', 'confidence']
WHERE scenario_id = '847';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['social-anxiety', 'meal-conversation', 'social-engagement', 'presence']
WHERE scenario_id = '848';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['social-anxiety', 'mindful-eating', 'public-consciousness', 'self-acceptance']
WHERE scenario_id = '849';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['social-anxiety', 'dessert-pressure', 'boundaries', 'patience']
WHERE scenario_id = '850';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['social-anxiety', 'buffet-confidence', 'social-eating', 'courage']
WHERE scenario_id = '851';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['social-anxiety', 'meal-timing', 'connection', 'sharing']
WHERE scenario_id = '852';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['social-anxiety', 'alcohol-confidence', 'social-eating', 'health-choices']
WHERE scenario_id = '853';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['social-anxiety', 'portion-judgment', 'boundaries', 'self-acceptance']
WHERE scenario_id = '854';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['social-anxiety', 'new-people', 'courage', 'connection']
WHERE scenario_id = '855';

-- Cultural food issues
UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['cultural-food', 'heritage', 'education', 'pride']
WHERE scenario_id = '856';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['cultural-food', 'family-boundaries', 'dietary-needs', 'respect']
WHERE scenario_id = '857';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['cultural-food', 'workplace-inclusion', 'potluck', 'diversity']
WHERE scenario_id = '858';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['cultural-food', 'dating', 'cultural-blend', 'respect']
WHERE scenario_id = '859';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['cultural-food', 'religious-practice', 'ritual', 'respect']
WHERE scenario_id = '860';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['cultural-food', 'immigration', 'identity-loss', 'adaptation']
WHERE scenario_id = '862';

-- Fitness and appearance
UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['fitness', 'appearance-focus', 'health-balance', 'overtraining']
WHERE scenario_id = '863';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['fitness', 'crash-dieting', 'event-pressure', 'health-first']
WHERE scenario_id = '864';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['fitness', 'strength-training', 'body-myths', 'education']
WHERE scenario_id = '865';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['fitness', 'pain-ignorance', 'appearance-priority', 'health-wisdom']
WHERE scenario_id = '866';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['fitness', 'supplements', 'appearance-focus', 'health-needs']
WHERE scenario_id = '867';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['body-image', 'media-comparison', 'edited-images', 'reality-check']
WHERE scenario_id = '868';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['nutrition', 'calorie-tracking', 'obsession', 'balance']
WHERE scenario_id = '870';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['fitness', 'medical-avoidance', 'training-priority', 'health-first']
WHERE scenario_id = '871';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['fitness', 'weight-focus', 'function-over-form', 'performance']
WHERE scenario_id = '872';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['nutrition', 'food-enjoyment', 'restriction', 'joy-in-eating']
WHERE scenario_id = '873';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['body-image', 'gym-mirrors', 'body-dysmorphia', 'self-compassion']
WHERE scenario_id = '874';

UPDATE scenario_translations 
SET category = 'Health & Wellness', tags = ARRAY['body-image', 'plastic-surgery', 'social-pressure', 'self-worth']
WHERE scenario_id = '875';

-- ===========================================
-- 3. NAVIGATING_UNCERTAINTY_CHANGE → LIFE TRANSITIONS
-- ===========================================

UPDATE scenario_translations 
SET category = 'Life Transitions', tags = ARRAY['career-change', 'job-loss', 'uncertainty', 'resilience']
WHERE scenario_id = '578';

UPDATE scenario_translations 
SET category = 'Life Transitions', tags = ARRAY['relocation', 'cultural-adaptation', 'learning', 'patience']
WHERE scenario_id = '579';

UPDATE scenario_translations 
SET category = 'Life Transitions', tags = ARRAY['career-uncertainty', 'company-merger', 'planning', 'focus']
WHERE scenario_id = '580';

UPDATE scenario_translations 
SET category = 'Life Transitions', tags = ARRAY['health-crisis', 'life-planning', 'adaptation', 'priorities']
WHERE scenario_id = '581';

UPDATE scenario_translations 
SET category = 'Life Transitions', tags = ARRAY['marriage-transition', 'relationship-change', 'adaptation', 'growth']
WHERE scenario_id = '582';

UPDATE scenario_translations 
SET category = 'Life Transitions', tags = ARRAY['industry-disruption', 'skill-adaptation', 'fearlessness', 'career-pivot']
WHERE scenario_id = '583';

UPDATE scenario_translations 
SET category = 'Life Transitions', tags = ARRAY['leadership-transition', 'unexpected-role', 'learning', 'growth']
WHERE scenario_id = '584';

UPDATE scenario_translations 
SET category = 'Life Transitions', tags = ARRAY['natural-disaster', 'crisis-management', 'resilience', 'adaptation']
WHERE scenario_id = '585';

UPDATE scenario_translations 
SET category = 'Life Transitions', tags = ARRAY['life-stage-shift', 'identity-change', 'purpose', 'self-discovery']
WHERE scenario_id = '586';

UPDATE scenario_translations 
SET category = 'Life Transitions', tags = ARRAY['company-closure', 'career-ending', 'resilience', 'new-beginnings']
WHERE scenario_id = '587';

-- ===========================================
-- 4. PUBLIC_REPUTATION_CANCEL_CULTURE → SOCIAL & COMMUNITY
-- ===========================================

UPDATE scenario_translations 
SET category = 'Social & Community', tags = ARRAY['reputation-management', 'social-media-backlash', 'accountability', 'humility']
WHERE scenario_id = '530';

UPDATE scenario_translations 
SET category = 'Social & Community', tags = ARRAY['reputation-management', 'false-allegations', 'truth', 'integrity']
WHERE scenario_id = '531';

UPDATE scenario_translations 
SET category = 'Social & Community', tags = ARRAY['reputation-management', 'context-loss', 'communication', 'misunderstanding']
WHERE scenario_id = '532';

UPDATE scenario_translations 
SET category = 'Social & Community', tags = ARRAY['reputation-management', 'workplace-ostracism', 'relationships', 'loyalty']
WHERE scenario_id = '533';

UPDATE scenario_translations 
SET category = 'Social & Community', tags = ARRAY['reputation-management', 'minority-opinion', 'courage', 'respect']
WHERE scenario_id = '534';

UPDATE scenario_translations 
SET category = 'Social & Community', tags = ARRAY['reputation-management', 'public-criticism', 'conflict', 'humility']
WHERE scenario_id = '535';

UPDATE scenario_translations 
SET category = 'Social & Community', tags = ARRAY['reputation-management', 'mistake-consequences', 'growth', 'perseverance']
WHERE scenario_id = '536';

UPDATE scenario_translations 
SET category = 'Social & Community', tags = ARRAY['reputation-management', 'friendship-loss', 'loyalty', 'authenticity']
WHERE scenario_id = '537';

UPDATE scenario_translations 
SET category = 'Social & Community', tags = ARRAY['reputation-management', 'media-criticism', 'public-image', 'patience']
WHERE scenario_id = '538';

UPDATE scenario_translations 
SET category = 'Social & Community', tags = ARRAY['reputation-management', 'speech-fear', 'cancel-culture', 'courage']
WHERE scenario_id = '539';

-- ===========================================
-- 5. QUEER_IDENTITY → PERSONAL GROWTH
-- ===========================================

-- Coming out scenarios
UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['lgbtq-identity', 'coming-out', 'workplace', 'courage']
WHERE scenario_id = '688';

UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['lgbtq-identity', 'coming-out', 'friendship', 'authenticity']
WHERE scenario_id = '689';

UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['lgbtq-identity', 'privacy', 'boundaries', 'safety']
WHERE scenario_id = '690';

UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['lgbtq-identity', 'online-offline-identity', 'authenticity', 'consistency']
WHERE scenario_id = '691';

UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['lgbtq-identity', 'accidental-outing', 'social-media', 'family-impact']
WHERE scenario_id = '692';

UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['lgbtq-identity', 'workplace-safety', 'conservative-environment', 'strategy']
WHERE scenario_id = '693';

UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['lgbtq-identity', 'privacy-choice', 'safety', 'self-acceptance']
WHERE scenario_id = '694';

UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['lgbtq-identity', 'group-coming-out', 'event-timing', 'courage']
WHERE scenario_id = '696';

UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['lgbtq-identity', 'boundaries', 'readiness', 'social-pressure']
WHERE scenario_id = '698';

UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['lgbtq-identity', 'labels', 'self-discovery', 'language']
WHERE scenario_id = '699';

-- Family relationships
UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['lgbtq-identity', 'family-acceptance', 'patience', 'parent-relationship']
WHERE scenario_id = '700';

UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['lgbtq-identity', 'family-rejection', 'boundaries', 'sibling-relationships']
WHERE scenario_id = '701';

UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['lgbtq-identity', 'family-ultimatum', 'housing', 'authenticity']
WHERE scenario_id = '702';

UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['lgbtq-identity', 'family-religion', 'faith-conflict', 'debate']
WHERE scenario_id = '703';

UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['lgbtq-identity', 'family-fear', 'community-judgment', 'acceptance']
WHERE scenario_id = '704';

UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['lgbtq-identity', 'family-events', 'partner-exclusion', 'boundaries']
WHERE scenario_id = '705';

UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['lgbtq-identity', 'conditional-acceptance', 'family-dynamics', 'authenticity']
WHERE scenario_id = '707';

UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['lgbtq-identity', 'family-support', 'private-vs-public', 'advocacy']
WHERE scenario_id = '708';

UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['lgbtq-identity', 'inheritance-threats', 'family-pressure', 'integrity']
WHERE scenario_id = '709';

-- Faith and spirituality
UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['lgbtq-identity', 'faith-community', 'inclusion', 'spiritual-home']
WHERE scenario_id = '710';

UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['lgbtq-identity', 'faith-interpretation', 'religious-learning', 'identity-integration']
WHERE scenario_id = '711';

UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['lgbtq-identity', 'interfaith-relationship', 'respect', 'compromise']
WHERE scenario_id = '712';

UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['lgbtq-identity', 'religious-allyship', 'leadership-support', 'faith-integration']
WHERE scenario_id IN ('713', '732');

UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['lgbtq-identity', 'faith-inclusion', 'study-group', 'community-building']
WHERE scenario_id IN ('714', '733');

UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['lgbtq-identity', 'faith-pride-balance', 'ritual-integration', 'identity-harmony']
WHERE scenario_id IN ('715', '734');

UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['lgbtq-identity', 'faith-dialogue', 'respectful-challenge', 'courage']
WHERE scenario_id IN ('716', '735');

UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['lgbtq-identity', 'interfaith-events', 'inclusion', 'community-bridge']
WHERE scenario_id IN ('717', '736');

-- Chosen family
UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['lgbtq-identity', 'chosen-family', 'support-network', 'relationships']
WHERE scenario_id IN ('718', '737');

UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['lgbtq-identity', 'chosen-family', 'parenting', 'nontraditional-family']
WHERE scenario_id IN ('720', '738');

UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['lgbtq-identity', 'chosen-family', 'holidays', 'tradition-creation']
WHERE scenario_id IN ('721', '740');

UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['lgbtq-identity', 'chosen-family', 'caregiving', 'illness-support']
WHERE scenario_id IN ('722', '742');

UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['lgbtq-identity', 'chosen-family', 'housing', 'safety']
WHERE scenario_id IN ('723', '743');

-- Community and identity
UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['lgbtq-identity', 'sports-community', 'inclusion', 'belonging']
WHERE scenario_id IN ('724', '744');

UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['lgbtq-identity', 'microaggressions', 'community-respect', 'advocacy']
WHERE scenario_id IN ('725', '745');

UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['lgbtq-identity', 'faith-inclusion', 'worship-creation', 'spiritual-community']
WHERE scenario_id IN ('726', '746');

UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['lgbtq-identity', 'gender-expression', 'safety', 'exploration']
WHERE scenario_id IN ('727', '747');

UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['lgbtq-identity', 'orientation-affirmation', 'acceptance', 'self-growth']
WHERE scenario_id IN ('728', '748');

UPDATE scenario_translations 
SET category = 'Personal Growth', tags = ARRAY['lgbtq-identity', 'stereotype-rejection', 'media-representation', 'authenticity']
WHERE scenario_id IN ('729', '749');

-- ===========================================
-- 6. STARTUP_FOUNDER_BURNOUT → WORK & CAREER
-- ===========================================

UPDATE scenario_translations 
SET category = 'Work & Career', tags = ARRAY['entrepreneurship', 'startup-burnout', 'work-balance', 'self-care']
WHERE scenario_id = '568';

UPDATE scenario_translations 
SET category = 'Work & Career', tags = ARRAY['entrepreneurship', 'relationship-neglect', 'isolation', 'connection']
WHERE scenario_id = '569';

UPDATE scenario_translations 
SET category = 'Work & Career', tags = ARRAY['entrepreneurship', 'mental-detachment', 'work-obsession', 'focus-balance']
WHERE scenario_id = '570';

UPDATE scenario_translations 
SET category = 'Work & Career', tags = ARRAY['entrepreneurship', 'burnout-prevention', 'awareness', 'early-signs']
WHERE scenario_id = '571';

UPDATE scenario_translations 
SET category = 'Work & Career', tags = ARRAY['entrepreneurship', 'investor-pressure', 'boundaries', 'sustainable-growth']
WHERE scenario_id = '572';

UPDATE scenario_translations 
SET category = 'Work & Career', tags = ARRAY['entrepreneurship', 'delegation', 'leadership', 'trust-building']
WHERE scenario_id = '573';

UPDATE scenario_translations 
SET category = 'Work & Career', tags = ARRAY['entrepreneurship', 'health-sacrifice', 'deadline-pressure', 'balance']
WHERE scenario_id = '574';

UPDATE scenario_translations 
SET category = 'Work & Career', tags = ARRAY['entrepreneurship', 'success-celebration', 'gratitude', 'progress-joy']
WHERE scenario_id = '575';

UPDATE scenario_translations 
SET category = 'Work & Career', tags = ARRAY['entrepreneurship', 'creative-fatigue', 'vision-loss', 'renewal']
WHERE scenario_id = '576';

UPDATE scenario_translations 
SET category = 'Work & Career', tags = ARRAY['entrepreneurship', 'leadership-isolation', 'support', 'connection']
WHERE scenario_id = '577';

-- ===========================================
-- 7. SUSTAINABLE_MINIMALISM → MODERN LIVING
-- ===========================================

-- Sustainability pressures
UPDATE scenario_translations 
SET category = 'Modern Living', tags = ARRAY['sustainability', 'eco-guilt', 'plastic-use', 'progress-over-perfection']
WHERE scenario_id = '751';

UPDATE scenario_translations 
SET category = 'Modern Living', tags = ARRAY['sustainability', 'peer-pressure', 'solar-shaming', 'boundaries']
WHERE scenario_id = '752';

UPDATE scenario_translations 
SET category = 'Modern Living', tags = ARRAY['sustainability', 'zero-waste', 'overwhelm', 'habit-balance']
WHERE scenario_id = '753';

UPDATE scenario_translations 
SET category = 'Modern Living', tags = ARRAY['sustainability', 'influencer-comparison', 'eco-lifestyle', 'realism']
WHERE scenario_id = '754';

UPDATE scenario_translations 
SET category = 'Modern Living', tags = ARRAY['sustainability', 'fashion-guilt', 'consumption', 'authenticity']
WHERE scenario_id = '755';

UPDATE scenario_translations 
SET category = 'Modern Living', tags = ARRAY['sustainability', 'fomo-technology', 'eco-trends', 'discernment']
WHERE scenario_id = '762';

UPDATE scenario_translations 
SET category = 'Modern Living', tags = ARRAY['sustainability', 'shopping-comparison', 'zero-waste-stores', 'eco-guilt']
WHERE scenario_id = '763';

UPDATE scenario_translations 
SET category = 'Modern Living', tags = ARRAY['sustainability', 'off-grid-pressure', 'lifestyle-choice', 'boundaries']
WHERE scenario_id = '765';

UPDATE scenario_translations 
SET category = 'Modern Living', tags = ARRAY['sustainability', 'transport-judgment', 'electric-car', 'planning']
WHERE scenario_id = '766';

UPDATE scenario_translations 
SET category = 'Modern Living', tags = ARRAY['sustainability', 'diy-expectations', 'burnout', 'realistic-goals']
WHERE scenario_id = '767';

UPDATE scenario_translations 
SET category = 'Modern Living', tags = ARRAY['sustainability', 'technology-criticism', 'balance', 'modern-life']
WHERE scenario_id = '768';

UPDATE scenario_translations 
SET category = 'Modern Living', tags = ARRAY['sustainability', 'activism-overwhelm', 'balance', 'rest']
WHERE scenario_id = '769';

UPDATE scenario_translations 
SET category = 'Modern Living', tags = ARRAY['sustainability', 'product-choice-overload', 'decision-clarity', 'simplicity']
WHERE scenario_id = '770';

UPDATE scenario_translations 
SET category = 'Modern Living', tags = ARRAY['sustainability', 'ethics-affordability', 'budget-balance', 'values']
WHERE scenario_id = '771';

UPDATE scenario_translations 
SET category = 'Modern Living', tags = ARRAY['sustainability', 'purchase-analysis', 'perfectionism', 'focus']
WHERE scenario_id = '772';

UPDATE scenario_translations 
SET category = 'Modern Living', tags = ARRAY['sustainability', 'eco-label-confusion', 'green-washing', 'knowledge']
WHERE scenario_id = '773';

UPDATE scenario_translations 
SET category = 'Modern Living', tags = ARRAY['sustainability', 'food-desert', 'access-limitations', 'creativity']
WHERE scenario_id = '774';

UPDATE scenario_translations 
SET category = 'Modern Living', tags = ARRAY['sustainability', 'low-income', 'eco-accessibility', 'inclusive-habits']
WHERE scenario_id = '775';

UPDATE scenario_translations 
SET category = 'Modern Living', tags = ARRAY['sustainability', 'compost-infrastructure', 'system-limitations', 'adaptability']
WHERE scenario_id = '776';

UPDATE scenario_translations 
SET category = 'Modern Living', tags = ARRAY['sustainability', 'cultural-norms', 'second-hand-stigma', 'perception']
WHERE scenario_id = '777';

UPDATE scenario_translations 
SET category = 'Modern Living', tags = ARRAY['sustainability', 'bulk-buying', 'space-limitations', 'balance']
WHERE scenario_id = '778';

-- Minimalism challenges
UPDATE scenario_translations 
SET category = 'Modern Living', tags = ARRAY['minimalism', 'decision-paralysis', 'burnout', 'needs-balance']
WHERE scenario_id = '756';

UPDATE scenario_translations 
SET category = 'Modern Living', tags = ARRAY['minimalism', 'declutter-fatigue', 'burnout', 'rest']
WHERE scenario_id = '757';

UPDATE scenario_translations 
SET category = 'Modern Living', tags = ARRAY['minimalism', 'sentimental-regret', 'detachment', 'memory-keeping']
WHERE scenario_id = '758';

UPDATE scenario_translations 
SET category = 'Modern Living', tags = ARRAY['minimalism', 'comfort-neglect', 'aesthetic-focus', 'balance']
WHERE scenario_id = '759';

UPDATE scenario_translations 
SET category = 'Modern Living', tags = ARRAY['minimalism', 'maintenance-time', 'system-planning', 'capacity']
WHERE scenario_id = '760';

UPDATE scenario_translations 
SET category = 'Modern Living', tags = ARRAY['minimalism', 'travel-envy', 'fomo', 'comparison']
WHERE scenario_id = '761';

UPDATE scenario_translations 
SET category = 'Modern Living', tags = ARRAY['minimalism', 'housing-contentment', 'space-comparison', 'gratitude']
WHERE scenario_id = '764';

COMMIT;

-- VERIFICATION
SELECT 'CONSOLIDATION COMPLETE - FINAL CATEGORY COUNT:' as info;
SELECT category, COUNT(*) as count 
FROM scenario_translations 
GROUP BY category 
ORDER BY count DESC;