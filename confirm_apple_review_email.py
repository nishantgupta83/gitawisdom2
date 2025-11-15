#!/usr/bin/env python3
"""
Manually confirm the Apple review account email in Supabase.
"""
from supabase import create_client
import requests

# Using development database
supabase = create_client(
    "https://wlfwdtdtiedlcczfoslt.supabase.co",
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndsZndkdGR0aWVkbGNjemZvc2x0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE4NjQ5MDAsImV4cCI6MjA2NzQ0MDkwMH0.OiWhZled2trJ7eTd8lpQ658B4p-IVsRp2HXHcgAUoFU"
)

print("🔍 Checking Apple review account status...\n")
print("="*80)

email = "applereview@gitawisdom.app"
password = "AppleTest2025!Review"

# Try to sign in
print(f"\n📧 Attempting to sign in: {email}")

try:
    response = supabase.auth.sign_in_with_password({
        "email": email,
        "password": password
    })
    print(f"\n✅ Account exists and sign-in works!")
    print(f"   User ID: {response.user.id}")
    print(f"   Email: {response.user.email}")
    print(f"   Email confirmed: {response.user.email_confirmed_at}")

    if response.user.email_confirmed_at:
        print(f"\n✅ Email is already confirmed!")
    else:
        print(f"\n⚠️  Email is NOT confirmed")
        print(f"   This is why sign-in doesn't work in the app")

except Exception as e:
    error_msg = str(e)
    print(f"\n❌ Sign-in failed: {error_msg}")

    if "Email not confirmed" in error_msg or "email_not_confirmed" in error_msg.lower():
        print(f"\n⚠️  Email confirmation required!")
        print(f"\n📝 To fix this, you need to:")
        print(f"   1. Go to Supabase Dashboard")
        print(f"   2. Authentication → Users")
        print(f"   3. Find {email}")
        print(f"   4. Click the three dots → 'Confirm email'")
        print(f"   OR disable email confirmation in Supabase settings")

print(f"\n{'='*80}")
print("\n📋 Summary:")
print(f"  Email: {email}")
print(f"  Password: {password}")
print(f"\n💡 For Apple App Review, you should:")
print(f"  1. Manually confirm this account's email in Supabase Dashboard")
print(f"  2. OR disable 'Enable email confirmations' in Supabase Auth settings")
