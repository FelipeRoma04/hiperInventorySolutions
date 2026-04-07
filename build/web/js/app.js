// ===== SIDEBAR TOGGLE =====
document.addEventListener('DOMContentLoaded', function() {
    const hamburger = document.querySelector('.hamburger');
    const sidebar = document.querySelector('.sidebar');
    const mainLayout = document.querySelector('.main-layout');

    if (hamburger) {
        hamburger.addEventListener('click', function(e) {
            e.stopPropagation();
            sidebar.classList.toggle('collapsed');
            mainLayout.classList.toggle('sidebar-collapsed');
            localStorage.setItem('sidebarCollapsed', sidebar.classList.contains('collapsed'));
        });
    }

    // Restore sidebar state
    const sidebarCollapsed = localStorage.getItem('sidebarCollapsed') === 'true';
    if (sidebarCollapsed && sidebar) {
        sidebar.classList.add('collapsed');
        mainLayout.classList.add('sidebar-collapsed');
    }

    // Hacer que el menú se cierre en móvil al hacer clic en un enlace
    const sidebarLinks = document.querySelectorAll('.sidebar-nav a');
    sidebarLinks.forEach(link => {
        link.addEventListener('click', function() {
            if (window.innerWidth <= 768) {
                sidebar.classList.add('collapsed');
                mainLayout.classList.add('sidebar-collapsed');
            }
        });
    });

    // Inicializar todas las funcionalidades
    initSearch();
    initTableSort();
    initBulkSelection();
    initFilters();
});

// ===== SEARCH FUNCTIONALITY =====
function initSearch() {
    const searchInput = document.querySelector('.search-box input');
    if (!searchInput) return;

    searchInput.addEventListener('input', function(e) {
        const query = e.target.value.toLowerCase().trim();
        const tableRows = document.querySelectorAll('tbody tr');
        
        tableRows.forEach(row => {
            const text = row.textContent.toLowerCase();
            row.style.display = text.includes(query) ? '' : 'none';
        });
    });
}

// ===== TABLE SORTING =====
function initTableSort() {
    const headers = document.querySelectorAll('table th[onclick*="sort"]');
    headers.forEach((header, index) => {
        header.style.cursor = 'pointer';
        header.addEventListener('click', function() {
            const table = header.closest('table');
            const tbody = table.querySelector('tbody');
            const rows = Array.from(tbody.querySelectorAll('tr'));
            
            const isAscending = header.classList.contains('sort-asc');
            
            rows.sort((a, b) => {
                const aVal = a.querySelectorAll('td')[index]?.textContent.trim() || '';
                const bVal = b.querySelectorAll('td')[index]?.textContent.trim() || '';
                
                const aNum = parseFloat(aVal);
                const bNum = parseFloat(bVal);
                
                if (!isNaN(aNum) && !isNaN(bNum)) {
                    return isAscending ? bNum - aNum : aNum - bNum;
                } else {
                    return isAscending ? bVal.localeCompare(aVal) : aVal.localeCompare(bVal);
                }
            });
            
            // Update header view
            document.querySelectorAll('table th').forEach(h => {
                h.classList.remove('sort-asc', 'sort-desc');
            });
            header.classList.add(isAscending ? 'sort-desc' : 'sort-asc');
            
            // Re-insert rows
            rows.forEach(row => tbody.appendChild(row));
        });
    });
}

// ===== MODAL HANDLING =====
function openModal(modalId) {
    const modal = document.getElementById(modalId);
    if (modal) {
        modal.classList.add('show');
        modal.style.display = 'flex';
    }
}

function closeModal(modalId) {
    const modal = document.getElementById(modalId);
    if (modal) {
        modal.classList.remove('show');
        modal.style.display = 'none';
    }
}

// Close modal when clicking outside content
document.addEventListener('click', function(e) {
    if (e.target.classList.contains('modal')) {
        e.target.classList.remove('show');
        e.target.style.display = 'none';
    }
});

