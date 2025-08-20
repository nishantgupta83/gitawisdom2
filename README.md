# GitaWisdom - Bhagavad Gita Guide for Modern Life

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.com)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)

> **"Apply ancient Gita teachings to modern-day situations"**

A comprehensive Flutter application that brings the wisdom of the Bhagavad Gita to contemporary life through interactive chapters, real-world scenarios, daily verses, and personal journaling.

## 📱 App Overview

**GitaWisdom** transforms the 18 chapters of the Bhagavad Gita into an accessible, modern spiritual guide. Users can explore verses, apply teachings to real-life situations, and maintain a personal spiritual journal.

### ✨ Key Features

- 📖 **18 Complete Chapters**: Full Bhagavad Gita content with permanent caching for instant loading
- 🎯 **1280+ Real-world Scenarios**: Modern applications of ancient wisdom with heart vs duty guidance
- 🌅 **Daily Verses**: Calendar-based verse refresher with permanent verse caching
- 🎨 **Dynamic Theming**: Light/Dark mode with enhanced amber glow effects
- 🔤 **Typography Control**: Responsive font sizes and improved text visibility
- 🎵 **Ambient Audio**: Background music with persistent settings
- 💾 **Aggressive Caching**: Monthly sync strategy reducing API calls by 97%
- 🔄 **Instant Performance**: Offline-first with permanent caching for chapters and verses
- 📐 **Responsive Design**: Optimized for tablets, phones, and all orientations
- ✨ **Enhanced Visual Effects**: Professional amber glow effects and glassmorphism
- 🚀 **Production Ready**: English-only MVP optimized for store launch

## 🏗️ Architecture

### Technology Stack
- **Frontend**: Flutter 3.2.0+ with Material Design
- **Backend**: Supabase (PostgreSQL database)
- **Local Storage**: Hive for offline data and settings
- **State Management**: Provider pattern with ValueListenableBuilder
- **Typography**: Google Fonts (Poppins family)
- **Audio**: just_audio for background music
- **UI Components**: flutter_neumorphic for modern design

### Project Structure
```
lib/
├── main.dart                 # App entry point with theme configuration
├── models/                   # Data models with Hive adapters
│   ├── chapter.dart         # Chapter model with Hive adapter
│   ├── chapter_summary.dart # Lightweight chapter overview
│   ├── verse.dart          # Individual verse model (enhanced with chapterId)
│   ├── scenario.dart       # Real-world scenario model with Hive adapter
│   ├── daily_verse_set.dart # Calendar-based daily verse collection
│   └── journal_entry.dart  # User journal entry model
├── screens/                # UI screens
│   ├── home_screen.dart    # Main landing with daily verses
│   ├── chapters_screen.dart # Chapter list overview
│   ├── chapters_detail_view.dart # Individual chapter details
│   ├── scenarios_screen.dart # Life scenarios listing
│   ├── scenario_detail_view.dart # Scenario details with guidance
│   ├── verse_list_view.dart # Chapter verses display
│   ├── journal_screen.dart # Personal journal interface
│   ├── more_screen.dart    # Settings and app info
│   └── about_screen.dart   # App information
├── services/               # Business logic layer
│   ├── supabase_service.dart # Database operations
│   ├── settings_service.dart # User preferences (Hive)
│   ├── journal_service.dart  # Journal management
│   ├── audio_service.dart   # Background music
│   ├── daily_verse_service.dart # Calendar-based verse caching
│   ├── scenario_service.dart # Scenario caching and search
│   ├── cache_service.dart   # Unified cache management
│   └── analytics_service.dart # Usage tracking
├── widgets/               # Reusable UI components
│   ├── custom_nav_bar.dart # Enhanced bottom navigation (pill/dev/floating styles)
│   └── expandable_text.dart # Text with read more/less functionality
└── config/                # Configuration and environment
    └── environment.dart   # Environment-specific settings
```

## 🔄 Application Flow Diagrams

### Main Navigation Flow
```mermaid
graph TD
    A[Splash Screen] --> B[Home Screen]
    B --> C[Chapters Screen]
    B --> D[Scenarios Screen]
    B --> E[Journal Screen]
    B --> F[More Screen]
    
    C --> G[Chapter Detail View]
    G --> H[Verse List View]
    
    D --> I[Scenario Detail View]
    
    E --> J[Journal Entry Detail]
    E --> K[New Journal Entry]
    
    F --> L[About Screen]
    F --> M[References Screen]
    F --> N[Settings Panel]
```

### Screen-by-Screen Flow Details

