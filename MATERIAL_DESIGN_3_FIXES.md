# Material Design 3 Compliance - Implementation Guide
## More Screen (more_screen.dart) - Code Fixes & Improvements

**Last Updated**: November 7, 2025
**Status**: Ready for Implementation

---

## QUICK REFERENCE: Issues & Solutions

| Issue | Location | Severity | Effort | Status |
|-------|----------|----------|--------|--------|
| Section header inconsistency | Lines 240, 304, 320, 370, 384 | MEDIUM | LOW | ❌ Need Fix |
| Chevron icons on non-nav items | Lines 199, 208, 233 | MEDIUM | LOW | ❌ Need Fix |
| Card + ExpansionTile redundancy | Lines 180-212 | MEDIUM | LOW | ❌ Need Fix |
| Dialog stacking in cache refresh | Lines 757-789 | HIGH | MEDIUM | ❌ Need Fix |
| No Semantics on progress | Lines 715-742 | LOW | LOW | ⚠️ Optional |
| Dropdown button instability | Lines 283-299 | LOW | MEDIUM | ⚠️ Optional |

---

## FIX #1: Section Header Consistency (Highest Priority)

### Current Code (WRONG)
```dart
// Line 240 - Title Case (WRONG for Material Design 3)
Text('Appearance', style: theme.textTheme.titleMedium),

// Line 304 - Title Case (WRONG)
Text('Content', style: theme.textTheme.titleMedium),

// Line 320 - Title Case (WRONG)
Text('Extras', style: theme.textTheme.titleMedium),

// Line 370 - Title Case (WRONG)
Text('Resources', style: theme.textTheme.titleMedium),

// Line 384 - Title Case (WRONG)
Text('Support & Legal', style: theme.textTheme.titleMedium),

// Line 175 - UPPERCASE with letterSpacing (CORRECT)
Text('ACCOUNT', style: theme.textTheme.titleSmall?.copyWith(
  letterSpacing: 0.5,
  color: theme.colorScheme.onSurfaceVariant,
)),
```

### Fixed Code
```dart
// Create a reusable helper for section headers
Widget _buildSectionHeader(String label, ThemeData theme) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
    child: Text(
      label.toUpperCase(), // Ensure UPPERCASE
      style: theme.textTheme.titleSmall?.copyWith(
        letterSpacing: 0.5,
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    ),
  );
}

// Usage throughout the file
_buildSectionHeader('APPEARANCE', theme),
// instead of:
// Padding(padding: const EdgeInsets.fromLTRB(16, 24, 16, 8), child: Text('Appearance', ...))

_buildSectionHeader('CONTENT', theme),
_buildSectionHeader('EXTRAS', theme),
_buildSectionHeader('RESOURCES', theme),
_buildSectionHeader('SUPPORT & LEGAL', theme),
```

### Apply to Full Widget Tree
Replace ALL occurrences in `_buildBody()`:
- Line 240: `Text('Appearance', ...)`
- Line 304: `Text('Content', ...)`
- Line 320: `Text('Extras', ...)`
- Line 370: `Text('Resources', ...)`
- Line 384: `Text('Support & Legal', ...)`

**Expected Output**:
```
┌─────────────────────────────────┐
│ ACCOUNT                    [>]  │
│ user@example.com               │
├─────────────────────────────────┤
│ CACHE MANAGEMENT               │
│ Refresh All Data           [>]  │
│ ┌─────────────────────────────┐ │
├─────────────────────────────────┤
│ APPEARANCE                      │  ← Now UPPERCASE with spacing
│ Dark Mode                   [o] │
│ Background Music            [o] │
│ Font Size                     M │
├─────────────────────────────────┤
│ CONTENT                         │  ← Now UPPERCASE with spacing
│ Search                          │
└─────────────────────────────────┘
```

---

## FIX #2: Remove Navigation Chevrons (Non-Navigational Items)

