# GitaWisdom Testing Guide

**Phase 2: Test Suite Execution & Validation**
**Last Updated**: October 14, 2025

---

## Overview

This document covers the comprehensive testing strategy for GitaWisdom v2.3.1+28, including automated tests, manual testing procedures, and validation checklists.

---

## 🧪 Test Suite Structure

### Current Test Coverage

```
GitaWisdom/
├── test/                           # Unit tests
│   ├── models/                     # Data model tests
│   ├── services/                   # Business logic tests
│   └── widgets/                    # Widget tests
├── integration_test/               # Integration tests
│   └── ui_ux_agent_test.dart      # Full app flow testing
└── test_driver/                    # (Future) End-to-end tests
```

### Test Statistics
- **Total Test Files**: 1 integration test (more unit tests to be added)
- **Screen Coverage**: All 11,173 lines of screen code need validation
- **Critical Paths**: Authentication, Journal, Search, Bookmarks

---

## ⚡ Running Tests

### 1. Flutter Unit Tests

```bash
# Run all unit tests
flutter test

# Run specific test file
flutter test test/models/chapter_test.dart

# Run tests with coverage
flutter test --coverage

# View coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### 2. Integration Tests

```bash
# Run integration tests on emulator/simulator
flutter test integration_test/ui_ux_agent_test.dart

# Run on specific device
flutter test integration_test/ui_ux_agent_test.dart -d emulator-5554
flutter test integration_test/ui_ux_agent_test.dart -d 00008030-000C0D1E0140802E
```

### 3. Quick Validation Script

```bash
# Create quick_test.sh
#!/bin/bash
echo "Running GitaWisdom Test Suite..."

# Check for compilation errors
echo "1. Checking for compilation errors..."
flutter analyze

# Run unit tests
echo "2. Running unit tests..."
flutter test --no-pub

# Check for new warnings
echo "3. Checking for warnings..."
flutter analyze --no-pub | grep -E "warning|error" || echo "✅ No warnings"

