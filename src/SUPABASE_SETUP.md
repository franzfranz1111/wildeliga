# Supabase Setup für Wilde Liga Bremen

## 1. Supabase-Projekt erstellen

1. Gehe zu [supabase.com](https://supabase.com)
2. Erstelle ein kostenloses Konto
3. Klicke auf "New project"
4. Wähle eine Organisation (oder erstelle eine neue)
5. Projektname: `wilde-liga-bremen`
6. Wähle eine Region (am besten Frankfurt für Deutschland)
7. Erstelle ein starkes Passwort für die Datenbank
8. Klicke auf "Create new project"

## 2. Datenbank-Schema erstellen

1. Gehe zu deinem Supabase-Dashboard
2. Klicke auf "SQL Editor" in der linken Sidebar
3. Kopiere den Inhalt aus `database-schema.sql` und füge ihn ein
4. Klicke auf "Run" um die Tabellen zu erstellen

## 3. Konfiguration aktualisieren

1. Gehe zu "Settings" → "API" in deinem Supabase-Dashboard
2. Kopiere die folgenden Werte:
   - **Project URL**: `https://your-project-id.supabase.co`
   - **Anon/Public Key**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`

3. Öffne `src/config.js` und ersetze:
   ```javascript
   const SUPABASE_CONFIG = {
       url: 'https://your-project-id.supabase.co', // Deine Project URL
       anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...' // Dein Anon Key
   };
   ```

## 4. Row Level Security (RLS) konfigurieren

Für öffentliche Lesezugriffe, füge diese Policies hinzu:

```sql
-- Enable RLS
ALTER TABLE teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE players ENABLE ROW LEVEL SECURITY;
ALTER TABLE achievements ENABLE ROW LEVEL SECURITY;

-- Allow public read access
CREATE POLICY "Public read access" ON teams FOR SELECT USING (true);
CREATE POLICY "Public read access" ON matches FOR SELECT USING (true);
CREATE POLICY "Public read access" ON players FOR SELECT USING (true);
CREATE POLICY "Public read access" ON achievements FOR SELECT USING (true);
```

## 5. Testen der Verbindung

1. Öffne `src/wilde-liga.html` in deinem Browser
2. Öffne die Entwicklertools (F12)
3. Gehe zur Konsole
4. Teste die API:
   ```javascript
   WildeLigaAPI.getTeams().then(teams => console.log(teams));
   ```

## 6. Funktionen die verfügbar sind

Nach dem Setup hast du folgende API-Funktionen:

- `WildeLigaAPI.getTeams()` - Alle Teams laden
- `WildeLigaAPI.getStandings()` - Aktuelle Tabelle laden
- `WildeLigaAPI.getMatchesByMatchday(matchday)` - Spiele nach Spieltag
- `WildeLigaAPI.getTeamMatches(teamName)` - Spiele eines Teams
- `WildeLigaAPI.getTeamById(id)` - Team-Details mit Spielern

## 7. Erweiterte Funktionen

### Realtime Updates
Du kannst später auch Realtime-Updates hinzufügen:

```javascript
// Realtime Standings Updates
supabase
  .channel('standings')
  .on('postgres_changes', 
    { event: '*', schema: 'public', table: 'matches' },
    (payload) => {
      console.log('Match updated:', payload);
      // Tabelle neu laden
      loadStandings();
    }
  )
  .subscribe();
```

### Admin-Interface
Mit Authentication kannst du ein Admin-Interface für das Bearbeiten von Daten erstellen.

## Kosten

- Supabase ist kostenlos bis zu:
  - 500MB Datenbank
  - 2GB Bandbreite pro Monat
  - 50MB Dateispeicher

Das reicht problemlos für eine lokale Fußball-Liga!
