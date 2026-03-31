@echo off
REM Script para descargar y configurar las librerías necesarias
REM Crea la carpeta de librerías si no existe
if not exist "web\WEB-INF\lib" mkdir "web\WEB-INF\lib"

echo Descargando SQLite JDBC Driver...
powershell -Command "try { Invoke-WebRequest -Uri 'https://github.com/xerial/sqlite-jdbc/releases/download/3.44.0.0/sqlite-jdbc-3.44.0.0.jar' -OutFile 'web\WEB-INF\lib\sqlite-jdbc.jar' } catch { Write-Host 'Error descargando: $_' }"

echo.
echo Librerías descargadas en web\WEB-INF\lib\
echo Contenido:
dir web\WEB-INF\lib\
echo.
echo Listo para compilar con Ant
pause
