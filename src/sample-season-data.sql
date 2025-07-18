-- Beispieldaten für Saisons 2023 und 2024
-- Dieses Script fügt Beispieldaten für vergangene und aktuelle Saisons hinzu

-- Erst die alte Saison auf completed setzen
UPDATE seasons SET status = 'completed' WHERE year = 2024;

-- Saison 2023/24 hinzufügen (abgeschlossen)
INSERT INTO seasons (name, year, status, start_date, end_date) VALUES
('Saison 2023/24', 2023, 'completed', '2023-08-01', '2024-05-31');

-- Saison 2024/25 hinzufügen (aktuell aktiv)
INSERT INTO seasons (name, year, status, start_date, end_date) VALUES
('Saison 2024/25', 2024, 'active', '2024-08-01', '2025-05-31');

-- Teams für Saison 2023/24 (9 Teams - einer weniger als 2024)
-- Hinweis: TSV Lesum hat 2023 noch nicht mitgespielt
INSERT INTO season_teams (season_id, team_id)
SELECT 
    (SELECT id FROM seasons WHERE year = 2023),
    id
FROM teams 
WHERE name IN (
    'FC Werdersee', 'SV Neustadt', 'Bremer SV', 'FC Vahr', 
    'TSV Findorff', 'SG Aumund', 'FC Borgfeld', 'SV Grohn', 'FC Schwachhausen'
);

-- Teams für Saison 2024/25 (10 Teams - TSV Lesum ist neu dazugekommen)
INSERT INTO season_teams (season_id, team_id)
SELECT 
    (SELECT id FROM seasons WHERE year = 2024),
    id
FROM teams;

-- ========================================
-- SAISON 2023/24 - ABGESCHLOSSENE MATCHES
-- ========================================

-- Spieltag 1 (2023-08-19)
INSERT INTO matches (season_id, home_team_id, away_team_id, home_score, away_score, matchday, match_date, status) VALUES
((SELECT id FROM seasons WHERE year = 2023), (SELECT id FROM teams WHERE name = 'SV Neustadt'), (SELECT id FROM teams WHERE name = 'FC Werdersee'), 1, 2, 1, '2023-08-19', 'completed'),
((SELECT id FROM seasons WHERE year = 2023), (SELECT id FROM teams WHERE name = 'Bremer SV'), (SELECT id FROM teams WHERE name = 'FC Vahr'), 2, 0, 1, '2023-08-19', 'completed'),
((SELECT id FROM seasons WHERE year = 2023), (SELECT id FROM teams WHERE name = 'TSV Findorff'), (SELECT id FROM teams WHERE name = 'SG Aumund'), 1, 1, 1, '2023-08-19', 'completed'),
((SELECT id FROM seasons WHERE year = 2023), (SELECT id FROM teams WHERE name = 'FC Borgfeld'), (SELECT id FROM teams WHERE name = 'SV Grohn'), 0, 3, 1, '2023-08-19', 'completed'),
((SELECT id FROM seasons WHERE year = 2023), (SELECT id FROM teams WHERE name = 'FC Schwachhausen'), NULL, NULL, NULL, 1, '2023-08-19', 'completed'); -- Spielfrei

-- Spieltag 2 (2023-08-26)
INSERT INTO matches (season_id, home_team_id, away_team_id, home_score, away_score, matchday, match_date, status) VALUES
((SELECT id FROM seasons WHERE year = 2023), (SELECT id FROM teams WHERE name = 'FC Werdersee'), (SELECT id FROM teams WHERE name = 'Bremer SV'), 3, 0, 2, '2023-08-26', 'completed'),
((SELECT id FROM seasons WHERE year = 2023), (SELECT id FROM teams WHERE name = 'FC Vahr'), (SELECT id FROM teams WHERE name = 'TSV Findorff'), 2, 1, 2, '2023-08-26', 'completed'),
((SELECT id FROM seasons WHERE year = 2023), (SELECT id FROM teams WHERE name = 'SG Aumund'), (SELECT id FROM teams WHERE name = 'FC Borgfeld'), 1, 0, 2, '2023-08-26', 'completed'),
((SELECT id FROM seasons WHERE year = 2023), (SELECT id FROM teams WHERE name = 'SV Grohn'), (SELECT id FROM teams WHERE name = 'FC Schwachhausen'), 2, 1, 2, '2023-08-26', 'completed'),
((SELECT id FROM seasons WHERE year = 2023), (SELECT id FROM teams WHERE name = 'SV Neustadt'), NULL, NULL, NULL, 2, '2023-08-26', 'completed'); -- Spielfrei