// Close modal with X button
document.querySelectorAll('.modal-close').forEach(btn => {
    btn.addEventListener('click', function() {
        const modal = this.closest('.modal');
        if (modal) {
            modal.classList.remove('show');
            modal.style.display = 'none';
        }
    });
});

// ===== IMAGE UPLOAD FUNCTIONALITY =====
function setupImageUpload(inputId, previewId) {
    const input = document.getElementById(inputId);
    const preview = document.getElementById(previewId);
    
    if (!input) return;
    
    input.addEventListener('change', function(e) {
        const file = e.target.files[0];
        if (file) {
            const reader = new FileReader();
            reader.onload = function(e) {
                if (preview) {
                    const img = document.createElement('img');
                    img.src = e.target.result;
                    img.className = 'preview-image';
                    preview.innerHTML = '';
                    preview.appendChild(img);
                }
            };
            reader.readAsDataURL(file);
        }
    });
}

// ===== DRAG & DROP UPLOAD =====
function setupDragDrop(dropZoneId, inputId) {
    const dropZone = document.getElementById(dropZoneId);
    const input = document.getElementById(inputId);
    
    if (!dropZone || !input) return;
    
    ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
        dropZone.addEventListener(eventName, preventDefaults, false);
    });
    
    function preventDefaults(e) {
        e.preventDefault();
        e.stopPropagation();
    }
    
    ['dragenter', 'dragover'].forEach(eventName => {
        dropZone.addEventListener(eventName, () => {
            dropZone.style.backgroundColor = '#f0f0f0';
            dropZone.style.borderColor = '#764ba2';
        }, false);
    });
    
    ['dragleave', 'drop'].forEach(eventName => {
        dropZone.addEventListener(eventName, () => {
            dropZone.style.backgroundColor = '#f9f9f9';
            dropZone.style.borderColor = '#667eea';
        }, false);
    });
    
    dropZone.addEventListener('drop', (e) => {
        const dt = e.dataTransfer;
        const files = dt.files;
        input.files = files;
        
        // Trigger change event
        const event = new Event('change', { bubbles: true });
        input.dispatchEvent(event);
    }, false);
}

// ===== BULK CHECKBOX SELECTION =====
function initBulkSelection() {
    const selectAllCheckbox = document.getElementById('select-all');
    const rowCheckboxes = document.querySelectorAll('.row-checkbox');
    const bulkActions = document.querySelector('.action-buttons');
    
    if (!selectAllCheckbox) return;
    
    selectAllCheckbox.addEventListener('change', function() {
        rowCheckboxes.forEach(cb => {
            cb.checked = this.checked;
        });
        updateBulkActionsVisibility();
    });
    
    rowCheckboxes.forEach(cb => {
        cb.addEventListener('change', function() {
            const allChecked = Array.from(rowCheckboxes).every(c => c.checked);
            const someChecked = Array.from(rowCheckboxes).some(c => c.checked);
            
            selectAllCheckbox.checked = allChecked;
            selectAllCheckbox.indeterminate = someChecked && !allChecked;
            updateBulkActionsVisibility();
        });
    });
}

function updateBulkActionsVisibility() {
    const checkedCount = document.querySelectorAll('.row-checkbox:checked').length;
    const bulkActions = document.querySelector('.action-buttons');
    const counter = document.querySelector('.selected-count');
    
    if (counter) {
        counter.textContent = checkedCount > 0 ? `${checkedCount} seleccionado(s)` : '';
    }
    
    if (bulkActions) {
        bulkActions.style.opacity = checkedCount > 0 ? '1' : '0.5';
        bulkActions.style.pointerEvents = checkedCount > 0 ? 'auto' : 'none';
    }
}

function getSelectedAssets() {
    return Array.from(document.querySelectorAll('.row-checkbox:checked')).map(cb => cb.dataset.assetId);
}

function deleteSelectedAssets() {
    const selected = getSelectedAssets();
    if (selected.length === 0) {
        alert('Por favor selecciona al menos un activo');
        return;
    }
    
    if (confirm(`¿Estás seguro que deseas eliminar ${selected.length} activo(s)?`)) {
        // Aquí se enviaría la solicitud al servidor
        console.log('Eliminar:', selected);
        alert('Activos eliminados correctamente');
        location.reload();
    }
}

