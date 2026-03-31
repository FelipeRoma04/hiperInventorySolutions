package com.hiper.inventory.models;

import java.io.Serializable;
import java.util.Date;

/**
 * Modelo de datos para Activos
 */
public class Asset implements Serializable {
    private static final long serialVersionUID = 1L;
    
    private int id;
    private String nombre;
    private String codigo;
    private String descripcion;
    private String categoria;
    private String estado; // Operativo, Reparación, Baja, Préstamo
    private String ubicacion;
    private String sede;
    private double valor;
    private Date fechaRegistro;
    private Date fechaCompra;
    private String imagenUrl;
    private String qrCode;
    private int stockMinimo;
    private int cantidad;
    private String asignadoA;
    private Date fechaAsignacion;
    private Date fechaDevolucionEsperada;
    private String etiquetas; // Comma-separated
    private String responsable;
    private String notas;

    // Constructor vacío
    public Asset() {}

    // Constructor completo
    public Asset(int id, String nombre, String codigo, String categoria, 
                 String estado, String ubicacion, String sede, double valor,
                 int stockMinimo, int cantidad) {
        this.id = id;
        this.nombre = nombre;
        this.codigo = codigo;
        this.categoria = categoria;
        this.estado = estado;
        this.ubicacion = ubicacion;
        this.sede = sede;
        this.valor = valor;
        this.stockMinimo = stockMinimo;
        this.cantidad = cantidad;
    }

    // Getters y Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getCodigo() { return codigo; }
    public void setCodigo(String codigo) { this.codigo = codigo; }

    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }

    public String getCategoria() { return categoria; }
    public void setCategoria(String categoria) { this.categoria = categoria; }

    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }

    public String getUbicacion() { return ubicacion; }
    public void setUbicacion(String ubicacion) { this.ubicacion = ubicacion; }

    public String getSede() { return sede; }
    public void setSede(String sede) { this.sede = sede; }

    public double getValor() { return valor; }
    public void setValor(double valor) { this.valor = valor; }

    public Date getFechaRegistro() { return fechaRegistro; }
    public void setFechaRegistro(Date fechaRegistro) { this.fechaRegistro = fechaRegistro; }

    public Date getFechaCompra() { return fechaCompra; }
    public void setFechaCompra(Date fechaCompra) { this.fechaCompra = fechaCompra; }

    public String getImagenUrl() { return imagenUrl; }
    public void setImagenUrl(String imagenUrl) { this.imagenUrl = imagenUrl; }

    public String getQrCode() { return qrCode; }
    public void setQrCode(String qrCode) { this.qrCode = qrCode; }

    public int getStockMinimo() { return stockMinimo; }
    public void setStockMinimo(int stockMinimo) { this.stockMinimo = stockMinimo; }

    public int getCantidad() { return cantidad; }
    public void setCantidad(int cantidad) { this.cantidad = cantidad; }

    public String getAsignadoA() { return asignadoA; }
    public void setAsignadoA(String asignadoA) { this.asignadoA = asignadoA; }

    public Date getFechaAsignacion() { return fechaAsignacion; }
    public void setFechaAsignacion(Date fechaAsignacion) { this.fechaAsignacion = fechaAsignacion; }

    public Date getFechaDevolucionEsperada() { return fechaDevolucionEsperada; }
    public void setFechaDevolucionEsperada(Date fechaDevolucionEsperada) { 
        this.fechaDevolucionEsperada = fechaDevolucionEsperada; 
    }

    public String getEtiquetas() { return etiquetas; }
    public void setEtiquetas(String etiquetas) { this.etiquetas = etiquetas; }

    public String getResponsable() { return responsable; }
    public void setResponsable(String responsable) { this.responsable = responsable; }

    public String getNotas() { return notas; }
    public void setNotas(String notas) { this.notas = notas; }

    @Override
    public String toString() {
        return "Asset{" +
                "id=" + id +
                ", nombre='" + nombre + '\'' +
                ", codigo='" + codigo + '\'' +
                ", categoria='" + categoria + '\'' +
                ", estado='" + estado + '\'' +
                ", ubicacion='" + ubicacion + '\'' +
                ", valor=" + valor +
                '}';
    }
}
