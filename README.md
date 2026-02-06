# FarmDirect: Production-Grade Agriculture Marketplace

Welcome to **FarmDirect**, a comprehensive ecosystem connecting Farmers, Retailers, and Delivery Partners. This project is a fully functional, production-ready system.

## 📂 Project Modules

| Module | Path | Description | Tech Stack |
| :--- | :--- | :--- | :--- |
| **Backend** | `/backend` | Core API, Auth, Database, Storage | Node.js, Express, PostgreSQL/SQLite, Supabase |
| **Mobile App** | `/mobile` | Unified App for Farmers, Retailers, Delivery | Flutter (Android/iOS) |
| **Admin Panel** | `/frontend-admin` | System Monitoring & User Management | React, Vite, TailwindCSS |

---

## 🚀 Quick Start Guide

### 1. Backend (The Brain)

The backend handles all data, authentication, and logic. It uses a **Hybrid Database** (SQLite for local dev, Supabase PostgreSQL for production) and **Supabase Storage** for images.

```bash
cd backend
npm install
npm start
```

* Server runs on `http://localhost:5000`.
* Swagger implementation is not included, but API routes are in `/backend/routes`.

### 2. Mobile App (The Hands)

Connects to the backend to perform real-world actions.

* **Farmer**: List crops, upload photos, manage orders.
* **Retailer**: Browse marketplace, buy crops, track delivery.
* **Delivery**: Accept pickup jobs, deliver orders.

```bash
cd mobile
flutter pub get
flutter run
```

* **Build Release APK**: `flutter build apk --release` (Output: `build/app/outputs/flutter-apk/app-release.apk`)

### 3. Admin Panel (The Eyes)

Monitor system health, revenue, and user base.

```bash
cd frontend-admin
npm install
npm run dev
```

* Open `http://localhost:5173`.

---

## 🔑 Key Features

* **Real Image Uploads**: Products images are uploaded to the Cloud (Supabase).
* **Secure Auth**: JWT-based authentication with OTP verification.
* **Role-Based Access**: Strict separation of Farmer, Retailer, and Delivery logic.
* **Production Grade**:
  * **Validation**: Joi middleware sanitizes all inputs.
  * **Logging**: HTTP request logging with Morgan.
  * **Error Handling**: Centralized error management.
  * **Integration Tests**: Automated end-to-end verification (`node test_integration.js`).

## 🛠 Configuration

The system uses `.env` files for configuration.

* `backend/.env`: Contains Database URL, Supabase Keys, JWT Secret.

*Built with ❤️ by Antigravity.*
