package com.hiper.inventory.utils;

import java.sql.*;
import java.util.*;
import java.util.concurrent.*;

/**
 * Optimización de base de datos con Connection Pool
 */
public class DatabaseOptimization {
    private static final DatabaseOptimization instance = new DatabaseOptimization();
    private final BlockingQueue<Connection> connectionPool;
    private final int poolSize = 10;
    private boolean initialized = false;
    
    private DatabaseOptimization() {
        this.connectionPool = new LinkedBlockingQueue<>(poolSize);
    }
    
    public static DatabaseOptimization getInstance() {
        return instance;
    }
    
    /**
     * Inicializar pool de conexiones
     */
    public synchronized void initializePool() {
        if (initialized) return;
        
        try {
            Class.forName("org.sqlite.JDBC");
            for (int i = 0; i < poolSize; i++) {
                Connection conn = DriverManager.getConnection(
                    "jdbc:sqlite:hiperInventory.db");
                conn.setAutoCommit(true);
                connectionPool.offer(conn);
            }
            initialized = true;
            System.out.println("[DB] Connection pool initialized with " + poolSize + " connections");
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }
    }
    
    /**
     * Obtener conexión del pool
     */
    public Connection getConnection() throws InterruptedException {
        if (!initialized) initializePool();
        return connectionPool.poll(5, TimeUnit.SECONDS);
    }
    
    /**
     * Devolver conexión al pool
     */
    public void releaseConnection(Connection conn) {
        if (conn != null) {
            try {
                if (!conn.isClosed()) {
                    connectionPool.offer(conn);
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    
    /**
     * Crear índices en tablas para búsqueda rápida
     */
    public void createIndexes() {
        Connection conn = null;
        try {
            conn = getConnection();
            Statement stmt = conn.createStatement();
            
            // Índices en tabla assets
            stmt.execute("CREATE INDEX IF NOT EXISTS idx_assets_code ON assets(code)");
            stmt.execute("CREATE INDEX IF NOT EXISTS idx_assets_category ON assets(category)");
            stmt.execute("CREATE INDEX IF NOT EXISTS idx_assets_status ON assets(status)");
            stmt.execute("CREATE INDEX IF NOT EXISTS idx_assets_location ON assets(location)");
            
            // Índices en tabla users
            stmt.execute("CREATE INDEX IF NOT EXISTS idx_users_email ON users(email)");
            stmt.execute("CREATE INDEX IF NOT EXISTS idx_users_role ON users(role)");
            
            // Índices en tabla audit_log
            stmt.execute("CREATE INDEX IF NOT EXISTS idx_audit_user ON audit_log(user_id)");
            stmt.execute("CREATE INDEX IF NOT EXISTS idx_audit_asset ON audit_log(asset_id)");
            stmt.execute("CREATE INDEX IF NOT EXISTS idx_audit_date ON audit_log(created_at)");
            
            // Índices en tabla assignments
            stmt.execute("CREATE INDEX IF NOT EXISTS idx_assign_asset ON assignments(asset_id)");
            stmt.execute("CREATE INDEX IF NOT EXISTS idx_assign_user ON assignments(user_id)");
            
            stmt.close();
            System.out.println("[DB] Indexes created successfully");
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            releaseConnection(conn);
        }
    }
    
    /**
     * Optimizar BD (VACUUM, ANALYZE)
     */
    public void optimizeDatabase() {
        Connection conn = null;
        try {
            conn = getConnection();
            Statement stmt = conn.createStatement();
            stmt.execute("VACUUM");
            stmt.execute("ANALYZE");
            stmt.close();
            System.out.println("[DB] Database optimized");
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            releaseConnection(conn);
        }
    }
    
    /**
     * Obtener estadísticas del pool
     */
    public Map<String, Object> getPoolStats() {
        Map<String, Object> stats = new LinkedHashMap<>();
        stats.put("available", connectionPool.size());
        stats.put("maxSize", poolSize);
        stats.put("active", poolSize - connectionPool.size());
        return stats;
    }
    
    /**
     * Cerrar todas las conexiones
     */
    public void closeAllConnections() {
        Connection conn;
        while ((conn = connectionPool.poll()) != null) {
            try {
                conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        initialized = false;
    }
}
