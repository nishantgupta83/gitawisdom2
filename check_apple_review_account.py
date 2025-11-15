#!/usr/bin/env python3
"""
Check if Apple review account exists and create if needed.
"""
from supabase import create_client

# Using DEVELOPMENT database (same as production for now)
supabase = create_client(
    "https://wlfwdtdtiedlcczfoslt.supabase.co",
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndsZndkdGR0aWVkbGNjemZvc2x0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE4NjQ5MDAsImV4cCI6MjA2NzQ0MDkwMH0.OiWhZled2trJ7eTd8lpQ658B4p-IVsRp2HXHcgAUoFU"
)

print("🔍 Checking for Apple review account...\n")
print("="*80)

email = "applereview@gitawisdom.app"
password = "AppleTest2025!Review"

# Try to sign in
print(f"\n📧 Attempting to sign in with: {email}")
print(f"🔑 Password: {password}")

try:
    response = supabase.auth.sign_in_with_password({
        "email": email,
        "password": password
    })
    print(f"\n✅ SUCCESS! Account exists and credentials work!")
    print(f"   User ID: {response.user.id}")
    print(f"   Email: {response.user.email}")
    print(f"   Created: {response.user.created_at}")
except Exception as e:
    error_msg = str(e)
    print(f"\n❌ Sign-in failed: {error_msg}")

    if "Invalid login credentials" in error_msg or "invalid_credentials" in error_msg.lower():
        print(f"\n⚠️  Account may not exist or password is wrong")
        print(f"\n🔧 Let's try to create the account...")

        try:
            response = supabase.auth.sign_up({
                "email": email,
                "password": password
            })
            print(f"\n✅ Account created successfully!")
            print(f"   User ID: {response.user.id}")
            print(f"   Email: {response.user.email}")
            print(f"\n📧 Email confirmation may be required")
            print(f"   Check if email confirmation is enabled in Supabase")
        except Exception as create_error:
            print(f"\n❌ Failed to create account: {create_error}")
    else:
        print(f"\n⚠️  Other error occurred")

print(f"\n{'='*80}")
print("\n✅ Check complete!")
print(f"\nCredentials for Apple App Review:")
print(f"  Email: {email}")
print(f"  Password: {password}")