-- Spieltag 3 (2023-09-02)
INSERT INTO matches (season_id, home_team_id, away_team_id, home_score, away_score, matchday, match_date, status) VALUES
((SELECT id FROM seasons WHERE year = 2023), (SELECT id FROM teams WHERE name = 'Bremer SV'), (SELECT id FROM teams WHERE name = 'SG Aumund'), 1, 2, 3, '2023-09-02', 'completed'),
((SELECT id FROM seasons WHERE year = 2023), (SELECT id FROM teams WHERE name = 'TSV Findorff'), (SELECT id FROM teams WHERE name = 'SV Grohn'), 2, 2, 3, '2023-09-02', 'completed'),
((SELECT id FROM seasons WHERE year = 2023), (SELECT id FROM teams WHERE name = 'FC Borgfeld'), (SELECT id FROM teams WHERE name = 'FC Schwachhausen'), 1, 0, 3, '2023-09-02', 'completed'),
((SELECT id FROM seasons WHERE year = 2023), (SELECT id FROM teams WHERE name = 'SV Neustadt'), (SELECT id FROM teams WHERE name = 'FC Vahr'), 0, 1, 3, '2023-09-02', 'completed'),
((SELECT id FROM seasons WHERE year = 2023), (SELECT id FROM teams WHERE name = 'FC Werdersee'), NULL, NULL, NULL, 3, '2023-09-02', 'completed'); -- Spielfrei

-- Weitere Spieltage für Saison 2023/24...
-- Spieltag 4 (2023-09-09)
INSERT INTO matches (season_id, home_team_id, away_team_id, home_score, away_score, matchday, match_date, status) VALUES
((SELECT id FROM seasons WHERE year = 2023), (SELECT id FROM teams WHERE name = 'FC Vahr'), (SELECT id FROM teams WHERE name = 'Bremer SV'), 1, 3, 4, '2023-09-09', 'completed'),
((SELECT id FROM seasons WHERE year = 2023), (SELECT id FROM teams WHERE name = 'SG Aumund'), (SELECT id FROM teams WHERE name = 'TSV Findorff'), 0, 2, 4, '2023-09-09', 'completed'),
((SELECT id FROM seasons WHERE year = 2023), (SELECT id FROM teams WHERE name = 'SV Grohn'), (SELECT id FROM teams WHERE name = 'FC Borgfeld'), 1, 1, 4, '2023-09-09', 'completed'),
((SELECT id FROM seasons WHERE year = 2023), (SELECT id FROM teams WHERE name = 'FC Schwachhausen'), (SELECT id FROM teams WHERE name = 'SV Neustadt'), 0, 4, 4, '2023-09-09', 'completed'),
((SELECT id FROM seasons WHERE year = 2023), (SELECT id FROM teams WHERE name = 'FC Werdersee'), NULL, NULL, NULL, 4, '2023-09-09', 'completed'); -- Spielfrei

-- Spieltag 5 (2023-09-16)
INSERT INTO matches (season_id, home_team_id, away_team_id, home_score, away_score, matchday, match_date, status) VALUES
((SELECT id FROM seasons WHERE year = 2023), (SELECT id FROM teams WHERE name = 'Bremer SV'), (SELECT id FROM teams WHERE name = 'SV Grohn'), 2, 0, 5, '2023-09-16', 'completed'),
((SELECT id FROM seasons WHERE year = 2023), (SELECT id FROM teams WHERE name = 'TSV Findorff'), (SELECT id FROM teams WHERE name = 'FC Schwachhausen'), 3, 1, 5, '2023-09-16', 'completed'),
((SELECT id FROM seasons WHERE year = 2023), (SELECT id FROM teams WHERE name = 'FC Borgfeld'), (SELECT id FROM teams WHERE name = 'SV Neustadt'), 0, 2, 5, '2023-09-16', 'completed'),
((SELECT id FROM seasons WHERE year = 2023), (SELECT id FROM teams WHERE name = 'FC Werdersee'), (SELECT id FROM teams WHERE name = 'SG Aumund'), 4, 0, 5, '2023-09-16', 'completed'),
((SELECT id FROM seasons WHERE year = 2023), (SELECT id FROM teams WHERE name = 'FC Vahr'), NULL, NULL, NULL, 5, '2023-09-16', 'completed'); -- Spielfrei

