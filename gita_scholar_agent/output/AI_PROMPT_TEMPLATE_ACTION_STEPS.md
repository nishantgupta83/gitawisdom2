# AI Prompt Template for Generating High-Quality Action Steps

## Purpose
This template ensures consistent, specific, and actionable guidance for scenario action steps, avoiding generic or repetitive language patterns.

---

## Master Prompt Template

```
You are an expert advisor creating actionable guidance for real-world dilemmas based on Bhagavad Gita wisdom.

**Scenario Context:**
- **Title:** {SCENARIO_TITLE}
- **Description:** {SCENARIO_DESCRIPTION}
- **Category:** {CATEGORY}
- **Heart Response:** {HEART_RESPONSE}
- **Duty Response:** {DUTY_RESPONSE}
- **Gita Wisdom:** {GITA_WISDOM}

**Your Task:**
Generate 5 specific, actionable steps that help someone navigate this scenario. Each step should be:

1. **Concrete and Specific**: Include clear actions, timeframes, or measurable criteria
2. **Immediately Actionable**: Steps someone can start today without requiring extensive preparation
3. **Contextually Relevant**: Tailored to the unique aspects of this scenario, not generic advice
4. **Progressively Structured**: Steps should flow logically (e.g., assess → plan → act → review)
5. **Varied in Language**: Avoid repetitive sentence structures and phrases

**Quality Requirements:**
✅ Each step should be 1-2 sentences (20-40 words)
✅ Use varied action verbs (identify, create, schedule, track, practice, etc.)
✅ Include specific examples, timeframes, or quantities where relevant
✅ Avoid prefixes like "Take time to..." or "Consider..."
✅ Avoid suffixes like "...ensuring you understand the full context"
✅ NO generic filler language or motivational platitudes

**Anti-Patterns to Avoid:**
❌ "Take time to reflect on..."
❌ "Consider how this might..."
❌ "Think about ways to..."
❌ "...ensuring you understand the full context and implications"
❌ "Remember that..."
❌ "Be mindful of..."

**Output Format:**
Return ONLY a JSON array of 5 action steps:

[
  "Step 1 text here",
  "Step 2 text here",
  "Step 3 text here",
  "Step 4 text here",
  "Step 5 text here"
]
```

---

## Example Usage

### Input Variables:
```json
{
  "SCENARIO_TITLE": "Eating Out Causes Anxiety and Isolation",
  "SCENARIO_DESCRIPTION": "You feel anxious about eating out with friends because of dietary restrictions or food fears, leading to social isolation.",
  "CATEGORY": "Health and Wellness",
  "HEART_RESPONSE": "My anxiety tells me to avoid restaurants entirely to stay safe and in control.",
  "DUTY_RESPONSE": "I should maintain social connections and not let food fears control my relationships.",
  "GITA_WISDOM": "Krishna teaches that balance and gradual progress are key. We should act according to our nature while gently expanding our comfort zones."
}
```

### Expected Output:
```json
[
  "Check restaurant menus online before accepting invitations to identify safe options that align with your dietary needs.",
  "Call the restaurant during off-peak hours to ask about ingredient lists, preparation methods, or possible accommodations.",
  "When friends plan outings, volunteer to suggest a restaurant you've researched, framing it as your treat or enthusiasm to share a new spot.",
  "Eat a small, satisfying snack before going out so hunger doesn't pressure you into uncomfortable choices.",
  "Choose one menu item outside your usual comfort zone each month to gradually build confidence and reduce food-related anxiety."
]
```

---

## Quality Checklist for Generated Steps

Before accepting any generated action steps, verify:

