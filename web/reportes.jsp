<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    if (session.getAttribute("username") == null) {
        response.sendRedirect("index.jsp");
        return;
    }
    String username = (String) session.getAttribute("username");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reportes - hiperInventorySolutions</title>
    <link rel="stylesheet" href="css/styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
    <aside class="sidebar">
        <div class="sidebar-header">
            <img src="https://ui-avatars.com/api/?name=HIS&background=667eea&color=fff" alt="HIS">
            <h1>HIS</h1>
        </div>
        <nav>
            <ul class="sidebar-nav">
                <li><a href="inicio.jsp"><i class="fas fa-chart-line"></i>Dashboard</a></li>
                <li><a href="activos.jsp"><i class="fas fa-box"></i>Activos</a></li>
                <li><a href="categorias.jsp"><i class="fas fa-tags"></i>Categorías</a></li>
                <li><a href="ubicaciones.jsp"><i class="fas fa-map-location-dot"></i>Ubicaciones</a></li>
                <li><a href="usuarios.jsp"><i class="fas fa-users"></i>Usuarios</a></li>
                <li><a href="reportes.jsp" class="active"><i class="fas fa-file-csv"></i>Reportes</a></li>
                <li><a href="logout.jsp"><i class="fas fa-sign-out-alt"></i>Cerrar Sesión</a></li>
            </ul>
        </nav>
    </aside>

    <div class="main-layout">
        <header class="topbar">
            <div class="topbar-left">
                <button class="hamburger"><i class="fas fa-bars"></i></button>
                <h2 class="topbar-title">Reportes</h2>
            </div>
            <div class="topbar-right">
                <div class="search-box">
                    <i class="fas fa-search"></i>
                    <input type="text" placeholder="Buscar...">
                </div>
                <div class="user-menu">
                    <img src="https://ui-avatars.com/api/?name=<%= username %>&background=1E90FF&color=fff">
                    <span><%= username %></span>
                </div>
            </div>
        </header>

        <main class="main-content">
            <div class="card">
                <div class="card-header">
                    <h3>Generación de Reportes</h3>
                    <div>
                        <button class="btn-primary"><i class="fas fa-file-pdf"></i> PDF</button>
                        <button class="btn-primary"><i class="fas fa-file-excel"></i> Excel</button>
                    </div>
                </div>
                <div class="card-empty">
                    <i class="fas fa-chart-bar"></i>
                    <div>Módulo de Reportes en desarrollo</div>
                </div>
            </div>
        </main>
    </div>

    <script src="js/app.js"></script>
</body>
</html>
