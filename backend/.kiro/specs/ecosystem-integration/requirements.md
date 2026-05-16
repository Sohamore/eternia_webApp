# Requirements Document

## Introduction

This document specifies the requirements for the Eternia Ecosystem Integration — a full production-level unification of the Flutter mobile app, web/admin frontend, and Node.js/Express backend into a single cohesive system. The primary goal is to close the massive connectivity gap between the Flutter app screens and the existing backend APIs, build missing backend services for Flutter-only features, establish real-time communication infrastructure, and deploy a production-ready architecture on AWS.

## Glossary

- **API_Gateway**: The Express.js REST API server that handles all HTTP requests from clients
- **Flutter_Client**: The Flutter mobile application consuming backend APIs via Dio HTTP client
- **WebSocket_Server**: The Socket.io server handling real-time bidirectional communication
- **Auth_Service**: The authentication module managing JWT tokens, refresh tokens, and session lifecycle
- **Blackbox_Module**: The anonymous journaling and therapy session subsystem
- **Peer_Module**: The peer-to-peer support system connecting students with trained interns
- **Credits_Engine**: The ECC (Eternia Community Credits) economy system managing earn/spend/grant/purchase flows
- **Notification_Service**: The system responsible for in-app and push notification delivery
- **Media_Service**: The S3-backed file upload and retrieval service for voice recordings, avatars, and attachments
- **Selfhelp_Module**: The self-help tools subsystem including journal, mood, gratitude, breathing, daily check-in, and tibetan bowl
- **Quest_Engine**: The daily quest card system with XP rewards and weekly ECC caps
- **Subscription_Service**: The premium subscription management system integrated with Razorpay
- **OTP_Service**: The one-time password verification system for phone/email validation
- **Session_Aggregator**: The service that consolidates session history across appointments, peer sessions, and blackbox sessions
- **Push_Service**: The Firebase Cloud Messaging integration for delivering push notifications to mobile devices
- **Cache_Layer**: The Redis-based caching infrastructure for frequently accessed data
- **Student**: A default user role representing a student using the platform
- **Intern**: A trained peer support provider role
- **Expert**: A licensed counselor or therapist role
- **SPOC**: Single Point of Contact — an institutional administrator role
- **Admin**: A system-wide administrator role
- **Therapist**: A blackbox session handler role for anonymous therapy

## Requirements

### Requirement 1: Flutter API Client Completeness

**User Story:** As a student, I want all app screens to be connected to the backend, so that my data persists across sessions and devices.

#### Acceptance Criteria

1. WHEN the Flutter_Client initializes, THE API_Gateway SHALL respond to a health check within 2 seconds confirming service availability
2. WHEN a user navigates to any Blackbox screen, THE Flutter_Client SHALL call the corresponding Blackbox_Module endpoints for CRUD operations on entries, including listing entries with cursor-based pagination (default 30 per page), creating entries with content and content_type, and deleting owned entries
3. WHEN a user creates a journal entry in the Flutter_Client, THE API_Gateway SHALL persist the entry via the Selfhelp_Module and return the created resource with a unique identifier within 3 seconds
4. WHEN a user records a mood entry, THE Flutter_Client SHALL submit the mood value (integer, 1-5 scale) and an optional note (maximum 500 characters) to the Selfhelp_Module endpoint
5. WHEN a user submits a gratitude entry, THE Flutter_Client SHALL send between one and three gratitude items (each maximum 300 characters) to the Selfhelp_Module endpoint
6. WHEN a user opens the notifications screen, THE Flutter_Client SHALL fetch notifications from the Notification_Service using limit-based pagination with a default page size of 50 and a configurable limit parameter
7. WHEN a user opens their profile screen, THE Flutter_Client SHALL retrieve the full profile (username, role, avatar, bio, specialty, streak_days, total_sessions, verification status) including associated institution name from the API_Gateway
8. WHEN a user updates their profile, THE Flutter_Client SHALL submit the changed fields to the profiles endpoint and upon receiving a success response, update the locally displayed profile data to match the server response
9. WHEN a user navigates to session history, THE Flutter_Client SHALL request session data from the peer sessions and appointments endpoints, combining results sorted by date descending
10. WHEN a user opens the peer connect screen, THE Flutter_Client SHALL fetch interns filtered by the user's institution from the Peer_Module, displaying only interns with an active status
11. IF an API call from the Flutter_Client receives an HTTP 4xx or 5xx response, THEN THE Flutter_Client SHALL display an error indication to the user describing the failure category (network error, validation error, or server error) without exposing internal details
12. IF the Flutter_Client receives an HTTP 401 response with code TOKEN_EXPIRED, THEN THE Flutter_Client SHALL attempt a token refresh and retry the original request once before displaying an authentication error

### Requirement 2: Blackbox Integration

**User Story:** As a student, I want to write private journal entries and access anonymous therapy sessions from my phone, so that I can express myself safely.

#### Acceptance Criteria

