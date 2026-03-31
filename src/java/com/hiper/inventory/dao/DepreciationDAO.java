package com.hiper.inventory.dao;

import com.hiper.inventory.models.Depreciation;
import com.hiper.inventory.utils.DatabaseUtil;
import java.sql.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO para manejo de depreciación de activos
 */
public class DepreciationDAO {
    
    private Connection conn;
    
    public DepreciationDAO() throws SQLException {
        this.conn = DatabaseUtil.getConnection();
    }
    
    // Crear tabla si no existe
    public static void createTable() throws SQLException {
        Connection conn = DatabaseUtil.getConnection();
        String sql = "CREATE TABLE IF NOT EXISTS depreciation (" +
                "id INTEGER PRIMARY KEY AUTOINCREMENT," +
                "asset_id INTEGER NOT NULL UNIQUE," +
                "purchase_price REAL NOT NULL," +
                "residual_value REAL DEFAULT 0," +
                "useful_life INTEGER NOT NULL," +
                "purchase_date DATE NOT NULL," +
                "method TEXT DEFAULT 'Linear'," +
                "depreciation_rate REAL DEFAULT 0," +
                "monthly_depreciation REAL DEFAULT 0," +
                "accumulated_depreciation REAL DEFAULT 0," +
                "current_value REAL DEFAULT 0," +
                "last_calculated TIMESTAMP," +
                "FOREIGN KEY(asset_id) REFERENCES assets(id)" +
                ")";
        Statement stmt = conn.createStatement();
        stmt.execute(sql);
        stmt.close();
    }
    
    // Crear depreciación
    public int create(Depreciation depreciation) throws SQLException {
        String sql = "INSERT INTO depreciation (asset_id, purchase_price, residual_value, useful_life, " +
                "purchase_date, method, depreciation_rate, monthly_depreciation, accumulated_depreciation, " +
                "current_value, last_calculated) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
        pstmt.setInt(1, depreciation.getAssetId());
        pstmt.setDouble(2, depreciation.getPurchasePrice());
        pstmt.setDouble(3, depreciation.getResidualValue());
        pstmt.setInt(4, depreciation.getUsefulLife());
        pstmt.setDate(5, Date.valueOf(depreciation.getPurchaseDate()));
        pstmt.setString(6, depreciation.getMethod());
        pstmt.setDouble(7, depreciation.getDepreciationRate());
        pstmt.setDouble(8, depreciation.getMonthlyDepreciation());
        pstmt.setDouble(9, depreciation.getAccumulatedDepreciation());
        pstmt.setDouble(10, depreciation.getCurrentValue());
        pstmt.setTimestamp(11, Timestamp.valueOf(depreciation.getLastCalculated()));
        
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
    public Depreciation getById(int id) throws SQLException {
        String sql = "SELECT * FROM depreciation WHERE id = ?";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, id);
        ResultSet rs = pstmt.executeQuery();
        
        Depreciation d = null;
        if (rs.next()) {
            d = mapRow(rs);
        }
        rs.close();
        pstmt.close();
        return d;
    }
    
    // Obtener por activo
    public Depreciation getByAssetId(int assetId) throws SQLException {
        String sql = "SELECT * FROM depreciation WHERE asset_id = ?";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, assetId);
        ResultSet rs = pstmt.executeQuery();
        
        Depreciation d = null;
        if (rs.next()) {
            d = mapRow(rs);
        }
        rs.close();
        pstmt.close();
        return d;
    }
    
    // Obtener todos
    public List<Depreciation> getAll() throws SQLException {
        String sql = "SELECT * FROM depreciation";
        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery(sql);
        
        List<Depreciation> list = new ArrayList<>();
        while (rs.next()) {
            list.add(mapRow(rs));
        }
        rs.close();
        stmt.close();
        return list;
    }
    
    // Actualizar
    public boolean update(Depreciation depreciation) throws SQLException {
        String sql = "UPDATE depreciation SET purchase_price=?, residual_value=?, useful_life=?, " +
                "purchase_date=?, method=?, depreciation_rate=?, monthly_depreciation=?, " +
                "accumulated_depreciation=?, current_value=?, last_calculated=? WHERE id=?";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setDouble(1, depreciation.getPurchasePrice());
        pstmt.setDouble(2, depreciation.getResidualValue());
        pstmt.setInt(3, depreciation.getUsefulLife());
        pstmt.setDate(4, Date.valueOf(depreciation.getPurchaseDate()));
        pstmt.setString(5, depreciation.getMethod());
        pstmt.setDouble(6, depreciation.getDepreciationRate());
        pstmt.setDouble(7, depreciation.getMonthlyDepreciation());
        pstmt.setDouble(8, depreciation.getAccumulatedDepreciation());
        pstmt.setDouble(9, depreciation.getCurrentValue());
        pstmt.setTimestamp(10, Timestamp.valueOf(depreciation.getLastCalculated()));
        pstmt.setInt(11, depreciation.getId());
        
        int rows = pstmt.executeUpdate();
        pstmt.close();
        return rows > 0;
    }
    
    // Eliminar
    public boolean delete(int id) throws SQLException {
        String sql = "DELETE FROM depreciation WHERE id=?";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, id);
        int rows = pstmt.executeUpdate();
        pstmt.close();
        return rows > 0;
    }
    
    // Mapear ResultSet a objeto
    private Depreciation mapRow(ResultSet rs) throws SQLException {
        Depreciation d = new Depreciation();
        d.setId(rs.getInt("id"));
        d.setAssetId(rs.getInt("asset_id"));
        d.setPurchasePrice(rs.getDouble("purchase_price"));
        d.setResidualValue(rs.getDouble("residual_value"));
        d.setUsefulLife(rs.getInt("useful_life"));
        d.setPurchaseDate(rs.getDate("purchase_date").toLocalDate());
        d.setMethod(rs.getString("method"));
        d.setDepreciationRate(rs.getDouble("depreciation_rate"));
        d.setMonthlyDepreciation(rs.getDouble("monthly_depreciation"));
        d.setAccumulatedDepreciation(rs.getDouble("accumulated_depreciation"));
        d.setCurrentValue(rs.getDouble("current_value"));
        Timestamp lastCalc = rs.getTimestamp("last_calculated");
        if (lastCalc != null) {
            d.setLastCalculated(lastCalc.toLocalDateTime());
        }
        return d;
    }
}
