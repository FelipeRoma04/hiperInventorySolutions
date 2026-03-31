<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String token = request.getParameter("token");
    String password = request.getParameter("password");
    String confirmPassword = request.getParameter("confirm-password");
    
    if (token == null || password == null || confirmPassword == null) {
        response.sendRedirect("index.jsp?error=invalid");
        return;
    }
    
    // Validar que las contraseñas coincidan
    if (!password.equals(confirmPassword)) {
        response.sendRedirect("resetPassword.jsp?token=" + token + "&error=mismatch");
        return;
    }
    
    // Validar requisitos de contraseña
    if (password.length() < 8 || !password.matches(".*[A-Z].*") || !password.matches(".*[a-z].*") || !password.matches(".*\\d.*")) {
        response.sendRedirect("resetPassword.jsp?token=" + token + "&error=weak");
        return;
    }
    
    // Aquí iría el código para:
    // 1. Validar token en BD
    // 2. Actualizar contraseña en BD
    // 3. Invalidar token
    
    // Para esta demo, asumimos éxito
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Contraseña Actualizada - hiperInventorySolutions</title>
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
            animation: pulse 1.5s ease-in-out infinite;
        }

        @keyframes pulse {
            0%, 100% { transform: scale(1); }
            50% { transform: scale(1.05); }
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

        .success-box {
            background: #e8f5e9;
            border-left: 4px solid #4caf50;
            padding: 15px;
            border-radius: 6px;
            margin: 20px 0;
        }

        .success-box p {
            color: #2e7d32;
            margin: 0;
        }

        .btn {
            display: inline-block;
            padding: 12px 40px;
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

        .countdown {
            color: #999;
            font-size: 12px;
            margin-top: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="success-icon">
            <i class="fas fa-lock"></i>
        </div>

        <h1>¡Contraseña Actualizada!</h1>
        <p>Tu contraseña ha sido restablecida exitosamente.</p>

        <div class="success-box">
            <p><i class="fas fa-check-circle"></i> Paso 2 completado</p>
        </div>

        <p>Ahora puedes iniciar sesión con tu nueva contraseña.</p>

        <a href="index.jsp" class="btn">
            <i class="fas fa-sign-in-alt"></i> Ir al Login
        </a>

        <div class="countdown">
            <p>Serás redirigido automáticamente en 5 segundos...</p>
        </div>
    </div>

    <script>
        setTimeout(function() {
            window.location.href = 'index.jsp';
        }, 5000);
    </script>
</body>
</html>
