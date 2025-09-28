# GitaWisdom Authentication & User-Specific Features Implementation

## Overview
The app now supports both **anonymous users** and **authenticated users** with seamless data synchronization and user-specific features.

## Test Users for Login

| Email | Password | Profile Type | Key Features |
|-------|----------|--------------|--------------|
| **test1@gitawisdom.com** | TestUser@2024 | Beginner Reader | • 3-day reading streak<br>• 5 bookmarks saved<br>• 2 chapters completed<br>• 45 minutes total reading |
| **test2@gitawisdom.com** | TestUser@2024 | Advanced Reader | • 21-day streak<br>• 25 bookmarks<br>• 8 chapters completed<br>• 100+ verses read |
| **test3@gitawisdom.com** | TestUser@2024 | Casual Browser | • Inactive 5 days<br>• Notifications disabled<br>• Minimal progress<br>• 2 bookmarks only |
| **test4@gitawisdom.com** | TestUser@2024 | Power User | • 90-day streak!<br>• All 18 chapters completed<br>• 100+ bookmarks<br>• 500+ verses read |
| **test5@gitawisdom.com** | TestUser@2024 | New User | • Just signed up<br>• 1-day streak<br>• No bookmarks yet<br>• Fresh start |

## Technical Implementation

### 1. Authentication Flow

```
App Launch
    ↓
AuthService.initialize()
    ↓
Generate Device ID (SHA256 hash)
    ↓
Check Supabase Auth Status
    ↓
┌─────────────────┐
│ User Logged In? │
└─────────────────┘
    ↙         ↘
  No           Yes
   ↓            ↓
Anonymous    Authenticated
   Mode         Mode
```

### 2. User ID Strategy

The app uses a **dual ID system**:

- **Anonymous Users**: `device_${sha256_hash}` (e.g., `device_a1b2c3d4e5f6g7h8`)
- **Authenticated Users**: Supabase Auth UUID (e.g., `550e8400-e29b-41d4-a716-446655440000`)

### 3. Data Storage Architecture

#### Local Storage (Hive)
- **Immediate access** for offline capability
- Stores: Journal entries, settings, cached data
- Location: `/lib/services/journal_service.dart`

#### Cloud Storage (Supabase)
- **Synchronized data** across devices
- Tables:
  - `user_bookmarks` - Saved verses, chapters, scenarios
  - `user_progress` - Reading progress, streaks, achievements  
  - `user_settings` - Preferences, goals, widget config
  - `daily_practice_log` - Meditation, reflection sessions
  - `notification_history` - Push notification tracking

### 4. User-Specific Features Implementation

#### A. Bookmarks Service (`/lib/services/bookmark_service.dart`)
```dart
class BookmarkService extends ChangeNotifier {
  String? _userId;
  
  void initialize(String? userId) {
    _userId = userId ?? _generateAnonymousId();
    _loadBookmarks();
  }
  
  Future<void> addBookmark(Bookmark bookmark) async {
    // Save to Supabase with user_device_id = _userId
    await _supabase.from('user_bookmarks').insert({
      'user_device_id': _userId,
      'bookmark_type': bookmark.type,
      'reference_id': bookmark.referenceId,
      // ... other fields
    });
  }
}
```

#### B. Progress Tracking (`/lib/services/progress_service.dart`)
```dart
class ProgressService extends ChangeNotifier {
  Future<void> trackProgress(String userId) async {
    // Fetch user-specific progress
    final response = await _supabase
      .from('user_progress')
      .select()
      .eq('user_device_id', userId);
    
    // Calculate streaks, achievements, etc.
    _calculateReadingStreak(response.data);
    _checkAchievements(response.data);
  }
}
```

#### C. Authentication State Management (`/lib/main.dart`)
```dart
MultiProvider(
  providers: [
    // Auth service provides user state
    ChangeNotifierProvider<AuthService>(
      create: (_) => AuthService()..initialize(),
    ),
    
    // Other services depend on auth state
    ChangeNotifierProxyProvider<AuthService, BookmarkService>(
      update: (_, authService, bookmarkService) {
        bookmarkService!.initialize(authService.userId);
        return bookmarkService;
      },
    ),
  ],
)
```