1. WHEN a user creates a blackbox entry with content type "text", THE Blackbox_Module SHALL validate that the content does not exceed 5000 characters, encrypt and store the content, and return the entry with its identifier
2. WHEN a user creates a blackbox entry with content type "voice", THE Flutter_Client SHALL first upload the audio file to the Media_Service, then submit the file reference to the Blackbox_Module
3. WHEN a user requests their blackbox entries, THE Blackbox_Module SHALL return entries in reverse chronological order with cursor-based pagination (default 30 per page)
4. WHEN a user deletes a blackbox entry, THE Blackbox_Module SHALL permanently remove the entry only if the requesting user owns it
5. IF a user attempts to delete a blackbox entry they do not own, THEN THE Blackbox_Module SHALL return HTTP 404 without revealing whether the entry exists
6. WHEN a user requests a blackbox therapy session, THE Blackbox_Module SHALL enforce a maximum of 3 sessions per calendar day (server timezone) per user
7. IF a blackbox session creation fails due to the daily limit, THEN THE Blackbox_Module SHALL return HTTP 429 with a message indicating the daily session limit has been reached
8. WHEN a user cancels a blackbox session before the user has joined (student_joined_at is not set), THE Credits_Engine SHALL refund the spent credits to the user's balance
9. IF a user creates a blackbox entry with an unsupported content type, THEN THE Blackbox_Module SHALL reject the request with HTTP 400 and an error message indicating the allowed types ("text", "voice")

### Requirement 3: Peer Support Real-Time Communication

**User Story:** As a student, I want to chat and call with peer interns in real time, so that I can get immediate emotional support.

#### Acceptance Criteria

1. WHEN a student requests a peer session, THE Peer_Module SHALL create a pending session and notify the selected intern via the Notification_Service
2. IF the selected intern already has an active or pending session, THEN THE Peer_Module SHALL reject the request with an error indicating the intern is currently busy
3. IF a pending peer session is not accepted within 2 minutes, THEN THE Peer_Module SHALL treat the session as expired and allow the student to request a new session
4. WHEN an intern accepts a peer session, THE Peer_Module SHALL transition the session to "active" status and notify the student via the Notification_Service
5. WHILE a peer session is active, THE WebSocket_Server SHALL relay chat messages between the student and intern, emitting an acknowledgment event to the sender upon successful delivery to the recipient's socket
6. WHEN a user sends a message in a peer session, THE Peer_Module SHALL validate that the message content does not exceed 2000 characters, persist the encrypted message, and broadcast it to the other participant via WebSocket
7. WHEN a user initiates a voice or video call within a peer session, THE API_Gateway SHALL create a VideoSDK room and return the room credentials to both participants
8. IF VideoSDK room creation fails, THEN THE API_Gateway SHALL return an error indicating the call could not be started and the peer session SHALL remain active for text chat
9. WHEN an intern flags a peer session for concern, THE Peer_Module SHALL create an escalation request and notify the institutional SPOC via the Notification_Service
10. IF the WebSocket connection drops, THEN THE Flutter_Client SHALL attempt reconnection with exponential backoff starting at 1 second, doubling each attempt, up to a maximum of 5 retries and a maximum delay of 16 seconds
11. WHEN a peer session ends, THE Peer_Module SHALL update the session status to "completed" and record the end timestamp, where either participant (student or intern) may end the session

### Requirement 4: WebSocket Real-Time Infrastructure

**User Story:** As a user, I want to receive instant notifications and messages without refreshing, so that I stay informed in real time.

#### Acceptance Criteria

1. WHEN a client initiates a WebSocket connection, THE WebSocket_Server SHALL authenticate the connection by validating the JWT token provided in the handshake query parameters using the same verification logic used for REST API authentication
2. WHEN a WebSocket connection is established, THE WebSocket_Server SHALL associate the socket with the authenticated user's identifier and add it to the user's active connection set
3. WHEN a notification is created for a user, THE Notification_Service SHALL emit the notification payload (containing notification id, type, title, message, and metadata) to all of the user's active WebSocket connections within 2 seconds of creation
4. WHILE a user has an active WebSocket connection, THE WebSocket_Server SHALL send a heartbeat ping every 30 seconds; IF no pong response is received within 10 seconds, THEN THE WebSocket_Server SHALL terminate the connection and remove it from the user's active connection set
5. IF a WebSocket connection fails authentication (invalid, expired, or missing token), THEN THE WebSocket_Server SHALL close the connection with code 4001 and reason "authentication_failed" without completing the handshake
6. WHEN a user has multiple device connections, THE WebSocket_Server SHALL deliver messages to all active connections for that user up to a maximum of 5 concurrent connections per user; IF a new connection exceeds this limit, THEN THE WebSocket_Server SHALL close the oldest connection before accepting the new one
7. THE WebSocket_Server SHALL register separate namespaces for chat (/chat), notifications (/notifications), and session events (/sessions), routing messages only to clients subscribed to the relevant namespace
8. IF the JWT token expires while a WebSocket connection is active, THEN THE WebSocket_Server SHALL emit a "token_expiring" event 60 seconds before expiry, and close the connection with code 4002 and reason "token_expired" if no re-authentication occurs within that window
9. WHEN a WebSocket connection is terminated unexpectedly, THE WebSocket_Server SHALL buffer undelivered messages for that user for up to 5 minutes; WHEN the user reconnects within that window, THE WebSocket_Server SHALL deliver all buffered messages in chronological order

### Requirement 5: Push Notification System

**User Story:** As a user, I want to receive push notifications on my phone even when the app is closed, so that I never miss important updates.

#### Acceptance Criteria

