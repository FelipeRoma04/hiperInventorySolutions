package com.hiper.inventory.models;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * Modelo de API Key para integración externa
 * Permite a sistemas externos consumir la API REST
 */
public class ApiKey implements Serializable {
    private static final long serialVersionUID = 1L;
    
    private int id;
    private int userId;
    private String username;
    private String apiKey; // Token único
    private String description;
    private String status; // "Active", "Inactive", "Revoked"
    private int requestsLimit; // -1 = ilimitado
    private int requestsUsed;
    private LocalDateTime createdAt;
    private LocalDateTime lastUsed;
    private LocalDateTime expiresAt;
    private String[] permissions; // ["assets:read", "assets:write", "reports:read", etc]
    
    // Constructores
    public ApiKey() {}
    
    public ApiKey(int userId, String username, String description) {
        this.userId = userId;
        this.username = username;
        this.description = description;
        this.apiKey = generateApiKey();
        this.status = "Active";
        this.requestsLimit = -1;
        this.requestsUsed = 0;
        this.createdAt = LocalDateTime.now();
        this.expiresAt = LocalDateTime.now().plusYears(1);
        this.permissions = new String[] {"assets:read", "reports:read"};
    }
    
    // Genera un API key único
    private String generateApiKey() {
        return "sk-" + System.currentTimeMillis() + "-" + 
               Math.random() * 1000000000;
    }
    
    // Verifica si la API key está activa y válida
    public boolean isValid() {
        return "Active".equals(status) && 
               (expiresAt == null || LocalDateTime.now().isBefore(expiresAt));
    }
    
    // Verifica si se alcanzó el límite de requests
    public boolean hasRemainingRequests() {
        return requestsLimit == -1 || requestsUsed < requestsLimit;
    }
    
    // Getters y Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    
    public String getApiKey() { return apiKey; }
    public void setApiKey(String apiKey) { this.apiKey = apiKey; }
    
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    
    public int getRequestsLimit() { return requestsLimit; }
    public void setRequestsLimit(int requestsLimit) { this.requestsLimit = requestsLimit; }
    
    public int getRequestsUsed() { return requestsUsed; }
    public void setRequestsUsed(int requestsUsed) { this.requestsUsed = requestsUsed; }
    
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    
    public LocalDateTime getLastUsed() { return lastUsed; }
    public void setLastUsed(LocalDateTime lastUsed) { this.lastUsed = lastUsed; }
    
    public LocalDateTime getExpiresAt() { return expiresAt; }
    public void setExpiresAt(LocalDateTime expiresAt) { this.expiresAt = expiresAt; }
    
    public String[] getPermissions() { return permissions; }
    public void setPermissions(String[] permissions) { this.permissions = permissions; }
    
    // Verifica si tiene un permiso específico
    public boolean hasPermission(String permission) {
        if (permissions == null) return false;
        for (String p : permissions) {
            if (p.equals(permission)) return true;
        }
        return false;
    }
    
    @Override
    public String toString() {
        return "ApiKey{" +
                "id=" + id +
                ", username='" + username + '\'' +
                ", status='" + status + '\'' +
                ", requestsUsed=" + requestsUsed +
                ", createdAt=" + createdAt +
                '}';
    }
}
