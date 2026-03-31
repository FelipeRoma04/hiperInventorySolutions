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
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>
    <!-- SIDEBAR -->
    <aside class="sidebar">
        <div class="sidebar-header">
            <h1><i class="fas fa-cube"></i> GlobanInventory</h1>
        </div>
        <nav class="sidebar-nav">
            <li><a href="inicio.jsp" class="active"><i class="fas fa-chart-line"></i> Dashboard</a></li>
            <li><a href="activos_fase2.jsp"><i class="fas fa-box"></i> Activos</a></li>
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
                <button class="hamburger" onclick="document.querySelector('.sidebar').classList.toggle('collapsed'); document.querySelector('.main-layout').classList.toggle('sidebar-collapsed');">
                    <i class="fas fa-bars"></i>
                </button>
                <h2 class="topbar-title">Dashboard</h2>
            </div>
            <div class="topbar-right">
                <!-- NOTIFICACIONES CAMPANA -->
                <div class="notification-bell" onclick="event.stopPropagation(); document.querySelector('.notification-center').classList.toggle('show')">
                    <i class="fas fa-bell"></i>
                    <span class="notification-badge">3</span>
                </div>
                
                <!-- MENÚ USUARIO -->
                <div class="user-menu-dropdown">
                    <div class="user-menu">
                        <div class="user-avatar"><%= Character.toUpperCase(username.charAt(0)) %></div>
                        <span><%= username %></span>
                        <i class="fas fa-chevron-down" style="font-size: 12px;"></i>
                    </div>
                    <div class="dropdown-menu">
                        <button class="dropdown-item" data-action="edit-profile">
                            <i class="fas fa-user"></i> Mi Perfil
                        </button>
                        <button class="dropdown-item" data-action="change-password">
                            <i class="fas fa-lock"></i> Cambiar Contraseña
                        </button>
                        <div class="dropdown-divider"></div>
                        <div class="dropdown-item" style="font-weight: 600; color: #667eea;">
                            <i class="fas fa-shield"></i> Rol: ADMIN
                        </div>
                        <a href="logout.jsp" class="dropdown-item">
                            <i class="fas fa-sign-out-alt"></i> Cerrar Sesión
                        </a>
                    </div>
                </div>
            </div>
        </header>

        <!-- NOTIFICATION CENTER -->
        <div class="notification-center">
            <!-- Se genera dinámicamente con JS -->
        </div>

        <!-- MAIN CONTENT -->
        <main class="main-content">
            <!-- ALERTAS DE STOCK BAJO -->
            <div class="stock-alerts-container">
                <!-- Se generan dinámicamente con JS -->
            </div>

            <!-- ESTADÍSTICAS -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon blue"><i class="fas fa-cube"></i></div>
                    <h3>Total de Activos</h3>
                    <div class="stat-value">245</div>
                    <p style="color: #999; font-size: 12px;">Activos reHIStrados</p>
                </div>

                <div class="stat-card">
                    <div class="stat-icon green"><i class="fas fa-check-circle"></i></div>
                    <h3>Operativos</h3>
                    <div class="stat-value">218</div>
                    <p style="color: #999; font-size: 12px;">En uso normal</p>
                </div>

                <div class="stat-card">
                    <div class="stat-icon orange"><i class="fas fa-tools"></i></div>
                    <h3>En Reparación</h3>
                    <div class="stat-value">12</div>
                    <p style="color: #999; font-size: 12px;">Pendiente de mantenimiento</p>
                </div>

                <div class="stat-card">
                    <div class="stat-icon red"><i class="fas fa-ban"></i></div>
                    <h3>Dados de Baja</h3>
                    <div class="stat-value">15</div>
                    <p style="color: #999; font-size: 12px;">Fuera de servicio</p>
                </div>
            </div>

            <!-- GRÁFICAS -->
            <div class="charts-container">
                <div class="chart-wrapper">
                    <h3 class="chart-title"><i class="fas fa-chart-bar"></i> Activos por Categoría</h3>
                    <canvas id="categoryChart"></canvas>
                </div>

                <div class="chart-wrapper">
                    <h3 class="chart-title"><i class="fas fa-chart-line"></i> Movimiento de Inventario (6 meses)</h3>
                    <canvas id="trendChart"></canvas>
                </div>

                <div class="chart-wrapper">
                    <h3 class="chart-title"><i class="fas fa-chart-doughnut"></i> Distribución de Estados</h3>
                    <canvas id="statusChart"></canvas>
                </div>

                <div class="chart-wrapper">
                    <h3 class="chart-title"><i class="fas fa-chart-bar"></i> Valor por Categoría ($)</h3>
                    <canvas id="valueChart"></canvas>
                </div>
            </div>

            <!-- ACTIVIDAD RECIENTE -->
            <div class="card">
                <h2 class="card-title"><i class="fas fa-history"></i> Actividad Reciente</h2>
                <ul class="activity-list">
                    <li class="activity-item">
                        <div class="activity-time">Hace 2 horas</div>
                        <div class="activity-text"><strong>Activo ACT-001</strong> cambió de estado a <span class="badge badge-active">Operativo</span></div>
                    </li>
                    <li class="activity-item">
                        <div class="activity-time">Hace 5 horas</div>
                        <div class="activity-text"><strong>Admin</strong> creó un nuevo activo <strong>ACT-125</strong></div>
                    </li>
                    <li class="activity-item">
                        <div class="activity-time">Hace 1 día</div>
                        <div class="activity-text"><strong>Monitor Samsung</strong> fue asignado a <strong>Juan Pérez</strong></div>
                    </li>
                    <li class="activity-item">
                        <div class="activity-time">Hace 2 días</div>
                        <div class="activity-text">Nueva categoría <strong>"Equipos de Red"</strong> fue creada</div>
                    </li>
                    <li class="activity-item">
                        <div class="activity-time">Hace 3 días</div>
                        <div class="activity-text"><strong>Impresora HP</strong> cambió de estado a <span class="badge badge-repair">En Reparación</span></div>
                    </li>
                </ul>
            </div>

            <!-- SEDES / UBICACIONES -->
            <div class="card" style="margin-top: 25px;">
                <h2 class="card-title"><i class="fas fa-building"></i> Resumen por Sedes</h2>
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px;">
                    <div style="padding: 15px; background: #f9f9f9; border-radius: 8px; text-align: center;">
                        <div style="font-size: 24px; font-weight: 700; color: #667eea;">89</div>
                        <div style="color: #999; font-size: 12px; margin-top: 5px;">Sede Central</div>
                    </div>
                    <div style="padding: 15px; background: #f9f9f9; border-radius: 8px; text-align: center;">
                        <div style="font-size: 24px; font-weight: 700; color: #764ba2;">76</div>
                        <div style="color: #999; font-size: 12px; margin-top: 5px;">Almacén</div>
                    </div>
                    <div style="padding: 15px; background: #f9f9f9; border-radius: 8px; text-align: center;">
                        <div style="font-size: 24px; font-weight: 700; color: #667eea;">45</div>
                        <div style="color: #999; font-size: 12px; margin-top: 5px;">Sucursal Norte</div>
                    </div>
                    <div style="padding: 15px; background: #f9f9f9; border-radius: 8px; text-align: center;">
                        <div style="font-size: 24px; font-weight: 700; color: #764ba2;">35</div>
                        <div style="color: #999; font-size: 12px; margin-top: 5px;">Sucursal Sur</div>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <!-- Librerías -->
    <script src="js/qrcode.min.js"></script>
    <script src="js/app.js"></script>
    <script src="js/charts.js"></script>
</body>
</html>
