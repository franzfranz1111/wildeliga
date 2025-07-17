-- Weitere Spielergebnisse für alle bisherigen Spieltage (1-11)

-- Spieltag 11
INSERT INTO matches (home_team_id, away_team_id, home_score, away_score, matchday, match_date) VALUES
((SELECT id FROM teams WHERE name = 'SV Neustadt'), (SELECT id FROM teams WHERE name = 'Bremer SV'), 2, 1, 11, '2024-01-08'),
((SELECT id FROM teams WHERE name = 'FC Vahr'), (SELECT id FROM teams WHERE name = 'TSV Findorff'), 3, 2, 11, '2024-01-08'),
((SELECT id FROM teams WHERE name = 'SG Aumund'), (SELECT id FROM teams WHERE name = 'FC Borgfeld'), 1, 0, 11, '2024-01-08'),
((SELECT id FROM teams WHERE name = 'SV Grohn'), (SELECT id FROM teams WHERE name = 'FC Schwachhausen'), 2, 2, 11, '2024-01-08'),
((SELECT id FROM teams WHERE name = 'TSV Lesum'), (SELECT id FROM teams WHERE name = 'FC Werdersee'), 0, 3, 11, '2024-01-08');

-- Spieltag 10
INSERT INTO matches (home_team_id, away_team_id, home_score, away_score, matchday, match_date) VALUES
((SELECT id FROM teams WHERE name = 'FC Werdersee'), (SELECT id FROM teams WHERE name = 'FC Borgfeld'), 4, 0, 10, '2024-01-01'),
((SELECT id FROM teams WHERE name = 'Bremer SV'), (SELECT id FROM teams WHERE name = 'SG Aumund'), 1, 1, 10, '2024-01-01'),
((SELECT id FROM teams WHERE name = 'TSV Findorff'), (SELECT id FROM teams WHERE name = 'SV Grohn'), 2, 1, 10, '2024-01-01'),
((SELECT id FROM teams WHERE name = 'FC Schwachhausen'), (SELECT id FROM teams WHERE name = 'FC Vahr'), 0, 3, 10, '2024-01-01'),
((SELECT id FROM teams WHERE name = 'TSV Lesum'), (SELECT id FROM teams WHERE name = 'SV Neustadt'), 1, 2, 10, '2024-01-01');

-- Spieltag 9
INSERT INTO matches (home_team_id, away_team_id, home_score, away_score, matchday, match_date) VALUES
((SELECT id FROM teams WHERE name = 'SV Neustadt'), (SELECT id FROM teams WHERE name = 'FC Schwachhausen'), 3, 0, 9, '2023-12-25'),
((SELECT id FROM teams WHERE name = 'FC Vahr'), (SELECT id FROM teams WHERE name = 'TSV Lesum'), 2, 1, 9, '2023-12-25'),
((SELECT id FROM teams WHERE name = 'SV Grohn'), (SELECT id FROM teams WHERE name = 'FC Werdersee'), 0, 2, 9, '2023-12-25'),
((SELECT id FROM teams WHERE name = 'FC Borgfeld'), (SELECT id FROM teams WHERE name = 'TSV Findorff'), 1, 1, 9, '2023-12-25'),
((SELECT id FROM teams WHERE name = 'SG Aumund'), (SELECT id FROM teams WHERE name = 'Bremer SV'), 0, 1, 9, '2023-12-25');

-- Spieltag 8
INSERT INTO matches (home_team_id, away_team_id, home_score, away_score, matchday, match_date) VALUES
((SELECT id FROM teams WHERE name = 'FC Werdersee'), (SELECT id FROM teams WHERE name = 'SG Aumund'), 2, 0, 8, '2023-12-18'),
((SELECT id FROM teams WHERE name = 'Bremer SV'), (SELECT id FROM teams WHERE name = 'FC Schwachhausen'), 3, 1, 8, '2023-12-18'),
((SELECT id FROM teams WHERE name = 'TSV Findorff'), (SELECT id FROM teams WHERE name = 'FC Vahr'), 0, 1, 8, '2023-12-18'),
((SELECT id FROM teams WHERE name = 'TSV Lesum'), (SELECT id FROM teams WHERE name = 'SV Grohn'), 1, 1, 8, '2023-12-18'),
((SELECT id FROM teams WHERE name = 'FC Borgfeld'), (SELECT id FROM teams WHERE name = 'SV Neustadt'), 0, 2, 8, '2023-12-18');

