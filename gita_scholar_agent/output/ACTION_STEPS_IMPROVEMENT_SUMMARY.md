# Action Steps Improvement - Implementation Summary

**Date:** 2025-11-13
**Status:** Ready for Implementation
**Impact:** 100+ scenarios with repetitive action steps

---

## Problem Identified

**Current Pattern (Repetitive):**
```
1. Take time to notice superiority thoughts, ensuring you understand the full context and implications
2. Take time to reframe as personal choice, ensuring you understand the full context and implications
3. Take time to avoid unsolicited advice, ensuring you understand the full context and implications
4. Take time to ask others about favourites, ensuring you understand the full context and implications
5. Take time to celebrate diversity, ensuring you understand the full context and implications
```

**Issues:**
- Generic "Take time to..." prefix on every step
- Repetitive "ensuring you understand the full context and implications" suffix
- Reduces actionability and specificity
- Makes steps feel templated rather than tailored to the scenario

---

## Deliverables Created

### 1. High-Quality Action Steps for Top 20 Scenarios
**File:** `/gita_scholar_agent/output/top20_improved_action_steps.json`

**Contents:**
- 20 scenarios identified with worst repetitive patterns
- Each scenario has 5 completely rewritten, specific, actionable steps
- Steps are concrete, contextually relevant, and immediately actionable
- Average step length: 20-40 words (1-2 sentences)

**Example Improvement:**

**Before (Scenario 831):**
```
1. Take time to research menu ahead, ensuring you understand the full context...
2. Take time to call venue, ensuring you understand the full context...
3. Take time to suggest restaurant choice, ensuring you understand the full context...
```

**After:**
```
1. Check restaurant menus online before accepting invitations to identify safe options that align with your dietary needs.
2. Call the restaurant during off-peak hours to ask about ingredient lists, preparation methods, or possible accommodations.
3. When friends plan outings, volunteer to suggest a restaurant you've researched, framing it as your treat or enthusiasm to share a new spot.
```

**Scenarios Covered:**
- 831: Eating Out Causes Anxiety and Isolation
- 836: Over-Exercising to Compensate for Food Choices
- 832: Judging Others' Food Choices
- 829: Travel Anxiety Around Food
- 858: Workplace Potlucks Excluding Your Cuisine
- 874: Body Dysmorphia Triggers from Gym Mirrors
- 1139: Exam Pressure and Fear of Disappointing Others
- 676: Depression from Chronic Misunderstanding
- 682: Health Impact of Chronic Stress
- 805: Celebrity Endorsements Swaying Choices
- 864: Crash Dieting Before Events
- 867: Supplements Without True Need
- 854: Judged for Portion Sizes
- 833: Feeling Superior Over "Clean Eating"
- 631: Leading a Meeting for the First Time
- 821: Dismissed as "Not Body Positive Enough"
- 870: Obsessive Calorie Tracking Undermines Health
- 820: Being Tokenised in Media Campaigns
- 863: Overtraining for Aesthetic Goals
- 441: Layoff Rumors Spreading in Office

---

### 2. AI Prompt Template for Future Generation
**File:** `/gita_scholar_agent/output/AI_PROMPT_TEMPLATE_ACTION_STEPS.md`

**Contents:**
- Master prompt template with placeholders for scenario context
- Quality requirements and anti-patterns to avoid
- Scenario type-specific guidance (workplace, health, relationships, etc.)
- Testing checklist for validating generated steps
- 50+ alternative action verbs to ensure variety
- Before/after examples showing poor vs. improved steps

**Key Features:**
- Prevents "Take time to..." and similar generic prefixes
- Ensures 1-2 sentence length (20-40 words)
- Requires specific timeframes, quantities, or measurable criteria
- Enforces logical progression (assess → plan → act → review)
- Contextually unique to each scenario

**Usage:**
When generating new scenarios or improving existing ones, copy the master prompt template, fill in the scenario details, and use with any AI model (GPT-4, Claude, etc.) to generate high-quality action steps.

---

