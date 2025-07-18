// Enhanced Login JavaScript with Role-based Dashboards
let currentUser = null;
let userTeam = null;
let currentMatches = [];

document.addEventListener('DOMContentLoaded', function() {
    initializeAuth();
    setupEventListeners();
});

function setupEventListeners() {
    // Login form
    const loginForm = document.getElementById('login-form');
    if (loginForm) {
        loginForm.addEventListener('submit', handleLogin);
    }
    
    // Logout button
    const logoutBtn = document.getElementById('logoutBtn');
    if (logoutBtn) {
        logoutBtn.addEventListener('click', handleLogout);
    }
    
    // Season filter
    const seasonSelect = document.getElementById('contactSeasonSelect');
    if (seasonSelect) {
        seasonSelect.addEventListener('change', loadContactMatches);
    }
    
    // Score form
    const scoreForm = document.getElementById('scoreForm');
    if (scoreForm) {
        scoreForm.addEventListener('submit', handleScoreSubmit);
    }
}

// Authentication
async function initializeAuth() {
    try {
        const { data: { user } } = await supabase.auth.getUser();
        
        if (user) {
            await loadUserData(user.id);
            showDashboard();
        } else {
            showLogin();
        }
    } catch (error) {
        console.error('Auth error:', error);
        showLogin();
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
        document.getElementById('userDisplayName').textContent = data.name || data.email;
        
        const roleDisplay = document.getElementById('userRoleDisplay');
        const roleText = getRoleDisplayName(data.role);
        roleDisplay.textContent = roleText;
        roleDisplay.className = `role-badge ${data.role}`;
        
        if (userTeam && data.role === 'contact_person') {
            document.getElementById('contactTeamName').textContent = userTeam.name;
            await loadSeasons();
        }
        
    } catch (error) {
        console.error('Error loading user data:', error);
        showAlert('Fehler beim Laden der Benutzerdaten', 'error');
    }
}

async function handleLogin(e) {
    e.preventDefault();
    
    const email = document.getElementById('login-email').value;
    const password = document.getElementById('login-password').value;
    
    try {
        showLoading(true);
        
        const { data, error } = await supabase.auth.signInWithPassword({
            email: email,
            password: password
        });
        
        if (error) throw error;
        
        await loadUserData(data.user.id);
        showDashboard();
        
    } catch (error) {
        console.error('Login error:', error);
        showAlert('Anmeldung fehlgeschlagen: ' + error.message, 'error');
    } finally {
        showLoading(false);
    }
}

async function handleLogout() {
    try {
        await supabase.auth.signOut();
        currentUser = null;
        userTeam = null;
        showLogin();
    } catch (error) {
        console.error('Logout error:', error);
    }
}

function showLogin() {
    document.getElementById('loginContainer').style.display = 'block';
    document.getElementById('userDashboard').style.display = 'none';
}

function showDashboard() {
    document.getElementById('loginContainer').style.display = 'none';
    document.getElementById('userDashboard').style.display = 'block';
    
    // Show appropriate section based on role
    const adminSection = document.getElementById('adminSection');
    const contactSection = document.getElementById('contactSection');
    const userSection = document.getElementById('userSection');
    
    // Hide all sections first
    adminSection.style.display = 'none';
    contactSection.style.display = 'none';
    userSection.style.display = 'none';
    
    // Show appropriate section
    switch (currentUser.role) {
        case 'admin':
            adminSection.style.display = 'block';
            break;
        case 'contact_person':
            contactSection.style.display = 'block';
            break;
        default:
            userSection.style.display = 'block';
    }
}

function getRoleDisplayName(role) {
    switch (role) {
        case 'admin': return 'Administrator';
        case 'contact_person': return 'Ansprechpartner';
        case 'user': return 'Benutzer';
        default: return role;
    }
}

// Season Management for Contact Persons
async function loadSeasons() {
    try {
        const { data, error } = await supabase
            .from('seasons')
            .select('*')
            .order('year', { ascending: false });
        
        if (error) throw error;
        
        const select = document.getElementById('contactSeasonSelect');
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
            await loadContactMatches();
        }
        
    } catch (error) {
        console.error('Error loading seasons:', error);
        showAlert('Fehler beim Laden der Saisons', 'error');
    }
}

// Match Management for Contact Persons
async function loadContactMatches() {
    const seasonId = document.getElementById('contactSeasonSelect').value;
    const container = document.getElementById('contactMatchesContainer');
    
    if (!seasonId || !userTeam) {
        container.innerHTML = '<div class="empty-state"><h3>Keine Saison ausgewählt oder kein Team zugeordnet</h3></div>';
        return;
    }
    
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
        renderContactMatches(data);
        
    } catch (error) {
        console.error('Error loading matches:', error);
        showAlert('Fehler beim Laden der Spiele', 'error');
        container.innerHTML = '<div class="empty-state"><h3>Fehler beim Laden der Spiele</h3></div>';
    }
}

function renderContactMatches(matches) {
    const container = document.getElementById('contactMatchesContainer');
    
    if (matches.length === 0) {
        container.innerHTML = '<div class="empty-state"><h3>Keine Spiele gefunden</h3><p>Für die ausgewählte Saison wurden keine Spiele gefunden.</p></div>';
        return;
    }
    
    container.innerHTML = '';
    
    matches.forEach(match => {
        const matchCard = createContactMatchCard(match);
        container.appendChild(matchCard);
    });
}

function createContactMatchCard(match) {
    const card = document.createElement('div');
    card.className = 'match-card';
    
    // Determine match status
    const isCompleted = match.home_score !== null && match.away_score !== null;
    
    if (isCompleted) {
        card.classList.add('completed');
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
        <h4>${match.home_team.name} vs ${match.away_team.name}</h4>
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
        showAlert('Spielstand darf nicht negativ sein', 'error');
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
        
        showAlert('Spielstand erfolgreich übermittelt', 'success');
        closeScoreModal();
        
        // Reload matches
        await loadContactMatches();
        
    } catch (error) {
        console.error('Error submitting score:', error);
        showAlert('Fehler beim Übermitteln des Spielstands', 'error');
    }
}

function closeScoreModal() {
    document.getElementById('scoreModal').style.display = 'none';
}

// Utility Functions
function showLoading(show) {
    const overlay = document.getElementById('loading-overlay');
    if (show) {
        overlay.classList.add('active');
    } else {
        overlay.classList.remove('active');
    }
}

function showAlert(message, type) {
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
            if (alertContainer.contains(alert)) {
                alertContainer.removeChild(alert);
            }
        }, 300);
    }, 5000);
}

// Listen for auth changes
supabase.auth.onAuthStateChange((event, session) => {
    if (event === 'SIGNED_OUT') {
        currentUser = null;
        userTeam = null;
        showLogin();
    }
});