#### 🏠 **Home Screen Flow**
```
┌─────────────────────────────────────────────────────────────────────┐
│                           HOME SCREEN                               │
├─────────────────────────────────────────────────────────────────────┤
│  ┌─ Header Card ─────────────────────────────────────────────────┐  │
│  │  🏛️ "GITA WISDOM"                                             │  │
│  │  "Apply Gita Teaching to Modern Day Situations"              │  │
│  └───────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  ┌─ Daily Verses Carousel ─────────────────────────────────────┐    │
│  │  📜 [Verse 1] ← → [Verse 2] ← → [Verse 3] ← → [Verse 4]    │    │
│  │     • Random verses from different chapters                  │    │
│  │     • Swipeable cards with page indicator                   │    │
│  │     • "Verse Refresher" section                            │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                                                                     │
│  ┌─ Quick Access Buttons ────────────────────────────────────────┐  │
│  │  [📖 Explore Chapters] [🎯 Browse Scenarios]                 │  │
│  │  • Direct navigation to main content sections                │  │
│  └───────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  🔘 Bottom Navigation: Home | Chapters | Scenarios | More          │
│  🎈 Floating Buttons: 🏠 Home | ⋯ More (Top-right corner)          │
└─────────────────────────────────────────────────────────────────────┘

User Interactions:
• Swipe verses horizontally for random spiritual guidance
• Tap "Explore Chapters" → Chapters Screen
• Tap "Browse Scenarios" → Scenarios Screen  
• Tap floating Home → Stay on Home
• Tap floating More → More Screen
• Use bottom nav for primary navigation
```

#### 📚 **Chapters Screen Flow**
```
┌─────────────────────────────────────────────────────────────────────┐
│                         CHAPTERS SCREEN                            │
├─────────────────────────────────────────────────────────────────────┤
│  ┌─ Header Card ─────────────────────────────────────────────────┐  │
│  │  📖 "GITA CHAPTERS"                                           │  │
│  │  "Immerse into the ocean of knowledge"                       │  │
│  └───────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  ┌─ Chapter List (18 Chapters) ────────────────────────────────┐    │
│  │  ┌─ Chapter Card ─────────────────────────────────────────┐ │    │
│  │  │ [1] Arjuna Vishada Yoga                                 │ │    │
│  │  │     "The Despondency of Arjuna"                        │ │    │
│  │  │     Verses → 47  •  Modern Life Scenarios → 12    ➤   │ │    │
│  │  └─────────────────────────────────────────────────────────┘ │    │
│  │  ┌─ Chapter Card ─────────────────────────────────────────┐ │    │
│  │  │ [2] Sankhya Yoga                                        │ │    │
│  │  │     "The Yoga of Knowledge"                            │ │    │
│  │  │     Verses → 72  •  Modern Life Scenarios → 18    ➤   │ │    │
│  │  └─────────────────────────────────────────────────────────┘ │    │
│  │  ...continuing for all 18 chapters                            │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                     │
│  🎈 Floating Buttons: ← Back | 🏠 Home (Top-right corner)           │
└─────────────────────────────────────────────────────────────────────┘

User Flow:
• Browse all 18 chapters with verse/scenario counts
• Tap any chapter card → Chapter Detail View
• Visual hierarchy: Chapter number, title, subtitle, counts
• Smooth fade transitions between screens
• Floating back button returns to previous screen
• Floating home button goes to main screen
```

#### 📖 **Chapter Detail View Flow**  
```
┌─────────────────────────────────────────────────────────────────────┐
│                      CHAPTER DETAIL VIEW                           │
├─────────────────────────────────────────────────────────────────────┤
│  ┌─ Hero Banner ─────────────────────────────────────────────────┐  │
│  │  🏛️ "Chapter {N}: {Title}"                                    │  │
│  │  📜 "{Subtitle/Description}"                                   │  │
│  │  📊 Overview: X verses, Y scenarios, key themes              │  │
│  └───────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  ┌─ Navigation Tabs ─────────────────────────────────────────────┐  │
│  │  [📜 Verses] [🎯 Scenarios] [📝 Summary] [🗝️ Key Teachings] │  │
│  └───────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  ┌─ Content Area (Dynamic based on tab) ───────────────────────┐    │
│  │  📜 VERSES TAB:                                              │    │
│  │     • Verse 1: "यदा यदा हि धर्मस्य..."                    │    │
│  │     • Verse 2: "Translation and commentary..."              │    │
│  │     • [View All Verses] → Verse List View                   │    │
│  │                                                              │    │
│  │  🎯 SCENARIOS TAB:                                           │    │
│  │     • "Workplace Conflict Resolution"                       │    │
│  │     • "Decision Making Under Pressure"                      │    │
│  │     • [Browse All Scenarios] → Scenarios filtered by chapter│    │
│  │                                                              │    │
│  │  📝 SUMMARY TAB:                                            │    │
│  │     • Chapter theme and core message                        │    │
│  │     • Historical context                                    │    │
│  │     • Practical applications                                │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                     │
│  🎈 Floating Navigation: ← Back | 🏠 Home | ➤ Next Chapter          │
└─────────────────────────────────────────────────────────────────────┘

Navigation Paths:
• Chapter Detail → Verse List View (all chapter verses)
• Chapter Detail → Scenario Detail View (filtered scenarios)  
• Chapter Detail → Next/Previous Chapter (sequential reading)
• Tabbed interface for different content types
• Rich content with expandable sections
```