### 3. SQL Migration for Bulk Cleanup
**File:** `/supabase/migrations/013_fix_repetitive_action_steps.sql`

**Purpose:**
Automatically clean up existing database by removing repetitive prefixes and suffixes from all scenarios.

**What It Does:**

**Step 1: Bulk Pattern Removal**
- Removes "Take time to " prefix (case-insensitive)
- Removes ", ensuring you understand the full context and implications" suffix
- Capitalizes first letter after prefix removal
- Processes all 1,226 scenarios automatically

**Step 2: Fix Specific Malformed Scenarios**
- Scenario 1139: Has fragmented steps like "food" and "not perfection."
- Provides complete rewritten steps for known quality issues

**Step 3: Verification Queries**
- Count affected scenarios
- Sample random scenarios to verify cleanup
- Check for remaining repetitive patterns (should return 0)

**Step 4: Quality Validation**
- Identify very short steps (potential fragments)
- Find incomplete steps (ending with "etc.", "...", etc.)

**Safety Features:**
- Includes rollback plan
- Recommends creating backup table before execution
- Preserves original data structure (JSON arrays)
- Only affects rows with identified patterns

---

## Implementation Plan

### Phase 1: Immediate Cleanup (Today)

1. **Backup Database**
   ```sql
   CREATE TABLE scenarios_backup_20251113 AS SELECT * FROM public.scenarios;
   ```

2. **Run SQL Migration**
   ```bash
   # If using Supabase CLI
   supabase db push

   # Or manually execute
   psql -h [host] -U [user] -d [database] -f supabase/migrations/013_fix_repetitive_action_steps.sql
   ```

3. **Verify Results**
   - Check verification queries in migration file
   - Run: `python3 gita_scholar_agent/scenario_quality_checker.py`
   - Confirm 0 scenarios with "Take time to..." pattern

**Expected Impact:**
- 100+ scenarios automatically cleaned
- Prefixes and suffixes removed
- First letter capitalization preserved
- Scenario 1139 completely fixed

---

### Phase 2: High-Priority Manual Updates (This Week)

1. **Update Top 20 Scenarios**
   - Use data from `top20_improved_action_steps.json`
   - Create individual UPDATE statements for each scenario
   - Example:
     ```sql
     UPDATE public.scenarios
     SET sc_action_steps = jsonb_build_array(
       'Check restaurant menus online before accepting invitations...',
       'Call the restaurant during off-peak hours...',
       'When friends plan outings, volunteer to suggest...',
       'Eat a small, satisfying snack before going out...',
       'Choose one menu item outside your usual comfort zone...'
     )
     WHERE scenario_id = 831;
     ```

2. **Test in App**
   - Rebuild Flutter app with updated data
   - Verify action steps display correctly
   - Check for text overflow or formatting issues
   - Confirm improved user experience

**Expected Impact:**
- Top 20 most problematic scenarios completely rewritten
- User-facing quality significantly improved
- More specific, actionable guidance

---

### Phase 3: Systematic Improvement (Next 2 Weeks)

1. **Identify Next Priority Scenarios**
   - Run quality checker: `python3 gita_scholar_agent/scenario_quality_checker.py`
   - Sort by issue count and severity
   - Focus on scenarios with fragments, very short steps, or incomplete text

2. **Use AI Template for Batch Generation**
   - Load AI prompt template
   - Process 10-20 scenarios per batch
   - Human review for quality and cultural appropriateness
   - Apply updates to database

3. **Quality Metrics Tracking**
   - Before: ~15 scenarios with quality issues (from report)
   - Target: <5 scenarios with quality issues
   - Monitor: Average step length, specificity, actionability

**Expected Impact:**
- All 1,226 scenarios meet quality standards
- Consistent user experience across entire app
- Reduced support requests about vague guidance

---

## Testing Checklist

### Database Level
- [ ] Backup created successfully
- [ ] Migration executed without errors
- [ ] Verification queries show 0 remaining patterns
- [ ] No scenarios lost or corrupted
- [ ] Action step counts preserved (still 5 per scenario)