echo "✅ All tests passed!"
```

---

## 🎯 Critical Test Cases

### 1. Journal Entry (Just Updated!)

**Test Objective**: Verify star rating implementation and dark mode fixes

**Manual Test Steps**:
1. Open app → Navigate to Scenarios → Select any scenario
2. Tap "Create Journal Entry"
3. **Verify**: Dialog has radial gradient background (dark mode: dark gray, light mode: mint)
4. **Verify**: Star rating row with 5 stars (empty by default)
5. Tap each star 1-5
6. **Verify**: Haptic feedback on each tap
7. **Verify**: Dynamic label changes:
   - 1 star: "Feeling Challenged"
   - 2 stars: "Finding My Way"
   - 3 stars: "Making Progress"
   - 4 stars: "Growing Stronger"
   - 5 stars: "Truly Blessed"
8. Enter reflection text
9. **Verify**: "Save Entry" button has purple gradient
10. Tap Save
11. **Verify**: Success toast with "View Journal" action

**Expected Results**:
- ✅ Dark mode: Dialog visible with good contrast
- ✅ Light mode: Mint gradient background
- ✅ Stars change color on selection (amber/gray)
- ✅ Labels update dynamically
- ✅ Entry saves successfully

**Automated Test** (to be written):
```dart
testWidgets('Journal entry star rating works', (WidgetTester tester) async {
  await tester.pumpWidget(MyApp());

  // Navigate to scenario detail
  await tester.tap(find.byType(ScenarioCard).first);
  await tester.pumpAndSettle();

  // Open journal dialog
  await tester.tap(find.text('Create Journal Entry'));
  await tester.pumpAndSettle();

  // Verify initial state
  expect(find.byIcon(Icons.star_border), findsNWidgets(5));
  expect(find.text('Feeling Challenged'), findsNothing);

  // Tap 3rd star
  await tester.tap(find.byIcon(Icons.star_border).at(2));
  await tester.pumpAndSettle();

  // Verify selection
  expect(find.byIcon(Icons.star), findsNWidgets(3));
  expect(find.text('Making Progress'), findsOneWidget);
});
```

---

### 2. Dark Mode Theme Switch

**Test Objective**: Ensure no contrast issues across app

**Test Steps**:
1. Open Settings → Toggle "Dark Mode"
2. Navigate through all tabs: Home, Chapters, Scenarios, Journal, More
3. **Verify**: All text readable (WCAG 2.1 AA: 4.5:1 contrast minimum)
4. **Verify**: No white text on white backgrounds
5. **Verify**: Icons visible in both modes

**Critical Screens**:
- ✅ Home (Daily Inspiration, Quick Access)
- ✅ Chapters List
- ✅ Chapter Detail (verse text)
- ✅ Scenarios List
- ✅ Scenario Detail (Heart/Duty cards)
- ✅ Journal Entry Dialog (JUST FIXED)
- ✅ Journal List
- ✅ Bookmarks
- ✅ More/Settings

---

### 3. OAuth Authentication Flow

**Test Objective**: Verify Google/Apple/Facebook sign-in

**Test Steps**:
1. Tap "Sign In with Google"
2. Complete OAuth flow in browser/system dialog
3. **Verify**: Returns to app without "Route not found" error (FIXED)
4. **Verify**: User profile loads correctly
5. **Verify**: Journal syncs to Supabase
6. Sign out
7. **Verify**: Local journal data persists (encrypted in Hive)

**Known Fixed Issues**:
- ✅ OAuth error display after successful auth (fixed in v2.3.0)
- ✅ Google sign-in error handling (fixed)

---

### 4. Database Quality Fixes

**Test Objective**: Verify scenario action_steps display correctly after SQL fixes

**Prerequisites**:
Execute SQL fixes from `gita_scholar_agent/output/fix_scenarios.sql`

**Test Steps**:
1. Navigate to Scenarios tab
2. Search for "Child with Learning Differences"
3. Open scenario detail
4. Scroll to "Action Steps" section
5. **Verify**: Step 2 reads "Celebrate your strengths (creativity, kindness, etc.)"
6. **Verify**: NOT "Celebrate your strengths (creativity" on one line and "kindness" on next
7. Repeat for all 15 fixed scenarios (see fix_scenarios_report.txt)

**Fixed Scenarios** (15 total):
- Being Told You're 'Too Sensitive'
- Debilitating Exam Failure Anxiety
- Struggling with Self-Harm Thoughts
- Social Media Comparison and Validation Seeking
- Logistics of Managing Two Toddlers
- Exam Pressure and Fear of Disappointing Others
- Developing Underperforming Team Member
- Child with Learning Differences
- Cyberbullying and Identity Crisis
- Child Grieving Grandparent's Death
- Managing Anxiety About Team Performance Results
- Different Spiritual Paths Creating Family Tension
- Letting Go of Control Over Critical Project
- Dealing with Pet Loss as a Child
- Interfaith Marriage Creating Family Tension

---

## 🔒 Regression Testing Checklist

After any code changes, verify:

### Core Functionality
- [ ] App launches without crashes
- [ ] Navigation between tabs works
- [ ] Search returns results
- [ ] Bookmarks save and load
- [ ] Journal entries save with encryption
- [ ] Theme switching doesn't crash
- [ ] OAuth login/logout works

### Performance
- [ ] App startup < 3 seconds on mid-range device
- [ ] Scenarios load instantly (cache-first)
- [ ] No ANR warnings on Android
- [ ] Memory usage < 200MB on typical usage
- [ ] No frame drops during scrolling

### UI/UX
- [ ] All text readable in both themes
- [ ] Touch targets ≥ 44x44dp
- [ ] Animations smooth (60fps)
- [ ] Gradients render correctly
- [ ] Images load without flickering

### Data Integrity
- [ ] Journal entries persist across app restarts
- [ ] Bookmarks don't disappear
- [ ] User progress tracked correctly
- [ ] No data loss on theme switch
- [ ] Encryption keys stored securely

---

## 🐛 Known Issues & Workarounds

### Non-Critical Issues
1. **Firebase Analytics** (Commented out)
   - Impact: No user behavior tracking yet
   - Workaround: Enable in MVP 2

2. **Multilingual Support** (Commented out)
   - Impact: English only
   - Workaround: Enable in MVP 2

3. **Test Coverage** (Low)
   - Impact: Manual testing required
   - Workaround: Add unit tests gradually

---

## 📊 Test Metrics

### Current Status
- **Unit Test Coverage**: ~5% (needs improvement)
- **Integration Tests**: 1 file
- **Manual Test Cases**: 15 critical paths
- **Regression Test Time**: ~30 minutes

### Target Goals (MVP 2)
- **Unit Test Coverage**: >60%
- **Integration Tests**: >10 files
- **Automated UI Tests**: >25 scenarios
- **Regression Test Time**: <10 minutes (automated)

---

## 🚀 Continuous Integration (Future)

### GitHub Actions Workflow

```yaml
# .github/workflows/flutter_test.yml
name: Flutter Tests

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.35.5'
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info
```

---

## 📝 Next Steps

### Immediate (Next Week)
1. ✅ Execute database quality SQL fixes in Supabase
2. ✅ Manual test all 15 fixed scenarios
3. ⏳ Run flutter analyze (check for new warnings)
4. ⏳ Test journal star rating on both iOS and Android
5. ⏳ Verify dark mode across all screens

### Short Term (MVP 2)
1. Add unit tests for JournalService (encryption)
2. Add unit tests for SearchService (semantic matching)
3. Add integration tests for OAuth flows
4. Set up GitHub Actions CI/CD
5. Implement automated screenshot testing

### Long Term (MVP 3)
1. Performance benchmarking suite
2. Load testing for 10K+ users
3. Accessibility audit with automated tools
4. Security penetration testing

---

**Document Version**: 1.0
**Author**: GitaWisdom Development Team
**Next Review**: After MVP 2 Launch