#### 🎯 **Scenarios Screen Flow** (Updated with Bulletproof Filtering)
```
┌─────────────────────────────────────────────────────────────────────┐
│                        SCENARIOS SCREEN                            │
├─────────────────────────────────────────────────────────────────────┤
│  ┌─ Header Card ─────────────────────────────────────────────────┐  │
│  │  🎯 "LIFE SCENARIOS"                                          │  │
│  │  "Apply Gita wisdom to real-world situations"                │  │
│  └───────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  ┌─ Advanced Filter System ─────────────────────────────────────┐  │
│  │  [All] [Life Stages] [Relationships] [Career & Work]        │  │
│  │  [Personal Growth] [Modern Life]                             │  │
│  │  🔍 Advanced Search: "parenting stress" "work life balance"  │  │
│  │  • Compound queries • Cross-field matching • Tag mapping    │  │
│  └───────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  ┌─ Scenario List ───────────────────────────────────────────────┐  │
│  │  ┌─ Scenario Card ─────────────────────────────────────────┐ │  │
│  │  │ 💼 "Workplace Conflict Resolution"                      │ │  │
│  │  │    "When colleagues disagree on project direction..."   │ │  │
│  │  │    📖 Chapter 2: Sankhya Yoga                          │ │  │
│  │  │    🏷️ Tags: work, conflict, decision-making        ➤  │ │  │
│  │  └─────────────────────────────────────────────────────────┘ │  │
│  │  ┌─ Scenario Card ─────────────────────────────────────────┐ │  │
│  │  │ 👨‍👩‍👧‍👦 "Family Relationship Challenges"                  │ │  │
│  │  │    "Balancing personal goals with family expectations" │ │  │
│  │  │    📖 Chapter 3: Karma Yoga                           │ │  │
│  │  │    🏷️ Tags: family, duty, balance                  ➤  │ │  │
│  │  └─────────────────────────────────────────────────────────┘ │  │
│  │  ...more scenario cards with expandable descriptions          │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  🎈 Floating Buttons: 🏠 Home | ⋯ More (Top-right corner)           │
└─────────────────────────────────────────────────────────────────────┘

Features:
• **Bulletproof filtering** with 5 comprehensive categories automatically mapping 699+ scenarios
• **Advanced search** with compound queries ("work stress", "family duty")
• **Smart tag matching** using extensive keyword libraries for precise categorization
• **Chapter-specific filtering** with seamless navigation integration
• **Future-proof design** automatically handles new scenario categories
• Expandable text with "Read more" functionality  
• Chapter reference for each scenario
• Tap any scenario → Scenario Detail View with full guidance
```

#### 🎯 **Scenario Detail View Flow**
```
┌─────────────────────────────────────────────────────────────────────┐
│                     SCENARIO DETAIL VIEW                           │
├─────────────────────────────────────────────────────────────────────┤
│  ┌─ Hero Section ───────────────────────────────────────────────┐   │
│  │  💼 "{Scenario Title}"                                       │   │
│  │  📖 Reference: Chapter {N} - {Chapter Name}                 │   │
│  │  🏷️ Tags: [work] [conflict] [decision-making]               │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─ Situation Description ──────────────────────────────────────┐   │
│  │  📝 "Detailed description of the modern-day situation..."   │   │
│  │     • Context and background                                 │   │
│  │     • Key challenges involved                               │   │
│  │     • Emotional and practical considerations               │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─ Two-Path Guidance ──────────────────────────────────────────┐   │
│  │  ❤️ HEART RESPONSE:                                         │   │
│  │     "What your emotions/instincts might tell you to do..."  │   │
│  │     • Emotional reaction approach                           │   │
│  │     • Short-term satisfaction focus                        │   │
│  │                                                             │   │
│  │  ⚖️ DHARMA (DUTY) RESPONSE:                                │   │
│  │     "What the Gita wisdom guides you to do..."             │   │
│  │     • Dharmic action based on duty and righteousness       │   │
│  │     • Long-term perspective and greater good               │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─ Gita Wisdom & Action Steps ────────────────────────────────┐   │
│  │  📜 RELEVANT VERSE:                                         │   │
│  │     "कर्मण्येवाधिकारस्ते मा फलेषु कदाचन..."               │   │
│  │     "You have the right to action, not to its fruits..."   │   │
│  │                                                             │   │
│  │  ✅ PRACTICAL ACTION STEPS:                                │   │
│  │     1. Pause and assess the situation objectively          │   │
│  │     2. Consider duty and dharma over personal preferences   │   │
│  │     3. Act without attachment to outcomes                   │   │
│  │     4. Reflect on lessons learned                          │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  [📝 Add to Journal] [🔗 Share Wisdom] [📖 Read Full Chapter]      │
│                                                                     │
│  🎈 Floating Navigation: ← Back | 🏠 Home | 📱 More Scenarios       │
└─────────────────────────────────────────────────────────────────────┘

Key Interactions:
• Compare heart vs duty responses for balanced decision-making
• Access relevant Gita verses with modern interpretations  
• Save insights to personal journal
• Navigate to full chapter for deeper study
• Share wisdom snippets with others
```

