-- Function to delete user account and all associated data
-- This function can be called via Supabase RPC from the Flutter app
-- Usage: supabase.rpc('delete_user_account')

CREATE OR REPLACE FUNCTION delete_user_account()
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER -- Run with elevated privileges
SET search_path = public
AS $$
DECLARE
  current_user_id uuid;
BEGIN
  -- Get the current authenticated user ID
  current_user_id := auth.uid();

  -- Check if user is authenticated
  IF current_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  -- NOTE: This app uses Hive for local storage (journal entries, bookmarks, progress, settings)
  -- All user data is stored locally on the device, not in Supabase tables
  -- Therefore, we only need to delete the auth.users record

  -- Delete the auth user
  -- Note: This requires admin privileges, so we use SECURITY DEFINER
  DELETE FROM auth.users WHERE id = current_user_id;

  -- Return success response
  RETURN json_build_object(
    'success', true,
    'message', 'Account deleted successfully',
    'user_id', current_user_id
  );

EXCEPTION
  WHEN OTHERS THEN
    -- Return error response
    RETURN json_build_object(
      'success', false,
      'error', SQLERRM,
      'detail', SQLSTATE
    );
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION delete_user_account() TO authenticated;

-- Add comment for documentation
COMMENT ON FUNCTION delete_user_account() IS 'Deletes the current authenticated user account and all associated data. Complies with Apple App Store guideline 5.1.1(v).';
