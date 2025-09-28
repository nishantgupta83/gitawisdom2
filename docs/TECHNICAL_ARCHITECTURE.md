# 🏗️ GitaWisdom Technical Architecture

**Comprehensive Technical Documentation for External Audit and Development**

## Overview

GitaWisdom is a Flutter-based mobile application built with a sophisticated service-oriented architecture designed for scalability, performance, and maintainability. This document provides a detailed technical overview for external audits, code reviews, and developer onboarding.

## 📊 Architecture Summary

```
┌─────────────────────────────────────────────────────────────┐
│                    GitaWisdom Application                   │
├─────────────────┬─────────────────┬─────────────────────────┤
│   Presentation  │   Business      │        Data             │
│     Layer       │    Logic        │       Layer             │
│                 │    Layer        │                         │
│ • Screens       │ • Services      │ • Supabase Backend      │
│ • Widgets       │ • Providers     │ • Hive Local Storage    │
│ • Themes        │ • Controllers   │ • TFLite AI Models      │
│ • Navigation    │ • Managers      │ • File System Cache     │
└─────────────────┴─────────────────┴─────────────────────────┘
```

## 🚀 High-Level Architecture

### 1. **Client Architecture (Flutter App)**

```
GitaWisdom/
├── lib/
│   ├── core/                    # Foundation layer
│   │   ├── app_config.dart      # App configuration
│   │   ├── app_initializer.dart # Startup sequence
│   │   ├── theme/              # Theming system
│   │   ├── navigation/         # Navigation management
│   │   └── performance/        # Performance monitoring
│   ├── models/                 # Data models
│   │   ├── chapter.dart        # Gita chapter model
│   │   ├── scenario.dart       # Life scenario model
│   │   ├── journal_entry.dart  # User journal model
│   │   └── search_result.dart  # Search result model
│   ├── services/               # Business logic layer
│   │   ├── enhanced_supabase_service.dart
│   │   ├── intelligent_scenario_search.dart
│   │   ├── keyword_search_service.dart
│   │   ├── semantic_search_service.dart
│   │   └── background_music_service.dart
│   ├── screens/                # UI screens
│   │   ├── home_screen.dart
│   │   ├── chapters_screen.dart
│   │   ├── scenarios_screen.dart
│   │   ├── search_screen.dart
│   │   └── journal_screen.dart
│   └── widgets/                # Reusable UI components
└── assets/
    ├── fonts/                  # Google Fonts (Poppins)
    ├── images/                 # App icons and imagery
    └── audio/                  # Background music files
```

### 2. **Backend Architecture (Supabase)**

```
Supabase Infrastructure:
├── PostgreSQL Database
│   ├── chapters               # Bhagavad Gita chapters
│   ├── gita_verses           # Individual verses
│   ├── scenarios             # Life scenarios
│   └── user_data             # Authentication & profiles
├── Authentication
│   ├── Email/Password
│   ├── Anonymous Users
│   └── Social Login (Google, Apple)
├── Real-time Subscriptions
│   ├── Scenario Updates
│   ├── New Content Notifications
│   └── User Sync Events
└── Edge Functions
    ├── Content Moderation
    ├── Recommendation Engine
    └── Analytics Processing
```

## 🔧 Core Services Architecture

### 1. **Search System (AI-Powered)**

```
Intelligent Search Architecture:

┌─────────────────────────────────────────────────────────────┐
│                    Search Request                           │
│                         │                                   │
│                         ▼                                   │
│              ┌─────────────────────┐                        │
│              │ intelligent_scenario │                        │
│              │    _search.dart     │                        │
│              └─────────────────────┘                        │
│                         │                                   │
│                ┌────────┴────────┐                          │
│                ▼                 ▼                          │
│    ┌─────────────────┐  ┌─────────────────┐                │
│    │ keyword_search  │  │ semantic_search │                │
│    │ _service.dart   │  │ _service.dart   │                │
│    │                 │  │                 │                │
│    │ TF-IDF          │  │ TensorFlow Lite │                │
│    │ <50ms           │  │ ~100ms          │                │
│    │ Keyword Match   │  │ Semantic AI     │                │
│    └─────────────────┘  └─────────────────┘                │
│                ▲                 ▲                          │
│                │                 │                          │
│         ┌─────────────┐   ┌─────────────┐                  │
│         │ Local Index │   │ TFLite Model│                  │
│         │ (Hive)      │   │ (Assets)    │                  │
│         └─────────────┘   └─────────────┘                  │
└─────────────────────────────────────────────────────────────┘
```

