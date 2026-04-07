-- ============================================================
-- HiperInventory Solutions - SQL Server Schema
-- Instance: .\SQLEXPRESS  |  Auth: Windows
-- ============================================================

USE master;
GO

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'hiperInventorySolutions')
BEGIN
    CREATE DATABASE hiperInventorySolutions;
    PRINT 'Database hiperInventorySolutions created.';
END
GO

USE hiperInventorySolutions;
GO

-- ============================================================
-- USERS
-- ============================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'users')
BEGIN
    CREATE TABLE users (
        id           INT IDENTITY(1,1) PRIMARY KEY,
        username     NVARCHAR(100) UNIQUE NOT NULL,
        password     NVARCHAR(255) NOT NULL,
        email        NVARCHAR(255) UNIQUE NOT NULL,
        nombre       NVARCHAR(200) NOT NULL,
        apellido     NVARCHAR(200),
        rol          NVARCHAR(50) NOT NULL,
        departamento NVARCHAR(200),
        telefono     NVARCHAR(50),
        avatar       NVARCHAR(500),
        sede         NVARCHAR(200),
        activo       BIT DEFAULT 1,
        fecha_registro DATETIME2 DEFAULT GETDATE(),
        ultimo_acceso  DATETIME2
    );
    PRINT 'Table users created.';
END
GO

-- ============================================================
-- ASSETS
-- ============================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'assets')
BEGIN
    CREATE TABLE assets (
        id                      INT IDENTITY(1,1) PRIMARY KEY,
        nombre                  NVARCHAR(300) NOT NULL,
        codigo                  NVARCHAR(100) UNIQUE NOT NULL,
        descripcion             NVARCHAR(MAX),
        categoria               NVARCHAR(200) NOT NULL,
        estado                  NVARCHAR(100) NOT NULL,
        ubicacion               NVARCHAR(300),
        sede                    NVARCHAR(200),
        valor                   FLOAT DEFAULT 0,
        stock_minimo            INT DEFAULT 1,
        cantidad                INT DEFAULT 1,
        imagen_url              NVARCHAR(MAX),
        qr_code                 NVARCHAR(MAX),
        asignado_a              NVARCHAR(300),
        etiquetas               NVARCHAR(500),
        responsable             NVARCHAR(300),
        notas                   NVARCHAR(MAX),
        fecha_registro          DATETIME2 DEFAULT GETDATE(),
        fecha_compra            DATETIME2,
        fecha_asignacion        DATETIME2,
        fecha_devolucion_esperada DATETIME2
    );
    PRINT 'Table assets created.';
END
GO

-- ============================================================
-- ASSIGNMENTS
-- ============================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'assignments')
BEGIN
    CREATE TABLE assignments (
        id                      INT IDENTITY(1,1) PRIMARY KEY,
        asset_id                INT NOT NULL,
        user_id                 INT NOT NULL,
        area_departamento       NVARCHAR(200),
        estado                  NVARCHAR(50) DEFAULT 'ACTIVO',
        cantidad                INT DEFAULT 1,
        notas                   NVARCHAR(MAX),
        responsable             NVARCHAR(300),
        fecha_asignacion        DATETIME2 DEFAULT GETDATE(),
        fecha_devolucion_esperada DATETIME2,
        fecha_devolucion_real   DATETIME2,
        FOREIGN KEY (asset_id) REFERENCES assets(id),
        FOREIGN KEY (user_id)  REFERENCES users(id)
    );
    PRINT 'Table assignments created.';
END
GO

-- ============================================================
-- NOTIFICATIONS
-- ============================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'notifications')
BEGIN
    CREATE TABLE notifications (
        id             INT IDENTITY(1,1) PRIMARY KEY,
        user_id        INT NOT NULL,
        titulo         NVARCHAR(300) NOT NULL,
        mensaje        NVARCHAR(MAX) NOT NULL,
        tipo           NVARCHAR(50) NOT NULL,
        enlace         NVARCHAR(500),
        icono          NVARCHAR(100),
        leido          BIT DEFAULT 0,
        fecha_creacion DATETIME2 DEFAULT GETDATE(),
        FOREIGN KEY (user_id) REFERENCES users(id)
    );
    PRINT 'Table notifications created.';
END
GO

-- ============================================================
-- AUDIT LOG
-- ============================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'audit_log')
BEGIN
    CREATE TABLE audit_log (
        id             INT IDENTITY(1,1) PRIMARY KEY,
        user_id        INT,
        accion         NVARCHAR(100) NOT NULL,
        tabla          NVARCHAR(100) NOT NULL,
        registro_id    INT,
        valor_anterior NVARCHAR(MAX),
        valor_nuevo    NVARCHAR(MAX),
        ip_address     NVARCHAR(50),
        fecha_hora     DATETIME2 DEFAULT GETDATE(),
        FOREIGN KEY (user_id) REFERENCES users(id)
    );
    CREATE INDEX idx_audit_user  ON audit_log(user_id);
    CREATE INDEX idx_audit_tabla ON audit_log(tabla);
    CREATE INDEX idx_audit_fecha ON audit_log(fecha_hora);
    PRINT 'Table audit_log created.';
END
GO

-- ============================================================
-- CATEGORIAS
-- ============================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'categorias')
BEGIN
    CREATE TABLE categorias (
        id             INT IDENTITY(1,1) PRIMARY KEY,
        nombre         NVARCHAR(200) UNIQUE NOT NULL,
        descripcion    NVARCHAR(MAX),
        icono          NVARCHAR(200),
        fecha_creacion DATETIME2 DEFAULT GETDATE()
    );
    PRINT 'Table categorias created.';