-- Spieltag 6 (2023-09-23)
INSERT INTO matches (season_id, home_team_id, away_team_id, home_score, away_score, matchday, match_date, status) VALUES
((SELECT id FROM seasons WHERE year = 2023), (SELECT id FROM teams WHERE name = 'SV Grohn'), (SELECT id FROM teams WHERE name = 'TSV Findorff'), 1, 2, 6, '2023-09-23', 'completed'),
((SELECT id FROM seasons WHERE year = 2023), (SELECT id FROM teams WHERE name = 'FC Schwachhausen'), (SELECT id FROM teams WHERE name = 'FC Borgfeld'), 1, 3, 6, '2023-09-23', 'completed'),
((SELECT id FROM seasons WHERE year = 2023), (SELECT id FROM teams WHERE name = 'SV Neustadt'), (SELECT id FROM teams WHERE name = 'FC Werdersee'), 0, 3, 6, '2023-09-23', 'completed'),
((SELECT id FROM seasons WHERE year = 2023), (SELECT id FROM teams WHERE name = 'SG Aumund'), (SELECT id FROM teams WHERE name = 'FC Vahr'), 2, 2, 6, '2023-09-23', 'completed'),
((SELECT id FROM seasons WHERE year = 2023), (SELECT id FROM teams WHERE name = 'Bremer SV'), NULL, NULL, NULL, 6, '2023-09-23', 'completed'); -- Spielfrei

-- Spieltag 7 (2023-09-30)
INSERT INTO matches (season_id, home_team_id, away_team_id, home_score, away_score, matchday, match_date, status) VALUES
((SELECT id FROM seasons WHERE year = 2023), (SELECT id FROM teams WHERE name = 'TSV Findorff'), (SELECT id FROM teams WHERE name = 'FC Schwachhausen'), 2, 0, 7, '2023-09-30', 'completed'),
((SELECT id FROM seasons WHERE year = 2023), (SELECT id FROM teams WHERE name = 'FC Borgfeld'), (SELECT id FROM teams WHERE name = 'SV Neustadt'), 1, 1, 7, '2023-09-30', 'completed'),
((SELECT id FROM seasons WHERE year = 2023), (SELECT id FROM teams WHERE name = 'FC Werdersee'), (SELECT id FROM teams WHERE name = 'SG Aumund'), 5, 1, 7, '2023-09-30', 'completed'),
((SELECT id FROM seasons WHERE year = 2023), (SELECT id FROM teams WHERE name = 'FC Vahr'), (SELECT id FROM teams WHERE name = 'SV Grohn'), 1, 0, 7, '2023-09-30', 'completed'),
((SELECT id FROM seasons WHERE year = 2023), (SELECT id FROM teams WHERE name = 'Bremer SV'), NULL, NULL, NULL, 7, '2023-09-30', 'completed'); -- Spielfrei

-- Spieltag 8 (2023-10-07)
INSERT INTO matches (season_id, home_team_id, away_team_id, home_score, away_score, matchday, match_date, status) VALUES
((SELECT id FROM seasons WHERE year = 2023), (SELECT id FROM teams WHERE name = 'FC Schwachhausen'), (SELECT id FROM teams WHERE name = 'FC Borgfeld'), 0, 2, 8, '2023-10-07', 'completed'),
((SELECT id FROM seasons WHERE year = 2023), (SELECT id FROM teams WHERE name = 'SV Neustadt'), (SELECT id FROM teams WHERE name = 'FC Werdersee'), 1, 4, 8, '2023-10-07', 'completed'),
((SELECT id FROM seasons WHERE year = 2023), (SELECT id FROM teams WHERE name = 'SG Aumund'), (SELECT id FROM teams WHERE name = 'FC Vahr'), 1, 2, 8, '2023-10-07', 'completed'),
((SELECT id FROM seasons WHERE year = 2023), (SELECT id FROM teams WHERE name = 'SV Grohn'), (SELECT id FROM teams WHERE name = 'Bremer SV'), 0, 1, 8, '2023-10-07', 'completed'),
((SELECT id FROM seasons WHERE year = 2023), (SELECT id FROM teams WHERE name = 'TSV Findorff'), NULL, NULL, NULL, 8, '2023-10-07', 'completed'); -- Spielfrei

-- ========================================
-- SAISON 2024/25 - AKTUELLE MATCHES (bereits teilweise eingefügt)
-- ========================================

