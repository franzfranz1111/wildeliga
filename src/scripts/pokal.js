// Pokal/Cup Tournament JavaScript
class PokalManager {
    constructor() {
        // Use CONFIG from config.js or fallback to global variables
        const supabaseUrl = window.CONFIG?.supabaseUrl || window.supabaseUrl;
        const supabaseKey = window.CONFIG?.supabaseKey || window.supabaseAnonKey;
        
        if (!supabaseUrl || !supabaseKey) {
            console.error('Supabase configuration missing!', { supabaseUrl, supabaseKey: supabaseKey ? '[PRESENT]' : '[MISSING]' });
            throw new Error('Supabase configuration is required');
        }
        
        this.supabase = window.supabase.createClient(supabaseUrl, supabaseKey);
        this.currentCup = null;
        this.init();
    }

    async init() {
        await this.loadCups();
        this.setupEventListeners();
        await this.loadDefaultCup();
    }

    setupEventListeners() {
        // Cup selector
        document.getElementById('cup-select').addEventListener('change', (e) => {
            if (e.target.value) {
                this.loadCup(e.target.value);
            }
        });

        // Round filter
        document.getElementById('round-filter').addEventListener('change', () => {
            this.loadCupResults();
        });

        // Bracket modal
        document.getElementById('expand-bracket').addEventListener('click', () => {
            this.openBracketModal();
        });

        document.getElementById('close-bracket-modal').addEventListener('click', () => {
            this.closeBracketModal();
        });

        // Close modal on outside click
        document.getElementById('bracket-modal').addEventListener('click', (e) => {
            if (e.target.id === 'bracket-modal') {
                this.closeBracketModal();
            }
        });
    }

    async loadCups() {
        try {
            console.log('Loading cups...');
            const { data: cups, error } = await this.supabase
                .from('cups')
                .select('*')
                .order('year', { ascending: false });

            if (error) {
                console.error('Supabase error loading cups:', error);
                throw error;
            }

            console.log('Loaded cups:', cups);

            const select = document.getElementById('cup-select');
            select.innerHTML = '<option value="">Pokal auswählen...</option>';
            
            if (cups && cups.length > 0) {
                cups.forEach(cup => {
                    const option = document.createElement('option');
                    option.value = cup.id;
                    option.textContent = `${cup.name} (${cup.year})`;
                    select.appendChild(option);
                });
                console.log(`Added ${cups.length} cups to selector`);
            } else {
                console.log('No cups found');
                select.innerHTML = '<option value="">Keine Pokale gefunden</option>';
            }

        } catch (error) {
            console.error('Error loading cups:', error);
            this.showError('Fehler beim Laden der Pokale: ' + error.message);
            const select = document.getElementById('cup-select');
            select.innerHTML = '<option value="">Fehler beim Laden</option>';
        }
    }

    async loadDefaultCup() {
        try {
            console.log('Loading default cup...');
            
            // First try to find Bremen Cup or Wilde Liga Pokal
            let { data: cups, error } = await this.supabase
                .from('cups')
                .select('*')
                .or('name.ilike.%bremen%,name.ilike.%wilde liga pokal%')
                .order('year', { ascending: false })
                .limit(1);

            if (error) throw error;

            // If no Bremen Cup found, try any active cup
            if (!cups || cups.length === 0) {
                console.log('No Bremen Cup found, looking for active cups...');
                const result = await this.supabase
                    .from('cups')
                    .select('*')
                    .eq('status', 'active')
                    .order('year', { ascending: false })
                    .limit(1);
                
                cups = result.data;
                if (result.error) throw result.error;
            }

            // If still no cups, try any cup at all
            if (!cups || cups.length === 0) {
                console.log('No active cups found, looking for any cup...');
                const result = await this.supabase
                    .from('cups')
                    .select('*')
                    .order('year', { ascending: false })
                    .limit(1);
                
                cups = result.data;
                if (result.error) throw result.error;
            }

            if (cups && cups.length > 0) {
                console.log('Auto-selecting cup:', cups[0].name);
                document.getElementById('cup-select').value = cups[0].id;
                await this.loadCup(cups[0].id);
            } else {
                console.log('No cups available');
                // Show message that no tournaments are available
                document.getElementById('tournament-bracket').innerHTML = 
                    '<div class="no-data">Keine Pokalturniere verfügbar</div>';
            }

        } catch (error) {
            console.error('Error loading default cup:', error);
            document.getElementById('tournament-bracket').innerHTML = 
                `<div class="error">Fehler beim Laden: ${error.message}</div>`;
        }
    }

