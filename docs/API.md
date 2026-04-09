# API Documentation — HiperInventory Solutions

HiperInventory provides a REST-like API for integrating with external systems. All requests must be authenticated using an API Key.

## 🔑 Authentication

Include your API Key in the request header or as a query parameter:

*   **Header**: `X-API-Key: your_api_key_here`
*   **Query**: `?apiKey=your_api_key_here`

You can manage API keys in the **Settings** section of the administrative dashboard.

---

## 📦 Assets Endpoints

### 1. List Assets
Returns a list of all active assets in the system.

*   **URL**: `/api/external/assets`
*   **Method**: `GET`
*   **Response (JSON)**:
    ```json
    [
      {
        "id": 1,
        "name": "Laptop Dell XPS",
        "category": "Computers",
        "status": "Available",
        "location": "Main Office"
      },
      ...
    ]
    ```

### 2. Get Asset Details
Fetch detailed information about a specific asset.

*   **URL**: `/api/external/assets/{id}`
*   **Method**: `GET`
*   **Success Response**: `200 OK`
*   **Error Response**: `404 Not Found` (if asset doesn't exist)

---

## 📈 Performance Endpoints

### 1. System Health
Returns the current health status and load of the application server.

*   **URL**: `/api/external/status`
*   **Method**: `GET`
*   **Response**:
    ```json
    {
      "status": "healthy",
      "uptime": "12:34:56",
      "dbConnection": "active"
    }
    ```

---

## 🚩 Error Handling

The API uses standard HTTP status codes:

| Code | Description |
| :--- | :--- |
| `200` | Request successful. |
| `201` | Resource created. |
| `401` | Unauthorized (Invalid or missing API Key). |
| `404` | Resource not found. |
| `500` | Internal Server Error. |

> [!TIP]
> Always use HTTPS in production to protect your API Keys during transmission.
