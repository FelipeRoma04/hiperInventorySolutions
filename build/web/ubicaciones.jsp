<%@ page isELIgnored="true"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    if (session.getAttribute("username") == null) {
        response.sendRedirect("index.jsp");
        return;
    }
    String username = (String) session.getAttribute("username");
    String userRole = (String) session.getAttribute("userRole");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ubicaciones - hiperInventorySolutions</title>
    <link rel="stylesheet" href="css/styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
    <aside class="sidebar">
        <div class="sidebar-header"><h1><i class="fas fa-cube"></i> HiperInventory</h1></div>
        <nav><ul class="sidebar-nav">
            <li><a href="inicio.jsp"><i class="fas fa-chart-line"></i> Dashboard</a></li>
            <li><a href="activos.jsp"><i class="fas fa-box"></i> Activos</a></li>
            <li><a href="categorias.jsp"><i class="fas fa-tags"></i> Categorías</a></li>
            <li><a href="ubicaciones.jsp" class="active"><i class="fas fa-map-marker-alt"></i> Ubicaciones</a></li>
            <li><a href="usuarios.jsp"><i class="fas fa-users"></i> Usuarios</a></li>
            <li><a href="reportes.jsp"><i class="fas fa-file-pdf"></i> Reportes</a></li>
            <li><hr style="border:none;border-top:1px solid rgba(255,255,255,0.1);margin:15px 0;"></li>
            <li><a href="logout.jsp"><i class="fas fa-sign-out-alt"></i> Cerrar Sesión</a></li>
        </ul></nav>
    </aside>

    <div class="main-layout">
        <header class="topbar">
            <div style="display:flex;align-items:center;gap:15px;">
                <button class="hamburger"><i class="fas fa-bars"></i></button>
                <h2 class="topbar-title">Ubicaciones</h2>
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

            <div class="table-container">
                <div class="table-controls">
                    <div class="search-box">
                        <i class="fas fa-search"></i>
                        <input type="text" id="searchInput" placeholder="Buscar ubicación..." oninput="filterTable()">
                    </div>
                    <div class="action-buttons">
                        <% if ("ADMIN".equals(userRole) || "EDITOR".equals(userRole)) { %>
                        <button class="btn btn-primary" onclick="openModal()">
                            <i class="fas fa-plus"></i> Nueva Ubicación
                        </button>
                        <% } %>
                    </div>
                </div>

                <table id="ubicacionesTable">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Nombre</th>
                            <th>Sede</th>
                            <th>Descripción</th>
                            <th>Activos</th>
                            <th>Fecha Creación</th>
                            <% if ("ADMIN".equals(userRole) || "EDITOR".equals(userRole)) { %>
                            <th>Acciones</th>
                            <% } %>
                        </tr>
                    </thead>
                    <tbody id="tableBody">
                        <tr><td colspan="7" style="text-align:center;padding:40px;color:#999;">
                            <i class="fas fa-spinner fa-spin"></i> Cargando...
                        </td></tr>
                    </tbody>
                </table>
            </div>
        </main>
    </div>

    <!-- MODAL -->
    <div class="modal" id="ubicacionModal">
        <div class="modal-content">
            <div class="modal-header">
                <h3 class="modal-title" id="modalTitle">Nueva Ubicación</h3>
                <button class="modal-close" onclick="closeModal()">&times;</button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="ubicacionId">
                <div class="form-group">
                    <label>Nombre *</label>
                    <input type="text" id="nombre" placeholder="Ej: Almacén Central" required>
                </div>
                <div class="form-group">
                    <label>Sede</label>
                    <input type="text" id="sede" placeholder="Ej: Principal">
                </div>
                <div class="form-group">
                    <label>Descripción</label>
                    <textarea id="descripcion" rows="3" placeholder="Descripción opcional..."></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button class="btn btn-secondary" onclick="closeModal()">Cancelar</button>
                <button class="btn btn-primary" onclick="saveUbicacion()">
                    <i class="fas fa-save"></i> Guardar
                </button>
            </div>
        </div>
    </div>

    <!-- CONFIRM DELETE MODAL -->
    <div class="modal" id="deleteModal">
        <div class="modal-content" style="max-width:400px;">
            <div class="modal-header">
                <h3 class="modal-title">Confirmar Eliminación</h3>
                <button class="modal-close" onclick="closeDeleteModal()">&times;</button>
            </div>
            <div class="modal-body">
                <p>Â¿Estás seguro de que deseas eliminar la ubicación <strong id="deleteNombre"></strong>?</p>
            </div>
            <div class="modal-footer">
                <button class="btn btn-secondary" onclick="closeDeleteModal()">Cancelar</button>
                <button class="btn btn-danger" onclick="confirmDelete()">
                    <i class="fas fa-trash"></i> Eliminar
                </button>
            </div>
        </div>
    </div>

    <script src="js/app.js"></script>
    <script>
        const isEditor = <%= ("ADMIN".equals(userRole) || "EDITOR".equals(userRole)) %>;
        let ubicaciones = [];
        let deleteId = null;

        async function loadUbicaciones() {
            try {
                const res = await fetch('api/ubicaciones');
                const json = await res.json();
                ubicaciones = json.data || [];
                renderTable(ubicaciones);
            } catch(e) {
                showAlert('Error cargando ubicaciones: ' + e.message, 'error');
            }
        }

        function renderTable(data) {
            const tbody = document.getElementById('tableBody');
            if (!data.length) {
                tbody.innerHTML = '<tr><td colspan="7" style="text-align:center;padding:40px;color:#999;"><i class="fas fa-map-marker-alt" style="font-size:32px;opacity:0.3;display:block;margin-bottom:10px;"></i>No hay ubicaciones registradas</td></tr>';
                return;
            }
            tbody.innerHTML = data.map((u, i) => `
                <tr>
                    <td>${i + 1}</td>
                    <td><strong>${u.nombre}</strong></td>
                    <td>${u.sede ? `<span class="location-badge">${u.sede}</span>` : '<span style="color:#ccc">â€”</span>'}</td>
                    <td>${u.descripcion || '<span style="color:#ccc">â€”</span>'}</td>
                    <td><span class="badge badge-active">${u.totalActivos || 0}</span></td>
                    <td>${u.fechaCreacion ? new Date(u.fechaCreacion).toLocaleDateString('es') : 'â€”'}</td>
                    ${isEditor ? `<td>
                        <button class="btn btn-secondary btn-small" onclick="editUbicacion(${u.id})">
                            <i class="fas fa-edit"></i>
                        </button>
                        <button class="btn btn-danger btn-small" onclick="askDelete(${u.id}, '${u.nombre.replace(/'/g,"\\'")}')">
                            <i class="fas fa-trash"></i>
                        </button>
                    </td>` : ''}
                </tr>`).join('');
        }

        function filterTable() {
            const q = document.getElementById('searchInput').value.toLowerCase();
            renderTable(ubicaciones.filter(u =>
                u.nombre.toLowerCase().includes(q) ||
                (u.sede||'').toLowerCase().includes(q) ||
                (u.descripcion||'').toLowerCase().includes(q)
            ));
        }

        function openModal() {
            document.getElementById('ubicacionId').value = '';
            document.getElementById('nombre').value = '';
            document.getElementById('sede').value = '';
            document.getElementById('descripcion').value = '';
            document.getElementById('modalTitle').textContent = 'Nueva Ubicación';
            document.getElementById('ubicacionModal').classList.add('show');
        }

        function editUbicacion(id) {
            const u = ubicaciones.find(x => x.id === id);
            if (!u) return;
            document.getElementById('ubicacionId').value = u.id;
            document.getElementById('nombre').value = u.nombre;
            document.getElementById('sede').value = u.sede || '';
            document.getElementById('descripcion').value = u.descripcion || '';
            document.getElementById('modalTitle').textContent = 'Editar Ubicación';
            document.getElementById('ubicacionModal').classList.add('show');
        }

        function closeModal() { document.getElementById('ubicacionModal').classList.remove('show'); }

        async function saveUbicacion() {
            const id = document.getElementById('ubicacionId').value;
            const nombre = document.getElementById('nombre').value.trim();
            const sede = document.getElementById('sede').value.trim();
            const descripcion = document.getElementById('descripcion').value.trim();
            if (!nombre) { showAlert('El nombre es requerido', 'error'); return; }

            const params = new URLSearchParams({ nombre, sede, descripcion });
            const url = id ? `api/ubicaciones/${id}` : 'api/ubicaciones';
            const method = id ? 'PUT' : 'POST';

            try {
                const res = await fetch(url, { method, body: params });
                const json = await res.json();
                if (json.success) {
                    showAlert(id ? 'Ubicación actualizada' : 'Ubicación creada', 'success');
                    closeModal();
                    loadUbicaciones();
                } else {
                    showAlert(json.message || 'Error guardando', 'error');
                }
            } catch(e) { showAlert('Error: ' + e.message, 'error'); }
        }

        function askDelete(id, nombre) {
            deleteId = id;
            document.getElementById('deleteNombre').textContent = nombre;
            document.getElementById('deleteModal').classList.add('show');
        }

        function closeDeleteModal() { document.getElementById('deleteModal').classList.remove('show'); deleteId = null; }

        async function confirmDelete() {
            if (!deleteId) return;
            try {
                const res = await fetch(`api/ubicaciones/${deleteId}`, { method: 'DELETE' });
                const json = await res.json();
                if (json.success) {
                    showAlert('Ubicación eliminada', 'success');
                    closeDeleteModal();
                    loadUbicaciones();
                } else {
                    showAlert(json.message || 'Error eliminando', 'error');
                }
            } catch(e) { showAlert('Error: ' + e.message, 'error'); }
        }

        function showAlert(msg, type) {
            const div = document.createElement('div');
            div.className = `alert alert-${type === 'error' ? 'error' : 'success'}`;
            div.innerHTML = `<i class="fas fa-${type === 'error' ? 'exclamation-circle' : 'check-circle'}"></i> ${msg}`;
            const container = document.getElementById('alert-container');
            container.appendChild(div);
            setTimeout(() => div.remove(), 4000);
        }

        document.addEventListener('DOMContentLoaded', loadUbicaciones);
    </script>
</body>
</html>