1. WHEN a user logs in from the Flutter_Client, THE Flutter_Client SHALL register the device's FCM token with the API_Gateway within 5 seconds of receiving a successful authentication response
2. WHEN a notification is created and the target user has no active WebSocket connection, THE Push_Service SHALL deliver the notification via Firebase Cloud Messaging to all FCM tokens registered for that user
3. WHEN a user's FCM token changes (app reinstall or token refresh), THE Flutter_Client SHALL update the stored token on the API_Gateway, replacing the previous token for that device
4. THE Push_Service SHALL be capable of delivering notification types: peer_request, peer_accepted, appointment_reminder, escalation, session_flagged, credit_received, and system_announcement, each including a type field and a metadata object containing the resource identifier for deep-linking
5. WHEN a push notification is tapped, THE Flutter_Client SHALL navigate to the target screen mapped by notification type: peer_request and peer_accepted to the peer session screen, appointment_reminder to the appointment detail screen, escalation and session_flagged to the notifications list screen, credit_received to the credits screen, and system_announcement to the notifications list screen
6. IF the Push_Service fails to deliver a notification after 3 retries with exponential backoff (initial interval of 5 seconds), THEN THE Push_Service SHALL log the failure and mark the notification as undelivered in the database
7. WHEN a user logs out from the Flutter_Client, THE Flutter_Client SHALL request removal of the current device's FCM token from the API_Gateway so that the logged-out device no longer receives push notifications
8. WHEN a user has multiple registered devices, THE Push_Service SHALL deliver the push notification to all registered FCM tokens for that user

### Requirement 6: Media Upload Service

**User Story:** As a user, I want to upload voice recordings and profile avatars, so that I can personalize my experience and use voice journaling.

#### Acceptance Criteria

1. WHEN a user uploads a file, THE Media_Service SHALL validate the file type against an allowlist (audio/mp3, audio/m4a, audio/wav, image/jpeg, image/png, image/webp) and reject files with a size of zero bytes
2. IF a user uploads a file with a type not in the allowlist, THEN THE Media_Service SHALL reject the request with HTTP 415 and an error message indicating the accepted file types
3. WHEN a valid file is uploaded, THE Media_Service SHALL store it in AWS S3 with a unique key prefixed by user identifier and content type
4. THE Media_Service SHALL enforce a maximum file size of 25MB for audio files and 5MB for image files
5. IF an upload exceeds the size limit, THEN THE Media_Service SHALL reject the request with HTTP 413 and an error message indicating the maximum allowed size for the file type
6. WHEN a file is successfully uploaded, THE Media_Service SHALL return a signed URL valid for 24 hours for immediate access and a permanent reference key
7. WHEN a user updates their avatar and a previous avatar file exists, THE Media_Service SHALL delete the previous avatar file from S3 before storing the new one
8. IF deletion of the previous avatar from S3 fails, THEN THE Media_Service SHALL proceed with storing the new avatar and log the orphaned file key for later cleanup
9. THE Media_Service SHALL generate pre-signed upload URLs with a validity of 15 minutes so that the Flutter_Client uploads directly to S3, reducing backend bandwidth usage

### Requirement 7: Self-Help Tools Backend Integration

**User Story:** As a student, I want my breathing exercises, daily check-ins, and tibetan bowl sessions tracked, so that I can see my wellness progress over time.

#### Acceptance Criteria

1. WHEN a user completes a daily check-in, THE API_Gateway SHALL record the check-in with mood score (integer 1–5), energy level (integer 1–5), and sleep quality (integer 1–5) for the current calendar date
2. THE API_Gateway SHALL allow only one daily check-in per user per calendar day; duplicate submissions for the same day SHALL return HTTP 409
3. WHEN a user completes a breathing exercise session, THE API_Gateway SHALL log the exercise type (one of: box, 4-7-8, deep, guided), duration in seconds (minimum 10, maximum 3600), and completion timestamp
4. WHEN a user completes a tibetan bowl session, THE API_Gateway SHALL log the bowl frequency in Hz (integer, range 100–1000), duration in seconds (minimum 10, maximum 3600), and session timestamp
5. WHEN a user interacts with the wreck buddy feature, THE API_Gateway SHALL record the interaction type (one of: tap, shake, draw, scream) and duration in seconds (minimum 1, maximum 300)
6. WHEN a user requests their wellness history with a date range, THE API_Gateway SHALL return daily check-in records, exercise logs, and per-day mood averages for the requested range, limited to a maximum span of 90 days
7. WHEN a user completes a daily check-in, THE API_Gateway SHALL recalculate streak days based on consecutive calendar days with a check-in (no gaps) and update the user's profile streak_days field
8. IF a daily check-in submission contains a mood score, energy level, or sleep quality value outside the 1–5 range, THEN THE API_Gateway SHALL reject the request with HTTP 400 and an error message indicating the invalid field
9. IF a user requests wellness history without specifying a date range, THEN THE API_Gateway SHALL default to the most recent 30 days of data

### Requirement 8: Premium Subscription Management

**User Story:** As a student, I want to subscribe to premium features using Razorpay, so that I can access advanced tools and unlimited sessions.

#### Acceptance Criteria

1. WHEN a user initiates a premium subscription, THE Subscription_Service SHALL create a Razorpay subscription with the selected plan (monthly or annual) and return the subscription identifier to the client within 10 seconds
2. WHEN Razorpay confirms a successful payment, THE Subscription_Service SHALL activate the premium status on the user's profile and record the subscription start date and next renewal date
3. WHILE a user has an active premium subscription, THE API_Gateway SHALL bypass credit deductions for blackbox therapy sessions, peer sessions, and expert appointment bookings
4. WHEN a subscription payment fails, THE Subscription_Service SHALL notify the user via the Notification_Service and maintain premium access for a 3-day grace period; IF the grace period expires without successful payment, THEN THE Subscription_Service SHALL set the user's premium status to inactive and resume standard credit deductions
5. WHEN a user cancels their subscription, THE Subscription_Service SHALL maintain premium access until the current billing period ends and set the subscription status to "cancelled_pending_expiry"
6. THE Subscription_Service SHALL expose an endpoint returning the user's current subscription status, plan type, renewal date, and paginated payment history (default 20 records per page)
7. WHEN Razorpay sends a webhook event for subscription state changes, THE Subscription_Service SHALL validate the webhook signature using HMAC verification and update the subscription state accordingly; duplicate webhook events with the same event identifier SHALL be ignored without error
8. IF the Subscription_Service receives a webhook with an invalid signature, THEN THE Subscription_Service SHALL reject the request with HTTP 401 and log the attempt with the source IP hash and timestamp

