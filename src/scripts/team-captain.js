// Team Captain System for Wilde Liga Bremen
class TeamCaptainSystem {
    constructor() {
        this.supabase = window.supabase.createClient(CONFIG.supabaseUrl, CONFIG.supabaseKey);
        this.currentUser = null;
        this.userProfile = null;
        this.teamData = null;
        this.currentMatch = null;
        this.currentPlayer = null;
        
        this.init();
    }

    async init() {
        try {
            await this.checkAuth();
            await this.loadUserProfile();
            await this.loadTeamData();
            this.initializeEventListeners();
            this.loadAllData();
        } catch (error) {
            console.error('Initialization error:', error);
            this.redirectToLogin();
        }
    }

    async checkAuth() {
        const { data: { user } } = await this.supabase.auth.getUser();
        if (!user) {
            this.redirectToLogin();
            return;
        }
        this.currentUser = user;
    }

    async loadUserProfile() {
        const { data: profile, error } = await this.supabase
            .from('user_profiles')
            .select('*')
            .eq('id', this.currentUser.id)
            .single();

        if (error || !profile) {
            console.error('Profile load error:', error);
            this.redirectToLogin();
            return;
        }

        if (profile.role !== 'team_captain') {
            this.showAlert('Fehler', 'Keine Berechtigung für diese Seite.', 'error');
            setTimeout(() => window.location.href = 'index.html', 2000);
            return;
        }

        this.userProfile = profile;
        
        // Update UI
        document.getElementById('user-name').textContent = profile.name || profile.email;
    }

    async loadTeamData() {
        if (!this.userProfile.team_id) {
            this.showAlert('Fehler', 'Kein Team zugewiesen.', 'error');
            return;
        }

        const { data: team, error } = await this.supabase
            .from('teams')
            .select('*')
            .eq('id', this.userProfile.team_id)
            .single();

        if (error || !team) {
            console.error('Team load error:', error);
            this.showAlert('Fehler', 'Team konnte nicht geladen werden.', 'error');
            return;
        }

        this.teamData = team;
        
        // Update UI
        document.getElementById('team-name').textContent = team.name;
        this.populateTeamForm(team);
    }

    populateTeamForm(team) {
        document.getElementById('team-name-input').value = team.name || '';
        document.getElementById('team-short-name').value = team.short_name || '';
        document.getElementById('team-description').value = team.description || '';
        document.getElementById('team-stadium').value = team.stadium || '';
        document.getElementById('team-coach').value = team.coach || '';
        document.getElementById('team-email').value = team.email || '';
        document.getElementById('team-colors').value = team.colors || '';
        document.getElementById('team-training-days').value = team.training_days || '';
    }

    initializeEventListeners() {
        // Team form
        document.getElementById('team-form').addEventListener('submit', (e) => {
            e.preventDefault();
            this.handleTeamUpdate();
        });

        // Match form
        document.getElementById('match-form').addEventListener('submit', (e) => {
            e.preventDefault();
            this.handleMatchUpdate();
        });

        // Player form
        document.getElementById('player-form').addEventListener('submit', (e) => {
            e.preventDefault();
            this.handlePlayerSave();
        });

        // Add player button
        document.getElementById('add-player-btn').addEventListener('click', () => {
            this.showPlayerModal();
        });

        // Logout button
        document.getElementById('logout-btn').addEventListener('click', () => {
            this.handleLogout();
        });
    }

    async loadAllData() {
        this.showLoading(true);
        try {
            await Promise.all([
                this.loadMatches(),
                this.loadPlayers()
            ]);
        } catch (error) {
            console.error('Data loading error:', error);
            this.showAlert('Fehler', 'Daten konnten nicht geladen werden.', 'error');
        } finally {
            this.showLoading(false);
        }
    }

