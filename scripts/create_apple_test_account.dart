import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

/// Script to create Apple App Review test account
/// Run with: dart scripts/create_apple_test_account.dart
void main() async {
  // Load environment variables
  final supabaseUrl = const String.fromEnvironment('SUPABASE_URL');
  final supabaseKey = const String.fromEnvironment('SUPABASE_ANON_KEY');

  if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
    print('❌ Error: Missing Supabase credentials');
    print('Run with: dart scripts/create_apple_test_account.dart \\');
    print('  --dart-define=SUPABASE_URL=\$SUPABASE_URL \\');
    print('  --dart-define=SUPABASE_ANON_KEY=\$SUPABASE_ANON_KEY');
    exit(1);
  }

  print('🚀 Creating Apple App Review test account...\n');

  // Initialize Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );

  final supabase = Supabase.instance.client;

  // Test account credentials
  const testEmail = 'applereview@gitawisdom.app';
  const testPassword = 'AppleTest2025!Review';
  const testName = 'Apple Reviewer';

  try {
    // Try to sign up the user
    print('📝 Creating account...');
    print('   Email: $testEmail');
    print('   Password: $testPassword');
    print('   Name: $testName\n');

    final response = await supabase.auth.signUp(
      email: testEmail,
      password: testPassword,
      data: {'name': testName},
    );

    if (response.user != null) {
      print('✅ Account created successfully!');
      print('   User ID: ${response.user!.id}');
      print('   Email: ${response.user!.email}\n');

      // Sign out
      await supabase.auth.signOut();

      print('📋 Apple App Review Credentials:');
      print('─────────────────────────────────────');
      print('Email:    $testEmail');
      print('Password: $testPassword');
      print('─────────────────────────────────────\n');

      print('✅ Test account ready for Apple App Review!');
      print('\n📱 Testing instructions for Apple reviewers:');
      print('1. Launch the app');
      print('2. Tap the "Journal" tab');
      print('3. Tap "Sign In" button');
      print('4. Enter the credentials above');
      print('5. Access journal with cloud sync enabled');
    } else {
      print('⚠️ Unexpected response: ${response}');
    }
  } catch (e) {
    if (e.toString().contains('already registered')) {
      print('ℹ️ Account already exists');
      print('\n📋 Apple App Review Credentials:');
      print('─────────────────────────────────────');
      print('Email:    $testEmail');
      print('Password: $testPassword');
      print('─────────────────────────────────────\n');
      print('✅ Existing test account ready for Apple App Review!');
    } else {
      print('❌ Error creating account: $e');
      exit(1);
    }
  }
}
