# GitaWisdom MVP Roadmap

**Current Version**: v2.3.1+28 (MVP 1 Complete)
**Last Updated**: October 14, 2025

---

## 🎯 MVP 1: Core Product (SHIPPED ✅)

**Status**: Live on Google Play Store | iOS App Store Ready
**Users**: Closed testing with positive feedback
**Features**: Complete and production-ready

### Shipped Features

**Core Content**
- ✅ 18 Bhagavad Gita chapters with full text and summaries
- ✅ 1,226 real-world scenarios with Heart vs Duty guidance
- ✅ 700+ Gita verses with chapter context
- ✅ Daily inspiration carousel (31 rotating quotes)

**User Experience**
- ✅ Personal journal with star ratings and emoji hints
- ✅ OAuth authentication (Google, Apple, Facebook)
- ✅ Bookmark system for verses and scenarios
- ✅ Search with semantic matching
- ✅ Dark/light theme with gradient aesthetics
- ✅ Offline-first architecture with Hive caching
- ✅ Background meditation audio

**Platform & Compliance**
- ✅ iOS and Android production builds
- ✅ Google Play 2024 compliance (account deletion, encryption)
- ✅ AES-256 journal encryption
- ✅ Android 13+ runtime permissions
- ✅ WCAG 2.1 AA accessibility compliance
- ✅ ProMotion battery optimization (iOS)

**Performance Metrics**
- ✅ 70% faster app startup
- ✅ 97% API call reduction through caching
- ✅ 66% memory optimization
- ✅ Instant scenario loading (cache-first)

---

## 📊 MVP 2: Growth & Engagement (PLANNED)

**Target**: Q1 2026
**Focus**: User retention and data-driven improvements
**Implementation**: Feature flags (code merged but disabled)

### Planned Features

#### 1. Firebase Analytics Integration (Priority: HIGH)
**Timeline**: 1-2 weeks
**Status**: Dependencies ready (commented in pubspec.yaml)

**Features**:
- User behavior tracking (screen views, session duration)
- Scenario engagement metrics (most viewed, bookmarked)
- Journal entry patterns (frequency, ratings distribution)
- Search query analysis (popular terms, semantic match rates)
- Conversion tracking (guest → authenticated users)

**Implementation Strategy**:
```dart
// Feature flag in lib/core/feature_flags.dart
class FeatureFlags {
  static const FIREBASE_ANALYTICS = false; // Enable when ready
}

// Wrapped analytics calls
if (FeatureFlags.FIREBASE_ANALYTICS) {
  FirebaseAnalytics.logEvent(name: 'scenario_viewed', parameters: {...});
}
```

**Success Metrics**:
- DAU/MAU ratio > 25%
- Average session duration > 5 minutes
- Scenario engagement rate > 40%

---

#### 2. Multilingual Support (Priority: HIGH)
**Timeline**: 3-5 weeks
**Status**: Database structure ready, code marked with MULTILANG_TODO

**Features**:
- 15 languages supported (database schema exists)
- Automatic language detection
- In-app language switcher
- Translated scenarios, verses, and UI
- RTL support for Arabic/Hebrew

**Implementation Strategy**:
- Restore MULTILANG_TODO code blocks in `enhanced_supabase_service.dart`
- Add SupportedLanguage model (already exists, commented out)
- Build language switcher UI (hidden if flag OFF)
- Test with Hindi, Spanish, German initially

**Technical Details**:
```dart
// Database already has columns:
// scenarios: title_en, title_hi, title_es, title_de...
// gita_verses: text_en, text_hi, text_es, text_de...

// SupportedLanguage model exists at:
// lib/models/supported_language.dart (currently commented)
```

**Success Metrics**:
- 20% of users switch from default language
- 30% growth in non-English speaking regions

---

#### 3. Dynamic Inspirations Database (Priority: MEDIUM)
**Timeline**: 1 week
**Status**: Currently hardcoded in home_screen.dart (31 quotes)

**Features**:
- Database-driven daily quotes
- Admin panel for quote management
- A/B testing different quote styles
- User-favorite quotes
- Category-based quotes (morning, evening, challenges)

