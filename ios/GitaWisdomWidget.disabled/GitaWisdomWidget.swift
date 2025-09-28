//
//  GitaWisdomWidget.swift
//  GitaWisdomWidget
//
//  Created by Nishant Gupta on 8/26/25.
//

import WidgetKit
import SwiftUI

// Daily Gita verses data
struct GitaVerse {
    let chapterNumber: Int
    let verseNumber: Int
    let sanskrit: String
    let english: String
    let meaning: String
}

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(), 
            configuration: ConfigurationAppIntent(),
            verse: GitaVerse(
                chapterNumber: 2,
                verseNumber: 47,
                sanskrit: "कर्मण्येवाधिकारस्ते मा फलेषु कदाचन",
                english: "You have the right to work, but never to the fruits of work.",
                meaning: "Focus on action, not results"
            )
        )
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        return SimpleEntry(
            date: Date(), 
            configuration: configuration,
            verse: getDailyVerse()
        )
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []
        let currentDate = Date()
        
        // Update once daily at midnight
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        let nextMidnight = calendar.startOfDay(for: tomorrow)
        
        let entry = SimpleEntry(
            date: currentDate,
            configuration: configuration,
            verse: getDailyVerse()
        )
        entries.append(entry)

        return Timeline(entries: entries, policy: .after(nextMidnight))
    }
    
    private func getDailyVerse() -> GitaVerse {
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 1
        
        // Sample verses - rotate based on day of year
        let verses = [
            GitaVerse(
                chapterNumber: 2,
                verseNumber: 47,
                sanskrit: "कर्मण्येवाधिकारस्ते मा फलेषु कदाचन",
                english: "You have the right to work, but never to the fruits of work.",
                meaning: "Focus on your duties without attachment to results"
            ),
            GitaVerse(
                chapterNumber: 3,
                verseNumber: 35,
                sanskrit: "श्रेयान्स्वधर्मो विगुणः परधर्मात्स्वनुष्ठितात्",
                english: "Better is one's own dharma, though imperfectly performed.",
                meaning: "Follow your own path rather than imitating others"
            ),
            GitaVerse(
                chapterNumber: 6,
                verseNumber: 5,
                sanskrit: "उद्धरेदात्मनात्मानं नात्मानमवसादयेत्",
                english: "Lift yourself up by your own efforts, do not degrade yourself.",
                meaning: "Be your own friend through self-discipline"
            ),
            GitaVerse(
                chapterNumber: 18,
                verseNumber: 78,
                sanskrit: "यत्र योगेश्वरः कृष्णो यत्र पार्थो धनुर्धरः",
                english: "Where there is Krishna and Arjuna, there is prosperity.",
                meaning: "Divine guidance and dedicated effort ensure success"
            )
        ]
        
        let index = (dayOfYear - 1) % verses.count
        return verses[index]
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let verse: GitaVerse
}

struct GitaWisdomWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            MediumWidgetView(entry: entry)
        }
    }
}

struct SmallWidgetView: View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text("📿")
                    .font(.title3)
                Spacer()
                Text("\(entry.verse.chapterNumber).\(entry.verse.verseNumber)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(entry.verse.meaning)
                .font(.caption)
                .multilineTextAlignment(.center)
                .lineLimit(3)
            
            Spacer()
            
            Text("GitaWisdom")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .containerBackground(Color.orange.opacity(0.1), for: .widget)
    }
}

struct MediumWidgetView: View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("🕉️ Daily Wisdom")
                    .font(.headline)
                    .foregroundColor(.orange)
                Spacer()
                Text("BG \(entry.verse.chapterNumber).\(entry.verse.verseNumber)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(entry.verse.english)
                .font(.subheadline)
                .lineLimit(2)
                .foregroundColor(.primary)
            
            Text(entry.verse.meaning)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            Spacer()
        }
        .padding()
        .containerBackground(Color.orange.opacity(0.05), for: .widget)
    }
}

struct LargeWidgetView: View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("🕉️ Daily Gita Wisdom")
                    .font(.headline)
                    .foregroundColor(.orange)
                Spacer()
                Text("Chapter \(entry.verse.chapterNumber), Verse \(entry.verse.verseNumber)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(entry.verse.sanskrit)
                .font(.subheadline)
                .foregroundColor(.brown)
                .lineLimit(2)
            
            Divider()
            
            Text(entry.verse.english)
                .font(.body)
                .lineLimit(3)
                .foregroundColor(.primary)
            
            Text(entry.verse.meaning)
                .font(.callout)
                .foregroundColor(.secondary)
                .lineLimit(3)
                .italic()
            
            Spacer()
            
            Text("Tap to open GitaWisdom app")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .containerBackground(Color.orange.opacity(0.05), for: .widget)
    }
}

struct GitaWisdomWidget: Widget {
    let kind: String = "GitaWisdomWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            GitaWisdomWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Daily Gita Wisdom")
        .description("Get daily wisdom from the Bhagavad Gita on your home screen.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

extension ConfigurationAppIntent {
    fileprivate static var medium: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.widgetSize = "medium"
        return intent
    }
    
    fileprivate static var large: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.widgetSize = "large"
        return intent
    }
}

#Preview(as: .systemSmall) {
    GitaWisdomWidget()
} timeline: {
    SimpleEntry(
        date: .now, 
        configuration: .medium,
        verse: GitaVerse(
            chapterNumber: 2,
            verseNumber: 47,
            sanskrit: "कर्मण्येवाधिकारस्ते मा फलेषु कदाचन",
            english: "You have the right to work, but never to the fruits of work.",
            meaning: "Focus on action, not results"
        )
    )
}

#Preview(as: .systemMedium) {
    GitaWisdomWidget()
} timeline: {
    SimpleEntry(
        date: .now, 
        configuration: .medium,
        verse: GitaVerse(
            chapterNumber: 3,
            verseNumber: 35,
            sanskrit: "श्रेयान्स्वधर्मो विगुणः परधर्मात्स्वनुष्ठितात्",
            english: "Better is one's own dharma, though imperfectly performed.",
            meaning: "Follow your own path rather than imitating others"
        )
    )
}