- [ ] **No repetitive prefixes** ("Take time to...", "Consider...", "Think about...")
- [ ] **No repetitive suffixes** ("...ensuring you understand the full context")
- [ ] **Specific actions** (not vague suggestions like "reflect on your feelings")
- [ ] **Measurable or observable** (includes timeframes, quantities, or clear criteria)
- [ ] **Contextually unique** (couldn't be copy-pasted to unrelated scenarios)
- [ ] **Varied structure** (not all steps start with the same pattern)
- [ ] **Complete sentences** (no fragments or incomplete thoughts)
- [ ] **Actionable immediately** (not dependent on future conditions or circumstances)
- [ ] **Logical progression** (steps build on each other when appropriate)
- [ ] **Appropriate length** (20-40 words per step, 1-2 sentences)

---

## Common Action Verb Alternatives

To ensure variety, rotate through these action categories:

### Assessment/Awareness
- Identify, Track, Monitor, Observe, Document, Recognize, List, Assess, Evaluate

### Planning/Preparation
- Create, Design, Develop, Draft, Outline, Map, Schedule, Plan, Set, Build

### Execution/Action
- Practice, Implement, Execute, Establish, Initiate, Start, Begin, Launch, Apply

### Communication
- Ask, Share, Communicate, Express, Discuss, Request, Clarify, Explain, State

### Boundaries/Limits
- Set, Limit, Restrict, Decline, Refuse, Avoid, Eliminate, Reduce, Minimize

### Learning/Growth
- Learn, Study, Research, Explore, Experiment, Test, Try, Discover, Investigate

### Review/Adjustment
- Review, Reflect, Adjust, Refine, Revise, Update, Modify, Improve, Optimize

---

## Scenario Type-Specific Guidance

### Workplace Scenarios
- Include specific communication templates or meeting structures
- Reference professional tools (email, calendar, project management)
- Mention timeframes aligned with work cycles (weekly, quarterly)
- Address both immediate and long-term career implications

### Health/Wellness Scenarios
- Provide measurable health metrics (sleep hours, water intake, exercise frequency)
- Reference professional resources (doctors, trainers, therapists)
- Balance immediate relief tactics with sustainable long-term habits
- Address both physical and mental health dimensions

### Relationship Scenarios
- Include specific conversation starters or boundary-setting language
- Address both your actions and how to respond to others
- Consider cultural, family, or community contexts
- Balance self-care with maintaining important relationships

### Financial Scenarios
- Include specific amounts, timeframes, or percentages where relevant
- Reference tools (budgeting apps, savings accounts, investment platforms)
- Address immediate actions and long-term planning
- Balance practical steps with emotional/psychological aspects

### Spiritual/Ethical Scenarios
- Ground abstract concepts in concrete practices (meditation time, journaling prompts)
- Connect daily actions to broader values or principles
- Include community or support system elements
- Balance personal practice with social responsibility

---

## Testing Your Generated Steps

After generating action steps, ask:

1. **Could I start this today?** If not, the step is too vague or dependent.
2. **Would this work for a different scenario?** If yes, it's too generic.
3. **Can I measure or observe completion?** If no, add specific criteria.
4. **Does it respect the scenario's context?** Ensure cultural, social, and practical appropriateness.
5. **Would I actually do this?** If it feels impractical or unrealistic, revise.

---

## Revision Examples

### ❌ Poor Action Step:
"Take time to reflect on your feelings about the situation, ensuring you understand the full context and implications."

**Problems:**
- Generic prefix "Take time to..."
- Vague action "reflect on feelings"
- No specific method or outcome
- Generic suffix about understanding context

### ✅ Improved Version:
"Journal for 10 minutes daily about specific moments when anxiety arises around food, noting triggers, physical sensations, and your immediate thoughts."

**Improvements:**
- Specific action (journal)
- Defined timeframe (10 minutes daily)
- Clear focus (anxiety triggers)
- Observable elements (triggers, sensations, thoughts)

---

## Implementation Notes

1. **Batch Processing**: When generating steps for multiple scenarios, process them individually to ensure contextual uniqueness.

2. **Human Review**: Always have a human reviewer check 10-20% of generated steps against the quality checklist.

3. **Continuous Improvement**: Track recurring quality issues and update the anti-patterns list accordingly.

4. **Cultural Sensitivity**: Ensure steps are appropriate across different cultural contexts, especially for international users.

5. **Accessibility**: Consider different ability levels, resources, and circumstances when suggesting actions.

---

## Version History

- **v1.0** (2025-11-13): Initial template created based on analysis of 1,226 scenarios
- Anti-patterns identified: "Take time to...", "ensuring you understand the full context"
- Quality criteria established for specificity, actionability, and contextual relevance

---

## Support Resources

For questions or improvements to this template:
- Review `/gita_scholar_agent/output/scenario_quality_report.txt` for current quality metrics
- Check `/gita_scholar_agent/output/top20_improved_action_steps.json` for high-quality examples
- Run `python3 gita_scholar_agent/scenario_quality_checker.py` to audit existing content

---

**Last Updated:** 2025-11-13
**Maintained By:** GitaWisdom Content Quality Team
