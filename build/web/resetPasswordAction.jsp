<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String token = request.getParameter("token");
    String password = request.getParameter("password");
    String confirmPassword = request.getParameter("confirmPassword");
    
    if (token != null && password != null && password.equals(confirmPassword)) {
        // TODO: En un proyecto real:
        // 1. Validar que el token existe y no ha expirado
        // 2. Obtener el email/usuario asociado al token
        // 3. Hash de la nueva contraseña
        // 4. Actualizar la contraseña en la BD
        // 5. Eliminar el token
        // 6. Log del evento
        
        // Simular éxito
        response.sendRedirect("index.jsp?msg=password_reset");
    } else {
        response.sendRedirect("forgotPassword.jsp?error=invalid");
    }
%>
