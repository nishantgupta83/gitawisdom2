#!/usr/bin/env python3
"""
Generate SQL update scripts from AI-improved action steps.
"""

import json

# Manual mapping of improved action steps (from AI review above)
IMPROVED_STEPS = {
    361: [
        "Approach the target immediately after the incident and ask if they're okay and what support they need",
        "Write down specific details within 24 hours: date, time, location, witnesses, exact words or actions observed",
        "File a formal HR report using your documented evidence and request written confirmation of receipt",
        "Offer to serve as a witness if the target files a complaint, while respecting their autonomy in decision-making",
        "Check in with the target weekly to see how they're doing and if they need additional support"
    ],
    363: [
        "Schedule a private meeting with management to explain how transparency prevents larger legal and reputational risks",
        "Draft a client communication that acknowledges the error, outlines corrective actions, and provides a timeline",
        "Propose a specific recovery plan with measurable deliverables that demonstrates accountability",
        "Document all internal discussions about the decision in writing to record your ethical stance",
        "If management insists on concealment, consult your company's ethics officer or a trusted mentor about next steps"
    ],
    364: [
        "Conduct a 48-hour background check using public records, news articles, and industry watchdog reports",
        "Calculate what percentage of total funding this donation represents to assess dependency risk",
        "Convene a stakeholder meeting to discuss the donor's practices, values alignment, and reputational impact",
        "If misaligned, draft a respectful decline letter explaining your organization's ethical standards",
        "Launch a diversified fundraising outreach to three alternative donor sources within 30 days"
    ],
    365: [
        "Review your company's resource use policy in the employee handbook or intranet within the next 24 hours",
        "Ask your manager directly via email about permissible personal use to create a documented record",
        "Stop any current personal use of company resources until you have explicit written permission",
        "When you see colleagues misusing resources, privately share the company policy with them",
        "Set a monthly reminder to review expense reports and resource usage for compliance"
    ],
    368: [
        "Research your company's insider trading policy and relevant securities laws applicable to your role",
        "Immediately inform your supervisor if you accidentally receive confidential information you shouldn't have",
        "Decline any opportunity to profit from insider knowledge, even if the risk of detection seems low",
        "If you witness a colleague misusing privileged information, report it to your compliance officer",
        "When in doubt about information sensitivity, assume it's confidential and don't share it"
    ],
    322: [
        "Block three specific 45-minute time slots in your calendar this week for physical activity and mark them as non-negotiable",
        "Set a daily alarm for 10:30 PM to start your bedtime routine, treating sleep as seriously as morning meetings",
        "Replace one lunch meeting per week with a walking meeting to integrate movement into work",
        "Schedule your annual physical exam and two dental checkups for the year ahead within the next week",
        "Calculate how many productive years you're trading for current overwork and share the number with a trusted friend"
    ],
    333: [
        "Text or call your friend to acknowledge you've noticed the distance and ask if they want to talk about it",
        "In conversation, express genuine gratitude for specific ways they've supported you in the past",
        "Ask about their own goals and dreams, then offer concrete help like an introduction or resource",
        "Share your success story including the struggles and failures, not just the highlight reel",
        "Invite them to celebrate with you in a low-key way that focuses on connection, not achievement"
    ],
    353: [
        "Reach out directly with a message like 'I've missed connecting with you lately - can we grab coffee?'",
        "During your conversation, thank them for 2-3 specific instances when their support made a difference",
        "Ask them about their current projects and offer to help with introductions, advice, or accountability",
        "When sharing your achievement, include the setbacks and uncertainty you faced along the way",
        "Plan a shared activity you both enjoy that has nothing to do with work or accomplishments"
    ],
    340: [
        "Intervene in the moment if safe by redirecting the conversation or asking the target if they need to step away",
        "Submit an incident report to HR within 24 hours with specific details: who, what, when, where, witnesses",
        "Write down everything you remember about the incident immediately while details are fresh",
        "Ask the target privately how they would like you to support them and respect their wishes",
        "If HR doesn't respond within one week, escalate to the next management level in writing"
    ],
    341: [
        "Email all decision-makers immediately to disclose your friendship and ask about the recusal process",
        "Request that another manager lead the evaluation and final decision for this contract",
        "Create a written evaluation rubric with objective criteria and weights before reviewing any bids",
        "Save all communications and decision documentation to demonstrate fairness if later questioned",
        "If you must participate, score your friend's bid last to avoid anchoring bias"
    ],
    344: [
        "Search your company intranet for 'acceptable use policy' or 'resource policy' and read it thoroughly",
        "Email your manager asking 'Is personal use of [specific resource] permitted? I want to make sure I'm following policy.'",
        "If you've been misusing resources, stop immediately and self-report to your manager with a plan to repay if needed",
        "When you see a colleague taking supplies home, send them the policy link and say 'Just wanted to share this in case helpful'",
        "Set a calendar reminder every 6 months to review your expense reports and resource usage for compliance"
    ],
    352: [
        "List all your friend groups and rate each one 1-10 for energy, values alignment, and mutual support",
        "Block monthly recurring 2-hour time slots for your top 3 relationships and protect those slots",
        "Text lower-priority friends honestly: 'I have limited social capacity right now but value our friendship'",
        "For the next month, say no to any social event that doesn't genuinely excite you",
        "Every quarter, review your relationships and adjust time allocation based on who reciprocates effort"
    ],
    334: [
        "Within 24 hours, message your friend privately: 'I heard something concerning and wanted to talk to you first'",
        "Share exactly what you heard, who said it, and in what context, without adding interpretation",
        "Ask your friend if they want to know who's spreading rumors or if they'd rather you just support them",
        "When the rumor comes up again in conversation, say 'I've talked to them directly and won't speculate'",
        "If someone persists in gossiping, privately tell them 'This doesn't feel right to discuss behind their back'"
    ],
    354: [
        "Call or meet your friend privately within 24 hours and say 'I need to tell you what I've been hearing'",
        "Share the specific rumor and name who told you, so your friend has full context",
        "Ask how they want to handle it - address the source, ignore it, or have you set the record straight",
        "The next time someone brings up the rumor, interrupt with 'I've verified that's not accurate'",
        "Message the original gossiper privately: 'This rumor is harmful and inaccurate. Please stop spreading it.'"
    ],
    355: [
        "Before answering their next crisis call, write down what level of support you can realistically offer",
        "During the conversation, help them brainstorm solutions but don't offer to fix the problem for them",
        "After the crisis, wait one week then text: 'Would love to catch up about non-crisis stuff - coffee this week?'",
        "If the pattern continues, say directly: 'I care about you, but I'm noticing you mostly reach out when things are hard'",
        "Set a boundary like 'I can only help with urgent crises once a month' and stick to it consistently"
    ],
    356: [
        "Write a calm message or request a conversation: 'I need to talk about what happened when you shared my private information'",
        "In conversation, describe the specific impact: 'When you told them X, I felt Y and now I'm worried about Z'",
        "Ask them to explain their perspective: 'Help me understand why you shared that information'",
        "Set a clear boundary: 'Moving forward, I need you to ask before sharing anything I tell you privately'",
        "Give yourself a 30-day trial period to see if they respect the new boundary before deciding on the friendship"
    ],
    357: [
        "Set a recurring monthly calendar reminder to text or call your friend on a specific date",
        "Send a voice message about your week instead of text - it takes 2 minutes and feels more personal",
        "Start a shared photo album or playlist where you both add things that remind you of each other",
        "Plan one in-person visit in the next 6 months, even if it's just for a weekend",
        "Text them on important dates (birthday, work anniversary) with a specific memory: 'Remember when we...'"
    ],
    348: [
        "Spend 30 minutes researching your favorite brand using resources like Good On You, Ethical Consumer, or B Corp directory",
        "Find 2-3 alternative brands that score well on labor practices and test their products",
        "For items where no ethical option exists, reduce purchase frequency by 50% instead of eliminating entirely",
        "Share what you learned with friends by forwarding one helpful article or recommending one ethical alternative brand",
        "Each quarter, replace one problematic brand in your life with a verified ethical alternative"
    ],
    360: [
        "Break your remaining work into 2-hour chunks and schedule each chunk on your calendar with specific deliverables",
        "Email your instructor or manager right now asking for a 2-day extension and explaining your situation honestly",
        "Book a 30-minute appointment with a tutor, writing center, or colleague to get help on the hardest section",
        "If you use any external ideas or phrasing, add the citation immediately before moving to the next section",
        "Set a rule: 'If I'm tempted to plagiarize, that's the sign I need to ask for help or an extension'"
    ],
    362: [
        "Send an email to all decision-makers within 24 hours: 'I need to disclose that [candidate] is a close friend'",
        "Request in writing that you be fully recused from the interview, evaluation, and hiring decision",
        "If recusal isn't possible, create a standardized scoring rubric and have HR verify it before you see any applications",
        "Share your friendship disclosure with the hiring committee before the first application review",
        "Save all emails and documentation related to the disclosure in a 'conflict of interest' folder"
    ]
}