function exportSelected() {
    const selected = getSelectedAssets();
    if (selected.length === 0) {
        alert('Por favor selecciona al menos un activo');
        return;
    }
    
    // Crear CSV
    let csv = 'ID,Nombre,Categoría,Estado,Ubicación\n';
    document.querySelectorAll('.row-checkbox:checked').forEach(cb => {
        const row = cb.closest('tr');
        const cells = row.querySelectorAll('td');
        csv += Array.from(cells).map((cell, i) => {
            if (i === 0) return ''; // Skip checkbox
            return cell.textContent.trim();
        }).join(',') + '\n';
    });
    
    // Descargar
    const blob = new Blob([csv], { type: 'text/csv' });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `activos-${new Date().getTime()}.csv`;
    a.click();
}

// ===== FILTER FUNCTIONALITY =====
function initFilters() {
    const filterSelects = document.querySelectorAll('.filter-select');
    
    filterSelects.forEach(select => {
        select.addEventListener('change', applyFilters);
    });
}

function applyFilters() {
    const categoryFilter = document.querySelector('[name="category-filter"]')?.value || '';
    const statusFilter = document.querySelector('[name="status-filter"]')?.value || '';
    const locationFilter = document.querySelector('[name="location-filter"]')?.value || '';
    const dateFilter = document.querySelector('[name="date-filter"]')?.value || '';
    
    const rows = document.querySelectorAll('tbody tr');
    
    rows.forEach(row => {
        let show = true;
        
        if (categoryFilter) {
            const categoryCellValue = row.querySelector('[data-category]')?.textContent || '';
            show = show && categoryCellValue.includes(categoryFilter);
        }
        
        if (statusFilter) {
            const statusBadge = row.querySelector('.badge');
            show = show && statusBadge && statusBadge.textContent.includes(statusFilter);
        }
        
        if (locationFilter) {
            const locationCellValue = row.querySelector('[data-location]')?.textContent || '';
            show = show && locationCellValue.includes(locationFilter);
        }
        
        row.style.display = show ? '' : 'none';
    });
}

// ===== PASSWORD VALIDATION =====
function validatePassword(password) {
    const requirements = {
        length: password.length >= 8,
        uppercase: /[A-Z]/.test(password),
        lowercase: /[a-z]/.test(password),
        number: /\d/.test(password)
    };
    
    return requirements;
}

function updatePasswordStrength(password) {
    const requirements = validatePassword(password);
    const strengthMeter = document.querySelector('.password-strength');
    
    if (!strengthMeter) return;
    
    const passCount = Object.values(requirements).filter(Boolean).length;
    const strength = (passCount / 4) * 100;
    
    strengthMeter.style.width = strength + '%';
    strengthMeter.style.backgroundColor = 
        passCount < 2 ? '#f44336' :
        passCount < 3 ? '#ff9800' :
        passCount < 4 ? '#ffc107' : '#4caf50';
}

// ===== TOAST NOTIFICATIONS =====
function showToast(message, type = 'info') {
    const toast = document.createElement('div');
    toast.className = `alert alert-${type}`;
    toast.textContent = message;
    toast.style.position = 'fixed';
    toast.style.top = '20px';
    toast.style.right = '20px';
    toast.style.zIndex = '9999';
    toast.style.minWidth = '300px';
    
    document.body.appendChild(toast);
    
    setTimeout(() => {
        toast.style.opacity = '0';
        toast.style.transition = 'opacity 0.3s';
        setTimeout(() => toast.remove(), 300);
    }, 3000);
}

// ===== RESPONSIVE SIDEBAR ON MOBILE =====
window.addEventListener('resize', function() {
    const sidebar = document.querySelector('.sidebar');
    const mainLayout = document.querySelector('.main-layout');
    
    if (window.innerWidth > 768) {
        if (sidebar && mainLayout) {
            sidebar.classList.remove('collapsed');
            mainLayout.classList.remove('sidebar-collapsed');
        }
    }
});

    if (selectAllCheckbox) {
        selectAllCheckbox.addEventListener('change', function() {
            rowCheckboxes.forEach(checkbox => {
                checkbox.checked = this.checked;
            });
            updateBulkActionsVisibility();
        });
    }

    rowCheckboxes.forEach(checkbox => {
        checkbox.addEventListener('change', function() {
            updateBulkActionsVisibility();
        });
    });
}

