/**
 * API Client para consumir endpoints de Fase 3
 * Mantenimiento, Depreciación, Importación, 2FA, API Keys
 */

const Phase3API = {
    
    // ========== MANTENIMIENTO ==========
    
    /**
     * Obtener mantenimientos pendientes
     */
    async getPendingMaintenance() {
        try {
            const response = await fetch('/GlobanInventorySolutions/api/maintenance/pending', {
                method: 'GET',
                headers: { 'Content-Type': 'application/json' }
            });
            return await response.json();
        } catch (err) {
            console.error('Error fetching pending maintenance:', err);
            return [];
        }
    },
    
    /**
     * Crear mantenimiento
     */
    async createMaintenance(assetId, type, description, scheduledDate, priority = 'Media') {
        try {
            const response = await fetch('/GlobanInventorySolutions/api/maintenance/', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    assetId: assetId,
                    type: type,
                    description: description,
                    scheduledDate: scheduledDate,
                    priority: priority,
                    status: 'Pendiente'
                })
            });
            return await response.json();
        } catch (err) {
            console.error('Error creating maintenance:', err);
            return null;
        }
    },
    
    /**
     * Obtener mantenimientos de activo
     */
    async getAssetMaintenance(assetId) {
        try {
            const response = await fetch(`/GlobanInventorySolutions/api/maintenance/asset/${assetId}`, {
                method: 'GET',
                headers: { 'Content-Type': 'application/json' }
            });
            return await response.json();
        } catch (err) {
            console.error('Error fetching asset maintenance:', err);
            return [];
        }
    },
    
    // ========== DEPRECIACIÓN ==========
    
    /**
     * Obtener depreciaciones
     */
    async getAllDepreciation() {
        try {
            const response = await fetch('/GlobanInventorySolutions/api/depreciation/', {
                method: 'GET',
                headers: { 'Content-Type': 'application/json' }
            });
            return await response.json();
        } catch (err) {
            console.error('Error fetching depreciation:', err);
            return [];
        }
    },
    
    /**
     * Obtener depreciación de activo
     */
    async getAssetDepreciation(assetId) {
        try {
            const response = await fetch(`/GlobanInventorySolutions/api/depreciation/asset/${assetId}`, {
                method: 'GET',
                headers: { 'Content-Type': 'application/json' }
            });
            return await response.json();
        } catch (err) {
            console.error('Error fetching asset depreciation:', err);
            return null;
        }
    },
    
    /**
     * Crear depreciación
     */
    async createDepreciation(assetId, purchasePrice, usefulLife, purchaseDate, method = 'Linear') {
        try {
            const response = await fetch('/GlobanInventorySolutions/api/depreciation/',  {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    assetId: assetId,
                    purchasePrice: purchasePrice,
                    usefulLife: usefulLife,
                    purchaseDate: purchaseDate,
                    method: method,
                    residualValue: 0
                })
            });
            return await response.json();
        } catch (err) {
            console.error('Error creating depreciation:', err);
            return null;
        }
    },
    
    // ========== IMPORTACIÓN ==========
    
    /**
     * Importar activos desde Excel
     */
    async importAssets(file) {
        try {
            const formData = new FormData();
            formData.append('file', file);
            
            const response = await fetch('/GlobanInventorySolutions/api/import/', {
                method: 'POST',
                body: formData
            });
            return await response.json();
        } catch (err) {
            console.error('Error importing assets:', err);
            return { success: false, error: err.message };
        }
    },
    
    // ========== 2FA / OTP ==========
    
    /**
     * Generar secret para 2FA
     */
    async generate2FASecret() {
        try {
            const response = await fetch('/GlobanInventorySolutions/api/auth/2fa/generate', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' }
            });
            return await response.json();
        } catch (err) {
            console.error('Error generating 2FA secret:', err);
            return null;
        }
    },
    
    /**
     * Verificar código OTP
     */
    async verify2FA(otp) {
        try {
            const response = await fetch('/GlobanInventorySolutions/api/auth/2fa/verify', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ otp: otp })
            });
            return await response.json();
        } catch (err) {
            console.error('Error verifying 2FA:', err);
            return { verified: false };
        }
    },
    
    // ========== API KEYS ==========
    
    /**
     * Crear API key
     */
    async createAPIKey(description, permissions = ['assets:read']) {
        try {
            const response = await fetch('/GlobanInventorySolutions/api/auth/api-keys', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    description: description,
                    permissions: permissions
                })
            });
            return await response.json();
        } catch (err) {
            console.error('Error creating API key:', err);
            return null;
        }
    },
    
    /**
     * Obtener API keys del usuario
     */
    async getAPIKeys() {
        try {
            const response = await fetch('/GlobanInventorySolutions/api/auth/api-keys', {
                method: 'GET',
                headers: { 'Content-Type': 'application/json' }
            });
            return await response.json();
        } catch (err) {
            console.error('Error fetching API keys:', err);
            return [];
        }
    },
    
    /**
     * Revocar API key
     */
    async revokeAPIKey(keyId) {
        try {
            const response = await fetch(`/GlobanInventorySolutions/api/auth/api-keys/${keyId}`, {
                method: 'DELETE',
                headers: { 'Content-Type': 'application/json' }
            });
            return await response.json();
        } catch (err) {
            console.error('Error revoking API key:', err);
            return { success: false };
        }
    },
    
    // ========== API EXTERNA ==========
    
    /**
     * Consumir API externa (requiere API key)
     */
    async externalAPI(endpoint, apiKey, method = 'GET', data = null) {
        try {
            const options = {
                method: method,
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${apiKey}`
                }
            };
            
            if (data) {
                options.body = JSON.stringify(data);
            }
            
            const response = await fetch(`/GlobanInventorySolutions/api/external${endpoint}`, options);
            return await response.json();
        } catch (err) {
            console.error('Error calling external API:', err);
            return { error: err.message };
        }
    },
    
    /**
     * Obtener activos via API externa
     */
    async externalGetAssets(apiKey) {
        return this.externalAPI('/assets', apiKey, 'GET');
    },
    
    /**
     * Buscar activos via API externa
     */
    async externalSearchAssets(apiKey, query) {
        return this.externalAPI(`/search?q=${encodeURIComponent(query)}`, apiKey, 'GET');
    }
};

// Exportar para uso en navegador
window.Phase3API = Phase3API;
