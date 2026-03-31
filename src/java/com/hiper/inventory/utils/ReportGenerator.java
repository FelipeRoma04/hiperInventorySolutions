package com.hiper.inventory.utils;

import java.io.*;
import java.text.SimpleDateFormat;
import java.util.*;

/**
 * Utilidad para generar reportes en PDF y Excel
 * Nota: En producción usar iText o JasperReports
 * Esta versión genera CSV que puede convertirse a Excel
 */
public class ReportGenerator {
    
    private static final SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
    
    /**
     * Genera un reporte CSV de activos
     */
    public static String generateAssetsCSV(List<Map<String, String>> assets) {
        StringBuilder csv = new StringBuilder();
        
        // Headers
        csv.append("ID,Nombre,Código,Categoría,Estado,Ubicación,Sede,Valor,Stock Mínimo,Cantidad,Responsable,Fecha Registro\n");
        
        // Datos
        for (Map<String, String> asset : assets) {
            csv.append(escapeCSV(asset.get("id"))).append(",");
            csv.append(escapeCSV(asset.get("nombre"))).append(",");
            csv.append(escapeCSV(asset.get("codigo"))).append(",");
            csv.append(escapeCSV(asset.get("categoria"))).append(",");
            csv.append(escapeCSV(asset.get("estado"))).append(",");
            csv.append(escapeCSV(asset.get("ubicacion"))).append(",");
            csv.append(escapeCSV(asset.get("sede"))).append(",");
            csv.append(escapeCSV(asset.get("valor"))).append(",");
            csv.append(escapeCSV(asset.get("stockMinimo"))).append(",");
            csv.append(escapeCSV(asset.get("cantidad"))).append(",");
            csv.append(escapeCSV(asset.get("responsable"))).append(",");
            csv.append(escapeCSV(asset.get("fechaRegistro"))).append("\n");
        }
        
        return csv.toString();
    }
    
    /**
     * Genera un reporte HTML que puede imprimirse como PDF
     */
    public static String generateAssetsHTML(List<Map<String, String>> assets, String titulo) {
        StringBuilder html = new StringBuilder();
        
        html.append("<!DOCTYPE html>\n");
        html.append("<html>\n");
        html.append("<head>\n");
        html.append("<meta charset='UTF-8'>\n");
        html.append("<title>").append(titulo).append("</title>\n");
        html.append("<style>\n");
        html.append("body { font-family: Arial, sans-serif; margin: 20px; }\n");
        html.append("h1 { color: #333; border-bottom: 2px solid #6366f1; padding-bottom: 10px; }\n");
        html.append(".header { display: flex; justify-content: space-between; margin-bottom: 20px; }\n");
        html.append(".fecha { color: #666; font-size: 12px; }\n");
        html.append("table { width: 100%; border-collapse: collapse; margin-top: 20px; }\n");
        html.append("th { background-color: #6366f1; color: white; padding: 10px; text-align: left; }\n");
        html.append("td { padding: 10px; border-bottom: 1px solid #ddd; }\n");
        html.append("tr:hover { background-color: #f5f5f5; }\n");
        html.append(".badge { padding: 4px 8px; border-radius: 4px; font-size: 12px; font-weight: bold; }\n");
        html.append(".estado-operativo { background-color: #10b981; color: white; }\n");
        html.append(".estado-reparacion { background-color: #f59e0b; color: white; }\n");
        html.append(".estado-baja { background-color: #ef4444; color: white; }\n");
        html.append(".estado-prestamo { background-color: #3b82f6; color: white; }\n");
        html.append(".footer { margin-top: 30px; font-size: 12px; color: #666; text-align: center; }\n");
        html.append("@media print { body { margin: 0; } }\n");
        html.append("</style>\n");
        html.append("</head>\n");
        html.append("<body>\n");
        
        // Header
        html.append("<div class='header'>\n");
        html.append("<div>\n");
        html.append("<h1>").append(titulo).append("</h1>\n");
        html.append("<p>HiperInventory Solutions</p>\n");
        html.append("</div>\n");
        html.append("<div class='fecha'>\n");
        html.append("<p>Generado: ").append(sdf.format(new Date())).append("</p>\n");
        html.append("<p>Total registros: ").append(assets.size()).append("</p>\n");
        html.append("</div>\n");
        html.append("</div>\n");
        
        // Tabla
        html.append("<table>\n");
        html.append("<thead>\n");
        html.append("<tr>\n");
        html.append("<th>ID</th>\n");
        html.append("<th>Nombre</th>\n");
        html.append("<th>Código</th>\n");
        html.append("<th>Categoría</th>\n");
        html.append("<th>Estado</th>\n");
        html.append("<th>Ubicación</th>\n");
        html.append("<th>Valor</th>\n");
        html.append("<th>Cantidad</th>\n");
        html.append("</tr>\n");
        html.append("</thead>\n");
        html.append("<tbody>\n");
        
        for (Map<String, String> asset : assets) {
            html.append("<tr>\n");
            html.append("<td>").append(asset.get("id")).append("</td>\n");
            html.append("<td>").append(asset.get("nombre")).append("</td>\n");
            html.append("<td>").append(asset.get("codigo")).append("</td>\n");
            html.append("<td>").append(asset.get("categoria")).append("</td>\n");
            
            String estado = asset.get("estado");
            String estadoClass = "estado-" + estado.toLowerCase().replace(" ", "");
            html.append("<td><span class='badge ").append(estadoClass).append("'>").append(estado).append("</span></td>\n");
            
            html.append("<td>").append(asset.get("ubicacion")).append("</td>\n");
            html.append("<td>$").append(asset.get("valor")).append("</td>\n");
            html.append("<td>").append(asset.get("cantidad")).append("</td>\n");
            html.append("</tr>\n");
        }
        
        html.append("</tbody>\n");
        html.append("</table>\n");
        
        // Footer
        html.append("<div class='footer'>\n");
        html.append("<p>Este documento fue generado automáticamente por HiperInventory Solutions</p>\n");
        html.append("<p style='font-size: 10px;'>Para imprimir como PDF: Archivo > Imprimir > Guardar como PDF</p>\n");
        html.append("</div>\n");
        
        html.append("</body>\n");
        html.append("</html>\n");
        
        return html.toString();
    }
    
