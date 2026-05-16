# Eternia Backend Server

Node.js + Express + Prisma ORM backend replacing Supabase.

## Stack
- **Runtime:** Node.js (CommonJS)
- **Framework:** Express 4
- **ORM:** Prisma 5 (PostgreSQL)
- **Auth:** JWT (access + refresh tokens)
- **Payments:** Razorpay
- **Video:** VideoSDK
- **AI:** OpenAI-compatible gateway

## Setup

### 1. Install dependencies
```bash
cd server
npm install
```

### 2. Configure environment
```bash
cp .env.example .env
# Fill in DATABASE_URL, JWT_SECRET, JWT_REFRESH_SECRET, etc.
```

### 3. Set up the database
```bash
# Run migrations (creates all tables)
npm run db:migrate

# Generate Prisma client
npm run db:generate

# Seed with initial data (quest cards, sound content)
npm run db:seed
```

### 4. Start the server
```bash
# Development (with auto-reload)
npm run dev

# Production
npm start
```

## API Endpoints

| Module        | Base Path             |
|---------------|-----------------------|
| Auth          | `/api/auth`           |
| Credits       | `/api/credits`        |
| Appointments  | `/api/appointments`   |
| BlackBox      | `/api/blackbox`       |
| Peer Connect  | `/api/peers`          |
| Admin         | `/api/admin`          |
| Quests        | `/api/quests`         |
| Sound Therapy | `/api/sound`          |
| Notifications | `/api/notifications`  |
| Analytics     | `/api/analytics`      |
| Institutions  | `/api/institutions`   |
| VideoSDK      | `/api/videosdk`       |
| Self-Help     | `/api/selfhelp`       |
| Profiles      | `/api/profiles`       |

## Architecture

```
server/
├── index.js              # Express app entry point
├── prisma/
│   ├── schema.prisma     # Full database schema
│   ├── client.js         # Prisma singleton client
│   └── seed.js           # Initial data seed
├── routes/               # Express routers
├── controllers/          # HTTP request handlers
├── services/             # Business logic + Prisma queries
├── middlewares/
│   ├── auth.js           # JWT authentication
│   ├── rateLimit.js      # Rate limiting
│   └── errorHandler.js   # Global error handler
└── utils/
    ├── jwt.js            # Token sign/verify
    ├── logger.js         # Winston logger
    └── helpers.js        # Utility functions
```

## Environment Variables

| Variable               | Description                        |
|------------------------|------------------------------------|
| `DATABASE_URL`         | PostgreSQL connection string       |
| `JWT_SECRET`           | Access token signing key           |
| `JWT_REFRESH_SECRET`   | Refresh token signing key          |
| `JWT_EXPIRES_IN`       | Access token TTL (default: 15m)    |
| `JWT_REFRESH_EXPIRES_IN` | Refresh token TTL (default: 7d)  |
| `PORT`                 | Server port (default: 3001)        |
| `FRONTEND_URL`         | CORS origin                        |
| `RAZORPAY_KEY_ID`      | Razorpay public key                |
| `RAZORPAY_KEY_SECRET`  | Razorpay secret key                |
| `VIDEOSDK_API_KEY`     | VideoSDK API key                   |
| `VIDEOSDK_API_SECRET`  | VideoSDK API secret                |
| `AI_GATEWAY_URL`       | AI API base URL                    |
| `AI_GATEWAY_KEY`       | AI API key                         |
