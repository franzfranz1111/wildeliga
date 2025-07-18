// Admin Interface JavaScript

let currentUser = null;
let teams = [];

let users = [];

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
    document.getElementById('addSeasonBtn').addEventListener('click', () => openSeasonModal());
    document.getElementById('addTeamBtn').addEventListener('click', () => openTeamModal());
    document.getElementById('addContactBtn').addEventListener('click', () => openContactModal());
    document.getElementById('addMatchBtn').addEventListener('click', () => openMatchModal());
    document.getElementById('addUserBtn').addEventListener('click', () => openUserModal());
    
    // Forms
    document.getElementById('seasonForm').addEventListener('submit', handleSeasonSubmit);
    document.getElementById('teamForm').addEventListener('submit', handleTeamSubmit);
    document.getElementById('contactForm').addEventListener('submit', handleContactSubmit);
    document.getElementById('matchForm').addEventListener('submit', handleMatchSubmit);
    document.getElementById('userForm').addEventListener('submit', handleUserSubmit);
    
    // Filter
    document.getElementById('contactTeamFilter').addEventListener('change', filterContacts);
    document.getElementById('userRoleFilter').addEventListener('change', filterUsers);
    
    // Role selection handler
    document.getElementById('userRole').addEventListener('change', handleRoleChange);
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
    
    // Erfolgreiche Abmeldung anzeigen
    showAlert('Erfolgreich', 'Erfolgreich abgemeldet!', 'success');
    
    // Weiterleitung zur Startseite nach kurzer Verzögerung
    setTimeout(() => {
        window.location.href = 'index.html';
    }, 1500);
}

// Alert System
function showAlert(title, message, type = 'info') {
    const container = document.getElementById('alert-container');
    const alert = document.createElement('div');
    alert.className = `alert ${type}`;
    
    alert.innerHTML = `
        <div class="alert-title">${title}</div>
        <div class="alert-message">${message}</div>
    `;
    
    container.appendChild(alert);
    
    // Trigger animation
    setTimeout(() => {
        alert.classList.add('show');
    }, 100);
    
    // Remove after 5 seconds
    setTimeout(() => {
        alert.classList.remove('show');
        setTimeout(() => {
            if (alert.parentNode) {
                alert.parentNode.removeChild(alert);
            }
        }, 300);
    }, 5000);
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
        case 'contacts':
            loadContacts();
            break;
        case 'matches':
            loadMatches();
            break;
        case 'users':
            loadUsers();
            break;
        case 'achievements':
            loadAchievements();
            break;
    }
}

// Load initial data
async function loadInitialData() {
    await loadSeasons();
    await loadTeams();
    await loadTeamOptions();
}

// Season Management
async function loadSeasons() {
    try {
        const seasons = await WildeLigaAPI.getSeasons();
        const currentSeason = await WildeLigaAPI.getCurrentSeason();
        
        // Update current season display
        const currentSeasonDisplay = document.getElementById('current-season-display');
        if (currentSeason) {
            currentSeasonDisplay.innerHTML = `
                <strong>${currentSeason.name}</strong> (${currentSeason.year})
                <span class="season-status ${currentSeason.status}">${currentSeason.status}</span>
            `;
        } else {
            currentSeasonDisplay.innerHTML = '<span class="no-season">Keine aktive Saison</span>';
        }
        
        // Load seasons grid
        const seasonsGrid = document.getElementById('seasonsGrid');
        seasonsGrid.innerHTML = '';
        
        seasons.forEach(season => {
            const seasonCard = document.createElement('div');
            seasonCard.className = 'season-card';
            seasonCard.innerHTML = `
                <div class="season-header">
                    <h3>${season.name}</h3>
                    <span class="season-status ${season.status}">${season.status}</span>
                </div>
                <div class="season-info">
                    <p><strong>Jahr:</strong> ${season.year}</p>
                    <p><strong>Start:</strong> ${season.start_date ? new Date(season.start_date).toLocaleDateString() : 'Nicht gesetzt'}</p>
                    <p><strong>Ende:</strong> ${season.end_date ? new Date(season.end_date).toLocaleDateString() : 'Nicht gesetzt'}</p>
                </div>
                <div class="season-actions">
                    <button class="btn-small" onclick="viewSeasonTeams('${season.id}')">Teams anzeigen</button>
                    ${season.status === 'active' ? '' : '<button class="btn-small btn-danger" onclick="deleteSeason(\'' + season.id + '\')">Löschen</button>'}
                </div>
            `;
            seasonsGrid.appendChild(seasonCard);
        });
    } catch (error) {
        showErrorMessage('Fehler beim Laden der Saisons: ' + error.message);
    }
}

