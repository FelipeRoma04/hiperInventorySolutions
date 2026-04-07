/**
 * API Client para comunicarse con el backend Java REST 
 */
class ApiClient {
    
    /**
     * Realiza una llamada GET
     */
    static async get(endpoint) {
        try {
            const response = await fetch(endpoint, {
                method: 'GET',
                headers: {
                    'Content-Type': 'application/json'
                }
            });
            return await response.json();
        } catch (error) {
            console.error('❌ Error en GET ' + endpoint, error);
            return { success: false, error: error.message };
        }
    }
    
    /**
     * Realiza una llamada POST
     */
    static async post(endpoint, data = {}) {
        try {
            const response = await fetch(endpoint, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                },
                body: new URLSearchParams(data)
            });
            return await response.json();
        } catch (error) {
            console.error('❌ Error en POST ' + endpoint, error);
            return { success: false, error: error.message };
        }
    }
    
    /**
     * Realiza una llamada PUT
     */
    static async put(endpoint, data = {}) {
        try {
            const response = await fetch(endpoint, {
                method: 'PUT',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                },
                body: new URLSearchParams(data)
            });
            return await response.json();
        } catch (error) {
            console.error('❌ Error en PUT ' + endpoint, error);
            return { success: false, error: error.message };
        }
    }
    
    /**
     * Realiza una llamada DELETE
     */
    static async delete(endpoint) {
        try {
            const response = await fetch(endpoint, {
                method: 'DELETE'
            });
            return await response.json();
        } catch (error) {
            console.error('❌ Error en DELETE ' + endpoint, error);
            return { success: false, error: error.message };
        }
    }
}

/**
 * Servicio de Autenticación
 */
class AuthService {
    
    static async login(username, password) {
        return await ApiClient.post('/GlobanInventorySolutions/api/auth/login', {
            username, password
        });
    }
    
    static async logout() {
        return await ApiClient.post('/GlobanInventorySolutions/api/auth/logout', {});
    }
    
    static async register(username, password, email, nombre, rol) {
        return await ApiClient.post('/GlobanInventorySolutions/api/auth/register', {
            username, password, email, nombre, rol
        });
    }
}

/**
 * Servicio de Activos (Assets)
 */
class AssetService {
    
    static async getAll() {
        return await ApiClient.get('/GlobanInventorySolutions/api/assets');
    }
    
    static async getById(id) {
        return await ApiClient.get(`/GlobanInventorySolutions/api/assets/${id}`);
    }
    
    static async search(q, categoria, estado, ubicacion) {
        let url = '/GlobanInventorySolutions/api/assets/search?';
        if (q) url += 'q=' + encodeURIComponent(q) + '&';
        if (categoria) url += 'categoria=' + encodeURIComponent(categoria) + '&';
        if (estado) url += 'estado=' + encodeURIComponent(estado) + '&';
        if (ubicacion) url += 'ubicacion=' + encodeURIComponent(ubicacion);
        
        return await ApiClient.get(url);
    }
    
    static async create(asset) {
        return await ApiClient.post('/GlobanInventorySolutions/api/assets', asset);
    }
    
    static async update(id, data) {
        return await ApiClient.put(`/GlobanInventorySolutions/api/assets/${id}`, data);
    }
    
    static async delete(id) {
        return await ApiClient.delete(`/GlobanInventorySolutions/api/assets/${id}`);
    }
    
    static async getStats() {
        return await ApiClient.get('/GlobanInventorySolutions/api/assets/stats');
    }
    
    static async getLowStock() {
        return await ApiClient.get('/GlobanInventorySolutions/api/assets/low-stock');
    }
}

/**
 * Servicio de Reportes
 */
class ReportService {
    
    static downloadCSV() {
        window.location.href = '/GlobanInventorySolutions/api/reports/assets-csv';
    }
    
    static viewPDF() {
        window.open('/GlobanInventorySolutions/api/reports/assets-pdf', '_blank');
    }
    
    static async generateReport(type) {
        if (type === 'csv') {
            this.downloadCSV();
        } else if (type === 'pdf') {
            this.viewPDF();
        }
    }
}

console.log('✅ API Client cargado - Fase 3 Backend activo');
