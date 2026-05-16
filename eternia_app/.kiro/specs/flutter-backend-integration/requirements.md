# Requirements Document

## Introduction

This document specifies the requirements for integrating the Eternia Flutter mobile application with the existing Express.js/Prisma/PostgreSQL backend. The backend already serves a React website successfully. The Flutter app currently has a partially working auth flow with a hardcoded IP address, no token refresh logic, and missing service layers for all other modules. This feature will establish proper environment configuration, robust authentication with token refresh, and complete service layers for all backend API groups — mirroring the integration pattern used by the React website.

## Glossary

- **API_Client**: The centralized Dio HTTP client in the Flutter app responsible for all network requests, token attachment, and token refresh logic
- **Access_Token**: A short-lived JWT (15 minutes) used to authenticate API requests
- **Refresh_Token**: A long-lived JWT (7 days) used to obtain a new Access_Token when the current one expires
- **Environment_Config**: A configuration system that provides base URLs and settings for development, staging, and production environments without hardcoding
- **Auth_Service**: The Flutter service layer responsible for user authentication, registration, OTP verification, and session management
- **Credits_Service**: The Flutter service layer responsible for credit balance queries, earning, spending, and purchase operations
- **Appointments_Service**: The Flutter service layer responsible for expert listing, slot management, booking, cancellation, and rescheduling
- **Peers_Service**: The Flutter service layer responsible for peer support sessions including intern listing, session lifecycle, messaging, and voice calls
- **BlackBox_Service**: The Flutter service layer responsible for journal entries, emotional entries, AI moderation, and anonymous therapy sessions
- **Quests_Service**: The Flutter service layer responsible for daily quest cards and completion tracking
- **Sound_Service**: The Flutter service layer responsible for sound therapy content listing and playback metadata
- **SelfHelp_Service**: The Flutter service layer responsible for gratitude entries, journal entries, and mood tracking
- **Notifications_Service**: The Flutter service layer responsible for fetching and managing user notifications
- **Profiles_Service**: The Flutter service layer responsible for profile retrieval, updates, student ID verification, and emergency contacts
- **VideoSDK_Service**: The Flutter service layer responsible for generating video call tokens and creating rooms
- **Provider**: The state management solution used in the Flutter app (ChangeNotifier pattern)
- **Backend**: The Express.js server running on port 3001 with all routes under the `/api` prefix, deployed at `eternia-ef-prisma.onrender.com`
- **Token_Expired_Code**: The error code `TOKEN_EXPIRED` returned by the Backend in a 401 response when the Access_Token has expired

## Requirements

### Requirement 1: Environment Configuration

**User Story:** As a developer, I want environment-specific configuration for API base URLs, so that the app works across local development, staging, and production without code changes.

#### Acceptance Criteria

1. THE Environment_Config SHALL provide distinct base URL values for development, staging, and production environments, where each environment maps to exactly one URL value
2. IF no override is specified via `--dart-define`, THEN THE Environment_Config SHALL default to the production URL `https://eternia-ef-prisma.onrender.com/api`
3. WHEN a developer specifies a base URL override via `--dart-define` at compile time, THE Environment_Config SHALL use the provided URL value, provided it is a well-formed HTTP or HTTPS URL including scheme, host, and path
4. THE API_Client SHALL read the base URL exclusively from the Environment_Config, with no hardcoded URL strings in the API_Client source code
5. THE Environment_Config SHALL store no secrets or tokens — only non-sensitive values such as base URLs and environment identifiers
6. IF a base URL override provided via `--dart-define` is not a well-formed HTTP or HTTPS URL, THEN THE Environment_Config SHALL fall back to the production default URL and log a warning at application startup

### Requirement 2: API Client with Token Management

**User Story:** As a user, I want my session to persist seamlessly, so that I am not logged out every 15 minutes due to token expiration.

#### Acceptance Criteria