    async loadMatches() {
        const { data: matches, error } = await this.supabase
            .from('matches')
            .select(`
                *,
                home_team:teams!matches_home_team_id_fkey(name),
                away_team:teams!matches_away_team_id_fkey(name)
            `)
            .or(`home_team_id.eq.${this.userProfile.team_id},away_team_id.eq.${this.userProfile.team_id}`)
            .order('match_date', { ascending: false });

        if (error) {
            console.error('Matches load error:', error);
            return;
        }

        this.renderMatches(matches || []);
    }

    renderMatches(matches) {
        const upcomingContainer = document.getElementById('upcoming-matches');
        const recentContainer = document.getElementById('recent-matches');
        
        upcomingContainer.innerHTML = '';
        recentContainer.innerHTML = '';

        const today = new Date();
        const upcoming = matches.filter(match => 
            !match.home_score && !match.away_score && 
            match.match_date && new Date(match.match_date) >= today
        );
        const recent = matches.filter(match => 
            match.home_score !== null && match.away_score !== null
        );

        // Upcoming matches
        if (upcoming.length === 0) {
            upcomingContainer.innerHTML = '<p>Keine kommenden Spiele</p>';
        } else {
            upcoming.forEach(match => {
                const matchElement = this.createMatchElement(match, true);
                upcomingContainer.appendChild(matchElement);
            });
        }

        // Recent matches
        if (recent.length === 0) {
            recentContainer.innerHTML = '<p>Keine gespielten Spiele</p>';
        } else {
            recent.forEach(match => {
                const matchElement = this.createMatchElement(match, false);
                recentContainer.appendChild(matchElement);
            });
        }
    }

    createMatchElement(match, isUpcoming) {
        const div = document.createElement('div');
        div.className = 'match-item';
        
        const isHome = match.home_team_id === this.userProfile.team_id;
        const opponent = isHome ? match.away_team.name : match.home_team.name;
        const location = isHome ? 'Heim' : 'Auswärts';
        
        let scoreDisplay = '';
        if (!isUpcoming) {
            scoreDisplay = `<span class="match-score">${match.home_score}:${match.away_score}</span>`;
        }

        div.innerHTML = `
            <div class="match-teams">
                <strong>${opponent}</strong> (${location})
                <div class="match-date">${this.formatDate(match.match_date)}</div>
            </div>
            ${scoreDisplay}
            <div class="match-actions">
                ${isUpcoming ? `<button class="edit-btn" onclick="teamCaptain.showMatchModal('${match.id}')">Ergebnis eintragen</button>` : ''}
            </div>
        `;
        
        return div;
    }

    async loadPlayers() {
        const { data: players, error } = await this.supabase
            .from('players')
            .select('*')
            .eq('team_id', this.userProfile.team_id)
            .order('jersey_number', { ascending: true });

        if (error) {
            console.error('Players load error:', error);
            return;
        }

        this.renderPlayers(players || []);
    }

    renderPlayers(players) {
        const tbody = document.getElementById('players-tbody');
        tbody.innerHTML = '';

        if (players.length === 0) {
            tbody.innerHTML = '<tr><td colspan="5">Keine Spieler vorhanden</td></tr>';
            return;
        }

        players.forEach(player => {
            const row = document.createElement('tr');
            row.innerHTML = `
                <td>${player.name}</td>
                <td>${player.position || '-'}</td>
                <td>${player.jersey_number || '-'}</td>
                <td>${player.age || '-'}</td>
                <td>
                    <button class="action-btn" onclick="teamCaptain.editPlayer('${player.id}')">Bearbeiten</button>
                    <button class="action-btn delete" onclick="teamCaptain.deletePlayer('${player.id}')">Löschen</button>
                </td>
            `;
            tbody.appendChild(row);
        });
    }

