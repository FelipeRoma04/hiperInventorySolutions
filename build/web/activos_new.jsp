<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Verificar autenticación
    if (session.getAttribute("username") == null) {
        response.sendRedirect("index.jsp?error=session");
        return;
    }
    String username = (String) session.getAttribute("username");
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
            <h1><i class="fas fa-cube"></i> HiperInventory</h1>
        </div>
        <nav class="sidebar-nav">
            <li><a href="inicio.jsp"><i class="fas fa-chart-line"></i> Dashboard</a></li>
            <li><a href="activos.jsp" class="active"><i class="fas fa-box"></i> Activos</a></li>
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
                <div class="user-menu">
                    <div class="user-avatar"><%= Character.toUpperCase(username.charAt(0)) %></div>
                    <span><%= username %></span>
                </div>
            </div>
        </header>

        <!-- MAIN CONTENT -->
        <main class="main-content">
            <!-- TABLA DE ACTIVOS -->
            <div class="table-container">
                <!-- CONTROLES -->
                <div class="table-controls">
                    <!-- BÃšSQUEDA -->
                    <div class="search-box">
                        <i class="fas fa-search"></i>
                        <input type="text" placeholder="Buscar activo por nombre, código o categoría...">
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
                            <option value="Oficina">Oficina</option>
                            <option value="Almacén">Almacén</option>
                            <option value="Piso 1">Piso 1</option>
                            <option value="Piso 2">Piso 2</option>
                        </select>
                    </div>

                    <!-- BOTONES DE ACCIÃ“N -->
                    <div class="action-buttons">
                        <button class="btn-bulk btn-delete-bulk" onclick="deleteSelectedAssets()">
                            <i class="fas fa-trash"></i> Eliminar
                        </button>
                        <button class="btn-bulk btn-export" onclick="exportSelected()">
                            <i class="fas fa-download"></i> Exportar
                        </button>
                    </div>
                </div>

                <!-- CONTADOR DE SELECCIONADOS -->
                <div style="margin-bottom: 15px; color: #667eea; font-weight: 500;">
                    <span class="selected-count"></span>
                </div>

                <!-- TABLA -->
                <table>
                    <thead>
                        <tr>
                            <th><input type="checkbox" id="select-all" class="checkbox"></th>
                            <th>Código</th>
                            <th>Nombre</th>
                            <th data-category>Categoría</th>
                            <th data-location>Ubicación</th>
                            <th>Estado</th>
                            <th>Foto</th>
                            <th>Valor ($)</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        <!-- Ejemplo 1: Computadora Operativa -->
                        <tr>
                            <td><input type="checkbox" class="row-checkbox checkbox" data-asset-id="001"></td>
                            <td>ACT-001</td>
                            <td>Laptop Dell XPS 15</td>
                            <td data-category>Computadoras</td>
                            <td data-location>Oficina</td>
                            <td><span class="badge badge-active">Operativo</span></td>
                            <td><img src="https://via.placeholder.com/40" style="width: 40px; border-radius: 4px;"></td>
                            <td>$1,200</td>
                            <td>
                                <button class="btn btn-secondary btn-small" onclick="openModal('editModal')">
                                    <i class="fas fa-edit"></i>
                                </button>
                            </td>
                        </tr>

                        <!-- Ejemplo 2: Impresora en Reparación -->
                        <tr>
                            <td><input type="checkbox" class="row-checkbox checkbox" data-asset-id="002"></td>
                            <td>ACT-002</td>
                            <td>Impresora HP LaserJet</td>
                            <td data-category>Equipos</td>
                            <td data-location>Almacén</td>
                            <td><span class="badge badge-repair">En Reparación</span></td>
                            <td><img src="https://via.placeholder.com/40" style="width: 40px; border-radius: 4px;"></td>
                            <td>$450</td>
                            <td>
                                <button class="btn btn-secondary btn-small" onclick="openModal('editModal')">
                                    <i class="fas fa-edit"></i>
                                </button>
                            </td>
                        </tr>

                        <!-- Ejemplo 3: Monitor Operativo -->
                        <tr>
                            <td><input type="checkbox" class="row-checkbox checkbox" data-asset-id="003"></td>
                            <td>ACT-003</td>
                            <td>Monitor Samsung 27"</td>
                            <td data-category>Periféricos</td>
                            <td data-location>Piso 1</td>
                            <td><span class="badge badge-active">Operativo</span></td>
                            <td><img src="https://via.placeholder.com/40" style="width: 40px; border-radius: 4px;"></td>
                            <td>$250</td>
                            <td>
                                <button class="btn btn-secondary btn-small" onclick="openModal('editModal')">
                                    <i class="fas fa-edit"></i>
                                </button>
                            </td>
                        </tr>

                        <!-- Ejemplo 4: Escritorio Dado de Baja -->
                        <tr>
                            <td><input type="checkbox" class="row-checkbox checkbox" data-asset-id="004"></td>
                            <td>ACT-004</td>
                            <td>Escritorio Ejecutivo</td>
                            <td data-category>Muebles</td>
                            <td data-location>Almacén</td>
                            <td><span class="badge badge-inactive">Dado de Baja</span></td>
                            <td><img src="https://via.placeholder.com/40" style="width: 40px; border-radius: 4px;"></td>
                            <td>$300</td>
                            <td>
                                <button class="btn btn-secondary btn-small" onclick="openModal('editModal')">
                                    <i class="fas fa-edit"></i>
                                </button>
                            </td>
                        </tr>

                        <!-- Ejemplo 5: Teclado en Préstamo -->
                        <tr>
                            <td><input type="checkbox" class="row-checkbox checkbox" data-asset-id="005"></td>
                            <td>ACT-005</td>
                            <td>Teclado Mecánico Logitech</td>
                            <td data-category>Periféricos</td>
                            <td data-location>Piso 2</td>
                            <td><span class="badge badge-loan">En Préstamo</span></td>
                            <td><img src="https://via.placeholder.com/40" style="width: 40px; border-radius: 4px;"></td>
                            <td>$120</td>
                            <td>
                                <button class="btn btn-secondary btn-small" onclick="openModal('editModal')">
                                    <i class="fas fa-edit"></i>
                                </button>
                            </td>
                        </tr>

                        <!-- Ejemplo 6: Cable Red Operativo -->
                        <tr>
                            <td><input type="checkbox" class="row-checkbox checkbox" data-asset-id="006"></td>
                            <td>ACT-006</td>
                            <td>Cable de Red Cat6 (50m)</td>
                            <td data-category>Periféricos</td>
                            <td data-location>Almacén</td>
                            <td><span class="badge badge-active">Operativo</span></td>
                            <td><img src="https://via.placeholder.com/40" style="width: 40px; border-radius: 4px;"></td>
                            <td>$85</td>
                            <td>
                                <button class="btn btn-secondary btn-small" onclick="openModal('editModal')">
                                    <i class="fas fa-edit"></i>
                                </button>
                            </td>
                        </tr>

                        <!-- Ejemplo 7: Silla de Oficina -->
                        <tr>
                            <td><input type="checkbox" class="row-checkbox checkbox" data-asset-id="007"></td>
                            <td>ACT-007</td>
                            <td>Silla Ergonómica de Oficina</td>
                            <td data-category>Muebles</td>
                            <td data-location>Piso 1</td>
                            <td><span class="badge badge-active">Operativo</span></td>
                            <td><img src="https://via.placeholder.com/40" style="width: 40px; border-radius: 4px;"></td>
                            <td>$350</td>
                            <td>
                                <button class="btn btn-secondary btn-small" onclick="openModal('editModal')">
                                    <i class="fas fa-edit"></i>
                                </button>
                            </td>
                        </tr>

                        <!-- Ejemplo 8: Mouse Operativo -->
                        <tr>
                            <td><input type="checkbox" class="row-checkbox checkbox" data-asset-id="008"></td>
                            <td>ACT-008</td>
                            <td>Mouse Inalámbrico Logitech</td>
                            <td data-category>Periféricos</td>
                            <td data-location>Piso 2</td>
                            <td><span class="badge badge-active">Operativo</span></td>
                            <td><img src="https://via.placeholder.com/40" style="width: 40px; border-radius: 4px;"></td>
                            <td>$45</td>
                            <td>
                                <button class="btn btn-secondary btn-small" onclick="openModal('editModal')">
                                    <i class="fas fa-edit"></i>
                                </button>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </main>
    </div>

    <!-- MODAL EDITAR ACTIVO -->
    <div id="editModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2 class="modal-title">Editar Activo</h2>
                <button class="modal-close" onclick="closeModal('editModal')">Ã—</button>
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
                        <label>Estado</label>
                        <select>
                            <option>Operativo</option>
                            <option>En Reparación</option>
                            <option>Dado de Baja</option>
                            <option>En Préstamo</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label>Ubicación</label>
                        <input type="text" value="Oficina">
                    </div>

                    <div class="form-group">
                        <label>Valor ($)</label>
                        <input type="number" value="1200" step="0.01">
                    </div>

                    <div class="form-group">
                        <label>Foto/Imagen</label>
                        <div class="upload-area" id="uploadArea" onclick="document.getElementById('imageInput').click()">
                            <i class="fas fa-cloud-upload-alt"></i>
                            <p>Arrastra tu imagen aquí o haz clic para seleccionar</p>
                            <small>PNG, JPG, GIF (Max 5MB)</small>
                        </div>
                        <input type="file" id="imageInput" accept="image/*" style="display: none;">
                        <div id="imagePreview"></div>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button class="btn btn-secondary" onclick="closeModal('editModal')">Cancelar</button>
                <button class="btn btn-primary">Guardar Cambios</button>
            </div>
        </div>
    </div>

    <!-- SCRIPTS -->
    <script src="js/app.js"></script>
    <script>
        // Configurar drag & drop para carga de imágenes
        setupDragDrop('uploadArea', 'imageInput');
        setupImageUpload('imageInput', 'imagePreview');
    </script>
</body>
</html>