/* ============================================
   FASE 2: NUEVAS FUNCIONALIDADES
   ============================================ */

// ===== QR CODE GENERATION =====
function generateQRCode(assetId, assetName) {
    const qrContainer = document.getElementById('qr-container');
    if (!qrContainer) return;
    
    // Simple QR generation using canvas
    const canvas = document.createElement('canvas');
    canvas.width = 300;
    canvas.height = 300;
    const ctx = canvas.getContext('2d');
    
    // Draw QR border
    ctx.fillStyle = '#ffffff';
    ctx.fillRect(0, 0, 300, 300);
    
    // Create simple QR-like pattern (simulated)
    ctx.fillStyle = '#000000';
    const text = `Asset:${assetId}|Name:${assetName}`;
    const hash = Math.abs(text.split('').reduce((a, b) => a + b.charCodeAt(0), 0));
    
    for (let i = 0; i < 15; i++) {
        for (let j = 0; j < 15; j++) {
            if (((hash >> (i * 4 + j)) & 1) === 1) {
                ctx.fillRect(20 + i * 18, 20 + j * 18, 15, 15);
            }
        }
    }
    
    // Add text below
    ctx.fillStyle = '#000000';
    ctx.font = 'bold 14px Arial';
    ctx.textAlign = 'center';
    ctx.fillText(assetId, 150, 280);
    
    qrContainer.innerHTML = '';
    qrContainer.appendChild(canvas);
}

function downloadQRCode(assetId) {
    const canvas = document.querySelector('#qr-container canvas');
    if (!canvas) return;
    
    const image = canvas.toDataURL('image/png');
    const link = document.createElement('a');
    link.href = image;
    link.download = `qr-${assetId}.png`;
    link.click();
}

function printQRCodes() {
    const selected = getSelectedAssets();
    if (selected.length === 0) {
        showToast('Selecciona al menos un activo para imprimir', 'warning');
        return;
    }
    
    let printContent = '<html><head><title>Códigos QR</title></head><body>';
    printContent += '<h2>Códigos QR para Imprimir</h2>';
    
    selected.forEach(assetId => {
        printContent += `<div style="page-break-inside: avoid; margin: 20px; text-align: center;">`;
        printContent += `<canvas id="qr-${assetId}"></canvas>`;
        printContent += `<p>${assetId}</p></div>`;
    });
    
    printContent += '</body></html>';
    
    const printWindow = window.open('', '', 'width=800,height=600');
    printWindow.document.write(printContent);
    printWindow.print();
}

// ===== NOTIFICATIONS SYSTEM =====
class NotificationManager {
    constructor() {
        this.notifications = [
            {
                id: 1,
                title: 'Stock Bajo',
                message: 'Cable de red con stock bajo',
                type: 'warning',
                time: 'Hace 5 min',
                read: false
            },
            {
                id: 2,
                title: 'Activo Devuelto',
                message: 'Laptop ACT-001 ha sido devuelta',
                type: 'success',
                time: 'Hace 2 horas',
                read: false
            },
            {
                id: 3,
                title: 'Mantenimiento Próximo',
                message: 'Impresora requires maintenance',
                type: 'info',
                time: 'Hace 1 día',
                read: true
            }
        ];
    }
    
    getUnreadCount() {
        return this.notifications.filter(n => !n.read).length;
    }
    
    markAsRead(id) {
        const notif = this.notifications.find(n => n.id === id);
        if (notif) notif.read = true;
        this.render();
    }
    
    clearAll() {
        this.notifications = [];
        this.render();
    }
    
    addNotification(title, message, type = 'info') {
        this.notifications.unshift({
            id: Date.now(),
            title,
            message,
            type,
            time: 'Ahora',
            read: false
        });
        this.updateBadge();
        showToast(message, type);
    }
    