-- Aktualisiere alle bestehenden Matches mit der 2024 season_id
UPDATE matches 
SET season_id = (SELECT id FROM seasons WHERE year = 2024)
WHERE season_id IS NULL OR season_id = (SELECT id FROM seasons WHERE year = 2023);

-- Beispiel für neue Matches in Saison 2024/25 mit TSV Lesum
-- Spieltag 1 (2024-08-17) - Mit TSV Lesum als neuem Team
DELETE FROM matches WHERE season_id = (SELECT id FROM seasons WHERE year = 2024);

INSERT INTO matches (season_id, home_team_id, away_team_id, home_score, away_score, matchday, match_date, status) VALUES
((SELECT id FROM seasons WHERE year = 2024), (SELECT id FROM teams WHERE name = 'FC Werdersee'), (SELECT id FROM teams WHERE name = 'SV Neustadt'), 2, 1, 1, '2024-08-17', 'completed'),
((SELECT id FROM seasons WHERE year = 2024), (SELECT id FROM teams WHERE name = 'Bremer SV'), (SELECT id FROM teams WHERE name = 'FC Vahr'), 1, 0, 1, '2024-08-17', 'completed'),
((SELECT id FROM seasons WHERE year = 2024), (SELECT id FROM teams WHERE name = 'TSV Findorff'), (SELECT id FROM teams WHERE name = 'SG Aumund'), 3, 2, 1, '2024-08-17', 'completed'),
((SELECT id FROM seasons WHERE year = 2024), (SELECT id FROM teams WHERE name = 'FC Borgfeld'), (SELECT id FROM teams WHERE name = 'SV Grohn'), 1, 1, 1, '2024-08-17', 'completed'),
((SELECT id FROM seasons WHERE year = 2024), (SELECT id FROM teams WHERE name = 'FC Schwachhausen'), (SELECT id FROM teams WHERE name = 'TSV Lesum'), 0, 3, 1, '2024-08-17', 'completed');

-- Spieltag 2 (2024-08-24)
INSERT INTO matches (season_id, home_team_id, away_team_id, home_score, away_score, matchday, match_date, status) VALUES
((SELECT id FROM seasons WHERE year = 2024), (SELECT id FROM teams WHERE name = 'SV Neustadt'), (SELECT id FROM teams WHERE name = 'Bremer SV'), 2, 2, 2, '2024-08-24', 'completed'),
((SELECT id FROM seasons WHERE year = 2024), (SELECT id FROM teams WHERE name = 'FC Vahr'), (SELECT id FROM teams WHERE name = 'TSV Findorff'), 1, 2, 2, '2024-08-24', 'completed'),
((SELECT id FROM seasons WHERE year = 2024), (SELECT id FROM teams WHERE name = 'SG Aumund'), (SELECT id FROM teams WHERE name = 'FC Borgfeld'), 0, 1, 2, '2024-08-24', 'completed'),
((SELECT id FROM seasons WHERE year = 2024), (SELECT id FROM teams WHERE name = 'SV Grohn'), (SELECT id FROM teams WHERE name = 'FC Schwachhausen'), 3, 0, 2, '2024-08-24', 'completed'),
((SELECT id FROM seasons WHERE year = 2024), (SELECT id FROM teams WHERE name = 'TSV Lesum'), (SELECT id FROM teams WHERE name = 'FC Werdersee'), 1, 4, 2, '2024-08-24', 'completed');

-- Spieltag 3 (2024-08-31)
INSERT INTO matches (season_id, home_team_id, away_team_id, home_score, away_score, matchday, match_date, status) VALUES
((SELECT id FROM seasons WHERE year = 2024), (SELECT id FROM teams WHERE name = 'FC Werdersee'), (SELECT id FROM teams WHERE name = 'FC Vahr'), 3, 0, 3, '2024-08-31', 'completed'),
((SELECT id FROM seasons WHERE year = 2024), (SELECT id FROM teams WHERE name = 'Bremer SV'), (SELECT id FROM teams WHERE name = 'SG Aumund'), 2, 1, 3, '2024-08-31', 'completed'),
((SELECT id FROM seasons WHERE year = 2024), (SELECT id FROM teams WHERE name = 'TSV Findorff'), (SELECT id FROM teams WHERE name = 'SV Grohn'), 1, 1, 3, '2024-08-31', 'completed'),
((SELECT id FROM seasons WHERE year = 2024), (SELECT id FROM teams WHERE name = 'FC Borgfeld'), (SELECT id FROM teams WHERE name = 'TSV Lesum'), 2, 0, 3, '2024-08-31', 'completed'),
((SELECT id FROM seasons WHERE year = 2024), (SELECT id FROM teams WHERE name = 'FC Schwachhausen'), (SELECT id FROM teams WHERE name = 'SV Neustadt'), 1, 2, 3, '2024-08-31', 'completed');