    async loadCup(cupId) {
        try {
            // Load cup details
            const { data: cup, error: cupError } = await this.supabase
                .from('cups')
                .select('*')
                .eq('id', cupId)
                .single();

            if (cupError) throw cupError;

            this.currentCup = cup;
            this.updateCupHeader(cup);
            
            // Load all cup data
            await Promise.all([
                this.loadBracket(cupId),
                this.loadCupResults(cupId),
                this.loadCupTeams(cupId),
                this.updateCupStats(cupId)
            ]);

        } catch (error) {
            console.error('Error loading cup:', error);
            this.showError('Fehler beim Laden des Pokals');
        }
    }

    updateCupHeader(cup) {
        document.querySelector('.pokal-hero h2').textContent = cup.name;
        document.getElementById('current-round').textContent = this.getRoundDisplayName(cup.current_round);
        
        // Update page title
        document.title = `${cup.name} - Wilde Liga Bremen`;
        
        // Update the description
        const description = document.querySelector('.pokal-hero p');
        if (description) {
            if (cup.status === 'completed') {
                description.textContent = `Abgeschlossenes Turnier ${cup.year} - Alle Ergebnisse und der Pokalsieger!`;
            } else if (cup.status === 'active') {
                description.textContent = `Laufendes Turnier ${cup.year} - Spannende K.O.-Spiele um den begehrten Pokal!`;
            } else {
                description.textContent = `Geplantes Turnier ${cup.year} - Bald geht es los!`;
            }
        }
    }

    async updateCupStats(cupId) {
        try {
            // Count teams
            const { data: teams, error: teamsError } = await this.supabase
                .from('cup_teams')
                .select('id')
                .eq('cup_id', cupId);

            // Count played matches
            const { data: matches, error: matchesError } = await this.supabase
                .from('cup_matches')
                .select('id')
                .eq('cup_id', cupId)
                .eq('status', 'played');

            if (teamsError) throw teamsError;
            if (matchesError) throw matchesError;

            document.getElementById('teams-count').textContent = teams.length;
            document.getElementById('matches-played').textContent = matches.length;

        } catch (error) {
            console.error('Error updating cup stats:', error);
        }
    }

    async loadBracket(cupId) {
        try {
            console.log('Loading bracket for cup:', cupId);
            const { data: matches, error } = await this.supabase
                .from('cup_bracket')
                .select('*')
                .eq('cup_id', cupId)
                .order('round')
                .order('match_number');

            if (error) {
                console.error('Supabase error loading bracket:', error);
                throw error;
            }

            console.log('Loaded bracket matches:', matches);
            this.renderBracket(matches);

        } catch (error) {
            console.error('Error loading bracket:', error);
            document.getElementById('tournament-bracket').innerHTML = 
                `<div class="error">Fehler beim Laden des Turnierbaums: ${error.message}</div>`;
        }
    }

    renderBracket(matches) {
        const bracketContainer = document.getElementById('tournament-bracket');
        
        // Group matches by round
        const rounds = this.groupByRound(matches);
        const roundOrder = ['round_1', 'round_2', 'quarter_final', 'semi_final', 'final'];
        
        bracketContainer.innerHTML = '';

        roundOrder.forEach(roundName => {
            if (rounds[roundName]) {
                const roundDiv = this.createRoundDiv(roundName, rounds[roundName]);
                bracketContainer.appendChild(roundDiv);
            }
        });
    }

    groupByRound(matches) {
        return matches.reduce((acc, match) => {
            if (!acc[match.round]) {
                acc[match.round] = [];
            }
            acc[match.round].push(match);
            return acc;
        }, {});
    }

