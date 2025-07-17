// Admin Interface JavaScript

let currentUser = null;
let teams = [];
let players = [];

// Initialize admin interface
document.addEventListener('DOMContentLoaded', function() {
    initializeAuth();
    initializeEventListeners();
});

// Authentication
async function initializeAuth() {
    // Check if user is already logged in
    const { data: { user } } = await supabase.auth.getUser();
    
    if (user) {
        currentUser = user;
        showAdminDashboard();
    } else {
        showLoginModal();
    }
}

function showLoginModal() {
    document.getElementById('loginModal').style.display = 'block';
    document.getElementById('adminDashboard').style.display = 'none';
}

function showAdminDashboard() {
    document.getElementById('loginModal').style.display = 'none';
    document.getElementById('adminDashboard').style.display = 'block';
    loadInitialData();
}

// Event Listeners
function initializeEventListeners() {
    // Login form
    document.getElementById('loginForm').addEventListener('submit', handleLogin);
    
    // Logout button
    document.getElementById('logoutBtn').addEventListener('click', handleLogout);
    
    // Tab navigation
    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.addEventListener('click', (e) => switchTab(e.target.dataset.tab));
    });
    
    // Add buttons
    document.getElementById('addTeamBtn').addEventListener('click', () => openTeamModal());
    document.getElementById('addPlayerBtn').addEventListener('click', () => openPlayerModal());
    document.getElementById('addMatchBtn').addEventListener('click', () => openMatchModal());
    
    // Forms
    document.getElementById('teamForm').addEventListener('submit', handleTeamSubmit);
    document.getElementById('playerForm').addEventListener('submit', handlePlayerSubmit);
    document.getElementById('matchForm').addEventListener('submit', handleMatchSubmit);
    
    // Filter
    document.getElementById('playerTeamFilter').addEventListener('change', filterPlayers);
}

// Login/Logout
async function handleLogin(e) {
    e.preventDefault();
    
    const email = document.getElementById('email').value;
    const password = document.getElementById('password').value;
    const errorDiv = document.getElementById('loginError');
    
    try {
        const { data, error } = await supabase.auth.signInWithPassword({
            email,
            password
        });
        
        if (error) {
            errorDiv.textContent = 'Anmeldung fehlgeschlagen: ' + error.message;
            errorDiv.style.display = 'block';
        } else {
            currentUser = data.user;
            showAdminDashboard();
        }
    } catch (error) {
        errorDiv.textContent = 'Fehler beim Anmelden';
        errorDiv.style.display = 'block';
    }
}

async function handleLogout() {
    await supabase.auth.signOut();
    currentUser = null;
    showLoginModal();
}

// Tab Navigation
function switchTab(tabName) {
    // Update tab buttons
    document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
    document.querySelector(`[data-tab="${tabName}"]`).classList.add('active');
    
    // Update tab content
    document.querySelectorAll('.tab-content').forEach(content => content.classList.remove('active'));
    document.getElementById(`${tabName}Tab`).classList.add('active');
    
    // Load data for the active tab
    switch(tabName) {
        case 'teams':
            loadTeams();
            break;
        case 'players':
            loadPlayers();
            break;
        case 'matches':
            loadMatches();
            break;
        case 'achievements':
            loadAchievements();
            break;
    }
}

// Load initial data
async function loadInitialData() {
    await loadTeams();
    await loadTeamOptions();
}

// Team Management
async function loadTeams() {
    try {
        teams = await WildeLigaAPI.getTeams();
        renderTeams();
    } catch (error) {
        console.error('Error loading teams:', error);
    }
}

