-- Wilde Liga Bremen Database Schema

-- Teams table
CREATE TABLE teams (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    short_name VARCHAR(20),
    logo_url TEXT,
    description TEXT,
    founded INTEGER,
    stadium VARCHAR(100),
    colors VARCHAR(50),
    coach VARCHAR(100),
    email VARCHAR(100),
    training_days TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Players table
CREATE TABLE players (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    team_id UUID REFERENCES teams(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    position VARCHAR(50),
    jersey_number INTEGER,
    age INTEGER,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Matches table
CREATE TABLE matches (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    home_team_id UUID REFERENCES teams(id),
    away_team_id UUID REFERENCES teams(id),
    home_score INTEGER,
    away_score INTEGER,
    matchday INTEGER NOT NULL,
    match_date DATE,
    status VARCHAR(20) DEFAULT 'completed', -- completed, scheduled, live
    created_at TIMESTAMP DEFAULT NOW()
);

-- Achievements table
CREATE TABLE achievements (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    team_id UUID REFERENCES teams(id) ON DELETE CASCADE,
    title VARCHAR(100) NOT NULL,
    year INTEGER,
    icon VARCHAR(10),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Insert sample teams
INSERT INTO teams (name, short_name, description, stadium, coach, email, training_days) VALUES
('FC Werdersee', 'FCW', 'Tabellenführer mit starker Offensive', 'Werdersee-Sportplatz', 'Marcus Hoffmann', 'info@fc-werdersee.de', 'Dienstag & Donnerstag 19:00 Uhr'),
('SV Neustadt', 'SVN', 'Erfahrenes Team mit starker Defensive', 'Neustadt-Arena', 'Frank Lorenz', 'kontakt@sv-neustadt.de', 'Montag & Mittwoch 19:30 Uhr'),
('Bremer SV', 'BSV', 'Traditioneller Verein mit jungen Talenten', 'Bremer Sportpark', 'Thomas Klein', 'info@bremer-sv.de', 'Dienstag & Donnerstag 19:00 Uhr'),
('FC Vahr', 'FCV', 'Kampfstarkes Team aus dem Stadtteil', 'Vahr-Stadion', 'Michael Bauer', 'team@fc-vahr.de', 'Montag & Mittwoch 19:00 Uhr'),
('TSV Findorff', 'TSF', 'Solide Mittelfeldmannschaft', 'Findorff-Platz', 'Stefan Wolf', 'kontakt@tsv-findorff.de', 'Dienstag & Freitag 19:00 Uhr'),
('SG Aumund', 'SGA', 'Aufstrebende Spielgemeinschaft', 'Aumund-Arena', 'Oliver Schmidt', 'info@sg-aumund.de', 'Montag & Donnerstag 19:30 Uhr'),
('FC Borgfeld', 'FCB', 'Kämpferisches Team mit Herz', 'Borgfeld-Stadion', 'Andreas Müller', 'team@fc-borgfeld.de', 'Dienstag & Donnerstag 19:00 Uhr'),
('SV Grohn', 'SVG', 'Unentschieden-Spezialisten', 'Grohn-Sportplatz', 'Daniel Richter', 'kontakt@sv-grohn.de', 'Montag & Mittwoch 19:00 Uhr'),
('FC Schwachhausen', 'FCS', 'Junge Mannschaft im Aufbau', 'Schwachhausen-Platz', 'Robert Fischer', 'info@fc-schwachhausen.de', 'Dienstag & Donnerstag 19:30 Uhr'),
('TSV Lesum', 'TSL', 'Neues Team mit viel Potential', 'Lesum-Arena', 'Christian Weber', 'team@tsv-lesum.de', 'Montag & Freitag 19:00 Uhr');

-- Insert sample players for FC Werdersee
INSERT INTO players (team_id, name, position, jersey_number) VALUES
((SELECT id FROM teams WHERE name = 'FC Werdersee'), 'Thomas Müller', 'Torwart', 1),
((SELECT id FROM teams WHERE name = 'FC Werdersee'), 'Stefan Weber', 'Verteidiger', 4),
((SELECT id FROM teams WHERE name = 'FC Werdersee'), 'Marco Schmidt', 'Mittelfeld', 7),
((SELECT id FROM teams WHERE name = 'FC Werdersee'), 'Kevin Richter', 'Spielmacher', 10),
((SELECT id FROM teams WHERE name = 'FC Werdersee'), 'Jan Neumann', 'Stürmer', 11),
((SELECT id FROM teams WHERE name = 'FC Werdersee'), 'Mike Fischer', 'Stürmer', 9);

-- Insert sample matches for multiple matchdays
-- Spieltag 1 (2024-08-17)
INSERT INTO matches (home_team_id, away_team_id, home_score, away_score, matchday, match_date) VALUES
((SELECT id FROM teams WHERE name = 'FC Werdersee'), (SELECT id FROM teams WHERE name = 'SV Neustadt'), 2, 1, 1, '2024-08-17'),
((SELECT id FROM teams WHERE name = 'Bremer SV'), (SELECT id FROM teams WHERE name = 'FC Vahr'), 1, 0, 1, '2024-08-17'),
((SELECT id FROM teams WHERE name = 'TSV Findorff'), (SELECT id FROM teams WHERE name = 'SG Aumund'), 3, 2, 1, '2024-08-17'),
((SELECT id FROM teams WHERE name = 'FC Borgfeld'), (SELECT id FROM teams WHERE name = 'SV Grohn'), 1, 1, 1, '2024-08-17'),
((SELECT id FROM teams WHERE name = 'FC Schwachhausen'), (SELECT id FROM teams WHERE name = 'TSV Lesum'), 0, 3, 1, '2024-08-17');

-- Spieltag 2 (2024-08-24)
INSERT INTO matches (home_team_id, away_team_id, home_score, away_score, matchday, match_date) VALUES
((SELECT id FROM teams WHERE name = 'SV Neustadt'), (SELECT id FROM teams WHERE name = 'Bremer SV'), 2, 2, 2, '2024-08-24'),
((SELECT id FROM teams WHERE name = 'FC Vahr'), (SELECT id FROM teams WHERE name = 'TSV Findorff'), 1, 2, 2, '2024-08-24'),
((SELECT id FROM teams WHERE name = 'SG Aumund'), (SELECT id FROM teams WHERE name = 'FC Borgfeld'), 0, 1, 2, '2024-08-24'),
((SELECT id FROM teams WHERE name = 'SV Grohn'), (SELECT id FROM teams WHERE name = 'FC Schwachhausen'), 3, 0, 2, '2024-08-24'),
((SELECT id FROM teams WHERE name = 'TSV Lesum'), (SELECT id FROM teams WHERE name = 'FC Werdersee'), 1, 4, 2, '2024-08-24');

-- Spieltag 3 (2024-08-31)
INSERT INTO matches (home_team_id, away_team_id, home_score, away_score, matchday, match_date) VALUES
((SELECT id FROM teams WHERE name = 'FC Werdersee'), (SELECT id FROM teams WHERE name = 'FC Vahr'), 3, 0, 3, '2024-08-31'),
((SELECT id FROM teams WHERE name = 'Bremer SV'), (SELECT id FROM teams WHERE name = 'SG Aumund'), 2, 1, 3, '2024-08-31'),
((SELECT id FROM teams WHERE name = 'TSV Findorff'), (SELECT id FROM teams WHERE name = 'SV Grohn'), 1, 1, 3, '2024-08-31'),
((SELECT id FROM teams WHERE name = 'FC Borgfeld'), (SELECT id FROM teams WHERE name = 'TSV Lesum'), 2, 0, 3, '2024-08-31'),
((SELECT id FROM teams WHERE name = 'FC Schwachhausen'), (SELECT id FROM teams WHERE name = 'SV Neustadt'), 1, 2, 3, '2024-08-31');

-- Spieltag 4 (2024-09-07)
INSERT INTO matches (home_team_id, away_team_id, home_score, away_score, matchday, match_date) VALUES
((SELECT id FROM teams WHERE name = 'SV Neustadt'), (SELECT id FROM teams WHERE name = 'TSV Findorff'), 0, 0, 4, '2024-09-07'),
((SELECT id FROM teams WHERE name = 'FC Vahr'), (SELECT id FROM teams WHERE name = 'Bremer SV'), 2, 3, 4, '2024-09-07'),
((SELECT id FROM teams WHERE name = 'SG Aumund'), (SELECT id FROM teams WHERE name = 'FC Schwachhausen'), 1, 0, 4, '2024-09-07'),
((SELECT id FROM teams WHERE name = 'SV Grohn'), (SELECT id FROM teams WHERE name = 'FC Borgfeld'), 1, 2, 4, '2024-09-07'),
((SELECT id FROM teams WHERE name = 'TSV Lesum'), (SELECT id FROM teams WHERE name = 'FC Werdersee'), 0, 5, 4, '2024-09-07');

-- Spieltag 5 (2024-09-14)
INSERT INTO matches (home_team_id, away_team_id, home_score, away_score, matchday, match_date) VALUES
((SELECT id FROM teams WHERE name = 'FC Werdersee'), (SELECT id FROM teams WHERE name = 'SG Aumund'), 2, 1, 5, '2024-09-14'),
((SELECT id FROM teams WHERE name = 'Bremer SV'), (SELECT id FROM teams WHERE name = 'SV Grohn'), 1, 0, 5, '2024-09-14'),
((SELECT id FROM teams WHERE name = 'TSV Findorff'), (SELECT id FROM teams WHERE name = 'TSV Lesum'), 3, 1, 5, '2024-09-14'),
((SELECT id FROM teams WHERE name = 'FC Borgfeld'), (SELECT id FROM teams WHERE name = 'FC Schwachhausen'), 0, 1, 5, '2024-09-14'),
((SELECT id FROM teams WHERE name = 'FC Vahr'), (SELECT id FROM teams WHERE name = 'SV Neustadt'), 2, 2, 5, '2024-09-14');

-- Spieltag 6 (2024-09-21)
INSERT INTO matches (home_team_id, away_team_id, home_score, away_score, matchday, match_date) VALUES
((SELECT id FROM teams WHERE name = 'SV Neustadt'), (SELECT id FROM teams WHERE name = 'FC Borgfeld'), 1, 0, 6, '2024-09-21'),
((SELECT id FROM teams WHERE name = 'SG Aumund'), (SELECT id FROM teams WHERE name = 'FC Vahr'), 3, 2, 6, '2024-09-21'),
((SELECT id FROM teams WHERE name = 'SV Grohn'), (SELECT id FROM teams WHERE name = 'TSV Findorff'), 2, 1, 6, '2024-09-21'),
((SELECT id FROM teams WHERE name = 'TSV Lesum'), (SELECT id FROM teams WHERE name = 'Bremer SV'), 1, 3, 6, '2024-09-21'),
((SELECT id FROM teams WHERE name = 'FC Schwachhausen'), (SELECT id FROM teams WHERE name = 'FC Werdersee'), 0, 4, 6, '2024-09-21');

-- Spieltag 7 (2024-09-28)
INSERT INTO matches (home_team_id, away_team_id, home_score, away_score, matchday, match_date) VALUES
((SELECT id FROM teams WHERE name = 'FC Werdersee'), (SELECT id FROM teams WHERE name = 'SV Grohn'), 3, 1, 7, '2024-09-28'),
((SELECT id FROM teams WHERE name = 'Bremer SV'), (SELECT id FROM teams WHERE name = 'FC Schwachhausen'), 2, 0, 7, '2024-09-28'),
((SELECT id FROM teams WHERE name = 'TSV Findorff'), (SELECT id FROM teams WHERE name = 'FC Borgfeld'), 1, 2, 7, '2024-09-28'),
((SELECT id FROM teams WHERE name = 'FC Vahr'), (SELECT id FROM teams WHERE name = 'TSV Lesum'), 4, 1, 7, '2024-09-28'),
((SELECT id FROM teams WHERE name = 'SG Aumund'), (SELECT id FROM teams WHERE name = 'SV Neustadt'), 1, 1, 7, '2024-09-28');

-- Spieltag 8 (2024-10-05)
INSERT INTO matches (home_team_id, away_team_id, home_score, away_score, matchday, match_date) VALUES
((SELECT id FROM teams WHERE name = 'SV Neustadt'), (SELECT id FROM teams WHERE name = 'FC Vahr'), 2, 0, 8, '2024-10-05'),
((SELECT id FROM teams WHERE name = 'FC Borgfeld'), (SELECT id FROM teams WHERE name = 'SG Aumund'), 1, 3, 8, '2024-10-05'),
((SELECT id FROM teams WHERE name = 'SV Grohn'), (SELECT id FROM teams WHERE name = 'Bremer SV'), 0, 2, 8, '2024-10-05'),
((SELECT id FROM teams WHERE name = 'TSV Lesum'), (SELECT id FROM teams WHERE name = 'TSV Findorff'), 2, 2, 8, '2024-10-05'),
((SELECT id FROM teams WHERE name = 'FC Schwachhausen'), (SELECT id FROM teams WHERE name = 'FC Werdersee'), 1, 3, 8, '2024-10-05');

-- Spieltag 9 (2024-10-12)
INSERT INTO matches (home_team_id, away_team_id, home_score, away_score, matchday, match_date) VALUES
((SELECT id FROM teams WHERE name = 'FC Werdersee'), (SELECT id FROM teams WHERE name = 'FC Borgfeld'), 1, 0, 9, '2024-10-12'),
((SELECT id FROM teams WHERE name = 'Bremer SV'), (SELECT id FROM teams WHERE name = 'TSV Lesum'), 3, 1, 9, '2024-10-12'),
((SELECT id FROM teams WHERE name = 'TSV Findorff'), (SELECT id FROM teams WHERE name = 'FC Schwachhausen'), 2, 1, 9, '2024-10-12'),
((SELECT id FROM teams WHERE name = 'FC Vahr'), (SELECT id FROM teams WHERE name = 'SV Grohn'), 1, 1, 9, '2024-10-12'),
((SELECT id FROM teams WHERE name = 'SG Aumund'), (SELECT id FROM teams WHERE name = 'SV Neustadt'), 0, 2, 9, '2024-10-12');

-- Kommende Spiele (ohne Ergebnisse) - Spieltag 10
INSERT INTO matches (home_team_id, away_team_id, home_score, away_score, matchday, match_date, status) VALUES
((SELECT id FROM teams WHERE name = 'SV Neustadt'), (SELECT id FROM teams WHERE name = 'FC Werdersee'), NULL, NULL, 10, '2024-10-19', 'scheduled'),
((SELECT id FROM teams WHERE name = 'FC Borgfeld'), (SELECT id FROM teams WHERE name = 'FC Vahr'), NULL, NULL, 10, '2024-10-19', 'scheduled'),
((SELECT id FROM teams WHERE name = 'SV Grohn'), (SELECT id FROM teams WHERE name = 'SG Aumund'), NULL, NULL, 10, '2024-10-19', 'scheduled'),
((SELECT id FROM teams WHERE name = 'TSV Lesum'), (SELECT id FROM teams WHERE name = 'TSV Findorff'), NULL, NULL, 10, '2024-10-19', 'scheduled'),
((SELECT id FROM teams WHERE name = 'FC Schwachhausen'), (SELECT id FROM teams WHERE name = 'Bremer SV'), NULL, NULL, 10, '2024-10-19', 'scheduled');

-- Kommende Spiele - Spieltag 11
INSERT INTO matches (home_team_id, away_team_id, home_score, away_score, matchday, match_date, status) VALUES
((SELECT id FROM teams WHERE name = 'FC Werdersee'), (SELECT id FROM teams WHERE name = 'TSV Findorff'), NULL, NULL, 11, '2024-10-26', 'scheduled'),
((SELECT id FROM teams WHERE name = 'Bremer SV'), (SELECT id FROM teams WHERE name = 'SV Neustadt'), NULL, NULL, 11, '2024-10-26', 'scheduled'),
((SELECT id FROM teams WHERE name = 'FC Vahr'), (SELECT id FROM teams WHERE name = 'FC Schwachhausen'), NULL, NULL, 11, '2024-10-26', 'scheduled'),
((SELECT id FROM teams WHERE name = 'SG Aumund'), (SELECT id FROM teams WHERE name = 'TSV Lesum'), NULL, NULL, 11, '2024-10-26', 'scheduled'),
((SELECT id FROM teams WHERE name = 'FC Borgfeld'), (SELECT id FROM teams WHERE name = 'SV Grohn'), NULL, NULL, 11, '2024-10-26', 'scheduled');

-- Insert sample achievements
INSERT INTO achievements (team_id, title, year, icon) VALUES
((SELECT id FROM teams WHERE name = 'FC Werdersee'), 'Liga-Meister', 2019, '🏆'),
((SELECT id FROM teams WHERE name = 'FC Werdersee'), 'Liga-Meister', 2021, '🏆'),
((SELECT id FROM teams WHERE name = 'FC Werdersee'), 'Pokalsieger', 2020, '🥇'),
((SELECT id FROM teams WHERE name = 'FC Werdersee'), 'Beste Offensive', 2023, '⚽'),
((SELECT id FROM teams WHERE name = 'FC Werdersee'), 'Beste Defensive', 2024, '🛡️');

-- User profiles table for roles
CREATE TABLE user_profiles (
    id UUID REFERENCES auth.users(id) PRIMARY KEY,
    email TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'user', -- 'admin', 'team_captain', 'user'
    team_id UUID REFERENCES teams(id) ON DELETE CASCADE, -- nur für team_captain
    name VARCHAR(100),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Enable RLS on user_profiles
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- Enable RLS on existing tables
ALTER TABLE teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE players ENABLE ROW LEVEL SECURITY;
ALTER TABLE matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE achievements ENABLE ROW LEVEL SECURITY;

-- Policies for user_profiles
CREATE POLICY "Users can view their own profile" ON user_profiles FOR SELECT USING (id = auth.uid());
CREATE POLICY "Users can update their own profile" ON user_profiles FOR UPDATE USING (id = auth.uid());
CREATE POLICY "Admins can view all profiles" ON user_profiles FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM user_profiles 
        WHERE user_profiles.id = auth.uid() 
        AND user_profiles.role = 'admin'
    )
);
CREATE POLICY "Admins can manage all profiles" ON user_profiles FOR ALL USING (
    EXISTS (
        SELECT 1 FROM user_profiles 
        WHERE user_profiles.id = auth.uid() 
        AND user_profiles.role = 'admin'
    )
);

-- Policies for teams
CREATE POLICY "Public can view teams" ON teams FOR SELECT TO public USING (true);
CREATE POLICY "Admins can manage teams" ON teams FOR ALL USING (
    EXISTS (
        SELECT 1 FROM user_profiles 
        WHERE user_profiles.id = auth.uid() 
        AND user_profiles.role = 'admin'
    )
);
CREATE POLICY "Team captains can update their team" ON teams FOR UPDATE USING (
    EXISTS (
        SELECT 1 FROM user_profiles 
        WHERE user_profiles.id = auth.uid() 
        AND user_profiles.role = 'team_captain'
        AND user_profiles.team_id = teams.id
    )
);

-- Policies for players
CREATE POLICY "Public can view players" ON players FOR SELECT TO public USING (true);
CREATE POLICY "Admins can manage players" ON players FOR ALL USING (
    EXISTS (
        SELECT 1 FROM user_profiles 
        WHERE user_profiles.id = auth.uid() 
        AND user_profiles.role = 'admin'
    )
);
CREATE POLICY "Team captains can manage their team players" ON players FOR ALL USING (
    EXISTS (
        SELECT 1 FROM user_profiles 
        WHERE user_profiles.id = auth.uid() 
        AND user_profiles.role = 'team_captain'
        AND user_profiles.team_id = players.team_id
    )
);

-- Policies for matches
CREATE POLICY "Public can view matches" ON matches FOR SELECT TO public USING (true);
CREATE POLICY "Admins can manage matches" ON matches FOR ALL USING (
    EXISTS (
        SELECT 1 FROM user_profiles 
        WHERE user_profiles.id = auth.uid() 
        AND user_profiles.role = 'admin'
    )
);
CREATE POLICY "Team captains can update their team matches" ON matches FOR UPDATE USING (
    EXISTS (
        SELECT 1 FROM user_profiles 
        WHERE user_profiles.id = auth.uid() 
        AND user_profiles.role = 'team_captain'
        AND (user_profiles.team_id = matches.home_team_id OR user_profiles.team_id = matches.away_team_id)
    )
);

-- Policies for achievements
CREATE POLICY "Public can view achievements" ON achievements FOR SELECT TO public USING (true);
CREATE POLICY "Admins can manage achievements" ON achievements FOR ALL USING (
    EXISTS (
        SELECT 1 FROM user_profiles 
        WHERE user_profiles.id = auth.uid() 
        AND user_profiles.role = 'admin'
    )
);
CREATE POLICY "Team captains can manage their team achievements" ON achievements FOR ALL USING (
    EXISTS (
        SELECT 1 FROM user_profiles 
        WHERE user_profiles.id = auth.uid() 
        AND user_profiles.role = 'team_captain'
        AND user_profiles.team_id = achievements.team_id
    )
);

-- Function to handle new user registration
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
    INSERT INTO public.user_profiles (id, email, role, name)
    VALUES (
        NEW.id,
        NEW.email,
        'user',
        COALESCE(NEW.raw_user_meta_data->>'name', split_part(NEW.email, '@', 1))
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger for new user registration
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Create view for standings calculation
CREATE OR REPLACE VIEW standings AS
SELECT 
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
FROM teams t
LEFT JOIN matches m ON t.id = m.home_team_id OR t.id = m.away_team_id
WHERE m.status = 'completed'
GROUP BY t.id, t.name, t.short_name
ORDER BY points DESC, goal_difference DESC, goals_for DESC;
