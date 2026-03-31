/**
 * Color Customizer - Gestor de esquemas de color personalizados
 * Permite seleccionar entre esquemas predefinidos o crear personalizados
 */

class ColorCustomizer {
  constructor() {
    this.STORAGE_KEY = 'color-custom-preference';
    this.DEFAULT_SCHEMES = {
      purple: {
        name: 'Púrpura Neon',
        primary: '#5B6AE6',
        secondary: '#6C63FF',
        accent: '#FF6BAE'
      },
      blue: {
        name: 'Azul Océano',
        primary: '#0066FF',
        secondary: '#0040FF',
        accent: '#FF6B6B'
      },
      green: {
        name: 'Verde Naturaleza',
        primary: '#10B981',
        secondary: '#059669',
        accent: '#F59E0B'
      },
      pink: {
        name: 'Rosa Moderno',
        primary: '#EC4899',
        secondary: '#DB2777',
        accent: '#7C3AED'
      },
      orange: {
        name: 'Naranja Energía',
        primary: '#F97316',
        secondary: '#EA580C',
        accent: '#3B82F6'
      },
      indigo: {
        name: 'Índigo Profesional',
        primary: '#4F46E5',
        secondary: '#4338CA',
        accent: '#E0E7FF'
      },
      cyan: {
        name: 'Cian Tecnológico',
        primary: '#06B6D4',
        secondary: '#0891B2',
        accent: '#164E63'
      },
      rose: {
        name: 'Rosa Elegante',
        primary: '#E11D48',
        secondary: '#BE185D',
        accent: '#8B5CF6'
      }
    };
    
    this.currentScheme = this.getStoredScheme() || 'purple';
    this.init();
  }

  /**
   * Inicializar el gestor de colores
   */
  init() {
    this.applyColorScheme(this.currentScheme);
  }

  /**
   * Obtener esquema almacenado
   */
  getStoredScheme() {
    return localStorage.getItem(this.STORAGE_KEY);
  }

  /**
   * Aplicar esquema de color
   */
  applyColorScheme(schemeName) {
    const scheme = this.DEFAULT_SCHEMES[schemeName];
    if (!scheme) return;

    const root = document.documentElement;
    root.style.setProperty('--color-primary', scheme.primary);
    root.style.setProperty('--color-secondary', scheme.secondary);
    root.style.setProperty('--color-accent', scheme.accent);
    
    localStorage.setItem(this.STORAGE_KEY, schemeName);
    this.currentScheme = schemeName;
  }

  /**
   * Aplicar colores personalizados
   */
  applyCustomColors(primary, secondary, accent) {
    const root = document.documentElement;
    root.style.setProperty('--color-primary', primary);
    root.style.setProperty('--color-secondary', secondary);
    root.style.setProperty('--color-accent', accent);
    
    const custom = {
      primary: primary,
      secondary: secondary,
      accent: accent
    };
    
    localStorage.setItem(this.STORAGE_KEY + '-custom', JSON.stringify(custom));
  }

  /**
   * Obtener esquema actual
   */
  getCurrentScheme() {
    return this.DEFAULT_SCHEMES[this.currentScheme];
  }

  /**
   * Obtener todos los esquemas disponibles
   */
  getAvailableSchemes() {
    return this.DEFAULT_SCHEMES;
  }

  /**
   * Generar HTML de selector de colores
   */
  generateColorPicker() {
    return `
      <div class="color-picker-container">
        <h5 class="mb-3">Seleccionar Esquema de Color</h5>
        <div class="color-schemes-grid">
          ${Object.entries(this.DEFAULT_SCHEMES).map(([key, scheme]) => `
            <div class="color-scheme-card" data-scheme="${key}">
              <div class="scheme-preview">
                <div class="color-dot" style="background-color: ${scheme.primary};"></div>
                <div class="color-dot" style="background-color: ${scheme.secondary};"></div>
                <div class="color-dot" style="background-color: ${scheme.accent};"></div>
              </div>
              <small>${scheme.name}</small>
            </div>
          `).join('')}
        </div>
        <hr>
        <h6 class="mb-2">Personalizar Colores</h6>
        <div class="custom-color-picker">
          <div class="color-input-group">
            <label for="primary-color">Color Primario:</label>
            <input type="color" id="primary-color" value="#5B6AE6" class="form-control form-control-color">
          </div>
          <div class="color-input-group">
            <label for="secondary-color">Color Secundario:</label>
            <input type="color" id="secondary-color" value="#6C63FF" class="form-control form-control-color">
          </div>
          <div class="color-input-group">
            <label for="accent-color">Color de Acento:</label>
            <input type="color" id="accent-color" value="#FF6BAE" class="form-control form-control-color">
          </div>
          <button class="btn btn-primary btn-sm mt-2" id="apply-custom-colors">Aplicar Colores</button>
        </div>
      </div>
    `;
  }

  /**
   * Agregar event listeners al picker
   */
  attachColorPickerEvents() {
    // Esquemas predefinidos
    const schemeCards = document.querySelectorAll('.color-scheme-card');
    schemeCards.forEach(card => {
      card.addEventListener('click', () => {
        const scheme = card.getAttribute('data-scheme');
        this.applyColorScheme(scheme);
        
        schemeCards.forEach(c => c.classList.remove('active'));
        card.classList.add('active');
      });
    });

    // Colores personalizados
    const applyBtn = document.getElementById('apply-custom-colors');
    if (applyBtn) {
      applyBtn.addEventListener('click', () => {
        const primary = document.getElementById('primary-color').value;
        const secondary = document.getElementById('secondary-color').value;
        const accent = document.getElementById('accent-color').value;
        
        this.applyCustomColors(primary, secondary, accent);
      });
    }
  }
}

// Generar CSS dinámico para el color picker
if (!document.getElementById('color-picker-styles')) {
  const style = document.createElement('style');
  style.id = 'color-picker-styles';
  style.textContent = `
    .color-picker-container {
      padding: 20px;
    }

    .color-schemes-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
      gap: 15px;
      margin-bottom: 20px;
    }

    .color-scheme-card {
      cursor: pointer;
      padding: 12px;
      border: 2px solid transparent;
      border-radius: 8px;
      text-align: center;
      transition: 0.3s ease;
      background-color: var(--bg-secondary);
    }

    .color-scheme-card:hover {
      border-color: var(--color-primary);
      transform: translateY(-2px);
    }

    .color-scheme-card.active {
      border-color: var(--color-primary);
      background-color: var(--bg-tertiary);
    }

    .scheme-preview {
      display: flex;
      gap: 8px;
      justify-content: center;
      margin-bottom: 10px;
    }

    .color-dot {
      width: 30px;
      height: 30px;
      border-radius: 50%;
      border: 2px solid transparent;
      transition: 0.3s ease;
    }

    .color-scheme-card:hover .color-dot {
      border-color: rgba(255, 255, 255, 0.5);
    }

    .custom-color-picker {
      background-color: var(--bg-tertiary);
      padding: 15px;
      border-radius: 8px;
    }

    .color-input-group {
      margin-bottom: 12px;
    }

    .color-input-group label {
      display: block;
      margin-bottom: 5px;
      font-weight: 600;
      font-size: 0.9rem;
    }

    .form-control-color {
      height: 40px;
      cursor: pointer;
      border-radius: 6px;
      border: 1px solid var(--border-color);
    }

    .form-control-color:hover {
      border-color: var(--color-primary);
    }
  `;
  document.head.appendChild(style);
}

// Inicializar cuando DOM está listo
document.addEventListener('DOMContentLoaded', () => {
  window.colorCustomizer = new ColorCustomizer();
});
