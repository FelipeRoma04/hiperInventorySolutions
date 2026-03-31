<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Inicio - Global Inventory Solutions</title>
    <style>
        body {
            margin: 0;
            padding: 0;
            font-family: Arial, sans-serif;
            background: url('fondo.jpg') no-repeat center center fixed;
            background-size: cover;
        }

        .dashboard-container {
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
        }

        .dashboard-box {
            background: rgba(255, 255, 255, 0.9);
            padding: 30px;
            border-radius: 15px;
            width: 800px;
            box-shadow: 0px 0px 15px rgba(0,0,0,0.3);
        }

        .dashboard-header {
            text-align: center;
            margin-bottom: 25px;
        }

        .dashboard-header h2 {
            margin: 0;
            color: #333;
        }

        .dashboard-header span {
            color: #1E90FF;
            font-weight: bold;
        }

        .menu {
            display: flex;
            flex-direction: column;
            width: 200px;
            float: left;
        }

        .menu button {
            background: #f0f0f0;
            border: none;
            margin: 6px 0;
            padding: 12px;
            text-align: left;
            border-radius: 8px;
            cursor: pointer;
            font-weight: bold;
        }

        .menu button:hover {
            background: #dcdcdc;
        }

        .content {
            margin-left: 220px;
        }

        .cards {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 15px;
        }

        .card {
            background: #fff;
            padding: 15px;
            border-radius: 10px;
            text-align: center;
            box-shadow: 0px 0px 10px rgba(0,0,0,0.1);
        }

        .card h3 {
            margin: 10px 0;
        }

        .chart {
            margin-top: 20px;
            background: #fff;
            padding: 15px;
            border-radius: 10px;
            text-align: center;
            box-shadow: 0px 0px 10px rgba(0,0,0,0.1);
        }

        .footer {
            text-align: center;
            margin-top: 20px;
            font-size: 12px;
            color: #555;
        }
    </style>
</head>
<body>
    <div class="dashboard-container">
        <div class="dashboard-box">
            <div class="dashboard-header">
            	<img src="./logo.jpeg" alt="Logo" width="60">
                <h2><span>Global</span> Inventory Solutions</h2>
                <h3>Dashboard - Menú Principal</h3>
            </div>

            <div class="menu">
                <button>🏠 Home</button>
                <button>➕ Añadir activos</button>
                <button>📦 Activos</button>
                <button>📂 Modificar activos</button>
                <button>🗑 Eliminar</button>
                <button>📄 Ver Hoja de vida</button>
            </div>

            <div class="content">
                <h3>Resumen del Inventario</h3>
                <div class="cards">
                    <div class="card">
                        <h3>Total Activos</h3>
                        <p><strong>1,250</strong></p>
                    </div>
                    <div class="card">
                        <h3>Activos Fijos</h3>
                        <p><strong>890</strong></p>
                    </div>
                    <div class="card">
                        <h3>Activos de Consumo</h3>
                        <p><strong>360</strong></p>
                    </div>
                </div>

                <div class="chart">
                    <h3>Analytics del Inventario</h3>
                    <img src="./grafico.jpeg" alt="Gráfico" width="90%">
                    <br><br>
                    <button style="padding:10px; background:#1E90FF; color:#fff; border:none; border-radius:5px;">Generar Reporte</button>
                </div>
            </div>

            
        </div>
    </div>
</body>
</html>