END
GO

-- ============================================================
-- UBICACIONES
-- ============================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ubicaciones')
BEGIN
    CREATE TABLE ubicaciones (
        id             INT IDENTITY(1,1) PRIMARY KEY,
        nombre         NVARCHAR(300) UNIQUE NOT NULL,
        sede           NVARCHAR(200),
        descripcion    NVARCHAR(MAX),
        fecha_creacion DATETIME2 DEFAULT GETDATE()
    );
    PRINT 'Table ubicaciones created.';
END
GO

-- ============================================================
-- MAINTENANCE
-- ============================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'maintenance')
BEGIN
    CREATE TABLE maintenance (
        id             INT IDENTITY(1,1) PRIMARY KEY,
        asset_id       INT NOT NULL,
        type           NVARCHAR(100) NOT NULL,
        description    NVARCHAR(MAX),
        scheduled_date DATE NOT NULL,
        completed_date DATE,
        status         NVARCHAR(50) DEFAULT 'Pendiente',
        technician     NVARCHAR(300),
        notes          NVARCHAR(MAX),
        cost           FLOAT DEFAULT 0,
        priority       NVARCHAR(50) DEFAULT 'Media',
        created_at     DATETIME2 DEFAULT GETDATE(),
        updated_at     DATETIME2,
        FOREIGN KEY (asset_id) REFERENCES assets(id)
    );
    PRINT 'Table maintenance created.';
END
GO

-- ============================================================
-- DEPRECIATION
-- ============================================================
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'depreciation')
BEGIN
    CREATE TABLE depreciation (
        id                      INT IDENTITY(1,1) PRIMARY KEY,
        asset_id                INT NOT NULL UNIQUE,
        purchase_price          FLOAT NOT NULL,
        residual_value          FLOAT DEFAULT 0,
        useful_life             INT NOT NULL,
        purchase_date           DATE NOT NULL,
        method                  NVARCHAR(50) DEFAULT 'Linear',
        depreciation_rate       FLOAT DEFAULT 0,
        monthly_depreciation    FLOAT DEFAULT 0,
        accumulated_depreciation FLOAT DEFAULT 0,
        current_value           FLOAT DEFAULT 0,
        last_calculated         DATETIME2,
        FOREIGN KEY (asset_id) REFERENCES assets(id)
    );
    PRINT 'Table depreciation created.';
END
GO

-- ============================================================
-- SEED DATA
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM users WHERE username = 'admin')
BEGIN
    INSERT INTO users (username, password, email, nombre, rol, departamento, sede)
    VALUES ('admin', 'admin123', 'admin@hiperinventory.com', 'Administrador', 'ADMIN', 'IT', 'Principal');

    INSERT INTO categorias (nombre, icono) VALUES
        ('Computadoras', 'fas fa-laptop'),
        ('Accesorios',   'fas fa-keyboard'),
        ('Muebles',      'fas fa-chair'),
        ('Electronica',  'fas fa-tv'),
        ('Otros',        'fas fa-box');

    INSERT INTO ubicaciones (nombre, sede) VALUES
        ('Almacen Central', 'Principal'),
        ('Piso 1',          'Principal'),
        ('Piso 2',          'Principal'),
        ('Recepcion',       'Principal');

    INSERT INTO assets (nombre, codigo, categoria, estado, ubicacion, sede, valor, cantidad, stock_minimo) VALUES
        ('Laptop Dell XPS',      'ACT-001', 'Computadoras', 'Operativo',      'Piso 1',          'Principal', 1200, 5, 2),
        ('Laptop HP EliteBook',  'ACT-002', 'Computadoras', 'Operativo',      'Piso 2',          'Principal', 950,  3, 2),
        ('Impresora HP LaserJet','ACT-003', 'Electronica',  'En reparacion',  'Recepcion',       'Principal', 450,  1, 1),
        ('Monitor Samsung 27',   'ACT-004', 'Electronica',  'Operativo',      'Piso 1',          'Principal', 280,  8, 3),
        ('Escritorio Ejecutivo', 'ACT-005', 'Muebles',      'Operativo',      'Piso 2',          'Principal', 350, 10, 2),
        ('Silla Ergonomica',     'ACT-006', 'Muebles',      'Operativo',      'Piso 1',          'Principal', 220, 15, 5),
        ('Mouse Logitech MX',    'ACT-007', 'Accesorios',   'Operativo',      'Almacen Central', 'Principal', 45,   1, 3),
        ('Teclado Mecanico',     'ACT-008', 'Accesorios',   'En prestamo',    'Piso 2',          'Principal', 85,   4, 2),
        ('Servidor Dell',        'ACT-009', 'Computadoras', 'Operativo',      'Almacen Central', 'Principal', 3500, 2, 1),
        ('Proyector Epson',      'ACT-010', 'Electronica',  'Baja',           'Recepcion',       'Principal', 600,  1, 1),
        ('Switch Cisco 24p',     'ACT-011', 'Electronica',  'Operativo',      'Almacen Central', 'Principal', 800,  2, 1),
        ('Tablet iPad Pro',      'ACT-012', 'Computadoras', 'En prestamo',    'Piso 1',          'Principal', 750,  3, 1);

    PRINT 'Seed data inserted.';
END
GO

PRINT 'Schema ready: hiperInventorySolutions';
GO
