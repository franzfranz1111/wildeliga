# Lokaler Datenbankzugriff auf Supabase

## 1. Connection Details

Gehe zu deinem Supabase Dashboard → Settings → Database:

- **Host:** `db.jjbkrzhjkcyhfheqwvgc.supabase.co`
- **Port:** `5432`
- **Database:** `postgres`
- **Username:** `postgres`
- **Password:** `[DEIN-DB-PASSWORD]`

## 2. Connection String

```
postgresql://postgres:[YOUR-PASSWORD]@db.jjbkrzhjkcyhfheqwvgc.supabase.co:5432/postgres
```

## 3. pgAdmin Setup

1. Download pgAdmin 4: https://www.pgadmin.org/
2. Rechtsklick auf "Servers" → "Register" → "Server"
3. **General Tab:**
   - Name: `Wilde Liga Bremen`
4. **Connection Tab:**
   - Host: `db.jjbkrzhjkcyhfheqwvgc.supabase.co`
   - Port: `5432`
   - Database: `postgres`
   - Username: `postgres`
   - Password: `[DEIN-PASSWORD]`

## 4. DBeaver Setup

1. Download DBeaver: https://dbeaver.io/
2. Neue Verbindung → PostgreSQL
3. Connection-Details eingeben
4. "Test Connection" klicken

## 5. Command Line (psql)

```bash
# Windows (mit psql installiert)
psql "postgresql://postgres:[PASSWORD]@db.jjbkrzhjkcyhfheqwvgc.supabase.co:5432/postgres"

# Dann kannst du SQL-Befehle ausführen:
\dt                    # Tabellen anzeigen
SELECT * FROM teams;   # Teams anzeigen
SELECT * FROM matches; # Matches anzeigen
```

## 6. Supabase CLI (für lokale Entwicklung)

```bash
# Installation
npm install -g supabase

# Login
supabase login

# Lokale Instanz starten
supabase start

# Lokale Studio öffnen (läuft auf http://localhost:54323)
supabase studio
```

## 7. Nützliche SQL-Befehle

```sql
-- Alle Tabellen anzeigen
SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';

-- Tabellen-Struktur anzeigen
\d teams

-- Daten abfragen
SELECT * FROM teams;
SELECT * FROM matches ORDER BY matchday DESC;

-- Policies anzeigen
SELECT * FROM pg_policies WHERE schemaname = 'public';
```

## Sicherheitshinweise

- ⚠️ **Niemals** das Datenbank-Password öffentlich teilen
- ⚠️ **Niemals** Connection-Details in Git committen
- ✅ Verwende lokale Konfigurationsdateien für Credentials
