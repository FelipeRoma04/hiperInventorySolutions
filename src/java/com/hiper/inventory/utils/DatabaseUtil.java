package com.hiper.inventory.utils;

import java.sql.*;

/**
 * Utilidad para manejar conexiones a SQL Server.
 * Configuración via variables de entorno para soporte Docker.
 *
 * Variables de entorno:
 *   DB_HOST     - hostname del servidor SQL (default: sqlserver)
 *   DB_PORT     - puerto TCP (default: 1433)
 *   DB_NAME     - nombre de la base de datos (default: hiperInventorySolutions)
 *   DB_USER     - usuario SQL (default: sa)
 *   DB_PASSWORD - contraseña SQL (default: HiperApp2024!)
 */
public class DatabaseUtil {

    private static String buildUrl() {
        String host     = getEnv("DB_HOST",     "sqlserver");
        String port     = getEnv("DB_PORT",     "1433");
        String dbName   = getEnv("DB_NAME",     "hiperInventorySolutions");
        String user     = getEnv("DB_USER",     "sa");
        String password = getEnv("DB_PASSWORD", "HiperApp2024!");
        return "jdbc:sqlserver://" + host + ":" + port + ";" +
               "databaseName=" + dbName + ";" +
               "user=" + user + ";password=" + password + ";" +
               "encrypt=false;trustServerCertificate=true;loginTimeout=30;";
    }

    private static String getEnv(String key, String defaultValue) {
        String val = System.getenv(key);
        return (val != null && !val.isEmpty()) ? val : defaultValue;
    }

