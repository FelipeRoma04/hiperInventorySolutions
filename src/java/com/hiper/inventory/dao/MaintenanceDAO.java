package com.hiper.inventory.dao;

import com.hiper.inventory.models.Maintenance;
import com.hiper.inventory.utils.DatabaseUtil;
import java.sql.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO para manejo de mantenimientos preventivos
 */
public class MaintenanceDAO {
    
    private Connection conn;
    
    public MaintenanceDAO() throws SQLException {
        this.conn = DatabaseUtil.getConnection();
    }
    
    // Crear tabla si no existe
    public static void createTable() throws SQLException {
        Connection conn = DatabaseUtil.getConnection();
        String sql = "CREATE TABLE IF NOT EXISTS maintenance (" +
                "id INTEGER PRIMARY KEY AUTOINCREMENT," +
                "asset_id INTEGER NOT NULL," +
                "type TEXT NOT NULL," +
                "description TEXT," +
                "scheduled_date DATE NOT NULL," +
                "completed_date DATE," +
                "status TEXT DEFAULT 'Pendiente'," +
                "technician TEXT," +
                "notes TEXT," +
                "cost REAL DEFAULT 0," +
                "priority TEXT DEFAULT 'Media'," +
                "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP," +
                "updated_at TIMESTAMP," +
                "FOREIGN KEY(asset_id) REFERENCES assets(id)" +
                ")";
        Statement stmt = conn.createStatement();
        stmt.execute(sql);
        stmt.close();
    }
    
    // Crear mantenimiento
    public int create(Maintenance maintenance) throws SQLException {
        String sql = "INSERT INTO maintenance (asset_id, type, description, scheduled_date, status, priority, notes, cost, technician) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
        pstmt.setInt(1, maintenance.getAssetId());
        pstmt.setString(2, maintenance.getType());
        pstmt.setString(3, maintenance.getDescription());
        pstmt.setDate(4, Date.valueOf(maintenance.getScheduledDate()));
        pstmt.setString(5, maintenance.getStatus());
        pstmt.setString(6, maintenance.getPriority());
        pstmt.setString(7, maintenance.getNotes());
        pstmt.setDouble(8, maintenance.getCost());
        pstmt.setString(9, maintenance.getTechnician());
        
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
    
    // Obtener por ID
    public Maintenance getById(int id) throws SQLException {
        String sql = "SELECT * FROM maintenance WHERE id = ?";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, id);
        ResultSet rs = pstmt.executeQuery();
        
        Maintenance m = null;
        if (rs.next()) {
            m = mapRow(rs);
        }
        rs.close();
        pstmt.close();
        return m;
    }
    
    // Obtener por activo
    public List<Maintenance> getByAssetId(int assetId) throws SQLException {
        String sql = "SELECT * FROM maintenance WHERE asset_id = ? ORDER BY scheduled_date DESC";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, assetId);
        ResultSet rs = pstmt.executeQuery();
        
        List<Maintenance> list = new ArrayList<>();
        while (rs.next()) {
            list.add(mapRow(rs));
        }
        rs.close();
        pstmt.close();
        return list;
    }
    
    // Obtener pendientes (próximos 30 días)
    public List<Maintenance> getPending() throws SQLException {
        String sql = "SELECT * FROM maintenance WHERE status = 'Pendiente' " +
                "AND scheduled_date BETWEEN DATE('now') AND DATE('now', '+30 days') " +
                "ORDER BY priority DESC, scheduled_date ASC";
        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery(sql);
        
        List<Maintenance> list = new ArrayList<>();
        while (rs.next()) {
            list.add(mapRow(rs));
        }
        rs.close();
        stmt.close();
        return list;
    }
    
    // Actualizar
    public boolean update(Maintenance maintenance) throws SQLException {
        String sql = "UPDATE maintenance SET type=?, description=?, scheduled_date=?, " +
                "completed_date=?, status=?, technician=?, notes=?, cost=?, priority=?, updated_at=CURRENT_TIMESTAMP " +
                "WHERE id=?";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, maintenance.getType());
        pstmt.setString(2, maintenance.getDescription());
        pstmt.setDate(3, Date.valueOf(maintenance.getScheduledDate()));
        pstmt.setDate(4, maintenance.getCompletedDate() != null ? Date.valueOf(maintenance.getCompletedDate()) : null);
        pstmt.setString(5, maintenance.getStatus());
        pstmt.setString(6, maintenance.getTechnician());
        pstmt.setString(7, maintenance.getNotes());
        pstmt.setDouble(8, maintenance.getCost());
        pstmt.setString(9, maintenance.getPriority());
        pstmt.setInt(10, maintenance.getId());
        
        int rows = pstmt.executeUpdate();
        pstmt.close();
        return rows > 0;
    }
    
    // Eliminar
    public boolean delete(int id) throws SQLException {
        String sql = "DELETE FROM maintenance WHERE id=?";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, id);
        int rows = pstmt.executeUpdate();
        pstmt.close();
        return rows > 0;
    }
    
    // Mapear ResultSet a objeto
    private Maintenance mapRow(ResultSet rs) throws SQLException {
        Maintenance m = new Maintenance();
        m.setId(rs.getInt("id"));
        m.setAssetId(rs.getInt("asset_id"));
        m.setType(rs.getString("type"));
        m.setDescription(rs.getString("description"));
        m.setScheduledDate(rs.getDate("scheduled_date").toLocalDate());
        Date completedDate = rs.getDate("completed_date");
        if (completedDate != null) {
            m.setCompletedDate(completedDate.toLocalDate());
        }
        m.setStatus(rs.getString("status"));
        m.setTechnician(rs.getString("technician"));
        m.setNotes(rs.getString("notes"));
        m.setCost(rs.getDouble("cost"));
        m.setPriority(rs.getString("priority"));
        return m;
    }
}
