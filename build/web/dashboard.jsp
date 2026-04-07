<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Verificar autenticación
    if (session.getAttribute("username") == null) {
        response.sendRedirect("index.jsp?error=session");
        return;
    }
    String username = (String) session.getAttribute("username");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - hiperInventorySolutions</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="css/styles.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@3.9.1/dist/chart.min.js"></script>
</head>
<body>
    <!-- SIDEBAR -->
    <aside class="sidebar">
        <div class="sidebar-header">
            <h1><i class="fas fa-cube"></i> HiperInventory</h1>
        </div>
        <nav class="sidebar-nav">
            <li><a href="inicio.jsp" class="active"><i class="fas fa-chart-line"></i> Dashboard</a></li>
            <li><a href="activos.jsp"><i class="fas fa-box"></i> Activos</a></li>
            <li><a href="categorias.jsp"><i class="fas fa-tags"></i> Categorías</a></li>
            <li><a href="ubicaciones.jsp"><i class="fas fa-map-marker-alt"></i> Ubicaciones</a></li>
            <li><a href="usuarios.jsp"><i class="fas fa-users"></i> Usuarios</a></li>
            <li><a href="reportes.jsp"><i class="fas fa-file-pdf"></i> Reportes</a></li>
            <li><hr style="border: none; border-top: 1px solid rgba(255,255,255,0.1); margin: 15px 0;">
            <li><a href="logout.jsp"><i class="fas fa-sign-out-alt"></i> Cerrar Sesión</a></li>
        </nav>
    </aside>

    <!-- MAIN LAYOUT -->
    <div class="main-layout">
        <!-- TOP BAR -->
        <header class="topbar">
            <div>
                <button class="hamburger" onclick="document.querySelector('.hamburger').click()">
                    <i class="fas fa-bars"></i>
                </button>
                <h2 class="topbar-title">Dashboard</h2>
            </div>
            <div class="topbar-right">
                <div class="user-menu">
                    <div class="user-avatar"><%= Character.toUpperCase(username.charAt(0)) %></div>
                    <span><%= username %></span>
                </div>
            </div>
        </header>

        <!-- MAIN CONTENT -->
        <main class="main-content">
            <!-- STATISTICS CARDS -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon blue"><i class="fas fa-boxes"></i></div>
                    <h3>Total de Activos</h3>
                    <div class="stat-value" id="stat-total">â€”</div>
                    <p>Activos registrados en el sistema</p>
                </div>

                <div class="stat-card">
                    <div class="stat-icon green"><i class="fas fa-check-circle"></i></div>
                    <h3>Activos Operativos</h3>
                    <div class="stat-value" id="stat-operativo">â€”</div>
                    <p>En condición de operación</p>
                </div>

                <div class="stat-card">
                    <div class="stat-icon orange"><i class="fas fa-tools"></i></div>
                    <h3>En Reparación</h3>
                    <div class="stat-value" id="stat-reparacion">â€”</div>
                    <p>Esperando mantenimiento</p>
                </div>

                <div class="stat-card">
                    <div class="stat-icon red"><i class="fas fa-ban"></i></div>
                    <h3>Dados de Baja</h3>
                    <div class="stat-value" id="stat-baja">â€”</div>
                    <p>Fuera de servicio</p>
                </div>
            </div>

            <!-- CHARTS -->
            <div class="charts-container">
                <div class="chart-wrapper">
                    <h3 class="chart-title"><i class="fas fa-chart-bar"></i> Activos por Categoría</h3>
                    <canvas id="categoryChart"></canvas>
                </div>

                <div class="chart-wrapper">
                    <h3 class="chart-title"><i class="fas fa-chart-line"></i> Movimiento de Inventario (6 Meses)</h3>
                    <canvas id="movementChart"></canvas>
                </div>

                <div class="chart-wrapper">
                    <h3 class="chart-title"><i class="fas fa-chart-pie"></i> Distribución de Estados</h3>
                    <canvas id="statusChart"></canvas>
                </div>

                <div class="chart-wrapper">
                    <h3 class="chart-title"><i class="fas fa-dollar-sign"></i> Valor por Categoría</h3>
                    <canvas id="valueChart"></canvas>
                </div>
            </div>

            <!-- RECENT ACTIVITY -->
            <div class="card">
                <h3 class="card-title"><i class="fas fa-history"></i> Actividad Reciente</h3>
                <ul class="activity-list">
                    <li class="activity-item">
                        <div class="activity-time">Hace 2 horas</div>
                        <div class="activity-text">Se reHIStró un nuevo activo: Laptop Dell XPS 15</div>
                    </li>
                    <li class="activity-item">
                        <div class="activity-time">Hace 5 horas</div>
                        <div class="activity-text">Se cambió el estado de Impresora HP a "En reparación"</div>
                    </li>
                    <li class="activity-item">
                        <div class="activity-time">Hace 1 día</div>
                        <div class="activity-text">Se creó nueva ubicación: Oficina Piso 3</div>
                    </li>
                    <li class="activity-item">
                        <div class="activity-time">Hace 2 días</div>
                        <div class="activity-text">Se exportó reporte de activos a PDF</div>
                    </li>
                </ul>
            </div>
        </main>
    </div>

    <!-- SCRIPTS -->
    <script src="js/app.js"></script>
    <script src="js/charts.js"></script>
</body>
</html>