1. THE API_Client SHALL attach the stored Access_Token as a Bearer token in the Authorization header of every authenticated request
2. WHEN the Backend returns a 401 response with code `TOKEN_EXPIRED`, THE API_Client SHALL automatically attempt to refresh the Access_Token by sending a POST request to `/auth/refresh` with the stored Refresh_Token in the body as `{ refreshToken }`
3. WHEN the token refresh succeeds (HTTP 200 response containing `token` and `refreshToken` fields), THE API_Client SHALL persist the new Access_Token and Refresh_Token to secure local storage, then retry the original failed request exactly once with the new Access_Token
4. IF the token refresh fails with a non-200 response or a network error, THEN THE API_Client SHALL clear all stored tokens and Refresh_Token from secure local storage and navigate the user to the login screen
5. WHILE a token refresh request is in progress, THE API_Client SHALL enqueue all subsequent authenticated requests (up to a maximum of 50 queued requests) and replay them with the new Access_Token once the refresh succeeds, or reject them all with an authentication error if the refresh fails
6. THE API_Client SHALL set a connection timeout of 15 seconds and a receive timeout of 15 seconds for all requests
7. IF a network error or non-401 HTTP error occurs, THEN THE API_Client SHALL return a structured error object containing the HTTP status code (or 0 if unavailable), the error message string, and the backend error code field when present in the response body
8. IF the API_Client receives a 401 response without the `TOKEN_EXPIRED` code (e.g., `Invalid token` or `Authentication required`), THEN THE API_Client SHALL clear all stored tokens and navigate the user to the login screen without attempting a refresh

### Requirement 3: Secure Token Storage

**User Story:** As a user, I want my authentication tokens stored securely on my device, so that my session is protected from unauthorized access.

#### Acceptance Criteria

1. WHEN the user successfully authenticates (login, registration, or account activation), THE Auth_Service SHALL store the Access_Token under the key 'auth_token' and the Refresh_Token under the key 'refresh_token' in flutter_secure_storage
2. WHEN the user logs out, THE Auth_Service SHALL remove both the Access_Token (key: 'auth_token') and the Refresh_Token (key: 'refresh_token') from flutter_secure_storage and set the in-memory authentication state to unauthenticated
3. WHEN the app launches and a stored Access_Token is present, THE Auth_Service SHALL call `/auth/me` within 5 seconds to restore the session, and if the call succeeds, set the authentication state to authenticated with the returned user profile
4. IF the `/auth/me` call fails due to an expired or invalid Access_Token on app launch, THEN THE Auth_Service SHALL attempt a token refresh by sending the stored Refresh_Token to `/auth/refresh` before concluding the session is invalid
5. IF the token refresh attempt fails (missing Refresh_Token, expired Refresh_Token, or server error), THEN THE Auth_Service SHALL remove both stored tokens from flutter_secure_storage and set the authentication state to unauthenticated
6. IF no stored Access_Token is found on app launch, THEN THE Auth_Service SHALL set the authentication state to unauthenticated without making any network calls

### Requirement 4: Authentication Service

**User Story:** As a user, I want to register, log in, verify my account, and recover my password from the Flutter app, so that I have full account management capabilities.

#### Acceptance Criteria

1. WHEN a user submits registration data with a username and a password of at least 8 characters, THE Auth_Service SHALL send a POST request to `/auth/register` and store the returned Access_Token and Refresh_Token in secure local storage on success
2. IF the registration request returns a 409 conflict (username already taken) or a 400 validation error, THEN THE Auth_Service SHALL surface the server-provided error message to the UI without storing any tokens
3. WHEN a user submits login credentials with a non-empty username and password, THE Auth_Service SHALL send a POST request to `/auth/login` and store the returned Access_Token, Refresh_Token, user profile, and creditBalance in secure local storage on success
4. IF the login request returns a 401 (invalid credentials) or 403 (account deactivated), THEN THE Auth_Service SHALL surface the server-provided error message to the UI and clear any previously stored tokens
5. WHEN a user requests an OTP, THE Auth_Service SHALL send a POST request to `/auth/send-otp` with the user email
6. WHEN a user submits an OTP for verification, THE Auth_Service SHALL send a POST request to `/auth/verify-otp` with the email and OTP code
7. IF the OTP verification request returns a 400 error (invalid or expired OTP), THEN THE Auth_Service SHALL surface an error message indicating the OTP is invalid or expired to the UI
8. WHEN a user submits a password reset with OTP, THE Auth_Service SHALL send a POST request to `/auth/reset-password-otp` with the username, new password (at least 8 characters), and OTP
9. WHEN a user requests account activation, THE Auth_Service SHALL send a POST request to `/auth/activate-account` with the tempCredentialId, username, and password and store the returned tokens on success
10. WHEN a user logs out, THE Auth_Service SHALL send a POST request to `/auth/logout` and clear all local session data (tokens, cached user profile, creditBalance) regardless of the server response
11. WHEN the Access_Token expires or an authenticated request receives a 401 response with code TOKEN_EXPIRED, THE Auth_Service SHALL automatically send a POST request to `/auth/refresh` with the stored Refresh_Token and replace the stored Access_Token and Refresh_Token with the new values before retrying the original request
12. IF the token refresh request fails (invalid or expired Refresh_Token), THEN THE Auth_Service SHALL clear all local session data and navigate the user to the login screen
13. THE Auth_Service SHALL expose the current user profile data and creditBalance obtained from `/auth/me` to the UI layer via a Provider

