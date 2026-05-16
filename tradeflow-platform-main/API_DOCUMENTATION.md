# Eternia Platform — API Documentation (v1.0)

This document serves as the technical specification for connecting the **Eternia Flutter App** and the **Eternia Web Dashboard** to the centralized Node.js/Prisma backend.

## 🚀 System Overview
- **Backend Stack:** Node.js, Express, Prisma ORM
- **Database:** Neon Postgres
- **Auth Strategy:** JWT (JSON Web Tokens) with Bearer Authorization
- **Base URL (Local Dev):** `http://localhost:5000/api`
- **Base URL (Mobile IP):** `http://<your-laptop-ip>:5000/api`

---

## 🏫 Onboarding & Verification

### 1. Verify Institution Code
`POST /institutions/verify-code`
- **Body:** `{ "code": "UNIV2024" }`
- **Returns:** `{ "valid": true, "institution": { "id", "name" } }`

### 2. Activate Account (After QR Scan)
`POST /auth/activate`
- **Body:** 
```json
{
  "tempCredentialId": "...",
  "username": "...",
  "password": "...",
  "emergencyContact": { "name": "...", "phone": "..." },
  "studentIdData": { "idType": "...", "rawId": "..." }
}
```
- **Returns:** `{ "token": "...", "user": { ... } }`

---

## 🔐 Authentication Module

### 2. Login User
`POST /auth/login`
- **Body:** `{ "username": "...", "password": "..." }`
- **Returns:** `{ "token": "...", "user": { "id", "username", "role", "is_verified" ... } }`

### 3. Get Current Profile
`GET /auth/me` (Requires Bearer Token)
- **Returns:** `{ "user": { ... }, "creditBalance": 100 }`

### 4. Password Recovery
`POST /auth/recovery/hints`
- **Body:** `{ "username": "sezzz" }`
- **Returns:** `{ "hasRecovery": true, "hints": [ { "hint": "Question 1" } ] }`

`POST /auth/recovery/verify`
- **Body:** 
```json
{
  "username": "...",
  "fragmentPairs": [ { "answer": "..." } ],
  "emojiPattern": [ "😀", "😎" ],
  "newPassword": "..."
}
```
- **Returns:** `{ "success": true }`

---

## 🃏 Quests Module (Gamification)

### 1. Get Available Quests
`GET /quests`
- **Returns:** `{ "quests": [ { "id", "title", "description", "xp_reward" ... } ] }`

### 2. Complete Quest
`POST /quests/complete`
- **Body:** `{ "quest_id": "...", "answer": "..." }`
- **Success:** `{ "reward": 20, "weeklyTotal": 40 }`

---

## 📅 Expert Connect (Appointments)

### 1. List Experts
`GET /appointments/experts`
- **Returns:** `{ "experts": [ { "id", "username", "specialty" ... } ] }`

### 2. Get Available Slots
`GET /appointments/slots?expert_id=<id>`
- **Returns:** `{ "slots": [ { "id", "start_time", "end_time" ... } ] }`

### 3. Book Appointment
`POST /appointments`
- **Body:** 
```json
{
  "expert_id": "...",
  "slot_id": "...",
  "slot_time": "ISO_TIMESTAMP",
  "session_type": "video|audio",
  "credits_charged": 50
}
```

---

## 🎵 Sound Therapy

### 1. Get Tracks
`GET /sound`
- **Returns:** `{ "sounds": [ { "title", "file_url", "cover_emoji", "category" ... } ] }`

---

## 💬 Peer Connect (Anonymous Chat)

### 1. Create Session
`POST /peers/sessions`
- **Body:** `{ "intern_id": "..." }`
- **Returns:** `{ "session": { "id", "status" ... } }`

### 2. Send Message
`POST /peers/sessions/:id/messages`
- **Body:** `{ "content": "..." }`

### 3. Poll Messages
`GET /peers/sessions/:id/messages?limit=50&cursor=<timestamp>`

---

## 💰 Credits (ECC)

### 1. Get Balance
`GET /credits/balance`
- **Returns:** `{ "balance": 120 }`

---

## 🛠 Integration Prompt for Flutter AI (Cursor/ChatGPT)

> "Act as a Senior Flutter Developer. I have a Node.js/Prisma REST API documented in API_DOCUMENTATION.md. Please build a Flutter Service layer using the `dio` package. Implement authentication persistence using `flutter_secure_storage`. All data models should be generated using `freezed` or `json_serializable`. Ensure that the API base URL is configurable for development (local IP) and production (AWS URL)."

---

## ☁️ AWS Deployment Plan
1. **Compute:** Deploy the `server/` directory to **AWS App Runner**.
2. **Database:** Use **Neon.tech** (Postgres) and paste the connection string into the AWS Environment Variable `DATABASE_URL`.
3. **Storage:** (Optional) Use **AWS S3** for uploading custom sound files or avatar images.
