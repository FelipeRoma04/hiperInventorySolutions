<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mantenimiento Preventivo - HiperInventory</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link rel="stylesheet" href="css/styles.css">
    <style>
        .maintenance-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 20px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }
        .maintenance-timeline {
            position: relative;
            padding: 20px 0;
        }
        .timeline-item {
            display: flex;
            margin-bottom: 30px;
            position: relative;
        }
        .timeline-marker {
            width: 40px;
            height: 40px;
            background: #667eea;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: bold;
            margin-right: 20px;
            flex-shrink: 0;
        }
        .timeline-marker.completed {
            background: #4caf50;
        }
        .timeline-marker.pending {
            background: #ff9800;
        }
        .timeline-marker.overdue {
            background: #f44336;
        }
        .timeline-content {
            flex: 1;
            background: white;
            padding: 15px;
            border-radius: 8px;
            border-left: 3px solid #667eea;
        }
        .timeline-content.completed {
            border-left-color: #4caf50;
        }
        .timeline-content.pending {
            border-left-color: #ff9800;
        }
        .timeline-content.overdue {
            border-left-color: #f44336;
        }
        .maintenance-badge {
            display: inline-block;
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: bold;
            margin-right: 10px;
        }
        .badge-completed {
            background: #e8f5e9;
            color: #2e7d32;
        }
        .badge-pending {
            background: #fff3e0;
            color: #e65100;
        }
        .badge-overdue {
            background: #ffebee;
            color: #c62828;
        }
        .schedule-form {
            background: white;
            padding: 25px;
            border-radius: 10px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .form-group {
            margin-bottom: 15px;
        }
        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: #333;
        }
        .form-group input, 
        .form-group select, 
        .form-group textarea {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 14px;
        }
        .form-group textarea {
            resize: vertical;
            min-height: 80px;
        }
        .btn-schedule {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            padding: 12px 30px;
            border-radius: 5px;
            cursor: pointer;
            font-weight: 600;
            transition: transform 0.3s;
        }
        .btn-schedule:hover {
            transform: translateY(-2px);
        }
        .maintenance-stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        .stat-box {
            background: white;
            padding: 20px;
            border-radius: 10px;
            text-align: center;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            border-top: 4px solid #667eea;
        }
        .stat-number {
            font-size: 32px;
            font-weight: bold;
            color: #667eea;
        }
        .stat-label {
            color: #666;
            margin-top: 8px;
            font-size: 14px;
        }
    </style>