**Performance Characteristics:**
- **Keyword Search**: <50ms response time
- **Semantic Search**: ~100ms response time
- **Fallback Strategy**: Keyword first, semantic if needed
- **Privacy**: 100% offline AI processing

### 2. **Data Layer Architecture**

```
Data Flow Architecture:

┌─────────────────────────────────────────────────────────────┐
│                    Data Sources                             │
│                                                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │  Supabase   │  │    Hive     │  │   Assets    │        │
│  │  (Cloud)    │  │  (Local)    │  │   (Static)  │        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
│         │                 │                 │              │
│         ▼                 ▼                 ▼              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │            Intelligent Caching Layer               │   │
│  │                                                     │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │   │
│  │  │ Progressive │  │ Smart Cache │  │ Background  │ │   │
│  │  │   Cache     │  │   Manager   │  │   Sync      │ │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘ │   │
│  └─────────────────────────────────────────────────────┘   │
│                            │                               │
│                            ▼                               │
│                 ┌─────────────────────┐                    │
│                 │   Service Layer     │                    │
│                 │                     │                    │
│                 │ • enhanced_supabase │                    │
│                 │ • scenario_service  │                    │
│                 │ • search_service    │                    │
│                 └─────────────────────┘                    │
└─────────────────────────────────────────────────────────────┘
```

### 3. **State Management Architecture**

```
State Management (Provider Pattern):

┌─────────────────────────────────────────────────────────────┐
│                    Widget Tree                              │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              MultiProvider                          │   │
│  │                                                     │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │   │
│  │  │ Settings    │  │ Theme       │  │ Auth        │ │   │
│  │  │ Provider    │  │ Provider    │  │ Provider    │ │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘ │   │
│  │                                                     │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │   │
│  │  │ Search      │  │ Music       │  │ Journal     │ │   │
│  │  │ Provider    │  │ Provider    │  │ Provider    │ │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘ │   │
│  └─────────────────────────────────────────────────────┘   │
│                            │                               │
│                            ▼                               │
│                 ┌─────────────────────┐                    │
│                 │    UI Screens       │                    │
│                 │                     │                    │
│                 │ Consumer<Service>() │                    │
│                 │ Selector<Service>() │                    │
│                 └─────────────────────┘                    │
└─────────────────────────────────────────────────────────────┘
```

## 💾 Database Design

### 1. **Supabase Schema**

```sql
-- Core Content Tables
CREATE TABLE chapters (
    id SERIAL PRIMARY KEY,
    chapter_number INTEGER NOT NULL,
    title TEXT NOT NULL,
    summary TEXT,
    verse_count INTEGER,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE gita_verses (
    id SERIAL PRIMARY KEY,
    chapter_id INTEGER REFERENCES chapters(id),
    verse_number INTEGER NOT NULL,
    sanskrit_text TEXT NOT NULL,
    english_translation TEXT NOT NULL,
    commentary TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE scenarios (
    id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    heart_response TEXT NOT NULL,
    duty_response TEXT NOT NULL,
    relevant_verses INTEGER[],
    category TEXT,
    difficulty_level INTEGER,
    monthly_featured BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- User Data Tables
CREATE TABLE user_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email TEXT UNIQUE,
    display_name TEXT,
    preferences JSONB,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE user_bookmarks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES user_profiles(id),
    content_type TEXT NOT NULL, -- 'verse', 'scenario', 'chapter'
    content_id INTEGER NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);
```

### 2. **Hive Local Storage**

```dart
// Local Storage Models (Hive)

@HiveType(typeId: 0)
class CachedChapter extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String summary;

  @HiveField(3)
  List<CachedVerse> verses;

  @HiveField(4)
  DateTime lastUpdated;
}

@HiveType(typeId: 1)
class CachedScenario extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  String heartResponse;

  @HiveField(4)
  String dutyResponse;

  @HiveField(5)
  List<int> relevantVerses;

  @HiveField(6)
  DateTime cacheTime;
}

@HiveType(typeId: 2)
class SearchIndex extends HiveObject {
  @HiveField(0)
  Map<String, List<int>> termFrequency;

  @HiveField(1)
  Map<int, double> documentFrequency;

  @HiveField(2)
  DateTime lastBuilt;
}
```

