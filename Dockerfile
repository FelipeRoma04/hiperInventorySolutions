# ============================================================
# HiperInventory Solutions — Dockerfile (Multi-stage)
# ============================================================

# --- Stage 1: Build Stage ---
FROM openjdk:11-jdk-slim AS builder

# Install Ant
RUN apt-get update && \
    apt-get install -y ant && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Copy source code and libraries
COPY . .

# Build the project using Ant
# Note: We use the 'default' target which typically builds the WAR in NetBeans projects
RUN ant -f build.xml clean default

# --- Stage 2: Runtime Stage ---
FROM tomcat:9.0-jdk11-temurin

LABEL maintainer="HiperInventory Solutions"
LABEL description="Sistema de Gestión de Inventario - Tomcat 9 + JDK 11"

# Remove default Tomcat apps to keep it clean
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy the built WAR from the builder stage
# The path dist/hiperInventorySolutions.war is standard for NetBeans builds
COPY --from=builder /build/dist/hiperInventorySolutions.war \
     /usr/local/tomcat/webapps/hiperInventorySolutions.war

# Copy Tomcat server configuration
COPY docker/server.xml /usr/local/tomcat/conf/server.xml

# Environment variables — can be overridden at runtime
ENV DB_HOST=sqlserver \
    DB_PORT=1433 \
    DB_NAME=hiperInventorySolutions \
    DB_USER=sa \
    DB_PASSWORD=HiperApp2024! \
    JAVA_OPTS="-Xms256m -Xmx512m -Dfile.encoding=UTF-8"

EXPOSE 8080

# Health check — ensures the app is actually responding
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -sf http://localhost:8080/hiperInventorySolutions/index.jsp || exit 1

CMD ["catalina.sh", "run"]