-- Spieltag 7
INSERT INTO matches (home_team_id, away_team_id, home_score, away_score, matchday, match_date) VALUES
((SELECT id FROM teams WHERE name = 'SV Neustadt'), (SELECT id FROM teams WHERE name = 'TSV Findorff'), 1, 0, 7, '2023-12-11'),
((SELECT id FROM teams WHERE name = 'FC Vahr'), (SELECT id FROM teams WHERE name = 'FC Borgfeld'), 2, 1, 7, '2023-12-11'),
((SELECT id FROM teams WHERE name = 'FC Schwachhausen'), (SELECT id FROM teams WHERE name = 'FC Werdersee'), 1, 3, 7, '2023-12-11'),
((SELECT id FROM teams WHERE name = 'SV Grohn'), (SELECT id FROM teams WHERE name = 'Bremer SV'), 1, 2, 7, '2023-12-11'),
((SELECT id FROM teams WHERE name = 'SG Aumund'), (SELECT id FROM teams WHERE name = 'TSV Lesum'), 2, 0, 7, '2023-12-11');

-- Spieltag 6
INSERT INTO matches (home_team_id, away_team_id, home_score, away_score, matchday, match_date) VALUES
((SELECT id FROM teams WHERE name = 'FC Werdersee'), (SELECT id FROM teams WHERE name = 'FC Vahr'), 1, 1, 6, '2023-12-04'),
((SELECT id FROM teams WHERE name = 'Bremer SV'), (SELECT id FROM teams WHERE name = 'FC Borgfeld'), 2, 0, 6, '2023-12-04'),
((SELECT id FROM teams WHERE name = 'TSV Findorff'), (SELECT id FROM teams WHERE name = 'SG Aumund'), 1, 2, 6, '2023-12-04'),
((SELECT id FROM teams WHERE name = 'TSV Lesum'), (SELECT id FROM teams WHERE name = 'FC Schwachhausen'), 0, 1, 6, '2023-12-04'),
((SELECT id FROM teams WHERE name = 'SV Grohn'), (SELECT id FROM teams WHERE name = 'SV Neustadt'), 0, 3, 6, '2023-12-04');

-- Spieltag 5
INSERT INTO matches (home_team_id, away_team_id, home_score, away_score, matchday, match_date) VALUES
((SELECT id FROM teams WHERE name = 'SV Neustadt'), (SELECT id FROM teams WHERE name = 'SG Aumund'), 2, 1, 5, '2023-11-27'),
((SELECT id FROM teams WHERE name = 'FC Vahr'), (SELECT id FROM teams WHERE name = 'SV Grohn'), 1, 0, 5, '2023-11-27'),
((SELECT id FROM teams WHERE name = 'FC Borgfeld'), (SELECT id FROM teams WHERE name = 'FC Werdersee'), 1, 2, 5, '2023-11-27'),
((SELECT id FROM teams WHERE name = 'FC Schwachhausen'), (SELECT id FROM teams WHERE name = 'TSV Findorff'), 2, 3, 5, '2023-11-27'),
((SELECT id FROM teams WHERE name = 'TSV Lesum'), (SELECT id FROM teams WHERE name = 'Bremer SV'), 0, 4, 5, '2023-11-27');