#### 📖 **Verse List View Flow**
```
┌─────────────────────────────────────────────────────────────────────┐
│                        VERSE LIST VIEW                             │
│                     (Chapter-specific)                             │
├─────────────────────────────────────────────────────────────────────┤
│  ┌─ Chapter Header ─────────────────────────────────────────────┐   │
│  │  📖 "Chapter {N}: {Title}"                                   │   │
│  │  📊 "{X} Total Verses"                                      │   │
│  │  🔍 [Search verses] [Filter by theme]                       │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─ Verse Cards List ───────────────────────────────────────────┐   │
│  │  ┌─ Verse Card ────────────────────────────────────────────┐ │   │
│  │  │ 📜 Verse 1                                              │ │   │
│  │  │    Original: "यदा यदा हि धर्मस्य ग्लानिर्भवति भारत" │ │   │
│  │  │    Translation: "Whenever there is decline of dharma..." │ │   │
│  │  │                                                          │ │   │
│  │  │    💡 Commentary: Brief explanation                     │ │   │
│  │  │    🎯 Modern Application: Real-world relevance          │ │   │
│  │  │    [🔖 Bookmark] [📝 Add Note] [🔗 Share]              │ │   │
│  │  └──────────────────────────────────────────────────────────┘ │   │
│  │  ┌─ Verse Card ────────────────────────────────────────────┐ │   │
│  │  │ 📜 Verse 2                                              │ │   │
│  │  │    [Similar structure...]                               │ │   │
│  │  └──────────────────────────────────────────────────────────┘ │   │
│  │  ...continuing for all verses in chapter                      │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─ Reading Progress ───────────────────────────────────────────┐   │
│  │  ████████░░ 80% Complete                                    │   │
│  │  [📖 Continue Reading] [🔄 Reset Progress]                  │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  🎈 Floating Navigation: ← Back to Chapter | 🏠 Home                │
└─────────────────────────────────────────────────────────────────────┘

Features:
• Sequential verse reading with progress tracking
• Original Sanskrit with English translations
• Personal notes and bookmarking system
• Search within chapter verses
• Modern applications for each verse
```

#### 📝 **Journal Screen Flow**  
```
┌─────────────────────────────────────────────────────────────────────┐
│                         JOURNAL SCREEN                             │
├─────────────────────────────────────────────────────────────────────┤
│  ┌─ Header Card ─────────────────────────────────────────────────┐  │
│  │  📝 "SPIRITUAL JOURNAL"                                       │  │
│  │  "Reflect on your spiritual journey and insights"            │  │
│  │  [➕ New Entry] [📅 Calendar View] [🔍 Search]               │  │
│  └───────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  ┌─ Entry Filters ──────────────────────────────────────────────┐  │
│  │  [All] [This Week] [This Month] [Favorites] [By Rating]     │  │
│  └───────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  ┌─ Journal Entries List ───────────────────────────────────────┐  │
│  │  ┌─ Entry Card ────────────────────────────────────────────┐ │  │
│  │  │ 📅 March 15, 2024                                       │ │  │
│  │  │ 📝 "Insights on letting go of attachment..."           │ │  │
│  │  │ ⭐ Rating: ★★★★☆                                       │ │  │
│  │  │ 🎯 Related: Chapter 2 - Karma Yoga                    │ │  │
│  │  │ 📎 Tags: [attachment] [peace] [growth]            ➤   │ │  │
│  │  └──────────────────────────────────────────────────────────┘ │  │
│  │  ┌─ Entry Card ────────────────────────────────────────────┐ │  │  
│  │  │ 📅 March 10, 2024                                       │ │  │
│  │  │ 📝 "Applying dharma in difficult decisions..."         │ │  │
│  │  │ ⭐ Rating: ★★★★★                                       │ │  │
│  │  │ 🎯 Related: Workplace Scenario                         │ │  │
│  │  └──────────────────────────────────────────────────────────┘ │  │
│  │  ...more journal entries...                                   │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  📊 Quick Stats: "15 entries this month • 4.2 avg rating"          │
│                                                                     │
│  🎈 Floating Action: [➕ Quick Entry] (Bottom-right corner)         │
└─────────────────────────────────────────────────────────────────────┘

User Flow:
• Create new entries with text, ratings, and tags
• Link entries to specific chapters or scenarios  
• Search entries by content, tags, or date range
• Tap any entry → Journal Entry Detail View for full content
• Export journal data for backup/sharing
```

