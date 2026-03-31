<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Verificar autenticación
    if (session.getAttribute("username") == null) {
        response.sendRedirect("index.jsp");
        return;
    }
    
    String username = (String) session.getAttribute("username");
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
                <div class="user-menu">
                    <img src="https://ui-avatars.com/api/?name=<%= username %>&background=1E90FF&color=fff" 
                         alt="<%= username %>">
                    <span><%= username %></span>
                </div>
            </div>
        </header>

        <!-- CONTENT -->
        <main class="content">
            <!-- ESTADÍSTICAS -->
            <div class="dashboard-stats">
                <div class="stat-card info">
                    <div class="stat-content">
                        <h3>Activos Totales</h3>
                        <div class="stat-value">427</div>
                    </div>
                    <i class="fas fa-box stat-icon"></i>
                </div>

                <div class="stat-card success">
                    <div class="stat-content">
                        <h3>Activos Operativos</h3>
                        <div class="stat-value">389</div>
                    </div>
                    <i class="fas fa-check-circle stat-icon"></i>
                </div>

                <div class="stat-card warning">
                    <div class="stat-content">
                        <h3>En Reparación</h3>
                        <div class="stat-value">18</div>
                    </div>
                    <i class="fas fa-tools stat-icon"></i>
                </div>

                <div class="stat-card danger">
                    <div class="stat-content">
                        <h3>Dados de Baja</h3>
                        <div class="stat-value">20</div>
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

    <!-- SCRIPTS -->
    <script src="js/app.js"></script>
    <script src="js/charts.js"></script>
    
    <script>
        // Datos de las gráficas
        const chartData = {
            category: {
                labels: ['Computadoras', 'Equipos de Red', 'Periféricos', 'Muebles', 'Software'],
                values: [127, 85, 156, 42, 17]
            },
            status: {
                labels: ['Operativo', 'En Reparación', 'En Préstamo', 'Dado de Baja'],
                values: [389, 18, 10, 20]
            },
            movement: {
                labels: ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio'],
                added: [15, 22, 18, 25, 19, 28],
                removed: [3, 5, 2, 4, 3, 6]
            },
            depreciation: {
                labels: ['Computadoras', 'Equipos', 'Periféricos', 'Muebles', 'Software'],
                values: [85000, 45000, 32000, 18000, 25000]
            }
        };

        // Inicializar gráficas cuando el DOM esté listo
        document.addEventListener('DOMContentLoaded', function() {
            initializeCharts(chartData);
        });
    </script>
</body>
</html>
