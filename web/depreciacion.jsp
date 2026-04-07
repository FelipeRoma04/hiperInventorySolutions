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
    <title>Depreciación - HiperInventory</title>
    <link rel="stylesheet" href="css/styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .alert { padding:12px 16px; border-radius:8px; margin-bottom:12px; display:flex; align-items:center; gap:8px; }
        .alert-success { background:#e8f5e9; color:#2e7d32; border-left:4px solid #4caf50; }
        .alert-error { background:#ffebee; color:#c62828; border-left:4px solid #f44336; }
        .btn-small { padding:5px 9px; font-size:12px; }
        .progress-bar-wrap { background:#f0f0f0; border-radius:6px; height:8px; width:100%; min-width:80px; }
        .progress-bar-fill { height:8px; border-radius:6px; background:linear-gradient(90deg,#667eea,#764ba2); transition:width .3s; }
        .summary-cards { display:grid; grid-template-columns:repeat(auto-fit,minmax(200px,1fr)); gap:16px; margin-bottom:24px; }
        .summary-card { background:#fff; border-radius:10px; padding:18px; box-shadow:0 2px 8px rgba(0,0,0,.07); text-align:center; }
        .summary-card .num { font-size:28px; font-weight:700; }
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
        <li><a href="mantenimiento.jsp"><i class="fas fa-tools"></i> Mantenimiento</a></li>
        <li><a href="depreciacion.jsp" class="active"><i class="fas fa-chart-line"></i> Depreciación</a></li>
        <li><a href="auditoria.jsp"><i class="fas fa-history"></i> Auditoría</a></li>
        <li><hr style="border:none;border-top:1px solid rgba(255,255,255,0.1);margin:15px 0;"></li>
        <li><a href="logout.jsp"><i class="fas fa-sign-out-alt"></i> Cerrar Sesión</a></li>
    </ul></nav>
</aside>

<div class="main-layout">
    <header class="topbar">
        <div style="display:flex;align-items:center;gap:15px;">
            <button class="hamburger"><i class="fas fa-bars"></i></button>
            <h2 class="topbar-title">Depreciación de Activos</h2>
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

        <div class="summary-cards">
            <div class="summary-card"><div class="num" id="sTotal" style="color:#667eea;">â€”</div><div class="lbl">Valor Original Total</div></div>
            <div class="summary-card"><div class="num" id="sCurrent" style="color:#4caf50;">â€”</div><div class="lbl">Valor Actual Total</div></div>
            <div class="summary-card"><div class="num" id="sDeprec" style="color:#f44336;">â€”</div><div class="lbl">Depreciación Acumulada</div></div>
            <div class="summary-card"><div class="num" id="sCount" style="color:#ff9800;">â€”</div><div class="lbl">Activos Registrados</div></div>
        </div>

        <div class="table-container">
            <div class="table-controls">
                <div class="search-box">
                    <i class="fas fa-search"></i>
                    <input type="text" id="searchInput" placeholder="Buscar activo..." oninput="filterTable()">
                </div>
                <% if (isEditor) { %>
                <button class="btn btn-primary" onclick="openModal()"><i class="fas fa-plus"></i> Registrar Depreciación</button>
                <% } %>
            </div>

            <table>
                <thead>
                    <tr>
                        <th>Activo</th><th>Precio Compra</th><th>Fecha Compra</th>
                        <th>Vida Ãštil</th><th>Método</th><th>Dep. Mensual</th>
                        <th>Dep. Acumulada</th><th>Valor Actual</th><th>% Depreciado</th>
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
<div class="modal" id="depModal">
    <div class="modal-content" style="max-width:520px;">
        <div class="modal-header">
            <h3 class="modal-title" id="modalTitle">Registrar Depreciación</h3>
            <button class="modal-close" onclick="closeModal()">&times;</button>
        </div>
        <div class="modal-body">
            <input type="hidden" id="dId">
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:16px;">
                <div class="form-group" style="grid-column:1/-1;">
                    <label>Activo *</label>
                    <select id="dAssetId"></select>
                </div>
                <div class="form-group">
                    <label>Precio de Compra ($) *</label>
                    <input type="number" id="dPurchasePrice" value="0" min="0" step="0.01">
                </div>
                <div class="form-group">
                    <label>Valor Residual ($)</label>
                    <input type="number" id="dResidualValue" value="0" min="0" step="0.01">
                </div>
                <div class="form-group">
                    <label>Vida Ãštil (años) *</label>
                    <input type="number" id="dUsefulLife" value="5" min="1" max="50">
                </div>
                <div class="form-group">
                    <label>Fecha de Compra *</label>
                    <input type="date" id="dPurchaseDate">
                </div>
                <div class="form-group" style="grid-column:1/-1;">
                    <label>Método de Depreciación</label>
                    <select id="dMethod">
                        <option value="Linear">Línea Recta</option>
                        <option value="DecreasingBalance">Saldo Decreciente</option>
                    </select>
                </div>
            </div>
            <div id="calcPreview" style="background:#f5f5f5;border-radius:8px;padding:14px;margin-top:8px;font-size:13px;display:none;"></div>
        </div>
        <div class="modal-footer">
            <button class="btn btn-secondary" onclick="closeModal()">Cancelar</button>
            <button class="btn btn-secondary" onclick="previewCalc()"><i class="fas fa-calculator"></i> Calcular</button>
            <button class="btn btn-primary" onclick="saveDeprec()"><i class="fas fa-save"></i> Guardar</button>
        </div>
    </div>
</div>

<script src="js/app.js"></script>
<script>
const IS_EDITOR = <%= isEditor %>;
let records = [], assets = [];

async function init() {
    try {
        const r = await fetch('api/assets'); const j = await r.json();
        assets = j.data || [];
        const sel = document.getElementById('dAssetId');
        assets.forEach(a => { const o = document.createElement('option'); o.value = a.id; o.textContent = `${a.codigo} - ${a.nombre}`; sel.appendChild(o); });
    } catch(e) {}
    await loadRecords();
}

async function loadRecords() {
    try {
        const r = await fetch('api/depreciation'); const j = await r.json();
        records = Array.isArray(j) ? j : [];
        updateSummary();
        renderTable(records);
    } catch(e) { showAlert('Error cargando depreciaciones: ' + e.message, 'error'); }
}

function updateSummary() {
    const totalOrig = records.reduce((s, r) => s + (r.purchasePrice || 0), 0);
    const totalCurr = records.reduce((s, r) => s + (r.currentValue || 0), 0);
    const totalDep = records.reduce((s, r) => s + (r.accumulatedDepreciation || 0), 0);
    document.getElementById('sTotal').textContent = '$' + totalOrig.toLocaleString('es', {maximumFractionDigits:0});
    document.getElementById('sCurrent').textContent = '$' + totalCurr.toLocaleString('es', {maximumFractionDigits:0});
    document.getElementById('sDeprec').textContent = '$' + totalDep.toLocaleString('es', {maximumFractionDigits:0});
    document.getElementById('sCount').textContent = records.length;
}

function renderTable(data) {
    const tbody = document.getElementById('tableBody');
    if (!data.length) {
        tbody.innerHTML = '<tr><td colspan="10" style="text-align:center;padding:40px;color:#999;"><i class="fas fa-chart-line" style="font-size:32px;opacity:0.3;display:block;margin-bottom:10px;"></i>Sin registros de depreciación</td></tr>';
        return;
    }
    tbody.innerHTML = data.map(d => {
        const asset = assets.find(a => a.id === d.assetId);
        const pct = d.purchasePrice > 0 ? Math.min(100, (d.accumulatedDepreciation / d.purchasePrice) * 100) : 0;
        const pctColor = pct > 80 ? '#f44336' : pct > 50 ? '#ff9800' : '#4caf50';
            const methodLabel = d.method === 'Linear' ? 'Línea Recta' : 'Saldo Decreciente';
        return `<tr>
            <td>${asset ? '<strong>' + asset.nombre + '</strong><br><small style="color:#888;">' + asset.codigo + '</small>' : 'ID:' + d.assetId}</td>
            <td>$${(d.purchasePrice||0).toLocaleString('es',{maximumFractionDigits:2})}</td>
            <td>${d.purchaseDate||'â€”'}</td>
            <td>${d.usefulLife||0} años</td>
            <td><span style="font-size:12px;background:#e3f2fd;color:#0d47a1;padding:2px 8px;border-radius:10px;">${methodLabel}</span></td>
            <td>$${(d.monthlyDepreciation||0).toLocaleString('es',{maximumFractionDigits:2})}/mes</td>
            <td>$${(d.accumulatedDepreciation||0).toLocaleString('es',{maximumFractionDigits:2})}</td>
            <td style="font-weight:700;color:${pct>80?'#f44336':pct>50?'#ff9800':'#333'};">$${(d.currentValue||0).toLocaleString('es',{maximumFractionDigits:2})}</td>
            <td>
                <div style="display:flex;align-items:center;gap:8px;">
                    <div class="progress-bar-wrap"><div class="progress-bar-fill" style="width:${pct}%;background:${pctColor};"></div></div>
                    <span style="font-size:12px;color:${pctColor};font-weight:600;">${pct.toFixed(1)}%</span>
                </div>
            </td>
            ${IS_EDITOR ? `<td><button class="btn btn-secondary btn-small" onclick="editRecord(${d.id})"><i class="fas fa-edit"></i></button></td>` : ''}
        </tr>`;
    }).join('');
}

function filterTable() {
    const q = document.getElementById('searchInput').value.toLowerCase();
    renderTable(records.filter(d => {
        const asset = assets.find(a => a.id === d.assetId);
        return !q || (asset?.nombre||'').toLowerCase().includes(q) || (asset?.codigo||'').toLowerCase().includes(q);
    }));
}

function openModal() {
    document.getElementById('dId').value = '';
    document.getElementById('dPurchasePrice').value = '0';
    document.getElementById('dResidualValue').value = '0';
    document.getElementById('dUsefulLife').value = '5';
    document.getElementById('dPurchaseDate').value = new Date().toISOString().split('T')[0];
    document.getElementById('dMethod').value = 'Linear';
    document.getElementById('calcPreview').style.display = 'none';
    document.getElementById('modalTitle').textContent = 'Registrar Depreciación';
    document.getElementById('depModal').classList.add('show');
}

function editRecord(id) {
    const d = records.find(x => x.id === id);
    if (!d) return;
    document.getElementById('dId').value = d.id;
    document.getElementById('dAssetId').value = d.assetId;
    document.getElementById('dPurchasePrice').value = d.purchasePrice || 0;
    document.getElementById('dResidualValue').value = d.residualValue || 0;
    document.getElementById('dUsefulLife').value = d.usefulLife || 5;
    document.getElementById('dPurchaseDate').value = d.purchaseDate || '';
    document.getElementById('dMethod').value = d.method || 'Linear';
    document.getElementById('calcPreview').style.display = 'none';
    document.getElementById('modalTitle').textContent = 'Editar Depreciación';
    document.getElementById('depModal').classList.add('show');
}

function closeModal() { document.getElementById('depModal').classList.remove('show'); }

function previewCalc() {
    const price = parseFloat(document.getElementById('dPurchasePrice').value) || 0;
    const residual = parseFloat(document.getElementById('dResidualValue').value) || 0;
    const life = parseInt(document.getElementById('dUsefulLife').value) || 1;
    const method = document.getElementById('dMethod').value;
    const purchaseDate = document.getElementById('dPurchaseDate').value;

    let monthly, rate;
    if (method == 'Linear') {
        monthly = (price - residual) / (life * 12);
        rate = 100 / (life * 12);
    } else {
        rate = (2.0 / life) * 100;
        monthly = (price * rate) / 100;
    }

    let monthsElapsed = 0;
    if (purchaseDate) {
        const pd = new Date(purchaseDate), now = new Date();
        monthsElapsed = (now.getFullYear() - pd.getFullYear()) * 12 + (now.getMonth() - pd.getMonth());
    }
    const accumulated = method == 'Linear' ? monthly * monthsElapsed : price - (price * Math.pow(1 - rate/100, monthsElapsed/12));
    const current = Math.max(price - accumulated, residual);

    document.getElementById('calcPreview').style.display = 'block';
    document.getElementById('calcPreview').innerHTML = `
        <strong>Vista previa del cálculo:</strong><br>
        Dep. mensual: <strong>$${monthly.toFixed(2)}</strong> &nbsp;|&nbsp;
        Meses transcurridos: <strong>${monthsElapsed}</strong><br>
        Dep. acumulada: <strong>$${accumulated.toFixed(2)}</strong> &nbsp;|&nbsp;
        Valor actual: <strong style="color:#667eea;">$${current.toFixed(2)}</strong>
    `;
}

async function saveDeprec() {
    const id = document.getElementById('dId').value;
    const assetId = document.getElementById('dAssetId').value;
    const purchasePrice = parseFloat(document.getElementById('dPurchasePrice').value);
    const purchaseDate = document.getElementById('dPurchaseDate').value;
    if (!assetId || !purchaseDate || purchasePrice <= 0) { showAlert('Activo, precio y fecha son requeridos', 'error'); return; }

    const body = JSON.stringify({
        assetId: parseInt(assetId),
        purchasePrice,
        residualValue: parseFloat(document.getElementById('dResidualValue').value) || 0,
        usefulLife: parseInt(document.getElementById('dUsefulLife').value) || 5,
        purchaseDate,
        method: document.getElementById('dMethod').value
    });

    const url = id ? `api/depreciation/${id}` : 'api/depreciation';
    const method = id ? 'PUT' : 'POST';
    try {
        const res = await fetch(url, { method, headers: {'Content-Type':'application/json'}, body });
        const json = await res.json();
        if (json.id || json.status) {
            showAlert(id ? 'Actualizado' : 'Registrado', 'success');
            closeModal(); loadRecords();
        } else { showAlert(json.error || 'Error guardando', 'error'); }
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