    updateBadge() {
        const badge = document.querySelector('.notification-badge');
        const count = this.getUnreadCount();
        if (badge) {
            badge.textContent = count;
            badge.style.display = count > 0 ? 'flex' : 'none';
        }
    }
    
    render() {
        const container = document.querySelector('.notification-center');
        if (!container) return;
        
        let html = '<div class="notification-header">';
        html += '<h3>Notificaciones</h3>';
        html += '<button class="clear-notifications" onclick="notificationManager.clearAll()">Limpiar</button>';
        html += '</div>';
        
        this.notifications.forEach(notif => {
            const iconClass = notif.type === 'warning' ? 'fa-exclamation' : 
                             notif.type === 'success' ? 'fa-check' : 'fa-info-circle';
            
            html += `<div class="notification-item ${notif.read ? '' : 'unread'}" onclick="notificationManager.markAsRead(${notif.id})">`;
            html += `<div class="notification-icon ${notif.type}"><i class="fas ${iconClass}"></i></div>`;
            html += `<div class="notification-content">`;
            html += `<div class="notification-title">${notif.title}</div>`;
            html += `<div class="notification-message">${notif.message}</div>`;
            html += `<div class="notification-time">${notif.time}</div>`;
            html += `</div></div>`;
        });
        
        container.innerHTML = html;
        this.updateBadge();
    }
}

const notificationManager = new NotificationManager();

// ===== USER PROFILE DROPDOWN =====
function initUserMenuDropdown() {
    const userMenu = document.querySelector('.user-menu');
    const dropdown = document.querySelector('.dropdown-menu');
    
    if (!userMenu || !dropdown) return;
    
    userMenu.addEventListener('click', function(e) {
        e.stopPropagation();
        dropdown.classList.toggle('show');
    });
    
    document.addEventListener('click', function() {
        if (dropdown) dropdown.classList.remove('show');
    });
    
    // Setup dropdown items
    setupDropdownItems();
}

function setupDropdownItems() {
    const editProfileBtn = document.querySelector('[data-action="edit-profile"]');
    const changePasswordBtn = document.querySelector('[data-action="change-password"]');
    const logoutBtn = document.querySelector('[data-action="logout"]');
    
    if (editProfileBtn) {
        editProfileBtn.addEventListener('click', () => {
            openModal('profileModal');
            closeUserDropdown();
        });
    }
    
    if (changePasswordBtn) {
        changePasswordBtn.addEventListener('click', () => {
            openModal('changePasswordModal');
            closeUserDropdown();
        });
    }
}

function closeUserDropdown() {
    const dropdown = document.querySelector('.dropdown-menu');
    if (dropdown) dropdown.classList.remove('show');
}

// ===== STOCK ALERTS =====
class StockAlertManager {
    constructor() {
        this.alerts = [
            { assetId: 'ACT-006', name: 'Cable de Red Cat6', stock: 2, minStock: 5, status: 'critical' }
        ];
    }
    
    checkStocks() {
        const container = document.querySelector('.stock-alerts-container');
        if (!container) return;
        
        let html = '';
        this.alerts.forEach(alert => {
            html += `
                <div class="low-stock-alert">
                    <div class="low-stock-icon"><i class="fas fa-exclamation-triangle"></i></div>
                    <div class="low-stock-content">
                        <h4>${alert.name}</h4>
                        <p>Stock actual: ${alert.stock} | Mínimo requerido: ${alert.minStock}</p>
                    </div>
                    <button class="btn btn-primary btn-small" onclick="openModal('restockModal')">
                        <i class="fas fa-plus"></i> Reponer
                    </button>
                </div>
            `;
        });
        
        container.innerHTML = html || '<p style="text-align: center; color: #999;">Sin alertas de stock</p>';
    }
    
    addAlert(assetId, name, stock, minStock) {
        this.alerts.push({ assetId, name, stock, minStock, status: 'critical' });
        this.checkStocks();
        notificationManager.addNotification('Alerta de Stock', `${name} tiene stock bajo`, 'warning');
    }
}

