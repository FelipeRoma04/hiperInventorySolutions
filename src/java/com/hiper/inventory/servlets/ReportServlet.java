package com.hiper.inventory.servlets;

import com.hiper.inventory.dao.AssetDAO;
import com.hiper.inventory.models.Asset;
import com.hiper.inventory.utils.ReportGenerator;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.*;

/**
 * Servlet para generar reportes (PDF, Excel)
 */
@WebServlet(name = "ReportServlet", urlPatterns = {"/api/reports/*"})
public class ReportServlet extends HttpServlet {
    
    private AssetDAO assetDAO = new AssetDAO();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Verificar autenticación
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }
        
        String pathInfo = request.getPathInfo();
        
        if (pathInfo.contains("/assets-csv")) {
            generateCSV(request, response);
        } else if (pathInfo.contains("/assets-pdf")) {
            generatePDF(request, response);
        }
    }
    
    /**
     * Genera CSV de activos
     */
    private void generateCSV(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        List<Asset> assets = assetDAO.getAllAssets();
        List<Map<String, String>> data = new ArrayList<>();
        
        for (Asset asset : assets) {
            Map<String, String> row = new HashMap<>();
            row.put("id", String.valueOf(asset.getId()));
            row.put("nombre", asset.getNombre());
            row.put("codigo", asset.getCodigo());
            row.put("categoria", asset.getCategoria());
            row.put("estado", asset.getEstado());
            row.put("ubicacion", asset.getUbicacion());
            row.put("sede", asset.getSede());
            row.put("valor", String.valueOf(asset.getValor()));
            row.put("stockMinimo", String.valueOf(asset.getStockMinimo()));
            row.put("cantidad", String.valueOf(asset.getCantidad()));
            row.put("responsable", asset.getResponsable() != null ? asset.getResponsable() : "");
            row.put("fechaRegistro", asset.getFechaRegistro() != null ? 
                   asset.getFechaRegistro().toString() : "");
            data.add(row);
        }
        
        String csv = ReportGenerator.generateAssetsCSV(data);
        
        response.setContentType("text/csv");
        response.setHeader("Content-Disposition", 
                          "attachment; filename=\"activos_" + System.currentTimeMillis() + ".csv\"");
        response.getWriter().write(csv);
    }
    
    /**
     * Genera HTML para visualización/impresión como PDF
     */
    private void generatePDF(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        List<Asset> assets = assetDAO.getAllAssets();
        List<Map<String, String>> data = new ArrayList<>();
        
        for (Asset asset : assets) {
            Map<String, String> row = new HashMap<>();
            row.put("id", String.valueOf(asset.getId()));
            row.put("nombre", asset.getNombre());
            row.put("codigo", asset.getCodigo());
            row.put("categoria", asset.getCategoria());
            row.put("estado", asset.getEstado());
            row.put("ubicacion", asset.getUbicacion());
            row.put("valor", "$" + String.valueOf(asset.getValor()));
            row.put("cantidad", String.valueOf(asset.getCantidad()));
            data.add(row);
        }
        
        String html = ReportGenerator.generateAssetsHTML(data, "Reporte de Activos");
        
        response.setContentType("text/html; charset=UTF-8");
        response.getWriter().write(html);
    }
}
