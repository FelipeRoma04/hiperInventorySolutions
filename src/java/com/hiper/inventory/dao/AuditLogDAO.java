package com.hiper.inventory.dao;

import com.hiper.inventory.models.AuditLog;
import com.hiper.inventory.utils.DatabaseUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AuditLogDAO {

    public AuditLogDAO() throws SQLException {}

    public static void createTable() throws SQLException {}

    public List<AuditLog> getRecent(int limit) throws SQLException {
        List<AuditLog> list = new ArrayList<>();
        String sql = "SELECT TOP (" + limit + ") * FROM audit_log ORDER BY fecha_hora DESC";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        }
        return list;
    }

    public List<AuditLog> getByUserId(int userId, int limit) throws SQLException {
        List<AuditLog> list = new ArrayList<>();
        String sql = "SELECT TOP (" + limit + ") * FROM audit_log WHERE user_id=? ORDER BY fecha_hora DESC";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        }
        return list;
    }

    public List<AuditLog> getByTableName(String tableName, int limit) throws SQLException {
        List<AuditLog> list = new ArrayList<>();
        String sql = "SELECT TOP (" + limit + ") * FROM audit_log WHERE tabla=? ORDER BY fecha_hora DESC";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, tableName);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        }
        return list;
    }

    private AuditLog mapRow(ResultSet rs) throws SQLException {
        AuditLog log = new AuditLog();
        log.setId(rs.getInt("id"));
        log.setUserId(rs.getInt("user_id"));
        log.setAction(rs.getString("accion"));
        log.setTableName(rs.getString("tabla"));
        log.setRecordId(rs.getInt("registro_id"));
        log.setOldValues(rs.getString("valor_anterior"));
        log.setNewValues(rs.getString("valor_nuevo"));
        log.setIpAddress(rs.getString("ip_address"));
        Timestamp ts = rs.getTimestamp("fecha_hora");
        if (ts != null) log.setTimestamp(ts.toLocalDateTime());
        return log;
    }
}
