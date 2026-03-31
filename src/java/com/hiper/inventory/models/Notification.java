package com.hiper.inventory.models;

import java.io.Serializable;
import java.util.Date;

/**
 * Modelo para Notificaciones
 */
public class Notification implements Serializable {
    private static final long serialVersionUID = 1L;
    
    private int id;
    private int userId;
    private String titulo;
    private String mensaje;
    private String tipo; // WARNING, SUCCESS, INFO, ERROR
    private String enlace; // URL para navegar
    private boolean leido;
    private Date fechaCreacion;
    private String icono; // Clase Font Awesome

    // Constructor
    public Notification() {}

    public Notification(int userId, String titulo, String mensaje, String tipo) {
        this.userId = userId;
        this.titulo = titulo;
        this.mensaje = mensaje;
        this.tipo = tipo;
        this.leido = false;
        this.fechaCreacion = new Date();
    }

    // Getters y Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getTitulo() { return titulo; }
    public void setTitulo(String titulo) { this.titulo = titulo; }

    public String getMensaje() { return mensaje; }
    public void setMensaje(String mensaje) { this.mensaje = mensaje; }

    public String getTipo() { return tipo; }
    public void setTipo(String tipo) { this.tipo = tipo; }

    public String getEnlace() { return enlace; }
    public void setEnlace(String enlace) { this.enlace = enlace; }

    public boolean isLeido() { return leido; }
    public void setLeido(boolean leido) { this.leido = leido; }

    public Date getFechaCreacion() { return fechaCreacion; }
    public void setFechaCreacion(Date fechaCreacion) { this.fechaCreacion = fechaCreacion; }

    public String getIcono() { return icono; }
    public void setIcono(String icono) { this.icono = icono; }
}
