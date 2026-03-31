package com.hiper.inventory.models;

import java.io.Serializable;
import java.util.Date;

/**
 * Modelo para Asignaciones de Activos
 */
public class Assignment implements Serializable {
    private static final long serialVersionUID = 1L;
    
    private int id;
    private int assetId;
    private int userId;
    private String areaDepartamento; // Área a la que se asigna
    private Date fechaAsignacion;
    private Date fechaDevolucionEsperada;
    private Date fechaDevolucionReal;
    private String estado; // ACTIVO, COMPLETADO, VENCIDO
    private String notas;
    private String responsable;
    private int cantidad;

    // Constructor
    public Assignment() {}

    public Assignment(int assetId, int userId, Date fechaAsignacion, 
                     Date fechaDevolucionEsperada) {
        this.assetId = assetId;
        this.userId = userId;
        this.fechaAsignacion = fechaAsignacion;
        this.fechaDevolucionEsperada = fechaDevolucionEsperada;
        this.estado = "ACTIVO";
    }

    // Getters y Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getAssetId() { return assetId; }
    public void setAssetId(int assetId) { this.assetId = assetId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getAreaDepartamento() { return areaDepartamento; }
    public void setAreaDepartamento(String areaDepartamento) { 
        this.areaDepartamento = areaDepartamento; 
    }

    public Date getFechaAsignacion() { return fechaAsignacion; }
    public void setFechaAsignacion(Date fechaAsignacion) { 
        this.fechaAsignacion = fechaAsignacion; 
    }

    public Date getFechaDevolucionEsperada() { return fechaDevolucionEsperada; }
    public void setFechaDevolucionEsperada(Date fechaDevolucionEsperada) { 
        this.fechaDevolucionEsperada = fechaDevolucionEsperada; 
    }

    public Date getFechaDevolucionReal() { return fechaDevolucionReal; }
    public void setFechaDevolucionReal(Date fechaDevolucionReal) { 
        this.fechaDevolucionReal = fechaDevolucionReal; 
    }

    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }

    public String getNotas() { return notas; }
    public void setNotas(String notas) { this.notas = notas; }

    public String getResponsable() { return responsable; }
    public void setResponsable(String responsable) { this.responsable = responsable; }

    public int getCantidad() { return cantidad; }
    public void setCantidad(int cantidad) { this.cantidad = cantidad; }
}