-- Spieltag 4 (2024-09-07)
INSERT INTO matches (season_id, home_team_id, away_team_id, home_score, away_score, matchday, match_date, status) VALUES
((SELECT id FROM seasons WHERE year = 2024), (SELECT id FROM teams WHERE name = 'SV Neustadt'), (SELECT id FROM teams WHERE name = 'TSV Findorff'), 0, 0, 4, '2024-09-07', 'completed'),
((SELECT id FROM seasons WHERE year = 2024), (SELECT id FROM teams WHERE name = 'FC Vahr'), (SELECT id FROM teams WHERE name = 'Bremer SV'), 2, 3, 4, '2024-09-07', 'completed'),
((SELECT id FROM seasons WHERE year = 2024), (SELECT id FROM teams WHERE name = 'SG Aumund'), (SELECT id FROM teams WHERE name = 'FC Schwachhausen'), 1, 0, 4, '2024-09-07', 'completed'),
((SELECT id FROM seasons WHERE year = 2024), (SELECT id FROM teams WHERE name = 'SV Grohn'), (SELECT id FROM teams WHERE name = 'FC Borgfeld'), 1, 2, 4, '2024-09-07', 'completed'),
((SELECT id FROM seasons WHERE year = 2024), (SELECT id FROM teams WHERE name = 'TSV Lesum'), (SELECT id FROM teams WHERE name = 'FC Werdersee'), 0, 5, 4, '2024-09-07', 'completed');

-- Spieltag 5 (2024-09-14)
INSERT INTO matches (season_id, home_team_id, away_team_id, home_score, away_score, matchday, match_date, status) VALUES
((SELECT id FROM seasons WHERE year = 2024), (SELECT id FROM teams WHERE name = 'FC Werdersee'), (SELECT id FROM teams WHERE name = 'SG Aumund'), 2, 1, 5, '2024-09-14', 'completed'),
((SELECT id FROM seasons WHERE year = 2024), (SELECT id FROM teams WHERE name = 'Bremer SV'), (SELECT id FROM teams WHERE name = 'SV Grohn'), 1, 0, 5, '2024-09-14', 'completed'),
((SELECT id FROM seasons WHERE year = 2024), (SELECT id FROM teams WHERE name = 'TSV Findorff'), (SELECT id FROM teams WHERE name = 'TSV Lesum'), 3, 1, 5, '2024-09-14', 'completed'),
((SELECT id FROM seasons WHERE year = 2024), (SELECT id FROM teams WHERE name = 'FC Borgfeld'), (SELECT id FROM teams WHERE name = 'FC Schwachhausen'), 0, 1, 5, '2024-09-14', 'completed'),
((SELECT id FROM seasons WHERE year = 2024), (SELECT id FROM teams WHERE name = 'FC Vahr'), (SELECT id FROM teams WHERE name = 'SV Neustadt'), 2, 2, 5, '2024-09-14', 'completed');

-- Spieltag 6 (2024-09-21)
INSERT INTO matches (season_id, home_team_id, away_team_id, home_score, away_score, matchday, match_date, status) VALUES
((SELECT id FROM seasons WHERE year = 2024), (SELECT id FROM teams WHERE name = 'SV Neustadt'), (SELECT id FROM teams WHERE name = 'FC Borgfeld'), 1, 0, 6, '2024-09-21', 'completed'),
((SELECT id FROM seasons WHERE year = 2024), (SELECT id FROM teams WHERE name = 'SG Aumund'), (SELECT id FROM teams WHERE name = 'FC Vahr'), 3, 2, 6, '2024-09-21', 'completed'),
((SELECT id FROM seasons WHERE year = 2024), (SELECT id FROM teams WHERE name = 'SV Grohn'), (SELECT id FROM teams WHERE name = 'TSV Findorff'), 2, 1, 6, '2024-09-21', 'completed'),
((SELECT id FROM seasons WHERE year = 2024), (SELECT id FROM teams WHERE name = 'TSV Lesum'), (SELECT id FROM teams WHERE name = 'Bremer SV'), 1, 3, 6, '2024-09-21', 'completed'),
((SELECT id FROM seasons WHERE year = 2024), (SELECT id FROM teams WHERE name = 'FC Schwachhausen'), (SELECT id FROM teams WHERE name = 'FC Werdersee'), 0, 4, 6, '2024-09-21', 'completed');

