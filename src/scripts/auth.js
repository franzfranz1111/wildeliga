// Authentication Helper Functions
// Wilde Liga Bremen - Auth System

// Check if user is authenticated
async function checkAuth() {
    try {
        const { data: { user } } = await supabase.auth.getUser();
        
        if (!user) {
            return null;
        }

        // Get user profile with role
        const { data: profile, error } = await supabase
            .from('user_profiles')
            .select('*')
            .eq('id', user.id)
            .single();

        if (error) {
            console.error('Error fetching user profile:', error);
            return null;
        }

        return {
            id: user.id,
            email: user.email,
            role: profile?.role || 'user',
            team_id: profile?.team_id || null,
            profile: profile
        };
    } catch (error) {
        console.error('Auth check failed:', error);
        return null;
    }
}

// Login function
async function login(email, password) {
    try {
        const { data, error } = await supabase.auth.signInWithPassword({
            email: email,
            password: password
        });

        if (error) {
            throw error;
        }

        return data;
    } catch (error) {
        console.error('Login failed:', error);
        throw error;
    }
}

// Logout function
async function logout() {
    try {
        const { error } = await supabase.auth.signOut();
        
        if (error) {
            throw error;
        }

        // Redirect to login page
        window.location.href = 'login.html';
    } catch (error) {
        console.error('Logout failed:', error);
        throw error;
    }
}

// Register function
async function register(email, password, userData = {}) {
    try {
        const { data, error } = await supabase.auth.signUp({
            email: email,
            password: password,
            options: {
                data: userData
            }
        });

        if (error) {
            throw error;
        }

        return data;
    } catch (error) {
        console.error('Registration failed:', error);
        throw error;
    }
}

// Check if user has specific role
function hasRole(user, role) {
    if (!user) return false;
    return user.role === role;
}

// Check if user is admin
function isAdmin(user) {
    return hasRole(user, 'admin');
}

// Check if user is team captain
function isTeamCaptain(user) {
    return hasRole(user, 'team_captain');
}

// Require authentication for page access
async function requireAuth(allowedRoles = []) {
    const user = await checkAuth();
    
    if (!user) {
        showAlert('Sie müssen sich anmelden, um auf diese Seite zuzugreifen.', 'error');
        setTimeout(() => {
            window.location.href = 'login.html';
        }, 2000);
        return null;
    }

    if (allowedRoles.length > 0 && !allowedRoles.includes(user.role)) {
        showAlert('Sie haben keine Berechtigung für diese Seite.', 'error');
        setTimeout(() => {
            window.location.href = 'index.html';
        }, 2000);
        return null;
    }

    return user;
}

// Show alert function
function showAlert(message, type = 'info') {
    // Create alert element
    const alertDiv = document.createElement('div');
    alertDiv.className = `alert alert-${type}`;
    alertDiv.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        z-index: 9999;
        padding: 15px 20px;
        border-radius: 5px;
        color: white;
        font-weight: 500;
        max-width: 400px;
        box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        transition: all 0.3s ease;
    `;

    // Set background color based on type
    const colors = {
        'success': '#28a745',
        'error': '#dc3545',
        'warning': '#ffc107',
        'info': '#17a2b8'
    };
    
    alertDiv.style.backgroundColor = colors[type] || colors.info;
    alertDiv.textContent = message;

    // Add to page
    document.body.appendChild(alertDiv);

    // Remove after 5 seconds
    setTimeout(() => {
        alertDiv.style.opacity = '0';
        alertDiv.style.transform = 'translateX(100%)';
        setTimeout(() => {
            if (alertDiv.parentNode) {
                alertDiv.parentNode.removeChild(alertDiv);
            }
        }, 300);
    }, 5000);
}

// Initialize auth state listener
function initAuthListener() {
    supabase.auth.onAuthStateChange((event, session) => {
        console.log('Auth state changed:', event, session);
        
        if (event === 'SIGNED_OUT') {
            // Clear any cached data
            localStorage.removeItem('userProfile');
        }
    });
}

// Initialize auth on page load
document.addEventListener('DOMContentLoaded', function() {
    initAuthListener();
});

// Export functions for global use
window.checkAuth = checkAuth;
window.login = login;
window.logout = logout;
window.register = register;
window.hasRole = hasRole;
window.isAdmin = isAdmin;
window.isTeamCaptain = isTeamCaptain;
window.requireAuth = requireAuth;
window.showAlert = showAlert;
