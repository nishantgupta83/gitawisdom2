# GitaWisdom App Testing Guide
**For Internal Testers - Basic UI and Functionality**

## 📱 Overview
This guide helps you test the main features of GitaWisdom app. No technical knowledge required - just follow the steps and report what you see!



## 🎯 What to Test
We want to make sure these core features work smoothly:
1. **Navigation** - Moving around the app
2. **Scenarios** - Heart vs Duty guidance
3. **Chapters** - Gita chapter browsing
4. **Settings** - App customization

---

## 🚀 Getting Started

### First Launch
1. **Install and open** the GitaWisdom app
2. **Expected**: App opens with a beautiful background and home screen
3. **Check**: 
   - App loads without crashing
   - You can see the main content
   - Bottom navigation bar is visible
   - Music starts playing (if enabled)

### Initial Setup
1. **Look for**: Welcome content or daily verse
2. **Expected**: You should see inspiring content immediately
3. **Report if**: App is blank, shows errors, or takes too long to load

---

## 🧭 Navigation Testing

### Bottom Navigation Bar
Test each tab by tapping them:

1. **🏠 Home Tab**
   - **Expected**: Daily verses, modern dilemmas carousel
   - **Test**: Swipe through different verses and scenarios

2. **📚 Chapters Tab**
   - **Expected**: List of 18 Gita chapters with titles
   - **Test**: Tap on any chapter to see details

3. **🎭 Scenarios Tab**
   - **Expected**: Categories like Family, Career, Relationships
   - **Test**: Tap categories to see scenario lists

4. **⚙️ More Tab**
   - **Expected**: Settings, about, references
   - **Test**: Check each menu option

### Navigation Issues to Report:
- ❌ Tabs don't respond to taps
- ❌ Wrong content appears
- ❌ App crashes when switching tabs
- ❌ Bottom bar is cut off or hidden

---

## 🎭 Scenarios Testing (Main Feature)

### Accessing Scenarios
1. **From Home**: Tap scenarios in the "Modern Dilemma" section
2. **From Scenarios Tab**: Browse by categories

### Testing Heart vs Duty Feature
1. **Select any scenario** (example: workplace conflict)
2. **Expected to see**:
   - Clear scenario description
   - **"What Your Heart Says"** section ❤️
   - **"What Duty Demands"** section ⚖️
   - **"Ancient Wisdom Says"** section 📖
   - **"Wisdom Steps"** section 📝

### Test Cases:
1. **Family Scenarios**
   - Open family category
   - Read 2-3 different scenarios
   - Check if guidance makes sense

2. **Relationship Scenarios**
   - Check love/friendship situations
   - Ensure wisdom is appropriate

### Scenario Issues to Report:
- ❌ Scenarios don't load
- ❌ Missing heart/duty/wisdom sections
- ❌ Text is unreadable or cut off
- ❌ Categories are empty
- ❌ App crashes when opening scenarios
---
## ⚙️ Settings & Customization

### Theme Testing
1. **Go to More → Settings**
2. **Test Dark/Light mode**:
   - Switch themes
   - Check if text remains readable
   - Verify all screens look good

### Audio Testing
1. **Find background music toggle**
2. **Test**: Turn music on/off
3. **Expected**: Music should start/stop immediately


### Settings Issues to Report:
- ❌ Settings don't save
- ❌ Theme changes don't work
- ❌ Music doesn't start/stop
- ❌ Text becomes unreadable

---

## 🔍 Specific Test Scenarios

### Test Case 1: Complete User Journey
1. Open app → Read daily verse → Browse scenarios → Find family conflict → Read heart vs duty 
2. **Expected**: Smooth flow without crashes

### Test Case 2: Deep Exploration
1. Pick Chapter 3 → Read summary →  Go to related scenarios → Read 2 scenarios 
2. **Expected**: All content connects logically

### Test Case 3: Quick Usage
1. Open app → Quickly browse 5 different scenarios → Check if they load fast
2. **Expected**: Fast loading, no delays

### Test Case 4: Settings Changes
1. Change to dark mode → Browse chapters → Switch back to light mode → Test audio toggle
2. **Expected**: All changes work immediately
---

## 📝 What to Report

### For Each Issue, Please Include:
1. **What you were doing** (step-by-step)
2. **What you expected** to happen
3. **What actually happened**

**Happy Testing!** 