function renderTeams() {
    const container = document.getElementById('teamsGrid');
    container.innerHTML = '';
    
    teams.forEach(team => {
        const teamCard = `
            <div class="team-admin-card">
                <h3>${team.name}</h3>
                <p><strong>Kürzel:</strong> ${team.short_name || '-'}</p>
                <p><strong>Trainer:</strong> ${team.coach || '-'}</p>
                <p><strong>Stadion:</strong> ${team.stadium || '-'}</p>
                <p><strong>E-Mail:</strong> ${team.email || '-'}</p>
                <div class="team-admin-actions">
                    <button class="btn-edit" onclick="editTeam('${team.id}')">Bearbeiten</button>
                    <button class="btn-danger" onclick="deleteTeam('${team.id}')">Löschen</button>
                </div>
            </div>
        `;
        container.innerHTML += teamCard;
    });
}

function openTeamModal(teamId = null) {
    const modal = document.getElementById('teamModal');
    const title = document.getElementById('teamModalTitle');
    const form = document.getElementById('teamForm');
    
    if (teamId) {
        const team = teams.find(t => t.id === teamId);
        title.textContent = 'Team bearbeiten';
        
        // Fill form with team data
        document.getElementById('teamId').value = team.id;
        document.getElementById('teamName').value = team.name;
        document.getElementById('teamShortName').value = team.short_name || '';
        document.getElementById('teamDescription').value = team.description || '';
        document.getElementById('teamStadium').value = team.stadium || '';
        document.getElementById('teamCoach').value = team.coach || '';
        document.getElementById('teamEmail').value = team.email || '';
        document.getElementById('teamTraining').value = team.training_days || '';
    } else {
        title.textContent = 'Neues Team';
        form.reset();
        document.getElementById('teamId').value = '';
    }
    
    modal.style.display = 'block';
}

function editTeam(teamId) {
    openTeamModal(teamId);
}

async function deleteTeam(teamId) {
    if (confirm('Team wirklich löschen? Alle Spieler und Spiele werden ebenfalls gelöscht.')) {
        try {
            const { error } = await supabase
                .from('teams')
                .delete()
                .eq('id', teamId);
            
            if (error) throw error;
            
            await loadTeams();
            showSuccessMessage('Team erfolgreich gelöscht');
        } catch (error) {
            console.error('Error deleting team:', error);
            showErrorMessage('Fehler beim Löschen des Teams');
        }
    }
}

async function handleTeamSubmit(e) {
    e.preventDefault();
    
    const teamData = {
        name: document.getElementById('teamName').value,
        short_name: document.getElementById('teamShortName').value,
        description: document.getElementById('teamDescription').value,
        stadium: document.getElementById('teamStadium').value,
        coach: document.getElementById('teamCoach').value,
        email: document.getElementById('teamEmail').value,
        training_days: document.getElementById('teamTraining').value
    };
    
    const teamId = document.getElementById('teamId').value;
    
    try {
        if (teamId) {
            // Update existing team
            const { error } = await supabase
                .from('teams')
                .update(teamData)
                .eq('id', teamId);
            
            if (error) throw error;
            showSuccessMessage('Team erfolgreich aktualisiert');
        } else {
            // Create new team
            const { error } = await supabase
                .from('teams')
                .insert([teamData]);
            
            if (error) throw error;
            showSuccessMessage('Team erfolgreich erstellt');
        }
        
        closeModal('teamModal');
        await loadTeams();
        await loadTeamOptions();
    } catch (error) {
        console.error('Error saving team:', error);
        showErrorMessage('Fehler beim Speichern des Teams');
    }
}

// Player Management
async function loadPlayers() {
    try {
        const { data, error } = await supabase
            .from('players')
            .select(`
                *,
                team:teams(name)
            `)
            .order('name');
        
        if (error) throw error;
        
        players = data;
        renderPlayers();
    } catch (error) {
        console.error('Error loading players:', error);
    }
}

