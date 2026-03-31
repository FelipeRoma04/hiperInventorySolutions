<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String token = request.getParameter("token");
    String error = request.getParameter("error");
    String message = "";
    
    if ("invalid".equals(error)) {
        message = "El enlace de recuperación ha expirado";
    }
    
    if (token == null || token.isEmpty()) {
        response.sendRedirect("forgotPassword.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Restablecer Contraseña - hiperInventorySolutions</title>
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

        .container {
            background: white;
            border-radius: 15px;
            padding: 40px;
            width: 100%;
            max-width: 450px;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
        }

        .header {
            text-align: center;
            margin-bottom: 30px;
        }

        .header h1 {
            color: #333;
            font-size: 28px;
            margin-bottom: 10px;
        }

        .header p {
            color: #666;
            font-size: 14px;
        }

        .icon {
            font-size: 48px;
            color: #667eea;
            margin-bottom: 15px;
        }

        .alert {
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .alert-error {
            background: #ffebee;
            color: #c62828;
            border-left: 4px solid #f44336;
        }

        .form-group {
            margin-bottom: 20px;
        }

        label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: #333;
            font-size: 14px;
        }

        input {
            width: 100%;
            padding: 12px 15px;
            border: 2px solid #e0e0e0;
            border-radius: 8px;
            font-family: inherit;
            font-size: 14px;
            transition: border-color 0.3s;
        }

        input:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }

        .strength-meter {
            height: 6px;
            background: #e0e0e0;
            border-radius: 3px;
            margin-top: 5px;
            overflow: hidden;
        }

        .strength-bar {
            height: 100%;
            width: 0%;
            background: #f44336;
            transition: all 0.3s;
        }

        .strength-text {
            font-size: 12px;
            margin-top: 5px;
            color: #666;
        }

        .requirements {
            background: #f9f9f9;
            padding: 12px;
            border-radius: 6px;
            font-size: 12px;
            margin-top: 10px;
        }

        .requirement {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 6px;
            color: #999;
        }

        .requirement.met {
            color: #4caf50;
        }

        .requirement i {
            width: 16px;
            text-align: center;
        }

        .btn {
            width: 100%;
            padding: 12px;
            border: none;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
            margin-top: 10px;
        }

        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(102, 126, 234, 0.4);
        }

        .back-link {
            text-align: center;
            margin-top: 20px;
        }

        .back-link a {
            color: #667eea;
            text-decoration: none;
            font-weight: 500;
            transition: color 0.3s;
        }

        .back-link a:hover {
            color: #764ba2;
        }

        .steps {
            background: #f9f9f9;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-size: 13px;
            color: #666;
        }

        .steps p {
            margin-bottom: 8px;
        }

        .steps strong {
            color: #333;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="icon">
                <i class="fas fa-lock"></i>
            </div>
            <h1>Restablecer Contraseña</h1>
            <p>Ingresa tu nueva contraseña</p>
        </div>

        <% if (!message.isEmpty()) { %>
            <div class="alert alert-error">
                <i class="fas fa-exclamation-circle"></i>
                <%= message %>
            </div>
        <% } %>

        <div class="steps">
            <p><strong>Paso 2 de 2:</strong> Crea una nueva contraseña</p>
            <p>La contraseña debe cumplir con los requisitos de seguridad</p>
        </div>

        <form method="POST" action="resetPasswordAction.jsp">
            <input type="hidden" name="token" value="<%= token %>">

            <div class="form-group">
                <label for="password">Nueva Contraseña</label>
                <input type="password" id="password" name="password" required placeholder="Ingresa tu nueva contraseña" onkeyup="validatePasswordStrength()">
                <div class="strength-meter">
                    <div class="strength-bar" id="strengthBar"></div>
                </div>
                <div class="strength-text" id="strengthText">Seguridad: Débil</div>

                <div class="requirements">
                    <div class="requirement" id="req-length">
                        <i class="fas fa-circle"></i>
                        <span>Mínimo 8 caracteres</span>
                    </div>
                    <div class="requirement" id="req-uppercase">
                        <i class="fas fa-circle"></i>
                        <span>Contiene letra mayúscula</span>
                    </div>
                    <div class="requirement" id="req-lowercase">
                        <i class="fas fa-circle"></i>
                        <span>Contiene letra minúscula</span>
                    </div>
                    <div class="requirement" id="req-number">
                        <i class="fas fa-circle"></i>
                        <span>Contiene número</span>
                    </div>
                </div>
            </div>

            <div class="form-group">
                <label for="confirm-password">Confirmar Contraseña</label>
                <input type="password" id="confirm-password" name="confirm-password" required placeholder="Confirma tu contraseña">
            </div>

            <button type="submit" class="btn btn-primary" id="submitBtn" disabled>
                <i class="fas fa-check"></i> Restaurar Contraseña
            </button>
        </form>

        <div class="back-link">
            <a href="index.jsp"><i class="fas fa-arrow-left"></i> Volver al Login</a>
        </div>
    </div>

    <script>
        function validatePasswordStrength() {
            const password = document.getElementById('password').value;
            const confirmPassword = document.getElementById('confirm-password').value;
            const submitBtn = document.getElementById('submitBtn');

            const requirements = {
                length: password.length >= 8,
                uppercase: /[A-Z]/.test(password),
                lowercase: /[a-z]/.test(password),
                number: /\d/.test(password)
            };

            // Update requirements display
            Object.keys(requirements).forEach(key => {
                const req = document.getElementById('req-' + key);
                if (req) {
                    if (requirements[key]) {
                        req.classList.add('met');
                        req.querySelector('i').className = 'fas fa-check-circle';
                    } else {
                        req.classList.remove('met');
                        req.querySelector('i').className = 'fas fa-circle';
                    }
                }
            });

            // Update strength bar
            const passCount = Object.values(requirements).filter(Boolean).length;
            const strength = (passCount / 4) * 100;
            const bar = document.getElementById('strengthBar');
            const text = document.getElementById('strengthText');

            bar.style.width = strength + '%';

            if (passCount < 2) {
                bar.style.backgroundColor = '#f44336';
                text.textContent = 'Seguridad: Débil';
            } else if (passCount < 3) {
                bar.style.backgroundColor = '#ff9800';
                text.textContent = 'Seguridad: Media';
            } else if (passCount < 4) {
                bar.style.backgroundColor = '#ffc107';
                text.textContent = 'Seguridad: Buena';
            } else {
                bar.style.backgroundColor = '#4caf50';
                text.textContent = 'Seguridad: Excelente';
            }

            // Enable submit button if all requirements met
            submitBtn.disabled = !(Object.values(requirements).every(Boolean) && password === confirmPassword && password.length > 0);
        }

        // Initial validation on page load
        document.addEventListener('DOMContentLoaded', function() {
            document.getElementById('confirm-password').addEventListener('input', validatePasswordStrength);
        });
    </script>
</body>
</html>
