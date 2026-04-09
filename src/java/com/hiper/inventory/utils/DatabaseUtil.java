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
     * Inicializa la base de datos — en SQL Server las tablas ya existen,
     * solo verificamos la conexión e insertamos datos iniciales si faltan.
     */
    public static void initializeDatabase() {
        try (Connection conn = getConnection();
             Statement stmt = conn.createStatement()) {

            // Verificar si ya hay datos
            ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM users");
            rs.next();
            if (rs.getInt(1) == 0) {
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
