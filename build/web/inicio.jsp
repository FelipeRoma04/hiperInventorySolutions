<%@ page isELIgnored="true"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Verificar autenticación
    if (session.getAttribute("username") == null) {
        response.sendRedirect("index.jsp");
        return;
    }
    
    String username = (String) session.getAttribute("username");
    String userRole = (String) session.getAttribute("userRole");
    String currentPage = "dashboard";
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - hiperInventorySolutions</title>
    
    <link rel="stylesheet" href="css/styles.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <style>
        .dashboard-stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .stat-card {
            background: white;
            padding: 25px;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
            border-left: 5px solid #1E90FF;
            display: flex;
            justify-content: space-between;
            align-items: center;
            transition: all 0.3s ease;
        }

        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 16px rgba(0, 0, 0, 0.12);
        }

        .stat-card.info { border-left-color: #1E90FF; }
        .stat-card.success { border-left-color: #28a745; }
        .stat-card.warning { border-left-color: #ffc107; }
        .stat-card.danger { border-left-color: #ff4757; }

        .stat-content h3 {
            margin: 0 0 10px 0;
            color: #999;
            font-size: 14px;
            text-transform: uppercase;
            font-weight: 600;
        }

        .stat-value {
            font-size: 36px;
            font-weight: 700;
            color: #333;
        }

        .stat-icon {
            font-size: 48px;
            opacity: 0.2;
            margin-left: 20px;
        }

        .chart-container {
            background: white;
            padding: 25px;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
            margin-bottom: 20px;
            position: relative;
        }

        .chart-container h3 {
            margin: 0 0 20px 0;
            color: #333;
            font-size: 18px;
            padding-bottom: 10px;
            border-bottom: 2px solid #f0f0f0;
        }

        .charts-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(500px, 1fr));
            gap: 20px;
            margin-top: 20px;
        }

        .chart-wrapper {
            position: relative;
            height: 400px;
        }

        .recent-activity {
            background: white;
            padding: 25px;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
        }

        .activity-item {
            display: flex;
            gap: 15px;
            padding: 15px 0;
            border-bottom: 1px solid #f0f0f0;
        }

        .activity-item:last-child {
            border-bottom: none;
        }

        .activity-icon {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            flex-shrink: 0;
        }

        .activity-icon.add { background: #28a745; }
        .activity-icon.edit { background: #ffc107; }
        .activity-icon.delete { background: #ff4757; }

        .activity-content h4 {
            margin: 0 0 5px 0;
            color: #333;
            font-size: 14px;
        }

        .activity-content p {
            margin: 0;
            color: #999;
            font-size: 12px;
        }

        .two-column {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }

        @media (max-width: 1200px) {
            .two-column,
            .charts-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <!-- SIDEBAR -->
    <aside class="sidebar">
        <div class="sidebar-header">
            <h1>HIS</h1>
        </div>

        <nav>
            <ul class="sidebar-nav">
                <li>
                    <a href="inicio.jsp" class="active">
                        <i class="fas fa-chart-line"></i>
                        Dashboard
                    </a>
                </li>
                <li>
                    <a href="activos.jsp">
                        <i class="fas fa-box"></i>
                        Activos
                    </a>
                </li>
                <li>
                    <a href="categorias.jsp">
                        <i class="fas fa-tags"></i>
                        Categorías
                    </a>
                </li>
                <li>
                    <a href="ubicaciones.jsp">
                        <i class="fas fa-map-location-dot"></i>
                        Ubicaciones
                    </a>
                </li>
                <li>
                    <a href="usuarios.jsp">
                        <i class="fas fa-users"></i>
                        Usuarios
                    </a>
                </li>
                <li>
                    <a href="reportes.jsp">
                        <i class="fas fa-file-csv"></i>
                        Reportes
                    </a>
                </li>
                <li>
                    <a href="logout.jsp">
                        <i class="fas fa-sign-out-alt"></i>
                        Cerrar Sesión
                    </a>
                </li>
            </ul>
        </nav>
    </aside>

    <!-- MAIN LAYOUT -->
    <div class="main-layout">
        <!-- TOP BAR -->
        <header class="topbar">
            <div class="topbar-left">
                <button class="hamburger" title="Menú">
                    <i class="fas fa-bars"></i>
                </button>
                <h2 class="topbar-title">Dashboard</h2>
            </div>

            <div class="topbar-right">
                <div class="search-box">
                    <i class="fas fa-search"></i>
                    <input type="text" placeholder="Buscar activos...">
                </div>
                <!-- NOTIFICATION BELL -->
                <div class="notification-bell" id="notifBell" onclick="toggleNotifications()" style="position:relative;cursor:pointer;font-size:20px;color:#667eea;padding:8px;">
                    <i class="fas fa-bell"></i>
                    <span class="notification-badge" id="notifBadge" style="display:none;">0</span>
                </div>
                <!-- USER DROPDOWN -->
                <div class="user-menu-dropdown" style="position:relative;">
                    <div class="user-menu" id="userMenuBtn" onclick="toggleUserMenu()" style="cursor:pointer;">
                        <div class="user-avatar"><%= Character.toUpperCase(username.charAt(0)) %></div>
                        <span><%= username %></span>
                        <i class="fas fa-chevron-down" style="font-size:12px;color:#999;margin-left:4px;"></i>
                    </div>
                    <div class="dropdown-menu" id="userDropdown">
                        <div style="padding:14px 20px;border-bottom:1px solid #f0f0f0;">
                            <div style="font-weight:700;color:#333;"><%= username %></div>
                            <div style="font-size:12px;color:#888;"><%= userRole %></div>
                        </div>
                        <a href="preferences.jsp" class="dropdown-item"><i class="fas fa-user-cog"></i> Mi Perfil</a>
                        <div class="dropdown-divider"></div>
                        <a href="logout.jsp" class="dropdown-item" style="color:#f44336;"><i class="fas fa-sign-out-alt"></i> Cerrar Sesión</a>
                    </div>
                </div>
            </div>
        </header>

        <!-- CONTENT -->
        <main class="content">
            <!-- ALERTAS DE STOCK BAJO -->
            <div id="lowStockDashboard" style="display:none;background:#fff3e0;border-left:4px solid #ff9800;border-radius:8px;padding:14px 18px;margin-bottom:20px;display:none;align-items:center;gap:12px;">
                <i class="fas fa-exclamation-triangle" style="color:#ff9800;font-size:20px;"></i>
                <div><strong style="color:#e65100;">Stock Bajo:</strong> <span id="lowStockDashMsg"></span></div>
                <a href="activos.jsp" style="margin-left:auto;color:#e65100;font-size:13px;font-weight:600;">Ver activos →</a>
            </div>

            <!-- ESTADÍSTICAS -->
            <div class="dashboard-stats">
                <div class="stat-card info">
                    <div class="stat-content">
                        <h3>Activos Totales</h3>
                        <div class="stat-value" id="stat-total">—</div>
                    </div>
                    <i class="fas fa-box stat-icon"></i>
                </div>

                <div class="stat-card success">
                    <div class="stat-content">
                        <h3>Activos Operativos</h3>
                        <div class="stat-value" id="stat-operativo">—</div>
                    </div>
                    <i class="fas fa-check-circle stat-icon"></i>
                </div>

                <div class="stat-card warning">
                    <div class="stat-content">
                        <h3>En Reparación</h3>
                        <div class="stat-value" id="stat-reparacion">—</div>
                    </div>
                    <i class="fas fa-tools stat-icon"></i>
                </div>

                <div class="stat-card danger">
                    <div class="stat-content">
                        <h3>Dados de Baja</h3>
                        <div class="stat-value" id="stat-baja">—</div>
                    </div>
                    <i class="fas fa-ban stat-icon"></i>
                </div>
            </div>

            <!-- GRÁFICAS -->
            <div class="charts-grid">
                <!-- Gráfica de Categorías (Barras) -->
                <div class="chart-container">
                    <h3><i class="fas fa-chart-bar"></i> Activos por Categoría</h3>
                    <div class="chart-wrapper">
                        <canvas id="categoryChart"></canvas>
                    </div>
                </div>

                <!-- Gráfica de Estado (Donut) -->
                <div class="chart-container">
                    <h3><i class="fas fa-chart-pie"></i> Distribución de Estados</h3>
                    <div class="chart-wrapper">
                        <canvas id="statusChart"></canvas>
                    </div>
                </div>
            </div>

            <!-- Movimiento de Inventario (Línea) -->
            <div class="chart-container">
                <h3><i class="fas fa-chart-line"></i> Movimiento de Inventario (Últimos 6 Meses)</h3>
                <div class="chart-wrapper" style="height: 350px;">
                    <canvas id="movementChart"></canvas>
                </div>
            </div>

            <!-- SEGUNDA FILA -->
            <div class="two-column" style="margin-top: 20px;">
                <!-- Depreciación -->
                <div class="chart-container">
                    <h3><i class="fas fa-dollar-sign"></i> Valor de Depreciación por Categoría</h3>
                    <div class="chart-wrapper" style="height: 300px;">
                        <canvas id="depreciationChart"></canvas>
                    </div>
                </div>

                <!-- Actividad Reciente -->
                <div class="recent-activity">
                    <h3><i class="fas fa-history"></i> Actividad Reciente</h3>
                    
                    <div class="activity-item">
                        <div class="activity-icon add">
                            <i class="fas fa-plus"></i>
                        </div>
                        <div class="activity-content">
                            <h4>Nuevo activo reHIStrado</h4>
                            <p>Computadora Dell Inspiron - Hace 2 horas</p>
                        </div>
                    </div>

                    <div class="activity-item">
                        <div class="activity-icon edit">
                            <i class="fas fa-edit"></i>
                        </div>
                        <div class="activity-content">
                            <h4>Activo actualizado</h4>
                            <p>HP LaserJet Pro - Estado cambiado - Hace 5 horas</p>
                        </div>
                    </div>

                    <div class="activity-item">
                        <div class="activity-icon add">
                            <i class="fas fa-plus"></i>
                        </div>
                        <div class="activity-content">
                            <h4>Activo asignado</h4>
                            <p>Monitor LG 24" - Asignado a Área de Ventas - Hace 1 día</p>
                        </div>
                    </div>

                    <div class="activity-item">
                        <div class="activity-icon delete">
                            <i class="fas fa-trash"></i>
                        </div>
                        <div class="activity-content">
                            <h4>Activo dado de baja</h4>
                            <p>Impresora Epson LX-350 - Fin de vida útil - Hace 2 días</p>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <!-- NOTIFICATION CENTER -->
    <div class="notification-center" id="notifCenter">
        <div class="notification-header">
            <h3>Notificaciones</h3>
            <button class="clear-notifications" onclick="clearNotifications()">Limpiar todo</button>
        </div>
        <div id="notifList"></div>
    </div>

    <!-- SCRIPTS -->
    <script src="js/app.js"></script>
    <script src="js/charts.js"></script>
    <script>
    const userRole = '<%= userRole %>';

    // User dropdown
    function toggleUserMenu() {
        document.getElementById('userDropdown').classList.toggle('show');
    }
    document.addEventListener('click', e => {
        if (!e.target.closest('.user-menu-dropdown')) document.getElementById('userDropdown')?.classList.remove('show');
        if (!e.target.closest('#notifBell') && !e.target.closest('#notifCenter')) document.getElementById('notifCenter')?.classList.remove('show');
    });

    // Notifications
    let notifications = [];
    function toggleNotifications() { document.getElementById('notifCenter').classList.toggle('show'); }
    function clearNotifications() { notifications = []; renderNotifications(); }
    function renderNotifications() {
        const list = document.getElementById('notifList');
        const badge = document.getElementById('notifBadge');
        const unread = notifications.filter(n => !n.read).length;
        badge.textContent = unread;
        badge.style.display = unread > 0 ? 'flex' : 'none';
        if (!notifications.length) { list.innerHTML = '<div style="padding:20px;text-align:center;color:#999;">Sin notificaciones</div>'; return; }
        list.innerHTML = notifications.map(n => {
            const icon = n.type === 'warning' ? 'fa-exclamation' : 'fa-info-circle';
            const unreadClass = n.read ? '' : 'unread';
            return '<div class="notification-item ' + unreadClass + '" onclick="markRead(' + n.id + ')">' +
                '<div class="notification-icon ' + n.type + '"><i class="fas ' + icon + '"></i></div>' +
                '<div class="notification-content">' +
                '<div class="notification-title">' + n.title + '</div>' +
                '<div class="notification-message">' + n.message + '</div>' +
                '<div class="notification-time">' + n.time + '</div>' +
                '</div></div>';
        }).join('');
    }
    function markRead(id) { const n = notifications.find(x=>x.id===id); if(n) n.read=true; renderNotifications(); }

    // Load low stock alerts
    async function loadDashboardAlerts() {
        try {
            const r = await fetch('api/assets/low-stock');
            const j = await r.json();
            const items = j.data || [];
            if (items.length > 0) {
                const widget = document.getElementById('lowStockDashboard');
                widget.style.display = 'flex';
                document.getElementById('lowStockDashMsg').textContent = `${items.length} activo(s): ${items.slice(0,3).map(a=>a.nombre).join(', ')}${items.length>3?'...':''}`;
                notifications.push({ id: Date.now(), title: 'Stock Bajo', message: `${items.length} activo(s) con stock bajo`, type: 'warning', time: 'Ahora', read: false });
                renderNotifications();
            }
        } catch(e) {}
    }

    document.addEventListener('DOMContentLoaded', loadDashboardAlerts);
    </script>
</html>