### Requirement 9: OTP Verification System

**User Story:** As a user, I want to verify my phone number or email via OTP, so that my account is secured and recoverable.

#### Acceptance Criteria

1. WHEN a user requests OTP verification for a phone number or email address, THE OTP_Service SHALL generate a 6-digit numeric code with a 5-minute expiry and invalidate any previously issued unexpired OTP for the same contact
2. WHEN an OTP is generated, THE OTP_Service SHALL deliver it via SMS (for phone) or email (for email verification) using a configured provider and return a confirmation indicating the OTP was sent without revealing the code
3. WHEN a user submits a valid OTP within the expiry window, THE OTP_Service SHALL mark the corresponding contact as verified on the user's profile
4. IF a user submits an incorrect OTP, THEN THE OTP_Service SHALL decrement the remaining attempts and return the remaining attempt count to the user
5. IF a user submits an OTP after the 5-minute expiry window has elapsed, THEN THE OTP_Service SHALL reject the submission with an error indicating the code has expired
6. IF a user exhausts 5 OTP attempts for a contact, THEN THE OTP_Service SHALL lock OTP verification for that contact for 30 minutes and reject further submissions until the lock expires
7. THE OTP_Service SHALL rate-limit OTP generation to a maximum of 3 requests per contact (phone number or email address) per hour
8. IF a user requests OTP verification for a contact that is already verified, THEN THE OTP_Service SHALL reject the request with an error indicating the contact is already verified

### Requirement 10: Session History Aggregation

**User Story:** As a user, I want to see all my past sessions (appointments, peer sessions, blackbox sessions) in one place, so that I can track my support journey.

#### Acceptance Criteria

1. WHEN a user requests session history, THE Session_Aggregator SHALL return a unified list combining appointments, peer sessions, and blackbox sessions sorted by date descending
2. THE Session_Aggregator SHALL support pagination with cursor-based navigation and a configurable page size (default 20, minimum 5, maximum 50)
3. THE Session_Aggregator SHALL include session type, status, counterpart name (expert/intern or "Anonymous" for blackbox), duration in minutes (or null for incomplete sessions), and timestamp for each entry
4. WHERE a filter parameter is provided, THE Session_Aggregator SHALL filter results by session type (appointment, peer, blackbox)
5. WHEN a user with role "expert" requests session history, THE Session_Aggregator SHALL return sessions where the user was the expert
6. WHEN a user with role "intern" requests session history, THE Session_Aggregator SHALL return sessions where the user was the intern or the student
7. IF no sessions match the query criteria, THEN THE Session_Aggregator SHALL return an empty list with pagination metadata indicating zero total results

### Requirement 11: Group Session Management

**User Story:** As a student, I want to join group therapy or support sessions, so that I can benefit from shared experiences with peers.

#### Acceptance Criteria

1. WHEN an expert creates a group session, THE API_Gateway SHALL store the session with title (maximum 100 characters), description (maximum 500 characters), scheduled time, maximum participant count (between 2 and 30), and session type
2. WHEN a student joins a group session that has not yet started and has available capacity, THE API_Gateway SHALL add the student to the participant list if the student is not already a participant
3. IF a group session is full, THEN THE API_Gateway SHALL reject the join request with HTTP 409 and a message indicating the session is at capacity
4. IF a student attempts to join a group session they have already joined, THEN THE API_Gateway SHALL reject the request with HTTP 409 and a message indicating duplicate participation
5. WHEN the scheduled time of a group session is reached, THE API_Gateway SHALL create a VideoSDK room and deliver the room credentials to all registered participants via the Notification_Service and active WebSocket connections
6. WHEN the expert ends a group session, THE API_Gateway SHALL update the session status to "completed" and record attendance as present for each participant who joined the VideoSDK room
7. WHEN an expert schedules a recurring group session with a recurrence rule (daily or weekly), THE API_Gateway SHALL generate individual session instances for up to 12 weeks in advance
8. WHEN a student leaves a group session before it starts, THE API_Gateway SHALL remove the student from the participant list and free the capacity slot
9. IF the VideoSDK room creation fails when a group session starts, THEN THE API_Gateway SHALL notify all registered participants of the failure via the Notification_Service and set the session status to "failed"

### Requirement 12: Privacy and Data Protection

**User Story:** As a user, I want control over my data privacy settings, so that I feel safe using the platform.

#### Acceptance Criteria

