<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Si ya está autenticado, redirigir a dashboard principal
    if (session.getAttribute("username") != null) {
        response.sendRedirect("inicio.jsp");
        return;
    }

    String error = request.getParameter("error");
    String message = "";

    if ("invalid".equals(error)) {
        message = "Usuario o contraseña inválidos";
    } else if ("required".equals(error)) {
        message = "Por favor completa todos los campos";
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inicio de Sesión - hiperInventorySolutions</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --primary-1: #667eea;
            --primary-2: #764ba2;
            --text-strong: #2c2c2c;
            --text-muted: #7d8090;
            --border: #e6e8f0;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Poppins', sans-serif;
            background: radial-gradient(circle at 20% 20%, rgba(255,255,255,0.08), transparent 35%),
                        radial-gradient(circle at 80% 0%, rgba(255,255,255,0.12), transparent 30%),
                        linear-gradient(135deg, var(--primary-1) 0%, var(--primary-2) 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 24px;
            color: var(--text-strong);
        }

        .login-card {
            width: 100%;
            max-width: 440px;
            background: #fff;
            border-radius: 18px;
            padding: 40px 36px 32px;
            box-shadow: 0 18px 50px rgba(54, 65, 100, 0.28);
            position: relative;
        }

        .login-card::after {
            content: "";
            position: absolute;
            inset: -1px;
            border-radius: 20px;
            padding: 1px;
            background: linear-gradient(135deg, rgba(102,126,234,0.25), rgba(118,75,162,0.25));
            z-index: -1;
            mask: linear-gradient(#000, #000) content-box, linear-gradient(#000, #000);
            mask-composite: exclude;
        }

        .logo {
            width: 72px;
            height: 72px;
            margin: 0 auto 18px;
            display: block;
        }

        .title {
            text-align: center;
            font-size: 26px;
            font-weight: 600;
            margin-bottom: 4px;
        }

        .subtitle {
            text-align: center;
            color: var(--text-muted);
            font-size: 14px;
            margin-bottom: 24px;
        }

        .alert {
            padding: 12px 14px;
            border-radius: 10px;
            background: #fde8ec;
            color: #c0392b;
            border: 1px solid #f8c9d0;
            display: flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 20px;
        }

        .field {
            margin-bottom: 18px;
        }

        label {
            display: block;
            font-size: 13px;
            font-weight: 500;
            margin-bottom: 8px;
            color: var(--text-strong);
        }

        .input {
            width: 100%;
            padding: 12px 14px;
            border: 1px solid var(--border);
            border-radius: 10px;
            font-size: 14px;
            transition: all 0.2s ease;
        }

        .input:focus {
            outline: none;
            border-color: var(--primary-1);
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.15);
        }

        .aux-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 8px;
            margin-bottom: 18px;
            font-size: 13px;
        }

        .remember {
            display: flex;
            align-items: center;
            gap: 8px;
            color: var(--text-strong);
        }

        .link {
            color: var(--primary-1);
            text-decoration: none;
            font-weight: 500;
        }

        .link:hover {
            color: var(--primary-2);
            text-decoration: underline;
        }

        .btn {
            width: 100%;
            padding: 13px;
            border: none;
            border-radius: 12px;
            color: #fff;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            background: linear-gradient(135deg, var(--primary-1), var(--primary-2));
            box-shadow: 0 10px 24px rgba(102, 126, 234, 0.35);
            transition: transform 0.15s ease, box-shadow 0.15s ease;
        }

        .btn:hover {
            transform: translateY(-1px);
            box-shadow: 0 14px 30px rgba(118, 75, 162, 0.35);
        }

        .btn:active {
            transform: translateY(0);
        }

        .signup {
            text-align: center;
            margin-top: 18px;
            font-size: 13px;
            color: var(--text-muted);
        }

        .loader {
            display: none;
            width: 16px;
            height: 16px;
            border: 2px solid #f3f3f3;
            border-top: 2px solid #fff;
            border-radius: 50%;
            animation: spin 1s linear infinite;
            margin-right: 8px;
        }

        .btn.loading {
            opacity: 0.9;
            pointer-events: none;
        }

        .btn.loading .loader {
            display: inline-block;
            vertical-align: middle;
        }

        @keyframes spin {
            to { transform: rotate(360deg); }
        }

        @media (max-width: 520px) {
            .login-card {
                padding: 32px 24px;
            }
        }
    </style>
</head>
<body>
    <div class="login-card">
        <img class="logo" src="./logo.jpeg" alt="Logo" onerror="this.src='https://ui-avatars.com/api/?name=HIS&background=667eea&color=fff'">
        <div class="title">hiperInventorySolutions</div>
        <div class="subtitle">Sistema de Gestión de Activos</div>

        <% if (!message.isEmpty()) { %>
            <div class="alert">
                <i class="fas fa-exclamation-circle"></i>
                <%= message %>
            </div>
        <% } %>

        <form action="loginAction.jsp" method="post" id="loginForm">
            <div class="field">
                <label for="username"><i class="fas fa-user"></i> Usuario</label>
                <input class="input" type="text" id="username" name="username" placeholder="Nombre de usuario" required>
            </div>

            <div class="field">
                <label for="password"><i class="fas fa-lock"></i> Contraseña</label>
                <input class="input" type="password" id="password" name="password" placeholder="Contraseña" required>
            </div>

            <div class="aux-row">
                <label class="remember">
                    <input type="checkbox" name="remember" value="on">
                    Recordarme
                </label>
                <a class="link" href="?action=forgot" id="forgotLink">¿Olvidaste tu contraseña?</a>
            </div>

            <button type="submit" class="btn">
                <span class="loader"></span>
                INGRESAR
            </button>
        </form>

        <div class="signup">
            ¿No tienes cuenta?
            <a class="link" href="?action=reHISter">Regístrate aquí</a>
        </div>
    </div>

    <script>
        const form = document.getElementById('loginForm');
        form.addEventListener('submit', function () {
            const btn = form.querySelector('.btn');
            btn.classList.add('loading');
        });

        document.getElementById('forgotLink').addEventListener('click', function (e) {
            e.preventDefault();
            const email = prompt('Ingresa tu email para restablecer tu contraseña:');
            if (email) {
                fetch('forgotPassword.jsp', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: 'email=' + encodeURIComponent(email)
                }).then(r => r.ok && alert('Se ha enviado un enlace de recuperación a tu email'));
            }
        });
    </script>
</body>
</html>
