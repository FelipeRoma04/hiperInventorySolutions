package com.hiper.inventory.utils;

import java.io.*;
import java.nio.file.*;
import java.util.*;
import java.util.regex.*;

/**
 * Utilidades para minificación de CSS y JavaScript
 */
public class MinificationUtil {
    
    /**
     * Minificar CSS
     */
    public static String minifyCSS(String css) {
        if (css == null) return "";
        
        // Remover comentarios
        css = css.replaceAll("/\\*[^*]*\\*+(?:[^/*][^*]*\\*+)*/", "");
        
        // Remover espacios en blanco
        css = css.replaceAll("\\s+", " ");
        css = css.replaceAll("\\s*([{}:;,>+~])\\s*", "$1");
        
        // Remover último ; antes de }
        css = css.replaceAll(";}", "}");
        
        return css.trim();
    }
    
    /**
     * Minificar JavaScript
     */
    public static String minifyJavaScript(String js) {
        if (js == null) return "";
        
        // Remover comentarios // (cuidado con URLs)
        js = js.replaceAll("(?<![:/])//.*?(?=\\n|$)", "");
        
        // Remover comentarios /* */
        js = js.replaceAll("/\\*[^*]*\\*+(?:[^/*][^*]*\\*+)*/", "");
        
        // Remover espacios excesivos
        js = js.replaceAll("\\s+", " ");
        js = js.replaceAll("\\s*([{}\\[\\];:,=<>!&|?+*/-])\\s*", "$1");
        
        // Remover espacios después de palabras clave (cuidado)
        js = js.replaceAll("\\b(if|else|for|while|function|var|const|let|return)\\s+", "$1 ");
        
        return js.trim();
    }
    
    /**
     * Comprimir para gzip
     */
    public static byte[] compressGzip(String content) throws Exception {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        java.util.zip.GZIPOutputStream gzip = new java.util.zip.GZIPOutputStream(baos);
        gzip.write(content.getBytes("UTF-8"));
        gzip.close();
        return baos.toByteArray();
    }
    
    /**
     * Descomprimir gzip
     */
    public static String decompressGzip(byte[] compressed) throws Exception {
        ByteArrayInputStream bais = new ByteArrayInputStream(compressed);
        java.util.zip.GZIPInputStream gzip = new java.util.zip.GZIPInputStream(bais);
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        byte[] buffer = new byte[1024];
        int len;
        while ((len = gzip.read(buffer)) != -1) {
            baos.write(buffer, 0, len);
        }
        return baos.toString("UTF-8");
    }
    
    /**
     * Calcular ratio de compresión
     */
    public static Map<String, Object> getCompressionStats(String original, byte[] compressed) {
        Map<String, Object> stats = new LinkedHashMap<>();
        stats.put("original_size", original.length() + " bytes");
        stats.put("compressed_size", compressed.length + " bytes");
        double ratio = ((double) compressed.length / original.length()) * 100;
        stats.put("compression_ratio", String.format("%.2f%%", ratio));
        stats.put("saved", original.length() - compressed.length + " bytes");
        return stats;
    }
}
