package com.hiper.inventory.models;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * Modelo de OTP (One-Time Password) para 2FA
 * Soporta 2FA con app de autenticación (TOTP)
 */
public class OTP implements Serializable {
    private static final long serialVersionUID = 1L;
    
    private int id;
    private int userId;
    private String secret; // Secret key para TOTP
    private String backupCodes; // Códigos de backup (JSON)
    private String method; // "TOTP", "SMS", "Email"
    private String phoneNumber;
    private String email;
    private boolean enabled;
    private boolean verified;
    private LocalDateTime createdAt;
    private LocalDateTime lastUsed;
    
    // Constructores
    public OTP() {}
    
    public OTP(int userId, String method) {
        this.userId = userId;
        this.method = method;
        this.enabled = false;
        this.verified = false;
        this.createdAt = LocalDateTime.now();
    }
    
    // Getters y Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    
    public String getSecret() { return secret; }
    public void setSecret(String secret) { this.secret = secret; }
    
    public String getBackupCodes() { return backupCodes; }
    public void setBackupCodes(String backupCodes) { this.backupCodes = backupCodes; }
    
    public String getMethod() { return method; }
    public void setMethod(String method) { this.method = method; }
    
    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }
    
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public boolean isEnabled() { return enabled; }
    public void setEnabled(boolean enabled) { this.enabled = enabled; }
    
    public boolean isVerified() { return verified; }
    public void setVerified(boolean verified) { this.verified = verified; }
    
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    
    public LocalDateTime getLastUsed() { return lastUsed; }
    public void setLastUsed(LocalDateTime lastUsed) { this.lastUsed = lastUsed; }
    
    @Override
    public String toString() {
        return "OTP{" +
                "id=" + id +
                ", userId=" + userId +
                ", method='" + method + '\'' +
                ", enabled=" + enabled +
                ", verified=" + verified +
                '}';
    }
}