#### ⚙️ **More Screen (Settings) Flow**
```
┌─────────────────────────────────────────────────────────────────────┐
│                          MORE SCREEN                               │
├─────────────────────────────────────────────────────────────────────┤
│  ┌─ APPEARANCE ──────────────────────────────────────────────────┐  │
│  │  🌙 Dark Mode                                        [Toggle] │  │
│  │  🎵 Background Music                                 [Toggle] │  │
│  │  🔤 Font Size                            [Small|Medium|Large] │  │
│  │  ✨ Text Shadow                                      [Toggle] │  │
│  │  🎨 Background Opacity          [░░░░░████] 30% ←→ 100%     │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  ┌─ EXTRAS ──────────────────────────────────────────────────────┐  │
│  │  📤 Share This App                                        ➤   │  │
│  │  📱 App Version: 1.0.0                                        │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  ┌─ RESOURCES ───────────────────────────────────────────────────┐  │
│  │  ℹ️ About                                                 ➤   │  │
│  │  📚 References                                            ➤   │  │  
│  └─────────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  ┌─ SUPPORT & LEGAL ─────────────────────────────────────────────┐  │
│  │  📧 Send Feedback                                         ➤   │  │
│  │  🔒 Privacy Policy                                        ➤   │  │
│  │  📜 Terms & Conditions                                    ➤   │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  🎈 Settings apply instantly with Hive persistence                 │
└─────────────────────────────────────────────────────────────────────┘

Features:
• Real-time theme switching (light/dark mode)
• Dynamic background opacity control with live preview
• Text shadow toggle for better readability  
• Font scaling with instant visual feedback
• Settings persist across app sessions
• Direct email feedback integration
```

## 🗃️ Data Flow Architecture

### Database Schema (Supabase)
```
chapters
├── ch_chapter_id (int, primary key)
├── ch_title (text)
├── ch_subtitle (text)
├── ch_summary (text)
├── ch_verse_count (int)
├── ch_theme (text)
└── ch_key_teachings (text[])

scenarios  
├── id (uuid, primary key)
├── sc_title (text)
├── sc_description (text)
├── sc_category (text)
├── sc_chapter (int, foreign key)
├── sc_heart_response (text)
├── sc_duty_response (text)
├── sc_gita_wisdom (text)
├── sc_verse (text)
├── sc_verse_number (text)
├── sc_tags (text[])
├── sc_action_steps (text[])
└── created_at (timestamp)

gita_verses
├── gv_verses_id (int, primary key)  
├── gv_verses (text)
└── gv_chapter_id (int, foreign key)

chapter_summary (view)
├── cs_chapter_id (int)
├── cs_title (text)
├── cs_subtitle (text)
├── cs_verse_count (int)
└── cs_scenario_count (int)
```

### Local Storage (Hive)
```
settings (Box)
├── isDarkMode (bool)
├── fontSize (string: 'small'|'medium'|'large')
├── music_enabled (bool)
├── text_shadow_enabled (bool)
└── background_opacity (double: 0.1-1.0)

journal_entries (Box<JournalEntry>)
├── id (string, key)
├── reflection (string)
├── rating (int: 1-5)
└── dateCreated (DateTime)

chapters (Box<Chapter>) - Cached from Supabase
├── chapterId (int, key)
├── title, subtitle, summary
├── verseCount, theme
└── keyTeachings (List<String>)

daily_verses (Box<DailyVerseSet>) - Calendar-based verse cache
├── date (string, key: 'YYYY-MM-DD')
├── verses (List<Verse>)
├── chapterIds (List<int>)
└── createdAt (DateTime)

scenarios (Box<Scenario>) - Cached for instant search
├── id (string, key)
├── title, description, category
├── chapter, heartResponse, dutyResponse
├── gitaWisdom, verse, verseNumber
├── tags (List<String>)
└── actionSteps (List<String>)
```

### 🎯 Advanced Filtering System Architecture

