package com.hiper.inventory.dao;

import com.hiper.inventory.models.AuditLog;
import com.hiper.inventory.utils.DatabaseUtil;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO para registro de auditoría
 */
public class AuditLogDAO {
    
    private Connection conn;
    
    public AuditLogDAO() throws SQLException {
        this.conn = DatabaseUtil.getConnection();
    }
    
    // Crear tabla si no existe
    public static void createTable() throws SQLException {
        Connection conn = DatabaseUtil.getConnection();
        String sql = "CREATE TABLE IF NOT EXISTS audit_log (" +
                "id INTEGER PRIMARY KEY AUTOINCREMENT," +
                "user_id INTEGER NOT NULL," +
                "username TEXT NOT NULL," +
                "action TEXT NOT NULL," +
                "table_name TEXT NOT NULL," +
                "record_id INTEGER," +
                "record_description TEXT," +
                "old_values TEXT," +
                "new_values TEXT," +
                "ip_address TEXT," +
                "user_agent TEXT," +
                "timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP," +
                "status TEXT DEFAULT 'SUCCESS'," +
                "error_message TEXT" +
                ")";
        Statement stmt = conn.createStatement();
        stmt.execute(sql);
        stmt.close();
        
        // Crear índices
        String idx1 = "CREATE INDEX IF NOT EXISTS idx_user_id ON audit_log(user_id)";
        String idx2 = "CREATE INDEX IF NOT EXISTS idx_table_name ON audit_log(table_name)";
        String idx3 = "CREATE INDEX IF NOT EXISTS idx_timestamp ON audit_log(timestamp)";
        stmt = conn.createStatement();
        stmt.execute(idx1);
        stmt.execute(idx2);
        stmt.execute(idx3);
        stmt.close();
    }
    
    // Crear entrada de auditoría
    public int create(AuditLog log) throws SQLException {
        String sql = "INSERT INTO audit_log (user_id, username, action, table_name, record_id, " +
                "record_description, old_values, new_values, ip_address, user_agent, status, error_message) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
        pstmt.setInt(1, log.getUserId());
        pstmt.setString(2, log.getUsername());
        pstmt.setString(3, log.getAction());
        pstmt.setString(4, log.getTableName());
        pstmt.setInt(5, log.getRecordId());
        pstmt.setString(6, log.getRecordDescription());
        pstmt.setString(7, log.getOldValues());
        pstmt.setString(8, log.getNewValues());
        pstmt.setString(9, log.getIpAddress());
        pstmt.setString(10, log.getUserAgent());
        pstmt.setString(11, log.getStatus());
        pstmt.setString(12, log.getErrorMessage());
        
        pstmt.executeUpdate();
        ResultSet rs = pstmt.getGeneratedKeys();
        int id = 0;
        if (rs.next()) {
            id = rs.getInt(1);
        }
        rs.close();
        pstmt.close();
        return id;
    }
    
    // Obtener por usuario
    public List<AuditLog> getByUserId(int userId, int limit) throws SQLException {
        String sql = "SELECT * FROM audit_log WHERE user_id = ? ORDER BY timestamp DESC LIMIT ?";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, userId);
        pstmt.setInt(2, limit);
        ResultSet rs = pstmt.executeQuery();
        
        List<AuditLog> list = new ArrayList<>();
        while (rs.next()) {
            list.add(mapRow(rs));
        }
        rs.close();
        pstmt.close();
        return list;
    }
    
    // Obtener por tabla
    public List<AuditLog> getByTableName(String tableName, int limit) throws SQLException {
        String sql = "SELECT * FROM audit_log WHERE table_name = ? ORDER BY timestamp DESC LIMIT ?";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, tableName);
        pstmt.setInt(2, limit);
        ResultSet rs = pstmt.executeQuery();
        
        List<AuditLog> list = new ArrayList<>();
        while (rs.next()) {
            list.add(mapRow(rs));
        }
        rs.close();
        pstmt.close();
        return list;
    }
    
    // Obtener por tabla y registro
    public List<AuditLog> getByRecord(String tableName, int recordId) throws SQLException {
        String sql = "SELECT * FROM audit_log WHERE table_name = ? AND record_id = ? ORDER BY timestamp DESC";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, tableName);
        pstmt.setInt(2, recordId);
        ResultSet rs = pstmt.executeQuery();
        
        List<AuditLog> list = new ArrayList<>();
        while (rs.next()) {
            list.add(mapRow(rs));
        }
        rs.close();
        pstmt.close();
        return list;
    }
    
    // Obtener todos recientes
    public List<AuditLog> getRecent(int limit) throws SQLException {
        String sql = "SELECT * FROM audit_log ORDER BY timestamp DESC LIMIT ?";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, limit);
        ResultSet rs = pstmt.executeQuery();
        
        List<AuditLog> list = new ArrayList<>();
        while (rs.next()) {
            list.add(mapRow(rs));
        }
        rs.close();
        pstmt.close();
        return list;
    }
    
    // Mapear ResultSet a objeto
    private AuditLog mapRow(ResultSet rs) throws SQLException {
        AuditLog log = new AuditLog();
        log.setId(rs.getInt("id"));
        log.setUserId(rs.getInt("user_id"));
        log.setUsername(rs.getString("username"));
        log.setAction(rs.getString("action"));
        log.setTableName(rs.getString("table_name"));
        log.setRecordId(rs.getInt("record_id"));
        log.setRecordDescription(rs.getString("record_description"));
        log.setOldValues(rs.getString("old_values"));
        log.setNewValues(rs.getString("new_values"));
        log.setIpAddress(rs.getString("ip_address"));
        log.setUserAgent(rs.getString("user_agent"));
        log.setStatus(rs.getString("status"));
        log.setErrorMessage(rs.getString("error_message"));
        Timestamp ts = rs.getTimestamp("timestamp");
        if (ts != null) {
            log.setTimestamp(ts.toLocalDateTime());
        }
        return log;
    }
}