function openSeasonModal() {
    const modal = document.getElementById('seasonModal');
    const form = document.getElementById('seasonForm');
    
    // Set default values
    const currentYear = new Date().getFullYear();
    document.getElementById('seasonYear').value = currentYear + 1;
    document.getElementById('seasonName').value = `Saison ${currentYear + 1}/${(currentYear + 2).toString().substr(2)}`;
    
    // Set default dates
    const startDate = new Date(currentYear + 1, 7, 1); // 1. August
    const endDate = new Date(currentYear + 2, 4, 31); // 31. Mai
    document.getElementById('seasonStartDate').value = startDate.toISOString().split('T')[0];
    document.getElementById('seasonEndDate').value = endDate.toISOString().split('T')[0];
    
    // Load teams for selection
    loadTeamSelection();
    
    modal.style.display = 'block';
}

async function loadTeamSelection() {
    try {
        const teams = await WildeLigaAPI.getTeams();
        const teamSelection = document.getElementById('teamSelection');
        teamSelection.innerHTML = '';
        
        teams.forEach(team => {
            const teamCheckbox = document.createElement('div');
            teamCheckbox.className = 'team-checkbox';
            teamCheckbox.innerHTML = `
                <label for="team-${team.id}">${team.name}</label>
                <input type="checkbox" value="${team.id}" id="team-${team.id}" checked>
            `;
            
            teamSelection.appendChild(teamCheckbox);
        });
    } catch (error) {
        showErrorMessage('Fehler beim Laden der Teams: ' + error.message);
    }
}

// Select all teams function
function selectAllTeams() {
    const checkboxes = document.querySelectorAll('#teamSelection input[type="checkbox"]');
    checkboxes.forEach(checkbox => {
        checkbox.checked = true;
    });
}

// Deselect all teams function
function deselectAllTeams() {
    const checkboxes = document.querySelectorAll('#teamSelection input[type="checkbox"]');
    checkboxes.forEach(checkbox => {
        checkbox.checked = false;
    });
}

async function handleSeasonSubmit(event) {
    event.preventDefault();
    
    const formData = new FormData(event.target);
    const selectedTeams = Array.from(document.querySelectorAll('#teamSelection input:checked')).map(cb => cb.value);
    
    if (selectedTeams.length === 0) {
        showErrorMessage('Bitte wählen Sie mindestens ein Team aus.');
        return;
    }
    
    const seasonData = {
        name: document.getElementById('seasonName').value,
        year: parseInt(document.getElementById('seasonYear').value),
        start_date: document.getElementById('seasonStartDate').value,
        end_date: document.getElementById('seasonEndDate').value
    };
    
    // Bestimme ob Hin- und Rückrunde
    const doubleRound = document.getElementById('doubleRound').checked;
    
    try {
        await WildeLigaAPI.createSeason(seasonData, selectedTeams, doubleRound);
        showSuccessMessage('Saison erfolgreich erstellt mit automatischem Spielplan');
        closeModal('seasonModal');
        loadSeasons();
    } catch (error) {
        showErrorMessage('Fehler beim Erstellen der Saison: ' + error.message);
    }
}

async function viewSeasonTeams(seasonId) {
    try {
        const seasonTeams = await WildeLigaAPI.getSeasonTeams(seasonId);
        const teamNames = seasonTeams.map(st => st.team.name).join(', ');
        alert(`Teams in dieser Saison:\n\n${teamNames}`);
    } catch (error) {
        showErrorMessage('Fehler beim Laden der Teams: ' + error.message);
    }
}

// Team Management
async function loadTeams() {
    try {
        const { data, error } = await supabase
            .from('teams')
            .select('*')
            .order('name');
        
        if (error) {
            console.error('Error loading teams:', error);
            showErrorMessage('Fehler beim Laden der Teams: ' + error.message);
            return;
        }
        
        teams = data || [];
        console.log('Loaded teams:', teams);
        renderTeams();
    } catch (error) {
        console.error('Error loading teams:', error);
        showErrorMessage('Fehler beim Laden der Teams');
    }
}

