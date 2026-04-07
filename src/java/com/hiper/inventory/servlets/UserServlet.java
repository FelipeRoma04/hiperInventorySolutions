package com.hiper.inventory.servlets;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.hiper.inventory.dao.UserDAO;
import com.hiper.inventory.models.User;
import com.hiper.inventory.utils.DatabaseUtil;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.*;

@WebServlet(name = "UserServlet", urlPatterns = {"/api/users/*"})
public class UserServlet extends HttpServlet {

    private final UserDAO dao = new UserDAO();
    private final ObjectMapper mapper = new ObjectMapper();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws IOException {
        if (!isAdmin(req)) { json(res, Map.of("success", false, "message", "No autorizado"), 403); return; }
        List<User> users = dao.getAllUsers();
        List<Map<String, Object>> data = new ArrayList<>();
        for (User u : users) {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("id", u.getId());
            m.put("username", u.getUsername());
            m.put("nombre", u.getNombre());
            m.put("apellido", u.getApellido() != null ? u.getApellido() : "");
            m.put("email", u.getEmail());
            m.put("rol", u.getRol());
            m.put("departamento", u.getDepartamento() != null ? u.getDepartamento() : "");
            m.put("telefono", u.getTelefono() != null ? u.getTelefono() : "");
            m.put("sede", u.getSede() != null ? u.getSede() : "");
            m.put("activo", u.isActivo());
            m.put("fechaRegistro", u.getFechaRegistro() != null ? u.getFechaRegistro().toString() : "");
            m.put("ultimoAcceso", u.getUltimoAcceso() != null ? u.getUltimoAcceso().toString() : "");
            data.add(m);
        }
        json(res, Map.of("success", true, "data", data), 200);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {
        if (!isAdmin(req)) { json(res, Map.of("success", false, "message", "Solo administradores"), 403); return; }
        String username = param(req, "username");
        String password = param(req, "password");
        String email = param(req, "email");
        String nombre = param(req, "nombre");
        String rol = param(req, "rol");
        if (username.isEmpty() || password.isEmpty() || email.isEmpty() || nombre.isEmpty() || rol.isEmpty()) {
            json(res, Map.of("success", false, "message", "Faltan campos requeridos"), 400); return;
        }
        if (dao.usernameExists(username)) {
            json(res, Map.of("success", false, "message", "El username ya existe"), 409); return;
        }
        User u = new User(username, password, email, nombre, rol);
        u.setApellido(param(req, "apellido"));
        u.setDepartamento(param(req, "departamento"));
        u.setTelefono(param(req, "telefono"));
        u.setSede(param(req, "sede"));
        int id = dao.createUser(u);
        if (id > 0) {
            logAction(req, "CREATE", "users", id, username);
            json(res, Map.of("success", true, "id", id), 201);
        } else {
            json(res, Map.of("success", false, "message", "Error creando usuario"), 500);
        }
    }

    @Override
    protected void doPut(HttpServletRequest req, HttpServletResponse res) throws IOException {
        if (!isAdmin(req)) { json(res, Map.of("success", false, "message", "Solo administradores"), 403); return; }
        int id = pathId(req);
        if (id < 0) { json(res, Map.of("success", false, "message", "ID inválido"), 400); return; }

        // Check if it's a password change
        String newPassword = param(req, "newPassword");
        if (!newPassword.isEmpty()) {
            boolean ok = dao.changePassword(id, newPassword);
            json(res, Map.of("success", ok), ok ? 200 : 500); return;
        }

        User u = dao.getUserById(id);
        if (u == null) { json(res, Map.of("success", false, "message", "Usuario no encontrado"), 404); return; }
        if (!param(req, "email").isEmpty()) u.setEmail(param(req, "email"));
        if (!param(req, "nombre").isEmpty()) u.setNombre(param(req, "nombre"));
        u.setApellido(param(req, "apellido"));
        if (!param(req, "rol").isEmpty()) u.setRol(param(req, "rol"));
        u.setDepartamento(param(req, "departamento"));
        u.setTelefono(param(req, "telefono"));
        u.setSede(param(req, "sede"));
        boolean ok = dao.updateUser(u);
        if (ok) { logAction(req, "UPDATE", "users", id, u.getUsername()); json(res, Map.of("success", true), 200); }
        else json(res, Map.of("success", false, "message", "Error actualizando"), 500);
    }

    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse res) throws IOException {
        if (!isAdmin(req)) { json(res, Map.of("success", false, "message", "Solo administradores"), 403); return; }
        int id = pathId(req);
        // Prevent self-deletion
        HttpSession s = req.getSession(false);
        if (s != null && s.getAttribute("userId") != null && (Integer) s.getAttribute("userId") == id) {
            json(res, Map.of("success", false, "message", "No puedes desactivar tu propia cuenta"), 400); return;
        }
        boolean ok = dao.deactivateUser(id);
        if (ok) { logAction(req, "DEACTIVATE", "users", id, null); json(res, Map.of("success", true), 200); }
        else json(res, Map.of("success", false, "message", "Error desactivando usuario"), 500);
    }

    private void json(HttpServletResponse res, Object data, int status) throws IOException {
        res.setStatus(status); res.setContentType("application/json"); res.setCharacterEncoding("UTF-8");
        mapper.writeValue(res.getWriter(), data);
    }
    private String param(HttpServletRequest req, String name) { String v = req.getParameter(name); return v != null ? v.trim() : ""; }
    private int pathId(HttpServletRequest req) { try { String p = req.getPathInfo(); return (p != null && p.length() > 1) ? Integer.parseInt(p.substring(1)) : -1; } catch (NumberFormatException e) { return -1; } }
    private boolean isAdmin(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        if (s == null) return false;
        String role = (String) s.getAttribute("userRole");
        // Accept both "ADMIN" and "admin" (case-insensitive)
        return "ADMIN".equalsIgnoreCase(role);
    }
    private void logAction(HttpServletRequest req, String action, String table, int id, String val) { HttpSession s = req.getSession(false); if (s != null && s.getAttribute("userId") != null) DatabaseUtil.logAction((Integer) s.getAttribute("userId"), action, table, id, null, val); }
}
