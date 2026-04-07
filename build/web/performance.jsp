<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Panel de Performance - HiperInventory</title>
    <link rel="stylesheet" href="css/styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"/>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/3.9.1/chart.min.css">
    <style>
        .metric-card { 
            background: white; 
            border-radius: 8px; 
            padding: 20px; 
            margin: 10px 0; 
            box-shadow: 0 2px 4px rgba(0,0,0,0.1); 
        }
        .metric-value { 
            font-size: 28px; 
            font-weight: bold; 
            color: #6366f1; 
            margin: 10px 0; 
        }
        .metric-label { 
            font-size: 14px; 
            color: #666; 
        }
        .status-green { 
            color: #10b981; 
        }
        .status-yellow { 
            color: #f59e0b; 
        }
        .status-red { 
            color: #ef4444; 
        }
        .btn-group { 
            display: flex; 
            gap: 10px; 
            margin-top: 20px; 
        }
        .btn { 
            padding: 10px 20px; 
            border: none; 
            border-radius: 5px; 
            cursor: pointer; 
            font-size: 14px; 
            transition: 0.3s; 
        }
        .btn-primary { 
            background: #6366f1; 
            color: white; 
        }
        .btn-primary:hover { 
            background: #4f46e5; 
        }
        .btn-success { 
            background: #10b981; 
            color: white; 
        }
        .btn-success:hover { 
            background: #059669; 
        }
        .metric-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 15px;
        }
        .metric-table th, .metric-table td {
            text-align: left;
            padding: 10px;
            border-bottom: 1px solid #e5e7eb;
        }
        .metric-table th {
            background: #f3f4f6;
            font-weight: 600;
            color: #374151;
        }
        .metric-table tr:hover {
            background: #f9fafb;
        }
        .refresh-time {
            font-size: 12px;
            color: #999;
            margin-top: 10px;
        }
        .real-time {
            display: inline-block;
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background: #10b981;
            margin-right: 5px;
            animation: pulse 2s infinite;
        }
        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.3; }
        }
    </style>