#### Category Mapping System
```
GitaWisdom Filtering Architecture
├── 🧬 Life Stages
│   ├── Parenting (new parents, twins, daycare, discipline)
│   ├── Pregnancy (prenatal, medical decisions, family planning)
│   ├── Education (student struggles, career choices, learning)
│   └── Family Transitions (newly married, joint family, elderly care)
│
├── 💕 Relationships  
│   ├── Dating & Romance (apps, ghosting, commitment, breakups)
│   ├── Marriage (communication, conflict, expectations, intimacy)
│   ├── Family Dynamics (in-laws, traditions, boundaries, loyalty)
│   └── Friendships (adult connections, social changes, support)
│
├── 💼 Career & Work
│   ├── Professional Growth (advancement, skills, networking, leadership)
│   ├── Workplace Challenges (harassment, toxic culture, ethics, boundaries)
│   ├── Entrepreneurship (startups, risk management, business decisions)
│   └── Financial Management (budgeting, debt, investments, security)
│
├── 🌱 Personal Growth
│   ├── Mental Health (anxiety, depression, therapy, self-care, healing)
│   ├── Spiritual Development (dharma, meditation, consciousness, service)
│   ├── Identity & Purpose (life direction, self-discovery, authenticity)
│   └── Personal Challenges (habits, addiction, change, resilience)
│
└── 🌐 Modern Life
    ├── Digital & Technology (social media, screen time, online presence)
    ├── Social Pressure (expectations, judgment, status, celebrations)
    ├── Lifestyle Choices (travel, health, hobbies, minimalism)
    └── Contemporary Issues (climate anxiety, cultural adaptation, modernity)
```

#### Search Intelligence Features
```
Advanced Search Capabilities
├── 📝 Compound Queries
│   ├── "parenting stress" → matches both keywords across all fields
│   ├── "work life balance" → finds scenarios addressing professional equilibrium
│   └── "family duty tradition" → locates multi-faceted cultural situations
│
├── 🔍 Cross-Field Matching
│   ├── Title: Primary scenario identification
│   ├── Description: Detailed situation context
│   ├── Tags: Categorical keywords and labels  
│   ├── Category: Broad classification groups
│   ├── Gita Wisdom: Spiritual guidance content
│   ├── Heart/Duty Responses: Emotional vs dharmic approaches
│   └── Action Steps: Practical implementation guidance
│
├── 🏷️ Smart Tag Mapping
│   ├── Automatic categorization using keyword libraries
│   ├── 50+ life stage keywords (parenting, pregnancy, education)
│   ├── 30+ relationship keywords (dating, marriage, family, friends)
│   ├── 25+ career keywords (professional, business, financial, work)
│   ├── 40+ growth keywords (mental health, spiritual, personal, identity)
│   └── 35+ modern life keywords (digital, social, lifestyle, contemporary)
│
└── 🔄 Future-Proof Design
    ├── Extensible keyword libraries for new categories
    ├── Automatic tag-to-category intelligent mapping
    ├── Graceful handling of unknown or new scenario types
    └── Scalable architecture ready for content expansion
```

New Capabilities:
- **Bulletproof filtering system** with comprehensive category mapping for 699+ scenarios
- **Advanced compound search** functionality across all scenario fields
- **Smart tag-to-category mapping** using extensive keyword libraries  
- **Future-proof architecture** ready for new scenario categories
- Scenario cache size monitoring
- Scenario cache clearing functionality
- Health checks and repair for scenario cache
- Complete cache statistics including scenario count

📊 Performance Improvements Achieved

| Feature               | Before             | After (v1.5.0)           |
|-----------------------|--------------------|---------------------------|
| Chapter Loading       | API calls every load | Instant (permanent cache) |
| Verse Loading         | API calls every load | Instant (permanent cache) |
| Scenario Caching      | 6 hour cache       | 30 day cache (monthly)   |
| API Call Frequency    | Every 6 hours      | Once per month           |
| Scenario Dataset      | 1000/1280 (78%)    | 1280/1280 (100%)         |
| Chapter Header        | Invisible text     | Professional amber glow   |
| Filter Text           | Poor visibility    | Enhanced contrast        |
| Journal Crashes       | Hive corruption    | Null-safe adapter       |
| Service Initialization| Multiple per session| Single initialization    |
| 50K Users API Load    | 6M calls/month     | 150K calls/month (97% ↓) |

🔧 Technical Architecture Implemented

GitaWisdom App Architecture (v1.5.0)
├── 📱 Aggressive Caching Strategy (monthly sync)
├── ⚡ Permanent Chapter/Verse Storage (never re-fetch)
├── 🎨 Professional Visual Effects (amber glow)
├── 📐 Enhanced Responsive Design (better visibility)
├── 💾 Complete Dataset Caching (all 1280 scenarios)
├── 🔄 Monthly Background Sync (97% API reduction)
├── 🏃‍♂️ Offline-First Architecture (instant performance)
└── 🛡️ Crash-Resistant Storage (null-safe adapters)

