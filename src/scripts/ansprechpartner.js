// Ansprechpartner Interface JavaScript

let currentUser = null;
let userTeam = null;
let currentMatches = [];

// Initialize interface
document.addEventListener('DOMContentLoaded', function() {
    initializeAuth();
    setupEventListeners();
});

function setupEventListeners() {
    // Login form
    document.getElementById('loginForm').addEventListener('submit', handleLogin);
    
    // Logout button
    document.getElementById('logoutBtn').addEventListener('click', handleLogout);
    
    // Season filter
    document.getElementById('seasonSelect').addEventListener('change', loadMatches);
    
    // Score form
    document.getElementById('scoreForm').addEventListener('submit', handleScoreSubmit);
}

// Authentication
async function initializeAuth() {
    try {
        const { data: { user } } = await supabase.auth.getUser();
        
        if (user) {
            await loadUserData(user.id);
            if (currentUser && currentUser.role === 'contact_person') {
                showDashboard();
            } else {
                showLoginModal('Sie haben keine Berechtigung für diese Seite.');
            }
        } else {
            showLoginModal();
        }
    } catch (error) {
        console.error('Auth error:', error);
        showLoginModal();
    }
}

async function loadUserData(userId) {
    try {
        const { data, error } = await supabase
            .from('user_profiles')
            .select(`
                *,
                team:teams(*)
            `)
            .eq('id', userId)
            .single();
        
        if (error) throw error;
        
        currentUser = data;
        userTeam = data.team;
        
        // Update UI
        document.getElementById('userName').textContent = data.name;
        document.getElementById('userTeam').textContent = userTeam ? userTeam.name : 'Kein Team';
        
        // Load seasons
        await loadSeasons();
        
    } catch (error) {
        console.error('Error loading user data:', error);
        showError('Fehler beim Laden der Benutzerdaten');
    }
}

async function handleLogin(e) {
    e.preventDefault();
    
    const email = document.getElementById('email').value;
    const password = document.getElementById('password').value;
    
    try {
        const { data, error } = await supabase.auth.signInWithPassword({
            email: email,
            password: password
        });
        
        if (error) throw error;
        
        await loadUserData(data.user.id);
        
        if (currentUser && currentUser.role === 'contact_person') {
            showDashboard();
        } else {
            throw new Error('Sie haben keine Berechtigung für diese Seite.');
        }
        
    } catch (error) {
        console.error('Login error:', error);
        showError(error.message || 'Anmeldung fehlgeschlagen');
    }
}

async function handleLogout() {
    try {
        await supabase.auth.signOut();
        currentUser = null;
        userTeam = null;
        showLoginModal();
    } catch (error) {
        console.error('Logout error:', error);
    }
}

function showLoginModal(message = '') {
    document.getElementById('loginModal').style.display = 'block';
    document.getElementById('contactDashboard').style.display = 'none';
    
    if (message) {
        showError(message);
    }
}

function showDashboard() {
    document.getElementById('loginModal').style.display = 'none';
    document.getElementById('contactDashboard').style.display = 'block';
}

// Season Management
async function loadSeasons() {
    try {
        const { data, error } = await supabase
            .from('seasons')
            .select('*')
            .order('year', { ascending: false });
        
        if (error) throw error;
        
        const select = document.getElementById('seasonSelect');
        select.innerHTML = '<option value="">Saison wählen</option>';
        
        data.forEach(season => {
            const option = document.createElement('option');
            option.value = season.id;
            option.textContent = season.name;
            if (season.status === 'active') {
                option.selected = true;
            }
            select.appendChild(option);
        });
        
        // Load matches for active season
        if (data.find(s => s.status === 'active')) {
            await loadMatches();
        }
        
    } catch (error) {
        console.error('Error loading seasons:', error);
        showError('Fehler beim Laden der Saisons');
    }
}

// Match Management
async function loadMatches() {
    const seasonId = document.getElementById('seasonSelect').value;
    const container = document.getElementById('matchesContainer');
    
    if (!seasonId || !userTeam) {
        container.innerHTML = '<div class="empty-state"><h3>Keine Saison ausgewählt oder kein Team zugeordnet</h3></div>';
        return;
    }
    
    // Show loading state
    container.innerHTML = '<div class="loading-state"><div class="loading-spinner"></div><p>Spiele werden geladen...</p></div>';
    
    try {
        const { data, error } = await supabase
            .from('matches')
            .select(`
                *,
                home_team:teams!matches_home_team_id_fkey(id, name),
                away_team:teams!matches_away_team_id_fkey(id, name)
            `)
            .eq('season_id', seasonId)
            .or(`home_team_id.eq.${userTeam.id},away_team_id.eq.${userTeam.id}`)
            .order('matchday')
            .order('match_date');
        
        if (error) throw error;
        
        currentMatches = data;
        renderMatches(data);
        
    } catch (error) {
        console.error('Error loading matches:', error);
        showError('Fehler beim Laden der Spiele');
        container.innerHTML = '<div class="empty-state"><h3>Fehler beim Laden der Spiele</h3></div>';
    }
}

function renderMatches(matches) {
    const container = document.getElementById('matchesContainer');
    
    if (matches.length === 0) {
        container.innerHTML = '<div class="empty-state"><h3>Keine Spiele gefunden</h3><p>Für die ausgewählte Saison wurden keine Spiele gefunden.</p></div>';
        return;
    }
    
    container.innerHTML = '';
    
    matches.forEach(match => {
        const matchCard = createMatchCard(match);
        container.appendChild(matchCard);
    });
}

