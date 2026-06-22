# 🚀 Full-Stack E-Commerce Automation System

This repository showcases a robust, full-stack e-commerce automation system built with modern web technologies and an advanced relational database architecture. The project is engineered with a heavy focus on relational database design, data integrity, security compliance, and backend-frontend synchronization.

## 🛠️ Technology Stack & Role Matrix

| Technology / Tool | Category | Project Role & Responsibility |
| :--- | :--- | :--- |
| **MS SQL Server** | Database Management | Core data layer storing structured information for customers, products, orders, logistics, and payments. |
| **T-SQL (Transact-SQL)** | Database Programming | Advanced database-level automation using triggers, stored procedures, optimized views, and ACID-compliant transactions. |
| **Node.js & Express.js** | Backend API | Secure RESTful API layer routing requests, managing active shopping carts, handling authentication, and processing checkouts. |
| **JavaScript (ES6+)** | Frontend Logic | Asynchronous frontend behavior utilizing `fetch()` API for dynamic cart operations and client-side filtering. |
| **HTML5 & CSS3** | User Interface (UI) | Responsive UI featuring a modern, dark-themed (Dark Mode) aesthetic tailored for high-tech product retail. |
| **dotenv & CORS** | Application Security | Protection of sensitive credentials (database passwords) and cross-origin resource sharing configuration. |

## 📐 Database Architecture & Advanced Logic

Instead of basic CRUD operations, this system offloads heavy business logic to the database level to ensure data integrity and maximum query performance:

### 1. 3NF & BCNF Normalization
The relational schema is strictly structured up to **3rd Normal Form (3NF)** and **Boyce-Codd Normal Form (BCNF)**. Entities like `CUSTOMER`, `ORDERS`, `PRODUCT`, `SHIPPING`, and `PAYMENT` are fully decoupled. This design eliminates data redundancy and prevents insertion, update, and deletion anomalies.

### 2. Automated Inventory Control (`trg_StokDusur` Trigger)
To prevent stock discrepancies, inventory management is handled directly by the database engine. The moment a new purchase is recorded in the order details table (`SIPARIS_DETAY`), this T-SQL trigger automatically fires to deduct the exact purchased quantities from the main stock table, completely eliminating race conditions.

### 3. Cyber Security & Data Privacy (Card Masking)
In compliance with data protection principles, credit/debit card numbers are never stored in plain text. When a user submits their 16-digit card info, backend filters intercept the payload. The database securely masks the numbers, storing and displaying only the last 4 digits (e.g., `************7777`), ensuring maximum data privacy.

### 4. ACID-Compliant Transactions & Modular Views
* **Transactions:** Order placement and cancellation processes are wrapped inside ACID-compliant SQL Transactions. If a failure occurs mid-operation (e.g., log failure), the entire sequence rolls back to protect state consistency.
* **Views (`View_UrunKategori`):** Product catalog queries utilize indexed relational Views. This decouples complex multi-table JOIN operations from the backend, allowing Express.js to fetch clean catalog data with minimal latency.

## 👥 Team Members & Contributors

This project was developed as a collaborative group effort. Special thanks to the team members for their contributions to the database architecture, backend endpoints, and frontend design:

* **Hatice Kübra Ünal**
* **Yaren Arslan**
* **Feyza Demirel**

## 📸 Application Screenshots (UI Showcase)
<img width="1208" height="699" alt="Ekran görüntüsü 2026-06-22 211211" src="https://github.com/user-attachments/assets/5671b4a8-7108-413c-8d57-3ebae0c0ffdc" />
<img width="1212" height="695" alt="Ekran görüntüsü 2026-05-10 212348" src="https://github.com/user-attachments/assets/c60389db-2af4-4df9-9e51-d0187617f27c" />
<img width="414" height="451" alt="Ekran görüntüsü 2026-05-10 211437" src="https://github.com/user-attachments/assets/d9031b4b-2c68-4d18-a526-9875701549d4" />
<img width="328" height="486" alt="Ekran görüntüsü 2026-05-10 211307" src="https://github.com/user-attachments/assets/1dacb9fc-3af2-422b-aa66-7a936d15db0a" />