### Requirement 5: Profiles Service

**User Story:** As a user, I want to view and update my profile, manage emergency contacts, and verify my student ID, so that my account information is complete and accurate.

#### Acceptance Criteria

1. WHEN the user requests their profile, THE Profiles_Service SHALL send a GET request to `/profiles/me` and return the profile object containing id, username, role, institution_id, is_active, is_verified, avatar_url, specialty, bio, total_sessions, streak_days, training_status, training_progress, created_at, student_id, last_login, and institution details
2. WHEN the user submits profile updates, THE Profiles_Service SHALL send a PATCH request to `/profiles/me` with only the changed fields from the updatable set (avatar_url, specialty, bio, training_status, training_progress) and return the updated profile object
3. WHEN the user submits a student ID for verification, THE Profiles_Service SHALL send a POST request to `/profiles/verify-student-id` with institution_id, id_type (apaar or erp), raw_id, and optionally claim_for_user_id
4. IF the student ID verification request is missing institution_id, id_type, or raw_id, THEN THE Profiles_Service SHALL display an error message indicating the missing required fields without submitting the request
5. WHEN the user updates their emergency contact, THE Profiles_Service SHALL send a PATCH request to `/profiles/emergency-contact` with emergency_name, emergency_phone, emergency_relation, and contact_is_self fields
6. WHEN the user requests SPOC QR validation, THE Profiles_Service SHALL send a POST request to `/profiles/validate-spoc-qr` with the qr_payload field containing the scanned QR data
7. IF the profile request returns a 404 status, THEN THE Profiles_Service SHALL display an error message indicating the profile was not found

### Requirement 6: Credits Service

**User Story:** As a user, I want to view my credit balance, earn credits, spend credits, and purchase credits, so that I can use the platform economy features.

#### Acceptance Criteria

1. WHEN the user requests their credit balance, THE Credits_Service SHALL send a GET request to `/credits/balance` and return the current balance as a numeric value
2. WHEN the user earns credits, THE Credits_Service SHALL send a POST request to `/credits/earn` with a body containing the amount (integer, minimum 1), notes, and reference_id
3. IF the earn request response indicates `weekly_cap_reached`, THEN THE Credits_Service SHALL notify the UI that the weekly earn cap of 5 ECC has been reached and report the capped amount actually earned
4. WHEN the user spends credits, THE Credits_Service SHALL send a POST request to `/credits/spend` with a body containing the amount (integer, 1 to 500), notes, and reference_id
5. IF the spend request returns a 402 status indicating insufficient balance, THEN THE Credits_Service SHALL notify the UI of the insufficient balance and preserve the user's current state without deducting credits
6. WHEN the user requests their transaction history, THE Credits_Service SHALL send a GET request to `/credits/transactions?limit=50` and return the list of transactions ordered by most recent first
7. WHEN the user requests their weekly earn total, THE Credits_Service SHALL send a GET request to `/credits/weekly-earn-total` and return the numeric total earned this week
8. WHEN the user initiates a credit purchase, THE Credits_Service SHALL send a POST request to `/credits/purchase/create-order` with the selected credit package (25, 60, or 130 credits) and return the Razorpay order_id and amount to the UI for payment initiation
9. WHEN the user completes a Razorpay payment, THE Credits_Service SHALL send a POST request to `/credits/purchase/verify-payment` with the razorpay_payment_id, razorpay_order_id, and razorpay_signature, and upon success update the displayed balance with the purchased credits
10. THE Credits_Service SHALL expose the current credit balance to the UI layer via a Provider that refreshes after any earn, spend, or purchase operation completes successfully

