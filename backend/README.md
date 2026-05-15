# MESCAS ERP Backend

## Setup Steps

### 1. Install Node.js
Download from https://nodejs.org (LTS version)

### 2. Install MongoDB
Download from https://www.mongodb.com/try/download/community
- Install and start MongoDB service

### 3. Setup the backend
```bash
# go into backend folder
cd backend

# install dependencies
npm install

# start the server
npm run dev
```

### 4. Default Admin Account
- Email: admin@mescas.com
- Password: admin123

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /api/auth/login | Login |
| POST | /api/auth/change-password | Change password |
| GET | /api/users | Get all users |
| POST | /api/users | Create user |
| PUT | /api/users/:id | Update user |
| DELETE | /api/users/:id | Delete user |
| GET | /api/courses | Get all courses |
| POST | /api/courses | Add course |
| PUT | /api/courses/:id | Update course |
| DELETE | /api/courses/:id | Delete course |
| GET | /api/departments | Get all departments |
| POST | /api/departments | Add department |
| PUT | /api/departments/:id | Update department |
| DELETE | /api/departments/:id | Delete department |
| GET | /api/notifications | Get notifications |
| POST | /api/notifications | Send notification |
| DELETE | /api/notifications/:id | Delete notification |
| GET | /api/timetable | Get timetable |
| POST | /api/timetable | Add slot |
| DELETE | /api/timetable/:id | Delete slot |
| GET | /api/reports/summary | Get stats |
| GET | /api/settings | Get settings |
| PUT | /api/settings | Update settings |
