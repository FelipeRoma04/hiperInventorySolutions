/**
 * performance-optimizer.js
 * Utilidades de optimización de frontend para Fase 4
 */

const PerformanceOptimizer = {
    
    /**
     * Lazy loading de imágenes usando Intersection Observer
     */
    enableLazyLoading() {
        const images = document.querySelectorAll('img[data-src]');
        
        if ('IntersectionObserver' in window) {
            const imageObserver = new IntersectionObserver((entries, observer) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        const img = entry.target;
                        img.src = img.dataset.src;
                        img.classList.add('loaded');
                        observer.unobserve(img);
                    }
                });
            });
            
            images.forEach(img => imageObserver.observe(img));
        } else {
            // Fallback para navegadores antiguos
            images.forEach(img => {
                img.src = img.dataset.src;
            });
        }
    },
    
    /**
     * Medir performance de página
     */
    measurePagePerformance() {
        const perfData = window.performance.timing;
        const pageLoadTime = perfData.loadEventEnd - perfData.navigationStart;
        
        const metrics = {
            domInteractive: perfData.domInteractive - perfData.navigationStart,
            domComplete: perfData.domComplete - perfData.navigationStart,
            resourceLoad: perfData.responseEnd - perfData.fetchStart,
            pageLoadTime: pageLoadTime
        };
        
        console.log('Performance Metrics:', metrics);
        return metrics;
    },
    
    /**
     * Minificar CSS inline
     */
    minifyInlineCSS(cssText) {
        return cssText
            .replace(/\/\*[^*]*\*+(?:[^/*][^*]*\*+)*\//g, '') // Remover comentarios
            .replace(/\s+/g, ' ') // Remover espacios
            .replace(/\s*([{}:;,>+~])\s*/g, '$1') // Remover espacios alrededor operadores
            .replace(/;}g, '}') // Remover ; antes de }
            .trim();
    },
    
    /**
     * Minificar JavaScript inline
     */
    minifyInlineJS(jsText) {
        return jsText
            .replace(/\/\/.*?(?=\n|$)/g, '') // Comentarios //
            .replace(/\/\*[^*]*\*+(?:[^/*][^*]*\*+)*\//g, '') // Comentarios /* */
            .replace(/\s+/g, ' ')
            .replace(/\s*([{}[\];:,=<>!&|?+*/-])\s*/g, '$1')
            .trim();
    },
    
    /**
     * Resource Prefetching
     */
    enablePrefetching() {
        const prefetchLinks = [
            '/api/assets',
            '/api/depreciation',
            '/api/maintenance'
        ];
        
        prefetchLinks.forEach(link => {
            const prefetch = document.createElement('link');
            prefetch.rel = 'prefetch';
            prefetch.href = link;
            document.head.appendChild(prefetch);
        });
    },
    
    /**
     * Enviar beacon de analytics (sin bloquear)
     */
    sendBeacon(url, data) {
        if (navigator.sendBeacon) {
            navigator.sendBeacon(url, JSON.stringify(data));
        } else {
            fetch(url, {
                method: 'POST',
                body: JSON.stringify(data),
                keepalive: true
            });
        }
    },
    
    /**
     * Comprimir datos con compresión de texto
     */
    compressText(text) {
        // Implementación simple de compresión
        let compressed = text;
        const replacements = {
            'function ': 'f ',
            'document': 'd',
            'window': 'w',
            'return': 'r',
            'const': 'c',
            'let': 'l',
            'var': 'v'
        };
        
        Object.entries(replacements).forEach(([key, value]) => {
            compressed = compressed.replaceAll(key, value);
        });
        
        return compressed;
    },
    
    /**
     * Cache busting para archivos
     */
    getCacheBustedUrl(url) {
        const timestamp = new Date().getTime();
        const separator = url.includes('?') ? '&' : '?';
        return `${url}${separator}v=${timestamp}`;
    },
    
    /**
     * Medir tiempo de operaciones
     */
    measureOperation(name, fn) {
        const start = performance.now();
        const result = fn();
        const end = performance.now();
        const duration = end - start;
        console.log(`${name} took ${duration.toFixed(2)}ms`);
        return { result, duration };
    },
    
    /**
     * Monitorear Largest Contentful Paint (LCP)
     */
    monitorLCP() {
        if ('PerformanceObserver' in window) {
            try {
                const observer = new PerformanceObserver((entryList) => {
                    const entries = entryList.getEntries();
                    const lastEntry = entries[entries.length - 1];
                    console.log('LCP:', lastEntry.renderTime || lastEntry.loadTime);
                });
                observer.observe({ entryTypes: ['largest-contentful-paint'] });
            } catch (e) {
                console.log('LCP monitoring not supported');
            }
        }
    },
    
    /**
     * Monitorear First Input Delay (FID)
     */
    monitorFID() {
        if ('PerformanceObserver' in window) {
            try {
                const observer = new PerformanceObserver((entryList) => {
                    const entry = entryList.getEntries()[0];
                    console.log('FID:', entry.processingDuration);
                });
                observer.observe({ entryTypes: ['first-input'] });
            } catch (e) {
                console.log('FID monitoring not supported');
            }
        }
    },
    
    /**
     * Monitorear Cumulative Layout Shift (CLS)
     */
    monitorCLS() {
        let clsValue = 0;
        if ('PerformanceObserver' in window) {
            try {
                const observer = new PerformanceObserver((entryList) => {
                    for (const entry of entryList.getEntries()) {
                        if (!entry.hadRecentInput) {
                            clsValue += entry.value;
                        }
                    }
                    console.log('CLS:', clsValue);
                });
                observer.observe({ entryTypes: ['layout-shift'] });
            } catch (e) {
                console.log('CLS monitoring not supported');
            }
        }
    },
    
    /**
     * Inicializar todas las optimizaciones
     */
    init() {
        console.log('🚀 Inicializando PerformanceOptimizer...');
        this.enableLazyLoading();
        this.enablePrefetching();
        this.monitorLCP();
        this.monitorFID();
        this.monitorCLS();
        
        document.addEventListener('DOMContentLoaded', () => {
            const metrics = this.measurePagePerformance();
            console.log('✅ Performance Optimizer iniciado');
            console.log('📊 Métricas:', metrics);
        });
    }
};

// Auto-inicializar si se incluye directamente
if (document.currentScript) {
    PerformanceOptimizer.init();
}
