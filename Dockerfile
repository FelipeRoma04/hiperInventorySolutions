# ============================================================
# HiperInventory Solutions — Dockerfile (Robust Single-Pull)
# ============================================================

# We use Eclipse Temurin (official replacement for openjdk)
# Using 'focal' (Ubuntu 20.04) for maximum stability on Railway
FROM eclipse-temurin:11-jdk-focal AS builder

# Install Ant and Curl for building and downloading dependencies
RUN apt-get update && \
    apt-get install -y ant curl && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /build
COPY . .

# Build the project using Ant
RUN ant -f build.xml clean default


# --- Stage 2: Runtime Stage ---
# We use the EXACT same base image as Stage 1 to ensure standard Railway behavior
FROM eclipse-temurin:11-jdk-focal

# Tomcat Configuration
ENV TOMCAT_VERSION=9.0.117
ENV CATALINA_HOME=/opt/tomcat
ENV PATH=$CATALINA_HOME/bin:$PATH

# Install Curl and setup Tomcat
RUN apt-get update && \
    apt-get install -y curl && \
    mkdir -p $CATALINA_HOME && \
    curl -fL https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz | tar -xzC $CATALINA_HOME --strip-components=1 && \
    rm -rf $CATALINA_HOME/webapps/* && \
    rm -rf /var/lib/apt/lists/*

WORKDIR $CATALINA_HOME

# Copy the built WAR from the builder stage
COPY --from=builder /build/dist/hiperInventorySolutions.war \
     $CATALINA_HOME/webapps/hiperInventorySolutions.war

# Copy Tomcat server configuration
COPY docker/server.xml $CATALINA_HOME/conf/server.xml

# Environment variables — can be overridden at runtime
ENV DB_HOST=sqlserver \
    DB_PORT=1433 \
    DB_NAME=hiperInventorySolutions \
    DB_USER=sa \
    DB_PASSWORD=HiperApp2024! \
    JAVA_OPTS="-Xms256m -Xmx512m -Dfile.encoding=UTF-8"

EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -sf http://localhost:8080/hiperInventorySolutions/index.jsp || exit 1

CMD ["catalina.sh", "run"]
