-- Update alle Spiele ohne expliziten Status auf 'completed'
-- Dies betrifft die Spieltage 1-9
UPDATE matches 
SET status = 'completed' 
WHERE status IS NULL OR status = '';

-- Speziell für Spieltage 1-9 (die Ergebnisse haben)
UPDATE matches 
SET status = 'completed' 
WHERE matchday <= 9 AND (home_score IS NOT NULL AND away_score IS NOT NULL);

-- Bestätigung: Zeige alle Matches mit ihrem Status
SELECT matchday, status, COUNT(*) as count
FROM matches 
GROUP BY matchday, status 
ORDER BY matchday;