const stockAlertManager = new StockAlertManager();

// ===== EXPORT TO EXCEL & PDF =====
function exportToExcel() {
    let csv = 'Código,Nombre,Categoría,Ubicación,Estado,Valor\n';
    
    document.querySelectorAll('tbody tr:visible').forEach(row => {
        const cells = row.querySelectorAll('td');
        let rowData = [];
        
        cells.forEach((cell, i) => {
            if (i !== 0 && i !== 7) { // Skip checkbox and actions
                rowData.push('"' + cell.textContent.trim() + '"');
            }
        });
        
        csv += rowData.join(',') + '\n';
    });
    
    const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    const url = URL.createObjectURL(blob);
    
    link.setAttribute('href', url);
    link.setAttribute('download', `activos-${new Date().toLocaleDateString()}.csv`);
    link.style.visibility = 'hidden';
    
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    
    showToast('Archivo Excel exportado correctamente', 'success');
}

function exportToPDF() {
    let content = 'REPORTE DE ACTIVOS\n';
    content += 'Fecha: ' + new Date().toLocaleDateString() + '\n\n';
    
    document.querySelectorAll('tbody tr:visible').forEach(row => {
        const cells = row.querySelectorAll('td');
        content += cells[1].textContent + ' - ' + cells[2].textContent + '\n';
    });
    
    // Simple text-based PDF simulation (en producción usar jspdf)
    const blob = new Blob([content], { type: 'text/plain' });
    const link = document.createElement('a');
    const url = URL.createObjectURL(blob);
    
    link.href = url;
    link.download = `activos-${new Date().getTime()}.txt`;
    link.click();
    
    showToast('Reporte PDF generado (modo texto)', 'success');
}

// ===== ASSET ASSIGNMENT =====
function assignAsset(assetId, userId, returnDate) {
    const assignmentData = {
        assetId,
        userId,
        assignedDate: new Date().toLocaleDateString(),
        returnDate
    };
    
    console.log('Asignando activo:', assignmentData);
    
    // Aquí se enviaría al servidor
    showToast('Activo asignado correctamente', 'success');
    closeModal('assignmentModal');
}

function recordAssetReturn(assetId) {
    if (confirm('¿Confirmar devolución del activo?')) {
        console.log('Activo devuelto:', assetId);
        showToast('Activo devuelto correctamente', 'success');
        notificationManager.addNotification('Activo Devuelto', `Activo ${assetId} ha sido devuelto`, 'success');
    }
}

// ===== ROLES & PERMISSIONS =====
class RoleManager {
    constructor() {
        this.userRole = localStorage.getItem('userRole') || 'viewer';
        this.permissions = {
            admin: ['view', 'create', 'edit', 'delete', 'export', 'manage-users'],
            editor: ['view', 'create', 'edit', 'export'],
            viewer: ['view']
        };
    }
    
    hasPermission(permission) {
        return this.permissions[this.userRole]?.includes(permission) || false;
    }
    
    canEdit() { return this.hasPermission('edit'); }
    canDelete() { return this.hasPermission('delete'); }
    canExport() { return this.hasPermission('export'); }
    canManageUsers() { return this.hasPermission('manage-users'); }
    
    applyPermissions() {
        // Hide delete buttons for non-admins
        if (!this.canDelete()) {
            document.querySelectorAll('.btn-delete-bulk').forEach(btn => {
                btn.style.display = 'none';
            });
        }
        
        // Hide user management for non-admins
        if (!this.canManageUsers()) {
            const usersLink = document.querySelector('a[href="usuarios.jsp"]');
            if (usersLink) usersLink.parentElement.style.display = 'none';
        }
        
        // Hide categories edit for non-admins  
        if (!this.hasPermission('manage-categories')) {
            const categoriesLink = document.querySelector('a[href="categorias.jsp"]');
            if (categoriesLink) {
                const editBtn = categoriesLink.querySelector('.btn-edit');
                if (editBtn) editBtn.style.display = 'none';
            }
        }
    }
}

const roleManager = new RoleManager();