**Implementation**:
```sql
-- Create Supabase table
CREATE TABLE daily_inspirations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  quote_text TEXT NOT NULL,
  source TEXT NOT NULL,
  category TEXT NOT NULL,
  language VARCHAR(5) DEFAULT 'en',
  is_active BOOLEAN DEFAULT TRUE,
  display_order INT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Migration Plan**:
- Migrate 31 existing hardcoded quotes to database
- Add 20 new quotes per category
- Implement fallback to hardcoded quotes if database unavailable

---

#### 4. Bookmark Enhancements (Priority: MEDIUM)
**Timeline**: 2 weeks
**Status**: TODO markers in bookmarks_screen.dart

**Features**:
- ✏️ Edit notes and tags on bookmarks
- 📤 Export bookmarks (JSON, PDF, text)
- ↩️ Undo delete action (5-second snackbar)
- 🔍 Search within bookmarks
- 📁 Bookmark collections/folders

**Implementation Locations**:
- `lib/screens/bookmarks_screen.dart:233` - Edit dialog TODO
- `lib/screens/bookmarks_screen.dart:358` - Export functionality TODO
- `lib/screens/bookmarks_screen.dart:425` - Undo action TODO

---

#### 5. Sub-Category Filtering (Priority: LOW)
**Timeline**: 1 week
**Status**: TODO marker in scenarios_screen.dart

**Features**:
- Filter scenarios by sub-categories
- "Career Growth", "Relationships", "Ethics", etc.
- Chip-based UI for quick filtering
- Save filter preferences

**Implementation**:
- Database: `scenarios.sc_category` already exists
- UI: TODO at `lib/screens/scenarios_screen.dart:47`
- Add sub_category_mapper.dart for category organization

---

## 🌟 MVP 3: Community & Personalization (VISION)

**Target**: Q2-Q3 2026
**Focus**: Power users and community features
**Status**: Conceptual (no code written)

### Envisioned Features

#### 1. User-Generated Content
- Share personal scenarios for community review
- Wisdom contributions from users
- Moderation system with AI-assisted flagging
- Reputation scoring for contributors

#### 2. Personalized Recommendations
- ML-based scenario suggestions based on reading history
- Adaptive content delivery (morning motivation, evening reflection)
- Progress tracking with milestone celebrations
- Learning path recommendations

#### 3. Social Features
- Anonymous journal insight sharing (opt-in)
- Discussion forums moderated by chapter
- Mentor matching for spiritual guidance
- Community challenges (30-day gratitude, etc.)

#### 4. Advanced Analytics Dashboard
- Personal growth metrics visualization
- Spiritual journey heatmaps
- Goal tracking with Gita-based milestones
- Weekly wisdom digest

#### 5. Premium Features (Monetization)
- Exclusive premium scenarios (50 new per month)
- One-on-one wisdom consultations
- Ad-free experience
- Early access to new features
- Custom theme builder

---

## 🏗️ Implementation Strategy

### Feature Flag Architecture

**Core Principle**: Build MVP2 features in same codebase, hidden behind flags

**Implementation**:
```dart
// lib/core/feature_flags.dart
class FeatureFlags {
  // MVP 2 flags
  static const FIREBASE_ANALYTICS = false;
  static const MULTILINGUAL_SUPPORT = false;
  static const DYNAMIC_INSPIRATIONS = false;
  static const BOOKMARK_ADVANCED = false;
  static const SUB_CATEGORIES = false;

  // Remote config support (future)
  static Future<void> loadFromRemote() async {
    // Load flags from Firebase Remote Config
  }
}
```

### Branch Strategy
- `main` - Production (all flags OFF)
- `feature/mvp2-analytics` - Firebase analytics work
- `feature/mvp2-multilang` - Language support
- `feature/mvp2-*` - Other MVP2 features

### Testing Strategy
1. **Local Testing**: Enable flags in dev environment
2. **Staging**: Test flag combinations
3. **Gradual Rollout**: Enable flags for 10% → 50% → 100% users
4. **A/B Testing**: Compare engagement with/without features

### Deployment Safety
- ✅ No code removal when merging
- ✅ Production stays stable (flags OFF)
- ✅ Enable features remotely when ready
- ✅ Instant rollback by toggling flags

---

## 📈 Success Metrics

### MVP 1 (Achieved)
- ✅ 500+ closed testing users
- ✅ 4.7+ star rating
- ✅ Zero critical bugs in 2 weeks
- ✅ Google Play compliance passed

### MVP 2 (Target)
- 5,000+ active users
- 30% DAU/MAU ratio
- 25% increase in session duration
- 15% growth in non-English markets
- 50% bookmark usage rate

### MVP 3 (Vision)
- 50,000+ active users
- 10,000+ community contributions
- 5% conversion to premium
- $5,000 MRR (Monthly Recurring Revenue)

---

## 🚀 Next Steps

### Immediate (Next 2 Weeks)
1. Create `lib/core/feature_flags.dart`
2. Uncomment Firebase dependencies in `pubspec.yaml`
3. Wrap analytics calls with feature flags
4. Test analytics locally with flag enabled
5. Deploy with flags OFF

### Short Term (1-2 Months)
1. Complete Firebase Analytics integration
2. Begin multilingual support restoration
3. Migrate daily inspirations to database
4. Implement bookmark enhancements

### Long Term (3-6 Months)
1. Enable MVP2 features gradually
2. Monitor metrics and gather user feedback
3. Plan MVP3 architecture
4. Explore monetization strategies

---

## 📞 Communication with Users

### Announcement Strategy

**Title**: "What's Next for GitaWisdom: Your Journey Continues"

**Message**:
> Thank you for being part of our community! GitaWisdom v2.3 brings you:
> - ✅ 1,226 wisdom-filled scenarios
> - ✅ Personal journal with beautiful new star ratings
> - ✅ Enhanced dark mode for peaceful nighttime reflection
> - ✅ Secure encryption for your private thoughts
>
> **Coming Soon in 2026**:
> - 🌍 15 languages to reach seekers worldwide
> - 📊 Personalized insights to track your growth
> - 🎯 Advanced bookmark organization
> - 🤝 Community features to connect with fellow travelers
>
> Stay tuned! Your feedback shapes our journey.

---

**Document Version**: 1.0
**Author**: GitaWisdom Development Team
**Contact**: https://github.com/nishantgupta83/gitawisdom2
