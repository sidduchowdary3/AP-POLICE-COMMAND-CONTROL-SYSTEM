<div align="center">
  <img src="frontend/assets/ap_police_logo.png" alt="AP Police Logo" width="150"/>
  <h1>Andhra Pradesh Police Command Control System</h1>
  <p><strong>A Next-Generation, Real-Time Police Dispatch & Patrol Management System</strong></p>
  
  [![Flutter](https://img.shields.io/badge/Frontend-Flutter-02569B?logo=flutter&style=for-the-badge)](https://flutter.dev/)
  [![NestJS](https://img.shields.io/badge/Backend-NestJS-E0234E?logo=nestjs&style=for-the-badge)](https://nestjs.com/)
  [![Prisma](https://img.shields.io/badge/ORM-Prisma-2D3748?logo=prisma&style=for-the-badge)](https://www.prisma.io/)
  [![Socket.io](https://img.shields.io/badge/Real--Time-Socket.io-010101?logo=socket.io&style=for-the-badge)](https://socket.io/)
</div>

<br/>

## 🚨 Overview
The **AP Police Command Control System** is a modern, full-stack platform designed exclusively for the Andhra Pradesh Police force. Built for high performance, the system enables hierarchical command management, real-time GPS tracking of active patrol units, and instant emergency backup signaling.

### ✨ Key Features
- **Hierarchical RBAC**: Strict Role-Based Access Control enforcing Super Admin, Command Officer, and Personnel boundaries.
- **Real-Time GIS Tracking**: Live tracking of police vehicles across Andhra Pradesh using CartoDB Dark Matter mapping and Websockets.
- **Instant Emergency Alerts**: Immediate cross-platform broadcast of "Officer Needs Backup" signals and high-risk incidents.
- **Cross-Platform Mobile App**: Dedicated mobile tracking interface for field officers built with Flutter.
- **Secure Authentication**: Encrypted JWT sessions and secure credential hashing via `bcrypt`.

---

## 🎥 System Walkthrough

*(The automated recording failed due to Canvas rendering. Please manually record and place your video here!)*

---

## 🛡️ Role-Based Access Control (RBAC)

The system automatically limits data visibility and actions based on user clearance.

| Role | Access Level | Description |
|---|---|---|
| 🔴 **Super Admin** | State-Level Control | Can create/manage all Police Stations across AP and assign high-ranking Command Officers. |
| 🔵 **Command Officer** | Station-Level Control | Manages a specific district station. Can view the live map of their officers and dispatch backup. |
| 🟢 **Police Personnel** | Field Operations | Uses the mobile application to stream live GPS coordinates and request emergency backup. |

---

## 🚀 Getting Started

Follow these steps to deploy and run the system locally. 

### Prerequisites
- [Node.js](https://nodejs.org/en/) (v18+)
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.19+)
- SQLite (pre-configured)

### 1️⃣ Backend Setup (NestJS)

```bash
cd backend
npm install

# Initialize the database & schema
npx prisma db push

# Seed the database with default AP Police credentials
npx ts-node src/seed.ts

# Start the API & Websocket Server
npm run start:dev
```

### 2️⃣ Frontend Setup (Flutter)

Open a **new terminal tab**:

```bash
cd frontend
flutter pub get

# Run the app in Google Chrome
flutter run -d chrome
```

---

## 🔐 Default Sandbox Credentials

After running the seed script, you can test the system using these exact credentials. 
*(Ensure you select the matching **Role Card** on the login screen or access will be denied).*

| Role | Badge ID / Email | Clearance Code |
|---|---|---|
| **Super Admin** | `superadmin@ap.gov.in` | `Admin@123` |
| **Command Officer** | `commander@ap.gov.in` | `Command@123` |
| **Police Personnel** | `officer@ap.gov.in` | `Police@123` |

---

## 🏗️ Architecture & Simulation Engine

Currently, the backend includes an automated **Websocket Simulation Engine** (`locations.gateway.ts`). Since real police vehicles are not connected to this test repository, the simulator spawns AI patrol units in major AP cities (Visakhapatnam, Vijayawada, Tirupati, etc.) and randomly generates AP-specific emergency scenarios (e.g., Sand Mafia Activity, Liquor Violations) to demonstrate system capabilities.

<br/>

<div align="center">
  <p><em>Built for the safety, security, and service of Andhra Pradesh.</em></p>
</div>