🎯 User Experience Enhancements (v1.5.0)

1. **Instant Performance**: Chapters and verses load instantly after first visit
2. **Complete Content**: All 1280 scenarios available for browsing and search
3. **Professional UI**: Enhanced amber glow effects and improved text visibility
4. **Crash-Free Experience**: Fixed all Hive corruption and runtime errors
5. **Monthly Fresh Content**: Automatic monthly updates with 97% fewer API calls
6. **Scalable Architecture**: Ready for 50K+ users without performance degradation
7. **Store Launch Ready**: Optimized for Apple App Store and Google Play submission

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.2.0+
- Dart 2.18.0+
- Android Studio / VS Code
- iOS/Android device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd GitaWisdom
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Hive adapters**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Configure Supabase**
   - Update `lib/main.dart` with your Supabase URL and anon key
   - Import database schema from `/supabase` folder

5. **Run the application**
   ```bash
   flutter run
   ```

### Build for Production
```bash
# Android
flutter build apk --release

# iOS  
flutter build ios --release
```

## 🧪 Testing

### Test Structure
```
test/
├── models/              # Model unit tests (all models with enhanced coverage)
├── services/            # Service layer tests (caching, settings, comprehensive)
├── screens/             # Widget tests for screens and navigation
├── utils/               # Test utilities and method channel mocks
├── widgets/             # Component tests (CustomNavBar, ExpandableText)
├── test_helpers.dart    # Common test setup and cleanup utilities
├── test_config.dart     # Test data and configuration
├── widget_test.dart     # Comprehensive widget integration tests
└── integration_test.dart # End-to-end caching and offline tests
```

### Run Tests
```bash
# All unit tests
flutter test

# Specific test suites
flutter test test/models/          # Model tests
flutter test test/services/        # Service tests  
flutter test test/screens/         # Screen tests
flutter test test/widget_test.dart # Widget integration tests

# Integration tests (caching and offline functionality)
flutter test test/integration_test.dart
```

## 🔧 Recent Bug Fixes & Improvements

### ✅ Latest Updates (August 2025)

#### 🚀 Store Launch Ready - v1.5.0 (August 20, 2025 - Performance Release)
- **Performance Optimization**: Implemented aggressive monthly caching reducing API calls by 97%
- **Permanent Caching**: Chapters and verses now permanently cached for instant loading
- **Enhanced UI**: Professional amber glow effects and improved text visibility
- **Crash Fixes**: Resolved Journal Entry Hive corruption and runtime errors
- **Complete Dataset**: Fixed scenario limit to cache all 1280 scenarios instead of 1000
- **Technical Details**:
  - Permanent caching for chapters (no re-fetching after first load)
  - Permanent caching for verses per chapter (instant loading)
  - Monthly scenario sync (30 days cache) instead of 6 hours
  - Fixed scenario fetch limit removing .range() constraints
  - Enhanced chapter header with professional amber glow effect
  - Improved scenarios filter text visibility in light mode
  - Fixed Journal Entry null safety preventing crashes
- **Scalability**: 50K users = 150K API calls/month vs 6M calls/month (97% reduction)
- **Store Launch**: Ready for Apple App Store and Google Play Store submission tonight
- **Deployment Status**: ✅ Performance optimized | ✅ All crashes fixed | ✅ Complete dataset cached

#### 🗂️ Category Consolidation & Database Optimization - v1.3.0 (August 18, 2025 - 14:30 UTC)
- **Major Update**: Consolidated 24+ scenario categories down to 10 streamlined main categories for better user experience
- **Database Optimization**: Updated 227 scenarios with underscore categories using proper PostgreSQL ARRAY syntax
- **Enhanced Tag System**: Implemented comprehensive tag-based sub-filtering within consolidated categories
- **Categories Consolidated**: 
  - `chronic_health_journey`, `food_culture_and_body_image` → **Health & Wellness**
  - `navigating_uncertainty_change` → **Life Transitions**  
  - `public_reputation_cancel_culture` → **Social & Community**
  - `queer_identity` → **Personal Growth**
  - `startup_founder_burnout` → **Work & Career**
  - `sustainable_minimalism` → **Modern Living**
- **UI Improvements**: Cleaner category navigation bar with proper scenario counts and filtering
- **Technical Details**:
  - Created comprehensive SQL migration scripts with real scenario IDs
  - Enhanced Flutter CategoryFilter with proper mappings
  - Implemented sub-category infrastructure for future tag-based filtering
  - Fixed database-app alignment issues causing zero scenario counts
