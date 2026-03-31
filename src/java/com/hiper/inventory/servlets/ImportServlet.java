package com.hiper.inventory.servlets;

import com.hiper.inventory.utils.ExcelImporter;
import com.fasterxml.jackson.databind.ObjectMapper;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.File;
import java.io.IOException;
import java.util.*;

/**
 * Servlet para importación masiva de activos desde Excel
 */
public class ImportServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private ObjectMapper objectMapper = new ObjectMapper();
    
    private static final String UPLOAD_DIR = "uploads";
    private static final int MAX_FILE_SIZE = 5 * 1024 * 1024; // 5MB
    private static final int MAX_MEMORY_SIZE = 1024 * 1024;  // 1MB
    
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json; charset=UTF-8");
        
        try {
            HttpSession session = req.getSession();
            Integer userId = (Integer) session.getAttribute("userId");
            String userRole = (String) session.getAttribute("userRole");
            
            if (userId == null || !userRole.equals("ADMIN")) {
                resp.setStatus(403);
                resp.getWriter().write("{\"error\":\"Only admins can import\"}");
                return;
            }
            
            // Respuesta simulada por ahora (sin librería fileupload)
            Map<String, Object> result = new HashMap<>();
            result.put("success", true);
            result.put("message", "Import feature requires Apache Commons FileUpload library");
            result.put("imported_count", 0);
            result.put("errors", new ArrayList<>());
            
            resp.getWriter().write(objectMapper.writeValueAsString(result));
            
        } catch (Exception e) {
            resp.setStatus(500);
            resp.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("text/html; charset=UTF-8");
        
        HttpSession session = req.getSession();
        Integer userId = (Integer) session.getAttribute("userId");
        
        if (userId == null) {
            resp.sendRedirect("index.jsp");
            return;
        }
        
        // Retornar formulario de importación
        String html = "<html><head><title>Importar Activos</title></head><body>" +
                "<h1>Importar Activos desde Excel</h1>" +
                "<form method='POST' enctype='multipart/form-data'>" +
                "<input type='file' name='file' accept='.xlsx,.xls' required/><br/><br/>" +
                "<button type='submit'>Importar</button>" +
                "</form>" +
                "<p>Formato esperado: Código, Nombre, Descripción, Categoría, Ubicación, Valor, Estado</p>" +
                "</body></html>";
        resp.getWriter().write(html);
    }
}