### Requirement 7: Appointments Service

**User Story:** As a user, I want to browse experts, view available slots, book appointments, and manage my bookings, so that I can access counseling services.

#### Acceptance Criteria

1. WHEN the user requests the experts list, THE Appointments_Service SHALL send a GET request to `/appointments/experts` with the user's `institution_id` as a query parameter and return the list of active experts including each expert's id, username, specialty, avatar_url, bio, and total_sessions
2. WHEN the user requests available slots for an expert, THE Appointments_Service SHALL send a GET request to `/appointments/slots` with the `expert_id` query parameter and return only future, unbooked time slots ordered by start_time ascending
3. WHEN the user books an appointment, THE Appointments_Service SHALL send a POST request to `/appointments/` with a body containing `expert_id`, `slot_id`, `slot_time`, `session_type`, and `credits_charged`, and return the created appointment with status 201
4. IF the selected slot is no longer available when the user attempts to book, THEN THE Appointments_Service SHALL display an error message indicating the slot is unavailable and not create the appointment
5. WHEN the user cancels an appointment, THE Appointments_Service SHALL send a PATCH request to `/appointments/:id/cancel` and upon success remove the appointment from the upcoming list
6. IF the user attempts to cancel an appointment that is already completed or already cancelled, THEN THE Appointments_Service SHALL display an error message indicating the appointment cannot be cancelled
7. WHEN the user reschedules an appointment, THE Appointments_Service SHALL send a PATCH request to `/appointments/:id/reschedule` with a body containing `slot_id` and `reschedule_reason`, and upon success update the appointment's displayed time to the new slot time
8. WHEN the user requests their appointment history, THE Appointments_Service SHALL send a GET request to `/appointments/` and return up to 50 past and upcoming appointments ordered by slot_time descending
9. IF a booking, cancellation, or reschedule request fails due to a network error or server error, THEN THE Appointments_Service SHALL display an error message indicating the operation failed and preserve any user-entered data

### Requirement 8: Peer Support Service

**User Story:** As a user, I want to connect with peer support interns for chat and voice sessions, so that I can receive emotional support from trained peers.

#### Acceptance Criteria

1. WHEN the user requests available interns, THE Peers_Service SHALL send a GET request to `/peers/interns` and return the list of available peer interns excluding the requesting user
2. WHEN the user requests a peer session, THE Peers_Service SHALL send a POST request to `/peers/sessions` with the body containing `intern_id` and return the created session with status "pending"
3. IF the selected intern already has an active or pending session, THEN THE Peers_Service SHALL return an error response indicating the intern is currently busy
4. WHEN an intern accepts a session, THE Peers_Service SHALL send a PATCH request to `/peers/sessions/:id/accept` with the session ID and the session status SHALL change to "active"
5. WHEN an intern declines a session, THE Peers_Service SHALL send a PATCH request to `/peers/sessions/:id/decline` with the session ID and the session status SHALL change to "completed"
6. WHEN a participant sends a message in an active session, THE Peers_Service SHALL send a POST request to `/peers/sessions/:id/messages` with the body containing `content` and return the created message
7. IF a participant attempts to send a message to a session that is not active, THEN THE Peers_Service SHALL return an error response indicating no active session was found
8. WHEN a participant ends the session, THE Peers_Service SHALL send a PATCH request to `/peers/sessions/:id/end` with the session ID and the session status SHALL change to "completed"
9. WHEN a session is flagged for concern, THE Peers_Service SHALL send a PATCH request to `/peers/sessions/:id/flag` with the body containing `escalation_note` and `justification`, and the session SHALL be marked as flagged
10. WHEN the user requests their session history, THE Peers_Service SHALL send a GET request to `/peers/sessions` and return up to 20 most recent peer sessions ordered by creation date descending
11. WHEN a participant retrieves messages for a session, THE Peers_Service SHALL send a GET request to `/peers/sessions/:id/messages` with optional query parameters `cursor` and `limit` (default 50, maximum 50) and return the messages with a `hasMore` indicator for pagination
12. WHEN a participant initiates a voice call in an active session, THE Peers_Service SHALL send a PATCH request to `/peers/sessions/:id/start-call` and return a `room_id` for the voice session