## 🎯 Performance Architecture

### 1. **Caching Strategy**

```
Multi-Layer Caching System:

┌─────────────────────────────────────────────────────────────┐
│                   Cache Hierarchy                           │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              L1: Memory Cache                       │   │
│  │  • Active screen data                               │   │
│  │  • Recently accessed items                          │   │
│  │  • Search results                                   │   │
│  │  • TTL: 5-10 minutes                               │   │
│  └─────────────────────────────────────────────────────┘   │
│                            │                               │
│                            ▼                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              L2: Hive Persistent Cache              │   │
│  │  • Chapters and verses                              │   │
│  │  • User bookmarks                                   │   │
│  │  • Search indices                                   │   │
│  │  • TTL: 24 hours                                   │   │
│  └─────────────────────────────────────────────────────┘   │
│                            │                               │
│                            ▼                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              L3: Progressive Cache                  │   │
│  │  • Scenarios (monthly refresh)                      │   │
│  │  • Non-critical content                             │   │
│  │  • Background downloaded                            │   │
│  │  • TTL: 30 days                                    │   │
│  └─────────────────────────────────────────────────────┘   │
│                            │                               │
│                            ▼                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              L4: Supabase Backend                   │   │
│  │  • Authoritative data source                        │   │
│  │  • Real-time updates                               │   │
│  │  • Analytics and metrics                           │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### 2. **Performance Monitoring**

```dart
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  // Performance Metrics
  Map<String, Duration> operationTimes = {};
  Map<String, int> memoryUsage = {};
  List<FrameRenderMetric> frameMetrics = [];

  // Monitor search performance
  Future<T> monitorOperation<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    final stopwatch = Stopwatch()..start();
    final T result = await operation();
    stopwatch.stop();

    operationTimes[operationName] = stopwatch.elapsed;
    _logPerformance(operationName, stopwatch.elapsed);

    return result;
  }

  // Performance thresholds
  static const Duration SEARCH_THRESHOLD = Duration(milliseconds: 100);
  static const Duration UI_RENDER_THRESHOLD = Duration(milliseconds: 16);
  static const int MEMORY_THRESHOLD_MB = 80;
}
```

## 🔒 Security Architecture

### 1. **Authentication Flow**

```
Authentication Architecture:

┌─────────────────────────────────────────────────────────────┐
│                 Authentication Flow                         │
│                                                             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐     │
│  │    User     │───▶│    App      │───▶│  Supabase   │     │
│  │  Interaction│    │  Auth UI    │    │    Auth     │     │
│  └─────────────┘    └─────────────┘    └─────────────┘     │
│                             │                 │             │
│                             ▼                 ▼             │
│                    ┌─────────────┐    ┌─────────────┐       │
│                    │ Simple Auth │    │    JWT      │       │
│                    │  Service    │    │   Tokens    │       │
│                    └─────────────┘    └─────────────┘       │
│                             │                 │             │
│                             ▼                 ▼             │
│                    ┌─────────────────────────────────┐      │
│                    │       Local Storage            │      │
│                    │                                │      │
│                    │ • Encrypted user tokens        │      │
│                    │ • Secure session management    │      │
│                    │ • Biometric integration        │      │
│                    └─────────────────────────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

### 2. **Data Privacy**

```dart
class PrivacyManager {
  // Ensure AI processing is 100% offline
  static bool get isOfflineProcessing => true;

  // Data encryption for sensitive information
  String encryptSensitiveData(String data) {
    // Implementation uses Flutter's crypto libraries
    return _encrypt(data);
  }

  // GDPR compliance helpers
  Future<void> exportUserData(String userId) async {
    // Export all user data in portable format
  }

  Future<void> deleteAllUserData(String userId) async {
    // Complete data deletion per GDPR requirements
  }

  // Privacy-first analytics
  void trackEvent(String eventName, Map<String, dynamic> parameters) {
    // Remove all PII before tracking
    final sanitizedParams = _removePII(parameters);
    _analyticsService.track(eventName, sanitizedParams);
  }
}
```

## 🚀 Deployment Architecture

### 1. **Build Pipeline**

