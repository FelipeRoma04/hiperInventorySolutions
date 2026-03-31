package com.hiper.inventory.servlets;

import com.hiper.inventory.dao.MaintenanceDAO;
import com.hiper.inventory.models.Maintenance;
import com.fasterxml.jackson.databind.ObjectMapper;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.List;

/**
 * Servlet REST para gestión de mantenimiento preventivo
 */
public class MaintenanceServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private ObjectMapper objectMapper = new ObjectMapper();
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json; charset=UTF-8");
        String path = req.getPathInfo();
        
        try {
            MaintenanceDAO dao = new MaintenanceDAO();
            
            if (path == null || path.equals("/")) {
                // GET /api/maintenance - Obtener todos pendientes
                List<Maintenance> pending = dao.getPending();
                resp.getWriter().write(objectMapper.writeValueAsString(pending));
            } else if (path.startsWith("/pending")) {
                // GET /api/maintenance/pending - Mantenimientos pendientes próximos
                List<Maintenance> pending = dao.getPending();
                resp.getWriter().write(objectMapper.writeValueAsString(pending));
            } else if (path.startsWith("/asset/")) {
                // GET /api/maintenance/asset/:assetId
                int assetId = Integer.parseInt(path.substring(7));
                List<Maintenance> list = dao.getByAssetId(assetId);
                resp.getWriter().write(objectMapper.writeValueAsString(list));
            } else if (path.matches("/\\d+")) {
                // GET /api/maintenance/:id
                int id = Integer.parseInt(path.substring(1));
                Maintenance m = dao.getById(id);
                if (m != null) {
                    resp.getWriter().write(objectMapper.writeValueAsString(m));
                } else {
                    resp.setStatus(404);
                    resp.getWriter().write("{\"error\":\"Not found\"}");
                }
            }
        } catch (SQLException e) {
            resp.setStatus(500);
            resp.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json; charset=UTF-8");
        
        try {
            HttpSession session = req.getSession();
            Integer userId = (Integer) session.getAttribute("userId");
            
            if (userId == null) {
                resp.setStatus(401);
                resp.getWriter().write("{\"error\":\"Unauthorized\"}");
                return;
            }
            
            Maintenance maintenance = objectMapper.readValue(req.getInputStream(), Maintenance.class);
            MaintenanceDAO dao = new MaintenanceDAO();
            int id = dao.create(maintenance);
            
            resp.setStatus(201);
            resp.getWriter().write("{\"id\":" + id + ",\"status\":\"created\"}");
        } catch (SQLException e) {
            resp.setStatus(500);
            resp.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
        }
    }
    
    @Override
    protected void doPut(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json; charset=UTF-8");
        
        try {
            HttpSession session = req.getSession();
            Integer userId = (Integer) session.getAttribute("userId");
            
            if (userId == null) {
                resp.setStatus(401);
                resp.getWriter().write("{\"error\":\"Unauthorized\"}");
                return;
            }
            
            String path = req.getPathInfo();
            int id = Integer.parseInt(path.substring(1));
            
            Maintenance maintenance = objectMapper.readValue(req.getInputStream(), Maintenance.class);
            maintenance.setId(id);
            
            MaintenanceDAO dao = new MaintenanceDAO();
            if (dao.update(maintenance)) {
                resp.getWriter().write("{\"status\":\"updated\"}");
            } else {
                resp.setStatus(404);
                resp.getWriter().write("{\"error\":\"Not found\"}");
            }
        } catch (SQLException e) {
            resp.setStatus(500);
            resp.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
        }
    }
    
    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json; charset=UTF-8");
        
        try {
            HttpSession session = req.getSession();
            Integer userId = (Integer) session.getAttribute("userId");
            
            if (userId == null) {
                resp.setStatus(401);
                resp.getWriter().write("{\"error\":\"Unauthorized\"}");
                return;
            }
            
            String path = req.getPathInfo();
            int id = Integer.parseInt(path.substring(1));
            
            MaintenanceDAO dao = new MaintenanceDAO();
            if (dao.delete(id)) {
                resp.getWriter().write("{\"status\":\"deleted\"}");
            } else {
                resp.setStatus(404);
                resp.getWriter().write("{\"error\":\"Not found\"}");
            }
        } catch (SQLException e) {
            resp.setStatus(500);
            resp.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
        }
    }
}