### Current Code (WRONG)
```dart
// Line 199 - Sign Out has chevron (WRONG - not navigation)
ListTile(
  leading: const Icon(Icons.logout),
  title: const Text('Sign Out'),
  trailing: const Icon(Icons.chevron_right), // ❌ Remove this
  onTap: () => _handleSignOut(context, authService),
),

// Line 208 - Delete Account has chevron (WRONG - danger action)
ListTile(
  leading: Icon(Icons.delete_forever, color: theme.colorScheme.error),
  title: Text('Delete Account', style: TextStyle(color: theme.colorScheme.error)),
  trailing: Icon(Icons.chevron_right, color: theme.colorScheme.error), // ❌ Remove
  onTap: () => _showDeleteAccountDialog(context, authService),
),

// Line 233 - Refresh Cache has chevron (WRONG - opens dialog, not navigation)
ListTile(
  leading: const Icon(Icons.cached),
  title: const Text('Refresh All Data'),
  subtitle: const Text('Clear and reload chapters, verses & scenarios'),
  trailing: const Icon(Icons.chevron_right), // ❌ Remove
  onTap: () => _handleRefreshCache(context),
),
```

### Fixed Code
```dart
// Sign Out - No trailing needed
ListTile(
  leading: const Icon(Icons.logout),
  title: const Text('Sign Out'),
  onTap: () => _handleSignOut(context, authService),
),

// Delete Account - Remove chevron, keep red styling for danger
ListTile(
  leading: Icon(Icons.delete_forever, color: theme.colorScheme.error),
  title: Text(
    'Delete Account',
    style: TextStyle(color: theme.colorScheme.error),
  ),
  onTap: () => _showDeleteAccountDialog(context, authService),
),

// Refresh Cache - Remove chevron, optionally add cache size as trailing
ListTile(
  leading: const Icon(Icons.cached),
  title: const Text('Refresh All Data'),
  subtitle: const Text('Clear and reload chapters, verses & scenarios'),
  trailing: Text(
    'Last synced',
    style: theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    ),
  ),
  onTap: () => _handleRefreshCache(context),
),
```

**Material Design 3 Rationale**:
- Chevrons suggest forward navigation to a new screen
- Sign Out, Delete Account, and Refresh are direct actions (not navigation)
- Android Material Design 3 removed chevron indicators
- Trailing content should show: values, toggles, or status (not navigation hint)

**Visual Change**:
```
BEFORE (with chevrons):
┌─────────────────────────────────┐
│ Sign Out                      > │  ← Suggests navigation
│ Delete Account                > │  ← Misleading for danger action
│ Refresh All Data              > │  ← Not navigation, opens dialog
└─────────────────────────────────┘

AFTER (without chevrons):
┌─────────────────────────────────┐
│ Sign Out                        │  ← Clear action
│ Delete Account                  │  ← Danger action clear
│ Refresh All Data  Last synced   │  ← Status info instead
└─────────────────────────────────┘
```

---

## FIX #3: Remove Card Wrapper from Account Section

### Current Code (WRONG)
```dart
// Lines 180-213: Card + ExpansionTile (Material Design 3 violation)
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text('ACCOUNT', style: /* ... */),
    ),
    Card(  // ❌ Unnecessary wrapper - adds double elevation
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: ExpansionTile(
        leading: Icon(Icons.account_circle, color: theme.colorScheme.primary),
        title: Text(authService.displayName ?? 'User', style: /* ... */),
        subtitle: Text(authService.userEmail ?? '', style: /* ... */),
        collapsedBackgroundColor: theme.colorScheme.surface,
        backgroundColor: theme.colorScheme.surface,
        children: [
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign Out'),
            trailing: const Icon(Icons.chevron_right), // Also remove
            onTap: () => _handleSignOut(context, authService),
          ),
          ListTile(
            leading: Icon(Icons.delete_forever, color: theme.colorScheme.error),
            title: Text('Delete Account', style: /* ... */),
            trailing: Icon(Icons.chevron_right, color: /* ... */), // Also remove
            onTap: () => _showDeleteAccountDialog(context, authService),
          ),
        ],
      ),
    ),
  ],
)
```

