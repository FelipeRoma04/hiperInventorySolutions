package com.hiper.inventory.models;

import java.io.Serializable;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Modelo de Mantenimiento Preventivo
 * Gestiona agendas de mantenimiento y historial de trabajos realizados
 */
public class Maintenance implements Serializable {
    private static final long serialVersionUID = 1L;
    
    private int id;
    private int assetId;
    private String type; // "Preventivo", "Correctivo", "Inspección"
    private String description;
    private LocalDate scheduledDate;
    private LocalDate completedDate;
    private String status; // "Pendiente", "Completado", "Cancelado"
    private String technician;
    private String notes;
    private double cost;
    private String priority; // "Baja", "Media", "Alta", "Crítica"
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    // Constructores
    public Maintenance() {}
    
    public Maintenance(int assetId, String type, String description, LocalDate scheduledDate) {
        this.assetId = assetId;
        this.type = type;
        this.description = description;
        this.scheduledDate = scheduledDate;
        this.status = "Pendiente";
        this.priority = "Media";
        this.createdAt = LocalDateTime.now();
    }
    
    // Getters y Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public int getAssetId() { return assetId; }
    public void setAssetId(int assetId) { this.assetId = assetId; }
    
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    
    public LocalDate getScheduledDate() { return scheduledDate; }
    public void setScheduledDate(LocalDate scheduledDate) { this.scheduledDate = scheduledDate; }
    
    public LocalDate getCompletedDate() { return completedDate; }
    public void setCompletedDate(LocalDate completedDate) { this.completedDate = completedDate; }
    
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    
    public String getTechnician() { return technician; }
    public void setTechnician(String technician) { this.technician = technician; }
    
    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }
    
    public double getCost() { return cost; }
    public void setCost(double cost) { this.cost = cost; }
    
    public String getPriority() { return priority; }
    public void setPriority(String priority) { this.priority = priority; }
    
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
    
    @Override
    public String toString() {
        return "Maintenance{" +
                "id=" + id +
                ", assetId=" + assetId +
                ", type='" + type + '\'' +
                ", status='" + status + '\'' +
                ", scheduledDate=" + scheduledDate +
                ", priority='" + priority + '\'' +
                '}';
    }
}
