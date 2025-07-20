-- Reset ALL policies to fix conflicts

-- Drop all existing policies
DROP POLICY IF EXISTS "Public can view teams" ON teams;
DROP POLICY IF EXISTS "Admins can manage teams" ON teams;
DROP POLICY IF EXISTS "Team captains can update their team" ON teams;

DROP POLICY IF EXISTS "Public can view players" ON players;
DROP POLICY IF EXISTS "Admins can manage players" ON players;
DROP POLICY IF EXISTS "Team captains can manage their team players" ON players;

DROP POLICY IF EXISTS "Public can view matches" ON matches;
DROP POLICY IF EXISTS "Admins can manage matches" ON matches;
DROP POLICY IF EXISTS "Team captains can update their team matches" ON matches;

DROP POLICY IF EXISTS "Public can view achievements" ON achievements;
DROP POLICY IF EXISTS "Admins can manage achievements" ON achievements;
DROP POLICY IF EXISTS "Team captains can manage their team achievements" ON achievements;

-- Drop any remaining user_profiles policies
DROP POLICY IF EXISTS "Users can view their own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON user_profiles;
DROP POLICY IF EXISTS "Admins can view all profiles" ON user_profiles;
DROP POLICY IF EXISTS "Admins can manage all profiles" ON user_profiles;
DROP POLICY IF EXISTS "Admins can insert profiles" ON user_profiles;
DROP POLICY IF EXISTS "Admins can update profiles" ON user_profiles;
DROP POLICY IF EXISTS "Admins can delete profiles" ON user_profiles;

-- Disable RLS on user_profiles (avoid circular dependencies)
ALTER TABLE user_profiles DISABLE ROW LEVEL SECURITY;

-- Create simple, working policies
-- Teams: Public read, admin write
CREATE POLICY "Public read teams" ON teams FOR SELECT TO public USING (true);
CREATE POLICY "Admin manage teams" ON teams FOR ALL USING (
    auth.jwt() ->> 'email' IN ('admin@wilde-liga.de', 'stefra2000@gmail.com')
);

-- Players: Public read, admin write
CREATE POLICY "Public read players" ON players FOR SELECT TO public USING (true);
CREATE POLICY "Admin manage players" ON players FOR ALL USING (
    auth.jwt() ->> 'email' IN ('admin@wilde-liga.de', 'admin@example.com')
);

-- Matches: Public read, admin write
CREATE POLICY "Public read matches" ON matches FOR SELECT TO public USING (true);
CREATE POLICY "Admin manage matches" ON matches FOR ALL USING (
    auth.jwt() ->> 'email' IN ('admin@wilde-liga.de', 'admin@example.com')
);

-- Achievements: Public read, admin write
CREATE POLICY "Public read achievements" ON achievements FOR SELECT TO public USING (true);
CREATE POLICY "Admin manage achievements" ON achievements FOR ALL USING (
    auth.jwt() ->> 'email' IN ('admin@wilde-liga.de', 'admin@example.com')
);

-- Check current policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE schemaname = 'public'
ORDER BY tablename, policyname;
