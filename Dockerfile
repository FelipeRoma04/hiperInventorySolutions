# ============================================================
# HiperInventory Solutions — Dockerfile (Robust Single-Pull)
# ============================================================

# --- Stage 1: Build Stage ---
FROM eclipse-temurin:11-jdk-focal AS builder

# Install Ant and Curl
RUN apt-get update && \
    apt-get install -y ant curl && \
    rm -rf /var/lib/apt/lists/*

# Setup Build Environment
WORKDIR /build

# 1. Download Tomcat (needed for J2EE classpaths)
ENV TOMCAT_VERSION=9.0.117
RUN curl -fL https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz | tar -xzC /opt && \
    mv /opt/apache-tomcat-${TOMCAT_VERSION} /opt/tomcat

# 2. Download NetBeans CopyLibs Task (essential for Ant headless builds)
# We use a stable version from the official NetBeans repository/mirrors
RUN mkdir -p /libs && \
    curl -fL -o /libs/copylibs.jar https://repo.maven.apache.org/maven2/org/netbeans/external/org-netbeans-modules-java-j2seproject-copylibstask/RELEASE120/org-netbeans-modules-java-j2seproject-copylibstask-RELEASE120.jar

# 3. Copy source code
COPY . .

# 4. Build the project using Ant with required Headless properties
RUN ant -f build.xml clean default \
    -Dj2ee.server.home=/opt/tomcat \
    -Dlibs.CopyLibs.classpath=/libs/copylibs.jar


# --- Stage 2: Runtime Stage ---
FROM eclipse-temurin:11-jdk-focal

# Tomcat Configuration
ENV TOMCAT_VERSION=9.0.117
ENV CATALINA_HOME=/opt/tomcat
ENV PATH=$CATALINA_HOME/bin:$PATH

# Setup Tomcat in the runtime container
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

# Environment variables
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
