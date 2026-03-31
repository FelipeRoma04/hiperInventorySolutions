package com.hiper.inventory.servlets;

import com.hiper.inventory.utils.DatabaseUtil;
import javax.servlet.*;
import javax.servlet.annotation.WebListener;

/**
 * Listener que se ejecuta al iniciar la aplicación web
 */
@WebListener
public class AppInitListener implements ServletContextListener {
    
    @Override
    public void contextInitialized(ServletContextEvent sce) {
        System.out.println("\n");
        System.out.println("╔════════════════════════════════════════════════════════════════╗");
        System.out.println("║          🚀 HiperInventory Solutions - INICIANDO 🚀             ║");
        System.out.println("╚════════════════════════════════════════════════════════════════╝");
        System.out.println("\n⏳ Inicializando base de datos SQLite...");
        
        try {
            // Inicializar base de datos
            DatabaseUtil.initializeDatabase();
            
            System.out.println("✅ Base de datos inicializada correctamente");
            System.out.println("✅ Servlets registrados:");
            System.out.println("   - /api/auth/login    [POST]");
            System.out.println("   - /api/auth/logout   [POST]");
            System.out.println("   - /api/auth/register [POST]");
            System.out.println("   - /api/assets        [GET, POST, PUT, DELETE]");
            System.out.println("   - /api/reports/*     [GET]");
            System.out.println("\n✅ Aplicación lista para usar");
            System.out.println("🌐 URL: http://localhost:8080/GlobanInventorySolutions");
            System.out.println("👤 Usuario demo: admin / admin123\n");
            
        } catch (Exception e) {
            System.err.println("❌ Error inicializando aplicación:");
            e.printStackTrace();
        }
    }
    
    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        System.out.println("\n⚠️  Aplicación detenida");
        DatabaseUtil.closeConnection();
    }
}
