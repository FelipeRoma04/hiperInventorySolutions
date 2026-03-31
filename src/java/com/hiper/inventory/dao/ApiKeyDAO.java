package com.hiper.inventory.dao;

import com.hiper.inventory.models.ApiKey;
import com.hiper.inventory.utils.DatabaseUtil;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO para API Keys de integración externa
 */
public class ApiKeyDAO {
    
    private Connection conn;
    
    public ApiKeyDAO() throws SQLException {
        this.conn = DatabaseUtil.getConnection();
    }
    
    // Crear tabla si no existe
    public static void createTable() throws SQLException {
        Connection conn = DatabaseUtil.getConnection();
        String sql = "CREATE TABLE IF NOT EXISTS api_keys (" +
                "id INTEGER PRIMARY KEY AUTOINCREMENT," +
                "user_id INTEGER NOT NULL," +
                "username TEXT NOT NULL," +
                "api_key TEXT NOT NULL UNIQUE," +
                "description TEXT," +
                "status TEXT DEFAULT 'Active'," +
                "requests_limit INTEGER DEFAULT -1," +
                "requests_used INTEGER DEFAULT 0," +
                "permissions TEXT," +
                "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP," +
                "last_used TIMESTAMP," +
                "expires_at TIMESTAMP," +
                "FOREIGN KEY(user_id) REFERENCES users(id)" +
                ")";
        Statement stmt = conn.createStatement();
        stmt.execute(sql);
        stmt.close();
        
        // Crear índice
        String idx = "CREATE INDEX IF NOT EXISTS idx_api_key ON api_keys(api_key)";
        stmt = conn.createStatement();
        stmt.execute(idx);
        stmt.close();
    }
    
    // Crear API key
    public int create(ApiKey apiKey) throws SQLException {
        String sql = "INSERT INTO api_keys (user_id, username, api_key, description, status, " +
                "requests_limit, permissions, expires_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
        pstmt.setInt(1, apiKey.getUserId());
        pstmt.setString(2, apiKey.getUsername());
        pstmt.setString(3, apiKey.getApiKey());
        pstmt.setString(4, apiKey.getDescription());
        pstmt.setString(5, apiKey.getStatus());
        pstmt.setInt(6, apiKey.getRequestsLimit());
        pstmt.setString(7, String.join(",", apiKey.getPermissions()));
        pstmt.setTimestamp(8, Timestamp.valueOf(apiKey.getExpiresAt()));
        
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
    
    // Obtener por API key
    public ApiKey getByKey(String apiKey) throws SQLException {
        String sql = "SELECT * FROM api_keys WHERE api_key = ?";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, apiKey);
        ResultSet rs = pstmt.executeQuery();
        
        ApiKey ak = null;
        if (rs.next()) {
            ak = mapRow(rs);
        }
        rs.close();
        pstmt.close();
        return ak;
    }
    
    // Obtener por usuario
    public List<ApiKey> getByUserId(int userId) throws SQLException {
        String sql = "SELECT * FROM api_keys WHERE user_id = ? ORDER BY created_at DESC";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, userId);
        ResultSet rs = pstmt.executeQuery();
        
        List<ApiKey> list = new ArrayList<>();
        while (rs.next()) {
            list.add(mapRow(rs));
        }
        rs.close();
        pstmt.close();
        return list;
    }
    
    // Obtener por ID
    public ApiKey getById(int id) throws SQLException {
        String sql = "SELECT * FROM api_keys WHERE id = ?";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, id);
        ResultSet rs = pstmt.executeQuery();
        
        ApiKey ak = null;
        if (rs.next()) {
            ak = mapRow(rs);
        }
        rs.close();
        pstmt.close();
        return ak;
    }
    
    // Actualizar request count
    public boolean updateRequestCount(int id) throws SQLException {
        String sql = "UPDATE api_keys SET requests_used = requests_used + 1, last_used = CURRENT_TIMESTAMP WHERE id = ?";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, id);
        int rows = pstmt.executeUpdate();
        pstmt.close();
        return rows > 0;
    }
    
    // Actualizar status
    public boolean updateStatus(int id, String status) throws SQLException {
        String sql = "UPDATE api_keys SET status = ? WHERE id = ?";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, status);
        pstmt.setInt(2, id);
        int rows = pstmt.executeUpdate();
        pstmt.close();
        return rows > 0;
    }
    
    // Eliminar
    public boolean delete(int id) throws SQLException {
        String sql = "DELETE FROM api_keys WHERE id = ?";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, id);
        int rows = pstmt.executeUpdate();
        pstmt.close();
        return rows > 0;
    }
    
    // Mapear ResultSet a objeto
    private ApiKey mapRow(ResultSet rs) throws SQLException {
        ApiKey ak = new ApiKey();
        ak.setId(rs.getInt("id"));
        ak.setUserId(rs.getInt("user_id"));
        ak.setUsername(rs.getString("username"));
        ak.setApiKey(rs.getString("api_key"));
        ak.setDescription(rs.getString("description"));
        ak.setStatus(rs.getString("status"));
        ak.setRequestsLimit(rs.getInt("requests_limit"));
        ak.setRequestsUsed(rs.getInt("requests_used"));
        
        String permsStr = rs.getString("permissions");
        if (permsStr != null && !permsStr.isEmpty()) {
            ak.setPermissions(permsStr.split(","));
        }
        
        Timestamp lastUsed = rs.getTimestamp("last_used");
        if (lastUsed != null) {
            ak.setLastUsed(lastUsed.toLocalDateTime());
        }
        
        Timestamp expiresAt = rs.getTimestamp("expires_at");
        if (expiresAt != null) {
            ak.setExpiresAt(expiresAt.toLocalDateTime());
        }
        
        return ak;
    }
}
