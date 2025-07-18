-- Fix security issues in Wilde Liga Bremen database
-- This script addresses all security warnings from Supabase Advisor

-- 1. Enable RLS on user_profiles table
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- 2. Fix SECURITY DEFINER views by recreating them without SECURITY DEFINER
-- Note: We need to recreate the views to remove SECURITY DEFINER property

-- Drop and recreate season_standings view
DROP VIEW IF EXISTS season_standings CASCADE;
CREATE VIEW season_standings AS
SELECT 
    s.id as season_id,
    s.name as season_name,
    t.id as team_id,
    t.name as team_name,
    COUNT(m.id) as games_played,
    SUM(CASE 
        WHEN (m.home_team_id = t.id AND m.home_score > m.away_score) 
          OR (m.away_team_id = t.id AND m.away_score > m.home_score) 
        THEN 1 ELSE 0 
    END) as wins,
    SUM(CASE 
        WHEN m.home_score = m.away_score AND m.home_score IS NOT NULL 
        THEN 1 ELSE 0 
    END) as draws,
    SUM(CASE 
        WHEN (m.home_team_id = t.id AND m.home_score < m.away_score) 
          OR (m.away_team_id = t.id AND m.away_score < m.home_score) 
        THEN 1 ELSE 0 
    END) as losses,
    SUM(CASE 
        WHEN m.home_team_id = t.id THEN COALESCE(m.home_score, 0)
        WHEN m.away_team_id = t.id THEN COALESCE(m.away_score, 0)
        ELSE 0
    END) as goals_for,
    SUM(CASE 
        WHEN m.home_team_id = t.id THEN COALESCE(m.away_score, 0)
        WHEN m.away_team_id = t.id THEN COALESCE(m.home_score, 0)
        ELSE 0
    END) as goals_against,
    (SUM(CASE 
        WHEN m.home_team_id = t.id THEN COALESCE(m.home_score, 0)
        WHEN m.away_team_id = t.id THEN COALESCE(m.away_score, 0)
        ELSE 0
    END) - SUM(CASE 
        WHEN m.home_team_id = t.id THEN COALESCE(m.away_score, 0)
        WHEN m.away_team_id = t.id THEN COALESCE(m.home_score, 0)
        ELSE 0
    END)) as goal_difference,
    (SUM(CASE 
        WHEN (m.home_team_id = t.id AND m.home_score > m.away_score) 
          OR (m.away_team_id = t.id AND m.away_score > m.home_score) 
        THEN 3
        WHEN m.home_score = m.away_score AND m.home_score IS NOT NULL 
        THEN 1 
        ELSE 0 
    END)) as points
FROM seasons s
CROSS JOIN teams t
LEFT JOIN season_teams st ON s.id = st.season_id AND t.id = st.team_id
LEFT JOIN matches m ON s.id = m.season_id 
    AND (m.home_team_id = t.id OR m.away_team_id = t.id)
    AND m.home_score IS NOT NULL 
    AND m.away_score IS NOT NULL
WHERE st.team_id IS NOT NULL
GROUP BY s.id, s.name, t.id, t.name;

-- Drop and recreate standings view  
DROP VIEW IF EXISTS standings CASCADE;
CREATE VIEW standings AS
SELECT 
    t.id as team_id,
    t.name as team_name,
    COUNT(m.id) as games_played,
    SUM(CASE 
        WHEN (m.home_team_id = t.id AND m.home_score > m.away_score) 
          OR (m.away_team_id = t.id AND m.away_score > m.home_score) 
        THEN 1 ELSE 0 
    END) as wins,
    SUM(CASE 
        WHEN m.home_score = m.away_score AND m.home_score IS NOT NULL 
        THEN 1 ELSE 0 
    END) as draws,
    SUM(CASE 
        WHEN (m.home_team_id = t.id AND m.home_score < m.away_score) 
          OR (m.away_team_id = t.id AND m.away_score < m.home_score) 
        THEN 1 ELSE 0 
    END) as losses,
    SUM(CASE 
        WHEN m.home_team_id = t.id THEN COALESCE(m.home_score, 0)
        WHEN m.away_team_id = t.id THEN COALESCE(m.away_score, 0)
        ELSE 0
    END) as goals_for,
    SUM(CASE 
        WHEN m.home_team_id = t.id THEN COALESCE(m.away_score, 0)
        WHEN m.away_team_id = t.id THEN COALESCE(m.home_score, 0)
        ELSE 0
    END) as goals_against,
    (SUM(CASE 
        WHEN m.home_team_id = t.id THEN COALESCE(m.home_score, 0)
        WHEN m.away_team_id = t.id THEN COALESCE(m.away_score, 0)
        ELSE 0
    END) - SUM(CASE 
        WHEN m.home_team_id = t.id THEN COALESCE(m.away_score, 0)
        WHEN m.away_team_id = t.id THEN COALESCE(m.home_score, 0)
        ELSE 0
    END)) as goal_difference,
    (SUM(CASE 
        WHEN (m.home_team_id = t.id AND m.home_score > m.away_score) 
          OR (m.away_team_id = t.id AND m.away_score > m.home_score) 
        THEN 3
        WHEN m.home_score = m.away_score AND m.home_score IS NOT NULL 
        THEN 1 
        ELSE 0 
    END)) as points
