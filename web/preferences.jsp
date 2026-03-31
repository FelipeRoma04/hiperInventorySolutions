<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es" data-theme="light">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Preferencias - HiperInventory Solutions</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
  <link href="css/styles.css" rel="stylesheet">
  <link href="css/theme-light.css" rel="stylesheet" id="theme-stylesheet">
  <style>
    .preferences-container {
      max-width: 900px;
      margin: 0 auto;
      padding: 30px 20px;
    }

    .preference-section {
      background-color: var(--bg-primary);
      border: 1px solid var(--border-light);
      border-radius: 12px;
      padding: 25px;
      margin-bottom: 25px;
      box-shadow: var(--shadow-sm);
      transition: var(--transition);
    }

    .preference-section:hover {
      box-shadow: var(--shadow-md);
      border-color: var(--color-primary);
    }

    .section-title {
      display: flex;
      align-items: center;
      gap: 12px;
      margin-bottom: 20px;
      padding-bottom: 15px;
      border-bottom: 2px solid var(--border-light);
      font-size: 1.3rem;
      font-weight: 700;
      color: var(--text-primary);
    }

    .section-title i {
      color: var(--color-primary);
      font-size: 1.5rem;
    }

    .preference-item {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 15px 0;
      border-bottom: 1px solid var(--border-light);
    }

    .preference-item:last-child {
      border-bottom: none;
    }

    .preference-label {
      display: flex;
      flex-direction: column;
      gap: 5px;
    }

    .preference-label h6 {
      margin: 0;
      font-weight: 600;
      color: var(--text-primary);
    }

    .preference-label small {
      color: var(--text-muted);
    }

    .preference-control {
      display: flex;
      gap: 10px;
      align-items: center;
    }

    .theme-toggle-btn {
      background: linear-gradient(135deg, var(--color-primary), var(--color-secondary));
      color: white;
      border: none;
      padding: 8px 16px;
      border-radius: 6px;
      cursor: pointer;
      font-weight: 600;
      transition: var(--transition);
    }

    .theme-toggle-btn:hover {
      transform: translateY(-2px);
      box-shadow: var(--shadow-md);
    }

    .language-buttons {
      display: flex;
      gap: 8px;
    }

    .lang-btn {
      padding: 8px 16px;
      border: 2px solid var(--border-color);
      background-color: var(--bg-secondary);
      color: var(--text-primary);
      border-radius: 6px;
      cursor: pointer;
      font-weight: 600;
      transition: var(--transition);
    }

    .lang-btn:hover {
      border-color: var(--color-primary);
      color: var(--color-primary);
    }

    .lang-btn.active {
      background-color: var(--color-primary);
      color: white;
      border-color: var(--color-primary);
    }

    .color-schemes-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(100px, 1fr));
      gap: 12px;
      margin: 15px 0;
    }

    .color-scheme-option {
      cursor: pointer;
      padding: 12px;
      border: 2px solid var(--border-light);
      border-radius: 8px;
      text-align: center;
      transition: var(--transition);
      background-color: var(--bg-secondary);
    }

    .color-scheme-option:hover {
      border-color: var(--color-primary);
      transform: translateY(-2px);
    }

    .color-scheme-option.active {
      border-color: var(--color-primary);
      background-color: var(--bg-tertiary);
      box-shadow: 0 0 15px rgba(91, 106, 230, 0.3);
    }

    .scheme-preview {
      display: flex;
      gap: 6px;
      justify-content: center;
      margin-bottom: 8px;
    }

    .color-dot {
      width: 24px;
      height: 24px;
      border-radius: 50%;
      border: 2px solid rgba(255, 255, 255, 0.3);
    }

    .color-scheme-option small {
      display: block;
      color: var(--text-muted);
      margin-top: 5px;
    }

    .custom-colors-section {
      background-color: var(--bg-tertiary);
      padding: 15px;
      border-radius: 8px;
      margin-top: 15px;
    }

    .color-input-group {
      margin-bottom: 12px;
    }

    .color-input-group:last-child {
      margin-bottom: 0;
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
      background-color: var(--bg-secondary);
    }

    .form-control-color:hover {
      border-color: var(--color-primary);
    }

    .toggle-switch {
      display: flex;
      align-items: center;
      gap: 10px;
    }

    .switch {
      position: relative;
      display: inline-block;
      width: 50px;
      height: 24px;
    }

    .switch input {
      opacity: 0;
      width: 0;
      height: 0;
    }

    .slider {
      position: absolute;
      cursor: pointer;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background-color: var(--border-color);
      transition: var(--transition);
      border-radius: 24px;
    }

    .slider:before {
      position: absolute;
      content: "";
      height: 18px;
      width: 18px;
      left: 3px;
      bottom: 3px;
      background-color: white;
      transition: var(--transition);
      border-radius: 50%;
    }

    input:checked + .slider {
      background-color: var(--color-primary);
    }

    input:checked + .slider:before {
      transform: translateX(26px);
    }

    .preference-description {
      padding: 12px;
      background-color: var(--bg-secondary);
      border-left: 4px solid var(--color-primary);
      border-radius: 4px;
      margin-top: 10px;
    }

    .preference-description p {
      margin: 0;
      color: var(--text-secondary);
      font-size: 0.9rem;
    }

    .header {
      text-align: center;
      margin-bottom: 40px;
      padding-bottom: 20px;
      border-bottom: 2px solid var(--border-light);
    }

    .header h1 {
      color: var(--color-primary);
      font-weight: 700;
      margin-bottom: 10px;
    }

    .header p {
      color: var(--text-secondary);
      font-size: 1.1rem;
    }

    .save-button {
      position: fixed;
      bottom: 30px;
      right: 30px;
      padding: 12px 24px;
      background: linear-gradient(135deg, var(--color-primary), var(--color-secondary));
      color: white;
      border: none;
      border-radius: 50px;
      cursor: pointer;
      font-weight: 700;
      font-size: 1rem;
      box-shadow: var(--shadow-lg);
      transition: var(--transition);
      display: none;
    }

    .save-button.show {
      display: block;
    }

    .save-button:hover {
      transform: translateY(-3px);
      box-shadow: var(--shadow-xl);
    }

    .success-message {
      position: fixed;
      top: 80px;
      right: 20px;
      background-color: #10B981;
      color: white;
      padding: 15px 25px;
      border-radius: 8px;
      box-shadow: var(--shadow-lg);
      animation: slideIn 0.3s ease;
      z-index: 1000;
    }

    @keyframes slideIn {
      from {
        transform: translateX(400px);
        opacity: 0;
      }
      to {
        transform: translateX(0);
        opacity: 1;
      }
    }

    @media (max-width: 768px) {
      .preferences-container {
        padding: 15px;
      }

      .preference-item {
        flex-direction: column;
        align-items: flex-start;
        gap: 10px;
      }

      .language-buttons {
        flex-wrap: wrap;
      }

      .save-button {
        bottom: 20px;
        right: 20px;
        padding: 10px 16px;
        font-size: 0.9rem;
      }
    }
  </style>
