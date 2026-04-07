<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Obtener información del usuario desde la sesión
    String username = (String) session.getAttribute("username");
    String userEmail = (String) session.getAttribute("userEmail");
    String currentPage = request.getParameter("page") != null ? request.getParameter("page") : "dashboard";
    
    // Redirigir a login si no está autenticado
    if (username == null) {
        response.sendRedirect("index.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${pageTitle} - hiperInventorySolutions</title>
    
    <!-- Estilos Main -->
    <link rel="stylesheet" href="css/styles.css">
    
    <!-- Chart.js para gráficas -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.js"></script>
    
    <!-- FontAwesome para iconos -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <!-- Estilos específicos de la página -->
    <style>
        ${additionalStyles}
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
                    <a href="?page=dashboard" class="<%= currentPage.equals("dashboard") ? "active" : "" %>">
                        <i class="fas fa-chart-line"></i>
                        Dashboard
                    </a>
                </li>
                <li>
                    <a href="?page=activos" class="<%= currentPage.equals("activos") ? "active" : "" %>">
                        <i class="fas fa-box"></i>
                        Activos
                    </a>
                </li>
                <li>
                    <a href="?page=categorias" class="<%= currentPage.equals("categorias") ? "active" : "" %>">
                        <i class="fas fa-tags"></i>
                        Categorías
                    </a>
                </li>
                <li>
                    <a href="?page=ubicaciones" class="<%= currentPage.equals("ubicaciones") ? "active" : "" %>">
                        <i class="fas fa-map-location-dot"></i>
                        Ubicaciones
                    </a>
                </li>
                <li>
                    <a href="?page=usuarios" class="<%= currentPage.equals("usuarios") ? "active" : "" %>">
                        <i class="fas fa-users"></i>
                        Usuarios
                    </a>
                </li>
                <li>
                    <a href="?page=reportes" class="<%= currentPage.equals("reportes") ? "active" : "" %>">
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
                <h2 class="topbar-title">${pageTitle}</h2>
            </div>

            <div class="topbar-right">
                <div class="search-box">
                    <i class="fas fa-search"></i>
                    <input type="text" placeholder="Buscar...">
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
            ${content}
        </main>
    </div>

    <!-- SCRIPTS -->
    <script src="js/app.js"></script>
    <script src="js/charts.js"></script>
    
    <!-- Scripts específicos de la página -->
    <script>
        ${additionalScripts}
    </script>
</body>
</html>
