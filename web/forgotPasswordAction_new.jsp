<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Simular envío de email (en producto real sería SMTP)
    String email = request.getParameter("email");
    
    if (email == null || email.isEmpty()) {
        response.sendRedirect("forgotPassword.jsp?error=required");
        return;
    }
    
    // Simular búsqueda de usuario (en producto real sería consulta a BD)
    boolean userExists = true; // Asumir que existe para demo
    
    if (userExists) {
        // Aquí iría el código para enviar email
        // En producción, generar token, guardarlo en BD, enviar email
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Email Enviado - hiperInventorySolutions</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }

        .container {
            background: white;
            border-radius: 15px;
            padding: 50px;
            width: 100%;
            max-width: 450px;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
            text-align: center;
        }

        .success-icon {
            font-size: 60px;
            color: #4caf50;
            margin-bottom: 20px;
        }

        h1 {
            color: #333;
            font-size: 28px;
            margin-bottom: 15px;
        }

        p {
            color: #666;
            font-size: 14px;
            line-height: 1.6;
            margin-bottom: 15px;
        }

        .email-highlight {
            background: #f0f0f0;
            padding: 10px;
            border-radius: 6px;
            font-weight: 600;
            color: #333;
            margin: 15px 0;
        }

        .info-box {
            background: #e8f5e9;
            border-left: 4px solid #4caf50;
            padding: 15px;
            border-radius: 6px;
            margin: 20px 0;
            text-align: left;
        }

        .info-box p {
            margin: 8px 0;
            color: #2e7d32;
        }

        .btn {
            display: inline-block;
            padding: 12px 30px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            text-decoration: none;
            border-radius: 8px;
            font-weight: 600;
            margin-top: 20px;
            transition: all 0.3s;
        }

        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(102, 126, 234, 0.4);
        }

        .timer {
            color: #999;
            font-size: 12px;
            margin-top: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="success-icon">
            <i class="fas fa-check-circle"></i>
        </div>

        <h1>¡Correo Enviado!</h1>
        <p>Hemos enviado un enlace de recuperación a:</p>

        <div class="email-highlight">
            <%= email %>
        </div>

        <div class="info-box">
            <p><strong>¿Qué sigue?</strong></p>
            <p>1. Revisa tu correo electrónico (incluyendo la carpeta de spam)</p>
            <p>2. Haz clic en el enlace de recuperación</p>
            <p>3. Crea una nueva contraseña</p>
            <p>4. Inicia sesión con tu nueva contraseña</p>
        </div>

        <p>El enlace expirará en 24 horas por razones de seguridad.</p>

        <a href="index.jsp" class="btn">
            <i class="fas fa-arrow-left"></i> Volver al Login
        </a>

        <div class="timer">
            <p>¿No recibiste el email? Revisa tu carpeta de spam o intenta nuevamente en unos minutos.</p>
        </div>
    </div>
</body>
</html>
<%
    } else {
        response.sendRedirect("forgotPassword.jsp?error=invalid");
    }
%>
