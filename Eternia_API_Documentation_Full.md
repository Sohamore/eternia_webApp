# Eternia Platform — Full API & Connectivity Documentation

This document provides a comprehensive overview of all backend routers and connectivity APIs used in the Eternia platform. The backend is built on **Node.js, Express, and Prisma ORM** with a **PostgreSQL** database.

**Base URL**: `http://<your-server-ip>:5000/api`

---

## 1. Authentication & Onboarding (`/auth`)
Handles user signup, login, OTP verification, and password recovery.

*   `POST /auth/login` - Authenticate a user and return a JWT token.
*   `POST /auth/signup` - Register a new user profile.
*   `POST /auth/verify-otp` - Verify email using the OTP sent during signup.
*   `POST /auth/activate` - Activate a student account after scanning an institutional QR code.
*   `GET /auth/me` - Fetch the currently authenticated user's profile and credit balance.
*   `POST /auth/recovery/hints` - Get recovery hints for a specific username.
*   `POST /auth/recovery/verify` - Verify recovery answers to reset password.
*   `POST /auth/logout` - Revoke the current device session.

## 2. Admin & SPOC Operations (`/admin`)
Restricted endpoints for system administrators and college SPOCs (Single Point of Contact).

*   `GET /admin/members` - List all members within an institution.
*   `POST /admin/members` - Manually create a new member/student.
*   `POST /admin/members/bulk` - Bulk upload students via CSV.
*   `PATCH /admin/members/:id/role` - Assign a new role (e.g., expert, intern) to a member.
*   `GET /admin/institutions` - List all institutions (Admin only).
*   `POST /admin/institutions` - Create a new institution (Admin only).
*   `GET /admin/escalations` - View flagged Blackbox entries and peer sessions.
*   `PATCH /admin/escalations/:id/approve` - Resolve an escalation ticket.
*   `POST /admin/temp-credentials/bulk` - Generate bulk temporary login IDs for students.
*   `POST /admin/credits/grant-bulk` - Grant credits/XP to multiple users at once.

## 3. User Profiles & Settings (`/profiles`)
Manages user profiles and private/encrypted data.

*   `GET /profiles/public/:username` - Fetch the public profile of a user.
*   `PATCH /profiles/me` - Update the authenticated user's avatar, bio, or specialty.
*   `PATCH /profiles/me/private` - Update encrypted private data like Emergency Contacts and Student IDs.
*   `DELETE /profiles/me` - Submit an account deletion request.

## 4. Institutions Verification (`/institutions`)
Endpoints for verifying college membership.

*   `GET /institutions` - Get a list of active institutions.
*   `POST /institutions/verify-code` - Verify an institution's unique invite/access code.

## 5. Expert Appointments (`/appointments`)
Booking engine for professional therapy sessions.

*   `GET /appointments/experts` - List all available experts/therapists.
*   `GET /appointments/slots` - Get available time slots for a specific expert.
*   `POST /appointments` - Book an appointment slot.
*   `GET /appointments` - Get a list of the user's upcoming appointments.
*   `POST /appointments/slots` - (Expert Only) Add a new available time slot.
*   `PATCH /appointments/:id/reschedule` - Reschedule an existing appointment.

## 6. Peer Sessions (Anonymous Chat) (`/peers`)
Facilitates chat sessions between students and trained interns.

*   `POST /peers/sessions` - Initiate a new peer-to-peer chat session.
*   `GET /peers/sessions/active` - Retrieve the currently active session.
*   `POST /peers/sessions/:id/messages` - Send an encrypted message in the chat room.
*   `GET /peers/sessions/:id/messages` - Poll for new messages in a session.
*   `PATCH /peers/sessions/:id/end` - End the peer session.

## 7. Blackbox (Digital Diary & AI Flagging) (`/blackbox`)
A secure space for users to vent, with AI monitoring for self-harm intent.

*   `POST /blackbox/entries` - Submit a new text or voice entry (Encrypted).
*   `GET /blackbox/entries` - Retrieve the user's past entries.
*   `POST /blackbox/sessions` - Queue for an emergency Blackbox therapy session.
*   `GET /blackbox/therapist/queue` - (Therapist Only) View the queue of escalated students.

## 8. Quests & Gamification (`/quests`)
Manages daily tasks that yield XP/Credits.

*   `GET /quests` - List all active quest cards for the day.
*   `POST /quests/complete` - Mark a quest as completed and claim the reward.
*   `GET /quests/history` - View the user's past completed quests.

## 9. Credits & Transactions (`/credits`)
Manages the internal platform currency (ECC/XP).

*   `GET /credits/balance` - Get the current credit balance of the user.
*   `GET /credits/history` - View the ledger of earned and spent credits.

## 10. Self-Help Tools (`/selfhelp`)
Tools for daily mental wellness tracking.

*   `POST /selfhelp/mood` - Log the daily mood score (1-5).
*   `GET /selfhelp/mood` - Get a historical chart of mood entries.
*   `POST /selfhelp/journal` - Save a standard journal entry.
*   `POST /selfhelp/gratitude` - Save 3 things the user is grateful for today.

## 11. Sound Therapy (`/sound`)
Audio streaming endpoints for meditation and relaxation.

*   `GET /sound` - List all active sound tracks and categories.
*   `POST /sound/:id/play` - Increment the play counter for a specific track.

## 12. Video SDK Integration (`/videosdk`)
Handles generation of dynamic tokens for WebRTC video calls.

*   `POST /videosdk/token` - Generate a temporary token to join an appointment or blackbox room.

## 13. Notifications (`/notifications`)
Manages in-app alerts and push notifications.

*   `GET /notifications` - Retrieve unread notifications.
*   `PATCH /notifications/:id/read` - Mark a specific notification as read.
*   `POST /notifications/push-token` - Register a device FCM token for push notifications.

## 14. Analytics (`/analytics`)
Tracks anonymous usage data.

*   `POST /analytics/events` - Track a page view or screen interaction.
*   `GET /analytics/data` - (Admin Only) View aggregated usage stats.

---
*Generated by Eternia AI Assistant*