-- Spieltag 4
INSERT INTO matches (home_team_id, away_team_id, home_score, away_score, matchday, match_date) VALUES
((SELECT id FROM teams WHERE name = 'FC Werdersee'), (SELECT id FROM teams WHERE name = 'TSV Findorff'), 3, 1, 4, '2023-11-20'),
((SELECT id FROM teams WHERE name = 'Bremer SV'), (SELECT id FROM teams WHERE name = 'FC Vahr'), 0, 0, 4, '2023-11-20'),
((SELECT id FROM teams WHERE name = 'SG Aumund'), (SELECT id FROM teams WHERE name = 'FC Schwachhausen'), 1, 0, 4, '2023-11-20'),
((SELECT id FROM teams WHERE name = 'SV Grohn'), (SELECT id FROM teams WHERE name = 'FC Borgfeld'), 1, 1, 4, '2023-11-20'),
((SELECT id FROM teams WHERE name = 'TSV Lesum'), (SELECT id FROM teams WHERE name = 'SV Neustadt'), 1, 3, 4, '2023-11-20');

-- Spieltag 3
INSERT INTO matches (home_team_id, away_team_id, home_score, away_score, matchday, match_date) VALUES
((SELECT id FROM teams WHERE name = 'SV Neustadt'), (SELECT id FROM teams WHERE name = 'FC Werdersee'), 1, 2, 3, '2023-11-13'),
((SELECT id FROM teams WHERE name = 'TSV Findorff'), (SELECT id FROM teams WHERE name = 'Bremer SV'), 2, 2, 3, '2023-11-13'),
((SELECT id FROM teams WHERE name = 'FC Vahr'), (SELECT id FROM teams WHERE name = 'SG Aumund'), 2, 1, 3, '2023-11-13'),
((SELECT id FROM teams WHERE name = 'FC Borgfeld'), (SELECT id FROM teams WHERE name = 'FC Schwachhausen'), 2, 0, 3, '2023-11-13'),
((SELECT id FROM teams WHERE name = 'SV Grohn'), (SELECT id FROM teams WHERE name = 'TSV Lesum'), 2, 0, 3, '2023-11-13');

-- Spieltag 2
INSERT INTO matches (home_team_id, away_team_id, home_score, away_score, matchday, match_date) VALUES
((SELECT id FROM teams WHERE name = 'FC Werdersee'), (SELECT id FROM teams WHERE name = 'SV Grohn'), 3, 0, 2, '2023-11-06'),
((SELECT id FROM teams WHERE name = 'Bremer SV'), (SELECT id FROM teams WHERE name = 'SV Neustadt'), 1, 1, 2, '2023-11-06'),
((SELECT id FROM teams WHERE name = 'SG Aumund'), (SELECT id FROM teams WHERE name = 'FC Borgfeld'), 0, 1, 2, '2023-11-06'),
((SELECT id FROM teams WHERE name = 'FC Schwachhausen'), (SELECT id FROM teams WHERE name = 'FC Vahr'), 0, 2, 2, '2023-11-06'),
((SELECT id FROM teams WHERE name = 'TSV Lesum'), (SELECT id FROM teams WHERE name = 'TSV Findorff'), 1, 2, 2, '2023-11-06');

-- Spieltag 1
INSERT INTO matches (home_team_id, away_team_id, home_score, away_score, matchday, match_date) VALUES
((SELECT id FROM teams WHERE name = 'SV Neustadt'), (SELECT id FROM teams WHERE name = 'FC Vahr'), 2, 0, 1, '2023-10-30'),
((SELECT id FROM teams WHERE name = 'TSV Findorff'), (SELECT id FROM teams WHERE name = 'FC Werdersee'), 1, 3, 1, '2023-10-30'),
((SELECT id FROM teams WHERE name = 'FC Borgfeld'), (SELECT id FROM teams WHERE name = 'Bremer SV'), 0, 1, 1, '2023-10-30'),
((SELECT id FROM teams WHERE name = 'SV Grohn'), (SELECT id FROM teams WHERE name = 'SG Aumund'), 1, 1, 1, '2023-10-30'),
((SELECT id FROM teams WHERE name = 'FC Schwachhausen'), (SELECT id FROM teams WHERE name = 'TSV Lesum'), 0, 1, 1, '2023-10-30');