### Fixed Code
```dart
// Lines 180-213: Remove Card wrapper - use Material surface directly
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text('ACCOUNT', style: theme.textTheme.titleSmall?.copyWith(
        letterSpacing: 0.5,
        color: theme.colorScheme.onSurfaceVariant,
      )),
    ),
    // ✅ No Card wrapper - ExpansionTile sits directly on surface
    Material(
      color: theme.colorScheme.surface,
      child: ExpansionTile(
        leading: Icon(Icons.account_circle, color: theme.colorScheme.primary),
        title: Text(
          authService.displayName ?? 'User',
          style: theme.textTheme.titleSmall,
        ),
        subtitle: Text(
          authService.userEmail ?? '',
          style: theme.textTheme.bodySmall,
        ),
        children: [
          Divider(
            height: 1,
            color: theme.colorScheme.outlineVariant, // Use semantic color
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign Out'),
            // ✅ No trailing chevron
            onTap: () => _handleSignOut(context, authService),
          ),
          ListTile(
            leading: Icon(Icons.delete_forever, color: theme.colorScheme.error),
            title: Text(
              'Delete Account',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            // ✅ No trailing chevron
            onTap: () => _showDeleteAccountDialog(context, authService),
          ),
        ],
      ),
    ),
  ],
)
```

**Why This Matters**:
- Card adds elevation on top of ExpansionTile's elevation (double layering)
- Material 3 uses single semantic surfaces: surface, surfaceContainer, surfaceVariant
- ExpansionTile already manages its own background color
- Divider now uses `colorScheme.outlineVariant` (Material 3 proper)

**Visual Hierarchy Before/After**:
```
BEFORE (Double Elevation Issue):
┌─────────────────────────────────┐ ← Surface (z=0)
│ ┌─────────────────────────────┐ │ ← Card Elevation (z=1)
│ │ ┌───────────────────────────┤ │ ← ExpansionTile
│ │ │ Account | user@example.com│ │
│ │ ├───────────────────────────┤ │
│ │ │ Sign Out                  │ │
│ │ └───────────────────────────┘ │
│ └─────────────────────────────┘ │
└─────────────────────────────────┘
(Too many visual layers - confusing hierarchy)

AFTER (Clean Single Surface):
┌─────────────────────────────────┐ ← Surface (z=0)
│ ┌───────────────────────────────┤ ← ExpansionTile
│ │ Account | user@example.com    │
│ ├───────────────────────────────┤
│ │ Sign Out                      │
│ │ Delete Account                │
│ └───────────────────────────────┘
└─────────────────────────────────┘
(Clean hierarchy - single semantic surface)
```

---

## FIX #4: Dialog Stack Management (Critical - Prevents Crashes)

### Current Code (BROKEN)
```dart
// Lines 704-815: Creates nested dialogs on orientation change
Future<void> _handleRefreshCache(BuildContext context) async {
  final theme = Theme.of(context);
  double _progress = 0.0;

  if (!mounted) return;

  // Initial dialog opened
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Refreshing Cache'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(value: _progress),
                const SizedBox(height: 16),
                Text(
                  _progress < 1.0
                      ? 'Clearing and reloading all data...'
                      : 'Cache refresh completed!',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: _progress < 1.0 ? [] : [
              ElevatedButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Done'),
              ),
            ],
          );
        },
      );
    },
  );

  try {
    final cacheRefreshService = CacheRefreshService(
      supabaseService: EnhancedSupabaseService(),
    );

    await cacheRefreshService.refreshAllCaches(
      onProgress: (message, progress) {
        debugPrint('📊 $message - Progress: ${(progress * 100).toStringAsFixed(0)}%');

        // ❌ PROBLEM: This opens ANOTHER dialog while one is already open!
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) {
              return AlertDialog(
                title: const Text('Refreshing Cache'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LinearProgressIndicator(value: progress),
                    const SizedBox(height: 16),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                actions: progress >= 1.0
                    ? [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            Navigator.of(context).pop(); // Trying to close multiple dialogs
                          },
                          child: const Text('Done'),
                        ),
                      ]
                    : [],
              );
            },
          );
        }
      },
    );
    // ...
  }
}
```

### Fixed Code (Using ValueNotifier)

**Option 1: ValueNotifier Pattern (Recommended)**