// ===== TABS FUNCTIONALITY =====
function initTabs() {
    const tabButtons = document.querySelectorAll('.tab-button');
    const tabContents = document.querySelectorAll('.tab-content');
    
    tabButtons.forEach((button, index) => {
        button.addEventListener('click', function() {
            // Remove active class from all
            tabButtons.forEach(btn => btn.classList.remove('active'));
            tabContents.forEach(content => content.classList.remove('active'));
            
            // Add active class to clicked
            this.classList.add('active');
            if (tabContents[index]) {
                tabContents[index].classList.add('active');
            }
        });
    });
}

// ===== INITIALIZE PHASE 2 ON PAGE LOAD =====
document.addEventListener('DOMContentLoaded', function() {
    initUserMenuDropdown();
    stockAlertManager.checkStocks();
    notificationManager.render();
    roleManager.applyPermissions();
    initTabs();
    
    // Add notification bell click handler
    const bellIcon = document.querySelector('.notification-bell');
    if (bellIcon) {
        bellIcon.addEventListener('click', function(e) {
            e.stopPropagation();
            const center = document.querySelector('.notification-center');
            if (center) center.classList.toggle('show');
        });
    }
});

function getSelectedAssets() {
    const checkboxes = document.querySelectorAll('.row-checkbox:checked');
    return Array.from(checkboxes).map(cb => cb.dataset.assetId);
}

function updateBulkActionsVisibility() {
    const selected = getSelectedAssets();
    const bulkActions = document.querySelector('.bulk-actions');
    if (bulkActions) {
        bulkActions.style.display = selected.length > 0 ? 'flex' : 'none';
    }
}

// ===== PAGINATION =====
function initPagination() {
    const pagButtons = document.querySelectorAll('.pagination button');
    pagButtons.forEach(button => {
        button.addEventListener('click', function() {
            // Remove active class from all buttons
            pagButtons.forEach(btn => btn.classList.remove('active'));
            // Add active class to clicked button
            this.classList.add('active');
        });
    });
}

// ===== TOAST NOTIFICATIONS =====
function showToast(message, type = 'info') {
    const toast = document.createElement('div');
    toast.className = `alert alert-${type}`;
    toast.textContent = message;
    toast.style.position = 'fixed';
    toast.style.top = '20px';
    toast.style.right = '20px';
    toast.style.zIndex = '3000';
    toast.style.maxWidth = '400px';

    document.body.appendChild(toast);

    setTimeout(() => {
        toast.style.animation = 'fadeOut 0.3s ease';
        setTimeout(() => toast.remove(), 300);
    }, 4000);
}

// ===== FORM VALIDATION =====
function validateForm(formId) {
    const form = document.getElementById(formId);
    const requiredFields = form.querySelectorAll('[required]');
    let isValid = true;

    requiredFields.forEach(field => {
        if (!field.value.trim()) {
            field.classList.add('error');
            isValid = false;
        } else {
            field.classList.remove('error');
        }
    });

    return isValid;
}

// ===== IMAGE PREVIEW =====
function previewImage(inputId, previewId) {
    const input = document.getElementById(inputId);
    const preview = document.getElementById(previewId);

    input.addEventListener('change', function() {
        const file = this.files[0];
        if (file) {
            const reader = new FileReader();
            reader.onload = function(e) {
                preview.src = e.target.result;
                preview.style.display = 'block';
            };
            reader.readAsDataURL(file);
        }
    });
}

// ===== UTILITY FUNCTIONS =====
function formatDate(date) {
    return new Date(date).toLocaleDateString('es-ES', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit'
    });
}

function formatNumber(num) {
    return new Intl.NumberFormat('es-ES').format(num);
}

// Initialize common features on page load
document.addEventListener('DOMContentLoaded', function() {
    initSearch();
    initTableSort();
    initBulkSelection();
    initPagination();
});

