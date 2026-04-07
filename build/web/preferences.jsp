<%@ page isELIgnored="true"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
    import="com.hiper.inventory.dao.UserDAO, com.hiper.inventory.models.User"%>
<%
    if (session.getAttribute("username") == null) { response.sendRedirect("index.jsp"); return; }
    String username = (String) session.getAttribute("username");
    String userRole = (String) session.getAttribute("userRole");
    int userId = session.getAttribute("userId") != null ? (Integer) session.getAttribute("userId") : -1;

    // Handle POST - save profile
    String saved = "";
    String error = "";
    if ("POST".equals(request.getMethod())) {
        String action = request.getParameter("action");
        if ("profile".equals(action)) {
            UserDAO dao = new UserDAO();
            User u = dao.getUserById(userId);
            if (u != null) {
                String nombre = request.getParameter("nombre");
                String email = request.getParameter("email");
                String dept = request.getParameter("departamento");
                String tel = request.getParameter("telefono");
                if (nombre != null && !nombre.trim().isEmpty()) u.setNombre(nombre.trim());
                if (email != null && !email.trim().isEmpty()) u.setEmail(email.trim());
                u.setDepartamento(dept != null ? dept.trim() : "");
                u.setTelefono(tel != null ? tel.trim() : "");
                if (dao.updateUser(u)) {
                    session.setAttribute("userName", u.getNombre());
                    saved = "Perfil actualizado correctamente";
                } else { error = "Error actualizando perfil"; }
            }
        } else if ("password".equals(action)) {
            String newPwd = request.getParameter("newPassword");
            String confirm = request.getParameter("confirmPassword");
            if (newPwd == null || newPwd.length() < 6) { error = "La contraseña debe tener al menos 6 caracteres"; }
            else if (!newPwd.equals(confirm)) { error = "Las contraseñas no coinciden"; }
            else {
                UserDAO dao = new UserDAO();
                if (dao.changePassword(userId, newPwd)) { saved = "Contraseña actualizada correctamente"; }
                else { error = "Error actualizando contraseña"; }
            }
        }
    }

    // Load current user data
    UserDAO dao = new UserDAO();
    User currentUser = dao.getUserById(userId);
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Preferencias - HiperInventory</title>
    <link rel="stylesheet" href="css/styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .pref-layout { display:flex; min-height:100vh; }
        .pref-sidebar { width:220px; background:linear-gradient(135deg,#667eea,#764ba2); color:#fff; padding:0; flex-shrink:0; }
        .pref-sidebar-header { padding:24px 20px; border-bottom:1px solid rgba(255,255,255,0.15); font-weight:700; font-size:16px; }
        .pref-nav a { display:flex; align-items:center; gap:10px; padding:14px 20px; color:rgba(255,255,255,0.85); text-decoration:none; transition:all .2s; border-left:3px solid transparent; }
        .pref-nav a:hover, .pref-nav a.active { background:rgba(255,255,255,0.12); color:#fff; border-left-color:#4dd0e1; }
        .pref-nav hr { border:none; border-top:1px solid rgba(255,255,255,0.15); margin:10px 0; }
        .pref-main { flex:1; background:#f5f7fa; }
        .pref-topbar { background:#fff; padding:16px 30px; box-shadow:0 2px 8px rgba(0,0,0,.08); display:flex; align-items:center; justify-content:space-between; }
        .pref-content { padding:30px; max-width:800px; }
        .pref-section { background:#fff; border-radius:12px; padding:28px; margin-bottom:24px; box-shadow:0 2px 8px rgba(0,0,0,.07); }
        .pref-section h3 { font-size:17px; font-weight:700; color:#333; margin:0 0 20px; padding-bottom:14px; border-bottom:2px solid #f0f0f0; display:flex; align-items:center; gap:10px; }
        .pref-section h3 i { color:#667eea; }
        .pref-row { display:flex; justify-content:space-between; align-items:center; padding:14px 0; border-bottom:1px solid #f5f5f5; }
        .pref-row:last-child { border-bottom:none; padding-bottom:0; }
        .pref-label h6 { margin:0 0 3px; font-weight:600; color:#333; font-size:14px; }
        .pref-label small { color:#888; font-size:12px; }
        .theme-btn { padding:8px 18px; border:2px solid #667eea; border-radius:8px; cursor:pointer; font-weight:600; font-size:13px; transition:all .2s; background:#fff; color:#667eea; }
        .theme-btn.active, .theme-btn:hover { background:#667eea; color:#fff; }
        .lang-btn { padding:7px 14px; border:2px solid #e0e0e0; border-radius:6px; cursor:pointer; font-size:13px; font-weight:600; background:#fff; color:#555; transition:all .2s; }
        .lang-btn.active { border-color:#667eea; background:#667eea; color:#fff; }
        .lang-btn:hover { border-color:#667eea; color:#667eea; }
        .switch { position:relative; display:inline-block; width:46px; height:22px; }
        .switch input { opacity:0; width:0; height:0; }
        .slider { position:absolute; cursor:pointer; inset:0; background:#ccc; border-radius:22px; transition:.3s; }
        .slider:before { position:absolute; content:""; height:16px; width:16px; left:3px; bottom:3px; background:#fff; border-radius:50%; transition:.3s; }
        input:checked + .slider { background:#667eea; }
        input:checked + .slider:before { transform:translateX(24px); }
        .color-grid { display:grid; grid-template-columns:repeat(6,1fr); gap:10px; margin-top:12px; }
        .color-swatch { cursor:pointer; border-radius:8px; padding:10px 6px; text-align:center; border:2px solid #e0e0e0; transition:all .2s; }
        .color-swatch:hover, .color-swatch.active { border-color:#667eea; transform:translateY(-2px); box-shadow:0 4px 12px rgba(102,126,234,.3); }
        .color-dots { display:flex; gap:4px; justify-content:center; margin-bottom:6px; }
        .color-dot { width:18px; height:18px; border-radius:50%; }
        .color-swatch small { font-size:11px; color:#666; }
        .form-row { display:grid; grid-template-columns:1fr 1fr; gap:16px; }
        .form-group { margin-bottom:16px; }
        .form-group label { display:block; font-size:13px; font-weight:600; color:#555; margin-bottom:6px; }
        .form-group input { width:100%; padding:10px 14px; border:2px solid #e0e0e0; border-radius:8px; font-size:14px; transition:border-color .2s; }
        .form-group input:focus { outline:none; border-color:#667eea; }
        .btn-save { background:linear-gradient(135deg,#667eea,#764ba2); color:#fff; border:none; padding:10px 24px; border-radius:8px; font-weight:600; cursor:pointer; font-size:14px; }
        .btn-save:hover { opacity:.9; }
        .alert-success { background:#e8f5e9; color:#2e7d32; border-left:4px solid #4caf50; padding:12px 16px; border-radius:8px; margin-bottom:16px; }
        .alert-error { background:#ffebee; color:#c62828; border-left:4px solid #f44336; padding:12px 16px; border-radius:8px; margin-bottom:16px; }
        .avatar-big { width:72px; height:72px; border-radius:50%; background:linear-gradient(135deg,#667eea,#764ba2); color:#fff; display:flex; align-items:center; justify-content:center; font-size:28px; font-weight:700; margin-right:20px; flex-shrink:0; }
        .profile-header { display:flex; align-items:center; margin-bottom:24px; }
        .role-pill { display:inline-block; padding:3px 12px; border-radius:12px; font-size:11px; font-weight:700; background:#e3f2fd; color:#0d47a1; margin-top:4px; }
    </style>
</head>
<body>
<div class="pref-layout">
    <aside class="pref-sidebar">
        <div class="pref-sidebar-header"><i class="fas fa-cog"></i> Preferencias</div>
        <nav class="pref-nav">
            <a href="#perfil" class="active" onclick="showSection('perfil',this)"><i class="fas fa-user"></i> Perfil</a>
            <a href="#seguridad" onclick="showSection('seguridad',this)"><i class="fas fa-lock"></i> Seguridad</a>
            <a href="#tema" onclick="showSection('tema',this)"><i class="fas fa-palette"></i> Tema</a>
            <a href="#idioma" onclick="showSection('idioma',this)"><i class="fas fa-globe"></i> Idioma</a>
            <a href="#notificaciones" onclick="showSection('notificaciones',this)"><i class="fas fa-bell"></i> Notificaciones</a>
            <hr>
            <a href="inicio.jsp"><i class="fas fa-arrow-left"></i> Volver al Dashboard</a>
        </nav>
    </aside>

    <div class="pref-main">
        <div class="pref-topbar">
            <h2 style="margin:0;font-size:20px;font-weight:700;color:#333;">Preferencias de Usuario</h2>
            <div style="font-size:13px;color:#888;">Sesión: <strong><%= username %></strong> &nbsp;|&nbsp; Rol: <strong><%= userRole %></strong></div>
        </div>

        <div class="pref-content">
            <% if (!saved.isEmpty()) { %>
            <div class="alert-success"><i class="fas fa-check-circle"></i> <%= saved %></div>
            <% } %>
            <% if (!error.isEmpty()) { %>
            <div class="alert-error"><i class="fas fa-exclamation-circle"></i> <%= error %></div>
            <% } %>

            <!-- PERFIL -->
            <div class="pref-section" id="sec-perfil">
                <h3><i class="fas fa-user"></i> Mi Perfil</h3>
                <div class="profile-header">
                    <div class="avatar-big"><%= Character.toUpperCase(username.charAt(0)) %></div>
                    <div>
                        <div style="font-size:18px;font-weight:700;color:#333;"><%= currentUser != null ? currentUser.getNombre() : username %></div>
                        <div style="color:#888;font-size:13px;"><%= currentUser != null ? currentUser.getEmail() : "" %></div>
                        <span class="role-pill"><%= userRole %></span>
                    </div>
                </div>
                <form method="POST" action="preferences.jsp">
                    <input type="hidden" name="action" value="profile">
                    <div class="form-row">
                        <div class="form-group">
                            <label>Nombre *</label>
                            <input type="text" name="nombre" value="<%= currentUser != null ? currentUser.getNombre() : "" %>" required>
                        </div>
                        <div class="form-group">
                            <label>Email *</label>
                            <input type="email" name="email" value="<%= currentUser != null ? currentUser.getEmail() : "" %>" required>
                        </div>
                        <div class="form-group">
                            <label>Departamento</label>
                            <input type="text" name="departamento" value="<%= currentUser != null && currentUser.getDepartamento() != null ? currentUser.getDepartamento() : "" %>">
                        </div>
                        <div class="form-group">
                            <label>Teléfono</label>
                            <input type="text" name="telefono" value="<%= currentUser != null && currentUser.getTelefono() != null ? currentUser.getTelefono() : "" %>">
                        </div>
                    </div>
                    <button type="submit" class="btn-save"><i class="fas fa-save"></i> Guardar Perfil</button>
                </form>
            </div>

            <!-- SEGURIDAD -->
            <div class="pref-section" id="sec-seguridad" style="display:none;">
                <h3><i class="fas fa-lock"></i> Seguridad</h3>
                <form method="POST" action="preferences.jsp">
                    <input type="hidden" name="action" value="password">
                    <div class="form-group">
                        <label>Nueva Contraseña *</label>
                        <input type="password" name="newPassword" placeholder="Mínimo 6 caracteres" required>
                    </div>
                    <div class="form-group">
                        <label>Confirmar Contraseña *</label>
                        <input type="password" name="confirmPassword" placeholder="Repetir contraseña" required>
                    </div>
                    <button type="submit" class="btn-save"><i class="fas fa-key"></i> Cambiar Contraseña</button>
                </form>
            </div>

            <!-- TEMA -->
            <div class="pref-section" id="sec-tema" style="display:none;">
                <h3><i class="fas fa-palette"></i> Tema de Interfaz</h3>
                <div class="pref-row">
                    <div class="pref-label"><h6>Tema Claro</h6><small>Diseño luminoso para ambientes bien iluminados</small></div>
                    <button class="theme-btn active" id="btn-light" onclick="setTheme('light')"><i class="fas fa-sun"></i> Claro</button>
                </div>
                <div class="pref-row">
                    <div class="pref-label"><h6>Tema Oscuro</h6><small>Más cómodo para los ojos en la noche</small></div>
                    <button class="theme-btn" id="btn-dark" onclick="setTheme('dark')"><i class="fas fa-moon"></i> Oscuro</button>
                </div>
                <div style="margin-top:20px;">
                    <h6 style="margin-bottom:12px;font-weight:600;">Esquema de Colores</h6>
                    <div class="color-grid">
                        <div class="color-swatch active" onclick="setColor('purple')">
                            <div class="color-dots"><div class="color-dot" style="background:#667eea;"></div><div class="color-dot" style="background:#764ba2;"></div></div>
                            <small>Púrpura</small>
                        </div>
                        <div class="color-swatch" onclick="setColor('blue')">
                            <div class="color-dots"><div class="color-dot" style="background:#2196f3;"></div><div class="color-dot" style="background:#1565c0;"></div></div>
                            <small>Azul</small>
                        </div>
                        <div class="color-swatch" onclick="setColor('green')">
                            <div class="color-dots"><div class="color-dot" style="background:#4caf50;"></div><div class="color-dot" style="background:#2e7d32;"></div></div>
                            <small>Verde</small>
                        </div>
                        <div class="color-swatch" onclick="setColor('red')">
                            <div class="color-dots"><div class="color-dot" style="background:#f44336;"></div><div class="color-dot" style="background:#b71c1c;"></div></div>
                            <small>Rojo</small>
                        </div>
                        <div class="color-swatch" onclick="setColor('orange')">
                            <div class="color-dots"><div class="color-dot" style="background:#ff9800;"></div><div class="color-dot" style="background:#e65100;"></div></div>
                            <small>Naranja</small>
                        </div>
                        <div class="color-swatch" onclick="setColor('teal')">
                            <div class="color-dots"><div class="color-dot" style="background:#009688;"></div><div class="color-dot" style="background:#004d40;"></div></div>
                            <small>Teal</small>
                        </div>
                    </div>
                </div>
            </div>

            <!-- IDIOMA -->
            <div class="pref-section" id="sec-idioma" style="display:none;">
                <h3><i class="fas fa-globe"></i> Idioma</h3>
                <div class="pref-row">
                    <div class="pref-label"><h6>Idioma de la interfaz</h6><small>Se aplica inmediatamente</small></div>
                    <div style="display:flex;gap:8px;">
                        <button class="lang-btn active" id="lang-es" onclick="setLang('es')">Español</button>
                        <button class="lang-btn" id="lang-en" onclick="setLang('en')">English</button>
                        <button class="lang-btn" id="lang-pt" onclick="setLang('pt')">Português</button>
                    </div>
                </div>
                <div style="margin-top:12px;padding:12px;background:#f5f5f5;border-radius:8px;font-size:13px;color:#666;">
                    <i class="fas fa-info-circle" style="color:#667eea;"></i> El idioma se guarda en tu navegador y se aplica en todas las páginas.
                </div>
            </div>

            <!-- NOTIFICACIONES -->
            <div class="pref-section" id="sec-notificaciones" style="display:none;">
                <h3><i class="fas fa-bell"></i> Notificaciones</h3>
                <div class="pref-row">
                    <div class="pref-label"><h6>Alertas de Stock Bajo</h6><small>Notificación cuando un activo baja del mínimo</small></div>
                    <label class="switch"><input type="checkbox" id="notif-stock" checked onchange="saveNotifPref()"><span class="slider"></span></label>
                </div>
                <div class="pref-row">
                    <div class="pref-label"><h6>Recordatorios de Mantenimiento</h6><small>Avisos de mantenimiento programado</small></div>
                    <label class="switch"><input type="checkbox" id="notif-maint" checked onchange="saveNotifPref()"><span class="slider"></span></label>
                </div>
                <div class="pref-row">
                    <div class="pref-label"><h6>Actividad de Usuarios</h6><small>Notificaciones de acciones de otros usuarios (solo admin)</small></div>
                    <label class="switch"><input type="checkbox" id="notif-users" onchange="saveNotifPref()"><span class="slider"></span></label>
                </div>
                <div style="margin-top:12px;padding:10px 14px;background:#e8f5e9;border-radius:8px;font-size:13px;color:#2e7d32;" id="notif-saved" style="display:none;">
                    <i class="fas fa-check-circle"></i> Preferencias de notificaciones guardadas
                </div>
            </div>

        </div>
    </div>
</div>

<script>
function showSection(id, link) {
    document.querySelectorAll('.pref-section').forEach(function(s){ s.style.display='none'; });
    var sec = document.getElementById('sec-' + id);
    if (sec) sec.style.display='block';
    document.querySelectorAll('.pref-nav a').forEach(function(a){ a.classList.remove('active'); });
    if (link) link.classList.add('active');
    return false;
}

// Theme
function setTheme(t) {
    localStorage.setItem('theme', t);
    document.getElementById('btn-light').classList.toggle('active', t === 'light');
    document.getElementById('btn-dark').classList.toggle('active', t === 'dark');
    if (window.applyDarkMode) window.applyDarkMode(t === 'dark');
    showToast('Tema ' + (t === 'dark' ? 'oscuro' : 'claro') + ' aplicado');
}

// Color scheme
var colorMap = {
    purple: ['#667eea','#764ba2'], blue: ['#2196f3','#1565c0'],
    green: ['#4caf50','#2e7d32'], red: ['#f44336','#b71c1c'],
    orange: ['#ff9800','#e65100'], teal: ['#009688','#004d40']
};
function setColor(name) {
    document.querySelectorAll('.color-swatch').forEach(function(s){ s.classList.remove('active'); });
    event.currentTarget.classList.add('active');
    localStorage.setItem('colorScheme', name);
    if (window.applyColorScheme) window.applyColorScheme(name);
    showToast('Color aplicado en toda la app');
}

// Language
function setLang(lang) {
    localStorage.setItem('lang', lang);
    ['es','en','pt'].forEach(function(l){ document.getElementById('lang-'+l).classList.toggle('active', l===lang); });
    showToast('Idioma guardado');
}

// Notifications
function saveNotifPref() {
    var prefs = {
        stock: document.getElementById('notif-stock').checked,
        maint: document.getElementById('notif-maint').checked,
        users: document.getElementById('notif-users').checked
    };
    localStorage.setItem('notifPrefs', JSON.stringify(prefs));
    var saved = document.getElementById('notif-saved');
    saved.style.display = 'block';
    setTimeout(function(){ saved.style.display='none'; }, 3000);
}

function showToast(msg) {
    var t = document.createElement('div');
    t.style.cssText = 'position:fixed;top:20px;right:20px;background:#667eea;color:#fff;padding:12px 20px;border-radius:8px;z-index:9999;font-size:14px;font-weight:600;box-shadow:0 4px 12px rgba(0,0,0,.2);';
    t.innerHTML = '<i class="fas fa-check-circle"></i> ' + msg;
    document.body.appendChild(t);
    setTimeout(function(){ t.remove(); }, 2500);
}

// Init: restore saved prefs
document.addEventListener('DOMContentLoaded', function() {
    var theme = localStorage.getItem('theme') || 'light';
    setTheme(theme);
    var lang = localStorage.getItem('lang') || 'es';
    ['es','en','pt'].forEach(function(l){ document.getElementById('lang-'+l).classList.toggle('active', l===lang); });
    var notifPrefs = JSON.parse(localStorage.getItem('notifPrefs') || '{}');
    if (notifPrefs.stock !== undefined) document.getElementById('notif-stock').checked = notifPrefs.stock;
    if (notifPrefs.maint !== undefined) document.getElementById('notif-maint').checked = notifPrefs.maint;
    if (notifPrefs.users !== undefined) document.getElementById('notif-users').checked = notifPrefs.users;
    var colorScheme = localStorage.getItem('colorScheme');
    if (colorScheme) {
        document.querySelectorAll('.color-swatch').forEach(function(s){ s.classList.remove('active'); });
        var swatches = document.querySelectorAll('.color-swatch');
        var idx = Object.keys(colorMap).indexOf(colorScheme);
        if (idx >= 0 && swatches[idx]) swatches[idx].classList.add('active');
    }
});
</script>
</body>
</html>
