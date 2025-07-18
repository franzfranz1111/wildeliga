-- Fix SECURITY DEFINER views by explicitly creating them with SECURITY INVOKER
-- This addresses the remaining security warnings

-- Drop and recreate season_standings view with SECURITY INVOKER
DROP VIEW IF EXISTS season_standings CASCADE;
CREATE VIEW season_standings 
WITH (security_invoker = true) AS
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

-- Drop and recreate standings view with SECURITY INVOKER
DROP VIEW IF EXISTS standings CASCADE;
CREATE VIEW standings 
WITH (security_invoker = true) AS
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

-- Drop and recreate match_score_submissions view with SECURITY INVOKER
DROP VIEW IF EXISTS match_score_submissions CASCADE;
CREATE VIEW match_score_submissions 
WITH (security_invoker = true) AS
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

-- Verify that views are now created with SECURITY INVOKER
SELECT 
    schemaname, 
    viewname,
    CASE 
        WHEN definition LIKE '%security_invoker%' THEN 'SECURITY INVOKER'
        WHEN definition LIKE '%security_definer%' THEN 'SECURITY DEFINER'
        ELSE 'DEFAULT (INVOKER)'
    END as security_type
FROM pg_views 
WHERE viewname IN ('season_standings', 'standings', 'match_score_submissions');

-- Show view definitions to confirm security_invoker is set
SELECT 
    schemaname,
    viewname,
    LEFT(definition, 100) as definition_start
FROM pg_views 
WHERE viewname IN ('season_standings', 'standings', 'match_score_submissions');

COMMENT ON VIEW season_standings IS 'Season standings view with SECURITY INVOKER';
COMMENT ON VIEW standings IS 'Current standings view with SECURITY INVOKER';
COMMENT ON VIEW match_score_submissions IS 'Match score submissions view with SECURITY INVOKER';
