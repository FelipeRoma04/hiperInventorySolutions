package com.hiper.inventory.utils;

import java.sql.*;
import java.io.File;

/**
 * Utilidad para manejar conexiones de base de datos SQLite
 */
public class DatabaseUtil {
    
    private static final String DB_PATH = "hiperInventory.db";
    private static final String DB_URL = "jdbc:sqlite:" + DB_PATH;
    private static Connection connection;

    /**
     * Obtiene una conexión a la base de datos
     */
    public static Connection getConnection() throws SQLException {
        try {
            Class.forName("org.sqlite.JDBC");
            if (connection == null || connection.isClosed()) {
                connection = DriverManager.getConnection(DB_URL);
                connection.setAutoCommit(true);
            }
            return connection;
        } catch (ClassNotFoundException e) {
            throw new SQLException("Driver SQLite no encontrado: " + e.getMessage());
        }
    }

    /**
     * Inicializa la base de datos con las tablas necesarias
     */
    public static void initializeDatabase() {
        try (Connection conn = getConnection();
             Statement stmt = conn.createStatement()) {
            
            // Tabla de Usuarios
            stmt.execute("CREATE TABLE IF NOT EXISTS users (" +
                    "id INTEGER PRIMARY KEY AUTOINCREMENT," +
                    "username TEXT UNIQUE NOT NULL," +
                    "password TEXT NOT NULL," +
                    "email TEXT UNIQUE NOT NULL," +
                    "nombre TEXT NOT NULL," +
                    "apellido TEXT," +
                    "rol TEXT NOT NULL," +
                    "departamento TEXT," +
                    "telefono TEXT," +
                    "avatar TEXT," +
                    "sede TEXT," +
                    "activo INTEGER DEFAULT 1," +
                    "fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP," +
                    "ultimo_acceso TIMESTAMP" +
                    ")");

            // Tabla de Activos
            stmt.execute("CREATE TABLE IF NOT EXISTS assets (" +
                    "id INTEGER PRIMARY KEY AUTOINCREMENT," +
                    "nombre TEXT NOT NULL," +
                    "codigo TEXT UNIQUE NOT NULL," +
                    "descripcion TEXT," +
                    "categoria TEXT NOT NULL," +
                    "estado TEXT NOT NULL," +
                    "ubicacion TEXT," +
                    "sede TEXT," +
                    "valor DOUBLE," +
                    "stock_minimo INTEGER DEFAULT 1," +
                    "cantidad INTEGER DEFAULT 1," +
                    "imagen_url TEXT," +
                    "qr_code TEXT," +
                    "asignado_a TEXT," +
                    "etiquetas TEXT," +
                    "responsable TEXT," +
                    "notas TEXT," +
                    "fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP," +
                    "fecha_compra TIMESTAMP," +
                    "fecha_asignacion TIMESTAMP," +
                    "fecha_devolucion_esperada TIMESTAMP" +
                    ")");

            // Tabla de Asignaciones
            stmt.execute("CREATE TABLE IF NOT EXISTS assignments (" +
                    "id INTEGER PRIMARY KEY AUTOINCREMENT," +
                    "asset_id INTEGER NOT NULL," +
                    "user_id INTEGER NOT NULL," +
                    "area_departamento TEXT," +
                    "estado TEXT DEFAULT 'ACTIVO'," +
                    "cantidad INTEGER DEFAULT 1," +
                    "notas TEXT," +
                    "responsable TEXT," +
                    "fecha_asignacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP," +
                    "fecha_devolucion_esperada TIMESTAMP," +
                    "fecha_devolucion_real TIMESTAMP," +
                    "FOREIGN KEY (asset_id) REFERENCES assets(id)," +
                    "FOREIGN KEY (user_id) REFERENCES users(id)" +
                    ")");

            // Tabla de Notificaciones
            stmt.execute("CREATE TABLE IF NOT EXISTS notifications (" +
                    "id INTEGER PRIMARY KEY AUTOINCREMENT," +
                    "user_id INTEGER NOT NULL," +
                    "titulo TEXT NOT NULL," +
                    "mensaje TEXT NOT NULL," +
                    "tipo TEXT NOT NULL," +
                    "enlace TEXT," +
                    "icono TEXT," +
                    "leido INTEGER DEFAULT 0," +
                    "fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP," +
                    "FOREIGN KEY (user_id) REFERENCES users(id)" +
                    ")");

            // Tabla de Auditoría
            stmt.execute("CREATE TABLE IF NOT EXISTS audit_log (" +
                    "id INTEGER PRIMARY KEY AUTOINCREMENT," +
                    "user_id INTEGER," +
                    "accion TEXT NOT NULL," +
                    "tabla TEXT NOT NULL," +
                    "registro_id INTEGER," +
                    "valor_anterior TEXT," +
                    "valor_nuevo TEXT," +
                    "ip_address TEXT," +
                    "fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP," +
                    "FOREIGN KEY (user_id) REFERENCES users(id)" +
                    ")");

            // Tabla de Categorías
            stmt.execute("CREATE TABLE IF NOT EXISTS categorias (" +
                    "id INTEGER PRIMARY KEY AUTOINCREMENT," +
                    "nombre TEXT UNIQUE NOT NULL," +
                    "descripcion TEXT," +
                    "icono TEXT," +
                    "fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP" +
                    ")");

            // Tabla de Ubicaciones
            stmt.execute("CREATE TABLE IF NOT EXISTS ubicaciones (" +
                    "id INTEGER PRIMARY KEY AUTOINCREMENT," +
                    "nombre TEXT UNIQUE NOT NULL," +
                    "sede TEXT," +
                    "descripcion TEXT," +
                    "fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP" +
                    ")");

            // Inserta datos iniciales de prueba
            insertInitialData(conn);
            
            System.out.println("✅ Base de datos inicializada correctamente");
        } catch (SQLException e) {
            System.err.println("❌ Error inicializando base de datos: " + e.getMessage());
            e.printStackTrace();
        }
    }

