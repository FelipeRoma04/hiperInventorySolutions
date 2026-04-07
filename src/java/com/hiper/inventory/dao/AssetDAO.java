package com.hiper.inventory.dao;

import com.hiper.inventory.models.Asset;
import com.hiper.inventory.utils.DatabaseUtil;
import java.sql.*;
import java.util.*;

/**
 * Data Access Object para la entidad Asset
 */
public class AssetDAO {
    
    /**
     * Obtiene un activo por ID
     */
    public Asset getAssetById(int id) {
        String sql = "SELECT * FROM assets WHERE id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, id);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToAsset(rs);
            }
        } catch (SQLException e) {
            System.err.println("Error obteniendo activo: " + e.getMessage());
        }
        return null;
    }
    
    /**
     * Obtiene todos los activos
     */
    public List<Asset> getAllAssets() {
        List<Asset> assets = new ArrayList<>();
        String sql = "SELECT * FROM assets ORDER BY nombre";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                assets.add(mapResultSetToAsset(rs));
            }
        } catch (SQLException e) {
            System.err.println("Error obteniendo activos: " + e.getMessage());
        }
        return assets;
    }
    
    /**
     * Busca activos por criterios
     */
    public List<Asset> searchAssets(String search, String categoria, String estado, String ubicacion) {
        List<Asset> assets = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM assets WHERE 1=1");
        
        if (search != null && !search.isEmpty()) {
            sql.append(" AND (nombre LIKE ? OR codigo LIKE ?)");
        }
        if (categoria != null && !categoria.isEmpty()) {
            sql.append(" AND categoria = ?");
        }
        if (estado != null && !estado.isEmpty()) {
            sql.append(" AND estado = ?");
        }
        if (ubicacion != null && !ubicacion.isEmpty()) {
            sql.append(" AND ubicacion = ?");
        }
        
        sql.append(" ORDER BY nombre");
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql.toString())) {
            
            int index = 1;
            if (search != null && !search.isEmpty()) {
                String searchPattern = "%" + search + "%";
                pstmt.setString(index++, searchPattern);
                pstmt.setString(index++, searchPattern);
            }
            if (categoria != null && !categoria.isEmpty()) {
                pstmt.setString(index++, categoria);
            }
            if (estado != null && !estado.isEmpty()) {
                pstmt.setString(index++, estado);
            }
            if (ubicacion != null && !ubicacion.isEmpty()) {
                pstmt.setString(index++, ubicacion);
            }
            
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                assets.add(mapResultSetToAsset(rs));
            }
        } catch (SQLException e) {
            System.err.println("Error buscando activos: " + e.getMessage());
        }
        return assets;
    }
    
    /**
     * Crea un nuevo activo
     */
    public int createAsset(Asset asset) {
        String sql = "INSERT INTO assets (nombre, codigo, descripcion, categoria, estado, ubicacion, " +
                     "sede, valor, stock_minimo, cantidad, responsable, notas) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            pstmt.setString(1, asset.getNombre());
            pstmt.setString(2, asset.getCodigo());
            pstmt.setString(3, asset.getDescripcion());
            pstmt.setString(4, asset.getCategoria());
            pstmt.setString(5, asset.getEstado());
            pstmt.setString(6, asset.getUbicacion());
            pstmt.setString(7, asset.getSede());
            pstmt.setDouble(8, asset.getValor());
            pstmt.setInt(9, asset.getStockMinimo());
            pstmt.setInt(10, asset.getCantidad());
            pstmt.setString(11, asset.getResponsable());
            pstmt.setString(12, asset.getNotas());
            
            pstmt.executeUpdate();
            
            ResultSet keys = pstmt.getGeneratedKeys();
            if (keys.next()) {
                return keys.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("Error creando activo: " + e.getMessage());
        }
        return -1;
    }
    
    /**
     * Actualiza un activo existente
     */
    public boolean updateAsset(Asset asset) {
        String sql = "UPDATE assets SET nombre = ?, descripcion = ?, categoria = ?, estado = ?, " +
                     "ubicacion = ?, sede = ?, valor = ?, stock_minimo = ?, cantidad = ?, " +
                     "asignado_a = ?, etiquetas = ?, responsable = ?, notas = ? WHERE id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, asset.getNombre());
            pstmt.setString(2, asset.getDescripcion());
            pstmt.setString(3, asset.getCategoria());
            pstmt.setString(4, asset.getEstado());
            pstmt.setString(5, asset.getUbicacion());
            pstmt.setString(6, asset.getSede());
            pstmt.setDouble(7, asset.getValor());
            pstmt.setInt(8, asset.getStockMinimo());
            pstmt.setInt(9, asset.getCantidad());
            pstmt.setString(10, asset.getAsignadoA());
            pstmt.setString(11, asset.getEtiquetas());
            pstmt.setString(12, asset.getResponsable());
            pstmt.setString(13, asset.getNotas());
            pstmt.setInt(14, asset.getId());
            
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error actualizando activo: " + e.getMessage());
        }
        return false;
    }
    
    /**
     * Elimina un activo
     */
    public boolean deleteAsset(int assetId) {
        String sql = "DELETE FROM assets WHERE id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, assetId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error eliminando activo: " + e.getMessage());
        }
        return false;
    }
    
    /**
     * Obtiene activos con stock bajo
     */
    public List<Asset> getLowStockAssets() {
        List<Asset> assets = new ArrayList<>();
        String sql = "SELECT * FROM assets WHERE cantidad <= stock_minimo ORDER BY nombre";
        
        try (Connection conn = DatabaseUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                assets.add(mapResultSetToAsset(rs));
            }
        } catch (SQLException e) {
            System.err.println("Error obteniendo activos con stock bajo: " + e.getMessage());
        }
        return assets;
    }
    
    /**
     * Obtiene estadísticas de activos
     */
    public Map<String, Integer> getAssetStatistics() {
        Map<String, Integer> stats = new HashMap<>();
        
        try (Connection conn = DatabaseUtil.getConnection();
             Statement stmt = conn.createStatement()) {
            
            // Total
            ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM assets");
            rs.next();
            stats.put("total", rs.getInt(1));
            
            // Por estado - acepta con y sin tilde
            rs = stmt.executeQuery("SELECT COUNT(*) FROM assets WHERE estado = 'Operativo'");
            rs.next();
            stats.put("operativo", rs.getInt(1));
            
            rs = stmt.executeQuery("SELECT COUNT(*) FROM assets WHERE estado IN ('En reparación','En reparacion')");
            rs.next();
            stats.put("reparacion", rs.getInt(1));
            
            rs = stmt.executeQuery("SELECT COUNT(*) FROM assets WHERE estado = 'Baja'");
            rs.next();
            stats.put("baja", rs.getInt(1));
            
            rs = stmt.executeQuery("SELECT COUNT(*) FROM assets WHERE estado IN ('En préstamo','En prestamo')");
            rs.next();
            stats.put("prestamo", rs.getInt(1));
            
            // Low stock
            rs = stmt.executeQuery("SELECT COUNT(*) FROM assets WHERE cantidad <= stock_minimo");
            rs.next();
            stats.put("stock_bajo", rs.getInt(1));
            
        } catch (SQLException e) {
            System.err.println("Error obteniendo estadísticas: " + e.getMessage());
        }
        
        return stats;
    }
    
    /**
     * Mapea un ResultSet a un objeto Asset
     */
    private Asset mapResultSetToAsset(ResultSet rs) throws SQLException {
        Asset asset = new Asset();
        asset.setId(rs.getInt("id"));
        asset.setNombre(rs.getString("nombre"));
        asset.setCodigo(rs.getString("codigo"));
        asset.setDescripcion(rs.getString("descripcion"));
        asset.setCategoria(rs.getString("categoria"));
        asset.setEstado(rs.getString("estado"));
        asset.setUbicacion(rs.getString("ubicacion"));
        asset.setSede(rs.getString("sede"));
        asset.setValor(rs.getDouble("valor"));
        asset.setStockMinimo(rs.getInt("stock_minimo"));
        asset.setCantidad(rs.getInt("cantidad"));
        asset.setImagenUrl(rs.getString("imagen_url"));
        asset.setQrCode(rs.getString("qr_code"));
        asset.setAsignadoA(rs.getString("asignado_a"));
        asset.setEtiquetas(rs.getString("etiquetas"));
        asset.setResponsable(rs.getString("responsable"));
        asset.setNotas(rs.getString("notas"));
        asset.setFechaRegistro(rs.getTimestamp("fecha_registro"));
        asset.setFechaCompra(rs.getTimestamp("fecha_compra"));
        asset.setFechaAsignacion(rs.getTimestamp("fecha_asignacion"));
        asset.setFechaDevolucionEsperada(rs.getTimestamp("fecha_devolucion_esperada"));
        return asset;
    }
}
