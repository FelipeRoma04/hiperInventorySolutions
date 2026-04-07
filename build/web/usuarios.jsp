<%@ page isELIgnored="true"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    if (session.getAttribute("username") == null) { response.sendRedirect("index.jsp"); return; }
    String username = (String) session.getAttribute("username");
    String userRole = (String) session.getAttribute("userRole");
    int sessionUserId = session.getAttribute("userId") != null ? (Integer) session.getAttribute("userId") : -1;
    boolean isAdmin = "ADMIN".equals(userRole);
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Usuarios - HiperInventory</title>
    <link rel="stylesheet" href="css/styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .role-badge { display:inline-block; padding:4px 10px; border-radius:12px; font-size:11px; font-weight:700; text-transform:uppercase; }
        .role-ADMIN { background:#e3f2fd; color:#0d47a1; }
        .role-EDITOR { background:#f3e5f5; color:#6a1b9a; }
        .role-VIEWER { background:#e8f5e9; color:#2e7d32; }
        .status-active { color:#4caf50; font-weight:600; }
        .status-inactive { color:#f44336; font-weight:600; }
        .btn-small { padding:5px 10px; font-size:12px; }
        .btn-danger { background:#f44336; color:#fff; border:none; border-radius:6px; cursor:pointer; }
        .btn-danger:hover { background:#d32f2f; }
        .alert { padding:12px 16px; border-radius:8px; margin-bottom:12px; display:flex; align-items:center; gap:8px; }
        .alert-success { background:#e8f5e9; color:#2e7d32; border-left:4px solid #4caf50; }
        .alert-error { background:#ffebee; color:#c62828; border-left:4px solid #f44336; }
        .avatar-circle { width:36px; height:36px; border-radius:50%; background:linear-gradient(135deg,#667eea,#764ba2); color:#fff; display:inline-flex; align-items:center; justify-content:center; font-weight:700; font-size:14px; }
        .no-admin-msg { background:#fff3e0; border-left:4px solid #ff9800; padding:20px; border-radius:8px; color:#e65100; }
    </style>
</head>
<body>
<aside class="sidebar">
    <div class="sidebar-header"><h1><i class="fas fa-cube"></i> HiperInventory</h1></div>
    <nav><ul class="sidebar-nav">
        <li><a href="inicio.jsp"><i class="fas fa-chart-line"></i> Dashboard</a></li>
        <li><a href="activos.jsp"><i class="fas fa-box"></i> Activos</a></li>
        <li><a href="categorias.jsp"><i class="fas fa-tags"></i> Categorías</a></li>
        <li><a href="ubicaciones.jsp"><i class="fas fa-map-marker-alt"></i> Ubicaciones</a></li>
        <li><a href="usuarios.jsp" class="active"><i class="fas fa-users"></i> Usuarios</a></li>
        <li><a href="reportes.jsp"><i class="fas fa-file-pdf"></i> Reportes</a></li>
        <li><hr style="border:none;border-top:1px solid rgba(255,255,255,0.1);margin:15px 0;"></li>
        <li><a href="logout.jsp"><i class="fas fa-sign-out-alt"></i> Cerrar Sesión</a></li>
    </ul></nav>
</aside>

<div class="main-layout">
    <header class="topbar">
        <div style="display:flex;align-items:center;gap:15px;">
            <button class="hamburger"><i class="fas fa-bars"></i></button>
            <h2 class="topbar-title">Usuarios</h2>
        </div>
        <div class="topbar-right">
            <div class="user-menu">
                <div class="user-avatar"><%= Character.toUpperCase(username.charAt(0)) %></div>
                <span><%= username %></span>
            </div>
        </div>
    </header>

    <main class="main-content">
        <div id="alert-container"></div>

        <% if (!isAdmin) { %>
        <div class="no-admin-msg">
            <i class="fas fa-lock"></i> Solo los administradores pueden gestionar usuarios.
        </div>
        <% } else { %>

        <div class="table-container">
            <div class="table-controls">
                <div class="search-box">
                    <i class="fas fa-search"></i>
                    <input type="text" id="searchInput" placeholder="Buscar usuario..." oninput="filterTable()">
                </div>
                <div class="action-buttons">
                    <button class="btn btn-primary" onclick="openModal()">
                        <i class="fas fa-plus"></i> Nuevo Usuario
                    </button>
                </div>
            </div>

            <table>
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Usuario</th>
                        <th>Nombre</th>
                        <th>Email</th>
                        <th>Rol</th>
                        <th>Departamento</th>
                        <th>Ãšltimo Acceso</th>
                        <th>Estado</th>
                        <th>Acciones</th>
                    </tr>
                </thead>
                <tbody id="tableBody">
                    <tr><td colspan="9" style="text-align:center;padding:40px;color:#999;">
                        <i class="fas fa-spinner fa-spin"></i> Cargando...
                    </td></tr>
                </tbody>
            </table>
        </div>
        <% } %>
    </main>
</div>

<!-- MODAL CREAR/EDITAR -->
<div class="modal" id="userModal">
    <div class="modal-content" style="max-width:560px;">
        <div class="modal-header">
            <h3 class="modal-title" id="modalTitle">Nuevo Usuario</h3>
            <button class="modal-close" onclick="closeModal()">&times;</button>
        </div>
        <div class="modal-body">
            <input type="hidden" id="userId">
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:16px;">
                <div class="form-group">
                    <label>Username *</label>
                    <input type="text" id="uUsername" placeholder="ej: jperez">
                </div>
                <div class="form-group">
                    <label>Contraseña <span id="passHint" style="color:#999;font-weight:400;">(requerida)</span></label>
                    <input type="password" id="uPassword" placeholder="Mínimo 6 caracteres">
                </div>
                <div class="form-group">
                    <label>Nombre *</label>
                    <input type="text" id="uNombre" placeholder="Nombre">
                </div>
                <div class="form-group">
                    <label>Apellido</label>
                    <input type="text" id="uApellido" placeholder="Apellido">
                </div>
                <div class="form-group">
                    <label>Email *</label>
                    <input type="email" id="uEmail" placeholder="correo@empresa.com">
                </div>
                <div class="form-group">
                    <label>Rol *</label>
                    <select id="uRol">
                        <option value="VIEWER">Lectura (Viewer)</option>
                        <option value="EDITOR">Editor</option>
                        <option value="ADMIN">Administrador</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Departamento</label>
                    <input type="text" id="uDepartamento" placeholder="Ej: IT">
                </div>
                <div class="form-group">
                    <label>Teléfono</label>
                    <input type="text" id="uTelefono" placeholder="+1 555 0000">
                </div>
                <div class="form-group">
                    <label>Sede</label>
                    <input type="text" id="uSede" placeholder="Ej: Principal">
                </div>
            </div>
            <!-- Role description -->
            <div id="roleDesc" style="margin-top:8px;padding:10px 14px;background:#f5f5f5;border-radius:6px;font-size:13px;color:#555;"></div>
        </div>
        <div class="modal-footer">
            <button class="btn btn-secondary" onclick="closeModal()">Cancelar</button>
            <button class="btn btn-primary" onclick="saveUser()"><i class="fas fa-save"></i> Guardar</button>
        </div>
    </div>
</div>

<!-- MODAL CAMBIAR CONTRASEÃ‘A -->
<div class="modal" id="pwdModal">
    <div class="modal-content" style="max-width:380px;">
        <div class="modal-header">
            <h3 class="modal-title">Cambiar Contraseña</h3>
            <button class="modal-close" onclick="closePwdModal()">&times;</button>
        </div>
        <div class="modal-body">
            <input type="hidden" id="pwdUserId">
            <div class="form-group">
                <label>Nueva Contraseña *</label>
                <input type="password" id="newPassword" placeholder="Mínimo 6 caracteres">
            </div>
            <div class="form-group">
                <label>Confirmar Contraseña *</label>
                <input type="password" id="confirmPassword" placeholder="Repetir contraseña">
            </div>
        </div>
        <div class="modal-footer">
            <button class="btn btn-secondary" onclick="closePwdModal()">Cancelar</button>
            <button class="btn btn-primary" onclick="changePassword()"><i class="fas fa-key"></i> Cambiar</button>
        </div>
    </div>
</div>

<!-- MODAL CONFIRMAR DESACTIVAR -->
<div class="modal" id="deleteModal">
    <div class="modal-content" style="max-width:400px;">
        <div class="modal-header">
            <h3 class="modal-title">Desactivar Usuario</h3>
            <button class="modal-close" onclick="closeDeleteModal()">&times;</button>
        </div>
        <div class="modal-body">
            <p>Â¿Desactivar al usuario <strong id="deleteUsername"></strong>?</p>
            <p style="color:#f44336;font-size:13px;margin-top:8px;"><i class="fas fa-info-circle"></i> El usuario no podrá iniciar sesión pero sus datos se conservan.</p>
        </div>
        <div class="modal-footer">
            <button class="btn btn-secondary" onclick="closeDeleteModal()">Cancelar</button>
            <button class="btn btn-danger" onclick="confirmDelete()"><i class="fas fa-user-slash"></i> Desactivar</button>
        </div>
    </div>
</div>

<script src="js/app.js"></script>
<script>
const SESSION_USER_ID = <%= sessionUserId %>;
let users = [];
let deleteId = null;

const roleDescriptions = {
    ADMIN: 'ðŸ”´ Acceso total: crear, editar, eliminar activos, gestionar usuarios y configuración.',
    EDITOR: 'ðŸŸ¡ Puede crear y editar activos, categorías y ubicaciones. No puede eliminar ni gestionar usuarios.',
    VIEWER: 'ðŸŸ¢ Solo lectura. Puede ver activos y reportes pero no modificar nada.'
};

document.getElementById('uRol').addEventListener('change', updateRoleDesc);
function updateRoleDesc() {
    const rol = document.getElementById('uRol').value;
    document.getElementById('roleDesc').textContent = roleDescriptions[rol] || '';
}
updateRoleDesc();

async function loadUsers() {
    try {
        const res = await fetch('api/users');
        const json = await res.json();
        if (!json.success) { showAlert(json.message || 'Sin acceso', 'error'); return; }
        users = json.data || [];
        renderTable(users);
    } catch(e) { showAlert('Error cargando usuarios: ' + e.message, 'error'); }
}

function renderTable(data) {
    const tbody = document.getElementById('tableBody');
    if (!data.length) {
        tbody.innerHTML = '<tr><td colspan="9" style="text-align:center;padding:40px;color:#999;"><i class="fas fa-users" style="font-size:32px;opacity:0.3;display:block;margin-bottom:10px;"></i>No hay usuarios</td></tr>';
        return;
    }
    tbody.innerHTML = data.map((u, i) => `
        <tr>
            <td>${i+1}</td>
            <td><div style="display:flex;align-items:center;gap:8px;">
                <div class="avatar-circle">${u.nombre.charAt(0).toUpperCase()}</div>
                <strong>${u.username}</strong>
            </div></td>
            <td>${u.nombre} ${u.apellido}</td>
            <td>${u.email}</td>
            <td><span class="role-badge role-${u.rol}">${u.rol}</span></td>
            <td>${u.departamento || '<span style="color:#ccc">â€”</span>'}</td>
            <td style="font-size:12px;color:#888;">${u.ultimoAcceso ? new Date(u.ultimoAcceso).toLocaleString('es') : 'Nunca'}</td>
            <td><span class="${u.activo ? 'status-active' : 'status-inactive'}">
                <i class="fas fa-${u.activo ? 'check-circle' : 'times-circle'}"></i> ${u.activo ? 'Activo' : 'Inactivo'}
            </span></td>
            <td style="display:flex;gap:6px;flex-wrap:wrap;">
                <button class="btn btn-secondary btn-small" onclick="editUser(${u.id})" title="Editar"><i class="fas fa-edit"></i></button>
                <button class="btn btn-secondary btn-small" onclick="openPwdModal(${u.id})" title="Cambiar contraseña"><i class="fas fa-key"></i></button>
                ${u.id !== SESSION_USER_ID ? `<button class="btn btn-danger btn-small" onclick="askDelete(${u.id},'${u.username.replace(/'/g,"\\'")}')"><i class="fas fa-user-slash"></i></button>` : ''}
            </td>
        </tr>`).join('');
}

function filterTable() {
    const q = document.getElementById('searchInput').value.toLowerCase();
    renderTable(users.filter(u =>
        u.username.toLowerCase().includes(q) ||
        u.nombre.toLowerCase().includes(q) ||
        u.email.toLowerCase().includes(q) ||
        u.rol.toLowerCase().includes(q) ||
        (u.departamento||'').toLowerCase().includes(q)
    ));
}

function openModal() {
    document.getElementById('userId').value = '';
    document.getElementById('uUsername').value = '';
    document.getElementById('uPassword').value = '';
    document.getElementById('uNombre').value = '';
    document.getElementById('uApellido').value = '';
    document.getElementById('uEmail').value = '';
    document.getElementById('uRol').value = 'VIEWER';
    document.getElementById('uDepartamento').value = '';
    document.getElementById('uTelefono').value = '';
    document.getElementById('uSede').value = '';
    document.getElementById('uUsername').disabled = false;
    document.getElementById('passHint').textContent = '(requerida)';
    document.getElementById('modalTitle').textContent = 'Nuevo Usuario';
    updateRoleDesc();
    document.getElementById('userModal').classList.add('show');
}

function editUser(id) {
    const u = users.find(x => x.id === id);
    if (!u) return;
    document.getElementById('userId').value = u.id;
    document.getElementById('uUsername').value = u.username;
    document.getElementById('uUsername').disabled = true;
    document.getElementById('uPassword').value = '';
    document.getElementById('uNombre').value = u.nombre;
    document.getElementById('uApellido').value = u.apellido || '';
    document.getElementById('uEmail').value = u.email;
    document.getElementById('uRol').value = u.rol;
    document.getElementById('uDepartamento').value = u.departamento || '';
    document.getElementById('uTelefono').value = u.telefono || '';
    document.getElementById('uSede').value = u.sede || '';
    document.getElementById('passHint').textContent = '(dejar vacío para no cambiar)';
    document.getElementById('modalTitle').textContent = 'Editar Usuario';
    updateRoleDesc();
    document.getElementById('userModal').classList.add('show');
}

function closeModal() { document.getElementById('userModal').classList.remove('show'); }

async function saveUser() {
    const id = document.getElementById('userId').value;
    const nombre = document.getElementById('uNombre').value.trim();
    const email = document.getElementById('uEmail').value.trim();
    const rol = document.getElementById('uRol').value;
    if (!nombre || !email || !rol) { showAlert('Nombre, email y rol son requeridos', 'error'); return; }

    const params = new URLSearchParams({
        nombre, email, rol,
        apellido: document.getElementById('uApellido').value.trim(),
        departamento: document.getElementById('uDepartamento').value.trim(),
        telefono: document.getElementById('uTelefono').value.trim(),
        sede: document.getElementById('uSede').value.trim()
    });

    if (!id) {
        const username = document.getElementById('uUsername').value.trim();
        const password = document.getElementById('uPassword').value;
        if (!username || !password) { showAlert('Username y contraseña son requeridos', 'error'); return; }
        params.append('username', username);
        params.append('password', password);
    }

    const url = id ? `api/users/${id}` : 'api/users';
    const method = id ? 'PUT' : 'POST';
    try {
        const res = await fetch(url, { method, body: params });
        const json = await res.json();
        if (json.success) {
            showAlert(id ? 'Usuario actualizado' : 'Usuario creado', 'success');
            closeModal(); loadUsers();
        } else { showAlert(json.message || 'Error guardando', 'error'); }
    } catch(e) { showAlert('Error: ' + e.message, 'error'); }
}

function openPwdModal(id) {
    document.getElementById('pwdUserId').value = id;
    document.getElementById('newPassword').value = '';
    document.getElementById('confirmPassword').value = '';
    document.getElementById('pwdModal').classList.add('show');
}
function closePwdModal() { document.getElementById('pwdModal').classList.remove('show'); }

async function changePassword() {
    const id = document.getElementById('pwdUserId').value;
    const pwd = document.getElementById('newPassword').value;
    const confirm = document.getElementById('confirmPassword').value;
    if (pwd.length < 6) { showAlert('La contraseña debe tener al menos 6 caracteres', 'error'); return; }
    if (pwd !== confirm) { showAlert('Las contraseñas no coinciden', 'error'); return; }
    try {
        const res = await fetch(`api/users/${id}`, { method: 'PUT', body: new URLSearchParams({ newPassword: pwd }) });
        const json = await res.json();
        if (json.success) { showAlert('Contraseña actualizada', 'success'); closePwdModal(); }
        else { showAlert(json.message || 'Error', 'error'); }
    } catch(e) { showAlert('Error: ' + e.message, 'error'); }
}

function askDelete(id, uname) {
    deleteId = id;
    document.getElementById('deleteUsername').textContent = uname;
    document.getElementById('deleteModal').classList.add('show');
}
function closeDeleteModal() { document.getElementById('deleteModal').classList.remove('show'); deleteId = null; }

async function confirmDelete() {
    if (!deleteId) return;
    try {
        const res = await fetch(`api/users/${deleteId}`, { method: 'DELETE' });
        const json = await res.json();
        if (json.success) { showAlert('Usuario desactivado', 'success'); closeDeleteModal(); loadUsers(); }
        else { showAlert(json.message || 'Error', 'error'); }
    } catch(e) { showAlert('Error: ' + e.message, 'error'); }
}

function showAlert(msg, type) {
    const div = document.createElement('div');
    div.className = `alert alert-${type === 'error' ? 'error' : 'success'}`;
    div.innerHTML = `<i class="fas fa-${type === 'error' ? 'exclamation-circle' : 'check-circle'}"></i> ${msg}`;
    document.getElementById('alert-container').appendChild(div);
    setTimeout(() => div.remove(), 4000);
}

document.addEventListener('DOMContentLoaded', loadUsers);
</script>
</body>
</html>
