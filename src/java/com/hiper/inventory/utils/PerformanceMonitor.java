package com.hiper.inventory.utils;

import java.util.*;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Monitor de performance - registra tiempos de query y operaciones
 */
public class PerformanceMonitor {
    private static final PerformanceMonitor instance = new PerformanceMonitor();
    private final Map<String, List<Long>> metrics = new ConcurrentHashMap<>();
    private final int maxRecords = 100;
    
    private PerformanceMonitor() {}
    
    public static PerformanceMonitor getInstance() {
        return instance;
    }
    
    /**
     * Iniciar medición de tiempo
     */
    public long startTimer() {
        return System.currentTimeMillis();
    }
    
    /**
     * Finalizar medición y registrar
     */
    public void recordTime(String operationName, long startTime) {
        long duration = System.currentTimeMillis() - startTime;
        metrics.computeIfAbsent(operationName, k -> new CopyOnWriteArrayList<>())
            .add(duration);
        
        // Mantener últimas N mediciones
        List<Long> times = metrics.get(operationName);
        if (times.size() > maxRecords) {
            times.remove(0);
        }
        
        // Log de operaciones lentas (> 1000ms)
        if (duration > 1000) {
            System.out.println("[PERF WARNING] " + operationName + " took " + duration + "ms");
        }
    }
    
    /**
     * Obtener promedio de tiempo
     */
    public double getAverageTime(String operationName) {
        List<Long> times = metrics.get(operationName);
        if (times == null || times.isEmpty()) return 0;
        return times.stream().mapToLong(Long::longValue).average().orElse(0);
    }
    
    /**
     * Obtener máximo tiempo
     */
    public long getMaxTime(String operationName) {
        List<Long> times = metrics.get(operationName);
        if (times == null || times.isEmpty()) return 0;
        return times.stream().mapToLong(Long::longValue).max().orElse(0);
    }
    
    /**
     * Obtener mínimo tiempo
     */
    public long getMinTime(String operationName) {
        List<Long> times = metrics.get(operationName);
        if (times == null || times.isEmpty()) return 0;
        return times.stream().mapToLong(Long::longValue).min().orElse(0);
    }
    
    /**
     * Reporte completo de performance
     */
    public Map<String, Map<String, Object>> getReport() {
        Map<String, Map<String, Object>> report = new LinkedHashMap<>();
        
        metrics.forEach((operation, times) -> {
            Map<String, Object> stats = new LinkedHashMap<>();
            stats.put("count", times.size());
            stats.put("average", String.format("%.2f ms", getAverageTime(operation)));
            stats.put("min", getMinTime(operation) + " ms");
            stats.put("max", getMaxTime(operation) + " ms");
            report.put(operation, stats);
        });
        
        return report;
    }
    
    /**
     * Limpiar métricas
     */
    public void clear() {
        metrics.clear();
    }
}