    createRoundDiv(roundName, matches) {
        const roundDiv = document.createElement('div');
        roundDiv.className = `bracket-round round-${roundName}`;

        const title = document.createElement('div');
        title.className = 'round-title';
        title.textContent = this.getRoundDisplayName(roundName);
        roundDiv.appendChild(title);

        matches.forEach(match => {
            const matchDiv = this.createMatchDiv(match);
            roundDiv.appendChild(matchDiv);
        });

        return roundDiv;
    }

    createMatchDiv(match) {
        const matchDiv = document.createElement('div');
        matchDiv.className = `bracket-match ${match.status}`;

        const teamsDiv = document.createElement('div');
        teamsDiv.className = 'match-teams';

        // Home team
        const homeTeam = document.createElement('div');
        homeTeam.className = `match-team ${this.getTeamClass(match, 'home')}`;
        homeTeam.innerHTML = `
            <span class="team-name">${match.home_team || 'TBD'}</span>
            <span class="team-score">${match.home_score !== null ? match.home_score : ''}</span>
        `;
        teamsDiv.appendChild(homeTeam);

        // Away team
        const awayTeam = document.createElement('div');
        awayTeam.className = `match-team ${this.getTeamClass(match, 'away')}`;
        awayTeam.innerHTML = `
            <span class="team-name">${match.away_team || 'TBD'}</span>
            <span class="team-score">${match.away_score !== null ? match.away_score : ''}</span>
        `;
        teamsDiv.appendChild(awayTeam);

        matchDiv.appendChild(teamsDiv);

        // Match info
        if (match.match_date || match.status === 'played') {
            const infoDiv = document.createElement('div');
            infoDiv.className = 'match-info';
            
            if (match.match_date) {
                const date = new Date(match.match_date);
                infoDiv.innerHTML = `<div class="match-date">${date.toLocaleDateString('de-DE')}</div>`;
            }

            // Penalty info
            if (match.penalty_home_score !== null && match.penalty_away_score !== null) {
                const penaltyDiv = document.createElement('div');
                penaltyDiv.className = 'penalty-info';
                penaltyDiv.textContent = `Elfmeter: ${match.penalty_home_score}:${match.penalty_away_score}`;
                infoDiv.appendChild(penaltyDiv);
            }

            matchDiv.appendChild(infoDiv);
        }

        return matchDiv;
    }

    getTeamClass(match, side) {
        if (match.status !== 'played' || !match.winner_team) return '';
        
        const teamName = side === 'home' ? match.home_team : match.away_team;
        
        if (teamName === match.winner_team) return 'winner';
        return 'loser';
    }

    async loadCupResults(cupId = null) {
        if (!cupId && this.currentCup) {
            cupId = this.currentCup.id;
        }
        if (!cupId) return;

        try {
            let query = this.supabase
                .from('cup_bracket')
                .select('*')
                .eq('cup_id', cupId)
                .eq('status', 'played')
                .order('match_date', { ascending: false });

            const roundFilter = document.getElementById('round-filter').value;
            if (roundFilter) {
                query = query.eq('round', roundFilter);
            }

            const { data: results, error } = await query;
            if (error) throw error;

            this.renderResults(results);

        } catch (error) {
            console.error('Error loading cup results:', error);
            document.getElementById('cup-results').innerHTML = 
                '<div class="error">Fehler beim Laden der Ergebnisse</div>';
        }
    }

    renderResults(results) {
        const container = document.getElementById('cup-results');
        
        if (results.length === 0) {
            container.innerHTML = '<div class="no-results">Keine Ergebnisse gefunden</div>';
            return;
        }

        container.innerHTML = '';

        results.forEach(result => {
            const resultDiv = document.createElement('div');
            resultDiv.className = 'result-item';

            const matchDiv = document.createElement('div');
            matchDiv.className = 'result-match';

            const penaltyText = result.penalty_home_score !== null ? 
                ` (${result.penalty_home_score}:${result.penalty_away_score} i.E.)` : '';

            matchDiv.innerHTML = `
                <div class="result-teams">${result.home_team} vs ${result.away_team}</div>
                <div class="result-score">${result.home_score}:${result.away_score}${penaltyText}</div>
            `;

            const infoDiv = document.createElement('div');
            infoDiv.className = 'result-info';
            infoDiv.innerHTML = `
                <div class="result-round">${this.getRoundDisplayName(result.round)}</div>
                <div class="result-date">${new Date(result.match_date).toLocaleDateString('de-DE')}</div>
            `;

            resultDiv.appendChild(matchDiv);
            resultDiv.appendChild(infoDiv);
            container.appendChild(resultDiv);
        });
    }

