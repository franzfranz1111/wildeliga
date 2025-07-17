// Login System for Wilde Liga Bremen
class LoginSystem {
    constructor() {
        this.supabase = window.supabase.createClient(CONFIG.supabaseUrl, CONFIG.supabaseKey);
        this.currentUser = null;
        this.initializeEventListeners();
        this.checkAuthStatus();
    }

    initializeEventListeners() {
        // Login form
        document.getElementById('login-form').addEventListener('submit', (e) => {
            e.preventDefault();
            this.handleLogin();
        });

        // Register form
        document.getElementById('register-form').addEventListener('submit', (e) => {
            e.preventDefault();
            this.handleRegister();
        });

        // Check URL parameters for redirect
        const urlParams = new URLSearchParams(window.location.search);
        const redirectTo = urlParams.get('redirect');
        if (redirectTo) {
            localStorage.setItem('loginRedirect', redirectTo);
        }
    }

    async checkAuthStatus() {
        try {
            const { data: { user } } = await this.supabase.auth.getUser();
            if (user) {
                this.currentUser = user;
                await this.redirectAfterLogin();
            }
        } catch (error) {
            console.error('Auth check error:', error);
        }
    }

    async handleLogin() {
        const email = document.getElementById('login-email').value;
        const password = document.getElementById('login-password').value;

        if (!email || !password) {
            this.showAlert('Fehler', 'Bitte alle Felder ausfüllen.', 'error');
            return;
        }

        this.showLoading(true);

        try {
            const { data, error } = await this.supabase.auth.signInWithPassword({
                email: email,
                password: password
            });

            if (error) {
                throw error;
            }

            this.currentUser = data.user;
            this.showAlert('Erfolgreich', 'Erfolgreich angemeldet!', 'success');
            
            // Redirect after short delay
            setTimeout(() => {
                this.redirectAfterLogin();
            }, 1000);

        } catch (error) {
            console.error('Login error:', error);
            let errorMessage = 'Anmeldung fehlgeschlagen.';
            
            if (error.message === 'Invalid login credentials') {
                errorMessage = 'E-Mail oder Passwort ist falsch.';
            } else if (error.message === 'Email not confirmed') {
                errorMessage = 'Bitte bestätige deine E-Mail-Adresse.';
            }
            
            this.showAlert('Fehler', errorMessage, 'error');
        } finally {
            this.showLoading(false);
        }
    }

    async handleRegister() {
        const name = document.getElementById('register-name').value;
        const email = document.getElementById('register-email').value;
        const password = document.getElementById('register-password').value;
        const passwordConfirm = document.getElementById('register-password-confirm').value;

        if (!name || !email || !password || !passwordConfirm) {
            this.showAlert('Fehler', 'Bitte alle Felder ausfüllen.', 'error');
            return;
        }

        if (password !== passwordConfirm) {
            this.showAlert('Fehler', 'Passwörter stimmen nicht überein.', 'error');
            return;
        }

        if (password.length < 6) {
            this.showAlert('Fehler', 'Passwort muss mindestens 6 Zeichen lang sein.', 'error');
            return;
        }

        this.showLoading(true);

        try {
            const { data, error } = await this.supabase.auth.signUp({
                email: email,
                password: password,
                options: {
                    data: {
                        name: name
                    }
                }
            });

            if (error) {
                throw error;
            }

            this.showAlert('Erfolgreich', 'Registrierung erfolgreich! Bitte bestätige deine E-Mail-Adresse.', 'success');
            
            // Switch to login tab
            setTimeout(() => {
                this.showTab('login');
            }, 2000);

        } catch (error) {
            console.error('Registration error:', error);
            let errorMessage = 'Registrierung fehlgeschlagen.';
            
            if (error.message === 'User already registered') {
                errorMessage = 'E-Mail-Adresse ist bereits registriert.';
            } else if (error.message.includes('password')) {
                errorMessage = 'Passwort ist zu schwach.';
            }
            
            this.showAlert('Fehler', errorMessage, 'error');
        } finally {
            this.showLoading(false);
        }
    }

    async redirectAfterLogin() {
        try {
            // Get user profile to determine role
            const { data: profile, error } = await this.supabase
                .from('user_profiles')
                .select('role, team_id')
                .eq('id', this.currentUser.id)
                .single();

            if (error) {
                console.error('Profile fetch error:', error);
                // Fallback to admin page
                window.location.href = 'admin.html';
                return;
            }

            // Check for saved redirect
            const savedRedirect = localStorage.getItem('loginRedirect');
            if (savedRedirect) {
                localStorage.removeItem('loginRedirect');
                window.location.href = savedRedirect;
                return;
            }

            // Redirect based on role
            if (profile.role === 'admin') {
                window.location.href = 'admin.html';
            } else if (profile.role === 'team_captain') {
                window.location.href = 'team-captain.html';
            } else {
                window.location.href = 'index.html';
            }

        } catch (error) {
            console.error('Redirect error:', error);
            window.location.href = 'admin.html';
        }
    }

    showTab(tabName) {
        // Hide all tabs
        const tabs = document.querySelectorAll('.tab-content');
        tabs.forEach(tab => tab.classList.remove('active'));

        // Hide all tab buttons
        const buttons = document.querySelectorAll('.tab-button');
        buttons.forEach(btn => btn.classList.remove('active'));

        // Show selected tab
        document.getElementById(tabName + '-tab').classList.add('active');
        event.target.classList.add('active');
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
}

// Global tab switching function
function showTab(tabName) {
    // Hide all tabs
    const tabs = document.querySelectorAll('.tab-content');
    tabs.forEach(tab => tab.classList.remove('active'));

    // Hide all tab buttons
    const buttons = document.querySelectorAll('.tab-button');
    buttons.forEach(btn => btn.classList.remove('active'));

    // Show selected tab
    document.getElementById(tabName + '-tab').classList.add('active');
    event.target.classList.add('active');
}

// Initialize login system when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    new LoginSystem();
});
