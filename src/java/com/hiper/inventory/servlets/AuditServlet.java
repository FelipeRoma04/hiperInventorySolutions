package com.hiper.inventory.servlets;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.hiper.inventory.utils.DatabaseUtil;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet(name = "AuditServlet", urlPatterns = {"/api/audit/*"})
public class AuditServlet extends HttpServlet {

    private final ObjectMapper mapper = new ObjectMapper();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws IOException {
        if (!isAdmin(req)) { json(res, Map.of("success", false, "message", "Solo administradores"), 403); return; }

        String pathInfo = req.getPathInfo();
        String tabla = req.getParameter("tabla");
        String usuario = req.getParameter("usuario");
        String accion = req.getParameter("accion");
        int limit = 200;
        try { String l = req.getParameter("limit"); if (l != null) limit = Integer.parseInt(l); } catch (Exception ignored) {}

        List<Map<String, Object>> rows = new ArrayList<>();
        // SQL Server: TOP must be inline, build query with limit value directly
        StringBuilder sql = new StringBuilder(
            "SELECT TOP (" + limit + ") a.id, a.user_id, u.username, a.accion, a.tabla, a.registro_id, " +
            "a.valor_anterior, a.valor_nuevo, a.ip_address, a.fecha_hora " +
            "FROM audit_log a LEFT JOIN users u ON a.user_id = u.id WHERE 1=1");

        List<Object> params = new ArrayList<>();
        if (tabla != null && !tabla.isEmpty()) { sql.append(" AND a.tabla = ?"); params.add(tabla); }
        if (usuario != null && !usuario.isEmpty()) { sql.append(" AND u.username LIKE ?"); params.add("%" + usuario + "%"); }
        if (accion != null && !accion.isEmpty()) { sql.append(" AND a.accion = ?"); params.add(accion); }
        sql.append(" ORDER BY a.fecha_hora DESC");

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> m = new LinkedHashMap<>();
                m.put("id", rs.getInt("id"));
                m.put("userId", rs.getInt("user_id"));
                m.put("username", rs.getString("username") != null ? rs.getString("username") : "Sistema");
                m.put("accion", rs.getString("accion"));
                m.put("tabla", rs.getString("tabla"));
                m.put("registroId", rs.getInt("registro_id"));
                m.put("valorAnterior", rs.getString("valor_anterior"));
                m.put("valorNuevo", rs.getString("valor_nuevo"));
                m.put("ipAddress", rs.getString("ip_address"));
                m.put("fechaHora", rs.getString("fecha_hora"));
                rows.add(m);
            }
        } catch (SQLException e) {
            json(res, Map.of("success", false, "message", e.getMessage()), 500); return;
        }
        json(res, Map.of("success", true, "data", rows, "total", rows.size()), 200);
    }

    private void json(HttpServletResponse res, Object data, int status) throws IOException {
        res.setStatus(status); res.setContentType("application/json"); res.setCharacterEncoding("UTF-8");
        mapper.writeValue(res.getWriter(), data);
    }

    private boolean isAdmin(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        return s != null && "ADMIN".equals(s.getAttribute("userRole"));
    }
}
