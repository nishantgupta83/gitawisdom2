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
    console.log(`[ASYNC] Deleting account for user: ${userId}`)

    // ✅ RETURN IMMEDIATELY to client (async architecture)
    // The actual deletion happens in the background
    const response = new Response(
      JSON.stringify({ success: true, message: 'Account deletion initiated' }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

    // ✅ FIRE-AND-FORGET: Run deletion in background without waiting
    // This returns to client immediately while Deno handles the cleanup
    performDeletionInBackground(userId, token, supabaseAdmin, user)

    return response

  } catch (error) {
    console.error('Unexpected error:', error)
    return new Response(
      JSON.stringify({ error: 'Internal server error', details: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})

// ✅ Background deletion function (runs after response is sent to client)
async function performDeletionInBackground(userId: string, token: string, supabaseAdmin: any, user: any) {
  try {
    console.log(`[BACKGROUND] Starting account deletion for user: ${userId}`)

    // Delete user data from all tables (if they exist in your schema)
    try {
      // Delete journal entries
      const { error: journalError } = await supabaseAdmin
        .from('journal_entries')
        .delete()
        .eq('user_id', userId)

      if (journalError && journalError.code !== 'PGRST116') { // PGRST116 = table not found
        console.error(`[BACKGROUND] Error deleting journal entries for ${userId}:`, journalError)
      } else {
        console.log(`[BACKGROUND] Deleted journal entries for ${userId}`)
      }

      // Delete bookmarks
      const { error: bookmarksError } = await supabaseAdmin
        .from('user_bookmarks')
        .delete()
        .eq('user_id', userId)

      if (bookmarksError && bookmarksError.code !== 'PGRST116') {
        console.error(`[BACKGROUND] Error deleting bookmarks for ${userId}:`, bookmarksError)
      } else {
        console.log(`[BACKGROUND] Deleted bookmarks for ${userId}`)
      }

      // Delete user progress
      const { error: progressError } = await supabaseAdmin
        .from('user_progress')
        .delete()
        .eq('user_id', userId)

      if (progressError && progressError.code !== 'PGRST116') {
        console.error(`[BACKGROUND] Error deleting progress for ${userId}:`, progressError)
      } else {
        console.log(`[BACKGROUND] Deleted user progress for ${userId}`)
      }

      // Delete user settings
      const { error: settingsError } = await supabaseAdmin
        .from('user_settings')
        .delete()
        .eq('user_id', userId)

      if (settingsError && settingsError.code !== 'PGRST116') {
        console.error(`[BACKGROUND] Error deleting settings for ${userId}:`, settingsError)
      } else {
        console.log(`[BACKGROUND] Deleted user settings for ${userId}`)
      }

      console.log(`[BACKGROUND] User data deleted from all tables for ${userId}`)
    } catch (dbError) {
      console.error(`[BACKGROUND] Error deleting user data for ${userId}:`, dbError)
      // Continue with auth deletion even if some tables don't exist
    }

    // Revoke Apple refresh token if user signed in with Apple
    if (user.app_metadata?.provider === 'apple' && user.user_metadata?.apple_refresh_token) {
      try {
        const appleClientId = Deno.env.get('APPLE_CLIENT_ID') || 'com.hub4apps.gitawisdom'
        const appleClientSecret = Deno.env.get('APPLE_CLIENT_SECRET')

        if (appleClientSecret) {
          console.log(`[BACKGROUND] Revoking Apple token for ${userId}`)
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
            console.log(`[BACKGROUND] Apple refresh token revoked for ${userId}`)
          } else {
            console.warn(`[BACKGROUND] Failed to revoke Apple token for ${userId}:`, await revokeResponse.text())
          }
        }
      } catch (appleError) {
        console.error(`[BACKGROUND] Error revoking Apple token for ${userId}:`, appleError)
      }
    }

    // Delete the auth user (this also removes from auth.users table)
    console.log(`[BACKGROUND] Deleting auth user ${userId}`)
    const { error: deleteUserError } = await supabaseAdmin.auth.admin.deleteUser(userId)

    if (deleteUserError) {
      console.error(`[BACKGROUND] Error deleting auth user ${userId}:`, deleteUserError)
    } else {
      console.log(`[BACKGROUND] Account deleted successfully for user: ${userId}`)
    }

  } catch (error) {
    console.error(`[BACKGROUND] Unexpected error deleting account for ${userId}:`, error)
  }
}
