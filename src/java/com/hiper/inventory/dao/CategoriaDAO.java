package com.hiper.inventory.dao;

import com.hiper.inventory.utils.DatabaseUtil;
import java.sql.*;
import java.util.*;

public class CategoriaDAO {

    public List<Map<String, Object>> getAll() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT c.*, (SELECT COUNT(*) FROM assets a WHERE a.categoria = c.nombre) AS total_activos " +
                     "FROM categorias c ORDER BY c.nombre";
        try (Connection conn = DatabaseUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                Map<String, Object> m = new LinkedHashMap<>();
                m.put("id", rs.getInt("id"));
                m.put("nombre", rs.getString("nombre"));
                m.put("descripcion", rs.getString("descripcion"));
                m.put("icono", rs.getString("icono"));
                m.put("fechaCreacion", rs.getString("fecha_creacion"));
                m.put("totalActivos", rs.getInt("total_activos"));
                list.add(m);
            }
        } catch (SQLException e) { System.err.println("CategoriaDAO.getAll: " + e.getMessage()); }
        return list;
    }

    public int create(String nombre, String descripcion, String icono) {
        String sql = "INSERT INTO categorias (nombre, descripcion, icono) VALUES (?, ?, ?)";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, nombre);
            ps.setString(2, descripcion);
            ps.setString(3, icono);
            ps.executeUpdate();
            ResultSet keys = ps.getGeneratedKeys();
            if (keys.next()) return keys.getInt(1);
        } catch (SQLException e) { System.err.println("CategoriaDAO.create: " + e.getMessage()); }
        return -1;
    }

    public boolean update(int id, String nombre, String descripcion, String icono) {
        String sql = "UPDATE categorias SET nombre=?, descripcion=?, icono=? WHERE id=?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, nombre); ps.setString(2, descripcion);
            ps.setString(3, icono); ps.setInt(4, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { System.err.println("CategoriaDAO.update: " + e.getMessage()); }
        return false;
    }

    public boolean delete(int id) {
        String sql = "DELETE FROM categorias WHERE id=?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { System.err.println("CategoriaDAO.delete: " + e.getMessage()); }
        return false;
    }

    public boolean exists(String nombre, int excludeId) {
        String sql = "SELECT COUNT(*) FROM categorias WHERE nombre=? AND id<>?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, nombre); ps.setInt(2, excludeId);
            ResultSet rs = ps.executeQuery();
            return rs.next() && rs.getInt(1) > 0;
        } catch (SQLException e) { System.err.println("CategoriaDAO.exists: " + e.getMessage()); }
        return false;
    }
}