```
CI/CD Pipeline:

┌─────────────────────────────────────────────────────────────┐
│                    Development                              │
│                                                             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐     │
│  │   Git Push  │───▶│  Unit Tests │───▶│ Integration │     │
│  │             │    │             │    │    Tests    │     │
│  └─────────────┘    └─────────────┘    └─────────────┘     │
│                                                │            │
│                                                ▼            │
│                                      ┌─────────────┐       │
│                                      │ Performance │       │
│                                      │   Tests     │       │
│                                      └─────────────┘       │
│                                                │            │
│                                                ▼            │
│                                      ┌─────────────┐       │
│                                      │   Build     │       │
│                                      │   Parallel  │       │
│                                      └─────────────┘       │
│                                                │            │
│                    ┌─────────────────────────────────────┐  │
│                    ▼                                     ▼  │
│            ┌─────────────┐                     ┌─────────────┐
│            │  Android    │                     │     iOS     │
│            │    APK      │                     │    IPA      │
│            └─────────────┘                     └─────────────┘
│                    │                                     │
│                    ▼                                     ▼
│            ┌─────────────┐                     ┌─────────────┐
│            │ Google Play │                     │ App Store   │
│            │   Store     │                     │             │
│            └─────────────┘                     └─────────────┘
└─────────────────────────────────────────────────────────────┘
```

### 2. **Environment Configuration**

```dart
class AppConfig {
  static const String environment = String.fromEnvironment('ENV', defaultValue: 'dev');

  static const Map<String, Config> configs = {
    'dev': Config(
      supabaseUrl: 'https://dev.supabase.co',
      supabaseKey: 'dev-key',
      enableDebugMode: true,
      enablePerformanceMonitoring: true,
    ),
    'staging': Config(
      supabaseUrl: 'https://staging.supabase.co',
      supabaseKey: 'staging-key',
      enableDebugMode: false,
      enablePerformanceMonitoring: true,
    ),
    'production': Config(
      supabaseUrl: 'https://prod.supabase.co',
      supabaseKey: 'prod-key',
      enableDebugMode: false,
      enablePerformanceMonitoring: false,
    ),
  };

  static Config get current => configs[environment]!;
}
```

## 📱 Platform-Specific Architecture

### 1. **iOS Integration**

```swift
// iOS-specific optimizations
class iOSPerformanceOptimizer {
    // Metal GPU acceleration for AI processing
    func optimizeForMetal() {
        // Configure Metal shaders for TensorFlow Lite
    }

    // ProMotion display optimization
    func configureProMotionDisplay() {
        // 120Hz display optimization
    }

    // Background app refresh management
    func configureBackgroundRefresh() {
        // Intelligent background sync
    }
}
```

### 2. **Android Integration**

```kotlin
// Android-specific optimizations
class AndroidPerformanceOptimizer {
    // GPU acceleration configuration
    fun optimizeForVulkan() {
        // Configure Vulkan API for AI processing
    }

    // Memory management
    fun configureLowMemoryHandling() {
        // Handle Android's memory pressure
    }

    // Background processing optimization
    fun configureWorkManager() {
        // Efficient background task management
    }
}
```

## 🔍 Testing Architecture

### 1. **Test Strategy**

```
Testing Pyramid:

┌─────────────────────────────────────────────────────────────┐
│                   Testing Strategy                          │
│                                                             │
│                     ┌─────────────┐                        │
│                     │   E2E Tests │                        │
│                     │     (5%)    │                        │
│                     └─────────────┘                        │
│                  ┌─────────────────────┐                   │
│                  │  Integration Tests  │                   │
│                  │       (15%)         │                   │
│                  └─────────────────────┘                   │
│              ┌─────────────────────────────────┐           │
│              │        Unit Tests               │           │
│              │          (80%)                  │           │
│              └─────────────────────────────────┘           │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              Test Categories                        │   │
│  │                                                     │   │
│  │  • Service Layer Tests                              │   │
│  │  • Widget Tests                                     │   │
│  │  • Performance Tests                                │   │
│  │  • Security Tests                                   │   │
│  │  • Accessibility Tests                              │   │
│  │  • Platform-specific Tests                          │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### 2. **Automated Testing**

```dart
// Automated test suite examples
class SearchServiceTest extends TestCase {
  @test
  void testKeywordSearchPerformance() async {
    final stopwatch = Stopwatch()..start();
    final results = await keywordSearchService.search('dharma');
    stopwatch.stop();

    expect(stopwatch.elapsedMilliseconds, lessThan(50));
    expect(results.length, greaterThan(0));
  }