    async handleTeamUpdate() {
        const formData = {
            description: document.getElementById('team-description').value,
            stadium: document.getElementById('team-stadium').value,
            coach: document.getElementById('team-coach').value,
            email: document.getElementById('team-email').value,
            colors: document.getElementById('team-colors').value,
            training_days: document.getElementById('team-training-days').value
        };

        this.showLoading(true);

        try {
            const { error } = await this.supabase
                .from('teams')
                .update(formData)
                .eq('id', this.userProfile.team_id);

            if (error) throw error;

            this.showAlert('Erfolg', 'Team-Informationen wurden aktualisiert.', 'success');
            
        } catch (error) {
            console.error('Team update error:', error);
            this.showAlert('Fehler', 'Team-Informationen konnten nicht aktualisiert werden.', 'error');
        } finally {
            this.showLoading(false);
        }
    }

    async showMatchModal(matchId) {
        try {
            const { data: match, error } = await this.supabase
                .from('matches')
                .select(`
                    *,
                    home_team:teams!matches_home_team_id_fkey(name),
                    away_team:teams!matches_away_team_id_fkey(name)
                `)
                .eq('id', matchId)
                .single();

            if (error) throw error;

            this.currentMatch = match;
            
            // Update modal content
            document.getElementById('match-info').innerHTML = `
                <strong>${match.home_team.name}</strong> vs <strong>${match.away_team.name}</strong><br>
                ${this.formatDate(match.match_date)}
            `;
            
            // Set current values if available
            document.getElementById('home-score').value = match.home_score || '';
            document.getElementById('away-score').value = match.away_score || '';
            
            // Show modal
            document.getElementById('match-modal').classList.add('active');
            
        } catch (error) {
            console.error('Match modal error:', error);
            this.showAlert('Fehler', 'Spiel konnte nicht geladen werden.', 'error');
        }
    }

    async handleMatchUpdate() {
        if (!this.currentMatch) return;

        const homeScore = parseInt(document.getElementById('home-score').value);
        const awayScore = parseInt(document.getElementById('away-score').value);

        if (homeScore < 0 || awayScore < 0) {
            this.showAlert('Fehler', 'Tore müssen positiv sein.', 'error');
            return;
        }

        this.showLoading(true);

        try {
            const { error } = await this.supabase
                .from('matches')
                .update({
                    home_score: homeScore,
                    away_score: awayScore,
                    status: 'completed'
                })
                .eq('id', this.currentMatch.id);

            if (error) throw error;

            this.showAlert('Erfolg', 'Spielergebnis wurde gespeichert.', 'success');
            this.closeModal();
            this.loadMatches();
            
        } catch (error) {
            console.error('Match update error:', error);
            this.showAlert('Fehler', 'Spielergebnis konnte nicht gespeichert werden.', 'error');
        } finally {
            this.showLoading(false);
        }
    }

    showPlayerModal(player = null) {
        this.currentPlayer = player;
        
        if (player) {
            document.getElementById('player-modal-title').textContent = 'Spieler bearbeiten';
            document.getElementById('player-name').value = player.name;
            document.getElementById('player-position').value = player.position || '';
            document.getElementById('player-number').value = player.jersey_number || '';
            document.getElementById('player-age').value = player.age || '';
        } else {
            document.getElementById('player-modal-title').textContent = 'Spieler hinzufügen';
            document.getElementById('player-form').reset();
        }
        
        document.getElementById('player-modal').classList.add('active');
    }

    async handlePlayerSave() {
        const formData = {
            name: document.getElementById('player-name').value,
            position: document.getElementById('player-position').value,
            jersey_number: document.getElementById('player-number').value || null,
            age: document.getElementById('player-age').value || null,
            team_id: this.userProfile.team_id
        };

        if (!formData.name) {
            this.showAlert('Fehler', 'Name ist erforderlich.', 'error');
            return;
        }

        this.showLoading(true);

        try {
            if (this.currentPlayer) {
                // Update existing player
                const { error } = await this.supabase
                    .from('players')
                    .update(formData)
                    .eq('id', this.currentPlayer.id);

                if (error) throw error;
                this.showAlert('Erfolg', 'Spieler wurde aktualisiert.', 'success');
            } else {
                // Create new player
                const { error } = await this.supabase
                    .from('players')
                    .insert(formData);

                if (error) throw error;
                this.showAlert('Erfolg', 'Spieler wurde hinzugefügt.', 'success');
            }

            this.closeModal();
            this.loadPlayers();
            
        } catch (error) {
            console.error('Player save error:', error);
            this.showAlert('Fehler', 'Spieler konnte nicht gespeichert werden.', 'error');
        } finally {
            this.showLoading(false);
        }
    }