function renderPlayers() {
    const container = document.getElementById('playersList');
    const filter = document.getElementById('playerTeamFilter').value;
    
    container.innerHTML = '';
    
    const filteredPlayers = filter === 'all' 
        ? players 
        : players.filter(p => p.team.name === filter);
    
    filteredPlayers.forEach(player => {
        const playerItem = `
            <div class="player-item">
                <div class="player-info">
                    <h4>${player.name}</h4>
                    <p><strong>Team:</strong> ${player.team.name}</p>
                    <p><strong>Position:</strong> ${player.position || '-'} | 
                       <strong>Nummer:</strong> ${player.jersey_number || '-'} | 
                       <strong>Alter:</strong> ${player.age || '-'}</p>
                </div>
                <div class="item-actions">
                    <button class="btn-edit" onclick="editPlayer('${player.id}')">Bearbeiten</button>
                    <button class="btn-danger" onclick="deletePlayer('${player.id}')">Löschen</button>
                </div>
            </div>
        `;
        container.innerHTML += playerItem;
    });
}

function openPlayerModal(playerId = null) {
    const modal = document.getElementById('playerModal');
    const title = document.getElementById('playerModalTitle');
    const form = document.getElementById('playerForm');
    
    if (playerId) {
        const player = players.find(p => p.id === playerId);
        title.textContent = 'Spieler bearbeiten';
        
        document.getElementById('playerId').value = player.id;
        document.getElementById('playerTeam').value = player.team_id;
        document.getElementById('playerName').value = player.name;
        document.getElementById('playerPosition').value = player.position || '';
        document.getElementById('playerNumber').value = player.jersey_number || '';
        document.getElementById('playerAge').value = player.age || '';
    } else {
        title.textContent = 'Neuer Spieler';
        form.reset();
        document.getElementById('playerId').value = '';
    }
    
    modal.style.display = 'block';
}

function editPlayer(playerId) {
    openPlayerModal(playerId);
}

async function deletePlayer(playerId) {
    if (confirm('Spieler wirklich löschen?')) {
        try {
            const { error } = await supabase
                .from('players')
                .delete()
                .eq('id', playerId);
            
            if (error) throw error;
            
            await loadPlayers();
            showSuccessMessage('Spieler erfolgreich gelöscht');
        } catch (error) {
            console.error('Error deleting player:', error);
            showErrorMessage('Fehler beim Löschen des Spielers');
        }
    }
}

async function handlePlayerSubmit(e) {
    e.preventDefault();
    
    const playerData = {
        team_id: document.getElementById('playerTeam').value,
        name: document.getElementById('playerName').value,
        position: document.getElementById('playerPosition').value,
        jersey_number: document.getElementById('playerNumber').value || null,
        age: document.getElementById('playerAge').value || null
    };
    
    const playerId = document.getElementById('playerId').value;
    
    try {
        if (playerId) {
            // Update existing player
            const { error } = await supabase
                .from('players')
                .update(playerData)
                .eq('id', playerId);
            
            if (error) throw error;
            showSuccessMessage('Spieler erfolgreich aktualisiert');
        } else {
            // Create new player
            const { error } = await supabase
                .from('players')
                .insert([playerData]);
            
            if (error) throw error;
            showSuccessMessage('Spieler erfolgreich erstellt');
        }
        
        closeModal('playerModal');
        await loadPlayers();
    } catch (error) {
        console.error('Error saving player:', error);
        showErrorMessage('Fehler beim Speichern des Spielers');
    }
}

// Match Management
async function loadMatches() {
    try {
        const matches = await WildeLigaAPI.getAllMatches();
        renderMatches(matches);
    } catch (error) {
        console.error('Error loading matches:', error);
    }
}

function renderMatches(matches) {
    const container = document.getElementById('matchesList');
    container.innerHTML = '';
    
    matches.forEach(match => {
        const matchItem = `
            <div class="match-item">
                <div class="match-info">
                    <h4>${match.home_team.name} vs ${match.away_team.name}</h4>
                    <p><strong>Ergebnis:</strong> ${match.home_score}:${match.away_score} | 
                       <strong>Spieltag:</strong> ${match.matchday} | 
                       <strong>Datum:</strong> ${new Date(match.match_date).toLocaleDateString('de-DE')}</p>
                </div>
                <div class="item-actions">
                    <button class="btn-edit" onclick="editMatch('${match.id}')">Bearbeiten</button>
                    <button class="btn-danger" onclick="deleteMatch('${match.id}')">Löschen</button>
                </div>
            </div>
        `;
        container.innerHTML += matchItem;
    });
}