### Requirement 9: BlackBox Service

**User Story:** As a user, I want to create journal entries, access my memory archive, and use anonymous therapy sessions, so that I have private emotional expression tools.

#### Acceptance Criteria

1. WHEN the user creates a journal entry, THE BlackBox_Service SHALL send a POST request to `/blackbox/entries` with the body containing content (string, max 5000 characters), content_type (string), and is_private (boolean), and return the created entry on success
2. WHEN the user requests their entries, THE BlackBox_Service SHALL send a GET request to `/blackbox/entries` with optional cursor and limit query parameters (default limit: 30, max limit: 100), and return the list of entries along with a hasMore flag indicating whether additional entries exist
3. WHEN the user deletes an entry, THE BlackBox_Service SHALL send a DELETE request to `/blackbox/entries/:id` and return a success confirmation
4. IF the user attempts to delete an entry that does not exist or does not belong to them, THEN THE BlackBox_Service SHALL return an error indicating the entry was not found
5. WHEN the user requests an anonymous therapy session, THE BlackBox_Service SHALL send a POST request to `/blackbox/sessions` to create a new queued session or reconnect to an existing active session, and return the session object along with a reconnected flag (true if reconnected, false if newly created)
6. IF the user requests an anonymous therapy session and has already reached the daily limit of 3 sessions, THEN THE BlackBox_Service SHALL return an error indicating the daily session limit has been reached
7. WHEN the user requests their active session state, THE BlackBox_Service SHALL send a GET request to `/blackbox/sessions/active` and return the list of sessions with status queued, accepted, or active
8. IF the user attempts to create a journal entry without providing content, THEN THE BlackBox_Service SHALL return an error indicating that content is required

### Requirement 10: Quests Service

**User Story:** As a user, I want to view daily quest cards and mark them as completed, so that I can engage with gamified wellness activities.

#### Acceptance Criteria

1. WHEN the user requests daily quests, THE Quests_Service SHALL send a GET request to `/quests/` and return the list of active quest cards, where each quest contains id, title, description, xp_reward, category, and is_active fields
2. WHEN the user completes a quest, THE Quests_Service SHALL send a POST request to `/quests/complete` with the quest_id in the request body and return the completion record, the earned reward amount, and the weekly credit total
3. IF the POST to `/quests/complete` is missing the quest_id field, THEN THE Quests_Service SHALL display an error message indicating that quest_id is required
4. IF the user attempts to complete a quest they have already completed today, THEN THE Quests_Service SHALL display an error message indicating the quest was already completed today
5. IF the user attempts to complete a quest that does not exist or is inactive, THEN THE Quests_Service SHALL display an error message indicating the quest was not found
6. WHEN the user requests their completion history, THE Quests_Service SHALL send a GET request to `/quests/completions/today` and return the list of quests the user has completed today

### Requirement 11: Sound Therapy Service

**User Story:** As a user, I want to browse and access sound therapy content, so that I can use audio-based relaxation tools.

#### Acceptance Criteria

1. WHEN the authenticated user requests sound content, THE Sound_Service SHALL send a GET request to `/sound` and return the list of sound therapy tracks where `is_active` is true, ordered by play_count descending, with each track containing: id, title, artist, category, description, file_url, duration_sec, cover_emoji, is_active, and play_count
2. WHEN the user requests content by category, THE Sound_Service SHALL filter the retrieved sound tracks client-side to return only tracks whose category field matches the requested category string (case-sensitive match), and return an empty list if no tracks match
3. IF the user is not authenticated when requesting sound content, THEN THE Sound_Service SHALL not send the request and SHALL indicate to the user that authentication is required
4. IF the GET request to `/sound` fails due to a network error or returns a non-success status code, THEN THE Sound_Service SHALL display an error indication to the user and SHALL not present partial or stale track data