function createMatchCard(match) {
    const card = document.createElement('div');
    card.className = 'match-card';
    
    // Determine match status
    const isCompleted = match.home_score !== null && match.away_score !== null;
    const isUserTeamMatch = match.home_team.id === userTeam.id || match.away_team.id === userTeam.id;
    
    if (isCompleted) {
        card.classList.add('completed');
    } else {
        card.classList.add('pending');
    }
    
    // Format date
    const matchDate = new Date(match.match_date).toLocaleDateString('de-DE', {
        weekday: 'short',
        year: 'numeric',
        month: 'short',
        day: 'numeric'
    });
    
    card.innerHTML = `
        <div class="match-header">
            <div class="match-teams">
                <span class="team-name ${match.home_team.id === userTeam.id ? 'user-team' : ''}">${match.home_team.name}</span>
                <span class="vs">vs</span>
                <span class="team-name ${match.away_team.id === userTeam.id ? 'user-team' : ''}">${match.away_team.name}</span>
            </div>
            <div class="match-status ${isCompleted ? 'completed' : 'scheduled'}">
                ${isCompleted ? 'Abgeschlossen' : 'Ausstehend'}
            </div>
        </div>
        <div class="match-details">
            <div class="match-info">
                <div class="match-date">${matchDate}</div>
                <div>Spieltag ${match.matchday}</div>
                ${isCompleted ? `<div class="match-score">Endstand: ${match.home_score} : ${match.away_score}</div>` : ''}
            </div>
            <div class="match-actions">
                ${!isCompleted ? `
                    <button class="btn-submit-score" onclick="openScoreModal('${match.id}')">
                        Spielstand übermitteln
                    </button>
                ` : ''}
            </div>
        </div>
    `;
    
    return card;
}

// Score Submission
function openScoreModal(matchId) {
    const match = currentMatches.find(m => m.id === matchId);
    if (!match) return;
    
    const modal = document.getElementById('scoreModal');
    const matchDetails = document.getElementById('matchDetails');
    
    // Set match ID
    document.getElementById('matchId').value = matchId;
    
    // Format match date
    const matchDate = new Date(match.match_date).toLocaleDateString('de-DE', {
        weekday: 'long',
        year: 'numeric',
        month: 'long',
        day: 'numeric'
    });
    
    // Update match details
    matchDetails.innerHTML = `
        <h3>${match.home_team.name} vs ${match.away_team.name}</h3>
        <p><strong>Datum:</strong> ${matchDate}</p>
        <p><strong>Spieltag:</strong> ${match.matchday}</p>
    `;
    
    // Update labels
    document.getElementById('homeTeamLabel').textContent = match.home_team.name;
    document.getElementById('awayTeamLabel').textContent = match.away_team.name;
    
    // Clear form
    document.getElementById('scoreForm').reset();
    document.getElementById('matchId').value = matchId;
    
    modal.style.display = 'block';
}

async function handleScoreSubmit(e) {
    e.preventDefault();
    
    const matchId = document.getElementById('matchId').value;
    const homeScore = parseInt(document.getElementById('homeScore').value);
    const awayScore = parseInt(document.getElementById('awayScore').value);
    const notes = document.getElementById('matchNotes').value;
    
    if (homeScore < 0 || awayScore < 0) {
        showError('Spielstand darf nicht negativ sein');
        return;
    }
    
    try {
        // Update match with score
        const { error } = await supabase
            .from('matches')
            .update({
                home_score: homeScore,
                away_score: awayScore,
                notes: notes,
                score_submitted_by: currentUser.id,
                score_submitted_at: new Date().toISOString()
            })
            .eq('id', matchId);
        
        if (error) throw error;
        
        showSuccess('Spielstand erfolgreich übermittelt');
        closeModal('scoreModal');
        
        // Reload matches
        await loadMatches();
        
    } catch (error) {
        console.error('Error submitting score:', error);
        showError('Fehler beim Übermitteln des Spielstands');
    }
}

// Utility Functions
function closeModal(modalId) {
    document.getElementById(modalId).style.display = 'none';
}

function showError(message) {
    showAlert(message, 'error');
}

function showSuccess(message) {
    showAlert(message, 'success');
}

function showAlert(message, type = 'info') {
    const alertContainer = document.getElementById('alert-container');
    const alert = document.createElement('div');
    alert.className = `alert ${type}`;
    alert.innerHTML = `
        <div class="alert-title">${type === 'error' ? 'Fehler' : type === 'success' ? 'Erfolg' : 'Info'}</div>
        <div class="alert-message">${message}</div>
    `;
    
    alertContainer.appendChild(alert);
    
    // Show alert
    setTimeout(() => {
        alert.classList.add('show');
    }, 100);
    
    // Remove alert after 5 seconds
    setTimeout(() => {
        alert.classList.remove('show');
        setTimeout(() => {
            alertContainer.removeChild(alert);
        }, 300);
    }, 5000);
}

// Listen for auth changes
supabase.auth.onAuthStateChange((event, session) => {
    if (event === 'SIGNED_OUT') {
        currentUser = null;
        userTeam = null;
        showLoginModal();
    }
});
