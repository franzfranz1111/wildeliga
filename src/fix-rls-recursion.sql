-- Fix infinite recursion in user_profiles RLS policies
-- This addresses the login error and 500 Internal Server Error

-- First, disable RLS temporarily to avoid recursion
ALTER TABLE user_profiles DISABLE ROW LEVEL SECURITY;

-- Drop all existing policies on user_profiles
DROP POLICY IF EXISTS "Users can view own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON user_profiles;
DROP POLICY IF EXISTS "Admins can view all profiles" ON user_profiles;
DROP POLICY IF EXISTS "Admins can update all profiles" ON user_profiles;
DROP POLICY IF EXISTS "Allow admins to create users" ON user_profiles;
DROP POLICY IF EXISTS "Allow viewing profiles" ON user_profiles;
DROP POLICY IF EXISTS "Allow updating own profile" ON user_profiles;
DROP POLICY IF EXISTS "Allow admins full access" ON user_profiles;

-- Re-enable RLS
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- Create simple, non-recursive policies
-- Policy 1: Users can view their own profile
CREATE POLICY "view_own_profile" ON user_profiles
    FOR SELECT USING (auth.uid() = id);

-- Policy 2: Users can update their own profile
CREATE POLICY "update_own_profile" ON user_profiles
    FOR UPDATE USING (auth.uid() = id);

-- Policy 3: Admins can view all profiles (using auth.jwt())
CREATE POLICY "admin_view_all" ON user_profiles
    FOR SELECT USING (
        COALESCE((auth.jwt() ->> 'user_metadata')::jsonb ->> 'role', '') = 'admin'
    );

-- Policy 4: Admins can update all profiles (using auth.jwt())
CREATE POLICY "admin_update_all" ON user_profiles
    FOR UPDATE USING (
        COALESCE((auth.jwt() ->> 'user_metadata')::jsonb ->> 'role', '') = 'admin'
    );

-- Policy 5: Admins can insert new profiles (using auth.jwt())
CREATE POLICY "admin_insert_profiles" ON user_profiles
    FOR INSERT WITH CHECK (
        COALESCE((auth.jwt() ->> 'user_metadata')::jsonb ->> 'role', '') = 'admin'
    );

-- Verify policies are created correctly
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE tablename = 'user_profiles';

-- Test query to ensure no recursion
SELECT COUNT(*) FROM user_profiles;

COMMENT ON TABLE user_profiles IS 'User profiles with fixed RLS policies to prevent infinite recursion';
