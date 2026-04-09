# Deployment Guide — HiperInventory Solutions

This guide provides instructions for deploying HiperInventory Solutions to various environments.

## ☁️ Deployment to Railway.app (Recommended)

Railway is our preferred cloud platform because it supports Docker-native deployments.

1.  **Connect GitHub**: In Railway, create a new project and select your repository.
2.  **Add a Database**:
    *   Click `+ New` -> `Database` -> `SQL Server`.
    *   Note the connection details (Host, Port, User, Password).
3.  **Configure Variables**:
    Go to the **Variables** tab of your `hiperInventorySolutions` service and add the following:
    *   `DB_HOST`: The host of your SQL Server service.
    *   `DB_PORT`: `1433` (default for SQL Server).
    *   `DB_NAME`: `hiperInventorySolutions`.
    *   `DB_USER`: The username for your SQL Server.
    *   `DB_PASSWORD`: The password for your SQL Server.
4.  **Networking**:
    In the **Settings** tab, make sure the Public Networking port is set to `8080`.
5.  **Domain**:
    Railway will generate a domain like `hiperinventorysolutions-production.up.railway.app`.

---

## 💻 Local Deployment (Docker Compose)

For development or internal staging, Docker Compose is the easiest way to get everything running.

1.  **Install Prerequisites**: Ensure you have [Docker](https://www.docker.com/) and [Docker Compose](https://docs.docker.com/compose/) installed.
2.  **Environment Setup**:
    Copy `.env.example` to `.env` and adjust the credentials if necessary.
3.  **Start Services**:
    ```bash
    docker-compose up -d
    ```
    This will start two containers:
    *   `app`: The Tomcat application server (Port 8080).
    *   `sqlserver`: Microsoft SQL Server 2022 (Port 1433).
4.  **Logs**:
    To monitor the startup process, run:
    ```bash
    docker-compose logs -f app
    ```

---

## 🔧 Environment Variables Reference

| Variable | Description | Default / Example |
| :--- | :--- | :--- |
| `DB_HOST` | Database server hostname | `localhost` or `sqlserver` |
| `DB_PORT` | Database server port | `1433` |
| `DB_NAME` | Database name | `hiperInventorySolutions` |
| `DB_USER` | Database username | `sa` |
| `DB_PASSWORD` | Database password | (Set a strong password) |
| `JAVA_OPTS` | JVM Tuning parameters | `-Xmx512m` |

---

## 🛠 Manual Deployment (Standard Tomcat)

If you are not using Docker, you can still deploy the app manually:

1.  Build the WAR using our Ant script:
    ```bash
    ant -f build-docker.xml dist -Dj2ee.server.home=/path/to/local/tomcat
    ```
2.  Copy `dist/ROOT.war` to your Tomcat's `webapps/` directory.
3.  Configure your database connection in `context.xml` or via environment variables before starting Tomcat.
