// ===== CHART.JS CONFIGURATION =====
Chart.defaults.font.family = "'Segoe UI', Tahoma, Geneva, Verdana, sans-serif";
Chart.defaults.color = '#666';

const chartColors = {
    primary: '#667eea',
    secondary: '#764ba2',
    success: '#4caf50',
    warning: '#ff9800',
    danger: '#f44336',
    info: '#2196f3',
    palette: ['#667eea', '#764ba2', '#4dd0e1', '#ff9800', '#f44336', '#4caf50', '#2196f3', '#ff6b6b']
};

function initCategoryChart(canvasId, data) {
    const ctx = document.getElementById(canvasId)?.getContext('2d');
    if (!ctx) return;
    new Chart(ctx, {
        type: 'bar',
        data: {
            labels: data.labels,
            datasets: [{
                label: 'Activos',
                data: data.values,
                backgroundColor: chartColors.palette,
                borderColor: '#fff',
                borderWidth: 2,
                borderRadius: 8
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true,
            plugins: { legend: { display: false } },
            scales: {
                y: { beginAtZero: true, grid: { color: 'rgba(0,0,0,0.05)' } },
                x: { grid: { display: false } }
            }
        }
    });
}

function initMovementChart(canvasId, data) {
    const ctx = document.getElementById(canvasId)?.getContext('2d');
    if (!ctx) return;
    new Chart(ctx, {
        type: 'line',
        data: {
            labels: data.labels,
            datasets: [{
                label: 'Activos Registrados',
                data: data.values,
                borderColor: chartColors.primary,
                backgroundColor: 'rgba(102,126,234,0.1)',
                borderWidth: 3,
                fill: true,
                tension: 0.4,
                pointRadius: 6,
                pointBackgroundColor: chartColors.primary,
                pointBorderColor: '#fff',
                pointBorderWidth: 2
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true,
            plugins: { legend: { display: true, position: 'top' } },
            scales: {
                y: { beginAtZero: true, grid: { color: 'rgba(0,0,0,0.05)' } },
                x: { grid: { display: false } }
            }
        }
    });
}

function initStatusChart(canvasId, data) {
    const ctx = document.getElementById(canvasId)?.getContext('2d');
    if (!ctx) return;
    new Chart(ctx, {
        type: 'doughnut',
        data: {
            labels: data.labels,
            datasets: [{
                data: data.values,
                backgroundColor: ['#4caf50','#ff9800','#f44336','#2196f3'],
                borderColor: '#fff',
                borderWidth: 2
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true,
            plugins: { legend: { position: 'bottom', labels: { padding: 15 } } }
        }
    });
}

function initValueChart(canvasId, data) {
    const ctx = document.getElementById(canvasId)?.getContext('2d');
    if (!ctx) return;
    new Chart(ctx, {
        type: 'bar',
        data: {
            labels: data.labels,
            datasets: [{
                label: 'Valor Total ($)',
                data: data.values,
                backgroundColor: chartColors.secondary,
                borderColor: '#fff',
                borderWidth: 2,
                borderRadius: 8
            }]
        },
        options: {
            indexAxis: 'y',
            responsive: true,
            maintainAspectRatio: true,
            plugins: { legend: { display: false } },
            scales: {
                x: { beginAtZero: true, grid: { color: 'rgba(0,0,0,0.05)' } },
                y: { grid: { display: false } }
            }
        }
    });
}

// ===== LOAD REAL DATA FROM API =====
async function loadDashboardCharts() {
    try {
        // Stats for status chart
        const statsRes = await fetch('api/assets/stats');
        const statsJson = await statsRes.json();
        const stats = statsJson.data || {};

        const statusData = {
            labels: ['Operativo', 'En Reparación', 'Baja', 'En Préstamo'],
            values: [
                stats.operativo || 0,
                stats.reparacion || 0,
                stats.baja || 0,
                stats.prestamo || 0
            ]
        };

        // All assets for category + value charts
        const assetsRes = await fetch('api/assets');
        const assetsJson = await assetsRes.json();
        const assets = assetsJson.data || [];

        // Group by category
        const catMap = {};
        const valMap = {};
        assets.forEach(a => {
            const cat = a.categoria || 'Sin categoría';
            catMap[cat] = (catMap[cat] || 0) + (a.cantidad || 1);
            valMap[cat] = (valMap[cat] || 0) + (a.valor || 0);
        });

        const categoryData = {
            labels: Object.keys(catMap),
            values: Object.values(catMap)
        };
        const valueData = {
            labels: Object.keys(valMap),
            values: Object.values(valMap)
        };

        // Movement: group by month of fecha_registro
        const monthMap = {};
        const months = ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'];
        assets.forEach(a => {
            if (a.fechaRegistro) {
                const d = new Date(a.fechaRegistro);
                const key = months[d.getMonth()] + ' ' + d.getFullYear();
                monthMap[key] = (monthMap[key] || 0) + 1;
            }
        });
        // Last 6 months
        const now = new Date();
        const movLabels = [];
        const movValues = [];
        for (let i = 5; i >= 0; i--) {
            const d = new Date(now.getFullYear(), now.getMonth() - i, 1);
            const key = months[d.getMonth()] + ' ' + d.getFullYear();
            movLabels.push(months[d.getMonth()]);
            movValues.push(monthMap[key] || 0);
        }
        const movementData = { labels: movLabels, values: movValues };

        // Render charts
        if (document.getElementById('categoryChart')) initCategoryChart('categoryChart', categoryData);
        if (document.getElementById('movementChart')) initMovementChart('movementChart', movementData);
        if (document.getElementById('statusChart')) initStatusChart('statusChart', statusData);
        if (document.getElementById('valueChart')) initValueChart('valueChart', valueData);
        if (document.getElementById('depreciationChart')) initValueChart('depreciationChart', valueData);

        // Update stat cards
        if (document.getElementById('stat-total')) document.getElementById('stat-total').textContent = stats.total || 0;
        if (document.getElementById('stat-operativo')) document.getElementById('stat-operativo').textContent = stats.operativo || 0;
        if (document.getElementById('stat-reparacion')) document.getElementById('stat-reparacion').textContent = stats.reparacion || 0;
        if (document.getElementById('stat-baja')) document.getElementById('stat-baja').textContent = stats.baja || 0;

    } catch (e) {
        console.error('Error cargando datos del dashboard:', e);
        // Fallback to static data
        initCategoryChart('categoryChart', { labels: ['Computadoras','Accesorios','Muebles','Electrónica','Otros'], values: [12,19,3,5,2] });
        initMovementChart('movementChart', { labels: ['Ene','Feb','Mar','Abr','May','Jun'], values: [10,15,12,20,25,30] });
        initStatusChart('statusChart', { labels: ['Operativo','En Reparación','Baja','En Préstamo'], values: [45,15,10,30] });
        initValueChart('valueChart', { labels: ['Computadoras','Accesorios','Muebles','Electrónica'], values: [45000,32000,8500,12000] });
    }
}

document.addEventListener('DOMContentLoaded', loadDashboardCharts);