```dart
// Add to _MoreScreenState
class _MoreScreenState extends State<MoreScreen> {
  String _version = '';
  bool _isLoading = true;
  String? _errorMessage;

  // ... existing code ...

  Future<void> _handleRefreshCache(BuildContext context) async {
    final theme = Theme.of(context);
    final progressNotifier = ValueNotifier<double>(0.0);
    final messageNotifier = ValueNotifier<String>('Initializing cache refresh...');

    if (!mounted) return;

    // Single dialog opened once
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Refreshing Cache'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ValueListenableBuilder<double>(
                valueListenable: progressNotifier,
                builder: (context, progress, _) {
                  return LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                  );
                },
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<String>(
                valueListenable: messageNotifier,
                builder: (context, message, _) {
                  return Text(
                    message,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  );
                },
              ),
            ],
          ),
          actions: ValueListenableBuilder<double>(
            valueListenable: progressNotifier,
            builder: (context, progress, _) {
              return progress >= 1.0
                  ? [
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Done'),
                      ),
                    ]
                  : [];
            },
          ),
        );
      },
    );

    try {
      final cacheRefreshService = CacheRefreshService(
        supabaseService: EnhancedSupabaseService(),
      );

      // ✅ Updates notifiers instead of opening new dialogs
      await cacheRefreshService.refreshAllCaches(
        onProgress: (message, progress) {
          debugPrint('📊 $message - Progress: ${(progress * 100).toStringAsFixed(0)}%');

          // Update ValueNotifiers - dialog rebuilds automatically
          messageNotifier.value = message;
          progressNotifier.value = progress;
        },
      );

      if (!mounted) return;

      // Single pop for single dialog
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cache refreshed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('❌ Cache refresh error: $e');

      if (!mounted) return;

      // Single pop for single dialog
      try {
        Navigator.of(context).pop();
      } catch (e) {
        debugPrint('Dialog already dismissed: $e');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cache refresh failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
```

**Option 2: StatefulBuilder Pattern (Alternative)**

```dart
Future<void> _handleRefreshCache(BuildContext context) async {
  final theme = Theme.of(context);
  double _progress = 0.0;
  String _message = 'Initializing cache refresh...';

  if (!mounted) return;

  // Keep reference to dialog context
  BuildContext? dialogContext;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dContext) {
      dialogContext = dContext;
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Refreshing Cache'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(value: _progress, minHeight: 8),
                const SizedBox(height: 16),
                Text(_message, textAlign: TextAlign.center),
              ],
            ),
            actions: _progress >= 1.0
                ? [
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Done'),
                    ),
                  ]
                : [],
          );
        },
      );
    },
  );

  try {
    final cacheRefreshService = CacheRefreshService(
      supabaseService: EnhancedSupabaseService(),
    );

    await cacheRefreshService.refreshAllCaches(
      onProgress: (message, progress) {
        debugPrint('📊 $message - Progress: ${(progress * 100).toStringAsFixed(0)}%');

        // Update state in existing dialog
        if (mounted && dialogContext != null) {
          // This approach has issues - avoid if possible
          // Better to use ValueNotifier pattern above
        }
      },
    );

    if (!mounted || dialogContext == null) return;
    Navigator.of(dialogContext!).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cache refreshed successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    if (!mounted || dialogContext == null) return;
    Navigator.of(dialogContext!).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cache refresh failed: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
```

**ValueNotifier Advantages**:
- ✅ Single dialog - no stacking
- ✅ Automatic rebuild on value change
- ✅ Safe on orientation change
- ✅ No need to keep dialog context reference
- ✅ Cleaner separation of concerns
- ✅ Works with WidgetsBindingObserver lifecycle

---

## FIX #5: Add Accessibility Semantics (Optional but Recommended)

### Current Code
```dart
LinearProgressIndicator(value: progress) // No semantics
```

### Enhanced Code with Accessibility
```dart
Semantics(
  slider: true,
  enabled: true,
  child: Tooltip(
    message: '${(progress * 100).toStringAsFixed(0)}% complete',
    child: LinearProgressIndicator(
      value: progress,
      minHeight: 8,
      semanticLabel: 'Cache refresh progress',
    ),
  ),
)
```

Or with custom Semantics:
```dart
Semantics(
  label: 'Cache refresh progress',
  slider: true,
  onIncrease: null, // Not adjustable by user
  onDecrease: null,
  child: LinearProgressIndicator(
    value: progress,
    minHeight: 8,
  ),
)
```