1. THE API_Gateway SHALL store all sensitive personal data (emergency contacts, student IDs, recovery credentials) in encrypted form using database-level field encryption
2. WHEN a user updates their privacy settings, THE API_Gateway SHALL persist the preferences (profile visibility: public/institution-only/private, and session history visibility: visible/hidden) and enforce them by filtering the user's data from queries made by other users within 5 seconds of the update
3. WHEN a user requests data export, THE API_Gateway SHALL generate a JSON archive containing profile data, blackbox entries, journal entries, mood entries, gratitude entries, credit transactions, session history, and notification history, and SHALL complete generation within 24 hours and notify the user via in-app notification when ready
4. IF a data export generation fails, THEN THE API_Gateway SHALL notify the user with an error indication and allow the user to retry the export request
5. WHEN a user requests account deletion, THE API_Gateway SHALL initiate a 14-day grace period during which the account is deactivated but recoverable, and after the grace period expires, SHALL soft-delete the account, anonymize personal data fields (username, email, emergency contacts, student IDs), and retain only aggregated analytics data with no link to the original user identity
6. THE API_Gateway SHALL enforce that blackbox entries marked as "private" (is_private = true) are accessible only by the owning user and never included in escalation reviews or admin queries
7. WHEN an admin or SPOC accesses emergency contact data, THE API_Gateway SHALL create an audit log entry recording the accessor identity, target user identity, timestamp, and access reason
8. THE API_Gateway SHALL enforce data retention policies: soft-delete accounts inactive for 365 consecutive days (based on last_login timestamp), with a notification sent to the user at 30 days and 7 days before the scheduled deletion
9. WHEN a user requests account deletion during the grace period, THE API_Gateway SHALL allow the user to cancel the deletion request and reactivate the account

### Requirement 13: Input Validation and Error Handling

**User Story:** As a developer, I want consistent input validation and structured error responses, so that the API is predictable and secure.

#### Acceptance Criteria

1. THE API_Gateway SHALL validate all incoming request bodies against defined JSON schemas before reaching controller logic, rejecting requests with missing required fields or fields that do not match the expected type
2. WHEN a request fails validation, THE API_Gateway SHALL return HTTP 400 with a structured error response containing an array of field-level error objects, each specifying the field path, the violated constraint, and a human-readable message
3. THE API_Gateway SHALL use a standardized error response format: `{ error: string, code: string, details?: object }` across all endpoints, where `error` contains a human-readable summary and `code` contains the machine-readable error code
4. THE API_Gateway SHALL map error codes to HTTP status codes as follows: VALIDATION_ERROR to 400, AUTH_EXPIRED to 401, INSUFFICIENT_CREDITS to 402, RESOURCE_NOT_FOUND to 404, CONFLICT to 409, RATE_LIMITED to 429
5. WHEN an unhandled exception occurs, THE API_Gateway SHALL log the full stack trace with request context, return HTTP 500 with the error response format containing code "INTERNAL_ERROR" and a non-revealing message in production, and include the original error message in the `details` field in non-production environments
6. THE API_Gateway SHALL sanitize all string inputs by trimming leading and trailing whitespace, removing null bytes, and enforcing a default maximum length of 1000 characters per string field unless a field-specific limit is defined in the schema
7. IF a request is received with a Content-Type header that does not match `application/json` on endpoints expecting a JSON body, THEN THE API_Gateway SHALL return HTTP 415 with the standardized error response format and code "UNSUPPORTED_MEDIA_TYPE"
8. WHEN multiple validation errors exist in a single request, THE API_Gateway SHALL return all detected errors in one response rather than failing on the first error encountered

### Requirement 14: API Versioning and Rate Limiting

**User Story:** As a developer, I want API versioning and granular rate limiting, so that the API can evolve without breaking clients and remains protected from abuse.

#### Acceptance Criteria

1. THE API_Gateway SHALL prefix all routes with a version identifier (v1) under the path `/api/v1/`
2. WHEN a deprecated endpoint is called, THE API_Gateway SHALL include a `Deprecation` header with the sunset date in ISO 8601 format (YYYY-MM-DD) and a `Link` header pointing to the replacement endpoint
3. THE API_Gateway SHALL apply rate limits per endpoint category: 20 requests per 15 minutes for auth endpoints (`/auth/*`), 60 requests per minute for general endpoints, and 10 requests per minute for sensitive operations (account deletion, password change, OTP generation, credit purchases, and subscription management endpoints)
4. WHEN a rate limit is exceeded, THE API_Gateway SHALL return HTTP 429 with a `Retry-After` header indicating seconds until the limit resets and a response body conforming to the standardized error format with error code RATE_LIMITED
5. THE API_Gateway SHALL identify clients by authenticated user ID for rate limiting; for unauthenticated endpoints (login, registration, OTP request), THE API_Gateway SHALL fall back to client IP address as the rate-limit key
6. WHERE a premium subscription is active, THE API_Gateway SHALL apply elevated rate limits (2x the standard limits) for the subscribed user
7. WHEN a previously non-versioned endpoint is accessed at its legacy path, THE API_Gateway SHALL return HTTP 301 redirecting to the corresponding `/api/v1/` path for a transition period of no less than 90 days

### Requirement 15: Caching Strategy

**User Story:** As a user, I want fast response times for frequently accessed data, so that the app feels responsive.

#### Acceptance Criteria

1. THE Cache_Layer SHALL cache quest card listings with a TTL of 5 minutes, invalidating on quest creation or deactivation
2. THE Cache_Layer SHALL cache sound content listings with a TTL of 10 minutes, invalidating when sound content is added or removed
3. THE Cache_Layer SHALL cache user credit balances with a TTL of 30 seconds, invalidating on any credit transaction for that user
4. THE Cache_Layer SHALL cache expert availability listings with a TTL of 1 minute, invalidating when a slot is booked or released
5. WHEN cached data is invalidated, THE Cache_Layer SHALL remove the specific cache key without affecting other cached entries
6. THE Cache_Layer SHALL use Redis as the backing store with a connection pool of minimum 2 and maximum 10 connections, and automatic reconnection on failure with exponential backoff up to 5 retries
7. IF the Cache_Layer does not respond within 500 milliseconds or is unreachable, THEN THE API_Gateway SHALL fall back to direct database queries, log a warning with the cache key and failure reason, and return the response to the client without an error indication
8. IF the Cache_Layer reconnection retries are exhausted, THEN THE API_Gateway SHALL continue operating with direct database queries and emit a critical-level log entry indicating cache unavailability