-- Spieltag 7 (2024-09-28)
INSERT INTO matches (season_id, home_team_id, away_team_id, home_score, away_score, matchday, match_date, status) VALUES
((SELECT id FROM seasons WHERE year = 2024), (SELECT id FROM teams WHERE name = 'FC Werdersee'), (SELECT id FROM teams WHERE name = 'SV Grohn'), 3, 1, 7, '2024-09-28', 'completed'),
((SELECT id FROM seasons WHERE year = 2024), (SELECT id FROM teams WHERE name = 'Bremer SV'), (SELECT id FROM teams WHERE name = 'FC Schwachhausen'), 2, 0, 7, '2024-09-28', 'completed'),
((SELECT id FROM seasons WHERE year = 2024), (SELECT id FROM teams WHERE name = 'TSV Findorff'), (SELECT id FROM teams WHERE name = 'FC Borgfeld'), 1, 2, 7, '2024-09-28', 'completed'),
((SELECT id FROM seasons WHERE year = 2024), (SELECT id FROM teams WHERE name = 'FC Vahr'), (SELECT id FROM teams WHERE name = 'TSV Lesum'), 4, 1, 7, '2024-09-28', 'completed'),
((SELECT id FROM seasons WHERE year = 2024), (SELECT id FROM teams WHERE name = 'SG Aumund'), (SELECT id FROM teams WHERE name = 'SV Neustadt'), 1, 1, 7, '2024-09-28', 'completed');

-- Spieltag 8 (2024-10-05)
INSERT INTO matches (season_id, home_team_id, away_team_id, home_score, away_score, matchday, match_date, status) VALUES
((SELECT id FROM seasons WHERE year = 2024), (SELECT id FROM teams WHERE name = 'SV Neustadt'), (SELECT id FROM teams WHERE name = 'FC Vahr'), 2, 0, 8, '2024-10-05', 'completed'),
((SELECT id FROM seasons WHERE year = 2024), (SELECT id FROM teams WHERE name = 'FC Borgfeld'), (SELECT id FROM teams WHERE name = 'SG Aumund'), 1, 3, 8, '2024-10-05', 'completed'),
((SELECT id FROM seasons WHERE year = 2024), (SELECT id FROM teams WHERE name = 'SV Grohn'), (SELECT id FROM teams WHERE name = 'Bremer SV'), 0, 2, 8, '2024-10-05', 'completed'),
((SELECT id FROM seasons WHERE year = 2024), (SELECT id FROM teams WHERE name = 'TSV Lesum'), (SELECT id FROM teams WHERE name = 'TSV Findorff'), 2, 2, 8, '2024-10-05', 'completed'),
((SELECT id FROM seasons WHERE year = 2024), (SELECT id FROM teams WHERE name = 'FC Schwachhausen'), (SELECT id FROM teams WHERE name = 'FC Werdersee'), 1, 3, 8, '2024-10-05', 'completed');

-- Spieltag 9 (2024-10-12)
INSERT INTO matches (season_id, home_team_id, away_team_id, home_score, away_score, matchday, match_date, status) VALUES
((SELECT id FROM seasons WHERE year = 2024), (SELECT id FROM teams WHERE name = 'FC Werdersee'), (SELECT id FROM teams WHERE name = 'FC Borgfeld'), 1, 0, 9, '2024-10-12', 'completed'),
((SELECT id FROM seasons WHERE year = 2024), (SELECT id FROM teams WHERE name = 'Bremer SV'), (SELECT id FROM teams WHERE name = 'TSV Lesum'), 3, 1, 9, '2024-10-12', 'completed'),
((SELECT id FROM seasons WHERE year = 2024), (SELECT id FROM teams WHERE name = 'TSV Findorff'), (SELECT id FROM teams WHERE name = 'FC Schwachhausen'), 2, 1, 9, '2024-10-12', 'completed'),
((SELECT id FROM seasons WHERE year = 2024), (SELECT id FROM teams WHERE name = 'FC Vahr'), (SELECT id FROM teams WHERE name = 'SV Grohn'), 1, 1, 9, '2024-10-12', 'completed'),
((SELECT id FROM seasons WHERE year = 2024), (SELECT id FROM teams WHERE name = 'SG Aumund'), (SELECT id FROM teams WHERE name = 'SV Neustadt'), 0, 2, 9, '2024-10-12', 'completed');

