# pgAdmin Setup für Wilde Liga Bremen

## 1. pgAdmin Installation

1. Download: https://www.pgadmin.org/download/
2. Windows Version herunterladen
3. Standard-Installation durchführen
4. pgAdmin 4 starten

## 2. Neue Server-Verbindung erstellen

### Schritt 1: Server hinzufügen
1. pgAdmin öffnen
2. **Rechtsklick** auf "Servers" (linke Sidebar)
3. **"Register"** → **"Server..."**

### Schritt 2: General Tab
- **Name:** `Wilde Liga Bremen`
- **Server group:** `Servers` (Standard)
- **Comments:** `Supabase Datenbank für Wilde Liga`

### Schritt 3: Connection Tab
- **Host name/address:** `db.jjbkrzhjkcyhfheqwvgc.supabase.co`
- **Port:** `5432`
- **Maintenance database:** `postgres`
- **Username:** `postgres`
- **Password:** `[DEIN-DB-PASSWORD]`
- **☑️ Save password** (aktivieren)

### Schritt 4: Advanced Tab
- **DB restriction:** `postgres` (optional)

### Schritt 5: SSL Tab
- **SSL mode:** `Require` (wichtig für Supabase!)

## 3. Verbindung testen

1. **"Save"** klicken
2. Bei erfolgreicher Verbindung erscheint der Server in der Sidebar
3. **Erweitere:** `Wilde Liga Bremen` → `Databases` → `postgres` → `Schemas` → `public` → `Tables`

## 4. Erste Schritte

### Tabellen anzeigen
- Navigiere zu: `Servers` → `Wilde Liga Bremen` → `Databases` → `postgres` → `Schemas` → `public` → `Tables`
- Du solltest sehen: `achievements`, `matches`, `players`, `teams`, `user_profiles`

### SQL-Query ausführen
1. **Rechtsklick** auf `postgres` Database
2. **"Query Tool"** auswählen
3. Test-Query eingeben:
```sql
SELECT name, short_name FROM teams ORDER BY name;
```
4. **F5** drücken oder **Execute** klicken

## 5. Nützliche Queries

```sql
-- Alle Teams anzeigen
SELECT * FROM teams;

-- Tabelle der aktuellen Saison
SELECT * FROM standings;

-- Letzte 5 Spiele
SELECT 
  m.matchday,
  ht.name as home_team,
  m.home_score,
  m.away_score,
  at.name as away_team,
  m.match_date
FROM matches m
JOIN teams ht ON m.home_team_id = ht.id
JOIN teams at ON m.away_team_id = at.id
ORDER BY m.matchday DESC
LIMIT 5;

-- Policies anzeigen
SELECT * FROM pg_policies WHERE schemaname = 'public';
```

## 6. Troubleshooting

### Verbindung fehlgeschlagen?
- ✅ **SSL Mode:** Muss auf "Require" stehen
- ✅ **Password:** Korrekt eingegeben?
- ✅ **Internet:** Verbindung verfügbar?

### Tabellen nicht sichtbar?
- ✅ **Schema:** `public` ausgewählt?
- ✅ **Berechtigung:** Anon Key hat Leseberechtigung?

## 7. Wichtige Hinweise

- 🔐 **Niemals** das DB-Password teilen
- 💾 **Backup:** Regelmäßig Daten exportieren
- 🚨 **Vorsicht:** Direkte DB-Änderungen können die Website beeinträchtigen
- 📝 **Testen:** Änderungen zuerst in Entwicklungsumgebung

## 8. Datenbank-Password vergessen?

Falls du das Password vergessen hast:
1. Supabase Dashboard → Settings → Database
2. "Reset database password" klicken
3. Neues Password setzen
4. pgAdmin-Verbindung mit neuem Password aktualisieren
