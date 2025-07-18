-- Automatische Spielplan-Erstellung für neue Saisons
-- Wilde Liga Bremen - Schedule Generator

-- Funktion zur automatischen Spielplan-Erstellung
CREATE OR REPLACE FUNCTION generate_season_schedule(
    p_season_id UUID,
    p_start_date DATE,
    p_end_date DATE,
    p_double_round BOOLEAN DEFAULT true -- Hin- und Rückrunde
) RETURNS INTEGER AS $$
DECLARE
    v_team_ids UUID[];
    v_team_count INTEGER;
    v_total_matchdays INTEGER;
    v_matches_per_matchday INTEGER;
    v_current_date DATE;
    v_week_interval INTEGER;
    v_matchday INTEGER;
    v_home_team_id UUID;
    v_away_team_id UUID;
    v_round INTEGER;
    v_team_i INTEGER;
    v_team_j INTEGER;
    v_match_count INTEGER := 0;
BEGIN
    -- Hole alle Teams der Saison
    SELECT ARRAY_AGG(team_id) INTO v_team_ids
    FROM season_teams
    WHERE season_id = p_season_id;
    
    v_team_count := array_length(v_team_ids, 1);
    
    IF v_team_count IS NULL OR v_team_count < 2 THEN
        RAISE EXCEPTION 'Mindestens 2 Teams erforderlich für Spielplan-Erstellung';
    END IF;
    
    -- Berechne Anzahl Spieltage
    v_total_matchdays := v_team_count - 1;
    IF p_double_round THEN
        v_total_matchdays := v_total_matchdays * 2;
    END IF;
    
    v_matches_per_matchday := v_team_count / 2;
    
    -- Berechne Wochen-Intervall basierend auf verfügbarer Zeit
    v_week_interval := GREATEST(1, (p_end_date - p_start_date) / v_total_matchdays);
    
    -- Finde das nächste Wochenende (Samstag) nach dem Startdatum
    v_current_date := p_start_date;
    -- Verschiebe zum nächsten Samstag (6 = Samstag)
    WHILE EXTRACT(DOW FROM v_current_date) != 6 LOOP
        v_current_date := v_current_date + INTERVAL '1 day';
    END LOOP;
    
    v_matchday := 1;
    
    -- Lösche existierende Spiele der Saison
    DELETE FROM matches WHERE season_id = p_season_id;
    
    -- Round-Robin Algorithmus für Hinrunde
    FOR v_round IN 1..(CASE WHEN p_double_round THEN 2 ELSE 1 END) LOOP
        FOR v_matchday IN 1..(v_team_count - 1) LOOP
            
            -- Erstelle Spiele für diesen Spieltag
            FOR v_team_i IN 1..v_team_count LOOP
                FOR v_team_j IN (v_team_i + 1)..v_team_count LOOP
                    
                    -- Berechne ob Teams an diesem Spieltag gegeneinander spielen
                    IF (v_team_i = 1 AND v_team_j = v_matchday + 1) OR
                       (v_team_i > 1 AND v_team_j > 1 AND 
                        (v_team_i + v_team_j + v_matchday - 2) % (v_team_count - 1) = 0) THEN
                        
                        -- Bestimme Heim-/Auswärtsteam (in Rückrunde tauschen)
                        IF v_round = 1 THEN
                            v_home_team_id := v_team_ids[v_team_i];
                            v_away_team_id := v_team_ids[v_team_j];
                        ELSE
                            v_home_team_id := v_team_ids[v_team_j];
                            v_away_team_id := v_team_ids[v_team_i];
                        END IF;
                        
                        -- Erstelle das Spiel
                        INSERT INTO matches (
                            id, 
                            home_team_id, 
                            away_team_id, 
                            home_score, 
                            away_score, 
                            matchday, 
                            match_date, 
                            status, 
                            season_id,
                            created_at
                        ) VALUES (
                            gen_random_uuid(),
                            v_home_team_id,
                            v_away_team_id,
                            NULL,
                            NULL,
                            (v_round - 1) * (v_team_count - 1) + v_matchday,
                            v_current_date,
                            'scheduled',
                            p_season_id,
                            NOW()
                        );
                        
                        v_match_count := v_match_count + 1;
                    END IF;
                END LOOP;
            END LOOP;
            
            -- Nächster Spieltag (eine Woche später, immer Samstag)
            v_current_date := v_current_date + (v_week_interval || ' weeks')::INTERVAL;
        END LOOP;
    END LOOP;
    
    RETURN v_match_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Verbesserte Funktion zur Saison-Erstellung mit automatischem Spielplan
