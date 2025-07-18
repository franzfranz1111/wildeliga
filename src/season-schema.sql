-- Saison-System für Wilde Liga Bremen
-- Dieses Schema erweitert die bestehende Datenbank um Saisons

-- Saisons Tabelle
CREATE TABLE seasons (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(100) NOT NULL, -- z.B. "Saison 2024/25"
    year INTEGER NOT NULL, -- 2024
    status VARCHAR(20) DEFAULT 'active', -- active, completed, planned
    start_date DATE,
    end_date DATE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Saison-Teams Verknüpfung (viele-zu-viele)
CREATE TABLE season_teams (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    season_id UUID REFERENCES seasons(id) ON DELETE CASCADE,
    team_id UUID REFERENCES teams(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(season_id, team_id)
);

-- Matches Tabelle erweitern um season_id
ALTER TABLE matches ADD COLUMN season_id UUID REFERENCES seasons(id);

-- Erstelle die erste Saison (aktuelle Saison)
INSERT INTO seasons (name, year, status, start_date, end_date) VALUES
('Saison 2024/25', 2024, 'active', '2024-08-01', '2025-05-31');

-- Verknüpfe alle aktuellen Teams mit der ersten Saison
INSERT INTO season_teams (season_id, team_id)
SELECT 
    (SELECT id FROM seasons WHERE year = 2024),
    id
FROM teams;

-- Aktualisiere alle bestehenden Matches mit der aktuellen Saison
UPDATE matches 
SET season_id = (SELECT id FROM seasons WHERE year = 2024)
WHERE season_id IS NULL;

-- Erweiterte Standings View für spezifische Saison
CREATE OR REPLACE VIEW season_standings AS
SELECT 
    s.id as season_id,
    s.name as season_name,
    t.id,
    t.name,
    t.short_name,
    COUNT(m.id) as games_played,
    SUM(CASE 
        WHEN (m.home_team_id = t.id AND m.home_score > m.away_score) OR 
             (m.away_team_id = t.id AND m.away_score > m.home_score) 
        THEN 1 ELSE 0 
    END) as wins,
    SUM(CASE 
        WHEN m.home_score = m.away_score 
        THEN 1 ELSE 0 
    END) as draws,
    SUM(CASE 
        WHEN (m.home_team_id = t.id AND m.home_score < m.away_score) OR 
             (m.away_team_id = t.id AND m.away_score < m.home_score) 
        THEN 1 ELSE 0 
    END) as losses,
    SUM(CASE 
        WHEN m.home_team_id = t.id THEN m.home_score
        WHEN m.away_team_id = t.id THEN m.away_score
        ELSE 0 
    END) as goals_for,
    SUM(CASE 
        WHEN m.home_team_id = t.id THEN m.away_score
        WHEN m.away_team_id = t.id THEN m.home_score
        ELSE 0 
    END) as goals_against,
    SUM(CASE 
        WHEN m.home_team_id = t.id THEN m.home_score - m.away_score
        WHEN m.away_team_id = t.id THEN m.away_score - m.home_score
        ELSE 0 
    END) as goal_difference,
    SUM(CASE 
        WHEN (m.home_team_id = t.id AND m.home_score > m.away_score) OR 
             (m.away_team_id = t.id AND m.away_score > m.home_score) 
        THEN 3
        WHEN m.home_score = m.away_score 
        THEN 1
        ELSE 0 
    END) as points
FROM seasons s
INNER JOIN season_teams st ON s.id = st.season_id
INNER JOIN teams t ON st.team_id = t.id
LEFT JOIN matches m ON (t.id = m.home_team_id OR t.id = m.away_team_id) 
                    AND m.season_id = s.id 
                    AND m.status = 'completed'
GROUP BY s.id, s.name, t.id, t.name, t.short_name
ORDER BY s.year DESC, points DESC, goal_difference DESC, goals_for DESC;

-- Policies für neue Tabellen
ALTER TABLE seasons ENABLE ROW LEVEL SECURITY;
ALTER TABLE season_teams ENABLE ROW LEVEL SECURITY;

-- Öffentlicher Lesezugriff auf Saisons
CREATE POLICY "Public can view seasons" ON seasons FOR SELECT TO public USING (true);
CREATE POLICY "Public can view season_teams" ON season_teams FOR SELECT TO public USING (true);

-- Admin-Zugriff auf Saisons
CREATE POLICY "Admin manage seasons" ON seasons FOR ALL USING (
    auth.jwt() ->> 'email' IN ('admin@wilde-liga.de', 'admin@example.com')
);
CREATE POLICY "Admin manage season_teams" ON season_teams FOR ALL USING (
    auth.jwt() ->> 'email' IN ('admin@wilde-liga.de', 'admin@example.com')
);

-- Funktion um eine neue Saison zu erstellen
CREATE OR REPLACE FUNCTION create_new_season(
    p_season_name VARCHAR(100),
    p_year INTEGER,
    p_start_date DATE,
    p_end_date DATE,
    p_team_ids UUID[]
) RETURNS UUID AS $$
DECLARE
    v_season_id UUID;
    v_team_id UUID;
BEGIN
    -- Setze alle anderen Saisons auf 'completed'
    UPDATE seasons SET status = 'completed' WHERE status = 'active';
    
    -- Erstelle neue Saison
    INSERT INTO seasons (name, year, status, start_date, end_date)
    VALUES (p_season_name, p_year, 'active', p_start_date, p_end_date)
    RETURNING id INTO v_season_id;
    
    -- Füge Teams zur Saison hinzu
    FOREACH v_team_id IN ARRAY p_team_ids LOOP
        INSERT INTO season_teams (season_id, team_id)
        VALUES (v_season_id, v_team_id);
    END LOOP;
    
    RETURN v_season_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