### Requirement 16: Infrastructure and Deployment

**User Story:** As a DevOps engineer, I want containerized deployments with CI/CD, so that releases are reliable and reproducible.

#### Acceptance Criteria

1. THE API_Gateway SHALL be containerized using a multi-stage Docker build with a production image under 200MB
2. THE API_Gateway Docker image SHALL run as a non-root user and expose only the configured application port (default 3000)
3. WHEN code is pushed to the main branch, THE CI/CD pipeline SHALL run linting, unit tests, and integration tests, build the Docker image, and deploy to the staging environment; IF any stage fails, THEN THE CI/CD pipeline SHALL halt execution and report the failing stage
4. WHEN a release tag is created, THE CI/CD pipeline SHALL deploy the tagged image to the production environment on AWS ECS; IF the new task fails the ECS health check within 5 minutes, THEN THE CI/CD pipeline SHALL roll back to the previously running task definition
5. THE infrastructure SHALL provision an AWS RDS PostgreSQL instance with automated daily backups retained for 7 days
6. THE infrastructure SHALL provision an AWS S3 bucket with server-side encryption (AES-256) for media storage
7. THE infrastructure SHALL provision a Redis instance (AWS ElastiCache) for caching and WebSocket session state
8. THE API_Gateway SHALL implement graceful shutdown: stop accepting new connections, complete in-flight requests within 30 seconds, then forcibly terminate any remaining connections and exit the process
9. THE ECS task definition SHALL include a health check that calls the API_Gateway `/health/ready` endpoint every 30 seconds, marking the task unhealthy after 3 consecutive failures

### Requirement 17: Monitoring and Observability

**User Story:** As a DevOps engineer, I want structured logging, health checks, and metrics, so that I can detect and diagnose production issues quickly.

#### Acceptance Criteria

1. THE API_Gateway SHALL emit structured JSON logs with fields: timestamp (ISO 8601), level (one of: error, warn, info, http, debug), request_id, user_id, method, path, status_code, and duration_ms
2. THE API_Gateway SHALL expose a `/health` endpoint that returns HTTP 200 with a JSON body containing: status ("healthy" or "degraded"), database connectivity (boolean), Redis connectivity (boolean), and uptime in seconds
3. THE API_Gateway SHALL expose a `/health/ready` endpoint that returns HTTP 200 when all dependencies (database, Redis, S3) are reachable within a 3-second per-dependency timeout, and HTTP 503 when any dependency is unreachable
4. WHEN a request takes longer than 5 seconds, THE API_Gateway SHALL log a warning with the request_id, method, path, and duration_ms
5. THE API_Gateway SHALL assign a unique request_id (UUID v4) to each incoming request and include it in all log entries and the response header `X-Request-Id`
6. THE API_Gateway SHALL expose a `/metrics` endpoint returning request count by endpoint, error count by endpoint, average response time over a rolling 5-minute window, and active WebSocket connection count
7. IF a dependency health check fails during a `/health` request, THEN THE API_Gateway SHALL return HTTP 200 with status "degraded" and indicate which dependency is unreachable in the response body

### Requirement 18: Security Hardening

**User Story:** As a security engineer, I want the platform hardened against common attack vectors, so that user data remains protected.

#### Acceptance Criteria

1. THE API_Gateway SHALL enable Helmet.js security headers in production (X-Content-Type-Options, X-Frame-Options, Strict-Transport-Security, Content-Security-Policy)
2. THE API_Gateway SHALL enforce HTTPS-only communication in production by redirecting HTTP requests to HTTPS with a 301 status code
3. THE API_Gateway SHALL validate JWT tokens on every authenticated request, rejecting tokens that are expired, malformed, or signed with an unknown key with HTTP 401 and a response body indicating the rejection reason
4. WHEN a refresh token is used, THE Auth_Service SHALL rotate the refresh token, invalidate the previous one (one-time use), and return the new refresh token alongside the new access token
5. IF an already-invalidated refresh token is presented, THEN THE Auth_Service SHALL reject the request with HTTP 401 and invalidate all refresh tokens for the associated user to mitigate replay attacks
6. THE API_Gateway SHALL implement CORS with an explicit allowlist of permitted origins in production (no wildcard); requests from origins not in the allowlist SHALL receive no CORS headers in the response
7. THE API_Gateway SHALL log all authentication failures with client IP hash, username attempted, and failure reason for security monitoring
8. THE API_Gateway SHALL reject request bodies larger than 10MB with HTTP 413 and an error message indicating the size limit
9. WHEN a user's account is deactivated, THE Auth_Service SHALL invalidate all active sessions and refresh tokens for that user before the deactivation response is returned to the caller
10. IF a single user account accumulates 10 consecutive failed authentication attempts, THEN THE Auth_Service SHALL lock the account for 15 minutes and notify the user via their verified contact method

### Requirement 19: Database Architecture Improvements

**User Story:** As a developer, I want proper soft deletes, connection pooling, and migration support, so that the database layer is production-ready.

#### Acceptance Criteria