function openMatchModal(matchId = null) {
    const modal = document.getElementById('matchModal');
    const title = document.getElementById('matchModalTitle');
    const form = document.getElementById('matchForm');
    
    if (matchId) {
        // Load match data and populate form
        title.textContent = 'Spiel bearbeiten';
        // Implementation would load match data
    } else {
        title.textContent = 'Neues Spiel';
        form.reset();
        document.getElementById('matchId').value = '';
    }
    
    modal.style.display = 'block';
}

async function handleMatchSubmit(e) {
    e.preventDefault();
    
    const matchData = {
        home_team_id: document.getElementById('matchHomeTeam').value,
        away_team_id: document.getElementById('matchAwayTeam').value,
        home_score: parseInt(document.getElementById('matchHomeScore').value),
        away_score: parseInt(document.getElementById('matchAwayScore').value),
        matchday: parseInt(document.getElementById('matchDay').value),
        match_date: document.getElementById('matchDate').value,
        status: 'completed'
    };
    
    const matchId = document.getElementById('matchId').value;
    
    try {
        if (matchId) {
            // Update existing match
            const { error } = await supabase
                .from('matches')
                .update(matchData)
                .eq('id', matchId);
            
            if (error) throw error;
            showSuccessMessage('Spiel erfolgreich aktualisiert');
        } else {
            // Create new match
            const { error } = await supabase
                .from('matches')
                .insert([matchData]);
            
            if (error) throw error;
            showSuccessMessage('Spiel erfolgreich erstellt');
        }
        
        closeModal('matchModal');
        await loadMatches();
    } catch (error) {
        console.error('Error saving match:', error);
        showErrorMessage('Fehler beim Speichern des Spiels');
    }
}

// Utility Functions
async function loadTeamOptions() {
    const selects = ['playerTeam', 'playerTeamFilter', 'matchHomeTeam', 'matchAwayTeam'];
    
    selects.forEach(selectId => {
        const select = document.getElementById(selectId);
        if (select) {
            // Clear existing options (except first one)
            while (select.children.length > 1) {
                select.removeChild(select.lastChild);
            }
            
            // Add team options
            teams.forEach(team => {
                const option = document.createElement('option');
                option.value = team.id;
                option.textContent = team.name;
                select.appendChild(option);
            });
        }
    });
}

function filterPlayers() {
    renderPlayers();
}

function closeModal(modalId) {
    document.getElementById(modalId).style.display = 'none';
}

function showSuccessMessage(message) {
    // Simple alert for now - could be enhanced with toast notifications
    alert(message);
}

function showErrorMessage(message) {
    alert('Fehler: ' + message);
}

// Load achievements (placeholder)
async function loadAchievements() {
    // Implementation for achievements management
    console.log('Loading achievements...');
}

// Global functions for onclick handlers
window.editTeam = editTeam;
window.deleteTeam = deleteTeam;
window.editPlayer = editPlayer;
window.deletePlayer = deletePlayer;
window.editMatch = openMatchModal;
window.deleteMatch = async function(matchId) {
    if (confirm('Spiel wirklich löschen?')) {
        try {
            const { error } = await supabase
                .from('matches')
                .delete()
                .eq('id', matchId);
            
            if (error) throw error;
            
            await loadMatches();
            showSuccessMessage('Spiel erfolgreich gelöscht');
        } catch (error) {
            console.error('Error deleting match:', error);
            showErrorMessage('Fehler beim Löschen des Spiels');
        }
    }
};
window.closeModal = closeModal;
