package com.hiper.inventory.models;

import java.io.Serializable;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Modelo de Depreciación de Activos Fijos
 * Calcula depreciación por línea recta o saldo decreciente
 */
public class Depreciation implements Serializable {
    private static final long serialVersionUID = 1L;
    
    private int id;
    private int assetId;
    private double purchasePrice;
    private double residualValue;
    private int usefulLife; // en años
    private LocalDate purchaseDate;
    private String method; // "Linear", "DecreasingBalance"
    private double depreciationRate;
    private double monthlyDepreciation;
    private double accumulatedDepreciation;
    private double currentValue;
    private LocalDateTime lastCalculated;
    
    // Constructores
    public Depreciation() {}
    
    public Depreciation(int assetId, double purchasePrice, int usefulLife, LocalDate purchaseDate) {
        this.assetId = assetId;
        this.purchasePrice = purchasePrice;
        this.usefulLife = usefulLife;
        this.purchaseDate = purchaseDate;
        this.method = "Linear";
        this.residualValue = 0;
        calculateDepreciation();
    }
    
    // Calcula depreciación automáticamente
    public void calculateDepreciation() {
        if (method.equals("Linear")) {
            this.monthlyDepreciation = (purchasePrice - residualValue) / (usefulLife * 12);
            this.depreciationRate = 100.0 / (usefulLife * 12);
        } else if (method.equals("DecreasingBalance")) {
            this.depreciationRate = (2.0 / usefulLife) * 100;
            this.monthlyDepreciation = (purchasePrice * depreciationRate) / 100;
        }
        
        // Calcula depreciación acumulada y valor actual
        long monthsElapsed = calculateMonthsElapsed();
        if (method.equals("Linear")) {
            this.accumulatedDepreciation = monthlyDepreciation * monthsElapsed;
        } else {
            // Saldo decreciente: V = P * (1 - r/100)^t
            this.accumulatedDepreciation = purchasePrice - 
                (purchasePrice * Math.pow(1 - (depreciationRate / 100), monthsElapsed / 12.0));
        }
        
        this.currentValue = Math.max(purchasePrice - accumulatedDepreciation, residualValue);
        this.lastCalculated = LocalDateTime.now();
    }
    
    private long calculateMonthsElapsed() {
        LocalDate today = LocalDate.now();
        return (today.getYear() - purchaseDate.getYear()) * 12 + 
               (today.getMonthValue() - purchaseDate.getMonthValue());
    }
    
    // Getters y Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public int getAssetId() { return assetId; }
    public void setAssetId(int assetId) { this.assetId = assetId; }
    
    public double getPurchasePrice() { return purchasePrice; }
    public void setPurchasePrice(double purchasePrice) { this.purchasePrice = purchasePrice; }
    
    public double getResidualValue() { return residualValue; }
    public void setResidualValue(double residualValue) { this.residualValue = residualValue; }
    
    public int getUsefulLife() { return usefulLife; }
    public void setUsefulLife(int usefulLife) { this.usefulLife = usefulLife; }
    
    public LocalDate getPurchaseDate() { return purchaseDate; }
    public void setPurchaseDate(LocalDate purchaseDate) { this.purchaseDate = purchaseDate; }
    
    public String getMethod() { return method; }
    public void setMethod(String method) { this.method = method; }
    
    public double getDepreciationRate() { return depreciationRate; }
    public void setDepreciationRate(double depreciationRate) { this.depreciationRate = depreciationRate; }
    
    public double getMonthlyDepreciation() { return monthlyDepreciation; }
    public void setMonthlyDepreciation(double monthlyDepreciation) { this.monthlyDepreciation = monthlyDepreciation; }
    
    public double getAccumulatedDepreciation() { return accumulatedDepreciation; }
    public void setAccumulatedDepreciation(double accumulatedDepreciation) { this.accumulatedDepreciation = accumulatedDepreciation; }
    
    public double getCurrentValue() { return currentValue; }
    public void setCurrentValue(double currentValue) { this.currentValue = currentValue; }
    
    public LocalDateTime getLastCalculated() { return lastCalculated; }
    public void setLastCalculated(LocalDateTime lastCalculated) { this.lastCalculated = lastCalculated; }
    
    @Override
    public String toString() {
        return "Depreciation{" +
                "id=" + id +
                ", assetId=" + assetId +
                ", purchasePrice=" + purchasePrice +
                ", currentValue=" + currentValue +
                ", method='" + method + '\'' +
                '}';
    }
}