---

## FIX #6: Improve Font Size Selector (Optional Enhancement)

### Current Code (Works but unstable on overflow)
```dart
ListTile(
  title: const Text('Font Size'),
  trailing: DropdownButton<String>(
    value: settingsService.fontSize,
    items: const [
      DropdownMenuItem(value: 'small', child: Text('Small')),
      DropdownMenuItem(value: 'medium', child: Text('Medium')),
      DropdownMenuItem(value: 'large', child: Text('Large')),
    ],
    onChanged: (v) {
      if (v != null) {
        settingsService.fontSize = v;
        debugPrint('📝 Font size changed to: $v');
      }
    },
  ),
)
```

### Fixed Code Option 1: Sized Dropdown
```dart
ListTile(
  title: const Text('Font Size'),
  trailing: SizedBox(
    width: 120, // Fixed width prevents overflow
    child: DropdownButton<String>(
      isExpanded: true,
      value: settingsService.fontSize,
      items: const [
        DropdownMenuItem(value: 'small', child: Text('Small')),
        DropdownMenuItem(value: 'medium', child: Text('Medium')),
        DropdownMenuItem(value: 'large', child: Text('Large')),
      ],
      onChanged: (v) {
        if (v != null) {
          settingsService.fontSize = v;
          debugPrint('📝 Font size changed to: $v');
        }
      },
    ),
  ),
)
```

### Fixed Code Option 2: SegmentedButton (Material Design 3)
```dart
Consumer<SettingsService>(
  builder: (context, settingsService, child) {
    return ListTile(
      title: const Text('Font Size'),
      trailing: SegmentedButton<String>(
        segments: const <ButtonSegment<String>>[
          ButtonSegment<String>(
            value: 'small',
            label: Text('S'),
            tooltip: 'Small',
          ),
          ButtonSegment<String>(
            value: 'medium',
            label: Text('M'),
            tooltip: 'Medium',
          ),
          ButtonSegment<String>(
            value: 'large',
            label: Text('L'),
            tooltip: 'Large',
          ),
        ],
        selected: <String>{settingsService.fontSize},
        onSelectionChanged: (Set<String> newSelection) {
          settingsService.fontSize = newSelection.first;
          debugPrint('📝 Font size changed to: ${newSelection.first}');
        },
      ),
    );
  },
)
```

**SegmentedButton Advantages**:
- Native Material Design 3 component
- No dropdown overflow issues
- Touch target: 48x48dp (exceeds 44pt minimum)
- Visual feedback on selection
- Compact, organized appearance

---

## IMPLEMENTATION CHECKLIST

### Phase 1: Quick Fixes (30 minutes)

- [ ] **Line 240**: Replace `Text('Appearance', ...)` with section header helper
- [ ] **Line 304**: Replace `Text('Content', ...)` with section header helper
- [ ] **Line 320**: Replace `Text('Extras', ...)` with section header helper
- [ ] **Line 370**: Replace `Text('Resources', ...)` with section header helper
- [ ] **Line 384**: Replace `Text('Support & Legal', ...)` with section header helper
- [ ] **Line 199**: Remove `trailing: const Icon(Icons.chevron_right)` from Sign Out
- [ ] **Line 208**: Remove `trailing: Icon(Icons.chevron_right, ...)` from Delete Account
- [ ] **Line 233**: Remove `trailing: const Icon(Icons.chevron_right)` from Refresh Cache
- [ ] **Line 180-212**: Remove Card wrapper, replace with Material(color: ...)
- [ ] **Line 195**: Update Divider to use `color: theme.colorScheme.outlineVariant`

**Estimated Time**: 30 minutes
**Testing**: Visual testing on Android emulator

### Phase 2: Dialog Safety (1 hour)

- [ ] Import ValueNotifier utilities (already in Flutter)
- [ ] Refactor `_handleRefreshCache()` to use ValueNotifier pattern
- [ ] Remove nested `showDialog()` calls from `onProgress` callback
- [ ] Test cache refresh on Android emulator
- [ ] Test orientation changes during cache refresh
- [ ] Verify no "Navigator history is empty" errors

**Estimated Time**: 45 minutes
**Testing**: Integration test on device rotation

