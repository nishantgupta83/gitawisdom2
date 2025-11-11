import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.3'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Get JWT token from Authorization header
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: 'Missing authorization header' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const token = authHeader.replace('Bearer ', '')

    // Initialize Supabase client with service role for admin operations
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

    const supabaseAdmin = createClient(supabaseUrl, supabaseServiceRoleKey, {
      auth: {
        autoRefreshToken: false,
        persistSession: false
      }
    })

    // Verify JWT and get user
    const { data: { user }, error: authError } = await supabaseAdmin.auth.getUser(token)

    if (authError || !user) {
      return new Response(
        JSON.stringify({ error: 'Invalid or expired token' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const userId = user.id
    console.log(`Deleting account for user: ${userId}`)

    // Delete user data from all tables (if they exist in your schema)
    // Adjust table names based on your actual database schema
    try {
      // Delete journal entries
      const { error: journalError } = await supabaseAdmin
        .from('journal_entries')
        .delete()
        .eq('user_id', userId)

      if (journalError && journalError.code !== 'PGRST116') { // PGRST116 = table not found
        console.error('Error deleting journal entries:', journalError)
      }

      // Delete bookmarks
      const { error: bookmarksError } = await supabaseAdmin
        .from('user_bookmarks')
        .delete()
        .eq('user_id', userId)

      if (bookmarksError && bookmarksError.code !== 'PGRST116') {
        console.error('Error deleting bookmarks:', bookmarksError)
      }

      // Delete user progress
      const { error: progressError } = await supabaseAdmin
        .from('user_progress')
        .delete()
        .eq('user_id', userId)

      if (progressError && progressError.code !== 'PGRST116') {
        console.error('Error deleting progress:', progressError)
      }

      // Delete user settings
      const { error: settingsError } = await supabaseAdmin
        .from('user_settings')
        .delete()
        .eq('user_id', userId)

      if (settingsError && settingsError.code !== 'PGRST116') {
        console.error('Error deleting settings:', settingsError)
      }

      console.log('User data deleted from all tables')
    } catch (dbError) {
      console.error('Error deleting user data:', dbError)
      // Continue with auth deletion even if some tables don't exist
    }

    // Revoke Apple refresh token if user signed in with Apple
    if (user.app_metadata?.provider === 'apple' && user.user_metadata?.apple_refresh_token) {
      try {
        // Apple token revocation endpoint
        const appleClientId = Deno.env.get('APPLE_CLIENT_ID') || 'com.hub4apps.gitawisdom'
        const appleClientSecret = Deno.env.get('APPLE_CLIENT_SECRET')

        if (appleClientSecret) {
          const revokeResponse = await fetch('https://appleid.apple.com/auth/revoke', {
            method: 'POST',
            headers: {
              'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: new URLSearchParams({
              client_id: appleClientId,
              client_secret: appleClientSecret,
              token: user.user_metadata.apple_refresh_token,
              token_type_hint: 'refresh_token',
            }),
          })

          if (revokeResponse.ok) {
            console.log('Apple refresh token revoked successfully')
          } else {
            console.warn('Failed to revoke Apple token:', await revokeResponse.text())
          }
        }
      } catch (appleError) {
        console.error('Error revoking Apple token:', appleError)
        // Continue with account deletion even if token revocation fails
      }
    }

    // Delete the auth user (this also removes from auth.users table)
    const { error: deleteUserError } = await supabaseAdmin.auth.admin.deleteUser(userId)

    if (deleteUserError) {
      console.error('Error deleting auth user:', deleteUserError)
      return new Response(
        JSON.stringify({ error: 'Failed to delete user account', details: deleteUserError.message }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    console.log(`Account deleted successfully for user: ${userId}`)

    return new Response(
      JSON.stringify({ success: true, message: 'Account deleted successfully' }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('Unexpected error:', error)
    return new Response(
      JSON.stringify({ error: 'Internal server error', details: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