    async editPlayer(playerId) {
        try {
            const { data: player, error } = await this.supabase
                .from('players')
                .select('*')
                .eq('id', playerId)
                .single();

            if (error) throw error;

            this.showPlayerModal(player);
            
        } catch (error) {
            console.error('Player edit error:', error);
            this.showAlert('Fehler', 'Spieler konnte nicht geladen werden.', 'error');
        }
    }

    async deletePlayer(playerId) {
        if (!confirm('Spieler wirklich löschen?')) return;

        this.showLoading(true);

        try {
            const { error } = await this.supabase
                .from('players')
                .delete()
                .eq('id', playerId);

            if (error) throw error;

            this.showAlert('Erfolg', 'Spieler wurde gelöscht.', 'success');
            this.loadPlayers();
            
        } catch (error) {
            console.error('Player delete error:', error);
            this.showAlert('Fehler', 'Spieler konnte nicht gelöscht werden.', 'error');
        } finally {
            this.showLoading(false);
        }
    }

    async handleLogout() {
        try {
            await this.supabase.auth.signOut();
            window.location.href = 'login.html';
        } catch (error) {
            console.error('Logout error:', error);
        }
    }

    redirectToLogin() {
        window.location.href = 'login.html?redirect=team-captain.html';
    }

    closeModal() {
        document.querySelectorAll('.modal').forEach(modal => {
            modal.classList.remove('active');
        });
        this.currentMatch = null;
        this.currentPlayer = null;
    }

    showLoading(show) {
        const overlay = document.getElementById('loading-overlay');
        if (show) {
            overlay.classList.add('active');
        } else {
            overlay.classList.remove('active');
        }
    }

    showAlert(title, message, type = 'info') {
        const container = document.getElementById('alert-container');
        const alert = document.createElement('div');
        alert.className = `alert ${type}`;
        
        alert.innerHTML = `
            <div class="alert-title">${title}</div>
            <div class="alert-message">${message}</div>
        `;
        
        container.appendChild(alert);
        
        setTimeout(() => {
            alert.classList.add('show');
        }, 100);
        
        setTimeout(() => {
            alert.classList.remove('show');
            setTimeout(() => {
                if (alert.parentNode) {
                    alert.parentNode.removeChild(alert);
                }
            }, 300);
        }, 5000);
    }

    formatDate(dateString) {
        if (!dateString) return 'Kein Datum';
        const date = new Date(dateString);
        return date.toLocaleDateString('de-DE', {
            weekday: 'short',
            year: 'numeric',
            month: 'short',
            day: 'numeric'
        });
    }
}

// Global functions for onclick handlers
let teamCaptain;

function showTab(tabName) {
    // Hide all tabs
    document.querySelectorAll('.tab-content').forEach(tab => {
        tab.classList.remove('active');
    });
    
    // Remove active class from all nav tabs
    document.querySelectorAll('.nav-tab').forEach(tab => {
        tab.classList.remove('active');
    });
    
    // Show selected tab
    document.getElementById(tabName + '-tab').classList.add('active');
    
    // Add active class to clicked nav tab
    event.target.classList.add('active');
}

function closeModal() {
    if (teamCaptain) {
        teamCaptain.closeModal();
    }
}

// Initialize when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    teamCaptain = new TeamCaptainSystem();
});
