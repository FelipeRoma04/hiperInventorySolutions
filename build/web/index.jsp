<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Login - Global Inventory Solutions</title>
    <style>
        body {
            margin: 0;
    		padding: 0;
    		font-family: Arial, sans-serif;
    		background: url('./fondo.jpg') no-repeat center center fixed;
    		background-size: cover; /* Cubre todo el fondo */
        }

        .login-container {
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
        }

        .login-box {
            background: rgba(255, 255, 255, 0.9);
            padding: 30px;
            border-radius: 15px;
            width: 350px;
            text-align: center;
            box-shadow: 0px 0px 15px rgba(0,0,0,0.3);
        }

        .login-box h2 {
            margin-bottom: 20px;
            color: #333;
        }

        .login-box input[type="text"],
        .login-box input[type="password"] {
            width: 90%;
            padding: 12px;
            margin: 10px 0;
            border: 1px solid #ccc;
            border-radius: 8px;
        }

        .login-box input[type="checkbox"] {
            margin-right: 8px;
        }

        .login-box button {
            width: 95%;
            padding: 12px;
            background-color: #1E90FF;
            color: white;
            font-weight: bold;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            margin-top: 10px;
        }

        .login-box button:hover {
            background-color: #0078e7;
        }

        .login-box a {
            display: block;
            margin-top: 15px;
            font-size: 14px;
            color: #0078e7;
            text-decoration: none;
        }

        .login-box a:hover {
            text-decoration: underline;
        }

        .footer {
            text-align: center;
            margin-top: 15px;
            font-size: 12px;
            color: #555;
        }
    </style>
</head>
<body>
    <div class="login-container">
        <div class="login-box">
            <img src="./logo.jpeg" alt="Logo" width="60">
            
            <h3>INICIO DE SESIÓN</h3>

            <form action="inicio.jsp" method="post">
    		<input type="text" name="username" placeholder="Nombre de usuario"><br>
    		<input type="password" name="password" placeholder="Contraseña"><br>
    		<label>
        	<input type="checkbox" name="remember"> Recordarme
    		</label><br>
    		<button type="submit">INGRESAR</button>
			</form>
	
            <a href="recuperar.jsp">¿Olvidaste tu contraseña?</a>
            <a href="registro.jsp">Crear una cuenta</a>

            <div class="footer">
                Desarrollado por FyF
            </div>
        </div>
    </div>
</body>
</html>
