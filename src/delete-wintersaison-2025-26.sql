-- Lösche Wintersaison 2025/26
-- Wilde Liga Bremen - Saison löschen

-- Prüfe zuerst, ob die Saison existiert
DO $$
DECLARE
    v_season_id UUID;
    v_match_count INTEGER;
    v_team_count INTEGER;
BEGIN
    -- Hole Saison-ID
    SELECT id INTO v_season_id
    FROM seasons
    WHERE name = 'Wintersaison 2025/26';
    
    IF v_season_id IS NULL THEN
        RAISE NOTICE 'Wintersaison 2025/26 nicht gefunden - nichts zu löschen.';
        RETURN;
    END IF;
    
    -- Zeige Statistiken vor dem Löschen
    SELECT COUNT(*) INTO v_match_count
    FROM matches
    WHERE season_id = v_season_id;
    
    SELECT COUNT(*) INTO v_team_count
    FROM season_teams
    WHERE season_id = v_season_id;
    
    RAISE NOTICE 'Gefunden: Wintersaison 2025/26 mit % Spielen und % Teams', v_match_count, v_team_count;
    
    -- Lösche alle Spiele der Saison
    DELETE FROM matches WHERE season_id = v_season_id;
    RAISE NOTICE 'Gelöscht: % Spiele', v_match_count;
    
    -- Lösche alle Team-Verknüpfungen
    DELETE FROM season_teams WHERE season_id = v_season_id;
    RAISE NOTICE 'Gelöscht: % Team-Verknüpfungen', v_team_count;
    
    -- Lösche alle Achievements der Saison (falls vorhanden)
    DELETE FROM achievements WHERE season_id = v_season_id;
    RAISE NOTICE 'Gelöscht: Achievements der Saison';
    
    -- Lösche die Saison selbst
    DELETE FROM seasons WHERE id = v_season_id;
    RAISE NOTICE 'Gelöscht: Wintersaison 2025/26';
    
    RAISE NOTICE 'Wintersaison 2025/26 erfolgreich gelöscht!';
END $$;

-- Bestätigung: Prüfe, ob die Saison wirklich gelöscht wurde
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM seasons WHERE name = 'Wintersaison 2025/26') 
        THEN 'FEHLER: Saison existiert noch!'
        ELSE 'ERFOLG: Wintersaison 2025/26 wurde gelöscht'
    END as status;

-- Zeige verbleibende Saisons
SELECT 
    name as saison,
    year as jahr,
    status,
    start_date as startdatum,
    end_date as enddatum
FROM seasons
ORDER BY year DESC, start_date DESC;
