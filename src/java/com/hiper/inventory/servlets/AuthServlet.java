package com.hiper.inventory.servlets;

import com.hiper.inventory.dao.UserDAO;
import com.hiper.inventory.models.User;
import com.hiper.inventory.utils.DatabaseUtil;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.Date;

/**
 * Servlet para autenticación y gestión de sesiones de usuarios
 */
@WebServlet(name = "AuthServlet", urlPatterns = {"/api/auth/login", "/api/auth/logout", "/api/auth/register"})
public class AuthServlet extends HttpServlet {
    
    private UserDAO userDAO = new UserDAO();
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String path = request.getRequestURI();
        
        if (path.contains("/login")) {
            handleLogin(request, response);
        } else if (path.contains("/logout")) {
            handleLogout(request, response);
        } else if (path.contains("/register")) {
            handleRegister(request, response);
        }
    }
    
    /**
     * Maneja el login de usuarios
     */
    private void handleLogin(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        
        // Validar entrada
        if (username == null || username.isEmpty() || password == null || password.isEmpty()) {
            sendResponse(response, false, "Username y password son requeridos", 400);
            return;
        }
        
        // Autenticar usuario
        User user = userDAO.authenticate(username, password);
        
        if (user != null && user.isActivo()) {
            // Crear sesión
            HttpSession session = request.getSession(true);
            session.setAttribute("userId", user.getId());
            session.setAttribute("username", user.getUsername());
            session.setAttribute("userRole", user.getRol());
            session.setAttribute("userName", user.getNombre());
            session.setAttribute("userDept", user.getDepartamento());
            session.setMaxInactiveInterval(30 * 60); // 30 minutos
            
            // Actualizar último acceso
            user.setUltimoAcceso(new Date());
            userDAO.updateUser(user);
            
            // Log
            DatabaseUtil.logAction(user.getId(), "LOGIN", "auth", 0, null, "Inicio de sesión");
            
            sendResponse(response, true, "Login exitoso", 200);
        } else {
            sendResponse(response, false, "Credenciales inválidas", 401);
        }
    }
    
    /**
     * Maneja el logout de usuarios
     */
    private void handleLogout(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        HttpSession session = request.getSession(false);
        if (session != null) {
            int userId = (Integer) session.getAttribute("userId");
            DatabaseUtil.logAction(userId, "LOGOUT", "auth", 0, null, "Cierre de sesión");
            session.invalidate();
        }
        
        sendResponse(response, true, "Logout exitoso", 200);
    }
    
    /**
     * Maneja el registro de nuevos usuarios (ADMIN only)
     */
    private void handleRegister(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        // Verificar que sea ADMIN
        HttpSession session = request.getSession(false);
        if (session == null || !"ADMIN".equals(session.getAttribute("userRole"))) {
            sendResponse(response, false, "Solo administradores pueden registrar usuarios", 403);
            return;
        }
        
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String email = request.getParameter("email");
        String nombre = request.getParameter("nombre");
        String rol = request.getParameter("rol");
        
        // Validar
        if (username == null || password == null || email == null || nombre == null || rol == null) {
            sendResponse(response, false, "Faltan parámetros requeridos", 400);
            return;
        }
        
        // Verificar si username ya existe
        if (userDAO.usernameExists(username)) {
            sendResponse(response, false, "El username ya existe", 409);
            return;
        }
        
        // Crear usuario
        User user = new User(username, password, email, nombre, rol);
        int userId = userDAO.createUser(user);
        
        if (userId > 0) {
            sendResponse(response, true, "Usuario registrado exitosamente", 201);
        } else {
            sendResponse(response, false, "Error registrando usuario", 500);
        }
    }
    
    /**
     * Envía respuesta JSON
     */
    private void sendResponse(HttpServletResponse response, boolean success, 
                            String message, int statusCode) throws IOException {
        response.setStatus(statusCode);
        response.setContentType("application/json");
        response.getWriter().write("{\"success\": " + success + ", \"message\": \"" + message + "\"}");
    }
}