1. THE API_Gateway SHALL use Prisma connection pooling with a minimum of 2 and maximum of 10 connections per instance, configured via the DATABASE_URL connection string parameters
2. WHEN a user or resource is deleted, THE API_Gateway SHALL perform a soft delete by setting a `deleted_at` timestamp rather than removing the row, applying to the following models: User, Profile, BlackboxEntry, JournalEntry, MoodEntry, GratitudeEntry, PeerSession, Appointment, and Notification
3. THE API_Gateway SHALL exclude soft-deleted records (where `deleted_at` is not null) from all standard queries unless the requesting user has the admin role and includes a query parameter indicating inclusion of deleted records
4. IF a database migration fails during the deployment pipeline, THEN THE API_Gateway SHALL abort the application startup and exit with a non-zero exit code, logging the migration error details
5. THE API_Gateway SHALL run database migrations via Prisma Migrate (`prisma migrate deploy`) as part of the deployment pipeline before starting the application
6. THE API_Gateway SHALL implement database query timeouts of 10 seconds; IF a query exceeds the timeout, THEN THE API_Gateway SHALL cancel the query and return an error response indicating a database timeout occurred
7. WHEN a database connection fails, THE API_Gateway SHALL retry the connection up to 3 times with exponential backoff starting at a base delay of 1 second (1s, 2s, 4s) before returning an error response indicating database unavailability

### Requirement 20: Flutter Client Architecture

**User Story:** As a mobile developer, I want a well-structured API client layer in Flutter, so that all screens can reliably communicate with the backend.

#### Acceptance Criteria

1. THE Flutter_Client SHALL implement a centralized API service class with methods for every backend endpoint, organized by module (auth, blackbox, peers, selfhelp, credits, notifications, profile, appointments, quests, sound)
2. IF the Flutter_Client receives a 401 response with code TOKEN_EXPIRED, THEN THE Flutter_Client SHALL call the refresh endpoint, update the stored token, and retry the original request exactly once
3. IF the token refresh request itself fails (refresh token expired, invalid, or server error), THEN THE Flutter_Client SHALL clear stored tokens, cancel pending requests, and navigate the user to the login screen
4. THE Flutter_Client SHALL store authentication tokens in platform-secure storage (flutter_secure_storage) and never in plain SharedPreferences
5. WHEN the Flutter_Client detects no network connectivity, THE Flutter_Client SHALL queue write operations locally (up to a maximum of 50 operations, discarding the oldest when full) and sync them in order when connectivity is restored within 24 hours of queuing
6. IF a queued write operation fails during sync with a non-retryable error (HTTP 400, 403, 404, 409), THEN THE Flutter_Client SHALL discard that operation, log the failure locally, and continue syncing remaining operations
7. THE Flutter_Client SHALL implement request retry logic with exponential backoff for transient failures (HTTP 500, 502, 503, timeout) starting at 1 second, doubling each attempt, up to a maximum of 3 retries with a maximum delay of 8 seconds
8. THE Flutter_Client SHALL use a consistent response model that wraps API responses with: a boolean success flag, the parsed response data (or null on failure), an error code string matching the backend error codes, and a human-readable error message
9. WHEN the Flutter_Client receives a WebSocket message of type "notification", THE Flutter_Client SHALL update the local notification badge count and display an in-app toast

### Requirement 21: Appointment and Expert Session Integration

**User Story:** As a student, I want to browse experts, book appointments, and join video sessions from my phone, so that I can access professional counseling.

#### Acceptance Criteria

1. WHEN a student browses experts, THE Flutter_Client SHALL fetch the expert list filtered by the student's institution from the API_Gateway
2. WHEN a student selects an expert, THE Flutter_Client SHALL fetch available time slots for that expert from the API_Gateway, displaying only future slots that are not yet booked
3. WHEN a student books an appointment, THE Credits_Engine SHALL atomically deduct the session cost and create the appointment in a single database transaction
4. IF the student has insufficient credits for an appointment, THEN THE Credits_Engine SHALL check the institution's stability pool; IF the pool has sufficient balance, THEN THE Credits_Engine SHALL deduct from the pool and proceed with booking
5. IF both the student's balance and the institution's stability pool are insufficient, THEN THE Credits_Engine SHALL reject the booking with error code INSUFFICIENT_CREDITS
6. WHEN an appointment time approaches (15 minutes before), THE Push_Service SHALL send a reminder notification to both the student and the expert
7. WHEN a video session starts, THE API_Gateway SHALL create a VideoSDK room and return tokens to both participants
8. IF VideoSDK room creation fails, THEN THE API_Gateway SHALL return an error and set the appointment status to "pending" for retry
9. WHEN an appointment is cancelled more than 1 hour before the scheduled time, THE Credits_Engine SHALL issue a full refund to the student
10. IF an appointment is cancelled less than 1 hour before the scheduled time, THEN THE Credits_Engine SHALL not issue a refund and the appointment status SHALL be set to "cancelled"

### Requirement 22: Credits Economy Flutter Integration

**User Story:** As a student, I want to view my credit balance, transaction history, and purchase credits from my phone, so that I can manage my ECC economy.

#### Acceptance Criteria

