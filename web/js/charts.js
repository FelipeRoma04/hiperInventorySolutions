// ===== CHART.JS CONFIGURATION =====
Chart.defaults.font.family = "'Segoe UI', Tahoma, Geneva, Verdana, sans-serif";
Chart.defaults.color = '#666';

// Color palette
const chartColors = {
    primary: '#667eea',
    secondary: '#764ba2',
    success: '#4caf50',
    warning: '#ff9800',
    danger: '#f44336',
    info: '#2196f3',
    light: ['#667eea', '#764ba2', '#4dd0e1', '#ff9800', '#f44336', '#4caf50', '#2196f3', '#ff6b6b']
};

// ===== ASSET CATEGORY CHART (BAR) =====
function initCategoryChart(canvasId, data) {
    const ctx = document.getElementById(canvasId)?.getContext('2d');
    if (!ctx) return;

    new Chart(ctx, {
        type: 'bar',
        data: {
            labels: data?.labels || ['Computadoras', 'Equipos', 'Periféricos', 'Muebles', 'Otros'],
            datasets: [{
                label: 'Activos por Categoría',
                data: data?.values || [12, 19, 3, 5, 2],
                backgroundColor: chartColors.light,
                borderColor: '#fff',
                borderWidth: 2,
                borderRadius: 8
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true,
            indexAxis: 'x',
            plugins: {
                legend: {
                    display: true,
                    position: 'top'
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    grid: {
                        color: 'rgba(0, 0, 0, 0.05)'
                    }
                },
                x: {
                    grid: {
                        display: false
                    }
                }
            }
        }
    });
}

// ===== INVENTORY MOVEMENT CHART (LINE) =====
function initMovementChart(canvasId, data) {
    const ctx = document.getElementById(canvasId)?.getContext('2d');
    if (!ctx) return;

    new Chart(ctx, {
        type: 'line',
        data: {
            labels: data?.labels || ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio'],
            datasets: [{
                label: 'Activos Registrados',
                data: data?.values || [10, 15, 12, 20, 25, 30],
                borderColor: chartColors.primary,
                backgroundColor: 'rgba(102, 126, 234, 0.1)',
                borderWidth: 3,
                fill: true,
                tension: 0.4,
                pointRadius: 6,
                pointBackgroundColor: chartColors.primary,
                pointBorderColor: '#fff',
                pointBorderWidth: 2,
                pointHoverRadius: 8
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true,
            plugins: {
                legend: {
                    display: true,
                    position: 'top'
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    grid: {
                        color: 'rgba(0, 0, 0, 0.05)'
                    }
                },
                x: {
                    grid: {
                        display: false
                    }
                }
            }
        }
    });
}

// ===== ASSET STATUS CHART (DONUT) =====
function initStatusChart(canvasId, data) {
    const ctx = document.getElementById(canvasId)?.getContext('2d');
    if (!ctx) return;

    new Chart(ctx, {
        type: 'doughnut',
        data: {
            labels: data?.labels || ['Operativo', 'En Reparación', 'Baja', 'En Préstamo'],
            datasets: [{
                data: data?.values || [45, 15, 10, 30],
                backgroundColor: [
                    '#4caf50',  // Verde
                    '#ff9800',  // Naranja
                    '#f44336',  // Rojo
                    '#2196f3'   // Azul
                ],
                borderColor: '#fff',
                borderWidth: 2
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true,
            plugins: {
                legend: {
                    position: 'bottom',
                    labels: {
                        padding: 15
                    }
                }
            }
        }
    });
}

// ===== ASSET VALUE BY CATEGORY CHART (HORIZONTAL BAR) =====
function initValueChart(canvasId, data) {
    const ctx = document.getElementById(canvasId)?.getContext('2d');
    if (!ctx) return;

    new Chart(ctx, {
        type: 'bar',
        data: {
            labels: data?.labels || ['Computadoras', 'Equipos', 'Periféricos', 'Muebles'],
            datasets: [{
                label: 'Valor Total ($)',
                data: data?.values || [45000, 32000, 8500, 12000],
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
            plugins: {
                legend: {
                    display: true
                }
            },
            scales: {
                x: {
                    beginAtZero: true,
                    grid: {
                        color: 'rgba(0, 0, 0, 0.05)'
                    }
                },
                y: {
                    grid: {
                        display: false
                    }
                }
            }
        }
    });
}

// ===== INITIALIZE ALL CHARTS =====
document.addEventListener('DOMContentLoaded', function() {
    // Example data - replace with real data from backend
    const categoryData = {
        labels: ['Computadoras', 'Equipos', 'Periféricos', 'Muebles', 'Otros'],
        values: [12, 19, 3, 5, 2]
    };
    
    const movementData = {
        labels: ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio'],
        values: [10, 15, 12, 20, 25, 30]
    };
    
    const statusData = {
        labels: ['Operativo', 'En Reparación', 'Baja', 'En Préstamo'],
        values: [45, 15, 10, 30]
    };
    
    const valueData = {
        labels: ['Computadoras', 'Equipos', 'Periféricos', 'Muebles'],
        values: [45000, 32000, 8500, 12000]
    };
    
    // Initialize charts if canvas exists
    if (document.getElementById('categoryChart')) {
        initCategoryChart('categoryChart', categoryData);
    }
    if (document.getElementById('movementChart')) {
        initMovementChart('movementChart', movementData);
    }
    if (document.getElementById('statusChart')) {
        initStatusChart('statusChart', statusData);
    }
    if (document.getElementById('valueChart')) {
        initValueChart('valueChart', valueData);
    }
});
        }
    });
}

// ===== INVENTORY MOVEMENT CHART (LINE) =====
function initMovementChart(canvasId, data) {
    const ctx = document.getElementById(canvasId)?.getContext('2d');
    if (!ctx) return;

    new Chart(ctx, {
        type: 'line',
        data: {
            labels: data.labels || ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun'],
            datasets: [{
                label: 'Activos Agregados',
                data: data.added || [5, 8, 12, 7, 14, 11],
                borderColor: '#28a745',
                backgroundColor: 'rgba(40, 167, 69, 0.1)',
                borderWidth: 3,
                fill: true,
                tension: 0.4,
                pointRadius: 5,
                pointBackgroundColor: '#28a745'
            },
            {
                label: 'Activos Retirados',
                data: data.removed || [2, 3, 1, 4, 2, 3],
                borderColor: '#ff4757',
                backgroundColor: 'rgba(255, 71, 87, 0.1)',
                borderWidth: 3,
                fill: true,
                tension: 0.4,
                pointRadius: 5,
                pointBackgroundColor: '#ff4757'
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true,
            plugins: {
                legend: {
                    display: true,
                    position: 'top'
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    grid: {
                        color: 'rgba(0, 0, 0, 0.05)'
                    }
                },
                x: {
                    grid: {
                        display: false
                    }
                }
            }
        }
    });
}

// ===== ASSET STATUS CHART (DONUT) =====
function initStatusChart(canvasId, data) {
    const ctx = document.getElementById(canvasId)?.getContext('2d');
    if (!ctx) return;

    new Chart(ctx, {
        type: 'doughnut',
        data: {
            labels: data.labels || ['Activos', 'En Reparación', 'Dados de Baja', 'En Préstamo'],
            datasets: [{
                data: data.values || [45, 12, 8, 15],
                backgroundColor: [
                    '#28a745',
                    '#ffc107',
                    '#dc3545',
                    '#17a2b8'
                ],
                borderColor: '#fff',
                borderWidth: 2
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true,
            plugins: {
                legend: {
                    display: true,
                    position: 'bottom'
                }
            }
        }
    });
}

// ===== DEPRECIATION CHART (HORIZONTAL BAR) =====
function initDepreciationChart(canvasId, data) {
    const ctx = document.getElementById(canvasId)?.getContext('2d');
    if (!ctx) return;

    new Chart(ctx, {
        type: 'bar',
        data: {
            labels: data.labels || ['Computadoras', 'Servidores', 'Licencias', 'Muebles'],
            datasets: [{
                label: 'Valor de Depreciación ($)',
                data: data.values || [45000, 32000, 18000, 12000],
                backgroundColor: '#FF6B6B',
                borderColor: '#fff',
                borderWidth: 2
            }]
        },
        options: {
            indexAxis: 'y',
            responsive: true,
            maintainAspectRatio: true,
            plugins: {
                legend: {
                    display: false
                }
            },
            scales: {
                x: {
                    beginAtZero: true,
                    grid: {
                        color: 'rgba(0, 0, 0, 0.05)'
                    }
                },
                y: {
                    grid: {
                        display: false
                    }
                }
            }
        }
    });
}

// ===== UTILIZATION RATE CHART =====
function initUtilizationChart(canvasId, data) {
    const ctx = document.getElementById(canvasId)?.getContext('2d');
    if (!ctx) return;

    new Chart(ctx, {
        type: 'radar',
        data: {
            labels: data.labels || ['Semanal', 'Mensual', 'Trimestral', 'Anual'],
            datasets: [{
                label: 'Tasa de Utilización (%)',
                data: data.values || [85, 78, 82, 88],
                borderColor: '#1E90FF',
                backgroundColor: 'rgba(30, 144, 255, 0.2)',
                borderWidth: 2,
                pointRadius: 5,
                pointBackgroundColor: '#1E90FF'
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true,
            scales: {
                r: {
                    beginAtZero: true,
                    max: 100
                }
            }
        }
    });
}

// ===== INITIALIZE ALL CHARTS =====
function initializeCharts(chartData) {
    if (chartData.category) {
        initCategoryChart('categoryChart', chartData.category);
    }
    if (chartData.movement) {
        initMovementChart('movementChart', chartData.movement);
    }
    if (chartData.status) {
        initStatusChart('statusChart', chartData.status);
    }
    if (chartData.depreciation) {
        initDepreciationChart('depreciationChart', chartData.depreciation);
    }
    if (chartData.utilization) {
        initUtilizationChart('utilizationChart', chartData.utilization);
    }
}
