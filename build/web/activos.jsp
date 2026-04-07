<%@ page isELIgnored="true"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    if (session.getAttribute("username") == null) { response.sendRedirect("index.jsp?error=session"); return; }
    String username = (String) session.getAttribute("username");
    String userRole = (String) session.getAttribute("userRole");
    boolean isAdmin = "ADMIN".equals(userRole);
    boolean isEditor = isAdmin || "EDITOR".equals(userRole);
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Activos - HiperInventory</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="css/styles.css">
    <script src="js/qrcode.min.js"></script>
    <style>
        .asset-img { width:40px; height:40px; border-radius:6px; object-fit:cover; background:#f0f0f0; }
        .asset-img-placeholder { width:40px; height:40px; border-radius:6px; background:#f0f0f0; display:inline-flex; align-items:center; justify-content:center; color:#ccc; font-size:18px; }
        .btn-small { padding:5px 9px; font-size:12px; }
        .btn-danger { background:#f44336; color:#fff; border:none; border-radius:6px; cursor:pointer; }
        .btn-danger:hover { background:#d32f2f; }
        .alert { padding:12px 16px; border-radius:8px; margin-bottom:12px; display:flex; align-items:center; gap:8px; }
        .alert-success { background:#e8f5e9; color:#2e7d32; border-left:4px solid #4caf50; }
        .alert-error { background:#ffebee; color:#c62828; border-left:4px solid #f44336; }
        .alert-warning { background:#fff3e0; color:#e65100; border-left:4px solid #ff9800; }
        .low-stock-widget { background:#fff3e0; border-left:4px solid #ff9800; border-radius:8px; padding:14px 18px; margin-bottom:20px; display:none; }
        .low-stock-widget.show { display:flex; align-items:center; gap:12px; flex-wrap:wrap; }
        .low-stock-widget strong { color:#e65100; }
        .upload-area { border:2px dashed #667eea; border-radius:8px; padding:24px; text-align:center; cursor:pointer; background:#f9f9f9; transition:all .2s; }
        .upload-area:hover { background:#f0f0f0; }
        .preview-image { max-width:120px; max-height:120px; border-radius:8px; margin-top:10px; }
        .qr-print-area { text-align:center; padding:10px; }
        .assign-history { max-height:200px; overflow-y:auto; }
        .assign-row { padding:8px 0; border-bottom:1px solid #f0f0f0; font-size:13px; }
    </style>
</head>
<body>
<aside class="sidebar">
    <div class="sidebar-header"><h1><i class="fas fa-cube"></i> HiperInventory</h1></div>
    <nav class="sidebar-nav">
        <li><a href="inicio.jsp"><i class="fas fa-chart-line"></i> Dashboard</a></li>
        <li><a href="activos.jsp" class="active"><i class="fas fa-box"></i> Activos</a></li>
        <li><a href="categorias.jsp"><i class="fas fa-tags"></i> Categorías</a></li>
        <li><a href="ubicaciones.jsp"><i class="fas fa-map-marker-alt"></i> Ubicaciones</a></li>
        <li><a href="usuarios.jsp"><i class="fas fa-users"></i> Usuarios</a></li>
        <li><a href="reportes.jsp"><i class="fas fa-file-pdf"></i> Reportes</a></li>
        <li><hr style="border:none;border-top:1px solid rgba(255,255,255,0.1);margin:15px 0;"></li>
        <li><a href="logout.jsp"><i class="fas fa-sign-out-alt"></i> Cerrar Sesión</a></li>
    </nav>
</aside>

<div class="main-layout">
    <header class="topbar">
        <div style="display:flex;align-items:center;gap:15px;">
            <button class="hamburger"><i class="fas fa-bars"></i></button>
            <h2 class="topbar-title">Gestión de Activos</h2>
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

        <!-- STOCK BAJO WIDGET -->
        <div class="low-stock-widget" id="lowStockWidget">
            <i class="fas fa-exclamation-triangle" style="color:#ff9800;font-size:20px;"></i>
            <div><strong>Alerta de Stock Bajo:</strong> <span id="lowStockMsg"></span></div>
            <a href="#" onclick="filterByLowStock()" style="margin-left:auto;color:#e65100;font-size:13px;font-weight:600;">Ver todos</a>
        </div>

        <div class="table-container">
            <div class="table-controls">
                <div class="search-box">
                    <i class="fas fa-search"></i>
                    <input type="text" id="searchInput" placeholder="Buscar por nombre, código..." oninput="filterTable()">
                </div>
                <div class="filters">
                    <select class="filter-select" id="fCategoria" onchange="filterTable()">
                        <option value="">Todas las Categorías</option>
                    </select>
                    <select class="filter-select" id="fEstado" onchange="filterTable()">
                        <option value="">Todos los Estados</option>
                        <option>Operativo</option>
                        <option>En reparación</option>
                        <option>Baja</option>
                        <option>En préstamo</option>
                    </select>
                    <select class="filter-select" id="fUbicacion" onchange="filterTable()">
                        <option value="">Todas las Ubicaciones</option>
                    </select>
                </div>
                <div class="action-buttons" style="display:flex;gap:8px;flex-wrap:wrap;">
                    <button class="btn-bulk btn-delete-bulk" id="btnDeleteBulk" onclick="deleteBulk()" style="display:none;">
                        <i class="fas fa-trash"></i> Eliminar (<span id="selCount">0</span>)
                    </button>
                    <button class="btn-bulk btn-export" id="btnExportBulk" onclick="exportBulk()" style="display:none;">
                        <i class="fas fa-download"></i> Exportar
                    </button>
                    <% if (isEditor) { %>
                    <button class="btn btn-primary" onclick="openCreateModal()">
                        <i class="fas fa-plus"></i> Nuevo Activo
                    </button>
                    <% } %>
                </div>
            </div>

            <table>
                <thead>
                    <tr>
                        <th><input type="checkbox" id="select-all" class="checkbox" onchange="toggleAll(this)"></th>
                        <th>Foto</th>
                        <th>Código</th>
                        <th>Nombre</th>
                        <th>Categoría</th>
                        <th>Ubicación</th>
                        <th>Estado</th>
                        <th>Cantidad</th>
                        <th>Valor</th>
                        <th>Acciones</th>
                    </tr>
                </thead>
                <tbody id="tableBody">
                    <tr><td colspan="10" style="text-align:center;padding:40px;color:#999;">
                        <i class="fas fa-spinner fa-spin"></i> Cargando...
                    </td></tr>
                </tbody>
            </table>
        </div>
    </main>
</div>

<!-- MODAL CREAR/EDITAR ACTIVO -->
<div class="modal" id="assetModal">
    <div class="modal-content" style="max-width:620px;">
        <div class="modal-header">
            <h3 class="modal-title" id="assetModalTitle">Nuevo Activo</h3>
            <button class="modal-close" onclick="closeAssetModal()">&times;</button>
        </div>
        <div class="modal-body">
            <input type="hidden" id="assetId">
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:16px;">
                <div class="form-group">
                    <label>Nombre *</label>
                    <input type="text" id="aNombre" placeholder="Ej: Laptop Dell XPS">
                </div>
                <div class="form-group">
                    <label>Código *</label>
                    <input type="text" id="aCodigo" placeholder="Ej: ACT-001">
                </div>
                <div class="form-group">
                    <label>Categoría *</label>
                    <select id="aCategoria"></select>
                </div>
                <div class="form-group">
                    <label>Estado</label>
                    <select id="aEstado">
                        <option>Operativo</option>
                        <option>En reparación</option>
                        <option>Baja</option>
                        <option>En préstamo</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Ubicación</label>
                    <select id="aUbicacion"></select>
                </div>
                <div class="form-group">
                    <label>Sede</label>
                    <input type="text" id="aSede" placeholder="Ej: Principal">
                </div>
                <div class="form-group">
                    <label>Valor ($)</label>
                    <input type="number" id="aValor" value="0" min="0" step="0.01">
                </div>
                <div class="form-group">
                    <label>Cantidad</label>
                    <input type="number" id="aCantidad" value="1" min="0">
                </div>
                <div class="form-group">
                    <label>Stock Mínimo</label>
                    <input type="number" id="aStockMinimo" value="1" min="0">
                </div>
                <div class="form-group">
                    <label>Responsable</label>
                    <input type="text" id="aResponsable" placeholder="Nombre del responsable">
                </div>
            </div>
            <div class="form-group">
                <label>Descripción</label>
                <textarea id="aDescripcion" rows="2" placeholder="Descripción opcional..."></textarea>
            </div>
            <div class="form-group">
                <label>Foto del Activo</label>
                <div class="upload-area" id="uploadArea" onclick="document.getElementById('photoInput').click()">
                    <i class="fas fa-cloud-upload-alt" style="font-size:28px;color:#667eea;"></i>
                    <p style="margin:8px 0 4px;color:#666;">Haz clic o arrastra una imagen</p>
                    <small style="color:#999;">PNG, JPG (Max 2MB)</small>
                </div>
                <input type="file" id="photoInput" accept="image/*" style="display:none;" onchange="previewPhoto(this)">
                <div id="photoPreview"></div>
            </div>
        </div>
        <div class="modal-footer">
            <button class="btn btn-secondary" onclick="closeAssetModal()">Cancelar</button>
            <button class="btn btn-primary" onclick="saveAsset()"><i class="fas fa-save"></i> Guardar</button>
        </div>
    </div>
</div>

<!-- MODAL QR -->
<div class="modal" id="qrModal">
    <div class="modal-content" style="max-width:360px;">
        <div class="modal-header">
            <h3 class="modal-title">Código QR del Activo</h3>
            <button class="modal-close" onclick="document.getElementById('qrModal').classList.remove('show')">&times;</button>
        </div>
        <div class="modal-body">
            <div class="qr-print-area">
                <div id="qrcode" style="display:inline-block;margin:10px auto;"></div>
                <div id="qrLabel" style="font-size:13px;color:#555;margin-top:8px;"></div>
            </div>
        </div>
        <div class="modal-footer">
            <button class="btn btn-secondary" onclick="document.getElementById('qrModal').classList.remove('show')">Cerrar</button>
            <button class="btn btn-primary" onclick="printQR()"><i class="fas fa-print"></i> Imprimir</button>
        </div>
    </div>
</div>

<!-- MODAL ASIGNACIÃ“N -->
<div class="modal" id="assignModal">
    <div class="modal-content" style="max-width:480px;">
        <div class="modal-header">
            <h3 class="modal-title">Asignar Activo</h3>
            <button class="modal-close" onclick="document.getElementById('assignModal').classList.remove('show')">&times;</button>
        </div>
        <div class="modal-body">
            <input type="hidden" id="assignAssetId">
            <div class="form-group">
                <label>Asignar a (nombre/usuario)</label>
                <input type="text" id="assignTo" placeholder="Nombre del responsable">
            </div>
            <div class="form-group">
                <label>Fecha devolución esperada</label>
                <input type="date" id="assignReturn">
            </div>
            <div class="form-group">
                <label>Notas</label>
                <textarea id="assignNotes" rows="2" placeholder="Notas opcionales..."></textarea>
            </div>
            <div id="assignHistory" class="assign-history" style="margin-top:12px;"></div>
        </div>
        <div class="modal-footer">
            <button class="btn btn-secondary" onclick="document.getElementById('assignModal').classList.remove('show')">Cancelar</button>
            <button class="btn btn-primary" onclick="saveAssignment()"><i class="fas fa-user-check"></i> Asignar</button>
        </div>
    </div>
</div>

<!-- MODAL CONFIRMAR ELIMINAR -->
<div class="modal" id="deleteModal">
    <div class="modal-content" style="max-width:380px;">
        <div class="modal-header">
            <h3 class="modal-title">Confirmar Eliminación</h3>
            <button class="modal-close" onclick="document.getElementById('deleteModal').classList.remove('show')">&times;</button>
        </div>
        <div class="modal-body"><p>Â¿Eliminar el activo <strong id="deleteAssetName"></strong>?</p></div>
        <div class="modal-footer">
            <button class="btn btn-secondary" onclick="document.getElementById('deleteModal').classList.remove('show')">Cancelar</button>
            <button class="btn btn-danger" onclick="confirmDelete()"><i class="fas fa-trash"></i> Eliminar</button>
        </div>
    </div>
</div>

<script src="js/app.js"></script>
<script>
const IS_EDITOR = <%= isEditor %>;
const IS_ADMIN = <%= isAdmin %>;
let allAssets = [];
let deleteAssetId = null;
let currentQrAsset = null;

const statusColors = { 'Operativo':'#4caf50','En reparación':'#ff9800','Baja':'#f44336','En préstamo':'#2196f3' };
const statusBadge = { 'Operativo':'badge-active','En reparación':'badge-repair','Baja':'badge-inactive','En préstamo':'badge-loan' };

async function init() {
    await Promise.all([loadFilters(), loadAssets()]);
}

async function loadFilters() {
    try {
        const [catRes, ubRes] = await Promise.all([fetch('api/categorias'), fetch('api/ubicaciones')]);
        const cats = (await catRes.json()).data || [];
        const ubs = (await ubRes.json()).data || [];
        const fCat = document.getElementById('fCategoria');
        const aCat = document.getElementById('aCategoria');
        cats.forEach(c => {
            [fCat, aCat].forEach(sel => { const o = document.createElement('option'); o.value = c.nombre; o.textContent = c.nombre; sel.appendChild(o); });
        });
        const fUb = document.getElementById('fUbicacion');
        const aUb = document.getElementById('aUbicacion');
        const emptyOpt = document.createElement('option'); emptyOpt.value = ''; emptyOpt.textContent = 'â€” Sin ubicación â€”'; aUb.appendChild(emptyOpt);
        ubs.forEach(u => {
            [fUb, aUb].forEach(sel => { const o = document.createElement('option'); o.value = u.nombre; o.textContent = u.nombre; sel.appendChild(o); });
        });
    } catch(e) {}
}

async function loadAssets() {
    try {
        const [assetsRes, statsRes] = await Promise.all([fetch('api/assets'), fetch('api/assets/stats')]);
        const json = await assetsRes.json();
        allAssets = json.data || [];
        renderTable(allAssets);
        // Low stock check
        const lowRes = await fetch('api/assets/low-stock');
        const lowJson = await lowRes.json();
        const lowItems = lowJson.data || [];
        if (lowItems.length > 0) {
            document.getElementById('lowStockWidget').classList.add('show');
            document.getElementById('lowStockMsg').textContent = `${lowItems.length} activo(s) con stock bajo: ${lowItems.slice(0,3).map(a=>a.nombre).join(', ')}${lowItems.length>3?'...':''}`;
        }
    } catch(e) { showAlert('Error cargando activos: ' + e.message, 'error'); }
}

function renderTable(data) {
    const tbody = document.getElementById('tableBody');
    if (!data.length) {
        tbody.innerHTML = '<tr><td colspan="10" style="text-align:center;padding:40px;color:#999;"><i class="fas fa-box" style="font-size:32px;opacity:0.3;display:block;margin-bottom:10px;"></i>No hay activos</td></tr>';
        return;
    }
    tbody.innerHTML = data.map(a => `
        <tr>
            <td><input type="checkbox" class="checkbox row-checkbox" data-asset-id="${a.id}" onchange="updateBulkButtons()"></td>
            <td>${a.imagenUrl ? `<img src="${a.imagenUrl}" class="asset-img" onerror="this.style.display='none'">` : '<div class="asset-img-placeholder"><i class="fas fa-image"></i></div>'}</td>
            <td><code style="font-size:12px;">${a.codigo||'â€”'}</code></td>
            <td><strong>${a.nombre}</strong>${a.asignadoA?`<br><small style="color:#888;"><i class="fas fa-user"></i> ${a.asignadoA}</small>`:''}</td>
            <td>${a.categoria||'â€”'}</td>
            <td>${a.ubicacion||'â€”'}</td>
            <td><span class="badge ${statusBadge[a.estado]||'badge-active'}">${a.estado||'â€”'}</span></td>
            <td>${a.cantidad||0} ${a.cantidad<=a.stockMinimo?'<i class="fas fa-exclamation-triangle" style="color:#ff9800;" title="Stock bajo"></i>':''}</td>
            <td>$${(a.valor||0).toLocaleString('es')}</td>
            <td style="display:flex;gap:4px;flex-wrap:wrap;">
                <button class="btn btn-secondary btn-small" onclick="openEditModal(${a.id})" title="Editar"><i class="fas fa-edit"></i></button>
                <button class="btn btn-secondary btn-small" onclick="showQR(${a.id})" title="QR"><i class="fas fa-qrcode"></i></button>
                ${IS_EDITOR ? `<button class="btn btn-secondary btn-small" onclick="openAssignModal(${a.id})" title="Asignar"><i class="fas fa-user-check"></i></button>` : ''}
                ${IS_ADMIN ? `<button class="btn btn-danger btn-small" onclick="askDelete(${a.id},'${a.nombre.replace(/'/g,"\\'")}')"><i class="fas fa-trash"></i></button>` : ''}
            </td>
        </tr>`).join('');
}

function filterTable() {
    const q = document.getElementById('searchInput').value.toLowerCase();
    const cat = document.getElementById('fCategoria').value;
    const est = document.getElementById('fEstado').value;
    const ub = document.getElementById('fUbicacion').value;
    renderTable(allAssets.filter(a =>
        (!q || a.nombre.toLowerCase().includes(q) || (a.codigo||'').toLowerCase().includes(q)) &&
        (!cat || a.categoria === cat) &&
        (!est || a.estado === est) &&
        (!ub || a.ubicacion === ub)
    ));
}

function filterByLowStock() {
    renderTable(allAssets.filter(a => a.cantidad <= a.stockMinimo));
}

function toggleAll(cb) {
    document.querySelectorAll('.row-checkbox').forEach(c => c.checked = cb.checked);
    updateBulkButtons();
}

function updateBulkButtons() {
    const count = document.querySelectorAll('.row-checkbox:checked').length;
    document.getElementById('selCount').textContent = count;
    document.getElementById('btnDeleteBulk').style.display = count > 0 && IS_ADMIN ? 'inline-flex' : 'none';
    document.getElementById('btnExportBulk').style.display = count > 0 ? 'inline-flex' : 'none';
    document.getElementById('select-all').indeterminate = count > 0 && count < document.querySelectorAll('.row-checkbox').length;
}

function getSelectedIds() {
    return Array.from(document.querySelectorAll('.row-checkbox:checked')).map(c => parseInt(c.dataset.assetId));
}

async function deleteBulk() {
    const ids = getSelectedIds();
    if (!ids.length) return;
    if (!confirm(`Â¿Eliminar ${ids.length} activo(s) seleccionado(s)?`)) return;
    let ok = 0;
    for (const id of ids) {
        try { const r = await fetch(`api/assets/${id}`, {method:'DELETE'}); if ((await r.json()).success) ok++; } catch(e) {}
    }
    showAlert(`${ok} activo(s) eliminado(s)`, 'success');
    loadAssets();
}

function exportBulk() {
    const ids = getSelectedIds();
    const data = ids.length ? allAssets.filter(a => ids.includes(a.id)) : allAssets;
    const headers = ['Código','Nombre','Categoría','Estado','Ubicación','Cantidad','Valor'];
    const rows = data.map(a => [a.codigo||'',a.nombre||'',a.categoria||'',a.estado||'',a.ubicacion||'',a.cantidad||0,a.valor||0].map(v=>`"${v}"`).join(','));
    const csv = '\uFEFF' + [headers.join(','),...rows].join('\n');
    const a = document.createElement('a'); a.href = URL.createObjectURL(new Blob([csv],{type:'text/csv;charset=utf-8;'})); a.download='activos.csv'; a.click();
}

// ---- CREATE / EDIT ----
function openCreateModal() {
    document.getElementById('assetId').value = '';
    ['aNombre','aCodigo','aSede','aResponsable','aDescripcion'].forEach(id => document.getElementById(id).value = '');
    document.getElementById('aEstado').value = 'Operativo';
    document.getElementById('aValor').value = '0';
    document.getElementById('aCantidad').value = '1';
    document.getElementById('aStockMinimo').value = '1';
    document.getElementById('photoPreview').innerHTML = '';
    document.getElementById('assetModalTitle').textContent = 'Nuevo Activo';
    document.getElementById('assetModal').classList.add('show');
}

function openEditModal(id) {
    const a = allAssets.find(x => x.id === id);
    if (!a) return;
    document.getElementById('assetId').value = a.id;
    document.getElementById('aNombre').value = a.nombre || '';
    document.getElementById('aCodigo').value = a.codigo || '';
    document.getElementById('aCategoria').value = a.categoria || '';
    document.getElementById('aEstado').value = a.estado || 'Operativo';
    document.getElementById('aUbicacion').value = a.ubicacion || '';
    document.getElementById('aSede').value = a.sede || '';
    document.getElementById('aValor').value = a.valor || 0;
    document.getElementById('aCantidad').value = a.cantidad || 1;
    document.getElementById('aStockMinimo').value = a.stockMinimo || 1;
    document.getElementById('aResponsable').value = a.responsable || '';
    document.getElementById('aDescripcion').value = a.descripcion || '';
    document.getElementById('photoPreview').innerHTML = a.imagenUrl ? `<img src="${a.imagenUrl}" class="preview-image">` : '';
    document.getElementById('assetModalTitle').textContent = 'Editar Activo';
    document.getElementById('assetModal').classList.add('show');
}

function closeAssetModal() { document.getElementById('assetModal').classList.remove('show'); }

function previewPhoto(input) {
    const file = input.files[0];
    if (!file) return;
    if (file.size > 2 * 1024 * 1024) { showAlert('La imagen no debe superar 2MB', 'error'); return; }
    const reader = new FileReader();
    reader.onload = e => {
        document.getElementById('photoPreview').innerHTML = `<img src="${e.target.result}" class="preview-image">`;
    };
    reader.readAsDataURL(file);
}

async function saveAsset() {
    const id = document.getElementById('assetId').value;
    const nombre = document.getElementById('aNombre').value.trim();
    const codigo = document.getElementById('aCodigo').value.trim();
    const categoria = document.getElementById('aCategoria').value;
    if (!nombre || !codigo || !categoria) { showAlert('Nombre, código y categoría son requeridos', 'error'); return; }

    const params = new URLSearchParams({
        nombre, codigo, categoria,
        estado: document.getElementById('aEstado').value,
        ubicacion: document.getElementById('aUbicacion').value,
        sede: document.getElementById('aSede').value,
        valor: document.getElementById('aValor').value,
        cantidad: document.getElementById('aCantidad').value,
        stockMinimo: document.getElementById('aStockMinimo').value,
        responsable: document.getElementById('aResponsable').value,
        descripcion: document.getElementById('aDescripcion').value
    });

    // Attach base64 photo if selected
    const photoFile = document.getElementById('photoInput').files[0];
    if (photoFile) {
        const b64 = await toBase64(photoFile);
        params.append('imagenBase64', b64);
    }

    const url = id ? `api/assets/${id}` : 'api/assets';
    const method = id ? 'PUT' : 'POST';
    try {
        const res = await fetch(url, { method, body: params });
        const json = await res.json();
        if (json.success) {
            showAlert(id ? 'Activo actualizado' : 'Activo creado', 'success');
            closeAssetModal();
            document.getElementById('photoInput').value = '';
            loadAssets();
        } else { showAlert(json.message || 'Error guardando', 'error'); }
    } catch(e) { showAlert('Error: ' + e.message, 'error'); }
}

function toBase64(file) {
    return new Promise((resolve, reject) => {
        const reader = new FileReader();
        reader.onload = e => resolve(e.target.result);
        reader.onerror = reject;
        reader.readAsDataURL(file);
    });
}

// ---- QR ----
function showQR(id) {
    const a = allAssets.find(x => x.id === id);
    if (!a) return;
    currentQrAsset = a;
    const container = document.getElementById('qrcode');
    container.innerHTML = '';
    if (typeof QRCode !== 'undefined') {
        new QRCode(container, { text: `ID:${a.id}|COD:${a.codigo}|NOM:${a.nombre}`, width:200, height:200, colorDark:'#333', colorLight:'#fff' });
    } else {
        container.innerHTML = `<div style="width:200px;height:200px;background:#f0f0f0;display:flex;align-items:center;justify-content:center;border-radius:8px;font-size:13px;color:#666;">${a.codigo}</div>`;
    }
    document.getElementById('qrLabel').innerHTML = `<strong>${a.nombre}</strong><br><code>${a.codigo}</code>`;
    document.getElementById('qrModal').classList.add('show');
}

function printQR() {
    if (!currentQrAsset) return;
    const qrHtml = document.getElementById('qrcode').innerHTML;
    const win = window.open('', '_blank');
    win.document.write(`<!DOCTYPE html><html><head><title>QR ${currentQrAsset.codigo}</title>
    <style>body{font-family:Arial;text-align:center;padding:30px;}h3{margin:10px 0 4px;}code{font-size:14px;}</style></head>
    <body><div>${qrHtml}</div><h3>${currentQrAsset.nombre}</h3><code>${currentQrAsset.codigo}</code>
    <script>window.onload=()=>{window.print();}<\/script></body></html>`);
    win.document.close();
}

// ---- ASSIGNMENT ----
function openAssignModal(id) {
    const a = allAssets.find(x => x.id === id);
    if (!a) return;
    document.getElementById('assignAssetId').value = id;
    document.getElementById('assignTo').value = a.asignadoA || '';
    document.getElementById('assignReturn').value = '';
    document.getElementById('assignNotes').value = '';
    document.getElementById('assignHistory').innerHTML = a.asignadoA
        ? `<div class="assign-row"><i class="fas fa-user" style="color:#667eea;"></i> Actualmente asignado a: <strong>${a.asignadoA}</strong></div>`
        : '<div style="color:#999;font-size:13px;">Sin asignación actual</div>';
    document.getElementById('assignModal').classList.add('show');
}

async function saveAssignment() {
    const id = document.getElementById('assignAssetId').value;
    const assignTo = document.getElementById('assignTo').value.trim();
    const params = new URLSearchParams({ asignadoA: assignTo, notas: document.getElementById('assignNotes').value });
    try {
        const res = await fetch(`api/assets/${id}`, { method: 'PUT', body: params });
        const json = await res.json();
        if (json.success) {
            showAlert(assignTo ? `Activo asignado a ${assignTo}` : 'Asignación removida', 'success');
            document.getElementById('assignModal').classList.remove('show');
            loadAssets();
        } else { showAlert(json.message || 'Error', 'error'); }
    } catch(e) { showAlert('Error: ' + e.message, 'error'); }
}

// ---- DELETE ----
function askDelete(id, name) {
    deleteAssetId = id;
    document.getElementById('deleteAssetName').textContent = name;
    document.getElementById('deleteModal').classList.add('show');
}

async function confirmDelete() {
    if (!deleteAssetId) return;
    try {
        const res = await fetch(`api/assets/${deleteAssetId}`, { method: 'DELETE' });
        const json = await res.json();
        if (json.success) {
            showAlert('Activo eliminado', 'success');
            document.getElementById('deleteModal').classList.remove('show');
            deleteAssetId = null;
            loadAssets();
        } else { showAlert(json.message || 'Error', 'error'); }
    } catch(e) { showAlert('Error: ' + e.message, 'error'); }
}

function showAlert(msg, type) {
    const div = document.createElement('div');
    div.className = `alert alert-${type === 'error' ? 'error' : type === 'warning' ? 'warning' : 'success'}`;
    div.innerHTML = `<i class="fas fa-${type === 'error' ? 'exclamation-circle' : 'check-circle'}"></i> ${msg}`;
    document.getElementById('alert-container').appendChild(div);
    setTimeout(() => div.remove(), 4000);
}

document.addEventListener('DOMContentLoaded', init);
</script>
</body>
</html>
