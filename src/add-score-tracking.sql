-- Add score tracking fields to matches table
-- Wilde Liga Bremen - Spielstand-Übermittlung

-- Add columns to track score submission
ALTER TABLE matches 
ADD COLUMN IF NOT EXISTS score_submitted_by UUID REFERENCES user_profiles(id),
ADD COLUMN IF NOT EXISTS score_submitted_at TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS notes TEXT;

-- Add index for better performance
CREATE INDEX IF NOT EXISTS idx_matches_score_submitted_by ON matches(score_submitted_by);
CREATE INDEX IF NOT EXISTS idx_matches_score_submitted_at ON matches(score_submitted_at);

-- Add comment to explain the fields
COMMENT ON COLUMN matches.score_submitted_by IS 'UUID of the contact person who submitted the score';
COMMENT ON COLUMN matches.score_submitted_at IS 'Timestamp when the score was submitted';
COMMENT ON COLUMN matches.notes IS 'Optional notes about the match from the contact person';

-- Create a view to easily see score submissions
CREATE OR REPLACE VIEW match_score_submissions AS
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

-- Grant access to the view
GRANT SELECT ON match_score_submissions TO authenticated;

-- Update RLS policies to allow contact persons to update their team's matches
CREATE POLICY "Contact persons can update their team matches" ON matches
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM user_profiles 
            WHERE user_profiles.id = auth.uid() 
            AND user_profiles.role = 'contact_person'
            AND (user_profiles.team_id = matches.home_team_id OR user_profiles.team_id = matches.away_team_id)
        )
    );

-- Show current matches status
SELECT 
    s.name as season,
    COUNT(*) as total_matches,
    COUNT(CASE WHEN m.home_score IS NOT NULL THEN 1 END) as completed_matches,
    COUNT(CASE WHEN m.home_score IS NULL THEN 1 END) as pending_matches
FROM matches m
JOIN seasons s ON m.season_id = s.id
WHERE s.status = 'active'
GROUP BY s.id, s.name;
