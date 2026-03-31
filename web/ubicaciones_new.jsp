<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
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
    <title>Ubicaciones - hiperInventorySolutions</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="css/styles.css">
</head>
<body>
    <aside class="sidebar">
        <div class="sidebar-header"><h1><i class="fas fa-cube"></i> GlobanInventory</h1></div>
        <nav class="sidebar-nav">
            <li><a href="inicio.jsp"><i class="fas fa-chart-line"></i> Dashboard</a></li>
            <li><a href="activos.jsp"><i class="fas fa-box"></i> Activos</a></li>
            <li><a href="categorias.jsp"><i class="fas fa-tags"></i> Categorías</a></li>
            <li><a href="ubicaciones.jsp" class="active"><i class="fas fa-map-marker-alt"></i> Ubicaciones</a></li>
            <li><a href="usuarios.jsp"><i class="fas fa-users"></i> Usuarios</a></li>
            <li><a href="reportes.jsp"><i class="fas fa-file-pdf"></i> Reportes</a></li>
            <li><hr style="border: none; border-top: 1px solid rgba(255,255,255,0.1); margin: 15px 0;"></li>
            <li><a href="logout.jsp"><i class="fas fa-sign-out-alt"></i> Cerrar Sesión</a></li>
        </nav>
    </aside>

    <div class="main-layout">
        <header class="topbar">
            <div><button class="hamburger"><i class="fas fa-bars"></i></button><h2 class="topbar-title">Ubicaciones</h2></div>
            <div class="topbar-right"><div class="user-menu"><div class="user-avatar"><%= Character.toUpperCase(username.charAt(0)) %></div><span><%= username %></span></div></div>
        </header>

        <main class="main-content">
            <div class="card">
                <h3 class="card-title"><i class="fas fa-map-marker-alt"></i> Gestión de Ubicaciones</h3>
                <p style="color: #666; text-align: center; padding: 40px;">
                    <i class="fas fa-cogs" style="font-size: 48px; color: #ccc; margin-bottom: 20px; display: block;"></i>
                    Esta sección está en desarrollo.
                </p>
            </div>
        </main>
    </div>

    <script src="js/app.js"></script>
</body>
</html>
