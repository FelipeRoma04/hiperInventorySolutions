<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.Date"%>
<%
    String username = request.getParameter("username");
    String password = request.getParameter("password");
    String remember = request.getParameter("remember");

    // Validar campos vacíos
    if (username == null || username.isEmpty() || password == null || password.isEmpty()) {
        response.sendRedirect("index.jsp?error=required");
        return;
    }

    // TODO: Aquí iría la validación contra base de datos
    // Por ahora, aceptar usuario/contraseña de prueba
    if ("admin".equals(username) && "admin123".equals(password)) {
        // Crear sesión
        session.setAttribute("username", username);
        session.setAttribute("userEmail", "admin@globalinventory.com");
        session.setAttribute("loginTime", new Date());
        
        // Si "Recordarme" está marcado, crear cookie
        if ("on".equals(remember)) {
            javax.servlet.http.Cookie cookie = new javax.servlet.http.Cookie("rememberMe", username);
            cookie.setMaxAge(7 * 24 * 60 * 60); // 7 días
            response.addCookie(cookie);
        }
        
        response.sendRedirect("inicio.jsp");
    } else {
        response.sendRedirect("index.jsp?error=invalid");
    }
%>