### Phase 3: Enhanced Accessibility (30 minutes)

- [ ] Add Semantics to LinearProgressIndicator
- [ ] Add Tooltip to progress dialog
- [ ] Test with screen reader (TalkBack on Android)
- [ ] Verify all touch targets are 44pt+

**Estimated Time**: 30 minutes
**Testing**: Screen reader testing with TalkBack

### Phase 4: Polish (optional, 30 minutes)

- [ ] Upgrade Font Size dropdown to SegmentedButton (or keep sized dropdown)
- [ ] Update dividers to use outlineVariant consistently
- [ ] Add Material 3 surfaceContainer for elevated surfaces (if needed)
- [ ] Verify Material You dynamic colors work (if available on device)

**Estimated Time**: 30 minutes
**Testing**: Visual testing on Android 12, 13, 14

---

## TESTING CHECKLIST

### Visual Testing
- [ ] All section headers are UPPERCASE
- [ ] Section header letter spacing is visible (0.5)
- [ ] No chevron icons on Sign Out, Delete, Refresh
- [ ] Account section has clean single surface (no double Card)
- [ ] Divider is visible and properly colored
- [ ] Layout looks correct in Light mode
- [ ] Layout looks correct in Dark mode

### Functionality Testing
- [ ] Sign Out action works
- [ ] Delete Account action works
- [ ] Refresh Cache action opens single dialog (not multiple)
- [ ] Progress updates smoothly without dialog flicker
- [ ] Dialog dismisses after cache refresh completes
- [ ] Dialog dismisses on orientation change (no crash)
- [ ] Dark Mode toggle works
- [ ] Background Music toggle works
- [ ] Font Size selection works

### Accessibility Testing
- [ ] TalkBack announces section headers correctly
- [ ] TalkBack announces all button labels
- [ ] All interactive elements are touchable (44pt+)
- [ ] Text contrast meets 4.5:1 minimum
- [ ] No screen reader labeling issues

### Device Testing
- [ ] Android 12 (API 31)
- [ ] Android 13 (API 33)
- [ ] Android 14 (API 34)
- [ ] Tablet landscape orientation
- [ ] Phone portrait orientation
- [ ] Orientation change doesn't crash dialogs

---

## CODE DIFF SUMMARY

```diff
// File: lib/screens/more_screen.dart

- Text('Appearance', style: theme.textTheme.titleMedium),
+ _buildSectionHeader('APPEARANCE', theme),

- Text('Content', style: theme.textTheme.titleMedium),
+ _buildSectionHeader('CONTENT', theme),

- Text('Extras', style: theme.textTheme.titleMedium),
+ _buildSectionHeader('EXTRAS', theme),

- Text('Resources', style: theme.textTheme.titleMedium),
+ _buildSectionHeader('RESOURCES', theme),

- Text('Support & Legal', style: theme.textTheme.titleMedium),
+ _buildSectionHeader('SUPPORT & LEGAL', theme),

- Card(
-   margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
-   child: ExpansionTile(
+ Material(
+   color: theme.colorScheme.surface,
+   child: ExpansionTile(

- const Divider(height: 1),
+ Divider(height: 1, color: theme.colorScheme.outlineVariant),

- trailing: const Icon(Icons.chevron_right),  // Line 199
+ // Removed

- trailing: Icon(Icons.chevron_right, color: theme.colorScheme.error),  // Line 208
+ // Removed

- trailing: const Icon(Icons.chevron_right),  // Line 233
+ trailing: Text('Last synced', style: theme.textTheme.labelSmall),

// New helper method at end of class:
+ Widget _buildSectionHeader(String label, ThemeData theme) {
+   return Padding(
+     padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
+     child: Text(
+       label,
+       style: theme.textTheme.titleSmall?.copyWith(
+         letterSpacing: 0.5,
+         fontWeight: FontWeight.w600,
+         color: theme.colorScheme.onSurfaceVariant,
+       ),
+     ),
+   );
+ }

// Replace entire _handleRefreshCache() method with ValueNotifier version
```

---

**Implementation Status**: Ready for Development
**Reviewed by**: Mobile UI/UX Design Expert
**Date**: November 7, 2025