</head>
<body>
    <%@ include file="layout.jsp" %>
    
    <main class="content">
        <div class="page-header">
            <h1><i class="fas fa-tachometer-alt"></i> Panel de Performance - Fase 4</h1>
            <p>Monitoreo de caché, base de datos y optimizaciones</p>
        </div>
        
        <!-- Sección de Estadísticas -->
        <div class="grid-2">
            <div class="metric-card">
                <div class="metric-label">
                    <span class="real-time"></span>
                    Cache - Entradas Activas
                </div>
                <div class="metric-value" id="cache-size">0</div>
                <canvas id="cache-chart" height="100"></canvas>
                <button class="btn btn-success" onclick="clearCache()">Limpiar Cache</button>
            </div>
            
            <div class="metric-card">
                <div class="metric-label">
                    <span class="real-time"></span>
                    Pool de Conexiones
                </div>
                <div class="metric-value" id="pool-available">0</div>
                <table class="metric-table">
                    <tr>
                        <th>Disponibles</th>
                        <td id="pool-size">0</td>
                    </tr>
                    <tr>
                        <th>Máximo</th>
                        <td id="pool-max">10</td>
                    </tr>
                    <tr>
                        <th>En Uso</th>
                        <td id="pool-active">0</td>
                    </tr>
                </table>
                <button class="btn btn-success" onclick="optimizeDB()">Optimizar BD</button>
            </div>
        </div>
        
        <!-- Sección de Performance -->
        <div class="metric-card">
            <h2><i class="fas fa-chart-line"></i> Métricas de Operaciones</h2>
            <div class="btn-group">
                <button class="btn btn-primary" onclick="loadStats()">
                    <i class="fas fa-sync"></i> Refrescar
                </button>
                <button class="btn btn-primary" onclick="resetMetrics()">
                    <i class="fas fa-redo"></i> Reset Métricas
                </button>
            </div>
            
            <table class="metric-table" id="performance-table">
                <thead>
                    <tr>
                        <th>Operación</th>
                        <th>Llamadas</th>
                        <th>Promedio</th>
                        <th>Mínimo</th>
                        <th>Máximo</th>
                    </tr>
                </thead>
                <tbody id="table-body">
                    <tr><td colspan="5" style="text-align: center; color: #999;">Cargando...</td></tr>
                </tbody>
            </table>
            <div class="refresh-time">
                Última actualización: <span id="update-time">nunca</span>
            </div>
        </div>
        
        <!-- Sección de Optimizaciones -->
        <div class="metric-card">
            <h2><i class="fas fa-tools"></i> Herramientas de Optimización</h2>
            <div class="grid-3">
                <button class="btn btn-success" onclick="compressAssets()">
                    <i class="fas fa-compress"></i><br>Comprimir Assets
                </button>
                <button class="btn btn-success" onclick="createIndexes()">
                    <i class="fas fa-database"></i><br>Crear Índices
                </button>
                <button class="btn btn-success" onclick="generateReport()">
                    <i class="fas fa-file-pdf"></i><br>Reporte PDF
                </button>
            </div>
        </div>
    </main>
    
    <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/3.9.1/chart.min.js"></script>
    <script>
        // Cliente de Performance API
        const PerformanceAPI = {
            baseUrl: '<%= request.getContextPath() %>/api/performance',
            
            async getStats() {
                try {
                    const response = await fetch(this.baseUrl + '?action=stats');
                    return await response.json();
                } catch (error) {
                    console.error('Error:', error);
                    return {};
                }
            },
            
            async getCache() {
                try {
                    const response = await fetch(this.baseUrl + '?action=cache');
                    return await response.json();
                } catch (error) {
                    console.error('Error:', error);
                    return {};
                }
            },
            
            async getDatabase() {
                try {
                    const response = await fetch(this.baseUrl + '?action=database');
                    return await response.json();
                } catch (error) {
                    console.error('Error:', error);
                    return {};
                }
            },
            
            async optimize(action) {
                try {
                    const response = await fetch(this.baseUrl + '?action=' + action, {
                        method: 'POST'
                    });
                    return await response.json();
                } catch (error) {
                    console.error('Error:', error);
                    return {};
                }
            }
        };
        
        // Funciones de la página
        async function loadStats() {
            const stats = await PerformanceAPI.getStats();
            const tbody = document.getElementById('table-body');
            tbody.innerHTML = '';
            
            if (stats.performance && Object.keys(stats.performance).length > 0) {
                Object.entries(stats.performance).forEach(([op, data]) => {
                    const row = `
                        <tr>
                            <td><strong>${op}</strong></td>
                            <td>${data.count || 0}</td>
                            <td>${data.average || '0 ms'}</td>
                            <td>${data.min || '0 ms'}</td>
                            <td>${data.max || '0 ms'}</td>
                        </tr>
                    `;
                    tbody.innerHTML += row;
                });
            } else {
                tbody.innerHTML = '<tr><td colspan="5" style="text-align: center; color: #999;">Sin datos aún</td></tr>';
            }
            
            document.getElementById('update-time').textContent = new Date().toLocaleTimeString();
        }
        
        async function loadCache() {
            const data = await PerformanceAPI.getCache();
            if (data.cache) {
                document.getElementById('cache-size').textContent = data.cache.size || 0;
            }
        }
        
        async function loadDatabase() {
            const data = await PerformanceAPI.getDatabase();
            if (data.pool) {
                document.getElementById('pool-available').textContent = data.pool.available || 0;
                document.getElementById('pool-size').textContent = data.pool.available || 0;
                document.getElementById('pool-max').textContent = data.pool.maxSize || 10;
                document.getElementById('pool-active').textContent = data.pool.active || 0;
            }
        }
        
        async function clearCache() {
            if (confirm('¿Estás seguro de que deseas limpiar el caché?')) {
                const result = await PerformanceAPI.optimize('clear-cache');
                alert(result.message || 'Caché limpiado');
                loadCache();
            }
        }
        
        async function optimizeDB() {
            if (confirm('¿Estás seguro de que deseas optimizar la BD?')) {
                const result = await PerformanceAPI.optimize('optimize-db');
                alert(result.message || 'BD optimizada');
                loadDatabase();
            }
        }
        
        async function resetMetrics() {
            if (confirm('¿Estás seguro de que deseas resetear las métricas?')) {
                const result = await PerformanceAPI.optimize('reset-metrics');
                alert(result.message || 'Métricas reseteadas');
                loadStats();
            }
        }
        
        async function compressAssets() {
            alert('Función de compresión de assets en desarrollo...');
        }
        
        async function createIndexes() {
            if (confirm('¿Estás seguro de que deseas crear/recrear los índices?')) {
                await optimizeDB();
            }
        }
        
        async function generateReport() {
            alert('Generando reporte...');
        }
        
        // Cargar datos al iniciar
        document.addEventListener('DOMContentLoaded', function() {
            loadCache();
            loadDatabase();
            loadStats();
            
            // Auto-refrescar cada 10 segundos
            setInterval(() => {
                loadCache();
                loadDatabase();
            }, 10000);
        });
    </script>
</body>
</html>