</head>
<body>
    <div class="layout">
        <!-- Sidebar -->
        <aside class="sidebar">
            <div class="logo">
                <i class="fas fa-box"></i> HiperInventory
            </div>
            <nav class="menu">
                <a href="inicio.jsp"><i class="fas fa-home"></i> Dashboard</a>
                <a href="activos.jsp"><i class="fas fa-cubes"></i> Activos</a>
                <a href="mantenimiento.jsp" class="active"><i class="fas fa-tools"></i> Mantenimiento</a>
                <a href="depreciation.jsp"><i class="fas fa-chart-line"></i> Depreciación</a>
                <a href="importar.jsp"><i class="fas fa-upload"></i> Importar</a>
                <a href="reportes.jsp"><i class="fas fa-file-pdf"></i> Reportes</a>
                <a href="usuarios.jsp"><i class="fas fa-users"></i> Usuarios</a>
            </nav>
        </aside>

        <!-- Main Content -->
        <main class="main-content">
            <!-- Topbar -->
            <div class="topbar">
                <div class="topbar-left">
                    <button id="menu-toggle" class="menu-toggle">
                        <i class="fas fa-bars"></i>
                    </button>
                    <h1>Mantenimiento Preventivo</h1>
                </div>
                <div class="topbar-right">
                    <div class="user-menu">
                        <img src="https://via.placeholder.com/40" alt="Avatar" class="avatar">
                        <span class="user-name">Admin</span>
                        <div class="dropdown-menu">
                            <a href="#"><i class="fas fa-user"></i> Mi Perfil</a>
                            <a href="#"><i class="fas fa-key"></i> Cambiar Contraseña</a>
                            <a href="logout.jsp"><i class="fas fa-sign-out-alt"></i> Cerrar Sesión</a>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Content -->
            <div class="content">
                <!-- Statistics -->
                <div class="maintenance-stats">
                    <div class="stat-box">
                        <div class="stat-number" id="stat-total">12</div>
                        <div class="stat-label">Mantenimientos Programados</div>
                    </div>
                    <div class="stat-box">
                        <div class="stat-number" id="stat-completed">8</div>
                        <div class="stat-label">Completados</div>
                    </div>
                    <div class="stat-box">
                        <div class="stat-number" id="stat-pending">3</div>
                        <div class="stat-label">Pendientes</div>
                    </div>
                    <div class="stat-box">
                        <div class="stat-number" id="stat-overdue">1</div>
                        <div class="stat-label">Vencidos</div>
                    </div>
                </div>

                <!-- Schedule New Maintenance -->
                <div class="maintenance-card">
                    <h3><i class="fas fa-calendar-plus"></i> Programar Nuevo Mantenimiento</h3>
                </div>

                <div class="schedule-form">
                    <form id="maintenance-form">
                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
                            <div class="form-group">
                                <label>Activo *</label>
                                <select id="asset-select" required>
                                    <option value="">Seleccionar activo...</option>
                                    <option value="1">Computadora Desktop - AST001</option>
                                    <option value="2">Laptop Dell - AST002</option>
                                    <option value="3">Impresora HP - AST003</option>
                                    <option value="4">Servidor - AST004</option>
                                </select>
                            </div>
                            <div class="form-group">
                                <label>Tipo de Mantenimiento *</label>
                                <select id="maintenance-type" required>
                                    <option value="">Seleccionar tipo...</option>
                                    <option value="preventivo">Preventivo</option>
                                    <option value="correctivo">Correctivo</option>
                                    <option value="inspección">Inspección</option>
                                    <option value="limpieza">Limpieza</option>
                                </select>
                            </div>
                        </div>

                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
                            <div class="form-group">
                                <label>Fecha Programada *</label>
                                <input type="date" id="maintenance-date" required>
                            </div>
                            <div class="form-group">
                                <label>Frecuencia (días) *</label>
                                <input type="number" id="frequency" placeholder="ej: 30" min="1" required>
                            </div>
                        </div>

                        <div class="form-group">
                            <label>Descripción</label>
                            <textarea id="description" placeholder="Describir el mantenimiento..."></textarea>
                        </div>

                        <button type="submit" class="btn-schedule">
                            <i class="fas fa-save"></i> Programar Mantenimiento
                        </button>
                    </form>
                </div>

                <!-- Maintenance History Timeline -->
                <div style="margin-top: 40px;">
                    <h2>Historial de Mantenimientos</h2>
                    <div class="maintenance-timeline" id="timeline">
                        <!-- Completed -->
                        <div class="timeline-item">
                            <div class="timeline-marker completed"><i class="fas fa-check"></i></div>
                            <div class="timeline-content completed">
                                <div style="display: flex; justify-content: space-between; align-items: start;">
                                    <div>
                                        <h4>Servidor - AST004</h4>
                                        <p><strong>Mantenimiento Preventivo</strong></p>
                                        <p style="color: #666; font-size: 13px;">Actualización de software, limpieza de filtros</p>
                                        <p style="margin-top: 10px;">
                                            <span class="maintenance-badge badge-completed">Completado</span>
                                            <small style="color: #999;">15 Mar 2026 - Técnico: Juan García</small>
                                        </p>
                                    </div>
                                    <div style="text-align: right;">
                                        <button class="btn btn-sm btn-info"><i class="fas fa-eye"></i> Detalles</button>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Pending -->
                        <div class="timeline-item">
                            <div class="timeline-marker pending"><i class="fas fa-clock"></i></div>
                            <div class="timeline-content pending">
                                <div style="display: flex; justify-content: space-between; align-items: start;">
                                    <div>
                                        <h4>Laptop Dell - AST002</h4>
                                        <p><strong>Inspección de Hardware</strong></p>
                                        <p style="color: #666; font-size: 13px;">Revisión de disco, RAM y batería</p>
                                        <p style="margin-top: 10px;">
                                            <span class="maintenance-badge badge-pending">Pendiente</span>
                                            <small style="color: #999;">Programado: 20 Abr 2026</small>
                                        </p>
                                    </div>
                                    <div style="text-align: right;">
                                        <button class="btn btn-sm btn-secondary"><i class="fas fa-edit"></i> Editar</button>
                                        <button class="btn btn-sm btn-success"><i class="fas fa-check"></i> Completar</button>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Overdue -->
                        <div class="timeline-item">
                            <div class="timeline-marker overdue"><i class="fas fa-exclamation"></i></div>
                            <div class="timeline-content overdue">
                                <div style="display: flex; justify-content: space-between; align-items: start;">
                                    <div>
                                        <h4>Impresora HP - AST003</h4>
                                        <p><strong>Cambio de Tóner</strong></p>
                                        <p style="color: #666; font-size: 13px;">Cambio de cartucho y limpieza</p>
                                        <p style="margin-top: 10px;">
                                            <span class="maintenance-badge badge-overdue">Vencido</span>
                                            <small style="color: #999;">Vencía: 10 Mar 2026 - PENDIENTE</small>
                                        </p>
                                    </div>
                                    <div style="text-align: right;">
                                        <button class="btn btn-sm btn-danger"><i class="fas fa-exclamation-triangle"></i> Urgente</button>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- More items -->
                        <div class="timeline-item">
                            <div class="timeline-marker completed"><i class="fas fa-check"></i></div>
                            <div class="timeline-content completed">
                                <div style="display: flex; justify-content: space-between; align-items: start;">
                                    <div>
                                        <h4>Computadora Desktop - AST001</h4>
                                        <p><strong>Limpieza de Componentes</strong></p>
                                        <p style="color: #666; font-size: 13px;">Limpieza interna y ventiladores</p>
                                        <p style="margin-top: 10px;">
                                            <span class="maintenance-badge badge-completed">Completado</span>
                                            <small style="color: #999;">01 Mar 2026 - Técnico: María López</small>
                                        </p>
                                    </div>
                                    <div style="text-align: right;">
                                        <button class="btn btn-sm btn-info"><i class="fas fa-eye"></i> Detalles</button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <!-- Estilos adicionales inline -->
    <style>
        .btn {
            padding: 8px 15px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 13px;
            transition: all 0.3s;
        }
        .btn-sm {
            padding: 6px 12px;
            font-size: 12px;
        }
        .btn-info {
            background: #2196F3;
            color: white;
        }
        .btn-info:hover {
            background: #1976D2;
        }
        .btn-secondary {
            background: #757575;
            color: white;
        }
        .btn-secondary:hover {
            background: #616161;
        }
        .btn-success {
            background: #4caf50;
            color: white;
        }
        .btn-success:hover {
            background: #388e3c;
        }
        .btn-danger {
            background: #f44336;
            color: white;
        }
        .btn-danger:hover {
            background: #d32f2f;
        }
    </style>

    <script>
        document.getElementById('maintenance-form').addEventListener('submit', function(e) {
            e.preventDefault();
            
            const formData = {
                assetId: document.getElementById('asset-select').value,
                type: document.getElementById('maintenance-type').value,
                scheduledDate: document.getElementById('maintenance-date').value,
                frequency: document.getElementById('frequency').value,
                description: document.getElementById('description').value
            };
            
            // Aquí iría la llamada al backend
            console.log('Mantenimiento programado:', formData);
            alert('Mantenimiento programado exitosamente');
            this.reset();
        });

        // Toggle sidebar
        document.getElementById('menu-toggle').addEventListener('click', function() {
            document.querySelector('.sidebar').classList.toggle('collapsed');
            document.querySelector('.main-content').classList.toggle('expanded');
        });
    </script>
</body>
</html>
