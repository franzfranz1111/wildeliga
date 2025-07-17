# Admin-Bereich Setup für Wilde Liga Bremen

## 🔐 Authentifizierung einrichten

### 1. Supabase Auth aktivieren

1. **Gehe zu deinem Supabase-Dashboard**
2. **Authentication → Settings**
3. **Aktiviere Email Auth** (sollte bereits aktiviert sein)
4. **Site URL setzen**: `http://localhost:3000` (oder deine Domain)

### 2. Admin-Benutzer erstellen

**Option A: Über Supabase Dashboard**
1. **Authentication → Users**
2. **"Add user" klicken**
3. **E-Mail**: `admin@wilde-liga.de` (oder deine gewünschte E-Mail)
4. **Passwort**: Sicheres Passwort wählen
5. **"Create user" klicken**

**Option B: Über SQL**
```sql
-- Admin-Benutzer erstellen
INSERT INTO auth.users (email, email_confirmed_at, created_at, updated_at)
VALUES ('admin@wilde-liga.de', NOW(), NOW(), NOW());

-- Oder einfach die Registrierung über die Auth-API nutzen
```

### 3. Row Level Security (RLS) für Admin-Zugriff

```sql
-- Admin-Policies für vollständigen Zugriff
CREATE POLICY "Admin full access" ON teams FOR ALL USING (
    auth.jwt() ->> 'email' = 'admin@wilde-liga.de'
);

CREATE POLICY "Admin full access" ON players FOR ALL USING (
    auth.jwt() ->> 'email' = 'admin@wilde-liga.de'
);

CREATE POLICY "Admin full access" ON matches FOR ALL USING (
    auth.jwt() ->> 'email' = 'admin@wilde-liga.de'
);

CREATE POLICY "Admin full access" ON achievements FOR ALL USING (
    auth.jwt() ->> 'email' = 'admin@wilde-liga.de'
);
```

## 🚀 Admin-Bereich nutzen

### 1. Admin-Seite öffnen
- URL: `src/admin.html`
- Login mit der erstellten E-Mail und Passwort

### 2. Verfügbare Funktionen

#### **Teams verwalten**
- ✅ Neue Teams erstellen
- ✅ Bestehende Teams bearbeiten
- ✅ Teams löschen (mit Warnung)
- ✅ Alle Team-Details (Name, Trainer, Stadion, etc.)

#### **Spieler verwalten**
- ✅ Neue Spieler zu Teams hinzufügen
- ✅ Spieler bearbeiten (Position, Nummer, Alter)
- ✅ Spieler löschen
- ✅ Nach Team filtern

#### **Spiele verwalten**
- ✅ Neue Spielergebnisse eingeben
- ✅ Bestehende Spiele bearbeiten
- ✅ Spiele löschen
- ✅ Automatische Tabellenaktualisierung

#### **Erfolge verwalten**
- 🔄 In Entwicklung

### 3. Sicherheitsfeatures

- 🔐 **Authentifizierung**: Nur angemeldete Benutzer
- 🛡️ **Authorization**: Nur Admin-E-Mail hat Zugriff
- ⚠️ **Lösch-Bestätigung**: Warnung vor irreversiblen Aktionen
- 🔄 **Realtime-Updates**: Änderungen sofort sichtbar

## 📱 Responsive Design

- **Desktop**: Vollständige Funktionalität
- **Tablet**: Angepasste Layouts
- **Mobile**: Optimierte Formulare und Navigation

## 🎯 Workflow-Beispiel

### Neues Team hinzufügen
1. **Admin-Bereich öffnen** → Teams-Tab
2. **"Neues Team" klicken**
3. **Formular ausfüllen**:
   - Name: "FC Mahndorf"
   - Kürzel: "FCM"
   - Trainer: "Peter Müller"
   - Stadion: "Mahndorf-Arena"
   - E-Mail: "info@fc-mahndorf.de"
4. **"Speichern" klicken**
5. **Team erscheint sofort** in der Übersicht und auf der Hauptseite

### Spieler hinzufügen
1. **Spieler-Tab öffnen**
2. **"Neuer Spieler" klicken**
3. **Team auswählen** (FC Mahndorf)
4. **Spieler-Details eingeben**
5. **Speichern**

### Spielergebnis eintragen
1. **Spiele-Tab öffnen**
2. **"Neues Spiel" klicken**
3. **Teams auswählen** (Heim/Auswärts)
4. **Ergebnis eingeben**
5. **Spieltag und Datum festlegen**
6. **Speichern** → Tabelle wird automatisch aktualisiert

## 🔧 Erweiterte Konfiguration

### Mehrere Admin-Benutzer
```sql
-- Weitere Admins hinzufügen
-- Ersetze 'admin@wilde-liga.de' in den RLS-Policies mit:
auth.jwt() ->> 'email' IN ('admin@wilde-liga.de', 'admin2@wilde-liga.de')
```

### Rollen-System
```sql
-- Profiles-Tabelle für Rollen
CREATE TABLE profiles (
    id UUID REFERENCES auth.users(id) PRIMARY KEY,
    email TEXT,
    role TEXT DEFAULT 'user',
    created_at TIMESTAMP DEFAULT NOW()
);

-- Policy mit Rollen
CREATE POLICY "Admin role access" ON teams FOR ALL USING (
    EXISTS (
        SELECT 1 FROM profiles 
        WHERE profiles.id = auth.uid() 
        AND profiles.role = 'admin'
    )
);
```

## 🚨 Wichtige Sicherheitshinweise

1. **Starke Passwörter** verwenden
2. **Admin-E-Mail geheim halten**
3. **Regelmäßige Backups** der Datenbank
4. **RLS-Policies regelmäßig überprüfen**
5. **Nur vertrauenswürdige Personen** als Admin

## 📞 Support

Bei Problemen:
1. **Browser-Konsole** überprüfen (F12)
2. **Supabase-Dashboard** → Logs überprüfen
3. **RLS-Policies** überprüfen
4. **Auth-Settings** überprüfen

**Deine Admin-Seite ist bereit! 🎉**
