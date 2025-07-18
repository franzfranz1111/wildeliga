-- Wintersaison 2025/26 mit automatischem Spielplan
-- Wilde Liga Bremen - Neue Saison erstellen

-- Hole alle Team-IDs für die neue Saison
DO $$
DECLARE
    v_team_ids UUID[];
    v_season_id UUID;
    v_match_count INTEGER;
BEGIN
    -- Sammle alle Team-IDs
    SELECT ARRAY_AGG(id) INTO v_team_ids
    FROM teams
    ORDER BY name;
    
    -- Erstelle neue Saison mit automatischem Spielplan
    SELECT create_new_season_with_schedule(
        'Wintersaison 2025/26',           -- Saison-Name
        2025,                             -- Jahr
        '2025-11-01'::DATE,              -- Startdatum
        '2026-03-31'::DATE,              -- Enddatum
        v_team_ids,                       -- Alle Teams
        true                             -- Hin- und Rückrunde
    ) INTO v_season_id;
    
    -- Zeige Ergebnis
    RAISE NOTICE 'Wintersaison 2025/26 erstellt mit ID: %', v_season_id;
    
    -- Zeige Spielplan-Statistiken
    SELECT COUNT(*) INTO v_match_count
    FROM matches
    WHERE season_id = v_season_id;
    
    RAISE NOTICE 'Spielplan erstellt: % Spiele für % Teams', v_match_count, array_length(v_team_ids, 1);
END $$;

-- Zeige den erstellten Spielplan
SELECT 
    s.name as saison,
    m.matchday as spieltag,
    ht.name as heimteam,
    at.name as gastteam,
    m.match_date::DATE as datum,
    m.match_date::TIME as uhrzeit,
    m.status
FROM matches m
JOIN teams ht ON m.home_team_id = ht.id
JOIN teams at ON m.away_team_id = at.id
JOIN seasons s ON m.season_id = s.id
WHERE s.name = 'Wintersaison 2025/26'
ORDER BY m.matchday, m.match_date;

-- Zeige Saison-Übersicht
SELECT 
    name as saison,
    year as jahr,
    status,
    start_date as startdatum,
    end_date as enddatum,
    (SELECT COUNT(*) FROM season_teams WHERE season_id = s.id) as anzahl_teams,
    (SELECT COUNT(*) FROM matches WHERE season_id = s.id) as anzahl_spiele
FROM seasons s
WHERE s.name = 'Wintersaison 2025/26';

-- Zeige Spielplan nach Spieltagen
SELECT 
    m.matchday as spieltag,
    COUNT(*) as anzahl_spiele,
    MIN(m.match_date::DATE) as datum,
    string_agg(ht.short_name || ' vs ' || at.short_name, ', ' ORDER BY m.match_date) as spiele
FROM matches m
JOIN teams ht ON m.home_team_id = ht.id
JOIN teams at ON m.away_team_id = at.id
JOIN seasons s ON m.season_id = s.id
WHERE s.name = 'Wintersaison 2025/26'
GROUP BY m.matchday
ORDER BY m.matchday;

-- Bestätigung
SELECT 'Wintersaison 2025/26 erfolgreich erstellt!' as status;
