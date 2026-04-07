<%@ page isELIgnored="true"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    if (session.getAttribute("username") == null) { response.sendRedirect("index.jsp"); return; }
    String username = (String) session.getAttribute("username");
    String userRole = (String) session.getAttribute("userRole");
    boolean isEditor = "ADMIN".equals(userRole) || "EDITOR".equals(userRole);
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mantenimiento - HiperInventory</title>
    <link rel="stylesheet" href="css/styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .priority-Alta { color:#f44336; font-weight:700; }
        .priority-Crítica { color:#b71c1c; font-weight:700; }
        .priority-Media { color:#ff9800; font-weight:600; }
        .priority-Baja { color:#4caf50; font-weight:600; }
        .status-Pendiente { background:#fff3e0; color:#e65100; padding:3px 10px; border-radius:12px; font-size:12px; font-weight:600; }
        .status-Completado { background:#e8f5e9; color:#2e7d32; padding:3px 10px; border-radius:12px; font-size:12px; font-weight:600; }
        .status-Cancelado { background:#f5f5f5; color:#757575; padding:3px 10px; border-radius:12px; font-size:12px; font-weight:600; }
        .overdue { background:#ffebee !important; }
        .alert { padding:12px 16px; border-radius:8px; margin-bottom:12px; display:flex; align-items:center; gap:8px; }
        .alert-success { background:#e8f5e9; color:#2e7d32; border-left:4px solid #4caf50; }
        .alert-error { background:#ffebee; color:#c62828; border-left:4px solid #f44336; }
        .btn-small { padding:5px 9px; font-size:12px; }
        .btn-danger { background:#f44336; color:#fff; border:none; border-radius:6px; cursor:pointer; }
        .btn-danger:hover { background:#d32f2f; }
        .btn-success { background:#4caf50; color:#fff; border:none; border-radius:6px; cursor:pointer; padding:5px 9px; font-size:12px; }
        .btn-success:hover { background:#388e3c; }
        .summary-cards { display:grid; grid-template-columns:repeat(auto-fit,minmax(180px,1fr)); gap:16px; margin-bottom:24px; }
        .summary-card { background:#fff; border-radius:10px; padding:18px; box-shadow:0 2px 8px rgba(0,0,0,.07); text-align:center; }
        .summary-card .num { font-size:32px; font-weight:700; }
        .summary-card .lbl { font-size:13px; color:#888; margin-top:4px; }
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
        <li><a href="usuarios.jsp"><i class="fas fa-users"></i> Usuarios</a></li>
        <li><a href="reportes.jsp"><i class="fas fa-file-pdf"></i> Reportes</a></li>
        <li><a href="mantenimiento.jsp" class="active"><i class="fas fa-tools"></i> Mantenimiento</a></li>
        <li><a href="depreciacion.jsp"><i class="fas fa-chart-line"></i> Depreciación</a></li>
        <li><a href="auditoria.jsp"><i class="fas fa-history"></i> Auditoría</a></li>
        <li><hr style="border:none;border-top:1px solid rgba(255,255,255,0.1);margin:15px 0;"></li>
        <li><a href="logout.jsp"><i class="fas fa-sign-out-alt"></i> Cerrar Sesión</a></li>
    </ul></nav>
</aside>

<div class="main-layout">
    <header class="topbar">
        <div style="display:flex;align-items:center;gap:15px;">
            <button class="hamburger"><i class="fas fa-bars"></i></button>
            <h2 class="topbar-title">Agenda de Mantenimiento</h2>
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

        <!-- SUMMARY -->
        <div class="summary-cards">
            <div class="summary-card"><div class="num" id="sPendiente" style="color:#ff9800;">â€”</div><div class="lbl">Pendientes</div></div>
            <div class="summary-card"><div class="num" id="sVencido" style="color:#f44336;">â€”</div><div class="lbl">Vencidos</div></div>
            <div class="summary-card"><div class="num" id="sCompletado" style="color:#4caf50;">â€”</div><div class="lbl">Completados</div></div>
            <div class="summary-card"><div class="num" id="sCosto" style="color:#667eea;">â€”</div><div class="lbl">Costo Total</div></div>
        </div>

        <div class="table-container">
            <div class="table-controls">
                <div class="search-box">
                    <i class="fas fa-search"></i>
                    <input type="text" id="searchInput" placeholder="Buscar..." oninput="filterTable()">
                </div>
                <div class="filters">
                    <select class="filter-select" id="fStatus" onchange="filterTable()">
                        <option value="">Todos los estados</option>
                        <option>Pendiente</option>
                        <option>Completado</option>
                        <option>Cancelado</option>
                    </select>
                    <select class="filter-select" id="fPriority" onchange="filterTable()">
                        <option value="">Todas las prioridades</option>
                        <option>Crítica</option>
                        <option>Alta</option>
                        <option>Media</option>
                        <option>Baja</option>
                    </select>
                </div>
                <% if (isEditor) { %>
                <button class="btn btn-primary" onclick="openModal()"><i class="fas fa-plus"></i> Nuevo</button>
                <% } %>
            </div>

            <table>
                <thead>
                    <tr>
                        <th>#</th><th>Activo</th><th>Tipo</th><th>Descripción</th>
                        <th>Fecha Prog.</th><th>Prioridad</th><th>Estado</th><th>Técnico</th><th>Costo</th>
                        <% if (isEditor) { %><th>Acciones</th><% } %>
                    </tr>
                </thead>
                <tbody id="tableBody">
                    <tr><td colspan="10" style="text-align:center;padding:40px;color:#999;"><i class="fas fa-spinner fa-spin"></i> Cargando...</td></tr>
                </tbody>
            </table>
        </div>
    </main>
</div>

<!-- MODAL -->
<div class="modal" id="maintModal">
    <div class="modal-content" style="max-width:560px;">
        <div class="modal-header">
            <h3 class="modal-title" id="modalTitle">Nuevo Mantenimiento</h3>
            <button class="modal-close" onclick="closeModal()">&times;</button>
        </div>
        <div class="modal-body">
            <input type="hidden" id="mId">
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:16px;">
                <div class="form-group" style="grid-column:1/-1;">
                    <label>Activo *</label>
                    <select id="mAssetId"></select>
                </div>
                <div class="form-group">
                    <label>Tipo *</label>
                    <select id="mType">
                        <option>Preventivo</option><option>Correctivo</option><option>Inspección</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Prioridad</label>
                    <select id="mPriority">
                        <option>Baja</option><option selected>Media</option><option>Alta</option><option>Crítica</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Fecha Programada *</label>
                    <input type="date" id="mScheduledDate">
                </div>
                <div class="form-group">
                    <label>Estado</label>
                    <select id="mStatus">
                        <option>Pendiente</option><option>Completado</option><option>Cancelado</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Técnico</label>
                    <input type="text" id="mTechnician" placeholder="Nombre del técnico">
                </div>
                <div class="form-group">
                    <label>Costo ($)</label>
                    <input type="number" id="mCost" value="0" min="0" step="0.01">
                </div>
                <div class="form-group" style="grid-column:1/-1;">
                    <label>Descripción</label>
                    <textarea id="mDescription" rows="2" placeholder="Descripción del trabajo..."></textarea>
                </div>
                <div class="form-group" style="grid-column:1/-1;">
                    <label>Notas</label>
                    <textarea id="mNotes" rows="2" placeholder="Notas adicionales..."></textarea>
                </div>
            </div>
        </div>
        <div class="modal-footer">
            <button class="btn btn-secondary" onclick="closeModal()">Cancelar</button>
            <button class="btn btn-primary" onclick="saveMaint()"><i class="fas fa-save"></i> Guardar</button>
        </div>
    </div>
</div>

<div class="modal" id="deleteModal">
    <div class="modal-content" style="max-width:380px;">
        <div class="modal-header"><h3 class="modal-title">Eliminar</h3><button class="modal-close" onclick="document.getElementById('deleteModal').classList.remove('show')">&times;</button></div>
        <div class="modal-body"><p>Â¿Eliminar este registro de mantenimiento?</p></div>
        <div class="modal-footer">
            <button class="btn btn-secondary" onclick="document.getElementById('deleteModal').classList.remove('show')">Cancelar</button>
            <button class="btn btn-danger" onclick="confirmDelete()"><i class="fas fa-trash"></i> Eliminar</button>
        </div>
    </div>
</div>

<script src="js/app.js"></script>
<script>
const IS_EDITOR = <%= isEditor %>;
let records = [], assets = [], deleteId = null;
const today = new Date().toISOString().split('T')[0];

async function init() {
    // Load assets for dropdown
    try {
        const r = await fetch('api/assets'); const j = await r.json();
        assets = j.data || [];
        const sel = document.getElementById('mAssetId');
        assets.forEach(a => { const o = document.createElement('option'); o.value = a.id; o.textContent = `${a.codigo} - ${a.nombre}`; sel.appendChild(o); });
    } catch(e) {}
    await loadRecords();
}

async function loadRecords() {
    try {
        const r = await fetch('api/maintenance'); const j = await r.json();
        records = Array.isArray(j) ? j : [];
        updateSummary();
        renderTable(records);
    } catch(e) { showAlert('Error cargando mantenimientos: ' + e.message, 'error'); }
}

function updateSummary() {
    const pending = records.filter(r => r.status === 'Pendiente');
    const overdue = pending.filter(r => r.scheduledDate < today);
    const completed = records.filter(r => r.status === 'Completado');
    const totalCost = records.reduce((s, r) => s + (r.cost || 0), 0);
    document.getElementById('sPendiente').textContent = pending.length;
    document.getElementById('sVencido').textContent = overdue.length;
    document.getElementById('sCompletado').textContent = completed.length;
    document.getElementById('sCosto').textContent = '$' + totalCost.toLocaleString('es');
}

function renderTable(data) {
    const tbody = document.getElementById('tableBody');
    if (!data.length) {
        tbody.innerHTML = '<tr><td colspan="10" style="text-align:center;padding:40px;color:#999;"><i class="fas fa-tools" style="font-size:32px;opacity:0.3;display:block;margin-bottom:10px;"></i>Sin registros</td></tr>';
        return;
    }
    tbody.innerHTML = data.map((m, i) => {
        const asset = assets.find(a => a.id === m.assetId);
        const isOverdue = m.status === 'Pendiente' && m.scheduledDate < today;
        return `<tr class="${isOverdue ? 'overdue' : ''}">
            <td>${i+1}</td>
            <td>${asset ? `<strong>${asset.nombre}</strong><br><small style="color:#888;">${asset.codigo}</small>` : `ID:${m.assetId}`}</td>
            <td>${m.type||'â€”'}</td>
            <td style="max-width:180px;font-size:13px;">${m.description||'â€”'}</td>
            <td>${m.scheduledDate||'â€”'} ${isOverdue ? '<i class="fas fa-exclamation-triangle" style="color:#f44336;" title="Vencido"></i>' : ''}</td>
            <td><span class="priority-${m.priority}">${m.priority||'â€”'}</span></td>
            <td><span class="status-${m.status}">${m.status||'â€”'}</span></td>
            <td>${m.technician||'<span style="color:#ccc">â€”</span>'}</td>
            <td>$${(m.cost||0).toLocaleString('es')}</td>
            ${IS_EDITOR ? `<td style="display:flex;gap:4px;">
                <button class="btn btn-secondary btn-small" onclick="editRecord(${m.id})"><i class="fas fa-edit"></i></button>
                ${m.status === 'Pendiente' ? `<button class="btn-success" onclick="markComplete(${m.id})" title="Marcar completado"><i class="fas fa-check"></i></button>` : ''}
                <button class="btn btn-danger btn-small" onclick="askDelete(${m.id})"><i class="fas fa-trash"></i></button>
            </td>` : ''}
        </tr>`;
    }).join('');
}

function filterTable() {
    const q = document.getElementById('searchInput').value.toLowerCase();
    const st = document.getElementById('fStatus').value;
    const pr = document.getElementById('fPriority').value;
    renderTable(records.filter(m => {
        const asset = assets.find(a => a.id === m.assetId);
        const text = `${asset?.nombre||''} ${m.type||''} ${m.description||''} ${m.technician||''}`.toLowerCase();
        return (!q || text.includes(q)) && (!st || m.status === st) && (!pr || m.priority === pr);
    }));
}

function openModal() {
    document.getElementById('mId').value = '';
    document.getElementById('mType').value = 'Preventivo';
    document.getElementById('mPriority').value = 'Media';
    document.getElementById('mScheduledDate').value = today;
    document.getElementById('mStatus').value = 'Pendiente';
    document.getElementById('mTechnician').value = '';
    document.getElementById('mCost').value = '0';
    document.getElementById('mDescription').value = '';
    document.getElementById('mNotes').value = '';
    document.getElementById('modalTitle').textContent = 'Nuevo Mantenimiento';
    document.getElementById('maintModal').classList.add('show');
}

function editRecord(id) {
    const m = records.find(x => x.id === id);
    if (!m) return;
    document.getElementById('mId').value = m.id;
    document.getElementById('mAssetId').value = m.assetId;
    document.getElementById('mType').value = m.type || 'Preventivo';
    document.getElementById('mPriority').value = m.priority || 'Media';
    document.getElementById('mScheduledDate').value = m.scheduledDate || today;
    document.getElementById('mStatus').value = m.status || 'Pendiente';
    document.getElementById('mTechnician').value = m.technician || '';
    document.getElementById('mCost').value = m.cost || 0;
    document.getElementById('mDescription').value = m.description || '';
    document.getElementById('mNotes').value = m.notes || '';
    document.getElementById('modalTitle').textContent = 'Editar Mantenimiento';
    document.getElementById('maintModal').classList.add('show');
}

function closeModal() { document.getElementById('maintModal').classList.remove('show'); }

async function saveMaint() {
    const id = document.getElementById('mId').value;
    const assetId = document.getElementById('mAssetId').value;
    const scheduledDate = document.getElementById('mScheduledDate').value;
    if (!assetId || !scheduledDate) { showAlert('Activo y fecha son requeridos', 'error'); return; }

    const body = JSON.stringify({
        assetId: parseInt(assetId),
        type: document.getElementById('mType').value,
        priority: document.getElementById('mPriority').value,
        scheduledDate,
        status: document.getElementById('mStatus').value,
        technician: document.getElementById('mTechnician').value,
        cost: parseFloat(document.getElementById('mCost').value) || 0,
        description: document.getElementById('mDescription').value,
        notes: document.getElementById('mNotes').value
    });

    const url = id ? `api/maintenance/${id}` : 'api/maintenance';
    const method = id ? 'PUT' : 'POST';
    try {
        const res = await fetch(url, { method, headers: {'Content-Type':'application/json'}, body });
        const json = await res.json();
        if (json.id || json.status) {
            showAlert(id ? 'Actualizado' : 'Creado', 'success');
            closeModal(); loadRecords();
        } else { showAlert(json.error || 'Error guardando', 'error'); }
    } catch(e) { showAlert('Error: ' + e.message, 'error'); }
}

async function markComplete(id) {
    const m = records.find(x => x.id === id);
    if (!m) return;
    const body = JSON.stringify({ ...m, status: 'Completado', completedDate: today });
    try {
        const res = await fetch(`api/maintenance/${id}`, { method: 'PUT', headers: {'Content-Type':'application/json'}, body });
        const json = await res.json();
        if (json.status) { showAlert('Marcado como completado', 'success'); loadRecords(); }
    } catch(e) { showAlert('Error: ' + e.message, 'error'); }
}

function askDelete(id) { deleteId = id; document.getElementById('deleteModal').classList.add('show'); }

async function confirmDelete() {
    if (!deleteId) return;
    try {
        const res = await fetch(`api/maintenance/${deleteId}`, { method: 'DELETE' });
        const json = await res.json();
        if (json.status) { showAlert('Eliminado', 'success'); document.getElementById('deleteModal').classList.remove('show'); deleteId = null; loadRecords(); }
        else { showAlert(json.error || 'Error', 'error'); }
    } catch(e) { showAlert('Error: ' + e.message, 'error'); }
}

function showAlert(msg, type) {
    const div = document.createElement('div');
    div.className = `alert alert-${type === 'error' ? 'error' : 'success'}`;
    div.innerHTML = `<i class="fas fa-${type === 'error' ? 'exclamation-circle' : 'check-circle'}"></i> ${msg}`;
    document.getElementById('alert-container').appendChild(div);
    setTimeout(() => div.remove(), 4000);
}

document.addEventListener('DOMContentLoaded', init);
</script>
</body>
</html>
