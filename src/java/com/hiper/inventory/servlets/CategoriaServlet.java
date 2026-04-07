package com.hiper.inventory.servlets;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.hiper.inventory.dao.CategoriaDAO;
import com.hiper.inventory.utils.DatabaseUtil;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.*;

@WebServlet(name = "CategoriaServlet", urlPatterns = {"/api/categorias/*"})
public class CategoriaServlet extends HttpServlet {

    private final CategoriaDAO dao = new CategoriaDAO();
    private final ObjectMapper mapper = new ObjectMapper();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws IOException {
        List<Map<String, Object>> data = dao.getAll();
        json(res, Map.of("success", true, "data", data), 200);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {
        if (!isEditor(req)) { json(res, Map.of("success", false, "message", "No autorizado"), 403); return; }
        String nombre = param(req, "nombre");
        if (nombre == null || nombre.isEmpty()) { json(res, Map.of("success", false, "message", "Nombre requerido"), 400); return; }
        if (dao.exists(nombre, 0)) { json(res, Map.of("success", false, "message", "Ya existe una categoría con ese nombre"), 409); return; }
        int id = dao.create(nombre, param(req, "descripcion"), param(req, "icono"));
        if (id > 0) {
            logAction(req, "CREATE", "categorias", id, nombre);
            json(res, Map.of("success", true, "id", id), 201);
        } else {
            json(res, Map.of("success", false, "message", "Error creando categoría"), 500);
        }
    }

    @Override
    protected void doPut(HttpServletRequest req, HttpServletResponse res) throws IOException {
        if (!isEditor(req)) { json(res, Map.of("success", false, "message", "No autorizado"), 403); return; }
        int id = pathId(req);
        if (id < 0) { json(res, Map.of("success", false, "message", "ID inválido"), 400); return; }
        String nombre = param(req, "nombre");
        if (nombre == null || nombre.isEmpty()) { json(res, Map.of("success", false, "message", "Nombre requerido"), 400); return; }
        if (dao.exists(nombre, id)) { json(res, Map.of("success", false, "message", "Ya existe una categoría con ese nombre"), 409); return; }
        boolean ok = dao.update(id, nombre, param(req, "descripcion"), param(req, "icono"));
        if (ok) { logAction(req, "UPDATE", "categorias", id, nombre); json(res, Map.of("success", true), 200); }
        else json(res, Map.of("success", false, "message", "Error actualizando"), 500);
    }

    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse res) throws IOException {
        if (!isAdmin(req)) { json(res, Map.of("success", false, "message", "Solo administradores"), 403); return; }
        int id = pathId(req);
        if (id < 0) { json(res, Map.of("success", false, "message", "ID inválido"), 400); return; }
        boolean ok = dao.delete(id);
        if (ok) { logAction(req, "DELETE", "categorias", id, null); json(res, Map.of("success", true), 200); }
        else json(res, Map.of("success", false, "message", "Error eliminando"), 500);
    }

    private void json(HttpServletResponse res, Object data, int status) throws IOException {
        res.setStatus(status);
        res.setContentType("application/json");
        res.setCharacterEncoding("UTF-8");
        mapper.writeValue(res.getWriter(), data);
    }

    private String param(HttpServletRequest req, String name) {
        String v = req.getParameter(name);
        return v != null ? v.trim() : "";
    }

    private int pathId(HttpServletRequest req) {
        try {
            String p = req.getPathInfo();
            return (p != null && p.length() > 1) ? Integer.parseInt(p.substring(1)) : -1;
        } catch (NumberFormatException e) { return -1; }
    }

    private boolean isEditor(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        if (s == null) return false;
        String role = (String) s.getAttribute("userRole");
        return "ADMIN".equalsIgnoreCase(role) || "EDITOR".equalsIgnoreCase(role);
    }

    private boolean isAdmin(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        return s != null && "ADMIN".equalsIgnoreCase((String) s.getAttribute("userRole"));
    }

    private void logAction(HttpServletRequest req, String action, String table, int id, String val) {
        HttpSession s = req.getSession(false);
        if (s != null && s.getAttribute("userId") != null) {
            DatabaseUtil.logAction((Integer) s.getAttribute("userId"), action, table, id, null, val);
        }
    }
}