### Requirement 12: Self-Help Service

**User Story:** As a user, I want to track my mood, write gratitude entries, and maintain a personal journal, so that I can practice daily wellness habits.

#### Acceptance Criteria

1. WHEN the user creates a gratitude entry, THE SelfHelp_Service SHALL send a POST request to `/selfhelp/gratitude` with a body containing `entry_1` (required, max 500 characters) and optionally `entry_2` and `entry_3` (each max 500 characters), and return the created entry on a 201 response
2. IF the user submits a gratitude entry without `entry_1`, THEN THE SelfHelp_Service SHALL display an error message indicating that at least one gratitude entry is required
3. WHEN the user requests their gratitude entries, THE SelfHelp_Service SHALL send a GET request to `/selfhelp/gratitude` and return the list of up to 30 entries ordered by most recent first
4. WHEN the user creates a journal entry, THE SelfHelp_Service SHALL send a POST request to `/selfhelp/journal` with a body containing `content` (required, max 5000 characters) and optionally `title` (max 200 characters) and `mood_tag`, and return the created entry on a 201 response
5. IF the user submits a journal entry without `content`, THEN THE SelfHelp_Service SHALL display an error message indicating that journal content is required
6. WHEN the user requests their journal entries, THE SelfHelp_Service SHALL send a GET request to `/selfhelp/journal` and return the list of up to 50 entries ordered by most recent first
7. WHEN the user deletes a journal entry, THE SelfHelp_Service SHALL send a DELETE request to `/selfhelp/journal/:id` and remove the entry from the displayed list on success
8. IF the user attempts to delete a journal entry that does not exist or is not owned by the user, THEN THE SelfHelp_Service SHALL display an error message indicating the entry was not found
9. WHEN the user logs a mood entry, THE SelfHelp_Service SHALL send a POST request to `/selfhelp/mood` with a body containing `mood` (required, integer from 1 to 5) and optionally `note` (max 500 characters), and return the created entry on a 201 response
10. IF the user submits a mood entry without a mood value, THEN THE SelfHelp_Service SHALL display an error message indicating that a mood value is required
11. WHEN the user requests their mood history, THE SelfHelp_Service SHALL send a GET request to `/selfhelp/mood` and return the list of up to 30 mood entries ordered by most recent first

### Requirement 13: Notifications Service

**User Story:** As a user, I want to receive and manage notifications, so that I stay informed about appointments, sessions, and platform activity.

#### Acceptance Criteria

1. WHEN the authenticated user requests their notifications, THE Notifications_Service SHALL send a GET request to `/notifications` with an optional `limit` query parameter (default: 50, maximum: 100) and return the list of notifications sorted by `created_at` in descending order
2. WHEN the user marks a notification as read, THE Notifications_Service SHALL send a PATCH request to `/notifications/:id/read` and update the notification's `is_read` field to true
3. IF the user attempts to mark a notification as read and the notification does not exist or does not belong to the user, THEN THE Notifications_Service SHALL handle the 404 error and display a notification-not-found indication to the user
4. WHEN the user marks all notifications as read, THE Notifications_Service SHALL send a PATCH request to `/notifications/read-all` and update all unread notifications for the authenticated user to `is_read: true`
5. THE Notifications_Service SHALL expose an unread notification count to the UI layer via a Provider, computed by counting notifications where `is_read` is false from the most recently fetched notifications list
6. WHEN a notification is received, THE Notifications_Service SHALL identify the notification type as one of: peer_request, peer_accepted, peer_declined, peer_call, or escalation, and render the notification accordingly

### Requirement 14: VideoSDK Service

**User Story:** As a user, I want to join video calls for appointments and therapy sessions, so that I can have face-to-face interactions with experts and therapists.

