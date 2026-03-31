/**
 * Theme Manager - Gestor de temas oscuro/claro
 * Permite cambiar entre temas y guardar preferencias
 */

class ThemeManager {
  constructor() {
    this.THEMES = {
      light: 'light',
      dark: 'dark'
    };
    
    this.STORAGE_KEY = 'theme-preference';
    this.LANGUAGE_KEY = 'language-preference';
    this.COLOR_KEY = 'color-preference';
    
    this.currentTheme = this.getStoredTheme() || this.getSystemPreference();
    this.currentLanguage = this.getStoredLanguage() || 'es';
    this.currentColor = this.getStoredColor() || 'purple';
    
    this.init();
  }

  /**
   * Inicializar el gestor de temas
   */
  init() {
    this.applyTheme(this.currentTheme);
    this.loadLanguage(this.currentLanguage);
    this.applyColorScheme(this.currentColor);
    this.attachEventListeners();
    this.loadTranslations();
  }

  /**
   * Obtener el tema almacenado
   */
  getStoredTheme() {
    return localStorage.getItem(this.STORAGE_KEY);
  }

  /**
   * Obtener la preferencia del sistema
   */
  getSystemPreference() {
    if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
      return this.THEMES.dark;
    }
    return this.THEMES.light;
  }

  /**
   * Aplicar tema
   */
  applyTheme(theme) {
    document.documentElement.setAttribute('data-theme', theme);
    document.body.setAttribute('data-theme', theme);
    
    // Cargar hoja de estilos del tema
    const themeLinkId = 'theme-stylesheet';
    let themeLink = document.getElementById(themeLinkId);
    
    if (!themeLink) {
      themeLink = document.createElement('link');
      themeLink.id = themeLinkId;
      themeLink.rel = 'stylesheet';
      document.head.appendChild(themeLink);
    }
    
    themeLink.href = `/GlobanInventorySolutions/css/theme-${theme}.css`;
    localStorage.setItem(this.STORAGE_KEY, theme);
    this.currentTheme = theme;
  }

  /**
   * Toggle entre temas
   */
  toggleTheme() {
    const newTheme = this.currentTheme === this.THEMES.light ? this.THEMES.dark : this.THEMES.light;
    this.applyTheme(newTheme);
    this.updateThemeButton();
  }

  /**
   * Obtener idioma almacenado
   */
  getStoredLanguage() {
    return localStorage.getItem(this.LANGUAGE_KEY);
  }

  /**
   * Cargar idioma
   */
  loadLanguage(lang) {
    this.currentLanguage = lang;
    localStorage.setItem(this.LANGUAGE_KEY, lang);
    
    // Cambiar atributo data-lang en HTML
    document.documentElement.setAttribute('data-lang', lang);
    
    // Cargar archivo de traducciones
    this.loadTranslations();
  }

  /**
   * Cargar traducciones desde JSON
   */
  loadTranslations() {
    const lang = this.currentLanguage;
    const filename = `/GlobanInventorySolutions/i18n/messages_${lang}.json`;
    
    fetch(filename)
      .then(response => response.json())
      .then(translations => {
        this.translations = translations;
        this.applyTranslations();
      })
      .catch(err => console.warn('No se pudo cargar el idioma:', lang));
  }

  /**
   * Aplicar traducciones a elementos con data-i18n
   */
  applyTranslations() {
    const elements = document.querySelectorAll('[data-i18n]');
    elements.forEach(el => {
      const key = el.getAttribute('data-i18n');
      const translation = this.getTranslation(key);
      if (translation) {
        el.textContent = translation;
      }
    });
  }

  /**
   * Obtener traducción por clave
   */
  getTranslation(key) {
    if (!this.translations) return key;
    
    const keys = key.split('.');
    let value = this.translations;
    
    for (let k of keys) {
      if (value[k]) {
        value = value[k];
      } else {
        return key;
      }
    }
    
    return value;
  }

  /**
   * Cambiar idioma
   */
  changeLanguage(lang) {
    this.loadLanguage(lang);
    this.updateLanguageButtons();
  }

  /**
   * Obtener esquema de color almacenado
   */
  getStoredColor() {
    return localStorage.getItem(this.COLOR_KEY);
  }

  /**
   * Aplicar esquema de colores personalizado
   */
  applyColorScheme(colorName) {
    const colorSchemes = {
      purple: {
        primary: '#5B6AE6',
        secondary: '#6C63FF',
        accent: '#FF6BAE'
      },
      blue: {
        primary: '#0066FF',
        secondary: '#0040FF',
        accent: '#FF6B6B'
      },
      green: {
        primary: '#10B981',
        secondary: '#059669',
        accent: '#F59E0B'
      },
      pink: {
        primary: '#EC4899',
        secondary: '#DB2777',
        accent: '#7C3AED'
      },
      orange: {
        primary: '#F97316',
        secondary: '#EA580C',
        accent: '#3B82F6'
      }
    };
    
    const colors = colorSchemes[colorName] || colorSchemes.purple;
    
    const root = document.documentElement;
    root.style.setProperty('--color-primary', colors.primary);
    root.style.setProperty('--color-secondary', colors.secondary);
    root.style.setProperty('--color-accent', colors.accent);
    
    localStorage.setItem(this.COLOR_KEY, colorName);
    this.currentColor = colorName;
  }

  /**
   * Adjuntar event listeners a los botones de tema
   */
  attachEventListeners() {
    // Botón de toggle de tema
    const themeToggle = document.getElementById('theme-toggle-btn');
    if (themeToggle) {
      themeToggle.addEventListener('click', (e) => {
        e.preventDefault();
        this.toggleTheme();
      });
    }

    // Botones de idioma
    const langButtons = document.querySelectorAll('[data-lang-select]');
    langButtons.forEach(btn => {
      btn.addEventListener('click', (e) => {
        e.preventDefault();
        const lang = btn.getAttribute('data-lang-select');
        this.changeLanguage(lang);
      });
    });

    // Botones de color
    const colorButtons = document.querySelectorAll('[data-color-select]');
    colorButtons.forEach(btn => {
      btn.addEventListener('click', (e) => {
        e.preventDefault();
        const color = btn.getAttribute('data-color-select');
        this.applyColorScheme(color);
        this.updateColorButtons();
      });
    });

    // Detectar cambio de preferencia del sistema
    if (window.matchMedia) {
      window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', (e) => {
        if (!localStorage.getItem(this.STORAGE_KEY)) {
          this.applyTheme(e.matches ? this.THEMES.dark : this.THEMES.light);
        }
      });
    }
  }

  /**
   * Actualizar botón de tema (icono)
   */
  updateThemeButton() {
    const btn = document.getElementById('theme-toggle-btn');
    if (btn) {
      const icon = btn.querySelector('i');
      if (icon) {
        if (this.currentTheme === this.THEMES.dark) {
          icon.className = 'fas fa-sun';
          btn.title = 'Cambiar a tema claro';
        } else {
          icon.className = 'fas fa-moon';
          btn.title = 'Cambiar a tema oscuro';
        }
      }
    }
  }

  /**
   * Actualizar botones de idioma (active state)
   */
  updateLanguageButtons() {
    const buttons = document.querySelectorAll('[data-lang-select]');
    buttons.forEach(btn => {
      btn.classList.remove('active');
      if (btn.getAttribute('data-lang-select') === this.currentLanguage) {
        btn.classList.add('active');
      }
    });
  }

  /**
   * Actualizar botones de color (active state)
   */
  updateColorButtons() {
    const buttons = document.querySelectorAll('[data-color-select]');
    buttons.forEach(btn => {
      btn.classList.remove('active');
      if (btn.getAttribute('data-color-select') === this.currentColor) {
        btn.classList.add('active');
      }
    });
  }

  /**
   * Obtener tema actual
   */
  getTheme() {
    return this.currentTheme;
  }

  /**
   * Obtener idioma actual
   */
  getLanguage() {
    return this.currentLanguage;
  }

  /**
   * Obtener color actual
   */
  getColor() {
    return this.currentColor;
  }
}

// Inicializar cuando el DOM esté listo
document.addEventListener('DOMContentLoaded', () => {
  window.themeManager = new ThemeManager();
});
