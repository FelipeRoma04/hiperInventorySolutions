package com.hiper.inventory.servlets;

import com.hiper.inventory.dao.DepreciationDAO;
import com.hiper.inventory.models.Depreciation;
import com.fasterxml.jackson.databind.ObjectMapper;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

/**
 * Servlet REST para gestión de depreciación de activos
 */
public class DepreciationServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private ObjectMapper objectMapper = new ObjectMapper();
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json; charset=UTF-8");
        String path = req.getPathInfo();
        
        try {
            DepreciationDAO dao = new DepreciationDAO();
            
            if (path == null || path.equals("/")) {
                // GET /api/depreciation - Obtener todos
                List<Depreciation> list = dao.getAll();
                resp.getWriter().write(objectMapper.writeValueAsString(list));
            } else if (path.startsWith("/asset/")) {
                // GET /api/depreciation/asset/:assetId
                int assetId = Integer.parseInt(path.substring(7));
                Depreciation d = dao.getByAssetId(assetId);
                if (d != null) {
                    // Recalcular depreciación actual
                    d.calculateDepreciation();
                    resp.getWriter().write(objectMapper.writeValueAsString(d));
                } else {
                    resp.setStatus(404);
                    resp.getWriter().write("{\"error\":\"Not found\"}");
                }
            } else if (path.matches("/\\d+")) {
                // GET /api/depreciation/:id
                int id = Integer.parseInt(path.substring(1));
                Depreciation d = dao.getById(id);
                if (d != null) {
                    d.calculateDepreciation();
                    resp.getWriter().write(objectMapper.writeValueAsString(d));
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
            
            Depreciation depreciation = objectMapper.readValue(req.getInputStream(), Depreciation.class);
            depreciation.calculateDepreciation();
            
            DepreciationDAO dao = new DepreciationDAO();
            int id = dao.create(depreciation);
            
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
            
            Depreciation depreciation = objectMapper.readValue(req.getInputStream(), Depreciation.class);
            depreciation.setId(id);
            depreciation.calculateDepreciation();
            
            DepreciationDAO dao = new DepreciationDAO();
            if (dao.update(depreciation)) {
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
}
