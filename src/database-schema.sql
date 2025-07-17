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

-- Insert sample matches for matchday 12
INSERT INTO matches (home_team_id, away_team_id, home_score, away_score, matchday, match_date) VALUES
((SELECT id FROM teams WHERE name = 'FC Werdersee'), (SELECT id FROM teams WHERE name = 'SV Neustadt'), 3, 1, 12, '2024-01-15'),
((SELECT id FROM teams WHERE name = 'Bremer SV'), (SELECT id FROM teams WHERE name = 'FC Vahr'), 2, 0, 12, '2024-01-15'),
((SELECT id FROM teams WHERE name = 'TSV Findorff'), (SELECT id FROM teams WHERE name = 'SG Aumund'), 1, 1, 12, '2024-01-15'),
((SELECT id FROM teams WHERE name = 'FC Borgfeld'), (SELECT id FROM teams WHERE name = 'SV Grohn'), 0, 2, 12, '2024-01-15'),
((SELECT id FROM teams WHERE name = 'FC Schwachhausen'), (SELECT id FROM teams WHERE name = 'TSV Lesum'), 1, 4, 12, '2024-01-15');

-- Insert sample achievements
INSERT INTO achievements (team_id, title, year, icon) VALUES
((SELECT id FROM teams WHERE name = 'FC Werdersee'), 'Liga-Meister', 2019, '🏆'),
((SELECT id FROM teams WHERE name = 'FC Werdersee'), 'Liga-Meister', 2021, '🏆'),
((SELECT id FROM teams WHERE name = 'FC Werdersee'), 'Pokalsieger', 2020, '🥇'),
((SELECT id FROM teams WHERE name = 'FC Werdersee'), 'Beste Offensive', 2023, '⚽'),
((SELECT id FROM teams WHERE name = 'FC Werdersee'), 'Beste Defensive', 2024, '🛡️');

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