    /**
     * Escapa caracteres especiales para CSV
     */
    private static String escapeCSV(String value) {
        if (value == null) return "";
        if (value.contains(",") || value.contains("\"") || value.contains("\n")) {
            return "\"" + value.replace("\"", "\"\"") + "\"";
        }
        return value;
    }
    
    /**
     * Genera un reporte de auditoría
     */
    public static String generateAuditReport(List<Map<String, String>> logs) {
        StringBuilder html = new StringBuilder();
        
        html.append("<!DOCTYPE html>\n");
        html.append("<html>\n");
        html.append("<head>\n");
        html.append("<meta charset='UTF-8'>\n");
        html.append("<title>Reporte de Auditoría</title>\n");
        html.append("<style>\n");
        html.append("body { font-family: Courier New, monospace; margin: 20px; background: #f5f5f5; }\n");
        html.append("h1 { color: #d32f2f; }\n");
        html.append("table { width: 100%; background: white; border-collapse: collapse; }\n");
        html.append("th { background: #d32f2f; color: white; padding: 10px; text-align: left; }\n");
        html.append("td { padding: 8px; border-bottom: 1px solid #ddd; font-size: 11px; }\n");
        html.append("</style>\n");
        html.append("</head>\n");
        html.append("<body>\n");
        html.append("<h1>📋 Reporte de Auditoría</h1>\n");
        html.append("<p>Generado: ").append(sdf.format(new Date())).append("</p>\n");
        html.append("<table>\n");
        html.append("<tr><th>Fecha</th><th>Usuario</th><th>Acción</th><th>Tabla</th><th>Cambios</th></tr>\n");
        
        for (Map<String, String> log : logs) {
            html.append("<tr>\n");
            html.append("<td>").append(log.get("fecha")).append("</td>\n");
            html.append("<td>").append(log.get("usuario")).append("</td>\n");
            html.append("<td>").append(log.get("accion")).append("</td>\n");
            html.append("<td>").append(log.get("tabla")).append("</td>\n");
            html.append("<td>").append(log.get("cambios")).append("</td>\n");
            html.append("</tr>\n");
        }
        
        html.append("</table>\n");
        html.append("</body>\n");
        html.append("</html>\n");
        
        return html.toString();
    }
}