    /**
     * Inserta datos iniciales de prueba
     */
    private static void insertInitialData(Connection conn) {
        try {
            // Verificar si ya existen datos
            ResultSet rs = conn.createStatement().executeQuery("SELECT COUNT(*) FROM users");
            rs.next();
            if (rs.getInt(1) > 0) {
                return; // Ya hay datos
            }

            // Insertar usuario admin
            try (PreparedStatement pstmt = conn.prepareStatement(
                    "INSERT INTO users (username, password, email, nombre, rol, departamento, sede) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?)")) {
                pstmt.setString(1, "admin");
                pstmt.setString(2, "admin123"); // En producción, hashear la contraseña
                pstmt.setString(3, "admin@hiperinventory.com");
                pstmt.setString(4, "Administrador");
                pstmt.setString(5, "ADMIN");
                pstmt.setString(6, "IT");
                pstmt.setString(7, "Principal");
                pstmt.executeUpdate();
            }

            // Insertar categorías iniciales
            String[] categorias = {"Computadoras", "Accesorios", "Muebles", "Electrónica", "Otros"};
            for (String cat : categorias) {
                try (PreparedStatement pstmt = conn.prepareStatement(
                        "INSERT OR IGNORE INTO categorias (nombre) VALUES (?)")) {
                    pstmt.setString(1, cat);
                    pstmt.executeUpdate();
                }
            }

            // Insertar ubicaciones iniciales
            String[] ubicaciones = {"Almacén Central", "Piso 1", "Piso 2", "Recepción"};
            String[] sedes = {"Principal", "Principal", "Principal", "Principal"};
            for (int i = 0; i < ubicaciones.length; i++) {
                try (PreparedStatement pstmt = conn.prepareStatement(
                        "INSERT OR IGNORE INTO ubicaciones (nombre, sede) VALUES (?, ?)")) {
                    pstmt.setString(1, ubicaciones[i]);
                    pstmt.setString(2, sedes[i]);
                    pstmt.executeUpdate();
                }
            }

            System.out.println("✅ Datos iniciales insertados");
        } catch (SQLException e) {
            System.err.println("⚠️ Error insertando datos iniciales: " + e.getMessage());
        }
    }

    /**
     * Cierra la conexión a la base de datos
     */
    public static void closeConnection() {
        try {
            if (connection != null && !connection.isClosed()) {
                connection.close();
                System.out.println("✅ Conexión a BD cerrada");
            }
        } catch (SQLException e) {
            System.err.println("❌ Error cerrando conexión: " + e.getMessage());
        }
    }

    /**
     * Registra una acción en el audit log
     */
    public static void logAction(int userId, String accion, String tabla, 
                                 int registroId, String valorAnterior, String valorNuevo) {
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(
                     "INSERT INTO audit_log (user_id, accion, tabla, registro_id, valor_anterior, valor_nuevo) " +
                     "VALUES (?, ?, ?, ?, ?, ?)")) {
            
            pstmt.setInt(1, userId > 0 ? userId : null);
            pstmt.setString(2, accion);
            pstmt.setString(3, tabla);
            pstmt.setInt(4, registroId);
            pstmt.setString(5, valorAnterior);
            pstmt.setString(6, valorNuevo);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            System.err.println("⚠️ Error registrando acción: " + e.getMessage());
        }
    }
}
