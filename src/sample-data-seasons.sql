-- Beispieldaten für vergangene Saisons
-- Sommersaison 2023 und Wintersaison 2024

-- Sommersaison 2023
INSERT INTO seasons (id, name, year, status, start_date, end_date) VALUES
(gen_random_uuid(), 'Sommersaison 2023', 2023, 'completed', '2023-04-01', '2023-09-30');

-- Wintersaison 2024
INSERT INTO seasons (id, name, year, status, start_date, end_date) VALUES
(gen_random_uuid(), 'Wintersaison 2024', 2024, 'completed', '2024-01-01', '2024-03-31');

-- Verknüpfe Teams mit Saisons (alle Teams haben in beiden Saisons gespielt)
INSERT INTO season_teams (season_id, team_id)
SELECT 
    (SELECT id FROM seasons WHERE name = 'Sommersaison 2023'),
    id
FROM teams;

INSERT INTO season_teams (season_id, team_id)
SELECT 
    (SELECT id FROM seasons WHERE name = 'Wintersaison 2024'),
    id
FROM teams;

-- Beispiel-Spiele für Sommersaison 2023
INSERT INTO matches (id, home_team_id, away_team_id, home_score, away_score, matchday, match_date, status, season_id) VALUES
-- Spieltag 1
(gen_random_uuid(), 
 (SELECT id FROM teams WHERE name = 'FC Werdersee'), 
 (SELECT id FROM teams WHERE name = 'SV Neustadt'), 
 2, 1, 1, '2023-04-15', 'completed', 
 (SELECT id FROM seasons WHERE name = 'Sommersaison 2023')),

(gen_random_uuid(), 
 (SELECT id FROM teams WHERE name = 'Bremer SV'), 
 (SELECT id FROM teams WHERE name = 'FC Vahr'), 
 0, 3, 1, '2023-04-15', 'completed', 
 (SELECT id FROM seasons WHERE name = 'Sommersaison 2023')),

(gen_random_uuid(), 
 (SELECT id FROM teams WHERE name = 'TSV Findorff'), 
 (SELECT id FROM teams WHERE name = 'SG Aumund'), 
 1, 1, 1, '2023-04-15', 'completed', 
 (SELECT id FROM seasons WHERE name = 'Sommersaison 2023')),

-- Spieltag 2
(gen_random_uuid(), 
 (SELECT id FROM teams WHERE name = 'SV Neustadt'), 
 (SELECT id FROM teams WHERE name = 'Bremer SV'), 
 2, 0, 2, '2023-04-22', 'completed', 
 (SELECT id FROM seasons WHERE name = 'Sommersaison 2023')),

(gen_random_uuid(), 
 (SELECT id FROM teams WHERE name = 'FC Vahr'), 
 (SELECT id FROM teams WHERE name = 'TSV Findorff'), 
 3, 2, 2, '2023-04-22', 'completed', 
 (SELECT id FROM seasons WHERE name = 'Sommersaison 2023')),

(gen_random_uuid(), 
 (SELECT id FROM teams WHERE name = 'SG Aumund'), 
 (SELECT id FROM teams WHERE name = 'FC Werdersee'), 
 1, 4, 2, '2023-04-22', 'completed', 
 (SELECT id FROM seasons WHERE name = 'Sommersaison 2023')),

-- Spieltag 3
(gen_random_uuid(), 
 (SELECT id FROM teams WHERE name = 'FC Werdersee'), 
 (SELECT id FROM teams WHERE name = 'FC Vahr'), 
 2, 2, 3, '2023-04-29', 'completed', 
 (SELECT id FROM seasons WHERE name = 'Sommersaison 2023')),

(gen_random_uuid(), 
 (SELECT id FROM teams WHERE name = 'Bremer SV'), 
 (SELECT id FROM teams WHERE name = 'SG Aumund'), 
 1, 0, 3, '2023-04-29', 'completed', 
 (SELECT id FROM seasons WHERE name = 'Sommersaison 2023')),

(gen_random_uuid(), 
 (SELECT id FROM teams WHERE name = 'TSV Findorff'), 
 (SELECT id FROM teams WHERE name = 'SV Neustadt'), 
 3, 1, 3, '2023-04-29', 'completed', 
 (SELECT id FROM seasons WHERE name = 'Sommersaison 2023')),

-- Spieltag 4
(gen_random_uuid(), 
 (SELECT id FROM teams WHERE name = 'SV Neustadt'), 
 (SELECT id FROM teams WHERE name = 'FC Werdersee'), 
 0, 2, 4, '2023-05-06', 'completed', 
 (SELECT id FROM seasons WHERE name = 'Sommersaison 2023')),

(gen_random_uuid(), 
 (SELECT id FROM teams WHERE name = 'FC Vahr'), 
 (SELECT id FROM teams WHERE name = 'Bremer SV'), 
 2, 1, 4, '2023-05-06', 'completed', 
 (SELECT id FROM seasons WHERE name = 'Sommersaison 2023')),