function renderTeams() {
    const container = document.getElementById('teamsGrid');
    if (!container) {
        console.error('teamsGrid container not found');
        return;
    }
    
    container.innerHTML = '';
    
    if (teams.length === 0) {
        container.innerHTML = '<p style="text-align: center; color: #666; margin: 20px;">Keine Teams gefunden.</p>';
        return;
    }
    
    teams.forEach(team => {
        const teamCard = document.createElement('div');
        teamCard.className = 'team-admin-card';
        teamCard.innerHTML = `
            <h3>${team.name}</h3>
            <p><strong>Kürzel:</strong> ${team.short_name || '-'}</p>
            <p><strong>Trainer:</strong> ${team.coach || '-'}</p>
            <p><strong>Stadion:</strong> ${team.stadium || '-'}</p>
            <p><strong>E-Mail:</strong> ${team.email || '-'}</p>
            <div class="team-admin-actions">
                <button class="btn-edit" onclick="editTeam('${team.id}')">Bearbeiten</button>
                <button class="btn-danger" onclick="deleteTeam('${team.id}')">Löschen</button>
            </div>
        `;
        container.appendChild(teamCard);
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

// Contact Management
async function loadContacts() {
    try {
        const { data, error } = await supabase
            .from('user_profiles')
            .select(`
                *,
                team:teams(name)
            `)
            .eq('role', 'contact_person')
            .order('name');
        
        if (error) throw error;
        
        renderContacts(data);
        await loadTeamsForContactFilter();
    } catch (error) {
        console.error('Error loading contacts:', error);
        showErrorMessage('Fehler beim Laden der Ansprechpartner');
    }
}

async function loadTeamsForContactFilter() {
    try {
        const { data: teams, error } = await supabase
            .from('teams')
            .select('*')
            .order('name');
        
        if (error) throw error;
        
        const filter = document.getElementById('contactTeamFilter');
        filter.innerHTML = '<option value="all">Alle Teams</option>';
        
        teams.forEach(team => {
            const option = document.createElement('option');
            option.value = team.name;
            option.textContent = team.name;
            filter.appendChild(option);
        });
    } catch (error) {
        console.error('Error loading teams for filter:', error);
    }
}

function renderContacts(contacts) {
    const container = document.getElementById('contactsList');
    const filter = document.getElementById('contactTeamFilter').value;
    
    container.innerHTML = '';
    
    const filteredContacts = filter === 'all' 
        ? contacts 
        : contacts.filter(c => c.team?.name === filter);
    
    filteredContacts.forEach(contact => {
        const contactItem = `
            <div class="contact-item">
                <div class="contact-info">
                    <h4>${contact.name}</h4>
                    <p><strong>Team:</strong> ${contact.team?.name || 'Kein Team'}</p>
                    <p><strong>E-Mail:</strong> ${contact.email}</p>
                    <p><strong>Telefon:</strong> ${contact.phone || '-'}</p>
                </div>
                <div class="item-actions">
                    <button class="btn-edit" onclick="editContact('${contact.id}')">Bearbeiten</button>
                    <button class="btn-danger" onclick="deleteContact('${contact.id}')">Löschen</button>
                </div>
            </div>
        `;
        container.innerHTML += contactItem;
    });
}

function openContactModal(contactId = null) {
    const modal = document.getElementById('contactModal');
    const title = document.getElementById('contactModalTitle');
    const form = document.getElementById('contactForm');
    
    // Load teams for dropdown
    loadTeamsForContactModal();
    
    if (contactId) {
        // Load contact data
        loadContactData(contactId);
        title.textContent = 'Ansprechpartner bearbeiten';
    } else {
        title.textContent = 'Neuer Ansprechpartner';
        form.reset();
        document.getElementById('contactId').value = '';
    }
    
    modal.style.display = 'block';
}

async function loadTeamsForContactModal() {
    try {
        const { data: teams, error } = await supabase
            .from('teams')
            .select('*')
            .order('name');
        
        if (error) throw error;
        
        const select = document.getElementById('contactTeam');
        select.innerHTML = '<option value="">Team wählen</option>';
        
        teams.forEach(team => {
            const option = document.createElement('option');
            option.value = team.id;
            option.textContent = team.name;
            select.appendChild(option);
        });
    } catch (error) {
        console.error('Error loading teams:', error);
    }
}

async function loadContactData(contactId) {
    try {
        const { data, error } = await supabase
            .from('user_profiles')
            .select('*')
            .eq('id', contactId)
            .single();
        
        if (error) throw error;
        
        document.getElementById('contactId').value = data.id;
        document.getElementById('contactName').value = data.name;
        document.getElementById('contactEmail').value = data.email;
        document.getElementById('contactPhone').value = data.phone || '';
        document.getElementById('contactTeam').value = data.team_id || '';
    } catch (error) {
        console.error('Error loading contact data:', error);
    }
}

function editContact(contactId) {
    openContactModal(contactId);
}

async function deleteContact(contactId) {
    if (confirm('Ansprechpartner wirklich löschen?')) {
        try {
            const { error } = await supabase
                .from('user_profiles')
                .delete()
                .eq('id', contactId);
            
            if (error) throw error;
            
            await loadContacts();
            showSuccessMessage('Ansprechpartner erfolgreich gelöscht');
        } catch (error) {
            console.error('Error deleting contact:', error);
            showErrorMessage('Fehler beim Löschen des Ansprechpartners');
        }
    }
}

async function handleContactSubmit(e) {
    e.preventDefault();
    
    const contactData = {
        name: document.getElementById('contactName').value,
        email: document.getElementById('contactEmail').value,
        phone: document.getElementById('contactPhone').value || null,
        team_id: document.getElementById('contactTeam').value || null,
        role: 'contact_person'
    };
    
    const password = document.getElementById('contactPassword').value;
    const contactId = document.getElementById('contactId').value;
    
    try {
        if (contactId) {
            // Update existing contact
            const { error } = await supabase
                .from('user_profiles')
                .update(contactData)
                .eq('id', contactId);
            
            if (error) throw error;
            
            // Update password if provided
            if (password) {
                const { error: authError } = await supabase.auth.updateUser({
                    password: password
                });
                if (authError) throw authError;
            }
            
            showSuccessMessage('Ansprechpartner erfolgreich aktualisiert');
        } else {
            // Create new contact
            if (!password) {
                showErrorMessage('Passwort ist erforderlich für neue Ansprechpartner');
                return;
            }
            
            // Generate a temporary ID for the contact
            const tempId = crypto.randomUUID();
            contactData.id = tempId;
            contactData.temp_password = password; // Store temporarily for manual creation
            
            // Create user record first
            const { error } = await supabase
                .from('user_profiles')
                .insert([contactData]);
            
            if (error) throw error;
            
            showSuccessMessage('Ansprechpartner erfolgreich erstellt. Bitte erstellen Sie den Auth-Benutzer manuell über das Supabase Dashboard.');
            showInfoMessage(`E-Mail: ${contactData.email}, Passwort: ${password}, ID: ${tempId}`);
        }
        
        closeModal('contactModal');
        await loadContacts();
    } catch (error) {
        console.error('Error saving contact:', error);
        showErrorMessage('Fehler beim Speichern des Ansprechpartners');
    }
}

function filterContacts() {
    loadContacts();
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

function closeModal(modalId) {
    document.getElementById(modalId).style.display = 'none';
}

function showSuccessMessage(message) {
    showAlert('Erfolgreich', message, 'success');
}

function showErrorMessage(message) {
    showAlert('Fehler', message, 'error');
}

function showInfoMessage(message) {
    showAlert('Info', message, 'info');
}

// Load achievements (placeholder)
async function loadAchievements() {
    // Implementation for achievements management
    console.log('Loading achievements...');
}

// User Management
async function loadUsers() {
    try {
        const { data, error } = await supabase
            .from('user_profiles')
            .select(`
                *,
                team:team_id(name)
            `)
            .order('created_at', { ascending: false });
        
        if (error) throw error;
        
        users = data || [];
        renderUsers();
    } catch (error) {
        console.error('Error loading users:', error);
        showErrorMessage('Fehler beim Laden der Benutzer');
    }
}

function renderUsers() {
    const tbody = document.getElementById('usersTableBody');
    tbody.innerHTML = '';
    
    const roleFilter = document.getElementById('userRoleFilter').value;
    let filteredUsers = users;
    
    if (roleFilter !== 'all') {
        filteredUsers = users.filter(user => user.role === roleFilter);
    }
    
    if (filteredUsers.length === 0) {
        tbody.innerHTML = '<tr><td colspan="6" style="text-align: center;">Keine Benutzer gefunden</td></tr>';
        return;
    }
    
    filteredUsers.forEach(user => {
        const row = document.createElement('tr');
        row.innerHTML = `
            <td>${user.name || '-'}</td>
            <td>${user.email}</td>
            <td><span class="role-badge ${user.role}">${getRoleDisplayName(user.role)}</span></td>
            <td>${user.team?.name || '-'}</td>
            <td>${new Date(user.created_at).toLocaleDateString('de-DE')}</td>
            <td>
                <div class="user-actions">
                    <button class="btn-small btn-edit" onclick="editUser('${user.id}')">Bearbeiten</button>
                    <button class="btn-small btn-delete" onclick="deleteUser('${user.id}')">Löschen</button>
                </div>
            </td>
        `;
        tbody.appendChild(row);
    });
}

function getRoleDisplayName(role) {
    switch (role) {
        case 'admin': return 'Admin';
        case 'contact_person': return 'Ansprechpartner';
        case 'user': return 'Benutzer';
        default: return role;
    }
}

function openUserModal(userId = null) {
    const modal = document.getElementById('userModal');
    const title = document.getElementById('userModalTitle');
    const form = document.getElementById('userForm');
    
    if (userId) {
        const user = users.find(u => u.id === userId);
        title.textContent = 'Benutzer bearbeiten';
        
        // Fill form with user data
        document.getElementById('userId').value = user.id;
        document.getElementById('userName').value = user.name || '';
        document.getElementById('userEmail').value = user.email;
        document.getElementById('userPassword').value = '';
        document.getElementById('userRole').value = user.role;
        document.getElementById('userTeam').value = user.team_id || '';
        
        // Show/hide team selection
        handleRoleChange();
    } else {
        title.textContent = 'Neuer Benutzer';
        form.reset();
        document.getElementById('userId').value = '';
        document.getElementById('userRole').value = 'user';
        handleRoleChange();
    }
    
    modal.style.display = 'block';
}

function handleRoleChange() {
    const role = document.getElementById('userRole').value;
    const teamGroup = document.getElementById('teamSelectGroup');
    
    if (role === 'contact_person') {
        teamGroup.classList.add('show');
    } else {
        teamGroup.classList.remove('show');
        document.getElementById('userTeam').value = '';
    }
}

function editUser(userId) {
    openUserModal(userId);
}

async function deleteUser(userId) {
    if (!confirm('Benutzer wirklich löschen?')) return;
    
    try {
        // Delete from auth.users (will cascade to user_profiles)
        const { error } = await supabase.auth.admin.deleteUser(userId);
        
        if (error) throw error;
        
        await loadUsers();
        showSuccessMessage('Benutzer erfolgreich gelöscht');
    } catch (error) {
        console.error('Error deleting user:', error);
        showErrorMessage('Fehler beim Löschen des Benutzers');
    }
}

async function handleUserSubmit(e) {
    e.preventDefault();
    
    const userId = document.getElementById('userId').value;
    const isEdit = !!userId;
    
    const userData = {
        name: document.getElementById('userName').value,
        email: document.getElementById('userEmail').value,
        role: document.getElementById('userRole').value,
        team_id: document.getElementById('userTeam').value || null
    };
    
    const password = document.getElementById('userPassword').value;
    
    try {
        if (isEdit) {
            // Update existing user
            const { error: profileError } = await supabase
                .from('user_profiles')
                .update(userData)
                .eq('id', userId);
            
            if (profileError) throw profileError;
            
            // Update password if provided
            if (password) {
                const { error: authError } = await supabase.auth.admin.updateUserById(userId, {
                    password: password
                });
                
                if (authError) throw authError;
            }
        } else {
            // Create new user
            if (!password) {
                throw new Error('Passwort ist erforderlich für neue Benutzer');
            }
            
            const { data: authData, error: authError } = await supabase.auth.admin.createUser({
                email: userData.email,
                password: password,
                user_metadata: {
                    name: userData.name
                }
            });
            
            if (authError) throw authError;
            
            // Update profile with role and team
            const { error: profileError } = await supabase
                .from('user_profiles')
                .update({
                    role: userData.role,
                    team_id: userData.team_id,
                    name: userData.name
                })
                .eq('id', authData.user.id);
            
            if (profileError) throw profileError;
        }
        
        closeModal('userModal');
        await loadUsers();
        showSuccessMessage(isEdit ? 'Benutzer erfolgreich aktualisiert' : 'Benutzer erfolgreich erstellt');
    } catch (error) {
        console.error('Error saving user:', error);
        showErrorMessage('Fehler beim Speichern des Benutzers: ' + error.message);
    }
}

function filterUsers() {
    renderUsers();
}

// Update loadTeamOptions to include user team dropdown
async function loadTeamOptions() {
    const selects = ['playerTeam', 'playerTeamFilter', 'matchHomeTeam', 'matchAwayTeam', 'userTeam'];
    
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
window.editUser = editUser;
window.deleteUser = deleteUser;
window.closeModal = closeModal;
