package com.hiper.inventory.servlets;

import com.hiper.inventory.dao.ApiKeyDAO;
import com.hiper.inventory.dao.AssetDAO;
import com.hiper.inventory.models.ApiKey;
import com.hiper.inventory.models.Asset;
import com.fasterxml.jackson.databind.ObjectMapper;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

/**
 * Servlet REST para API externa (ERP, contabilidad, etc.)
 * Requiere autenticación con API key
 */
public class ApiExternalServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private ObjectMapper objectMapper = new ObjectMapper();
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json; charset=UTF-8");
        resp.addHeader("Access-Control-Allow-Origin", "*");
        
        try {
            // Validar API key
            ApiKey apiKey = validateApiKey(req);
            if (apiKey == null) {
                resp.setStatus(401);
                resp.getWriter().write("{\"error\":\"Invalid or missing API key\"}");
                return;
            }
            
            // Verificar límites de requests
            if (!apiKey.hasRemainingRequests()) {
                resp.setStatus(429);
                resp.getWriter().write("{\"error\":\"API request limit exceeded\"}");
                return;
            }
            
            String path = req.getPathInfo();
            
            AssetDAO assetDAO = new AssetDAO();
            ApiKeyDAO keyDAO = new ApiKeyDAO();
            
            if (path == null || path.equals("/")) {
                // GET /api/external/assets - Listar activos
                if (!apiKey.hasPermission("assets:read")) {
                    resp.setStatus(403);
                    resp.getWriter().write("{\"error\":\"Permission denied\"}");
                    return;
                }
                
                List<Asset> assets = assetDAO.getAllAssets();
                resp.getWriter().write(objectMapper.writeValueAsString(assets));
                
            } else if (path.startsWith("/assets/")) {
                // GET /api/external/assets/:id - Obtener activo específico
                if (!apiKey.hasPermission("assets:read")) {
                    resp.setStatus(403);
                    resp.getWriter().write("{\"error\":\"Permission denied\"}");
                    return;
                }
                
                int id = Integer.parseInt(path.substring(8));
                Asset asset = assetDAO.getAssetById(id);
                if (asset != null) {
                    resp.getWriter().write(objectMapper.writeValueAsString(asset));
                } else {
                    resp.setStatus(404);
                    resp.getWriter().write("{\"error\":\"Asset not found\"}");
                }
                
            } else if (path.startsWith("/search")) {
                // GET /api/external/search?q=keyword - Búsqueda
                if (!apiKey.hasPermission("assets:read")) {
                    resp.setStatus(403);
                    resp.getWriter().write("{\"error\":\"Permission denied\"}");
                    return;
                }
                
                String q = req.getParameter("q");
                if (q != null && !q.isEmpty()) {
                    List<Asset> results = assetDAO.searchAssets(q, null, null, null);
                    resp.getWriter().write(objectMapper.writeValueAsString(results));
                } else {
                    resp.setStatus(400);
                    resp.getWriter().write("{\"error\":\"Search query required\"}");
                }
            }
            
            // Actualizar estadísticas de uso
            keyDAO.updateRequestCount(apiKey.getId());
            
        } catch (SQLException e) {
            resp.setStatus(500);
            resp.getWriter().write("{\"error\":\"Database error: " + e.getMessage() + "\"}");
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json; charset=UTF-8");
        resp.addHeader("Access-Control-Allow-Origin", "*");
        
        try {
            // Validar API key
            ApiKey apiKey = validateApiKey(req);
            if (apiKey == null) {
                resp.setStatus(401);
                resp.getWriter().write("{\"error\":\"Invalid or missing API key\"}");
                return;
            }
            
            // Verificar permisos de escritura
            if (!apiKey.hasPermission("assets:write")) {
                resp.setStatus(403);
                resp.getWriter().write("{\"error\":\"Permission denied for write operations\"}");
                return;
            }
            
            // Leer el activo del body
            Asset asset = objectMapper.readValue(req.getInputStream(), Asset.class);
            
            AssetDAO assetDAO = new AssetDAO();
            int id = assetDAO.createAsset(asset);
            
            ApiKeyDAO keyDAO = new ApiKeyDAO();
            keyDAO.updateRequestCount(apiKey.getId());
            
            resp.setStatus(201);
            resp.getWriter().write("{\"id\":" + id + ",\"status\":\"created\"}");
            
        } catch (SQLException e) {
            resp.setStatus(500);
            resp.getWriter().write("{\"error\":\"Database error: " + e.getMessage() + "\"}");
        }
    }
    
    /**
     * Valida el API key de la solicitud
     */
    private ApiKey validateApiKey(HttpServletRequest req) {
        try {
            String authHeader = req.getHeader("Authorization");
            if (authHeader == null || !authHeader.startsWith("Bearer ")) {
                return null;
            }
            
            String apiKeyString = authHeader.substring(7);
            
            ApiKeyDAO dao = new ApiKeyDAO();
            ApiKey apiKey = dao.getByKey(apiKeyString);
            
            // Validar que está activo y no expirado
            if (apiKey != null && apiKey.isValid()) {
                return apiKey;
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return null;
    }
    
    @Override
    protected void doOptions(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.addHeader("Access-Control-Allow-Origin", "*");
        resp.addHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
        resp.addHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");
    }
}
