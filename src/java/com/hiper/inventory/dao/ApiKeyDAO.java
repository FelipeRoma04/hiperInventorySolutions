package com.hiper.inventory.dao;

import com.hiper.inventory.models.ApiKey;
import com.hiper.inventory.utils.DatabaseUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ApiKeyDAO {

    public ApiKeyDAO() throws SQLException {}

    public static void createTable() throws SQLException {
        // Table managed via SQL Server schema script
    }

    public int create(ApiKey apiKey) throws SQLException {
        String sql = "INSERT INTO api_keys (user_id,username,api_key,description,status,requests_limit,permissions,expires_at) VALUES (?,?,?,?,?,?,?,?)";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, apiKey.getUserId());
            ps.setString(2, apiKey.getUsername());
            ps.setString(3, apiKey.getApiKey());
            ps.setString(4, apiKey.getDescription());
            ps.setString(5, apiKey.getStatus());
            ps.setInt(6, apiKey.getRequestsLimit());
            ps.setString(7, apiKey.getPermissions() != null ? String.join(",", apiKey.getPermissions()) : "");
            ps.setTimestamp(8, apiKey.getExpiresAt() != null ? Timestamp.valueOf(apiKey.getExpiresAt()) : null);
            ps.executeUpdate();
            ResultSet keys = ps.getGeneratedKeys();
            return keys.next() ? keys.getInt(1) : 0;
        }
    }

    public ApiKey getByKey(String apiKey) throws SQLException {
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT * FROM api_keys WHERE api_key=?")) {
            ps.setString(1, apiKey);
            ResultSet rs = ps.executeQuery();
            return rs.next() ? mapRow(rs) : null;
        }
    }

    public List<ApiKey> getByUserId(int userId) throws SQLException {
        List<ApiKey> list = new ArrayList<>();
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT * FROM api_keys WHERE user_id=? ORDER BY created_at DESC")) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        }
        return list;
    }

    public ApiKey getById(int id) throws SQLException {
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT * FROM api_keys WHERE id=?")) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            return rs.next() ? mapRow(rs) : null;
        }
    }

    public boolean updateRequestCount(int id) throws SQLException {
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("UPDATE api_keys SET requests_used=requests_used+1, last_used=GETDATE() WHERE id=?")) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean updateStatus(int id, String status) throws SQLException {
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("UPDATE api_keys SET status=? WHERE id=?")) {
            ps.setString(1, status); ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean delete(int id) throws SQLException {
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("DELETE FROM api_keys WHERE id=?")) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }

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
        String perms = rs.getString("permissions");
        if (perms != null && !perms.isEmpty()) ak.setPermissions(perms.split(","));
        Timestamp lu = rs.getTimestamp("last_used");
        if (lu != null) ak.setLastUsed(lu.toLocalDateTime());
        Timestamp ea = rs.getTimestamp("expires_at");
        if (ea != null) ak.setExpiresAt(ea.toLocalDateTime());
        return ak;
    }
}