1. WHEN a user opens the credits screen, THE Flutter_Client SHALL fetch the current balance and weekly earn total from the Credits_Engine and display both values within 3 seconds
2. WHEN a user views transaction history, THE Flutter_Client SHALL fetch paginated transactions (20 per page) from the Credits_Engine with type filtering support for earn, spend, grant, and purchase transaction types
3. WHEN a user initiates a credit purchase, THE Flutter_Client SHALL present the available credit packages (25, 60, or 130 ECC), request a Razorpay order from the API_Gateway for the selected package, and launch the Razorpay payment flow
4. WHEN Razorpay returns a successful payment, THE Flutter_Client SHALL submit the payment_id, order_id, and signature to the API_Gateway for verification and update the local balance with the credited amount upon success
5. IF payment verification fails (invalid signature or order mismatch), THEN THE Flutter_Client SHALL display an error message indicating verification failure and instruct the user to contact support, without updating the local balance
6. THE Credits_Engine SHALL enforce the weekly earn cap of 5 ECC from quest completions, returning the remaining allowance in the response
7. WHEN credits are spent on any service, THE Flutter_Client SHALL optimistically deduct the amount from the displayed balance and, if the server response returns a different balance, SHALL replace the local balance with the server-provided value

### Requirement 23: Institutional Support Integration

**User Story:** As a student at an institution, I want to scan my institution's QR code and access institution-specific features, so that I benefit from my institution's Eternia partnership.

#### Acceptance Criteria

1. WHEN a student scans an institution QR code, THE Flutter_Client SHALL submit the QR payload to the API_Gateway for validation within 10 seconds of the scan completing
2. WHEN the QR payload is valid and not expired (5-minute window from the embedded timestamp), THE API_Gateway SHALL return the institution name and plan type, and associate the student's profile with that institution by setting the institution_id on their profile
3. IF the QR payload signature is invalid or the timestamp exceeds the 5-minute window, THEN THE API_Gateway SHALL return an error indicating the QR code needs regeneration without revealing which check failed
4. WHEN a SPOC generates a QR code, THE API_Gateway SHALL create an HMAC-signed payload containing institution_id, spoc_id, and timestamp, with the resulting QR code valid for 5 minutes from the embedded timestamp
5. WHEN a student is associated with an institution, THE API_Gateway SHALL filter expert listings to include only experts linked to that institution, allow credit grants from the institution's stability pool, and include the student in institution group sessions
6. THE Flutter_Client SHALL support campus verification by submitting APAAR or ERP student IDs for hash-based validation against the institution's registered ID list, marking the corresponding verification flag (apaar_verified or erp_verified) as true on success
7. IF the submitted student ID hash does not match any entry in the institution's registered ID list, THEN THE API_Gateway SHALL return an error indicating the student ID is not recognized for that institution
8. IF a student is already associated with a different institution when scanning a new QR code, THEN THE API_Gateway SHALL replace the existing institution association with the new one and return the updated institution details

### Requirement 24: Emergency Contact and Safety Features

**User Story:** As a user in distress, I want quick access to emergency contacts and crisis resources, so that I can get help when I need it most.

#### Acceptance Criteria

1. WHEN a user sets up an emergency contact, THE API_Gateway SHALL validate that the contact name is between 1 and 100 characters, the phone number matches E.164 format (up to 15 digits), and the relationship is between 1 and 50 characters, then store all three fields in encrypted form in the UserPrivate record
2. WHEN a user accesses the emergency support screen, THE Flutter_Client SHALL retrieve stored emergency contacts from the API_Gateway and display the contact name, phone number, and relationship; IF no emergency contact has been saved, THEN THE Flutter_Client SHALL display a prompt to add one alongside the crisis helpline information
3. WHEN a blackbox entry is flagged at level 3 (critical), THE Notification_Service SHALL notify the institutional SPOC associated with the user's institution within 30 seconds of the flag being set, including the escalation request identifier and flag level
4. THE API_Gateway SHALL expose a dedicated emergency endpoint that returns crisis helpline numbers without requiring authentication; IF the requesting user is authenticated and associated with an institution, THEN the response SHALL also include the institutional SPOC contact information
5. WHEN an escalation is created, THE API_Gateway SHALL record an audit trail in the EscalationRequest record including the triggering entry identifier, flag level, assigned SPOC identifier, escalation status, trigger timestamp, and justification
6. IF a critical escalation (level 3) cannot identify an institutional SPOC for the user (user has no institution association), THEN THE Notification_Service SHALL notify the system admin and record the escalation with status "unassigned"

### Requirement 25: Offline Support and Data Synchronization

**User Story:** As a student with unreliable connectivity, I want the app to work offline for basic features, so that I can journal and track mood without internet.

#### Acceptance Criteria

1. WHEN the Flutter_Client detects offline status, THE Flutter_Client SHALL allow creation of journal entries, mood entries, and gratitude entries stored locally up to a maximum of 200 pending entries
2. WHEN network connectivity is restored, THE Flutter_Client SHALL synchronize all locally stored entries to the API_Gateway in chronological order within 60 seconds of detecting connectivity, processing entries in batches of up to 20
3. IF a sync conflict occurs (entry already exists on server), THEN THE Flutter_Client SHALL use the server version as authoritative and display an in-app message indicating which entries were resolved by the server version
4. THE Flutter_Client SHALL cache the most recent 50 notifications, 30 journal entries, 30 gratitude entries, and 7 days of mood data for offline viewing
5. WHILE offline, THE Flutter_Client SHALL display a persistent visual indicator visible on all screens informing the user that data will sync when connectivity returns
6. IF synchronization of an entry fails due to a server rejection (HTTP 400 or 422), THEN THE Flutter_Client SHALL mark the entry as failed, retain it locally, and display a notification indicating the number of entries that failed to sync
7. WHILE offline, THE Flutter_Client SHALL display a visual distinction on entries that have not yet been synchronized to the server