FROM teams t
LEFT JOIN matches m ON (m.home_team_id = t.id OR m.away_team_id = t.id)
    AND m.home_score IS NOT NULL 
    AND m.away_score IS NOT NULL
GROUP BY t.id, t.name;

-- Drop and recreate match_score_submissions view
DROP VIEW IF EXISTS match_score_submissions CASCADE;
CREATE VIEW match_score_submissions AS
SELECT 
    m.id,
    m.matchday,
    m.match_date,
    ht.name as home_team,
    at.name as away_team,
    m.home_score,
    m.away_score,
    m.notes,
    u.name as submitted_by,
    u.email as submitted_by_email,
    ut.name as submitted_by_team,
    m.score_submitted_at
FROM matches m
JOIN teams ht ON m.home_team_id = ht.id
JOIN teams at ON m.away_team_id = at.id
LEFT JOIN user_profiles u ON m.score_submitted_by = u.id
LEFT JOIN teams ut ON u.team_id = ut.id
WHERE m.home_score IS NOT NULL 
  AND m.away_score IS NOT NULL
ORDER BY m.score_submitted_at DESC;

-- Grant access to the recreated views
GRANT SELECT ON season_standings TO authenticated;
GRANT SELECT ON standings TO authenticated;
GRANT SELECT ON match_score_submissions TO authenticated;

-- Add proper RLS policies for user_profiles using DO block
DO $$
BEGIN
    -- Drop existing policies if they exist
    BEGIN
        DROP POLICY "Users can view own profile" ON user_profiles;
    EXCEPTION WHEN undefined_object THEN
        NULL; -- Policy doesn't exist, ignore
    END;
    
    BEGIN
        DROP POLICY "Users can update own profile" ON user_profiles;
    EXCEPTION WHEN undefined_object THEN
        NULL;
    END;
    
    BEGIN
        DROP POLICY "Admins can manage all users" ON user_profiles;
    EXCEPTION WHEN undefined_object THEN
        NULL;
    END;
    
    BEGIN
        DROP POLICY "Contact persons can view team members" ON user_profiles;
    EXCEPTION WHEN undefined_object THEN
        NULL;
    END;
    
    BEGIN
        DROP POLICY "Contact persons can view team users" ON user_profiles;
    EXCEPTION WHEN undefined_object THEN
        NULL;
    END;
END $$;

-- Create new policies
CREATE POLICY "Users can view own profile" ON user_profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON user_profiles
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Admins can manage all users" ON user_profiles
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM user_profiles 
            WHERE id = auth.uid() 
            AND role = 'admin'
        )
    );

CREATE POLICY "Contact persons can view team members" ON user_profiles
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM user_profiles up 
            WHERE up.id = auth.uid() 
            AND up.role = 'contact_person'
            AND up.team_id = user_profiles.team_id
        )
    );

-- Verify that RLS is now enabled
SELECT 
    schemaname, 
    tablename, 
    rowsecurity as rls_enabled
FROM pg_tables 
WHERE tablename = 'user_profiles';

-- Show view definitions to confirm they're not SECURITY DEFINER
SELECT schemaname, viewname, definition 
FROM pg_views 
WHERE viewname IN ('season_standings', 'standings', 'match_score_submissions');

-- Show all policies on user_profiles
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'user_profiles';

COMMENT ON TABLE user_profiles IS 'User profiles table with RLS enabled for security';
COMMENT ON VIEW season_standings IS 'Season standings view without SECURITY DEFINER';
COMMENT ON VIEW standings IS 'Current standings view without SECURITY DEFINER';
COMMENT ON VIEW match_score_submissions IS 'Match score submissions view without SECURITY DEFINER';
