# 🏆 Wilde Liga Bremen

Eine moderne Fußballliga-Website für Bremen mit Live-Tabellen, Spielergebnissen und Teamverwaltung.

## ✨ Features

- **Live-Tabelle**: Aktuelle Ligatabelle mit Platzierungen
- **Spielergebnisse**: Alle Ergebnisse der gespielten Spiele
- **Spieltermine**: Kommende Spiele und Terminkalender
- **Teamverwaltung**: Detaillierte Teamseiten mit Spielerinfos
- **Admin-Panel**: Verwaltung von Spielen, Ergebnissen und Teams
- **Responsive Design**: Optimiert für Desktop und Mobile

## 🛠 Technologien

- **Frontend**: HTML5, CSS3, JavaScript (ES6+)
- **Backend**: Supabase (PostgreSQL)
- **Deployment**: GitHub Pages
- **Build System**: Node.js
- **CI/CD**: GitHub Actions

## 🚀 Live Demo

Die Website ist verfügbar unter: https://franzfranz1111.github.io/wildeliga/

## 📁 Projektstruktur

```
wildeliga/
├── src/
│   ├── index.html              # Hauptseite (Liga-Übersicht)
│   ├── admin.html              # Admin-Panel
│   ├── config.js               # Konfiguration (wird beim Build generiert)
│   ├── config.template.js      # Konfigurations-Template
│   ├── database-schema.sql     # Datenbankschema
│   ├── styles/                 # CSS-Dateien
│   │   ├── wilde-liga.css      # Hauptstyles
│   │   ├── admin.css           # Admin-Panel Styles
│   │   └── ...
│   ├── scripts/                # JavaScript-Dateien
│   │   └── admin.js            # Admin-Panel Funktionalität
│   ├── teams/                  # Team-spezifische Seiten
│   └── assets/                 # Bilder und andere Assets
├── .github/
│   └── workflows/
│       └── deploy.yml          # GitHub Actions Deployment
├── dist/                       # Build-Output (generiert)
├── build.js                    # Build-Script
└── package.json
```

## 🔧 Installation & Setup

### 1. Repository klonen

```bash
git clone https://github.com/franzfranz1111/wildeliga.git
cd wildeliga
```

### 2. Dependencies installieren

```bash
npm install
```

### 3. Supabase Setup

1. Erstelle ein neues Supabase-Projekt auf [supabase.com](https://supabase.com)
2. Führe das SQL-Schema aus `src/database-schema.sql` aus
3. Kopiere die Supabase-Credentials

### 4. Environment Variables konfigurieren

Erstelle die folgenden Environment Variables:

```bash
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

### 5. Lokale Entwicklung

```bash
# Development Server starten
npm run dev

# Website ist verfügbar unter http://localhost:3000
```

### 6. Build für Production

```bash
npm run build
```

## 📊 Datenbankschema

Das Projekt verwendet folgende Haupttabellen:

- `teams` - Teamdaten (Name, Logo, Spieler)
- `games` - Spiele (Datum, Teams, Ergebnisse)
- `players` - Spielerinformationen
- `league_table` - Tabellenstand

Detailliertes Schema in [`database-schema.sql`](src/database-schema.sql).

## 🔒 Admin-Panel

Das Admin-Panel ist verfügbar unter `/admin.html` und bietet:

- Spielergebnisse eintragen
- Teams verwalten
- Tabelle aktualisieren
- Spieltermine planen

## 🚀 Deployment

### GitHub Pages (Automatisch)

Das Projekt wird automatisch über GitHub Actions deployed:

1. Code in `main` Branch pushen
2. GitHub Action läuft automatisch
3. Website wird unter `https://franzfranz1111.github.io/wildeliga/` deployed

### Manuelle Deployment

```bash
# Environment Variables setzen
export SUPABASE_URL="your-url"
export SUPABASE_ANON_KEY="your-key"

# Build ausführen
npm run build

# dist/ Ordner deployen
npm run serve
```

## 📝 Weitere Dokumentation

- [Admin Setup](src/ADMIN_SETUP.md) - Detaillierte Admin-Anleitung
- [Supabase Setup](src/SUPABASE_SETUP.md) - Datenbankeinrichtung

## 🤝 Beitragen

1. Fork das Repository
2. Erstelle einen Feature Branch (`git checkout -b feature/amazing-feature`)
3. Committe deine Änderungen (`git commit -m 'Add amazing feature'`)
4. Push zum Branch (`git push origin feature/amazing-feature`)
5. Öffne einen Pull Request

## 📄 Lizenz

Dieses Projekt ist unter der MIT-Lizenz lizenziert - siehe [LICENSE](LICENSE) für Details.

## 🏆 Über die Wilde Liga Bremen

Die Wilde Liga Bremen ist eine lokale Fußballliga, die Spaß am Spiel und faire Wettkämpfe in den Vordergrund stellt. Diese Website ermöglicht es, alle Spiele, Ergebnisse und die Tabelle digital zu verwalten und zu verfolgen.

---

Erstellt mit ❤️ für die Fußballgemeinschaft in Bremen