  @test
  void testSemanticSearchAccuracy() async {
    final results = await semanticSearchService.search('life purpose');
    final relevantResults = results.where((r) => r.relevanceScore > 0.7);

    expect(relevantResults.length, greaterThan(0));
  }
}
```

## 📊 Analytics Architecture

### 1. **Privacy-First Analytics**

```dart
class AnalyticsService {
  // Track user engagement without PII
  void trackScreenView(String screenName) {
    _analytics.logEvent('screen_view', {
      'screen_name': screenName,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'session_id': _anonymousSessionId,
    });
  }

  // Performance metrics tracking
  void trackPerformanceMetric(String operation, Duration duration) {
    _analytics.logEvent('performance_metric', {
      'operation': operation,
      'duration_ms': duration.inMilliseconds,
      'device_type': Platform.isIOS ? 'ios' : 'android',
    });
  }

  // Feature usage analytics
  void trackFeatureUsage(String feature, Map<String, dynamic> context) {
    final sanitizedContext = _removePII(context);
    _analytics.logEvent('feature_usage', {
      'feature': feature,
      'context': sanitizedContext,
    });
  }
}
```

## 🔧 Maintenance & Monitoring

### 1. **Health Monitoring**

```dart
class AppHealthMonitor {
  // Real-time app health metrics
  Map<String, dynamic> getHealthMetrics() {
    return {
      'memory_usage_mb': _getMemoryUsage(),
      'cache_hit_ratio': _getCacheHitRatio(),
      'search_performance_ms': _getAverageSearchTime(),
      'crash_count': _getCrashCount(),
      'user_session_duration': _getAverageSessionDuration(),
    };
  }

  // Proactive issue detection
  void monitorForIssues() {
    if (_getMemoryUsage() > MEMORY_THRESHOLD) {
      _triggerMemoryCleanup();
    }

    if (_getAverageSearchTime() > SEARCH_PERFORMANCE_THRESHOLD) {
      _optimizeSearchIndices();
    }
  }
}
```

## 🚀 Scalability Considerations

### 1. **Horizontal Scaling**

- **Stateless Services**: All services designed to be stateless
- **Database Scaling**: Supabase handles database scaling automatically
- **CDN Integration**: Static assets served via CDN
- **Caching Strategy**: Multi-layer caching reduces backend load

### 2. **Performance Optimization**

- **Lazy Loading**: Components loaded on-demand
- **Code Splitting**: Platform-specific code separation
- **Asset Optimization**: Images and audio compressed
- **Bundle Analysis**: Regular analysis of app bundle size

## 📋 Technical Debt Management

### 1. **Code Quality Metrics**

```dart
class CodeQualityMonitor {
  // Cyclomatic complexity monitoring
  int calculateComplexity(String fileName) {
    // Analyze code complexity
  }

  // Technical debt tracking
  List<TechnicalDebtItem> identifyTechnicalDebt() {
    return [
      // TODO items
      // Code duplications
      // Performance bottlenecks
      // Security vulnerabilities
    ];
  }
}
```

## 🔐 Security Best Practices

### 1. **Data Protection**

- **Encryption at Rest**: All sensitive data encrypted in Hive
- **Encryption in Transit**: HTTPS/TLS for all network communication
- **Token Management**: Secure JWT token storage and rotation
- **Input Validation**: All user inputs sanitized and validated

### 2. **Privacy Compliance**

- **GDPR Compliance**: User data export and deletion capabilities
- **Data Minimization**: Only essential data collected
- **Consent Management**: Clear user consent for data processing
- **Audit Trails**: Complete audit logs for data access

---

## 📞 Support & Contact

**Technical Architecture Questions:**
- **Email**: tech@hub4apps.com
- **Documentation**: https://docs.gitawisdom.app/architecture
- **GitHub Issues**: https://github.com/nishantgupta83/gitawisdom2/issues

**Code Review & Audit:**
- **Architecture Review**: Available upon request
- **Security Audit**: Third-party security assessments welcome
- **Performance Analysis**: Detailed performance reports available

---

**© 2024 Hub4Apps. Confidential Technical Documentation.**

*This document contains proprietary technical information. External sharing requires explicit authorization.*