-- Complete fix for all RLS recursion issues
-- This script addresses all potential RLS problems across all tables

-- 1. DISABLE RLS on all tables temporarily
ALTER TABLE user_profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE teams DISABLE ROW LEVEL SECURITY;
ALTER TABLE matches DISABLE ROW LEVEL SECURITY;
ALTER TABLE seasons DISABLE ROW LEVEL SECURITY;
ALTER TABLE season_teams DISABLE ROW LEVEL SECURITY;
ALTER TABLE players DISABLE ROW LEVEL SECURITY;
ALTER TABLE achievements DISABLE ROW LEVEL SECURITY;

-- 2. DROP ALL existing policies to start fresh
DO $$ 
DECLARE 
    r RECORD;
BEGIN
    -- Drop all policies on all tables
    FOR r IN (SELECT schemaname, tablename, policyname FROM pg_policies WHERE schemaname = 'public') 
    LOOP
        EXECUTE 'DROP POLICY IF EXISTS "' || r.policyname || '" ON ' || r.schemaname || '.' || r.tablename;
    END LOOP;
END $$;

-- 3. RE-ENABLE RLS on tables that need it
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- 4. Create SIMPLE, non-recursive policies for user_profiles only
-- Allow authenticated users to view their own profile
CREATE POLICY "user_profiles_select_own" ON user_profiles
    FOR SELECT 
    TO authenticated 
    USING (auth.uid() = id);

-- Allow authenticated users to update their own profile  
CREATE POLICY "user_profiles_update_own" ON user_profiles
    FOR UPDATE 
    TO authenticated 
    USING (auth.uid() = id);

-- Allow service role full access (for admin operations)
CREATE POLICY "user_profiles_service_role_all" ON user_profiles
    FOR ALL 
    TO service_role 
    USING (true);

-- 5. Make other tables PUBLIC (no RLS) for now to avoid recursion
-- These can be secured later after the login issue is resolved
GRANT SELECT ON teams TO anon, authenticated;
GRANT SELECT ON matches TO anon, authenticated;
GRANT SELECT ON seasons TO anon, authenticated;
GRANT SELECT ON season_teams TO anon, authenticated;
GRANT SELECT ON players TO anon, authenticated;
GRANT SELECT ON achievements TO anon, authenticated;

-- 6. Test the setup
SELECT 'user_profiles policies:' as info;
SELECT policyname, cmd, permissive 
FROM pg_policies 
WHERE tablename = 'user_profiles';

SELECT 'Tables with RLS enabled:' as info;
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' AND rowsecurity = true;

-- 7. Test query
SELECT 'Testing user_profiles access...' as info;
SELECT COUNT(*) as user_count FROM user_profiles;

COMMENT ON TABLE user_profiles IS 'User profiles with simplified RLS policies';
