package com.hiper.inventory.utils;

import java.util.*;
import java.util.concurrent.*;

/**
 * Gestor de caché en memoria para mejorar performance
 * Soporta expiración automática y límite de tamaño
 */
public class CacheManager {
    private static final CacheManager instance = new CacheManager();
    private final Map<String, CacheEntry> cache = new ConcurrentHashMap<>();
    private final long defaultTTL = 3600000; // 1 hora en ms
    private final int maxSize = 1000;
    
    private CacheManager() {
        // Iniciar thread de limpieza
        startCleanupThread();
    }
    
    public static CacheManager getInstance() {
        return instance;
    }
    
    /**
     * Guardar en caché con TTL por defecto
     */
    public void put(String key, Object value) {
        put(key, value, defaultTTL);
    }
    
    /**
     * Guardar en caché con TTL personalizado (ms)
     */
    public void put(String key, Object value, long ttl) {
        if (cache.size() >= maxSize) {
            evictOldest();
        }
        cache.put(key, new CacheEntry(value, System.currentTimeMillis() + ttl));
    }
    
    /**
     * Obtener del caché
     */
    public Object get(String key) {
        CacheEntry entry = cache.get(key);
        if (entry == null) return null;
        
        // Verificar si expiró
        if (System.currentTimeMillis() > entry.expiresAt) {
            cache.remove(key);
            return null;
        }
        
        return entry.value;
    }
    
    /**
     * Obtener typed
     */
    @SuppressWarnings("unchecked")
    public <T> T get(String key, Class<T> type) {
        Object value = get(key);
        if (value != null && type.isInstance(value)) {
            return (T) value;
        }
        return null;
    }
    
    /**
     * Invalidar caché
     */
    public void invalidate(String key) {
        cache.remove(key);
    }
    
    /**
     * Limpiar todo el caché
     */
    public void clear() {
        cache.clear();
    }
    
    /**
     * Obtener estadísticas
     */
    public Map<String, Object> getStats() {
        Map<String, Object> stats = new LinkedHashMap<>();
        stats.put("size", cache.size());
        stats.put("maxSize", maxSize);
        stats.put("entries", cache.keySet());
        return stats;
    }
    
    // Métodos privados
    
    private void evictOldest() {
        cache.entrySet().stream()
            .min(Comparator.comparing(e -> e.getValue().createdAt))
            .ifPresent(e -> cache.remove(e.getKey()));
    }
    
    private void startCleanupThread() {
        Thread cleanupThread = new Thread(() -> {
            while (true) {
                try {
                    Thread.sleep(300000); // Limpiar cada 5 minutos
                    long now = System.currentTimeMillis();
                    cache.entrySet().removeIf(e -> now > e.getValue().expiresAt);
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                    break;
                }
            }
        });
        cleanupThread.setDaemon(true);
        cleanupThread.start();
    }
    
    // Clase interna
    
    private static class CacheEntry {
        Object value;
        long createdAt;
        long expiresAt;
        
        CacheEntry(Object value, long expiresAt) {
            this.value = value;
            this.createdAt = System.currentTimeMillis();
            this.expiresAt = expiresAt;
        }
    }
}
