package com.hiper.inventory.models;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * Modelo de Registro de Auditoría
 * Registra quién hizo qué y cuándo para trazabilidad y control
 */
public class AuditLog implements Serializable {
    private static final long serialVersionUID = 1L;
    
    private int id;
    private int userId;
    private String username;
    private String action; // "CREATE", "UPDATE", "DELETE", "VIEW"
    private String tableName;
    private int recordId;
    private String recordDescription;
    private String oldValues; // JSON string
    private String newValues; // JSON string
    private String ipAddress;
    private String userAgent;
    private LocalDateTime timestamp;
    private String status; // "SUCCESS", "FAILURE"
    private String errorMessage;
    
    // Constructores
    public AuditLog() {}
    
    public AuditLog(int userId, String username, String action, String tableName, int recordId) {
        this.userId = userId;
        this.username = username;
        this.action = action;
        this.tableName = tableName;
        this.recordId = recordId;
        this.timestamp = LocalDateTime.now();
        this.status = "SUCCESS";
    }
    
    // Getters y Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    
    public String getAction() { return action; }
    public void setAction(String action) { this.action = action; }
    
    public String getTableName() { return tableName; }
    public void setTableName(String tableName) { this.tableName = tableName; }
    
    public int getRecordId() { return recordId; }
    public void setRecordId(int recordId) { this.recordId = recordId; }
    
    public String getRecordDescription() { return recordDescription; }
    public void setRecordDescription(String recordDescription) { this.recordDescription = recordDescription; }
    
    public String getOldValues() { return oldValues; }
    public void setOldValues(String oldValues) { this.oldValues = oldValues; }
    
    public String getNewValues() { return newValues; }
    public void setNewValues(String newValues) { this.newValues = newValues; }
    
    public String getIpAddress() { return ipAddress; }
    public void setIpAddress(String ipAddress) { this.ipAddress = ipAddress; }
    
    public String getUserAgent() { return userAgent; }
    public void setUserAgent(String userAgent) { this.userAgent = userAgent; }
    
    public LocalDateTime getTimestamp() { return timestamp; }
    public void setTimestamp(LocalDateTime timestamp) { this.timestamp = timestamp; }
    
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    
    public String getErrorMessage() { return errorMessage; }
    public void setErrorMessage(String errorMessage) { this.errorMessage = errorMessage; }
    
    @Override
    public String toString() {
        return "AuditLog{" +
                "id=" + id +
                ", username='" + username + '\'' +
                ", action='" + action + '\'' +
                ", tableName='" + tableName + '\'' +
                ", recordId=" + recordId +
                ", timestamp=" + timestamp +
                ", status='" + status + '\'' +
                '}';
    }
}