CREATE OR REPLACE FUNCTION create_new_season_with_schedule(
    p_season_name VARCHAR(100),
    p_year INTEGER,
    p_start_date DATE,
    p_end_date DATE,
    p_team_ids UUID[],
    p_double_round BOOLEAN DEFAULT true
) RETURNS UUID AS $$
DECLARE
    v_season_id UUID;
    v_team_id UUID;
    v_match_count INTEGER;
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
    
    -- Erstelle automatisch den Spielplan
    SELECT generate_season_schedule(v_season_id, p_start_date, p_end_date, p_double_round)
    INTO v_match_count;
    
    RAISE NOTICE 'Saison % erstellt mit % Spielen', p_season_name, v_match_count;
    
    RETURN v_season_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Funktion zum Verschieben eines einzelnen Spiels
CREATE OR REPLACE FUNCTION reschedule_match(
    p_match_id UUID,
    p_new_date DATE,
    p_new_time TIME DEFAULT '15:00:00'
) RETURNS BOOLEAN AS $$
DECLARE
    v_match_exists BOOLEAN;
BEGIN
    -- Prüfe ob das Spiel existiert
    SELECT EXISTS(SELECT 1 FROM matches WHERE id = p_match_id) INTO v_match_exists;
    
    IF NOT v_match_exists THEN
        RAISE EXCEPTION 'Spiel mit ID % nicht gefunden', p_match_id;
    END IF;
    
    -- Aktualisiere das Datum
    UPDATE matches 
    SET match_date = p_new_date + p_new_time,
        updated_at = NOW()
    WHERE id = p_match_id;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Funktion zum Verschieben aller Spiele eines Spieltags
CREATE OR REPLACE FUNCTION reschedule_matchday(
    p_season_id UUID,
    p_matchday INTEGER,
    p_new_date DATE,
    p_time_slots TIME[] DEFAULT ARRAY['15:00:00'::TIME, '17:00:00'::TIME]
) RETURNS INTEGER AS $$
DECLARE
    v_match_record RECORD;
    v_updated_count INTEGER := 0;
    v_time_index INTEGER := 1;
BEGIN
    -- Aktualisiere alle Spiele des Spieltags
    FOR v_match_record IN 
        SELECT id FROM matches 
        WHERE season_id = p_season_id AND matchday = p_matchday
        ORDER BY created_at
    LOOP
        -- Verwende abwechselnd verschiedene Uhrzeiten
        UPDATE matches 
        SET match_date = p_new_date + p_time_slots[v_time_index],
            updated_at = NOW()
        WHERE id = v_match_record.id;
        
        v_updated_count := v_updated_count + 1;
        
        -- Wechsle zur nächsten Uhrzeit
        v_time_index := (v_time_index % array_length(p_time_slots, 1)) + 1;
    END LOOP;
    
    RETURN v_updated_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Hilfsfunktion: Hole alle Spiele einer Saison mit Team-Namen
CREATE OR REPLACE FUNCTION get_season_matches(p_season_id UUID)
RETURNS TABLE (
    match_id UUID,
    home_team_name VARCHAR(100),
    away_team_name VARCHAR(100),
    home_score INTEGER,
    away_score INTEGER,
    matchday INTEGER,
    match_date TIMESTAMP,
    status VARCHAR(20)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        m.id as match_id,
        ht.name as home_team_name,
        at.name as away_team_name,
        m.home_score,
        m.away_score,
        m.matchday,
        m.match_date,
        m.status
    FROM matches m
    JOIN teams ht ON m.home_team_id = ht.id
    JOIN teams at ON m.away_team_id = at.id
    WHERE m.season_id = p_season_id
    ORDER BY m.matchday, m.match_date;
END;
$$ LANGUAGE plpgsql;

-- Policies für Schedule-Management
CREATE POLICY "Admin can manage match schedules" ON matches 
FOR UPDATE USING (
    auth.jwt() ->> 'email' IN ('admin@wilde-liga.de', 'admin@example.com')
);

-- Bestätigung der Erstellung
SELECT 'Spielplan-Generator erfolgreich erstellt!' as status;
