package com.hiper.inventory.servlets;

import com.hiper.inventory.utils.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.util.*;

/**
 * Servlet para monitoreo de performance y optimizaciones
 * GET /api/performance/stats - Obtener estadísticas
 * GET /api/performance/cache - Estado del caché
 * GET /api/performance/database - Estado de BD
 * POST /api/performance/optimize - Ejecutar optimizaciones
 */
@SuppressWarnings("serial")
public class PerformanceServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) 
            throws ServletException, IOException {
        
        String action = req.getParameter("action");
        resp.setContentType("application/json");
        
        Map<String, Object> result = new LinkedHashMap<>();
        
        try {
            if ("stats".equals(action)) {
                result.put("performance", PerformanceMonitor.getInstance().getReport());
                result.put("timestamp", System.currentTimeMillis());
                resp.setStatus(HttpServletResponse.SC_OK);
                
            } else if ("cache".equals(action)) {
                result.put("cache", CacheManager.getInstance().getStats());
                result.put("status", "active");
                resp.setStatus(HttpServletResponse.SC_OK);
                
            } else if ("database".equals(action)) {
                result.put("pool", DatabaseOptimization.getInstance().getPoolStats());
                result.put("status", "operational");
                resp.setStatus(HttpServletResponse.SC_OK);
                
            } else {
                result.put("available_actions", new String[]{
                    "stats - Estadísticas de performance",
                    "cache - Estado del caché",
                    "database - Estado del pool de conexiones"
                });
                resp.setStatus(HttpServletResponse.SC_OK);
            }
            
            // Convertir a JSON y enviar
            PrintWriter out = resp.getWriter();
            out.println(toJson(result));
            out.flush();
            
        } catch (Exception e) {
            result.clear();
            result.put("error", e.getMessage());
            result.put("status", "error");
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            
            PrintWriter out = resp.getWriter();
            out.println(toJson(result));
            out.flush();
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) 
            throws ServletException, IOException {
        
        String action = req.getParameter("action");
        resp.setContentType("application/json");
        
        Map<String, Object> result = new LinkedHashMap<>();
        
        try {
            if ("optimize-db".equals(action)) {
                DatabaseOptimization.getInstance().optimizeDatabase();
                DatabaseOptimization.getInstance().createIndexes();
                result.put("message", "Database optimized and indexed");
                result.put("status", "success");
                
            } else if ("clear-cache".equals(action)) {
                CacheManager.getInstance().clear();
                result.put("message", "Cache cleared");
                result.put("status", "success");
                
            } else if ("reset-metrics".equals(action)) {
                PerformanceMonitor.getInstance().clear();
                result.put("message", "Metrics reset");
                result.put("status", "success");
                
            } else {
                result.put("available_actions", new String[]{
                    "optimize-db - Optimizar y crear índices en BD",
                    "clear-cache - Limpiar caché en memoria",
                    "reset-metrics - Reset de métricas de performance"
                });
            }
            
            result.put("timestamp", System.currentTimeMillis());
            resp.setStatus(HttpServletResponse.SC_OK);
            
        } catch (Exception e) {
            result.clear();
            result.put("error", e.getMessage());
            result.put("status", "error");
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
        
        PrintWriter out = resp.getWriter();
        out.println(toJson(result));
        out.flush();
    }
    
    /**
     * Convertir Map a JSON simple
     */
    private String toJson(Map<String, Object> map) {
        StringBuilder json = new StringBuilder("{");
        boolean first = true;
        for (Map.Entry<String, Object> entry : map.entrySet()) {
            if (!first) json.append(",");
            json.append("\"").append(entry.getKey()).append("\":");
            
            if (entry.getValue() == null) {
                json.append("null");
            } else if (entry.getValue() instanceof String) {
                json.append("\"").append(entry.getValue()).append("\"");
            } else if (entry.getValue() instanceof Number) {
                json.append(entry.getValue());
            } else {
                json.append("\"").append(entry.getValue().toString()).append("\"");
            }
            first = false;
        }
        json.append("}");
        return json.toString();
    }
}