// ===== GLOBAL THEME & COLOR SYSTEM =====
(function applyStoredTheme() {
    var colorMap = {
        purple:  { primary: '#667eea', secondary: '#764ba2', gradient: 'linear-gradient(135deg,#667eea,#764ba2)' },
        blue:    { primary: '#2196f3', secondary: '#1565c0', gradient: 'linear-gradient(135deg,#2196f3,#1565c0)' },
        green:   { primary: '#4caf50', secondary: '#2e7d32', gradient: 'linear-gradient(135deg,#4caf50,#2e7d32)' },
        red:     { primary: '#f44336', secondary: '#b71c1c', gradient: 'linear-gradient(135deg,#f44336,#b71c1c)' },
        orange:  { primary: '#ff9800', secondary: '#e65100', gradient: 'linear-gradient(135deg,#ff9800,#e65100)' },
        teal:    { primary: '#009688', secondary: '#004d40', gradient: 'linear-gradient(135deg,#009688,#004d40)' }
    };

    function applyColors(scheme) {
        var c = colorMap[scheme];
        if (!c) return;
        var r = document.documentElement;
        r.style.setProperty('--color-primary', c.primary);
        r.style.setProperty('--color-secondary', c.secondary);
        // Apply to sidebar
        var sidebar = document.querySelector('.sidebar, .pref-sidebar');
        if (sidebar) sidebar.style.background = c.gradient;
        // Apply to buttons with gradient
        var style = document.getElementById('__theme_style__');
        if (!style) { style = document.createElement('style'); style.id = '__theme_style__'; document.head.appendChild(style); }
        style.textContent =
            '.btn-primary, .btn.btn-primary { background: ' + c.gradient + ' !important; border-color: ' + c.primary + ' !important; }' +
            '.sidebar, .pref-sidebar { background: ' + c.gradient + ' !important; }' +
            '.sidebar-nav a.active, .pref-nav a.active { border-left-color: ' + c.primary + ' !important; }' +
            '.user-avatar { background: ' + c.gradient + ' !important; }' +
            'a { color: ' + c.primary + '; }' +
            '.notification-bell { color: ' + c.primary + ' !important; }';
    }

    function applyDarkTheme(dark) {
        var style = document.getElementById('__dark_style__');
        if (!style) { style = document.createElement('style'); style.id = '__dark_style__'; document.head.appendChild(style); }
        if (dark) {
            style.textContent =
                'body { background: #1a1a2e !important; color: #e0e0e0 !important; }' +
                '.main-content, .content { background: #1a1a2e !important; }' +
                '.card, .table-container, .stat-card, .chart-wrapper, .pref-section { background: #16213e !important; color: #e0e0e0 !important; border-color: #0f3460 !important; }' +
                'table { background: #16213e !important; color: #e0e0e0 !important; }' +
                'th { background: #0f3460 !important; color: #e0e0e0 !important; }' +
                'td { border-color: #0f3460 !important; color: #e0e0e0 !important; }' +
                'tbody tr:hover { background: #0f3460 !important; }' +
                '.topbar, .pref-topbar { background: #16213e !important; color: #e0e0e0 !important; box-shadow: 0 2px 8px rgba(0,0,0,.4) !important; }' +
                '.topbar-title, h2.topbar-title { color: #e0e0e0 !important; }' +
                'input, select, textarea { background: #0f3460 !important; color: #e0e0e0 !important; border-color: #1a4a8a !important; }' +
                '.modal-content { background: #16213e !important; color: #e0e0e0 !important; }' +
                '.modal-header { border-color: #0f3460 !important; }' +
                'label { color: #ccc !important; }' +
                '.search-box input { background: #0f3460 !important; color: #e0e0e0 !important; }' +
                '.filter-select { background: #0f3460 !important; color: #e0e0e0 !important; }';
        } else {
            style.textContent = '';
        }
    }

    // Apply on every page load
    var scheme = localStorage.getItem('colorScheme') || 'purple';
    var dark = localStorage.getItem('theme') === 'dark';
    document.addEventListener('DOMContentLoaded', function() {
        applyColors(scheme);
        applyDarkTheme(dark);
    });

    // Expose globally for preferences page
    window.applyColorScheme = applyColors;
    window.applyDarkMode = applyDarkTheme;
})();
