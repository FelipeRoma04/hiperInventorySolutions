<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Verificar autenticación
    if (session.getAttribute("username") == null) {
        response.sendRedirect("index.jsp?error=session");
        return;
    }
    String username = (String) session.getAttribute("username");
    String userRole = "admin"; // Por defecto admin, en producción: de BD
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestión de Activos - hiperInventorySolutions</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="css/styles.css">
</head>
<body>
    <!-- SIDEBAR -->
    <aside class="sidebar">
        <div class="sidebar-header">
            <h1><i class="fas fa-cube"></i> GlobanInventory</h1>
        </div>
        <nav class="sidebar-nav">
            <li><a href="inicio.jsp"><i class="fas fa-chart-line"></i> Dashboard</a></li>
            <li><a href="activos_fase2.jsp" class="active"><i class="fas fa-box"></i> Activos</a></li>
            <li><a href="categorias.jsp"><i class="fas fa-tags"></i> Categorías</a></li>
            <li><a href="ubicaciones.jsp"><i class="fas fa-map-marker-alt"></i> Ubicaciones</a></li>
            <li><a href="usuarios.jsp"><i class="fas fa-users"></i> Usuarios</a></li>
            <li><a href="reportes.jsp"><i class="fas fa-file-pdf"></i> Reportes</a></li>
            <li><hr style="border: none; border-top: 1px solid rgba(255,255,255,0.1); margin: 15px 0;">
            <li><a href="logout.jsp"><i class="fas fa-sign-out-alt"></i> Cerrar Sesión</a></li>
        </nav>
    </aside>

    <!-- MAIN LAYOUT -->
    <div class="main-layout">
        <!-- TOP BAR -->
        <header class="topbar">
            <div>
                <button class="hamburger" onclick="document.querySelector('.sidebar').classList.toggle('collapsed'); document.querySelector('.main-layout').classList.toggle('sidebar-collapsed');">
                    <i class="fas fa-bars"></i>
                </button>
                <h2 class="topbar-title">Gestión de Activos</h2>
            </div>
            <div class="topbar-right">
                <!-- NOTIFICACIONES CAMPANA -->
                <div class="notification-bell" onclick="document.querySelector('.notification-center').classList.toggle('show')">
                    <i class="fas fa-bell"></i>
                    <span class="notification-badge" style="display: none;">3</span>
                </div>
                
                <!-- MENÚ USUARIO -->
                <div class="user-menu-dropdown">
                    <div class="user-menu">
                        <div class="user-avatar"><%= Character.toUpperCase(username.charAt(0)) %></div>
                        <span><%= username %></span>
                        <i class="fas fa-chevron-down" style="font-size: 12px;"></i>
                    </div>
                    <div class="dropdown-menu">
                        <button class="dropdown-item" data-action="edit-profile">
                            <i class="fas fa-user"></i> Mi Perfil
                        </button>
                        <button class="dropdown-item" data-action="change-password">
                            <i class="fas fa-lock"></i> Cambiar Contraseña
                        </button>
                        <div class="dropdown-divider"></div>
                        <div class="dropdown-item" style="font-weight: 600; color: #667eea;">
                            <i class="fas fa-shield"></i> Rol: <%= userRole.toUpperCase() %>
                        </div>
                        <a href="logout.jsp" class="dropdown-item">
                            <i class="fas fa-sign-out-alt"></i> Cerrar Sesión
                        </a>
                    </div>
                </div>
            </div>
        </header>

        <!-- NOTIFICATION CENTER -->
        <div class="notification-center">
            <!-- Se genera dinámicamente con JS -->
        </div>

        <!-- MAIN CONTENT -->
        <main class="main-content">
            <!-- CONTROLES DE TABLA -->
            <div class="table-container">
                <div class="table-controls">
                    <!-- BÚSQUEDA -->
                    <div class="search-box">
                        <i class="fas fa-search"></i>
                        <input type="text" placeholder="Buscar por nombre, código o categoría...">
                    </div>

                    <!-- FILTROS -->
                    <div class="filters">
                        <select class="filter-select" name="category-filter">
                            <option value="">Todas las Categorías</option>
                            <option value="Computadoras">Computadoras</option>
                            <option value="Equipos">Equipos</option>
                            <option value="Periféricos">Periféricos</option>
                            <option value="Muebles">Muebles</option>
                        </select>

                        <select class="filter-select" name="status-filter">
                            <option value="">Todos los Estados</option>
                            <option value="Operativo">Operativo</option>
                            <option value="Reparación">En Reparación</option>
                            <option value="Baja">Dado de Baja</option>
                            <option value="Préstamo">En Préstamo</option>
                        </select>

                        <select class="filter-select" name="location-filter">
                            <option value="">Todas las Ubicaciones</option>
                            <option value="Sede Central">Sede Central</option>
                            <option value="Alamcén">Almacén</option>
                            <option value="Piso 1">Piso 1</option>
                            <option value="Piso 2">Piso 2</option>
                        </select>
                    </div>

                    <!-- BOTONES DE ACCIÓN -->
                    <div class="action-buttons">
                        <button class="btn-bulk btn-export" onclick="exportToExcel()">
                            <i class="fas fa-file-excel"></i> Excel
                        </button>
                        <button class="btn-bulk btn-export" onclick="exportToPDF()">
                            <i class="fas fa-file-pdf"></i> PDF
                        </button>
                        <button class="btn-bulk btn-export" onclick="printQRCodes()">
                            <i class="fas fa-qrcode"></i> QR
                        </button>
                        <button class="btn-bulk btn-delete-bulk" onclick="deleteSelectedAssets()">
                            <i class="fas fa-trash"></i> Eliminar
                        </button>
                    </div>
                </div>

                <!-- CONTADOR DE SELECCIONADOS -->
                <div style="margin-bottom: 15px; color: #667eea; font-weight: 500;">
                    <span class="selected-count"></span>
                </div>

                <!-- TABLA DE ACTIVOS -->
                <table>
                    <thead>
                        <tr>
                            <th><input type="checkbox" id="select-all" class="checkbox"></th>
                            <th>Código</th>
                            <th>Nombre</th>
                            <th>Categoría</th>
                            <th>Ubicación</th>
                            <th>Estado</th>
                            <th>Foto</th>
                            <th>Valor</th>
                            <th>QR</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        <!-- Ejemplo 1 -->
                        <tr>
                            <td><input type="checkbox" class="row-checkbox checkbox" data-asset-id="001"></td>
                            <td><span class="location-badge" style="margin-left: 0;">Sed. C</span>ACT-001</td>
                            <td>Laptop Dell XPS 15</td>
                            <td data-category>Computadoras</td>
                            <td data-location>Sede Central</td>
                            <td><span class="badge badge-active">Operativo</span></td>
                            <td><img src="https://via.placeholder.com/40" style="width: 40px; border-radius: 4px;"></td>
                            <td>$1,200</td>
                            <td><button class="btn btn-icon btn-secondary" onclick="generateQRCode('ACT-001', 'Laptop'); openModal('qrModal')"><i class="fas fa-qrcode"></i></button></td>
                            <td>
                                <button class="btn btn-icon btn-secondary" onclick="openModal('editModal')" title="Editar">
                                    <i class="fas fa-edit"></i>
                                </button>
                                <button class="btn btn-icon btn-secondary" onclick="openModal('assignmentModal')" title="Asignar">
                                    <i class="fas fa-user-plus"></i>
                                </button>
                            </td>
                        </tr>

                        <!-- Ejemplo 2 -->
                        <tr>
                            <td><input type="checkbox" class="row-checkbox checkbox" data-asset-id="002"></td>
                            <td><span class="location-badge">Almacén</span>ACT-002</td>
                            <td>Impresora HP LaserJet</td>
                            <td data-category>Equipos</td>
                            <td data-location>Almacén</td>
                            <td><span class="badge badge-repair">En Reparación</span></td>
                            <td><img src="https://via.placeholder.com/40" style="width: 40px; border-radius: 4px;"></td>
                            <td>$450</td>
                            <td><button class="btn btn-icon btn-secondary" onclick="generateQRCode('ACT-002', 'Impresora'); openModal('qrModal')"><i class="fas fa-qrcode"></i></button></td>
                            <td>
                                <button class="btn btn-icon btn-secondary" onclick="openModal('editModal')">
                                    <i class="fas fa-edit"></i>
                                </button>
                                <button class="btn btn-icon btn-secondary" onclick="openModal('assignmentModal')">
                                    <i class="fas fa-user-plus"></i>
                                </button>
                            </td>
                        </tr>

                        <!-- Ejemplo 3 -->
                        <tr>
                            <td><input type="checkbox" class="row-checkbox checkbox" data-asset-id="003"></td>
                            <td><span class="location-badge">P1</span>ACT-003</td>
                            <td>Monitor Samsung 27"</td>
                            <td data-category>Periféricos</td>
                            <td data-location>Piso 1</td>
                            <td><span class="badge badge-active">Operativo</span></td>
                            <td><img src="https://via.placeholder.com/40" style="width: 40px; border-radius: 4px;"></td>
                            <td>$250</td>
                            <td><button class="btn btn-icon btn-secondary" onclick="generateQRCode('ACT-003', 'Monitor'); openModal('qrModal')"><i class="fas fa-qrcode"></i></button></td>
                            <td>
                                <button class="btn btn-icon btn-secondary" onclick="openModal('editModal')">
                                    <i class="fas fa-edit"></i>
                                </button>
                                <button class="btn btn-icon btn-secondary" onclick="openModal('assignmentModal')">
                                    <i class="fas fa-user-plus"></i>
                                </button>
                            </td>
                        </tr>

                        <!-- Más activos... -->
                    </tbody>
                </table>
            </div>
        </main>
    </div>

    <!-- MODAL: EDITAR ACTIVO -->
    <div id="editModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2 class="modal-title">Editar Activo</h2>
                <button class="modal-close" onclick="closeModal('editModal')">×</button>
            </div>
            <div class="modal-body">
                <form>
                    <div class="form-group">
                        <label>Código</label>
                        <input type="text" value="ACT-001" readonly>
                    </div>
                    <div class="form-group">
                        <label>Nombre del Activo</label>
                        <input type="text" value="Laptop Dell XPS 15">
                    </div>
                    <div class="form-group">
                        <label>Categoría</label>
                        <select>
                            <option>Computadoras</option>
                            <option>Equipos</option>
                            <option>Periféricos</option>
                            <option>Muebles</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Ubicación</label>
                        <select>
                            <option>Sede Central</option>
                            <option>Almacén</option>
                            <option>Piso 1</option>
                            <option>Piso 2</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Estado</label>
                        <select>
                            <option>Operativo</option>
                            <option>En Reparación</option>
                            <option>Dado de Baja</option>
                            <option>En Préstamo</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Valor ($)</label>
                        <input type="number" value="1200">
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button class="btn btn-secondary" onclick="closeModal('editModal')">Cancelar</button>
                <button class="btn btn-primary" onclick="alert('Activo actualizado'); closeModal('editModal')">Guardar</button>
            </div>
        </div>
    </div>

    <!-- MODAL: QR CODE -->
    <div id="qrModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2 class="modal-title">Código QR</h2>
                <button class="modal-close" onclick="closeModal('qrModal')">×</button>
            </div>
            <div class="modal-body">
                <div id="qr-container" class="qr-container"></div>
                <p style="text-align: center; color: #999; margin-top: 15px; font-size: 12px;">
                    Escanea este código para ver los detalles del activo
                </p>
            </div>
            <div class="modal-footer" style="justify-content: center;">
                <button class="btn btn-secondary" onclick="closeModal('qrModal')">Cerrar</button>
                <button class="btn btn-primary" onclick="downloadQRCode('ACT-001')">
                    <i class="fas fa-download"></i> Descargar
                </button>
            </div>
        </div>
    </div>

    <!-- MODAL: ASIGNACIÓN DE ACTIVO -->
    <div id="assignmentModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2 class="modal-title">Asignar Activo</h2>
                <button class="modal-close" onclick="closeModal('assignmentModal')">×</button>
            </div>
            <div class="modal-body">
                <form>
                    <div class="form-group">
                        <label>Usuario / Área</label>
                        <select>
                            <option>-- Seleccionar --</option>
                            <option>Juan Pérez (IT)</option>
                            <option>María García (Finanzas)</option>
                            <option>Almacén</option>
                            <option>Área de Ventas</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Fecha de Devolución Esperada</label>
                        <input type="date">
                    </div>
                    <div class="form-group">
                        <label>Notas</label>
                        <textarea rows="3" placeholder="Información adicional..."></textarea>
                    </div>
                </form>
                
                <!-- Historial de asignaciones anteriores -->
                <div class="assignment-section">
                    <h3 style="margin-bottom: 15px; font-size: 14px; font-weight: 600;">Historial de Asignaciones</h3>
                    <div class="assignment-item">
                        <div class="assignment-info">
                            <div class="assignment-user">Carlos López</div>
                            <div class="assignment-date">Asignado: 2024-01-15 | Devuelto: 2024-02-20</div>
                        </div>
                        <span class="assignment-badge">Completado</span>
                    </div>
                    <div class="assignment-item">
                        <div class="assignment-info">
                            <div class="assignment-user">Ana Rodríguez</div>
                            <div class="assignment-date">Asignado: 2023-11-10 | Devuelto: 2024-01-10</div>
                        </div>
                        <span class="assignment-badge">Completado</span>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button class="btn btn-secondary" onclick="closeModal('assignmentModal')">Cancelar</button>
                <button class="btn btn-primary" onclick="assignAsset('ACT-001', 'juan-perez', '2024-12-31'); closeModal('assignmentModal')">Asignar</button>
            </div>
        </div>
    </div>

    <!-- Cargar librerías -->
    <script src="js/qrcode.min.js"></script>
    <script src="js/app.js"></script>
    <script src="js/charts.js"></script>
</body>
</html>