### Application Level
- [ ] Flutter app builds successfully
- [ ] Scenarios load correctly in UI
- [ ] Action steps display without text overflow
- [ ] No null or empty action step arrays
- [ ] Dark mode and light mode both render properly

### Content Quality
- [ ] Steps are specific and actionable
- [ ] No generic prefixes or suffixes
- [ ] Contextually relevant to each scenario
- [ ] Logical progression through steps
- [ ] Appropriate length (not too short or too long)

### User Experience
- [ ] Guidance feels personalized, not templated
- [ ] Users can immediately understand what to do
- [ ] Steps are realistic and achievable
- [ ] Cultural sensitivity maintained
- [ ] Accessibility considerations met

---

## Rollback Procedure

If issues are discovered after migration:

```sql
-- Restore from backup
UPDATE public.scenarios
SET sc_action_steps = scenarios_backup_20251113.sc_action_steps
FROM scenarios_backup_20251113
WHERE scenarios.scenario_id = scenarios_backup_20251113.scenario_id;

-- Verify restoration
SELECT COUNT(*) FROM public.scenarios
WHERE sc_action_steps IS NOT NULL;

-- Drop backup table (only after confirming rollback successful)
DROP TABLE scenarios_backup_20251113;
```

---

## Metrics to Track

### Before Migration
- Scenarios with "Take time to..." prefix: **~100+**
- Scenarios with repetitive suffix: **~100+**
- Scenarios with quality issues: **15** (from quality report)
- Average action step specificity: **Low** (generic)

### After Full Implementation (Target)
- Scenarios with "Take time to..." prefix: **0**
- Scenarios with repetitive suffix: **0**
- Scenarios with quality issues: **<5**
- Average action step specificity: **High** (specific, actionable)

### User Impact Metrics (Monitor in Analytics)
- Time spent reading action steps
- Journal entries referencing specific action steps
- User satisfaction ratings for scenarios
- Scenario bookmarking/saving frequency

---

## Support Resources

**Documentation:**
- Quality Report: `/gita_scholar_agent/output/scenario_quality_report.txt`
- Top 20 JSON: `/gita_scholar_agent/output/top20_improved_action_steps.json`
- AI Template: `/gita_scholar_agent/output/AI_PROMPT_TEMPLATE_ACTION_STEPS.md`
- SQL Migration: `/supabase/migrations/013_fix_repetitive_action_steps.sql`

**Scripts:**
- Quality Checker: `python3 gita_scholar_agent/scenario_quality_checker.py`
- Query Tool: `python3 gita_scholar_agent/query_scenario.py`
- Top 20 Query: `python3 gita_scholar_agent/query_top20_scenarios.py`

**Contact:**
For questions or issues during implementation, refer to:
- `SUPABASE_DATABASE_DOCUMENTATION.md` for schema details
- `TESTING_GUIDE.md` for testing procedures
- `CLAUDE.md` for project context

---

## Next Steps After Implementation

1. **Content Expansion**
   - Use AI template to generate action steps for NEW scenarios
   - Ensure quality from the start (don't create new repetitive patterns)

2. **Localization Consideration**
   - Updated action steps will need translation for 15 supported languages
   - Coordinate with translation team to maintain quality across languages

3. **User Feedback Loop**
   - Monitor in-app ratings for scenarios
   - Collect user feedback on action step quality
   - Iterate based on real-world usage patterns

4. **Continuous Quality Monitoring**
   - Run quality checker monthly
   - Address new issues proactively
   - Update AI template based on learnings

---

**Status:** ✅ All deliverables complete and ready for implementation

**Approval Required:**
- [ ] Database backup plan approved
- [ ] Migration script reviewed
- [ ] Content quality validated
- [ ] Testing plan confirmed
- [ ] Rollback procedure understood

**Timeline:**
- Phase 1 (Immediate): 1 hour
- Phase 2 (High-Priority): 3-5 hours
- Phase 3 (Systematic): 10-15 hours over 2 weeks

---

**Last Updated:** 2025-11-13
**Created By:** GitaWisdom Content Quality Initiative