(gen_random_uuid(), 
 (SELECT id FROM teams WHERE name = 'SG Aumund'), 
 (SELECT id FROM teams WHERE name = 'TSV Findorff'), 
 2, 3, 4, '2023-05-06', 'completed', 
 (SELECT id FROM seasons WHERE name = 'Sommersaison 2023')),

-- Spieltag 5 (Rückrunde)
(gen_random_uuid(), 
 (SELECT id FROM teams WHERE name = 'FC Werdersee'), 
 (SELECT id FROM teams WHERE name = 'Bremer SV'), 
 3, 0, 5, '2023-05-13', 'completed', 
 (SELECT id FROM seasons WHERE name = 'Sommersaison 2023')),

(gen_random_uuid(), 
 (SELECT id FROM teams WHERE name = 'TSV Findorff'), 
 (SELECT id FROM teams WHERE name = 'FC Vahr'), 
 1, 2, 5, '2023-05-13', 'completed', 
 (SELECT id FROM seasons WHERE name = 'Sommersaison 2023')),

(gen_random_uuid(), 
 (SELECT id FROM teams WHERE name = 'SV Neustadt'), 
 (SELECT id FROM teams WHERE name = 'SG Aumund'), 
 2, 1, 5, '2023-05-13', 'completed', 
 (SELECT id FROM seasons WHERE name = 'Sommersaison 2023'));

-- Beispiel-Spiele für Wintersaison 2024
INSERT INTO matches (id, home_team_id, away_team_id, home_score, away_score, matchday, match_date, status, season_id) VALUES
-- Spieltag 1
(gen_random_uuid(), 
 (SELECT id FROM teams WHERE name = 'FC Borgfeld'), 
 (SELECT id FROM teams WHERE name = 'FC Werdersee'), 
 1, 3, 1, '2024-01-07', 'completed', 
 (SELECT id FROM seasons WHERE name = 'Wintersaison 2024')),

(gen_random_uuid(), 
 (SELECT id FROM teams WHERE name = 'SV Grohn'), 
 (SELECT id FROM teams WHERE name = 'SV Neustadt'), 
 2, 0, 1, '2024-01-07', 'completed', 
 (SELECT id FROM seasons WHERE name = 'Wintersaison 2024')),

(gen_random_uuid(), 
 (SELECT id FROM teams WHERE name = 'FC Schwachhausen'), 
 (SELECT id FROM teams WHERE name = 'TSV Findorff'), 
 1, 1, 1, '2024-01-07', 'completed', 
 (SELECT id FROM seasons WHERE name = 'Wintersaison 2024')),

-- Spieltag 2
(gen_random_uuid(), 
 (SELECT id FROM teams WHERE name = 'FC Werdersee'), 
 (SELECT id FROM teams WHERE name = 'SV Grohn'), 
 2, 1, 2, '2024-01-14', 'completed', 
 (SELECT id FROM seasons WHERE name = 'Wintersaison 2024')),

(gen_random_uuid(), 
 (SELECT id FROM teams WHERE name = 'SV Neustadt'), 
 (SELECT id FROM teams WHERE name = 'FC Schwachhausen'), 
 3, 2, 2, '2024-01-14', 'completed', 
 (SELECT id FROM seasons WHERE name = 'Wintersaison 2024')),

(gen_random_uuid(), 
 (SELECT id FROM teams WHERE name = 'TSV Findorff'), 
 (SELECT id FROM teams WHERE name = 'FC Borgfeld'), 
 0, 1, 2, '2024-01-14', 'completed', 
 (SELECT id FROM seasons WHERE name = 'Wintersaison 2024')),

-- Spieltag 3
(gen_random_uuid(), 
 (SELECT id FROM teams WHERE name = 'SV Grohn'), 
 (SELECT id FROM teams WHERE name = 'TSV Findorff'), 
 1, 2, 3, '2024-01-21', 'completed', 
 (SELECT id FROM seasons WHERE name = 'Wintersaison 2024')),

(gen_random_uuid(), 
 (SELECT id FROM teams WHERE name = 'FC Borgfeld'), 
 (SELECT id FROM teams WHERE name = 'SV Neustadt'), 
 2, 2, 3, '2024-01-21', 'completed', 
 (SELECT id FROM seasons WHERE name = 'Wintersaison 2024')),

(gen_random_uuid(), 
 (SELECT id FROM teams WHERE name = 'FC Schwachhausen'), 
 (SELECT id FROM teams WHERE name = 'FC Werdersee'), 
 0, 4, 3, '2024-01-21', 'completed', 
 (SELECT id FROM seasons WHERE name = 'Wintersaison 2024')),

-- Spieltag 4
(gen_random_uuid(), 
 (SELECT id FROM teams WHERE name = 'FC Werdersee'), 
 (SELECT id FROM teams WHERE name = 'TSV Findorff'), 
 3, 1, 4, '2024-01-28', 'completed', 
 (SELECT id FROM seasons WHERE name = 'Wintersaison 2024')),

