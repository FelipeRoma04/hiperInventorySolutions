<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String action = request.getParameter("action");
    String token = request.getParameter("token");
    String message = "";
    String error = "";
    
    if ("reset".equals(action) && token != null) {
        // Página de restablecimiento de contraseña
        // TODO: Validar token en la base de datos
    } else if ("sent".equals(action)) {
        message = "Se ha enviado un enlace de recuperación a tu correo electrónico.";
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Recuperar Contraseña - hiperInventorySolutions</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }

        .recovery-container {
            background: white;
            padding: 40px;
            border-radius: 15px;
            width: 100%;
            max-width: 420px;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.3);
            animation: slideUp 0.5s ease;
        }

        @keyframes slideUp {
            from {
                transform: translateY(30px);
                opacity: 0;
            }
            to {
                transform: translateY(0);
                opacity: 1;
            }
        }

        .recovery-header {
            text-align: center;
            margin-bottom: 30px;
        }

        .recovery-header h1 {
            font-size: 28px;
            color: #333;
            margin-bottom: 10px;
        }

        .recovery-header p {
            color: #999;
            font-size: 14px;
        }

        .icon-circle {
            width: 80px;
            height: 80px;
            background: #f0f8ff;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 20px;
            font-size: 40px;
            color: #667eea;
        }

        .alert {
            padding: 12px 15px;
            border-radius: 8px;
            margin-bottom: 20px;
            border-left: 4px solid;
        }

        .alert-success {
            background: #d4edda;
            color: #155724;
            border-left-color: #28a745;
        }

        .alert-danger {
            background: #f8d7da;
            color: #721c24;
            border-left-color: #ff4757;
        }

        .alert-info {
            background: #d1ecf1;
            color: #0c5460;
            border-left-color: #17a2b8;
        }

        .form-group {
            margin-bottom: 20px;
            text-align: left;
        }

        label {
            display: block;
            margin-bottom: 8px;
            color: #333;
            font-weight: 500;
        }

        input[type="email"],
        input[type="password"],
        input[type="text"] {
            width: 100%;
            padding: 12px 15px;
            border: 1px solid #ddd;
            border-radius: 8px;
            font-size: 14px;
            font-family: inherit;
            transition: all 0.3s ease;
        }

        input[type="email"]:focus,
        input[type="password"]:focus,
        input[type="text"]:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }

        button[type="submit"] {
            width: 100%;
            padding: 12px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            font-weight: 600;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-size: 16px;
            transition: all 0.3s ease;
            margin-bottom: 15px;
        }

        button[type="submit"]:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 20px rgba(102, 126, 234, 0.4);
        }

        .back-link {
            text-align: center;
            color: #666;
            font-size: 14px;
        }

        .back-link a {
            color: #667eea;
            text-decoration: none;
            font-weight: 600;
        }

        .back-link a:hover {
            text-decoration: underline;
        }

        .form-info {
            background: #f9f9f9;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-size: 14px;
            color: #666;
            line-height: 1.6;
        }

        .password-requirements {
            background: #f9f9f9;
            padding: 15px;
            border-radius: 8px;
            margin-top: 15px;
            font-size: 13px;
        }

        .requirements-list {
            list-style: none;
            margin-top: 10px;
        }

        .requirements-list li {
            padding: 5px 0;
            color: #999;
        }

        .requirements-list li.met {
            color: #28a745;
        }

        .requirements-list i {
            margin-right: 8px;
        }

        .success-message {
            text-align: center;
            padding: 30px 0;
        }

        .success-icon {
            font-size: 60px;
            color: #28a745;
            margin-bottom: 20px;
        }

        .success-message h2 {
            color: #333;
            margin-bottom: 10px;
        }

        .success-message p {
            color: #666;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
    <div class="recovery-container">
        <!-- HEADER -->
        <div class="recovery-header">
            <div class="icon-circle">
                <i class="fas fa-lock"></i>
            </div>
            <h1>Recuperar Contraseña</h1>
            <p>Restablece tu acceso a hiperInventorySolutions</p>
        </div>

        <% if (!message.isEmpty()) { %>
            <div class="alert alert-success">
                <i class="fas fa-check-circle"></i> <%= message %>
            </div>
        <% } %>

        <% if (!error.isEmpty()) { %>
            <div class="alert alert-danger">
                <i class="fas fa-exclamation-circle"></i> <%= error %>
            </div>
        <% } %>

        <!-- FORMULARIO DE SOLICITUD -->
        <% if (!"reset".equals(action) || token == null) { %>
            <form action="forgotPasswordAction.jsp" method="post">
                <div class="form-info">
                    <i class="fas fa-info-circle"></i>
                    Ingresa tu dirección de correo electrónico reHIStrada y te enviaremos un enlace 
                    para restablecer tu contraseña.
                </div>

                <div class="form-group">
                    <label for="email">
                        <i class="fas fa-envelope"></i> Correo Electrónico
                    </label>
                    <input type="email" id="email" name="email" placeholder="tu@email.com" required>
                </div>

                <button type="submit">
                    <i class="fas fa-paper-plane"></i> Enviar Enlace de Recuperación
                </button>

                <div class="back-link">
                    ¿Recuerdas tu contraseña? <a href="index.jsp">Volver al inicio de sesión</a>
                </div>
            </form>
        <% } else { %>
            <!-- FORMULARIO DE RESETEO -->
            <form action="resetPasswordAction.jsp" method="post">
                <input type="hidden" name="token" value="<%= token %>">

                <div class="form-info">
                    <i class="fas fa-shield-alt"></i>
                    Por su seguridad, la contraseña debe tener al menos 8 caracteres,
                    incluyendo mayúsculas, minúsculas y números.
                </div>

                <div class="form-group">
                    <label for="password">
                        <i class="fas fa-lock"></i> Nueva Contraseña
                    </label>
                    <input type="password" id="password" name="password" placeholder="Contraseña" required>
                </div>

                <div class="form-group">
                    <label for="confirmPassword">
                        <i class="fas fa-lock"></i> Confirmar Contraseña
                    </label>
                    <input type="password" id="confirmPassword" name="confirmPassword" placeholder="Repetir contraseña" required>
                </div>

                <div class="password-requirements">
                    <strong>Requisitos de la contraseña:</strong>
                    <ul class="requirements-list">
                        <li id="length"><i class="fas fa-circle"></i> Al menos 8 caracteres</li>
                        <li id="upper"><i class="fas fa-circle"></i> Al menos una mayúscula</li>
                        <li id="lower"><i class="fas fa-circle"></i> Al menos una minúscula</li>
                        <li id="number"><i class="fas fa-circle"></i> Al menos un número</li>
                    </ul>
                </div>

                <button type="submit" id="submitBtn" disabled>
                    <i class="fas fa-check"></i> Restablecer Contraseña
                </button>

                <div class="back-link">
                    <a href="index.jsp">Volver al inicio de sesión</a>
                </div>
            </form>

            <script>
                const passwordInput = document.getElementById('password');
                const confirmInput = document.getElementById('confirmPassword');
                const submitBtn = document.getElementById('submitBtn');

                function validatePassword() {
                    const password = passwordInput.value;
                    
                    const hasLength = password.length >= 8;
                    const hasUpper = /[A-Z]/.test(password);
                    const hasLower = /[a-z]/.test(password);
                    const hasNumber = /[0-9]/.test(password);
                    const match = password === confirmInput.value && password.length > 0;

                    // Update requirements
                    document.getElementById('length').classList.toggle('met', hasLength);
                    document.getElementById('upper').classList.toggle('met', hasUpper);
                    document.getElementById('lower').classList.toggle('met', hasLower);
                    document.getElementById('number').classList.toggle('met', hasNumber);

                    // Enable submit button
                    submitBtn.disabled = !(hasLength && hasUpper && hasLower && hasNumber && match);
                }

                passwordInput.addEventListener('input', validatePassword);
                confirmInput.addEventListener('input', validatePassword);
            </script>
        <% } %>
    </div>
</body>
</html>
