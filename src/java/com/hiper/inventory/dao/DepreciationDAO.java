package com.hiper.inventory.dao;

import com.hiper.inventory.models.Depreciation;
import com.hiper.inventory.utils.DatabaseUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DepreciationDAO {

    public DepreciationDAO() throws SQLException {}

    public static void createTable() throws SQLException {}

    public int create(Depreciation d) throws SQLException {
        String sql = "INSERT INTO depreciation (asset_id,purchase_price,residual_value,useful_life,purchase_date,method,depreciation_rate,monthly_depreciation,accumulated_depreciation,current_value,last_calculated) VALUES (?,?,?,?,?,?,?,?,?,?,?)";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, d.getAssetId());
            ps.setDouble(2, d.getPurchasePrice());
            ps.setDouble(3, d.getResidualValue());
            ps.setInt(4, d.getUsefulLife());
            ps.setDate(5, Date.valueOf(d.getPurchaseDate()));
            ps.setString(6, d.getMethod());
            ps.setDouble(7, d.getDepreciationRate());
            ps.setDouble(8, d.getMonthlyDepreciation());
            ps.setDouble(9, d.getAccumulatedDepreciation());
            ps.setDouble(10, d.getCurrentValue());
            ps.setTimestamp(11, d.getLastCalculated() != null ? Timestamp.valueOf(d.getLastCalculated()) : null);
            ps.executeUpdate();
            ResultSet keys = ps.getGeneratedKeys();
            return keys.next() ? keys.getInt(1) : 0;
        }
    }

    public Depreciation getById(int id) throws SQLException {
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT * FROM depreciation WHERE id=?")) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            return rs.next() ? mapRow(rs) : null;
        }
    }

    public Depreciation getByAssetId(int assetId) throws SQLException {
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT * FROM depreciation WHERE asset_id=?")) {
            ps.setInt(1, assetId);
            ResultSet rs = ps.executeQuery();
            return rs.next() ? mapRow(rs) : null;
        }
    }

    public List<Depreciation> getAll() throws SQLException {
        List<Depreciation> list = new ArrayList<>();
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT * FROM depreciation");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        }
        return list;
    }

    public boolean update(Depreciation d) throws SQLException {
        String sql = "UPDATE depreciation SET purchase_price=?,residual_value=?,useful_life=?,purchase_date=?,method=?,depreciation_rate=?,monthly_depreciation=?,accumulated_depreciation=?,current_value=?,last_calculated=? WHERE id=?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDouble(1, d.getPurchasePrice());
            ps.setDouble(2, d.getResidualValue());
            ps.setInt(3, d.getUsefulLife());
            ps.setDate(4, Date.valueOf(d.getPurchaseDate()));
            ps.setString(5, d.getMethod());
            ps.setDouble(6, d.getDepreciationRate());
            ps.setDouble(7, d.getMonthlyDepreciation());
            ps.setDouble(8, d.getAccumulatedDepreciation());
            ps.setDouble(9, d.getCurrentValue());
            ps.setTimestamp(10, d.getLastCalculated() != null ? Timestamp.valueOf(d.getLastCalculated()) : null);
            ps.setInt(11, d.getId());
            return ps.executeUpdate() > 0;
        }
    }

    public boolean delete(int id) throws SQLException {
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("DELETE FROM depreciation WHERE id=?")) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    private Depreciation mapRow(ResultSet rs) throws SQLException {
        Depreciation d = new Depreciation();
        d.setId(rs.getInt("id"));
        d.setAssetId(rs.getInt("asset_id"));
        d.setPurchasePrice(rs.getDouble("purchase_price"));
        d.setResidualValue(rs.getDouble("residual_value"));
        d.setUsefulLife(rs.getInt("useful_life"));
        Date pd = rs.getDate("purchase_date");
        if (pd != null) d.setPurchaseDate(pd.toLocalDate());
        d.setMethod(rs.getString("method"));
        d.setDepreciationRate(rs.getDouble("depreciation_rate"));
        d.setMonthlyDepreciation(rs.getDouble("monthly_depreciation"));
        d.setAccumulatedDepreciation(rs.getDouble("accumulated_depreciation"));
        d.setCurrentValue(rs.getDouble("current_value"));
        Timestamp lc = rs.getTimestamp("last_calculated");
        if (lc != null) d.setLastCalculated(lc.toLocalDateTime());
        return d;
    }
}