(gen_random_uuid(), 
 (SELECT id FROM teams WHERE name = 'SV Neustadt'), 
 (SELECT id FROM teams WHERE name = 'FC Borgfeld'), 
 1, 0, 4, '2024-01-28', 'completed', 
 (SELECT id FROM seasons WHERE name = 'Wintersaison 2024')),

(gen_random_uuid(), 
 (SELECT id FROM teams WHERE name = 'SV Grohn'), 
 (SELECT id FROM teams WHERE name = 'FC Schwachhausen'), 
 2, 1, 4, '2024-01-28', 'completed', 
 (SELECT id FROM seasons WHERE name = 'Wintersaison 2024')),

-- Spieltag 5 (Rückrunde)
(gen_random_uuid(), 
 (SELECT id FROM teams WHERE name = 'TSV Findorff'), 
 (SELECT id FROM teams WHERE name = 'SV Neustadt'), 
 2, 0, 5, '2024-02-04', 'completed', 
 (SELECT id FROM seasons WHERE name = 'Wintersaison 2024')),

(gen_random_uuid(), 
 (SELECT id FROM teams WHERE name = 'FC Borgfeld'), 
 (SELECT id FROM teams WHERE name = 'SV Grohn'), 
 1, 1, 5, '2024-02-04', 'completed', 
 (SELECT id FROM seasons WHERE name = 'Wintersaison 2024')),

(gen_random_uuid(), 
 (SELECT id FROM teams WHERE name = 'FC Schwachhausen'), 
 (SELECT id FROM teams WHERE name = 'FC Borgfeld'), 
 0, 2, 5, '2024-02-04', 'completed', 
 (SELECT id FROM seasons WHERE name = 'Wintersaison 2024')),

-- Spieltag 6 (Finale)
(gen_random_uuid(), 
 (SELECT id FROM teams WHERE name = 'FC Werdersee'), 
 (SELECT id FROM teams WHERE name = 'SV Neustadt'), 
 4, 0, 6, '2024-02-11', 'completed', 
 (SELECT id FROM seasons WHERE name = 'Wintersaison 2024')),

(gen_random_uuid(), 
 (SELECT id FROM teams WHERE name = 'TSV Findorff'), 
 (SELECT id FROM teams WHERE name = 'SV Grohn'), 
 3, 2, 6, '2024-02-11', 'completed', 
 (SELECT id FROM seasons WHERE name = 'Wintersaison 2024')),

(gen_random_uuid(), 
 (SELECT id FROM teams WHERE name = 'FC Borgfeld'), 
 (SELECT id FROM teams WHERE name = 'FC Schwachhausen'), 
 1, 0, 6, '2024-02-11', 'completed', 
 (SELECT id FROM seasons WHERE name = 'Wintersaison 2024'));

-- Beispiel-Achievements für die vergangenen Saisons
INSERT INTO achievements (team_id, title, year, icon) VALUES
-- Sommersaison 2023
((SELECT id FROM teams WHERE name = 'FC Werdersee'), 'Sommermeister 2023', 2023, '🏆'),
((SELECT id FROM teams WHERE name = 'FC Vahr'), 'Vizemeister Sommer 2023', 2023, '🥈'),
((SELECT id FROM teams WHERE name = 'TSV Findorff'), 'Fairplay Award 2023', 2023, '👥'),

-- Wintersaison 2024
((SELECT id FROM teams WHERE name = 'FC Werdersee'), 'Wintermeister 2024', 2024, '🏆'),
((SELECT id FROM teams WHERE name = 'TSV Findorff'), 'Vizemeister Winter 2024', 2024, '🥈'),
((SELECT id FROM teams WHERE name = 'FC Borgfeld'), 'Torschützenkönig 2024', 2024, '⚽');

-- Erweitere die achievements Tabelle um season_id falls noch nicht vorhanden
ALTER TABLE achievements ADD COLUMN IF NOT EXISTS season_id UUID REFERENCES seasons(id);

-- Aktualisiere bestehende achievements mit der aktuellen Saison
UPDATE achievements 
SET season_id = (SELECT id FROM seasons WHERE name = 'Saison 2024/25')
WHERE season_id IS NULL;

-- Verknüpfe die neuen Achievements mit den entsprechenden Saisons
UPDATE achievements 
SET season_id = (SELECT id FROM seasons WHERE name = 'Sommersaison 2023')
WHERE title LIKE '%2023%' AND season_id IS NULL;

UPDATE achievements 
SET season_id = (SELECT id FROM seasons WHERE name = 'Wintersaison 2024')
WHERE title LIKE '%2024%' AND season_id IS NULL;

-- Kommentar: Die Beispieldaten zeigen realistische Ergebnisse mit:
-- - FC Wilde Kicker als dominantes Team in beiden Saisons
-- - Ausgeglichene Ergebnisse zwischen den anderen Teams
-- - Verschiedene Torverteilungen und Unentschieden
-- - Achievements für Meister, Vizemeister und Fairplay