    async loadCupTeams(cupId) {
        try {
            const { data: teams, error } = await this.supabase
                .from('cup_teams')
                .select(`
                    *,
                    team:teams(name)
                `)
                .eq('cup_id', cupId);

            if (error) throw error;

            this.renderCupTeams(teams);

        } catch (error) {
            console.error('Error loading cup teams:', error);
            document.getElementById('cup-teams').innerHTML = 
                '<div class="error">Fehler beim Laden der Teams</div>';
        }
    }

    renderCupTeams(teams) {
        const container = document.getElementById('cup-teams');
        container.innerHTML = '';

        teams.forEach(team => {
            const teamDiv = document.createElement('div');
            teamDiv.className = `team-card ${this.getTeamStatus(team)}`;

            teamDiv.innerHTML = `
                <div class="team-name-card">${team.team.name}</div>
                <div class="team-status ${this.getTeamStatus(team)}">${this.getTeamStatusText(team)}</div>
            `;

            container.appendChild(teamDiv);
        });
    }

    getTeamStatus(team) {
        if (team.eliminated_in_round) return 'eliminated';
        // Check if team is cup winner
        return 'active';
    }

    getTeamStatusText(team) {
        if (team.eliminated_in_round) {
            return `Ausgeschieden im ${this.getRoundDisplayName(team.eliminated_in_round)}`;
        }
        return 'Noch im Turnier';
    }

    getRoundDisplayName(round) {
        const rounds = {
            'round_1': '1. Runde',
            'round_2': 'Achtelfinale',
            'quarter_final': 'Viertelfinale',
            'semi_final': 'Halbfinale',
            'final': 'Finale'
        };
        return rounds[round] || round;
    }

    openBracketModal() {
        const modal = document.getElementById('bracket-modal');
        const fullscreenBracket = document.getElementById('fullscreen-bracket');
        const originalBracket = document.getElementById('tournament-bracket');
        
        // Clone the bracket content
        fullscreenBracket.innerHTML = originalBracket.innerHTML;
        modal.style.display = 'flex';
        document.body.style.overflow = 'hidden';
    }

    closeBracketModal() {
        const modal = document.getElementById('bracket-modal');
        modal.style.display = 'none';
        document.body.style.overflow = 'auto';
    }

    showError(message) {
        console.error(message);
        
        // Create or update error display
        let errorContainer = document.getElementById('pokal-error-display');
        if (!errorContainer) {
            errorContainer = document.createElement('div');
            errorContainer.id = 'pokal-error-display';
            errorContainer.className = 'error-message show';
            errorContainer.style.cssText = `
                background: #ffebee;
                color: #c62828;
                border: 1px solid #ffcdd2;
                border-radius: 4px;
                padding: 1rem;
                margin: 1rem 0;
                display: block;
            `;
            
            // Insert at the top of main content
            const mainContent = document.querySelector('.main-content .container');
            if (mainContent) {
                mainContent.insertBefore(errorContainer, mainContent.firstChild);
            }
        }
        
        errorContainer.innerHTML = `
            <strong>Fehler:</strong> ${message}
            <button onclick="this.parentElement.remove()" style="float: right; background: none; border: none; color: #c62828; cursor: pointer; font-size: 18px;">&times;</button>
        `;
        
        // Auto-hide after 10 seconds
        setTimeout(() => {
            if (errorContainer && errorContainer.parentElement) {
                errorContainer.remove();
            }
        }, 10000);
    }
}

// Initialize when page loads
document.addEventListener('DOMContentLoaded', () => {
    new PokalManager();
});
