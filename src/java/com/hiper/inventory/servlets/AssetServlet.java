package com.hiper.inventory.servlets;

import com.hiper.inventory.dao.AssetDAO;
import com.hiper.inventory.models.Asset;
import com.hiper.inventory.utils.DatabaseUtil;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.*;

/**
 * Servlet REST para gestionar activos (CRUD)
 */
@WebServlet(name = "AssetServlet", urlPatterns = {"/api/assets/*"})
public class AssetServlet extends HttpServlet {
    
    private AssetDAO assetDAO = new AssetDAO();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String pathInfo = request.getPathInfo();
        
        // GET /api/assets -> Listar todos
        // GET /api/assets/1 -> Obtener por ID
        // GET /api/assets/search -> Buscar
        // GET /api/assets/stats -> Estadísticas
        // GET /api/assets/low-stock -> Stock bajo
        
        if (pathInfo == null || pathInfo.equals("/")) {
            handleList(request, response);
        } else if (pathInfo.contains("/search")) {
            handleSearch(request, response);
        } else if (pathInfo.contains("/stats")) {
            handleStats(request, response);
        } else if (pathInfo.contains("/low-stock")) {
            handleLowStock(request, response);
        } else {
            handleGetById(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String pathInfo = request.getPathInfo();
        
        if (pathInfo == null || pathInfo.equals("/")) {
            handleCreate(request, response);
        }
    }
    
    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        handleUpdate(request, response);
    }
    
    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        handleDelete(request, response);
    }
    
    /**
     * Obtiene todos los activos
     */
    private void handleList(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        List<Asset> assets = assetDAO.getAllAssets();
        sendJsonResponse(response, "{\"success\": true, \"data\": " + 
                        assetsToJson(assets) + "}", 200);
    }
    
    /**
     * Obtiene un activo por ID
     */
    private void handleGetById(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        String pathInfo = request.getPathInfo();
        int id = Integer.parseInt(pathInfo.substring(1));
        
        Asset asset = assetDAO.getAssetById(id);
        
        if (asset != null) {
            sendJsonResponse(response, "{\"success\": true, \"data\": " + 
                            assetToJson(asset) + "}", 200);
        } else {
            sendJsonResponse(response, "{\"success\": false, \"message\": \"Activo no encontrado\"}", 404);
        }
    }
    
    /**
     * Busca activos
     */
    private void handleSearch(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        String search = request.getParameter("q");
        String categoria = request.getParameter("categoria");
        String estado = request.getParameter("estado");
        String ubicacion = request.getParameter("ubicacion");
        
        List<Asset> assets = assetDAO.searchAssets(search, categoria, estado, ubicacion);
        sendJsonResponse(response, "{\"success\": true, \"data\": " + 
                        assetsToJson(assets) + "}", 200);
    }
    
    /**
     * Obtiene estadísticas
     */
    private void handleStats(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        Map<String, Integer> stats = assetDAO.getAssetStatistics();
        
        StringBuilder json = new StringBuilder("{\"success\": true, \"data\": {");
        boolean first = true;
        for (Map.Entry<String, Integer> entry : stats.entrySet()) {
            if (!first) json.append(",");
            json.append("\"").append(entry.getKey()).append("\": ").append(entry.getValue());
            first = false;
        }
        json.append("}}");
        
        sendJsonResponse(response, json.toString(), 200);
    }
    
    /**
     * Obtiene activos con stock bajo
     */
    private void handleLowStock(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        List<Asset> assets = assetDAO.getLowStockAssets();
        sendJsonResponse(response, "{\"success\": true, \"data\": " + 
                        assetsToJson(assets) + "}", 200);
    }
    
    /**
     * Crea un nuevo activo
     */
    private void handleCreate(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        // Verificar permisos
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            sendJsonResponse(response, "{\"success\": false, \"message\": \"No autorizado\"}", 401);
            return;
        }
        
        Asset asset = new Asset();
        asset.setNombre(request.getParameter("nombre"));
        asset.setCodigo(request.getParameter("codigo"));
        asset.setCategoria(request.getParameter("categoria"));
        asset.setEstado(request.getParameter("estado") != null ? 
                       request.getParameter("estado") : "Operativo");
        asset.setUbicacion(request.getParameter("ubicacion"));
        asset.setSede(request.getParameter("sede"));
        
        try {
            asset.setValor(Double.parseDouble(request.getParameter("valor")));
            asset.setStockMinimo(Integer.parseInt(request.getParameter("stockMinimo")));
            asset.setCantidad(Integer.parseInt(request.getParameter("cantidad")));
        } catch (NumberFormatException e) {
            sendJsonResponse(response, "{\"success\": false, \"message\": \"Formato de número inválido\"}", 400);
            return;
        }
        
        int id = assetDAO.createAsset(asset);
        if (id > 0) {
            int userId = (Integer) session.getAttribute("userId");
            DatabaseUtil.logAction(userId, "CREATE", "assets", id, null, asset.getNombre());
            sendJsonResponse(response, "{\"success\": true, \"id\": " + id + "}", 201);
        } else {
            sendJsonResponse(response, "{\"success\": false, \"message\": \"Error creando activo\"}", 500);
        }
    }
    
    /**
     * Actualiza un activo
     */
    private void handleUpdate(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null) {
            sendJsonResponse(response, "{\"success\": false, \"message\": \"No autorizado\"}", 401);
            return;
        }
        
        String pathInfo = request.getPathInfo();
        int id = Integer.parseInt(pathInfo.substring(1));
        
        Asset asset = assetDAO.getAssetById(id);
        if (asset == null) {
            sendJsonResponse(response, "{\"success\": false, \"message\": \"Activo no encontrado\"}", 404);
            return;
        }
        
        // Actualizar campos
        if (request.getParameter("nombre") != null) asset.setNombre(request.getParameter("nombre"));
        if (request.getParameter("estado") != null) asset.setEstado(request.getParameter("estado"));
        if (request.getParameter("ubicacion") != null) asset.setUbicacion(request.getParameter("ubicacion"));
        
        if (assetDAO.updateAsset(asset)) {
            int userId = (Integer) session.getAttribute("userId");
            DatabaseUtil.logAction(userId, "UPDATE", "assets", id, null, asset.getNombre());
            sendJsonResponse(response, "{\"success\": true}", 200);
        } else {
            sendJsonResponse(response, "{\"success\": false, \"message\": \"Error actualizando\"}", 500);
        }
    }
    
    /**
     * Elimina un activo
     */
    private void handleDelete(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || !"ADMIN".equals(session.getAttribute("userRole"))) {
            sendJsonResponse(response, "{\"success\": false, \"message\": \"No autorizado\"}", 403);
            return;
        }
        
        String pathInfo = request.getPathInfo();
        int id = Integer.parseInt(pathInfo.substring(1));
        
        if (assetDAO.deleteAsset(id)) {
            int userId = (Integer) session.getAttribute("userId");
            DatabaseUtil.logAction(userId, "DELETE", "assets", id, null, null);
            sendJsonResponse(response, "{\"success\": true}", 200);
        } else {
            sendJsonResponse(response, "{\"success\": false, \"message\": \"Error eliminando\"}", 500);
        }
    }
    
    /**
     * Convierte un activo a JSON
     */
    private String assetToJson(Asset asset) {
        return "{\"id\": " + asset.getId() + 
               ", \"nombre\": \"" + asset.getNombre() + "\"" +
               ", \"codigo\": \"" + asset.getCodigo() + "\"" +
               ", \"categoria\": \"" + asset.getCategoria() + "\"" +
               ", \"estado\": \"" + asset.getEstado() + "\"" +
               ", \"ubicacion\": \"" + asset.getUbicacion() + "\"" +
               ", \"sede\": \"" + asset.getSede() + "\"" +
               ", \"valor\": " + asset.getValor() +
               ", \"cantidad\": " + asset.getCantidad() +
               "}";
    }
    
    /**
     * Convierte una lista de activos a JSON
     */
    private String assetsToJson(List<Asset> assets) {
        StringBuilder json = new StringBuilder("[");
        boolean first = true;
        for (Asset asset : assets) {
            if (!first) json.append(",");
            json.append(assetToJson(asset));
            first = false;
        }
        json.append("]");
        return json.toString();
    }
    
    /**
     * Envía respuesta JSON
     */
    private void sendJsonResponse(HttpServletResponse response, String json, int status) 
            throws IOException {
        response.setStatus(status);
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write(json);
    }
}