#### Acceptance Criteria

1. WHEN an authenticated user requests a video call token, THE VideoSDK_Service SHALL send a POST request to `/videosdk/token` and return a response containing a JWT token with permissions `['allow_join', 'allow_mod']` and a 2-hour expiry
2. WHEN an authenticated user requests a new video room, THE VideoSDK_Service SHALL send a POST request to `/videosdk/room`, call the external VideoSDK API with a 10-second timeout, and return a response containing both the token and the room ID
3. IF the external VideoSDK API fails to create a room or does not respond within 10 seconds, THEN THE VideoSDK_Service SHALL return an error response indicating that room creation failed without exposing internal details
4. IF an authenticated user exceeds 10 requests per 60-second window to either VideoSDK endpoint, THEN THE VideoSDK_Service SHALL reject the request with an error response indicating the rate limit has been exceeded
5. IF the VideoSDK API credentials are not configured on the server, THEN THE VideoSDK_Service SHALL return an error response indicating a server configuration issue without exposing credential details

### Requirement 15: Error Handling and Loading States

**User Story:** As a user, I want clear feedback when operations are loading or when errors occur, so that I understand the app state and can take corrective action.

#### Acceptance Criteria

1. WHILE a network request is in progress, THE API_Client SHALL expose a loading state as a boolean property that the UI layer can observe via the Provider's `isLoading` getter, set to `true` before the request begins and `false` after the request completes or fails
2. IF a network request fails with a server error (HTTP 5xx), THEN THE API_Client SHALL return an error message indicating a server-side issue without exposing internal error details, stack traces, or raw exception messages
3. IF a network request fails due to no internet connectivity (DioException with type connectionError), THEN THE API_Client SHALL return a distinct error type that the UI can programmatically distinguish from server errors and validation errors
4. IF a network request fails with a validation error (HTTP 4xx), THEN THE API_Client SHALL extract and return the error string from the Backend response body's `error` field
5. WHEN a service operation fails, THE corresponding Provider SHALL set a `String?` error property observable by the UI layer, call `notifyListeners()`, and continue normal execution without throwing an unhandled exception
6. IF a network request exceeds the configured timeout duration (15 seconds for connect or receive), THEN THE API_Client SHALL return a distinct timeout error that the UI can programmatically distinguish from connectivity errors and server errors
7. WHEN a Provider operation completes with either success or failure, THE Provider SHALL reset its error property to null before beginning the next operation so that stale errors are not displayed to the user
8. IF a network request fails with a conflict error (HTTP 409), THEN THE API_Client SHALL return the error message from the Backend response indicating the resource already exists

### Requirement 16: State Management Architecture

**User Story:** As a developer, I want a consistent state management pattern across all service modules, so that the codebase is maintainable and predictable.

#### Acceptance Criteria

1. THE application SHALL use the Provider pattern (ChangeNotifier) for all module-level state management, with one Provider per module for each of the following: CreditsProvider, AppointmentsProvider, PeersProvider, BlackBoxProvider, QuestsProvider, SoundProvider, SelfHelpProvider, NotificationsProvider, and ProfilesProvider
2. WHEN a Provider is created for a module, THE Provider SHALL expose an `isLoading` boolean property, a nullable `error` string property, and module-specific data getter properties, all accessible via public getters that trigger UI rebuilds through notifyListeners()
3. THE application SHALL register all Providers (ThemeProvider, AuthProvider, CreditsProvider, AppointmentsProvider, PeersProvider, BlackBoxProvider, QuestsProvider, SoundProvider, SelfHelpProvider, NotificationsProvider, and ProfilesProvider) at the app root level using MultiProvider in main.dart
4. WHEN a user navigates to a module screen, THE corresponding Provider SHALL fetch fresh data from the Backend if no cached data exists or if the cached data was last fetched more than 5 minutes ago
5. IF a Provider's data fetch from the Backend fails, THEN THE Provider SHALL set isLoading to false, set the error property to a non-null string describing the failure reason, preserve any previously cached data, and call notifyListeners()
6. THE application SHALL preserve existing UI screens, layouts, themes, navigation, and animations without modification
