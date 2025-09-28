//
//  GitaWisdomWidget.swift
//  GitaWisdomWidget
//
//  Created by GitaWisdom App
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Provider
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), verse: "Chapter 2, Verse 47", 
                   content: "You have a right to perform your prescribed duty, but you are not entitled to the fruits of action.",
                   sanskrit: "कर्मण्येवाधिकारस्ते मा फलेषु कदाचन")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), 
                               verse: "Chapter 2, Verse 47",
                               content: "You have a right to perform your prescribed duty, but you are not entitled to the fruits of action.",
                               sanskrit: "कर्मण्येवाधिकारस्ते मा फलेषु कदाचन")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Sample verses for the widget
        let verses = [
            ("Chapter 2, Verse 47", "You have a right to perform your prescribed duty, but you are not entitled to the fruits of action.", "कर्मण्येवाधिकारस्ते मा फलेषु कदाचन"),
            ("Chapter 2, Verse 14", "The non-permanent appearance of happiness and distress, and their disappearance in due course, are like the appearance and disappearance of winter and summer seasons.", "मात्रास्पर्शास्तु कौन्तेय शीतोष्णसुखदुःखदाः"),
            ("Chapter 6, Verse 5", "One must elevate oneself by one's own mind, not degrade oneself. The mind is the friend of the conditioned soul, and his enemy as well.", "उद्धरेदात्मनात्मानं नात्मानमवसादयेत्"),
            ("Chapter 4, Verse 7", "Whenever there is a decline in righteousness and an increase in unrighteousness, O Arjun, at that time I manifest Myself on earth.", "यदा यदा हि धर्मस्य ग्लानिर्भवति भारत"),
            ("Chapter 18, Verse 66", "Abandon all varieties of religion and just surrender unto Me. I shall deliver you from all sinful reactions. Do not fear.", "सर्वधर्मान्परित्यज्य मामेकं शरणं व्रज")
        ]

        // Generate timeline entries for next 24 hours, changing every 5 hours
        let currentDate = Date()
        for hourOffset in stride(from: 0, to: 24, by: 5) {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let verseIndex = (hourOffset / 5) % verses.count
            let verse = verses[verseIndex]
            let entry = SimpleEntry(date: entryDate, verse: verse.0, content: verse.1, sanskrit: verse.2)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

// MARK: - Timeline Entry
struct SimpleEntry: TimelineEntry {
    let date: Date
    let verse: String
    let content: String
    let sanskrit: String
}

// MARK: - Widget View
struct GitaWisdomWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var widgetFamily

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.4, green: 0.2, blue: 0.6),
                    Color(red: 0.6, green: 0.3, blue: 0.7)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(alignment: .leading, spacing: 8) {
                // Header
                HStack {
                    Image(systemName: "book.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.9))
                    Text("Gita Wisdom")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                }
                
                // Verse reference
                Text(entry.verse)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                
                // Content based on widget size
                if widgetFamily == .systemLarge {
                    // Sanskrit text for large widget
                    Text(entry.sanskrit)
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(2)
                        .padding(.vertical, 2)
                }
                
                // Main verse content
                Text(entry.content)
                    .font(.system(size: widgetFamily == .systemSmall ? 11 : 12))
                    .foregroundColor(.white)
                    .lineLimit(widgetFamily == .systemSmall ? 3 : 4)
                    .minimumScaleFactor(0.8)
                
                Spacer(minLength: 0)
            }
            .padding()
        }
    }
}

// MARK: - Main Widget
struct GitaWisdomWidget: Widget {
    let kind: String = "GitaWisdomWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            GitaWisdomWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Daily Wisdom")
        .description("Receive daily verses from the Bhagavad Gita")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}