    /**
     * Abre una nueva conexión a SQL Server por cada llamada.
     * Siempre usar en try-with-resources para cerrar automáticamente.
     */
    public static Connection getConnection() throws SQLException {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            return DriverManager.getConnection(buildUrl());
        } catch (ClassNotFoundException e) {
            throw new SQLException("Driver SQL Server no encontrado: " + e.getMessage());
        }
    }

    /**
     * Inicializa la base de datos — crea el esquema si no está y puebla los datos iniciales.
     */
    public static void initializeDatabase() {
        try (Connection conn = getConnection();
             Statement stmt = conn.createStatement()) {

            boolean tablesExist = false;
            try {
                ResultSet rs = stmt.executeQuery("SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='users'");
                if (rs.next()) {
                    tablesExist = true;
                }
            } catch (SQLException e) {
                // Ignore
            }

            if (!tablesExist) {
                System.out.println("🔧 Inicializando esquema de base de datos...");
                
                String[] tables = {
                    "CREATE TABLE users (id INT IDENTITY(1,1) PRIMARY KEY, username NVARCHAR(100) UNIQUE NOT NULL, password NVARCHAR(255) NOT NULL, email NVARCHAR(255) UNIQUE NOT NULL, nombre NVARCHAR(200) NOT NULL, apellido NVARCHAR(200), rol NVARCHAR(50) NOT NULL, departamento NVARCHAR(200), telefono NVARCHAR(50), avatar NVARCHAR(500), sede NVARCHAR(200), activo BIT DEFAULT 1, fecha_registro DATETIME2 DEFAULT GETDATE(), ultimo_acceso DATETIME2)",
                    "CREATE TABLE assets (id INT IDENTITY(1,1) PRIMARY KEY, nombre NVARCHAR(300) NOT NULL, codigo NVARCHAR(100) UNIQUE NOT NULL, descripcion NVARCHAR(MAX), categoria NVARCHAR(200) NOT NULL, estado NVARCHAR(100) NOT NULL, ubicacion NVARCHAR(300), sede NVARCHAR(200), valor FLOAT DEFAULT 0, stock_minimo INT DEFAULT 1, cantidad INT DEFAULT 1, imagen_url NVARCHAR(MAX), qr_code NVARCHAR(MAX), asignado_a NVARCHAR(300), etiquetas NVARCHAR(500), responsable NVARCHAR(300), notas NVARCHAR(MAX), fecha_registro DATETIME2 DEFAULT GETDATE(), fecha_compra DATETIME2, fecha_asignacion DATETIME2, fecha_devolucion_esperada DATETIME2)",
                    "CREATE TABLE assignments (id INT IDENTITY(1,1) PRIMARY KEY, asset_id INT NOT NULL, user_id INT NOT NULL, area_departamento NVARCHAR(200), estado NVARCHAR(50) DEFAULT 'ACTIVO', cantidad INT DEFAULT 1, notas NVARCHAR(MAX), responsable NVARCHAR(300), fecha_asignacion DATETIME2 DEFAULT GETDATE(), fecha_devolucion_esperada DATETIME2, fecha_devolucion_real DATETIME2, FOREIGN KEY (asset_id) REFERENCES assets(id), FOREIGN KEY (user_id) REFERENCES users(id))",
                    "CREATE TABLE notifications (id INT IDENTITY(1,1) PRIMARY KEY, user_id INT NOT NULL, titulo NVARCHAR(300) NOT NULL, mensaje NVARCHAR(MAX) NOT NULL, tipo NVARCHAR(50) NOT NULL, enlace NVARCHAR(500), icono NVARCHAR(100), leido BIT DEFAULT 0, fecha_creacion DATETIME2 DEFAULT GETDATE(), FOREIGN KEY (user_id) REFERENCES users(id))",
                    "CREATE TABLE audit_log (id INT IDENTITY(1,1) PRIMARY KEY, user_id INT, accion NVARCHAR(100) NOT NULL, tabla NVARCHAR(100) NOT NULL, registro_id INT, valor_anterior NVARCHAR(MAX), valor_nuevo NVARCHAR(MAX), ip_address NVARCHAR(50), fecha_hora DATETIME2 DEFAULT GETDATE(), FOREIGN KEY (user_id) REFERENCES users(id))",
                    "CREATE TABLE categorias (id INT IDENTITY(1,1) PRIMARY KEY, nombre NVARCHAR(200) UNIQUE NOT NULL, descripcion NVARCHAR(MAX), icono NVARCHAR(200), fecha_creacion DATETIME2 DEFAULT GETDATE())",
                    "CREATE TABLE ubicaciones (id INT IDENTITY(1,1) PRIMARY KEY, nombre NVARCHAR(300) UNIQUE NOT NULL, sede NVARCHAR(200), descripcion NVARCHAR(MAX), fecha_creacion DATETIME2 DEFAULT GETDATE())",
                    "CREATE TABLE maintenance (id INT IDENTITY(1,1) PRIMARY KEY, asset_id INT NOT NULL, type NVARCHAR(100) NOT NULL, description NVARCHAR(MAX), scheduled_date DATE NOT NULL, completed_date DATE, status NVARCHAR(50) DEFAULT 'Pendiente', technician NVARCHAR(300), notes NVARCHAR(MAX), cost FLOAT DEFAULT 0, priority NVARCHAR(50) DEFAULT 'Media', created_at DATETIME2 DEFAULT GETDATE(), updated_at DATETIME2, FOREIGN KEY (asset_id) REFERENCES assets(id))",
                    "CREATE TABLE depreciation (id INT IDENTITY(1,1) PRIMARY KEY, asset_id INT NOT NULL UNIQUE, purchase_price FLOAT NOT NULL, residual_value FLOAT DEFAULT 0, useful_life INT NOT NULL, purchase_date DATE NOT NULL, method NVARCHAR(50) DEFAULT 'Linear', depreciation_rate FLOAT DEFAULT 0, monthly_depreciation FLOAT DEFAULT 0, accumulated_depreciation FLOAT DEFAULT 0, current_value FLOAT DEFAULT 0, last_calculated DATETIME2, FOREIGN KEY (asset_id) REFERENCES assets(id))"
                };

                for (String t : tables) {
                    stmt.execute(t);
                }
                
                System.out.println("✅ Tablas creadas. Insertando datos...");
                insertInitialData(conn);
            }
            
            System.out.println("✅ Conexión a SQL Server establecida correctamente");
            System.out.println("   Base de datos: hiperInventorySolutions");
        } catch (SQLException e) {
            System.err.println("❌ Error conectando a SQL Server: " + e.getMessage());
            e.printStackTrace();
        }
    }

    private static void insertInitialData(Connection conn) throws SQLException {
        // Admin user
        try (PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO users (username,password,email,nombre,rol,departamento,sede) VALUES (?,?,?,?,?,?,?)")) {
            ps.setString(1, "admin");
            ps.setString(2, "admin123");
            ps.setString(3, "admin@hiperinventory.com");
            ps.setString(4, "Administrador");
            ps.setString(5, "ADMIN");
            ps.setString(6, "IT");
            ps.setString(7, "Principal");
            ps.executeUpdate();
        }
        // Categories
        String[] cats = {"Computadoras","Accesorios","Muebles","Electronica","Otros"};
        for (String cat : cats) {
            try (PreparedStatement ps = conn.prepareStatement(
                    "IF NOT EXISTS (SELECT 1 FROM categorias WHERE nombre=?) INSERT INTO categorias(nombre) VALUES(?)")) {
                ps.setString(1, cat); ps.setString(2, cat); ps.executeUpdate();
            }
        }
        // Locations
        String[][] locs = {{"Almacen Central","Principal"},{"Piso 1","Principal"},{"Piso 2","Principal"},{"Recepcion","Principal"}};
        for (String[] loc : locs) {
            try (PreparedStatement ps = conn.prepareStatement(
                    "IF NOT EXISTS (SELECT 1 FROM ubicaciones WHERE nombre=?) INSERT INTO ubicaciones(nombre,sede) VALUES(?,?)")) {
                ps.setString(1, loc[0]); ps.setString(2, loc[0]); ps.setString(3, loc[1]); ps.executeUpdate();
            }
        }
        System.out.println("✅ Datos iniciales insertados");
    }

    /**
     * No-op: conexiones se cierran automáticamente con try-with-resources
     */
    public static void closeConnection() {
        System.out.println("✅ Conexiones SQL Server manejadas por request");
    }

    /**
     * Registra una acción en el audit log
     */
    public static void logAction(int userId, String accion, String tabla,
                                 int registroId, String valorAnterior, String valorNuevo) {
        String sql = "INSERT INTO audit_log (user_id,accion,tabla,registro_id,valor_anterior,valor_nuevo) VALUES (?,?,?,?,?,?)";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (userId > 0) ps.setInt(1, userId); else ps.setNull(1, Types.INTEGER);
            ps.setString(2, accion);
            ps.setString(3, tabla);
            ps.setInt(4, registroId);
            ps.setString(5, valorAnterior);
            ps.setString(6, valorNuevo);
            ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("⚠️ Error registrando acción: " + e.getMessage());
        }
    }
}