</head>
<body data-theme="light">
  <div class="d-flex">
    <!-- Sidebar -->
    <div class="sidebar">
      <div class="sidebar-header">
        <h5 class="mb-0"><i class="fas fa-cog"></i> Preferencias</h5>
      </div>
      <nav class="sidebar-nav mt-4">
        <a href="javascript:scrollToSection('theme')" class="sidebar-link active">
          <i class="fas fa-palette"></i> Tema
        </a>
        <a href="javascript:scrollToSection('language')" class="sidebar-link">
          <i class="fas fa-globe"></i> Idioma
        </a>
        <a href="javascript:scrollToSection('colors')" class="sidebar-link">
          <i class="fas fa-swatchbook"></i> Colores
        </a>
        <a href="javascript:scrollToSection('notifications')" class="sidebar-link">
          <i class="fas fa-bell"></i> Notificaciones
        </a>
        <a href="javascript:scrollToSection('privacy')" class="sidebar-link">
          <i class="fas fa-lock"></i> Privacidad
        </a>
        <hr class="my-3">
        <a href="inicio.jsp" class="sidebar-link">
          <i class="fas fa-arrow-left"></i> Volver al Dashboard
        </a>
      </nav>
    </div>

    <!-- Main Content -->
    <main class="main-content flex-grow-1">
      <div class="topbar">
        <div class="topbar-left">
          <button class="toggle-sidebar" id="toggle-sidebar">
            <i class="fas fa-bars"></i>
          </button>
          <span class="app-title">Preferencias de Usuario</span>
        </div>
        <div class="topbar-right">
          <button class="btn btn-light" id="theme-toggle-btn" title="Cambiar tema">
            <i class="fas fa-moon"></i>
          </button>
        </div>
      </div>

      <div class="preferences-container">
        <div class="header">
          <h1><i class="fas fa-sliders-h"></i> Preferencias de Usuario</h1>
          <p>Personaliza tu experiencia en HiperInventory Solutions</p>
        </div>

        <!-- TEMA SECTION -->
        <div class="preference-section" id="theme">
          <div class="section-title">
            <i class="fas fa-palette"></i>
            Tema de Interfaz
          </div>
          
          <div class="preference-item">
            <div class="preference-label">
              <h6 data-i18n="theme.light">Tema Claro</h6>
              <small data-i18n="preferences.light_description">Diseño claro y luminoso ideal para ambientes bien iluminados</small>
            </div>
            <div class="preference-control">
              <button class="theme-btn" onclick="switchTheme('light')">
                <i class="fas fa-sun"></i> Claro
              </button>
            </div>
          </div>

          <div class="preference-item">
            <div class="preference-label">
              <h6 data-i18n="theme.dark">Tema Oscuro</h6>
              <small data-i18n="preferences.dark_description">Diseño oscuro más cómodo para los ojos (recomendado para la noche)</small>
            </div>
            <div class="preference-control">
              <button class="theme-btn" onclick="switchTheme('dark')">
                <i class="fas fa-moon"></i> Oscuro
              </button>
            </div>
          </div>

          <div class="preference-description">
            <p><strong>Nota:</strong> El tema se cambiará inmediatamente y se guardará en tu navegador.</p>
          </div>
        </div>

        <!-- IDIOMA SECTION -->
        <div class="preference-section" id="language">
          <div class="section-title">
            <i class="fas fa-globe"></i>
            Idioma
          </div>
          
          <div class="preference-item">
            <div class="preference-label">
              <h6>Selecciona tu idioma preferido</h6>
              <small>La interfaz se actualizará en tiempo real</small>
            </div>
            <div class="language-buttons">
              <button class="lang-btn active" data-lang-select="es" onclick="changeLanguage('es')">
                <i class="fas fa-es"></i> Español
              </button>
              <button class="lang-btn" data-lang-select="en" onclick="changeLanguage('en')">
                <i class="fas fa-gb"></i> English
              </button>
              <button class="lang-btn" data-lang-select="pt" onclick="changeLanguage('pt')">
                <i class="fas fa-pt"></i> Português
              </button>
            </div>
          </div>

          <div class="preference-description">
            <p><i class="fas fa-info-circle"></i> Se soportan inglés, español y portugués.</p>
          </div>
        </div>

        <!-- COLORES SECTION -->
        <div class="preference-section" id="colors">
          <div class="section-title">
            <i class="fas fa-swatchbook"></i>
            Esquema de Colores
          </div>
          
          <p class="text-muted">Elige entre esquemas predefinidos o personaliza los colores a tu gusto:</p>
          
          <div class="color-schemes-grid">
            <div class="color-scheme-option active" data-color="purple">
              <div class="scheme-preview">
                <div class="color-dot" style="background-color: #5B6AE6;"></div>
                <div class="color-dot" style="background-color: #6C63FF;"></div>
                <div class="color-dot" style="background-color: #FF6BAE;"></div>
              </div>
              <small>Púrpura</small>
            </div>
            <div class="color-scheme-option" data-color="blue">
              <div class="scheme-preview">
                <div class="color-dot" style="background-color: #0066FF;"></div>
                <div class="color-dot" style="background-color: #0040FF;"></div>
                <div class="color-dot" style="background-color: #FF6B6B;"></div>
              </div>
              <small>Azul</small>
            </div>
            <div class="color-scheme-option" data-color="green">
              <div class="scheme-preview">
                <div class="color-dot" style="background-color: #10B981;"></div>
                <div class="color-dot" style="background-color: #059669;"></div>
                <div class="color-dot" style="background-color: #F59E0B;"></div>
              </div>
              <small>Verde</small>
            </div>
            <div class="color-scheme-option" data-color="pink">
              <div class="scheme-preview">
                <div class="color-dot" style="background-color: #EC4899;"></div>
                <div class="color-dot" style="background-color: #DB2777;"></div>
                <div class="color-dot" style="background-color: #7C3AED;"></div>
              </div>
              <small>Rosa</small>
            </div>
            <div class="color-scheme-option" data-color="orange">
              <div class="scheme-preview">
                <div class="color-dot" style="background-color: #F97316;"></div>
                <div class="color-dot" style="background-color: #EA580C;"></div>
                <div class="color-dot" style="background-color: #3B82F6;"></div>
              </div>
              <small>Naranja</small>
            </div>
            <div class="color-scheme-option" data-color="indigo">
              <div class="scheme-preview">
                <div class="color-dot" style="background-color: #4F46E5;"></div>
                <div class="color-dot" style="background-color: #4338CA;"></div>
                <div class="color-dot" style="background-color: #E0E7FF;"></div>
              </div>
              <small>Índigo</small>
            </div>
          </div>

          <h6 class="mt-4 mb-3">Colores Personalizados</h6>
          <div class="custom-colors-section">
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
            <button class="btn btn-primary btn-sm mt-3" onclick="applyCustomColors()">
              <i class="fas fa-check"></i> Aplicar Colores Personalizados
            </button>
          </div>
        </div>

        <!-- NOTIFICACIONES SECTION -->
        <div class="preference-section" id="notifications">
          <div class="section-title">
            <i class="fas fa-bell"></i>
            Notificaciones
          </div>
          
          <div class="preference-item">
            <div class="preference-label">
              <h6>Alertas de Stock Bajo</h6>
              <small>Recibe notificaciones cuando el stock esté bajo</small>
            </div>
            <div class="preference-control">
              <label class="switch">
                <input type="checkbox" checked>
                <span class="slider"></span>
              </label>
            </div>
          </div>

          <div class="preference-item">
            <div class="preference-label">
              <h6>Recordatorios de Mantenimiento</h6>
              <small>Notificaciones de mantenimiento programado</small>
            </div>
            <div class="preference-control">
              <label class="switch">
                <input type="checkbox" checked>
                <span class="slider"></span>
              </label>
            </div>
          </div>

          <div class="preference-item">
            <div class="preference-label">
              <h6>Notificaciones de Email</h6>
              <small>Recibe resúmenes por correo electrónico</small>
            </div>
            <div class="preference-control">
              <label class="switch">
                <input type="checkbox">
                <span class="slider"></span>
              </label>
            </div>
          </div>
        </div>

        <!-- PRIVACIDAD SECTION -->
        <div class="preference-section" id="privacy">
          <div class="section-title">
            <i class="fas fa-lock"></i>
            Privacidad y Seguridad
          </div>
          
          <div class="preference-item">
            <div class="preference-label">
              <h6>Recordar mi sesión</h6>
              <small>Mantener sesión iniciada en este navegador</small>
            </div>
            <div class="preference-control">
              <label class="switch">
                <input type="checkbox" checked>
                <span class="slider"></span>
              </label>
            </div>
          </div>

          <div class="preference-item">
            <div class="preference-label">
              <h6>Autenticación de Dos Factores (2FA)</h6>
              <small>Mayor seguridad para tu cuenta</small>
            </div>
            <div class="preference-control">
              <a href="2fa-setup.jsp" class="btn btn-sm btn-outline-primary">
                <i class="fas fa-shield-alt"></i> Configurar 2FA
              </a>
            </div>
          </div>

          <div class="preference-item">
            <div class="preference-label">
              <h6>Historial de Acceso</h6>
              <small>Ver últimos accesos a tu cuenta</small>
            </div>
            <div class="preference-control">
              <a href="javascript:void(0)" class="btn btn-sm btn-outline-secondary">
                <i class="fas fa-history"></i> Ver Historial
              </a>
            </div>
          </div>
        </div>

      </div>

      <button class="save-button" id="save-btn" onclick="savePreferences()">
        <i class="fas fa-save"></i> Guardar Cambios
      </button>
    </main>
  </div>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
  <script src="js/theme-manager.js"></script>
  <script src="js/color-customizer.js"></script>

  <script>
    function switchTheme(theme) {
      if (window.themeManager) {
        window.themeManager.applyTheme(theme);
        window.themeManager.updateThemeButton();
      }
    }

    function changeLanguage(lang) {
      if (window.themeManager) {
        window.themeManager.changeLanguage(lang);
      }
    }

    function applyCustomColors() {
      const primary = document.getElementById('primary-color').value;
      const secondary = document.getElementById('secondary-color').value;
      const accent = document.getElementById('accent-color').value;
      
      if (window.themeManager) {
        window.themeManager.applyColorScheme(primary);
      }
      
      const root = document.documentElement;
      root.style.setProperty('--color-primary', primary);
      root.style.setProperty('--color-secondary', secondary);
      root.style.setProperty('--color-accent', accent);
      
      localStorage.setItem('color-custom-preference', JSON.stringify({
        primary, secondary, accent
      }));
      
      showSuccessMessage('Colores aplicados correctamente');
    }

    function scrollToSection(id) {
      const element = document.getElementById(id);
      if (element) {
        element.scrollIntoView({ behavior: 'smooth' });
      }
    }

    function savePreferences() {
      showSuccessMessage('Preferencias guardadas correctamente');
    }

    function showSuccessMessage(msg) {
      const msg_el = document.createElement('div');
      msg_el.className = 'success-message';
      msg_el.innerHTML = `<i class="fas fa-check-circle"></i> ${msg}`;
      document.body.appendChild(msg_el);
      
      setTimeout(() => {
        msg_el.remove();
      }, 3000);
    }

    // Agregar event listeners a los esquemas de color
    document.querySelectorAll('.color-scheme-option').forEach(option => {
      option.addEventListener('click', function() {
        const color = this.getAttribute('data-color');
        document.querySelectorAll('.color-scheme-option').forEach(o => o.classList.remove('active'));
        this.classList.add('active');
        
        if (window.themeManager) {
          window.themeManager.applyColorScheme(color);
        }
      });
    });

    // Agregar event listeners a los botones de idioma
    document.querySelectorAll('.lang-btn').forEach(btn => {
      btn.addEventListener('click', function() {
        document.querySelectorAll('.lang-btn').forEach(b => b.classList.remove('active'));
        this.classList.add('active');
      });
    });

    document.addEventListener('DOMContentLoaded', function() {
      // Mostrar botón de guardar solo si hay cambios
      const inputs = document.querySelectorAll('input, select, .color-scheme-option, .lang-btn, .theme-btn');
      const saveBtn = document.getElementById('save-btn');
      
      inputs.forEach(input => {
        input.addEventListener('change', () => {
          saveBtn.classList.add('show');
        });
      });
    });
  </script>
</body>
</html>
