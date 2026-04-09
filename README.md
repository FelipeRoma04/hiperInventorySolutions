# HiperInventory Solutions 📦

A professional, containerized Asset and Inventory Management System built with Java, Tomcat, and SQL Server. Designed for stability, scalability, and ease of deployment.

[![Deployment Status](https://img.shields.io/badge/Deployment-Railway-blueviolet)](https://hiperinventorysolutions-production.up.railway.app/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## 🚀 Key Features

*   **Asset Lifecycle Management**: Track assets from acquisition to depreciation.
*   **Maintenance Tracking**: Log and schedule maintenance tasks for critical assets.
*   **User Authentication**: Robust security with Role-Based Access Control (RBAC) and OTP support.
*   **Audit Logging**: Every action is recorded for transparency and compliance.
*   **External API**: Integrate with third-party systems via a secure API Key mechanism.
*   **Data Import/Export**: Batch import assets and generate reports in various formats.
*   **Mobile-Friendly UI**: Modern JSP-based interface designed for accessibility.

## 🛠 Tech Stack

*   **Backend**: Java 11 (Eclipse Temurin), Apache Tomcat 9
*   **Frontend**: JSP, HTML5, Vanilla CSS
*   **Database**: Microsoft SQL Server
*   **Build System**: Ant (with custom `build-docker.xml` for portability)
*   **Containerization**: Docker (multi-stage build)
*   **Deployment**: Railway.app

## 🐳 Quick Start (Docker)

To run the application locally using Docker:

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/FelipeRoma04/hiperInventorySolutions.git
    cd hiperInventorySolutions
    ```

2.  **Configure environment variables**:
    Create a `.env` file based on `.env.example`:
    ```bash
    cp .env.example .env
    ```

3.  **Start with Docker Compose**:
    ```bash
    docker-compose up -d
    ```

4.  **Access the app**:
    Open [http://localhost:8080](http://localhost:8080) in your browser.

## 📁 Project Structure

*   `src/java`: Java source code (Servlets, DAOs, Models).
*   `web`: Web content (JSP, CSS, JS, WEB-INF).
*   `sql`: Database initialization and schema scripts.
*   `docker`: Configuration files for Tomcat and SQL Server.
*   `docs`: Detailed technical documentation.

## 📖 Documentation

*   [Architecture Guide](./docs/ARCHITECTURE.md)
*   [Deployment Guide](./docs/DEPLOYMENT.md)
*   [API Reference](./docs/API.md)

---
Developed by **HiperInventory Solutions Team**.
