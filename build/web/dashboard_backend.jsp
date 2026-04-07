<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Verificar autenticación
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("index.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard Fase 3 - HiperInventory</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.min.css" rel="stylesheet">
    <link href="css/styles.css" rel="stylesheet">
    <style>
        .backend-info {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 20px;
        }
        .backend-info h2 { margin-top: 0; }
        .api-status { 
            display: inline-block; 
            background: rgba(255,255,255,0.2); 
            padding: 10px 15px; 
            border-radius: 5px;
            margin: 5px 0;
        }
        .api-status.active { background: rgba(16, 185, 129, 0.3); }
        .api-status.loading { background: rgba(251, 191, 36, 0.3); }
        .api-list { 
            display: grid; 
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); 
            gap: 15px;
            margin-top: 15px;
        }
        .api-endpoint {
            background: rgba(255,255,255,0.1);
            padding: 12px;
            border-radius: 5px;
            font-size: 13px;
            border-left: 3px solid rgba(255,255,255,0.5);
        }
        .api-endpoint.success { border-left-color: #10b981; }
        .api-endpoint.error { border-left-color: #ef4444; }
        .badge-method {
            display: inline-block;
            padding: 3px 8px;
            border-radius: 3px;
            font-size: 11px;
            font-weight: bold;
            margin-right: 8px;
        }
        .badge-get { background: #3b82f6; }
        .badge-post { background: #10b981; }
        .badge-put { background: #f59e0b; }
        .badge-delete { background: #ef4444; }
    </style>
</head>
<body>
    <!-- Sidebar -->
    <aside class="sidebar">
        <div class="sidebar-header">
            <h1>ðŸš€ HiperInventory Fase 3</h1>
        </div>
        <nav class="sidebar-nav">
            <a href="inicio_fase2.jsp" class="nav-link">
                <i class="fas fa-chart-line"></i> Dashboard
            </a>
            <a href="activos_fase3.jsp" class="nav-link active">
                <i class="fas fa-database"></i> Backend API
            </a>
            <a href="usuarios.jsp" class="nav-link">
                <i class="fas fa-users"></i> Usuarios
            </a>
            <a href="dashboard_backend.jsp" class="nav-link">
                <i class="fas fa-server"></i> Estado Servidor
            </a>
        </nav>
    </aside>

    <!-- Main Content -->
    <main class="main-content">
        <!-- Topbar -->
        <div class="topbar">
            <div class="topbar-left">
                <button class="sidebar-toggle" onclick="toggleSidebar()">
                    <i class="fas fa-bars"></i>
                </button>
                <h2>Backend API - Fase 3</h2>
            </div>
            <div class="topbar-right">
                <div class="notification-bell">
                    <i class="fas fa-bell"></i>
                    <span class="badge">0</span>
                </div>
                <div class="user-menu">
                    <button onclick="toggleUserMenu()">
                        <div class="avatar"><%= ((String)session.getAttribute("userName")).charAt(0) %></div>
                        <span><%= (String)session.getAttribute("userName") %></span>
                    </button>
                    <div class="dropdown-menu">
                        <a href="#"><i class="fas fa-user"></i> Mi Perfil</a>
                        <a href="logout.jsp"><i class="fas fa-sign-out-alt"></i> Cerrar Sesión</a>
                    </div>
                </div>
            </div>
        </div>

        <!-- Content Area -->
        <div class="content">
            <!-- Fase 3 Backend Info -->
            <div class="backend-info">
                <h2>ðŸ”§ Fase 3: Backend Java REST API</h2>
                <p>Arquitectura completa con Servlets, DAOs y Base de Datos SQLite</p>
                <div class="api-status active">
                    <i class="fas fa-check-circle"></i> Backend Servlets activos
                </div>
                <div class="api-status">
                    <i class="fas fa-database"></i> SQLite Database: hiperInventory.db
                </div>
                <div class="api-status">
                    <i class="fas fa-lock"></i> Autenticación: Implementada
                </div>
                <div class="api-status">
                    <i class="fas fa-file"></i> Auditoría: Logging completo
                </div>
            </div>

            <!-- API Endpoints -->
            <div class="card">
                <div class="card-header">
                    <h3>ðŸ“¡ Endpoints REST Disponibles</h3>
                    <p>Todos los servicios están documentados y listos para usar</p>
                </div>
                <div class="card-body">
                    <div class="api-list">
                        <!-- Auth Endpoints -->
                        <div class="api-endpoint success">
                            <span class="badge-method badge-post">POST</span>
                            <strong>/api/auth/login</strong>
                            <br><small>Autenticación de usuarios</small>
                        </div>
                        <div class="api-endpoint success">
                            <span class="badge-method badge-post">POST</span>
                            <strong>/api/auth/logout</strong>
                            <br><small>Cierre de sesión</small>
                        </div>
                        <div class="api-endpoint success">
                            <span class="badge-method badge-post">POST</span>
                            <strong>/api/auth/reHISter</strong>
                            <br><small>ReHIStro de usuarios</small>
                        </div>

                        <!-- Asset Endpoints -->
                        <div class="api-endpoint success">
                            <span class="badge-method badge-get">GET</span>
                            <strong>/api/assets</strong>
                            <br><small>Listar todos los activos</small>
                        </div>
                        <div class="api-endpoint success">
                            <span class="badge-method badge-get">GET</span>
                            <strong>/api/assets/:id</strong>
                            <br><small>Obtener activo por ID</small>
                        </div>
                        <div class="api-endpoint success">
                            <span class="badge-method badge-get">GET</span>
                            <strong>/api/assets/search</strong>
                            <br><small>Buscar con filtros</small>
                        </div>
                        <div class="api-endpoint success">
                            <span class="badge-method badge-get">GET</span>
                            <strong>/api/assets/stats</strong>
                            <br><small>Estadísticas de activos</small>
                        </div>
                        <div class="api-endpoint success">
                            <span class="badge-method badge-get">GET</span>
                            <strong>/api/assets/low-stock</strong>
                            <br><small>Activos con stock bajo</small>
                        </div>
                        <div class="api-endpoint success">
                            <span class="badge-method badge-post">POST</span>
                            <strong>/api/assets</strong>
                            <br><small>Crear nuevo activo</small>
                        </div>
                        <div class="api-endpoint success">
                            <span class="badge-method badge-put">PUT</span>
                            <strong>/api/assets/:id</strong>
                            <br><small>Actualizar activo</small>
                        </div>
                        <div class="api-endpoint success">
                            <span class="badge-method badge-delete">DELETE</span>
                            <strong>/api/assets/:id</strong>
                            <br><small>Eliminar activo (ADMIN)</small>
                        </div>

                        <!-- Report Endpoints -->
                        <div class="api-endpoint success">
                            <span class="badge-method badge-get">GET</span>
                            <strong>/api/reports/assets-csv</strong>
                            <br><small>Exportar a CSV</small>
                        </div>
                        <div class="api-endpoint success">
                            <span class="badge-method badge-get">GET</span>
                            <strong>/api/reports/assets-pdf</strong>
                            <br><small>Exportar a PDF/HTML</small>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Test API -->
            <div class="card">
                <div class="card-header">
                    <h3>ðŸ§ª Prueba de API</h3>
                </div>
                <div class="card-body">
                    <button onclick="testAssetAPI()" class="btn btn-primary">
                        <i class="fas fa-play"></i> Probar GET /assets
                    </button>
                    <button onclick="testAssetStats()" class="btn btn-info">
                        <i class="fas fa-chart-bar"></i> Probar GET /assets/stats
                    </button>
                    <button onclick="testLowStock()" class="btn btn-warning">
                        <i class="fas fa-exclamation-triangle"></i> Probar GET /low-stock
                    </button>
                    <button onclick="testReportCSV()" class="btn btn-success">
                        <i class="fas fa-file-csv"></i> Descargar CSV
                    </button>
                    <div id="apiResponse" style="margin-top: 20px;"></div>
                </div>
            </div>

            <!-- Database Info -->
            <div class="card">
                <div class="card-header">
                    <h3>ðŸ’¾ Base de Datos SQLite</h3>
                </div>
                <div class="card-body">
                    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 15px;">
                        <div style="border: 1px solid #ddd; padding: 15px; border-radius: 5px;">
                            <strong>ðŸ“Š Tablas</strong>
                            <ul style="margin: 10px 0; padding-left: 20px;">
                                <li>users (Usuarios)</li>
                                <li>assets (Activos)</li>
                                <li>assignments (Asignaciones)</li>
                                <li>notifications (Notificaciones)</li>
                                <li>audit_log (Auditoría)</li>
                                <li>categorias (Categorías)</li>
                                <li>ubicaciones (Ubicaciones)</li>
                            </ul>
                        </div>
                        <div style="border: 1px solid #ddd; padding: 15px; border-radius: 5px;">
                            <strong>ðŸ” Funcionalidades</strong>
                            <ul style="margin: 10px 0; padding-left: 20px;">
                                <li>Control de acceso por roles</li>
                                <li>Historial de cambios</li>
                                <li>Timestamps de auditoría</li>
                                <li>Relaciones foreignKey</li>
                                <li>Validación de datos</li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Technology Stack -->
            <div class="card">
                <div class="card-header">
                    <h3>ðŸ—ï¸ Stack Tecnológico</h3>
                </div>
                <div class="card-body">
                    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px;">
                        <div style="background: #f0f4ff; padding: 15px; border-radius: 5px;">
                            <h4>Backend</h4>
                            <p>Java 26 | Servlets | JDBC <br> Apache Tomcat 9.0.109</p>
                        </div>
                        <div style="background: #f0fff4; padding: 15px; border-radius: 5px;">
                            <h4>Base de Datos</h4>
                            <p>SQLite 3.44 | SQL Queries <br> CRUD Operations</p>
                        </div>
                        <div style="background: #fff0f4; padding: 15px; border-radius: 5px;">
                            <h4>Frontend</h4>
                            <p>HTML5 | CSS3 | JavaScript <br> Chart.js | Font Awesome</p>
                        </div>
                        <div style="background: #f4f0ff; padding: 15px; border-radius: 5px;">
                            <h4>API</h4>
                            <p>REST Endpoints | JSON <br> Request/Response</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <script src="js/api-client.js"></script>
    <script>
        /**
         * Prueba GET /api/assets
         */
        async function testAssetAPI() {
            const response = await fetch('/hiperInventorySolutions/api/assets');
            const data = await response.json();
            displayResponse(data);
        }

        /**
         * Prueba GET /api/assets/stats
         */
        async function testAssetStats() {
            const response = await fetch('/hiperInventorySolutions/api/assets/stats');
            const data = await response.json();
            displayResponse(data);
        }

        /**
         * Prueba GET /api/assets/low-stock
         */
        async function testLowStock() {
            const response = await fetch('/hiperInventorySolutions/api/assets/low-stock');
            const data = await response.json();
            displayResponse(data);
        }

        /**
         * Descarga CSV
         */
        function testReportCSV() {
            window.location.href = '/hiperInventorySolutions/api/reports/assets-csv';
        }

        /**
         * Muestra la respuesta del API
         */
        function displayResponse(data) {
            const responseDiv = document.getElementById('apiResponse');
            responseDiv.innerHTML = '<pre style="background: #f5f5f5; padding: 15px; border-radius: 5px; overflow-x: auto;">' +
                                    JSON.stringify(data, null, 2) + '</pre>';
        }

        /**
         * Controla el sidebar
         */
        function toggleSidebar() {
            const sidebar = document.querySelector('.sidebar');
            sidebar.classList.toggle('collapsed');
        }

        /**
         * Menú usuario
         */
        function toggleUserMenu() {
            const menu = document.querySelector('.dropdown-menu');
            if (menu) menu.classList.toggle('active');
        }

        console.log('âœ… Fase 3 Dashboard cargado - Backend REST activo');
    </script>
</body>
</html>
