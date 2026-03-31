<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String email = request.getParameter("email");
    
    if (email != null && !email.isEmpty()) {
        // TODO: En un proyecto real, aquí irían:
        // 1. Validar que el email existe en la BD
        // 2. Generar un token único
        // 3. Guardar el token con timestamp en la BD
        // 4. Enviar email con el enlace: forgotPassword.jsp?action=reset&token=xxxxx
        // 5. Log del evento
        
        // Por ahora, simular envío de email
        // En producción usar bibliotecas como javax.mail o SendGrid
        
        response.sendRedirect("forgotPassword.jsp?action=sent");
    } else {
        response.sendRedirect("forgotPassword.jsp");
    }
%>
