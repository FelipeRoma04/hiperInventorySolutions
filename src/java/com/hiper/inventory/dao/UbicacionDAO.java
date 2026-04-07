package com.hiper.inventory.dao;

import com.hiper.inventory.utils.DatabaseUtil;
import java.sql.*;
import java.util.*;

public class UbicacionDAO {

    public List<Map<String, Object>> getAll() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT u.*, (SELECT COUNT(*) FROM assets a WHERE a.ubicacion = u.nombre) AS total_activos " +
                     "FROM ubicaciones u ORDER BY u.nombre";
        try (Connection conn = DatabaseUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                Map<String, Object> m = new LinkedHashMap<>();
                m.put("id", rs.getInt("id"));
                m.put("nombre", rs.getString("nombre"));
                m.put("sede", rs.getString("sede"));
                m.put("descripcion", rs.getString("descripcion"));
                m.put("fechaCreacion", rs.getString("fecha_creacion"));
                m.put("totalActivos", rs.getInt("total_activos"));
                list.add(m);
            }
        } catch (SQLException e) { System.err.println("UbicacionDAO.getAll: " + e.getMessage()); }
        return list;
    }

    public int create(String nombre, String sede, String descripcion) {
        String sql = "INSERT INTO ubicaciones (nombre, sede, descripcion) VALUES (?, ?, ?)";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, nombre); ps.setString(2, sede); ps.setString(3, descripcion);
            ps.executeUpdate();
            ResultSet keys = ps.getGeneratedKeys();
            if (keys.next()) return keys.getInt(1);
        } catch (SQLException e) { System.err.println("UbicacionDAO.create: " + e.getMessage()); }
        return -1;
    }

    public boolean update(int id, String nombre, String sede, String descripcion) {
        String sql = "UPDATE ubicaciones SET nombre=?, sede=?, descripcion=? WHERE id=?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, nombre); ps.setString(2, sede);
            ps.setString(3, descripcion); ps.setInt(4, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { System.err.println("UbicacionDAO.update: " + e.getMessage()); }
        return false;
    }

    public boolean delete(int id) {
        String sql = "DELETE FROM ubicaciones WHERE id=?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { System.err.println("UbicacionDAO.delete: " + e.getMessage()); }
        return false;
    }

    public boolean exists(String nombre, int excludeId) {
        String sql = "SELECT COUNT(*) FROM ubicaciones WHERE nombre=? AND id<>?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, nombre); ps.setInt(2, excludeId);
            ResultSet rs = ps.executeQuery();
            return rs.next() && rs.getInt(1) > 0;
        } catch (SQLException e) { System.err.println("UbicacionDAO.exists: " + e.getMessage()); }
        return false;
    }
}
