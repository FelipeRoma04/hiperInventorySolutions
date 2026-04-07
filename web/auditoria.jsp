<%@ page isELIgnored="true"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    if (session.getAttribute("username") == null) { response.sendRedirect("index.jsp"); return; }
    String username = (String) session.getAttribute("username");
    String userRole = (String) session.getAttribute("userRole");
    boolean isAdmin = "ADMIN".equals(userRole);
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Auditoría - HiperInventory</title>
    <link rel="stylesheet" href="css/styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .action-CREATE { background:#e8f5e9; color:#2e7d32; padding:3px 10px; border-radius:12px; font-size:11px; font-weight:700; }
        .action-UPDATE { background:#e3f2fd; color:#0d47a1; padding:3px 10px; border-radius:12px; font-size:11px; font-weight:700; }
        .action-DELETE { background:#ffebee; color:#c62828; padding:3px 10px; border-radius:12px; font-size:11px; font-weight:700; }
        .action-LOGIN  { background:#f3e5f5; color:#6a1b9a; padding:3px 10px; border-radius:12px; font-size:11px; font-weight:700; }
        .action-LOGOUT { background:#f5f5f5; color:#757575; padding:3px 10px; border-radius:12px; font-size:11px; font-weight:700; }
        .action-DEACTIVATE { background:#fff3e0; color:#e65100; padding:3px 10px; border-radius:12px; font-size:11px; font-weight:700; }
        .no-admin-msg { background:#fff3e0; border-left:4px solid #ff9800; padding:20px; border-radius:8px; color:#e65100; }
        .summary-cards { display:grid; grid-template-columns:repeat(auto-fit,minmax(160px,1fr)); gap:16px; margin-bottom:24px; }
        .summary-card { background:#fff; border-radius:10px; padding:16px; box-shadow:0 2px 8px rgba(0,0,0,.07); text-align:center; }
        .summary-card .num { font-size:28px; font-weight:700; }
        .summary-card .lbl { font-size:12px; color:#888; margin-top:4px; }
        .val-cell { max-width:160px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; font-size:12px; color:#666; cursor:pointer; }
        .val-cell:hover { color:#667eea; }
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
        <li><a href="mantenimiento.jsp"><i class="fas fa-tools"></i> Mantenimiento</a></li>
        <li><a href="depreciacion.jsp"><i class="fas fa-chart-line"></i> Depreciación</a></li>
        <li><a href="auditoria.jsp" class="active"><i class="fas fa-history"></i> Auditoría</a></li>
        <li><hr style="border:none;border-top:1px solid rgba(255,255,255,0.1);margin:15px 0;"></li>
        <li><a href="logout.jsp"><i class="fas fa-sign-out-alt"></i> Cerrar Sesión</a></li>
    </ul></nav>
</aside>

<div class="main-layout">
    <header class="topbar">
        <div style="display:flex;align-items:center;gap:15px;">
            <button class="hamburger"><i class="fas fa-bars"></i></button>
            <h2 class="topbar-title">Historial de Auditoría</h2>
        </div>
        <div class="topbar-right">
            <div class="user-menu">
                <div class="user-avatar"><%= Character.toUpperCase(username.charAt(0)) %></div>
                <span><%= username %></span>
            </div>
        </div>
    </header>

    <main class="main-content">
        <% if (!isAdmin) { %>
        <div class="no-admin-msg"><i class="fas fa-lock"></i> Solo los administradores pueden ver el historial de auditoría.</div>
        <% } else { %>

        <div class="summary-cards">
            <div class="summary-card"><div class="num" id="sTotal" style="color:#667eea;">â€”</div><div class="lbl">Total Eventos</div></div>
            <div class="summary-card"><div class="num" id="sCreate" style="color:#4caf50;">â€”</div><div class="lbl">Creaciones</div></div>
            <div class="summary-card"><div class="num" id="sUpdate" style="color:#2196f3;">â€”</div><div class="lbl">Actualizaciones</div></div>
            <div class="summary-card"><div class="num" id="sDelete" style="color:#f44336;">â€”</div><div class="lbl">Eliminaciones</div></div>
            <div class="summary-card"><div class="num" id="sLogin" style="color:#9c27b0;">â€”</div><div class="lbl">Inicios de Sesión</div></div>
        </div>

        <div class="table-container">
            <div class="table-controls">
                <div class="search-box">
                    <i class="fas fa-search"></i>
                    <input type="text" id="searchInput" placeholder="Buscar usuario, tabla..." oninput="filterTable()">
                </div>
                <div class="filters">
                    <select class="filter-select" id="fAccion" onchange="filterTable()">
                        <option value="">Todas las acciones</option>
                        <option>CREATE</option><option>UPDATE</option><option>DELETE</option>
                        <option>LOGIN</option><option>LOGOUT</option><option>DEACTIVATE</option>
                    </select>
                    <select class="filter-select" id="fTabla" onchange="filterTable()">
                        <option value="">Todas las tablas</option>
                        <option>assets</option><option>users</option><option>categorias</option>
                        <option>ubicaciones</option><option>auth</option>
                    </select>
                </div>
                <div style="display:flex;gap:8px;">
                    <button class="btn btn-secondary" onclick="loadRecords()"><i class="fas fa-sync"></i> Actualizar</button>
                    <button class="btn-bulk btn-export" onclick="exportCSV()"><i class="fas fa-download"></i> CSV</button>
                </div>
            </div>

            <table>
                <thead>
                    <tr>
                        <th>#</th><th>Fecha/Hora</th><th>Usuario</th><th>Acción</th>
                        <th>Tabla</th><th>Registro ID</th><th>Valor Anterior</th><th>Valor Nuevo</th>
                    </tr>
                </thead>
                <tbody id="tableBody">
                    <tr><td colspan="8" style="text-align:center;padding:40px;color:#999;"><i class="fas fa-spinner fa-spin"></i> Cargando...</td></tr>
                </tbody>
            </table>
            <div id="recordCount" style="padding:10px 0;font-size:13px;color:#888;"></div>
        </div>
        <% } %>
    </main>
</div>

<!-- DETAIL MODAL -->
<div class="modal" id="detailModal">
    <div class="modal-content" style="max-width:500px;">
        <div class="modal-header">
            <h3 class="modal-title">Detalle del Evento</h3>
            <button class="modal-close" onclick="document.getElementById('detailModal').classList.remove('show')">&times;</button>
        </div>
        <div class="modal-body" id="detailBody"></div>
        <div class="modal-footer">
            <button class="btn btn-secondary" onclick="document.getElementById('detailModal').classList.remove('show')">Cerrar</button>
        </div>
    </div>
</div>

<script src="js/app.js"></script>
<script>
let records = [];

async function loadRecords() {
    try {
        const r = await fetch('api/audit?limit=500');
        const j = await r.json();
        if (!j.success) { document.getElementById('tableBody').innerHTML = '<tr><td colspan="8" style="text-align:center;padding:20px;color:#f44336;">Sin acceso</td></tr>'; return; }
        records = j.data || [];
        updateSummary();
        renderTable(records);
    } catch(e) { console.error(e); }
}

function updateSummary() {
    document.getElementById('sTotal').textContent = records.length;
    document.getElementById('sCreate').textContent = records.filter(r => r.accion === 'CREATE').length;
    document.getElementById('sUpdate').textContent = records.filter(r => r.accion === 'UPDATE').length;
    document.getElementById('sDelete').textContent = records.filter(r => r.accion === 'DELETE').length;
    document.getElementById('sLogin').textContent = records.filter(r => r.accion === 'LOGIN').length;
}

function renderTable(data) {
    const tbody = document.getElementById('tableBody');
    document.getElementById('recordCount').textContent = `Mostrando ${data.length} evento(s)`;
    if (!data.length) {
        tbody.innerHTML = '<tr><td colspan="8" style="text-align:center;padding:40px;color:#999;"><i class="fas fa-history" style="font-size:32px;opacity:0.3;display:block;margin-bottom:10px;"></i>Sin eventos registrados</td></tr>';
        return;
    }
    tbody.innerHTML = data.map((r, i) => `
        <tr>
            <td style="color:#999;font-size:12px;">${r.id}</td>
            <td style="font-size:12px;white-space:nowrap;">${r.fechaHora ? new Date(r.fechaHora).toLocaleString('es') : 'â€”'}</td>
            <td><strong>${r.username||'Sistema'}</strong></td>
            <td><span class="action-${r.accion||'UPDATE'}">${r.accion||'â€”'}</span></td>
            <td><code style="font-size:11px;">${r.tabla||'â€”'}</code></td>
            <td style="text-align:center;">${r.registroId||'â€”'}</td>
            <td class="val-cell" title="${r.valorAnterior||''}" onclick="showDetail(${i})">${r.valorAnterior||'<span style="color:#ccc">â€”</span>'}</td>
            <td class="val-cell" title="${r.valorNuevo||''}" onclick="showDetail(${i})">${r.valorNuevo||'<span style="color:#ccc">â€”</span>'}</td>
        </tr>`).join('');
}

function filterTable() {
    const q = document.getElementById('searchInput').value.toLowerCase();
    const ac = document.getElementById('fAccion').value;
    const tb = document.getElementById('fTabla').value;
    renderTable(records.filter(r =>
        (!q || (r.username||'').toLowerCase().includes(q) || (r.tabla||'').toLowerCase().includes(q) || (r.valorNuevo||'').toLowerCase().includes(q)) &&
        (!ac || r.accion === ac) &&
        (!tb || r.tabla === tb)
    ));
}

function showDetail(idx) {
    const r = records[idx];
    if (!r) return;
    document.getElementById('detailBody').innerHTML = `
        <table style="width:100%;font-size:13px;border-collapse:collapse;">
            <tr><td style="padding:6px;color:#888;width:40%;">ID Evento</td><td style="padding:6px;"><strong>${r.id}</strong></td></tr>
            <tr style="background:#f9f9f9;"><td style="padding:6px;color:#888;">Fecha/Hora</td><td style="padding:6px;">${r.fechaHora ? new Date(r.fechaHora).toLocaleString('es') : 'â€”'}</td></tr>
            <tr><td style="padding:6px;color:#888;">Usuario</td><td style="padding:6px;"><strong>${r.username||'Sistema'}</strong></td></tr>
            <tr style="background:#f9f9f9;"><td style="padding:6px;color:#888;">Acción</td><td style="padding:6px;"><span class="action-${r.accion}">${r.accion}</span></td></tr>
            <tr><td style="padding:6px;color:#888;">Tabla</td><td style="padding:6px;"><code>${r.tabla}</code></td></tr>
            <tr style="background:#f9f9f9;"><td style="padding:6px;color:#888;">Registro ID</td><td style="padding:6px;">${r.registroId||'â€”'}</td></tr>
            <tr><td style="padding:6px;color:#888;">Valor Anterior</td><td style="padding:6px;word-break:break-all;">${r.valorAnterior||'<span style="color:#ccc">â€”</span>'}</td></tr>
            <tr style="background:#f9f9f9;"><td style="padding:6px;color:#888;">Valor Nuevo</td><td style="padding:6px;word-break:break-all;">${r.valorNuevo||'<span style="color:#ccc">â€”</span>'}</td></tr>
            <tr><td style="padding:6px;color:#888;">IP</td><td style="padding:6px;">${r.ipAddress||'â€”'}</td></tr>
        </table>`;
    document.getElementById('detailModal').classList.add('show');
}

function exportCSV() {
    const headers = ['ID','Fecha/Hora','Usuario','Acción','Tabla','Registro ID','Valor Anterior','Valor Nuevo'];
    const rows = records.map(r => [r.id, r.fechaHora||'', r.username||'', r.accion||'', r.tabla||'', r.registroId||'', r.valorAnterior||'', r.valorNuevo||''].map(v=>`"${String(v).replace(/"/g,'""')}"`).join(','));
    const csv = '\uFEFF' + [headers.join(','), ...rows].join('\n');
    const a = document.createElement('a'); a.href = URL.createObjectURL(new Blob([csv],{type:'text/csv;charset=utf-8;'})); a.download='auditoria.csv'; a.click();
}

document.addEventListener('DOMContentLoaded', loadRecords);
</script>
</body>
</html>