### 5. Data Migration Strategy

When an anonymous user signs up/logs in:

1. **Identify existing anonymous data** using device ID
2. **Update all records** to use the new authenticated user ID
3. **Merge if conflicts** (e.g., bookmarks from multiple devices)
4. **Sync across devices** for authenticated users

```dart
// In AuthService
Future<void> _migrateAnonymousData() async {
  final tables = ['user_bookmarks', 'user_progress', 'user_settings'];
  
  for (final table in tables) {
    await _supabase.from(table)
      .update({'user_device_id': _currentUser!.id})
      .eq('user_device_id', _deviceId!);
  }
}
```

### 6. Privacy & Security

- **Device IDs are hashed** - No raw device information stored
- **Row Level Security (RLS)** - Users can only access their own data
- **Secure authentication** - Supabase Auth with JWT tokens
- **Password requirements** - Minimum 8 chars, special characters required
- **Anonymous data cleanup** - Purged after 90 days of inactivity

### 7. Testing the Implementation

#### Manual Testing Steps:

1. **Anonymous User Flow**:
   - Launch app without logging in
   - Add bookmarks, track progress
   - Check data persists on app restart
   - Sign up and verify data migration

2. **Authenticated User Flow**:
   - Log in with test account
   - Add bookmarks on Device A
   - Log in on Device B
   - Verify bookmarks sync

3. **Edge Cases**:
   - Network offline → data saved locally
   - Multiple devices → data merges correctly
   - Logout → switches to anonymous mode
   - Delete account → data removal

#### Automated Testing:
```bash
# Run auth service tests
flutter test test/services/auth_service_test.dart

# Run integration tests
flutter test integration_test/auth_flow_test.dart
```

### 8. Supabase Configuration Status

✅ **Database Tables Created**:
- `user_bookmarks`
- `user_progress`
- `user_settings`
- `daily_practice_log`
- `notification_history`
- `content_search_index`

✅ **Row Level Security Enabled**:
- All user tables have RLS policies
- Users can only access their own data

✅ **Indexes Optimized**:
- Performance indexes on user_device_id
- Search indexes for full-text search
- Date-based indexes for analytics

### 9. UI/UX Implementation

#### Sign In Screen (`/lib/screens/auth_screen.dart`)
- Tabbed interface (Sign In / Sign Up)
- Email & password validation
- Error handling with user-friendly messages
- "Continue as Guest" option

#### Profile Screen (`/lib/screens/profile_screen.dart`)
- Shows user stats (streak, bookmarks, progress)
- Account management options
- Data sync status
- Sign out functionality

#### Integration Points:
- **More Screen** → Profile section
- **Bookmarks** → User-specific filtering
- **Progress Charts** → Personal analytics
- **Settings** → Synced preferences

### 10. Benefits of Creating an Account

Displayed to anonymous users to encourage sign-up:

1. **📱 Sync Across Devices** - Access bookmarks and progress anywhere
2. **☁️ Cloud Backup** - Never lose your spiritual journey data
3. **📊 Advanced Analytics** - Detailed insights into reading patterns
4. **🏆 Achievement System** - Unlock exclusive badges and rewards
5. **🔔 Smart Notifications** - Personalized reminders based on habits
6. **👥 Community Features** - Share insights with other seekers (coming soon)

## Next Steps

1. **Run Test User Creation**:
   ```bash
   # Update Supabase credentials in script
   node scripts/create_test_users.js
   ```

2. **Test Login Flow**:
   - Use test credentials above
   - Verify data persistence
   - Check cross-device sync

3. **Monitor Analytics**:
   - User retention metrics
   - Feature adoption rates
   - Sync success rates

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Login fails | Check Supabase Auth settings, verify email confirmed |
| Data not syncing | Verify RLS policies, check network connectivity |
| Anonymous data lost | Ensure device ID generation is consistent |
| Duplicate bookmarks | Check unique constraints in database |

## Support

For issues or questions:
- Check Supabase logs: Dashboard → Logs → Auth
- Review error messages in Flutter console
- Verify database permissions and RLS policies