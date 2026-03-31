package com.hiper.inventory.dao;

import com.hiper.inventory.models.User;
import com.hiper.inventory.utils.DatabaseUtil;
import java.sql.*;
import java.util.*;

/**
 * Data Access Object para la entidad User
 */
public class UserDAO {
    
    /**
     * Obtiene un usuario por username y password
     */
    public User authenticate(String username, String password) {
        String sql = "SELECT * FROM users WHERE username = ? AND password = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, username);
            pstmt.setString(2, password);
            
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return mapResultSetToUser(rs);
            }
        } catch (SQLException e) {
            System.err.println("Error autenticando usuario: " + e.getMessage());
        }
        return null;
    }
    
    /**
     * Obtiene un usuario por ID
     */
    public User getUserById(int id) {
        String sql = "SELECT * FROM users WHERE id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, id);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToUser(rs);
            }
        } catch (SQLException e) {
            System.err.println("Error obteniendo usuario: " + e.getMessage());
        }
        return null;
    }
    
    /**
     * Obtiene todos los usuarios
     */
    public List<User> getAllUsers() {
        List<User> users = new ArrayList<>();
        String sql = "SELECT * FROM users WHERE activo = 1 ORDER BY nombre";
        
        try (Connection conn = DatabaseUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                users.add(mapResultSetToUser(rs));
            }
        } catch (SQLException e) {
            System.err.println("Error obteniendo usuarios: " + e.getMessage());
        }
        return users;
    }
    
    /**
     * Crea un nuevo usuario
     */
    public int createUser(User user) {
        String sql = "INSERT INTO users (username, password, email, nombre, apellido, rol, departamento, sede) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            pstmt.setString(1, user.getUsername());
            pstmt.setString(2, user.getPassword());
            pstmt.setString(3, user.getEmail());
            pstmt.setString(4, user.getNombre());
            pstmt.setString(5, user.getApellido());
            pstmt.setString(6, user.getRol());
            pstmt.setString(7, user.getDepartamento());
            pstmt.setString(8, user.getSede());
            
            pstmt.executeUpdate();
            
            ResultSet keys = pstmt.getGeneratedKeys();
            if (keys.next()) {
                return keys.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("Error creando usuario: " + e.getMessage());
        }
        return -1;
    }
    
    /**
     * Actualiza un usuario existente
     */
    public boolean updateUser(User user) {
        String sql = "UPDATE users SET email = ?, nombre = ?, apellido = ?, rol = ?, " +
                     "departamento = ?, telefono = ?, sede = ? WHERE id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, user.getEmail());
            pstmt.setString(2, user.getNombre());
            pstmt.setString(3, user.getApellido());
            pstmt.setString(4, user.getRol());
            pstmt.setString(5, user.getDepartamento());
            pstmt.setString(6, user.getTelefono());
            pstmt.setString(7, user.getSede());
            pstmt.setInt(8, user.getId());
            
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error actualizando usuario: " + e.getMessage());
        }
        return false;
    }
    
    /**
     * Cambia la contraseña de un usuario
     */
    public boolean changePassword(int userId, String newPassword) {
        String sql = "UPDATE users SET password = ? WHERE id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, newPassword);
            pstmt.setInt(2, userId);
            
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error cambiando contraseña: " + e.getMessage());
        }
        return false;
    }
    
    /**
     * Desactiva un usuario
     */
    public boolean deactivateUser(int userId) {
        String sql = "UPDATE users SET activo = 0 WHERE id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error desactivando usuario: " + e.getMessage());
        }
        return false;
    }
    
    /**
     * Verifica si un username ya existe
     */
    public boolean usernameExists(String username) {
        String sql = "SELECT COUNT(*) FROM users WHERE username = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, username);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            System.err.println("Error verificando username: " + e.getMessage());
        }
        return false;
    }
    
    /**
     * Mapea un ResultSet a un objeto User
     */
    private User mapResultSetToUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setId(rs.getInt("id"));
        user.setUsername(rs.getString("username"));
        user.setPassword(rs.getString("password"));
        user.setEmail(rs.getString("email"));
        user.setNombre(rs.getString("nombre"));
        user.setApellido(rs.getString("apellido"));
        user.setRol(rs.getString("rol"));
        user.setDepartamento(rs.getString("departamento"));
        user.setTelefono(rs.getString("telefono"));
        user.setAvatar(rs.getString("avatar"));
        user.setSede(rs.getString("sede"));
        user.setActivo(rs.getInt("activo") == 1);
        user.setFechaRegistro(rs.getTimestamp("fecha_registro"));
        user.setUltimoAcceso(rs.getTimestamp("ultimo_acceso"));
        return user;
    }
}
