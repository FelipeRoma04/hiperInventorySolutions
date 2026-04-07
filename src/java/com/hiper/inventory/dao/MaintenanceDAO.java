package com.hiper.inventory.dao;

import com.hiper.inventory.models.Maintenance;
import com.hiper.inventory.utils.DatabaseUtil;
import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class MaintenanceDAO {

    public MaintenanceDAO() throws SQLException {}

    // No-op: table already created via SQL Server schema
    public static void createTable() throws SQLException {}

    public int create(Maintenance m) throws SQLException {
        String sql = "INSERT INTO maintenance (asset_id,type,description,scheduled_date,status,priority,notes,cost,technician) VALUES (?,?,?,?,?,?,?,?,?)";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, m.getAssetId());
            ps.setString(2, m.getType());
            ps.setString(3, m.getDescription());
            ps.setDate(4, Date.valueOf(m.getScheduledDate()));
            ps.setString(5, m.getStatus());
            ps.setString(6, m.getPriority());
            ps.setString(7, m.getNotes());
            ps.setDouble(8, m.getCost());
            ps.setString(9, m.getTechnician());
            ps.executeUpdate();
            ResultSet keys = ps.getGeneratedKeys();
            return keys.next() ? keys.getInt(1) : 0;
        }
    }

    public Maintenance getById(int id) throws SQLException {
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT * FROM maintenance WHERE id=?")) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            return rs.next() ? mapRow(rs) : null;
        }
    }

    public List<Maintenance> getByAssetId(int assetId) throws SQLException {
        List<Maintenance> list = new ArrayList<>();
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT * FROM maintenance WHERE asset_id=? ORDER BY scheduled_date DESC")) {
            ps.setInt(1, assetId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        }
        return list;
    }

    public List<Maintenance> getPending() throws SQLException {
        List<Maintenance> list = new ArrayList<>();
        String sql = "SELECT * FROM maintenance WHERE status='Pendiente' AND scheduled_date BETWEEN CAST(GETDATE() AS DATE) AND DATEADD(day,30,CAST(GETDATE() AS DATE)) ORDER BY priority DESC, scheduled_date ASC";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        }
        return list;
    }

    public boolean update(Maintenance m) throws SQLException {
        String sql = "UPDATE maintenance SET type=?,description=?,scheduled_date=?,completed_date=?,status=?,technician=?,notes=?,cost=?,priority=?,updated_at=GETDATE() WHERE id=?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, m.getType());
            ps.setString(2, m.getDescription());
            ps.setDate(3, Date.valueOf(m.getScheduledDate()));
            ps.setDate(4, m.getCompletedDate() != null ? Date.valueOf(m.getCompletedDate()) : null);
            ps.setString(5, m.getStatus());
            ps.setString(6, m.getTechnician());
            ps.setString(7, m.getNotes());
            ps.setDouble(8, m.getCost());
            ps.setString(9, m.getPriority());
            ps.setInt(10, m.getId());
            return ps.executeUpdate() > 0;
        }
    }

    public boolean delete(int id) throws SQLException {
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("DELETE FROM maintenance WHERE id=?")) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    private Maintenance mapRow(ResultSet rs) throws SQLException {
        Maintenance m = new Maintenance();
        m.setId(rs.getInt("id"));
        m.setAssetId(rs.getInt("asset_id"));
        m.setType(rs.getString("type"));
        m.setDescription(rs.getString("description"));
        Date sd = rs.getDate("scheduled_date");
        if (sd != null) m.setScheduledDate(sd.toLocalDate());
        Date cd = rs.getDate("completed_date");
        if (cd != null) m.setCompletedDate(cd.toLocalDate());
        m.setStatus(rs.getString("status"));
        m.setTechnician(rs.getString("technician"));
        m.setNotes(rs.getString("notes"));
        m.setCost(rs.getDouble("cost"));
        m.setPriority(rs.getString("priority"));
        return m;
    }
}
