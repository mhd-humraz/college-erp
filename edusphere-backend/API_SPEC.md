# EduSphere ERP - Core Engine REST Interface System Specifications v1.0.0
Base Server Endpoint Coordinates: `http://localhost:5000/api/v1`

## [Module Layer 1: Authentication Engine Gateway]

### 1. POST /auth/register
* **Access Context Security Clearance:** Administrative Authority (`Admin` Role Only)
* **Request Body JSON Application:**
    ```json
    {
      "email": "faculty.smith@edusphere.edu",
      "password": "TemporarySecurePassword123",
      "role": "Teacher"
    }
    ```
* **Response Blueprint Parameters:**
    * `201 Created`:
        ```json
        {
          "success": true,
          "message": "Identity registered successfully",
          "userId": "665a1b2c3d4e5f6a7b8c9d01"
        }
        ```
    * `400 Bad Request`: `{ "error": "Identity coordinate email signature already exists" }`

### 2. POST /auth/login
* **Access Context Security Clearance:** Unauthenticated Public Gateway Node
* **Request Body JSON Application:**
    ```json
    {
      "email": "student.doe@edusphere.edu",
      "password": "MySuperSecretPassword"
    }
    ```
* **Response Blueprint Parameters:**
    * `200 OK`:
        ```json
        {
          "accessToken": "eyJhbGciOiJIUzI1NiIsIn...",
          "refreshToken": "eyJhbGciOiJIUzI1NiIsIn...",
          "role": "Student",
          "userId": "665a1b2c3d4e5f6a7b8c9d02"
        }
        ```
    * `401 Unauthorized`: `{ "error": "Invalid identity verification credentials" }`

### 3. POST /auth/refresh-token
* **Request Body JSON Application:** `{ "token": "eyJhbGciOiJIUzI1NiIsIn..." }`
* **Response Blueprint Parameters:**
    * `200 OK`: `{ "accessToken": "new_access_token_string", "refreshToken": "new_rotated_refresh_token_string" }`
    * `403 Forbidden`: `{ "error": "Session token synchronization broken or lifecycle expired" }`

---

## [Module Layer 2: Academic Core Operations Pipeline]

### 1. POST /academic/attendance/submit
* **Access Context Security Clearance:** Checked Role Authorization: `['Teacher', 'HOD']`
* **Request Body JSON Application:**
    ```json
    {
      "subjectId": "665a1b2c3d4e5f6a7b8c9d05",
      "facultyId": "665a1b2c3d4e5f6a7b8c9d06",
      "date": "2026-06-01T00:00:00.000Z",
      "hour": 2,
      "records": [
        { "studentId": "665a1b2c3d4e5f6a7b8c9d10", "isPresent": true },
        { "studentId": "665a1b2c3d4e5f6a7b8c9d11", "isPresent": false }
      ]
    }
    ```
* **Response Blueprint Parameters:**
    * `201 Created`: `{ "success": true, "message": "Attendance logging block locked in database." }`

### 2. GET /academic/attendance/student/:id
* **Access Context Security Clearance:** Dynamic Checking Match: `Student` checking self ID, or `Teacher`/`Admin` roles
* **Response Blueprint Parameters:**
    * `200 OK`:
        ```json
        {
          "success": true,
          "metrics": {
            "totalSessions": 40,
            "presentSessions": 36,
            "attendancePercentage": 90.00
          }
        }
        ```

---

## [Module Layer 3: Incident Ticket Grievance Matrix]

### 1. POST /tickets/raise
* **Access Context Security Clearance:** Checked Role Authorization: `['Student', 'Teacher']`
* **Request Body JSON Application:**
    ```json
    {
      "title": "Lab 04 Server Connectivity Failure",
      "category": "Infrastructure",
      "description": "The main database proxy cluster in Lab 4 is refusing incoming secure socket terminal hits since morning."
    }
    ```
* **Response Blueprint Parameters:**
    * `201 Created`: `{ "success": true, "ticketId": "665a1b2c3d4e5f6a7b8c9d99", "status": "Open" }`

### 2. PATCH /tickets/update/:ticketId
* **Access Context Security Clearance:** Checked Role Authorization: `['Admin', 'HOD']`
* **Request Body JSON Application:**
    ```json
    {
      "status": "In Progress",
      "commentMessage": "System operations team dispatched hardware line analyzer units to investigate switches."
    }
    ```
* **Response Blueprint Parameters:**
    * `200 OK`: `{ "success": true, "updatedStatus": "In Progress" }`