def main():
    """Generate SQL updates."""

    output_file = 'gita_scholar_agent/output/UPDATE_ACTION_STEPS.sql'

    with open(output_file, 'w', encoding='utf-8') as f:
        f.write("-- SQL Script to Update Action Steps with AI-Improved Versions\n")
        f.write("-- Generated by generate_sql_updates.py\n")
        f.write("-- Replaces redundant templates with specific, actionable guidance\n\n")
        f.write("BEGIN;\n\n")

        for scenario_id, steps in sorted(IMPROVED_STEPS.items()):
            # Escape single quotes for SQL
            steps_json = json.dumps(steps, ensure_ascii=False)
            steps_json_escaped = steps_json.replace("'", "''")

            f.write(f"-- Scenario {scenario_id}\n")
            f.write(f"UPDATE scenarios \n")
            f.write(f"SET sc_action_steps = '{steps_json_escaped}'::jsonb \n")
            f.write(f"WHERE scenario_id = {scenario_id};\n\n")

        f.write("COMMIT;\n")
        f.write(f"\n-- Updated {len(IMPROVED_STEPS)} scenarios\n")

    print(f"✅ SQL script generated: {output_file}")
    print(f"📊 Scenarios updated: {len(IMPROVED_STEPS)}")
    print(f"\n🎯 Next steps:")
    print(f"   1. Review the SQL: {output_file}")
    print(f"   2. Test on a staging database first")
    print(f"   3. Run: psql -h <host> -U postgres -d postgres -f {output_file}")

if __name__ == "__main__":
    main()