-- Kommende Spiele (ohne Ergebnisse) - Spieltag 10
INSERT INTO matches (season_id, home_team_id, away_team_id, home_score, away_score, matchday, match_date, status) VALUES
((SELECT id FROM seasons WHERE year = 2024), (SELECT id FROM teams WHERE name = 'SV Neustadt'), (SELECT id FROM teams WHERE name = 'FC Werdersee'), NULL, NULL, 10, '2024-10-19', 'scheduled'),
((SELECT id FROM seasons WHERE year = 2024), (SELECT id FROM teams WHERE name = 'FC Borgfeld'), (SELECT id FROM teams WHERE name = 'FC Vahr'), NULL, NULL, 10, '2024-10-19', 'scheduled'),
((SELECT id FROM seasons WHERE year = 2024), (SELECT id FROM teams WHERE name = 'SV Grohn'), (SELECT id FROM teams WHERE name = 'SG Aumund'), NULL, NULL, 10, '2024-10-19', 'scheduled'),
((SELECT id FROM seasons WHERE year = 2024), (SELECT id FROM teams WHERE name = 'TSV Lesum'), (SELECT id FROM teams WHERE name = 'TSV Findorff'), NULL, NULL, 10, '2024-10-19', 'scheduled'),
((SELECT id FROM seasons WHERE year = 2024), (SELECT id FROM teams WHERE name = 'FC Schwachhausen'), (SELECT id FROM teams WHERE name = 'Bremer SV'), NULL, NULL, 10, '2024-10-19', 'scheduled');

-- Kommende Spiele - Spieltag 11
INSERT INTO matches (season_id, home_team_id, away_team_id, home_score, away_score, matchday, match_date, status) VALUES
((SELECT id FROM seasons WHERE year = 2024), (SELECT id FROM teams WHERE name = 'FC Werdersee'), (SELECT id FROM teams WHERE name = 'TSV Findorff'), NULL, NULL, 11, '2024-10-26', 'scheduled'),
((SELECT id FROM seasons WHERE year = 2024), (SELECT id FROM teams WHERE name = 'Bremer SV'), (SELECT id FROM teams WHERE name = 'SV Neustadt'), NULL, NULL, 11, '2024-10-26', 'scheduled'),
((SELECT id FROM seasons WHERE year = 2024), (SELECT id FROM teams WHERE name = 'FC Vahr'), (SELECT id FROM teams WHERE name = 'FC Schwachhausen'), NULL, NULL, 11, '2024-10-26', 'scheduled'),
((SELECT id FROM seasons WHERE year = 2024), (SELECT id FROM teams WHERE name = 'SG Aumund'), (SELECT id FROM teams WHERE name = 'TSV Lesum'), NULL, NULL, 11, '2024-10-26', 'scheduled'),
((SELECT id FROM seasons WHERE year = 2024), (SELECT id FROM teams WHERE name = 'FC Borgfeld'), (SELECT id FROM teams WHERE name = 'SV Grohn'), NULL, NULL, 11, '2024-10-26', 'scheduled');

-- Setze die aktuelle Saison auf 2024
UPDATE seasons SET status = 'completed' WHERE year = 2023;
UPDATE seasons SET status = 'active' WHERE year = 2024;

-- ========================================
-- ZUSAMMENFASSUNG DER BEISPIELDATEN:
-- ========================================
-- 
-- SAISON 2023/24 (abgeschlossen):
-- - 9 Teams (ohne TSV Lesum)
-- - 8 Spieltage komplett
-- - FC Werdersee war auch hier stark
-- - SV Neustadt zweiter
-- - FC Schwachhausen hatte Schwierigkeiten
--
-- SAISON 2024/25 (aktiv):
-- - 10 Teams (TSV Lesum neu dabei)
-- - 9 Spieltage gespielt, 2 geplant
-- - FC Werdersee führt wieder
-- - TSV Lesum kämpft als Neuling
-- 
-- Zeigt perfekt, wie sich Teams zwischen Saisons ändern können!
-- ========================================