-- Zusätzliche Spieler für andere Teams (SV Neustadt)
INSERT INTO players (team_id, name, position, jersey_number) VALUES
((SELECT id FROM teams WHERE name = 'SV Neustadt'), 'Oliver Bauer', 'Torwart', 12),
((SELECT id FROM teams WHERE name = 'SV Neustadt'), 'Daniel Krüger', 'Verteidiger', 5),
((SELECT id FROM teams WHERE name = 'SV Neustadt'), 'Andreas Wolf', 'Mittelfeld', 8),
((SELECT id FROM teams WHERE name = 'SV Neustadt'), 'Robert Klein', 'Mittelfeld', 6),
((SELECT id FROM teams WHERE name = 'SV Neustadt'), 'Sven Hartmann', 'Stürmer', 18),
((SELECT id FROM teams WHERE name = 'SV Neustadt'), 'Tim Lange', 'Stürmer', 21);

-- Zusätzliche Spieler für Bremer SV
INSERT INTO players (team_id, name, position, jersey_number) VALUES
((SELECT id FROM teams WHERE name = 'Bremer SV'), 'Markus Neuer', 'Torwart', 33),
((SELECT id FROM teams WHERE name = 'Bremer SV'), 'Lars Meier', 'Verteidiger', 2),
((SELECT id FROM teams WHERE name = 'Bremer SV'), 'Jörg Wagner', 'Mittelfeld', 14),
((SELECT id FROM teams WHERE name = 'Bremer SV'), 'Patrick Schulz', 'Mittelfeld', 19),
((SELECT id FROM teams WHERE name = 'Bremer SV'), 'Timo Hoffmann', 'Stürmer', 22),
((SELECT id FROM teams WHERE name = 'Bremer SV'), 'Felix Kramer', 'Stürmer', 27);

-- Zusätzliche Erfolge für andere Teams
INSERT INTO achievements (team_id, title, year, icon) VALUES
((SELECT id FROM teams WHERE name = 'SV Neustadt'), 'Liga-Meister', 2015, '🏆'),
((SELECT id FROM teams WHERE name = 'SV Neustadt'), 'Liga-Meister', 2018, '🏆'),
((SELECT id FROM teams WHERE name = 'SV Neustadt'), 'Vizemeister', 2022, '🥈'),
((SELECT id FROM teams WHERE name = 'SV Neustadt'), 'Vizemeister', 2023, '🥈'),
((SELECT id FROM teams WHERE name = 'SV Neustadt'), 'Beste Defensive', 2019, '🛡️'),
((SELECT id FROM teams WHERE name = 'SV Neustadt'), 'Beste Defensive', 2021, '🛡️'),
((SELECT id FROM teams WHERE name = 'SV Neustadt'), 'Fairplay-Preis', 2020, '👥'),

((SELECT id FROM teams WHERE name = 'Bremer SV'), 'Liga-Meister', 2017, '🏆'),
((SELECT id FROM teams WHERE name = 'Bremer SV'), 'Pokalsieger', 2019, '🥇'),
((SELECT id FROM teams WHERE name = 'Bremer SV'), 'Vizemeister', 2020, '🥈'),
((SELECT id FROM teams WHERE name = 'Bremer SV'), 'Beste Nachwuchsarbeit', 2022, '🌟'),

((SELECT id FROM teams WHERE name = 'FC Vahr'), 'Pokalsieger', 2018, '🥇'),
((SELECT id FROM teams WHERE name = 'FC Vahr'), 'Vizemeister', 2019, '🥈'),
((SELECT id FROM teams WHERE name = 'FC Vahr'), 'Fairplay-Preis', 2021, '👥'),

((SELECT id FROM teams WHERE name = 'TSV Findorff'), 'Liga-Meister', 2016, '🏆'),
((SELECT id FROM teams WHERE name = 'TSV Findorff'), 'Pokalsieger', 2017, '🥇'),
((SELECT id FROM teams WHERE name = 'TSV Findorff'), 'Beste Offensive', 2018, '⚽');