- **User Experience**: Categories now display correct scenario counts and filtering works properly
- **Development Tools**: Created verification SQL scripts and consolidation documentation
- **Deployment Status**: ✅ Database migration ready | ✅ Flutter UI updated | ✅ Clean compilation

#### 🧭 Navigation State Synchronization Fix - v1.2.1 (August 17, 2025 - 23:45 UTC)
- **Critical Fix**: Resolved navigation state desynchronization issue where floating home buttons bypassed tab management
- **Problem Solved**: Floating home button from scenario detail view now properly syncs with bottom navigation state
- **Technical Details**: 
  - Fixed 7 screens with floating home buttons (`scenario_detail_view.dart`, `chapters_screen.dart`, `scenarios_screen.dart`, `more_screen.dart`, `about_screen.dart`, `references_screen.dart`, `verse_list_view.dart`)
  - Replaced direct `Navigator.pushAndRemoveUntil()` calls with proper `NavigationHelper.goToTab(0)` API
  - Added public `NavigationHelper.goToTab()` method to expose private tab management functionality
  - Maintained backward compatibility with all existing navigation workflows
- **User Experience**: Bottom navigation now correctly shows "Home" as active when using floating home buttons
- **Deployment Status**: ✅ iOS Release Build (40.8MB) | ✅ Android APK (72.3MB) | ✅ Android App Bundle (62.8MB)
- **Compilation Status**: Clean builds with no critical errors, ready for production deployment

### ✅ Previous Updates (January 2025)
- **Bulletproof Filtering System** - Comprehensive scenario filtering with 5 major categories (Life Stages, Relationships, Career & Work, Personal Growth, Modern Life)
- **Advanced Search Capabilities** - Compound search queries ("parenting stress", "work life balance") with intelligent matching
- **Smart Category Mapping** - Automatic tag-to-category mapping using extensive keyword libraries for 699+ scenarios
- **Production-Ready Optimization** - Removed debug statements, fixed compilation issues, enhanced performance
- **Future-Proof Architecture** - Extensible filtering system ready for new scenario categories
- **Fixed ListView rebuild assertion error** in journal screen that was causing crashes on Android
- **Fixed bottom navigation bug** - "View Scenarios" button from chapter details now properly switches to scenarios tab
- **Enhanced responsive design** - Improved pixel overflow handling for large text settings
- **Added swipe-to-delete** functionality for journal entries with confirmation dialogs
- **Improved theme-based backgrounds** - Replaced background images with gradient themes
- **Enhanced localization** - Full support for English, Spanish, and Hindi languages
- **Navigation flow improvements** - Seamless chapter-to-scenarios navigation with proper filtering

### 🐛 Known Issues Resolved
- ✅ **Comprehensive filtering system** - All scenario categories and tags now properly handled
- ✅ **Search functionality** - Advanced compound searches work across all scenario fields  
- ✅ **Category navigation** - Intelligent tag-to-category mapping for seamless user experience
- ✅ **Performance optimization** - Production-ready code with clean compilation
- ✅ ListView rebuild errors on Android devices
- ✅ Bottom navigation not switching when navigating from chapters to scenarios  
- ✅ Pixel overflow issues with large text accessibility settings
- ✅ Journal entry deletion with proper undo functionality
- ✅ Dark theme background consistency improvements

### 🔄 Development Workflow
The app follows modern Flutter development practices with:
- Hot reload for rapid development iteration
- Comprehensive testing suite for reliability
- Modular architecture for maintainability
- Cross-platform deployment for maximum reach

## 📱 Platform Support

- ✅ **Android** 7.0+ (API level 24+) - Recently tested and optimized
- ✅ **iOS** 11.0+  
- ✅ **Web** (Progressive Web App ready)
- ✅ **Desktop** (Windows, macOS, Linux)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style
- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful commit messages
- Add tests for new features
- Update documentation as needed

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Bhagavad Gita** - The eternal source of wisdom
- **A.C. Bhaktivedanta Swami Prabhupada** - "Bhagavad-gītā As It Is" translation
- **Flutter Team** - Amazing cross-platform framework
- **Supabase** - Backend-as-a-Service platform
- **Google Fonts** - Beautiful typography options

## 📞 Support

- **Email**: support@hub4apps.com
- **Website**: [https://hub4apps.com/](https://hub4apps.com/)  
- **Issues**: [GitHub Issues](https://github.com/your-username/GitaWisdom/issues)

---

> *"You have the right to perform your actions, but you are not entitled to the fruits of action."* - Bhagavad Gita 2.47

**Made with ❤️ for spiritual seekers everywhere**