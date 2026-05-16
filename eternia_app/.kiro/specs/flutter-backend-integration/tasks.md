# Implementation Plan: Flutter Backend Integration

## Overview

This plan implements a three-layer architecture (Core → Services → Providers) to integrate the Eternia Flutter app with the existing Express.js backend. Tasks are ordered so that foundational core components are built first, then services consume them, and finally providers wire everything to the existing UI. Each step builds incrementally on the previous, ensuring no orphaned code.

## Tasks

- [x] 1. Set up dependencies and core infrastructure
  - [x] 1.1 Add flutter_secure_storage dependency to pubspec.yaml
    - Add `flutter_secure_storage: ^9.2.4` to the dependencies section of `pubspec.yaml`
    - Run `flutter pub get` to resolve the new dependency
    - _Requirements: 3.1_

  - [x] 1.2 Create EnvConfig (`lib/core/env_config.dart`)
    - Implement static class with `baseUrl` getter reading from `String.fromEnvironment('BASE_URL')`
    - Default to `https://eternia-ef-prisma.onrender.com/api` when no override or invalid URL
    - Implement `_isValidUrl` helper checking scheme (http/https) and non-empty host
    - Implement `environment` getter reading from `String.fromEnvironment('ENV', defaultValue: 'production')`
    - Log warning via `debugPrint` when invalid override is provided
    - _Requirements: 1.1, 1.2, 1.3, 1.5, 1.6_

  - [ ]* 1.3 Write property test for EnvConfig URL validation
    - **Property 1: URL Validation and Fallback**
    - Generate arbitrary strings; verify well-formed HTTP/HTTPS URLs are accepted, all others fall back to default
    - **Validates: Requirements 1.3, 1.6**

  - [x] 1.4 Create TokenStorage (`lib/core/token_storage.dart`)
    - Implement class wrapping `FlutterSecureStorage` with constructor injection for testability
    - Implement `saveTokens({required String accessToken, required String refreshToken})`
    - Implement `getAccessToken()`, `getRefreshToken()`, `clearTokens()`
    - Use keys `'auth_token'` and `'refresh_token'`
    - _Requirements: 3.1, 3.2_

  - [ ]* 1.5 Write property test for TokenStorage round-trip
    - **Property 3: Token Storage Round-Trip**
    - For arbitrary non-empty string pairs, verify saveTokens followed by getAccessToken/getRefreshToken returns the same values
    - Use a mock FlutterSecureStorage for in-memory testing
    - **Validates: Requirements 3.1**

  - [x] 1.6 Create ApiError (`lib/core/api_error.dart`)
    - Define `ApiErrorType` enum: network, timeout, server, validation, unauthorized, unknown
    - Implement `ApiError` class with `type`, `message`, `statusCode`, `backendCode` fields
    - _Requirements: 2.7, 15.2, 15.3, 15.4, 15.6_

- [x] 2. Implement ApiClient with interceptors
  - [x] 2.1 Rewrite ApiClient (`lib/core/api_client.dart`)
    - Remove hardcoded IP address and SharedPreferences usage
    - Accept `TokenStorage` via constructor injection; optionally accept `Dio` for testing
    - Configure Dio with `EnvConfig.baseUrl`, 15s connect timeout, 15s receive timeout
    - Expose public methods: `get`, `post`, `patch`, `delete` that return `Future<Response>`
    - Add `VoidCallback? onSessionExpired` for logout navigation
    - _Requirements: 1.4, 2.1, 2.6_

  - [x] 2.2 Implement token attachment interceptor
    - In `onRequest` interceptor, read access token from `TokenStorage`
    - Attach `Authorization: Bearer <token>` header if token is non-null
    - _Requirements: 2.1_

  - [ ]* 2.3 Write property test for token attachment
    - **Property 2: Token Attachment to Requests**
    - For any non-null token string stored, verify every request includes `Authorization: Bearer <token>` header with exact value
    - **Validates: Requirements 2.1**

  - [x] 2.4 Implement token refresh and request queuing logic
    - In `onError` interceptor, detect 401 + `code: TOKEN_EXPIRED` from response body
    - If not already refreshing: set `_isRefreshing = true`, call `POST /auth/refresh` with stored refresh token
    - On refresh success: save new tokens, retry original request, replay queued requests (max 50)
    - On refresh failure: clear tokens, reject all queued requests, invoke `onSessionExpired`
    - If already refreshing: enqueue the failed request (up to 50) and wait for refresh completion
    - Handle 401 without TOKEN_EXPIRED: clear tokens and invoke `onSessionExpired` without refresh attempt
    - _Requirements: 2.2, 2.3, 2.4, 2.5, 2.8_

  - [ ]* 2.5 Write property test for request queue replay
    - **Property 4: Request Queue Replay During Refresh**
    - For N requests (1 ≤ N ≤ 50) arriving during refresh, verify all N are replayed with new token, none lost or duplicated
    - **Validates: Requirements 2.5**

  - [x] 2.6 Implement error classification in ApiClient
    - Map `DioExceptionType.connectionError` → `ApiError.network`
    - Map `DioExceptionType.connectTimeout` / `receiveTimeout` → `ApiError.timeout`
    - Map 5xx responses → `ApiError.server` with generic message (no stack traces)
    - Map 4xx responses → `ApiError.validation` with `error` field from response body
    - Map 401 non-TOKEN_EXPIRED → `ApiError.unauthorized`
    - _Requirements: 2.7, 15.2, 15.3, 15.4, 15.6_

  - [ ]* 2.7 Write property test for error classification
    - **Property 5: Error Response Classification**
    - Generate arbitrary status codes and response bodies; verify correct ApiErrorType mapping
    - Verify 5xx messages never contain stack traces; 4xx messages equal backend error field
    - **Validates: Requirements 2.7, 15.2, 15.3, 15.4, 15.6**

- [x] 3. Checkpoint - Core layer complete
  - Ensure all tests pass, ask the user if questions arise.

- [x] 4. Implement Auth Service and refactor Auth Provider
  - [x] 4.1 Create AuthService (`lib/services/auth_service.dart`)
    - Implement stateless class accepting `ApiClient`
    - Implement `login(username, password)` → POST `/auth/login`, return token + refreshToken + user + creditBalance
    - Implement `register(username, password, metadata)` → POST `/auth/register`
    - Implement `sendOtp(email)` → POST `/auth/send-otp`
    - Implement `verifyOtp(email, otp)` → POST `/auth/verify-otp`
    - Implement `resetPasswordOtp(username, newPassword, otp)` → POST `/auth/reset-password-otp`
    - Implement `activateAccount(tempCredentialId, username, password)` → POST `/auth/activate-account`
    - Implement `logout()` → POST `/auth/logout`
    - Implement `fetchMe()` → GET `/auth/me`
    - Implement `refresh(refreshToken)` → POST `/auth/refresh`
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 4.7, 4.8, 4.9, 4.10, 4.11, 4.12, 4.13_

  - [x] 4.2 Refactor AuthProvider (`lib/providers/auth_provider.dart`)
    - Replace `SharedPreferences` with `TokenStorage` for token persistence
    - Replace direct `ApiClient().dio` calls with injected `AuthService`
    - Store both access token and refresh token on login/register/activate
    - Implement session restore: on launch, check stored token → call `/auth/me` → on 401 attempt refresh → on fail clear tokens
    - Implement `onSessionExpired` callback to clear state and notify UI
    - Expose `userProfile`, `creditBalance`, `isAuthenticated`, `isLoading`, `error`
    - Implement logout: call service logout, clear tokens, clear cached state
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 4.3, 4.10, 4.13_

  - [ ]* 4.3 Write unit tests for AuthProvider
    - Test login success stores tokens and sets authenticated state
    - Test login failure sets error and remains unauthenticated
    - Test session restore with valid token
    - Test session restore with expired token triggers refresh
    - Test logout clears all state
    - _Requirements: 3.1, 3.2, 3.3, 4.3, 4.10_

- [x] 5. Implement domain service layer (part 1)
  - [x] 5.1 Create CreditsService (`lib/services/credits_service.dart`)
    - Implement: `getBalance()`, `earn(amount, notes, referenceId)`, `spend(amount, notes, referenceId)`, `getTransactions(limit)`, `getWeeklyEarnTotal()`, `createOrder(package)`, `verifyPayment(paymentId, orderId, signature)`
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 6.7, 6.8, 6.9_

  - [x] 5.2 Create AppointmentsService (`lib/services/appointments_service.dart`)
    - Implement: `getExperts(institutionId)`, `getSlots(expertId)`, `book(expertId, slotId, slotTime, sessionType, creditsCharged)`, `cancel(id)`, `reschedule(id, slotId, reason)`, `getHistory()`
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 7.6, 7.7, 7.8, 7.9_

  - [x] 5.3 Create PeersService (`lib/services/peers_service.dart`)
    - Implement: `getInterns()`, `createSession(internId)`, `acceptSession(id)`, `declineSession(id)`, `sendMessage(sessionId, content)`, `endSession(id)`, `flagSession(id, note, justification)`, `getSessions()`, `getMessages(sessionId, cursor, limit)`, `startCall(sessionId)`
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5, 8.6, 8.7, 8.8, 8.9, 8.10, 8.11, 8.12_

  - [x] 5.4 Create BlackBoxService (`lib/services/blackbox_service.dart`)
    - Implement: `createEntry(content, contentType, isPrivate)`, `getEntries(cursor, limit)`, `deleteEntry(id)`, `createSession()`, `getActiveSessions()`
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5, 9.6, 9.7, 9.8_

- [x] 6. Implement domain service layer (part 2)
  - [x] 6.1 Create QuestsService (`lib/services/quests_service.dart`)
    - Implement: `getQuests()`, `completeQuest(questId)`, `getCompletionsToday()`
    - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5, 10.6_

  - [x] 6.2 Create SoundService (`lib/services/sound_service.dart`)
    - Implement: `getTracks()`, `getTracksByCategory(category)` (client-side filter)
    - _Requirements: 11.1, 11.2, 11.3, 11.4_

  - [ ]* 6.3 Write property test for sound track category filtering
    - **Property 8: Sound Track Category Filtering**
    - For any list of tracks and any category string, verify filter returns exactly matching tracks (case-sensitive)
    - **Validates: Requirements 11.2**

  - [x] 6.4 Create SelfHelpService (`lib/services/selfhelp_service.dart`)
    - Implement: `createGratitude(entry1, entry2, entry3)`, `getGratitudeEntries()`, `createJournal(content, title, moodTag)`, `getJournalEntries()`, `deleteJournal(id)`, `logMood(mood, note)`, `getMoodHistory()`
    - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5, 12.6, 12.7, 12.8, 12.9, 12.10, 12.11_

  - [x] 6.5 Create NotificationsService (`lib/services/notifications_service.dart`)
    - Implement: `getNotifications(limit)`, `markAsRead(id)`, `markAllAsRead()`
    - Implement `getUnreadCount(notifications)` helper that counts items where `is_read == false`
    - _Requirements: 13.1, 13.2, 13.3, 13.4, 13.5, 13.6_

  - [ ]* 6.6 Write property test for unread notification count
    - **Property 9: Unread Notification Count**
    - For any list of notification maps with varying `is_read` booleans, verify count equals number where `is_read` is false
    - **Validates: Requirements 13.5**

  - [ ]* 6.7 Write property test for notification type classification
    - **Property 10: Notification Type Classification**
    - For any notification with type in {peer_request, peer_accepted, peer_declined, peer_call, escalation}, verify correct identification
    - **Validates: Requirements 13.6**

  - [x] 6.8 Create ProfilesService (`lib/services/profiles_service.dart`)
    - Implement: `getProfile()`, `updateProfile(fields)`, `verifyStudentId(institutionId, idType, rawId, claimForUserId)`, `updateEmergencyContact(name, phone, relation, contactIsSelf)`, `validateSpocQr(qrPayload)`
    - Implement client-side validation: reject `verifyStudentId` if missing required fields without network call
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7_

  - [ ]* 6.9 Write property test for profile PATCH sends only changed fields
    - **Property 6: Profile PATCH Sends Only Changed Fields**
    - For any subset of updatable fields, verify request body contains exactly those fields and no others
    - **Validates: Requirements 5.2**

  - [ ]* 6.10 Write property test for client-side validation prevents submission
    - **Property 7: Client-Side Validation Prevents Submission**
    - For any request body missing one or more of {institution_id, id_type, raw_id}, verify error returned without network call
    - **Validates: Requirements 5.4**

  - [x] 6.11 Create VideoSDKService (`lib/services/videosdk_service.dart`)
    - Implement: `getToken()`, `createRoom()`
    - _Requirements: 14.1, 14.2, 14.3, 14.4, 14.5_

- [x] 7. Checkpoint - Service layer complete
  - Ensure all tests pass, ask the user if questions arise.

- [x] 8. Implement provider layer (part 1)
  - [x] 8.1 Create CreditsProvider (`lib/providers/credits_provider.dart`)
    - Implement ChangeNotifier with `isLoading`, `error`, `balance`, `transactions`, `weeklyEarnTotal` getters
    - Implement `fetchBalance(force)` with 5-minute cache staleness check
    - Implement `earn()`, `spend()`, `fetchTransactions()`, `fetchWeeklyTotal()`, `createOrder()`, `verifyPayment()`
    - On successful earn/spend/purchase, auto-refresh balance
    - Preserve cached data on error
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 6.7, 6.8, 6.9, 6.10, 15.1, 15.5, 15.7, 16.2, 16.4, 16.5_

  - [x] 8.2 Create AppointmentsProvider (`lib/providers/appointments_provider.dart`)
    - Implement ChangeNotifier with `isLoading`, `error`, `experts`, `slots`, `appointments` getters
    - Implement `fetchExperts(institutionId)`, `fetchSlots(expertId)`, `book()`, `cancel()`, `reschedule()`, `fetchHistory()`
    - 5-minute cache for experts and history
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 7.6, 7.7, 7.8, 7.9, 15.1, 15.5, 15.7, 16.2, 16.4, 16.5_

  - [x] 8.3 Create PeersProvider (`lib/providers/peers_provider.dart`)
    - Implement ChangeNotifier with `isLoading`, `error`, `interns`, `sessions`, `messages` getters
    - Implement all session lifecycle methods delegating to PeersService
    - 5-minute cache for interns list
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5, 8.6, 8.7, 8.8, 8.9, 8.10, 8.11, 8.12, 15.1, 15.5, 15.7, 16.2, 16.4, 16.5_

  - [x] 8.4 Create BlackBoxProvider (`lib/providers/blackbox_provider.dart`)
    - Implement ChangeNotifier with `isLoading`, `error`, `entries`, `activeSessions` getters
    - Implement `createEntry()`, `fetchEntries()`, `deleteEntry()`, `createSession()`, `fetchActiveSessions()`
    - 5-minute cache for entries
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5, 9.6, 9.7, 9.8, 15.1, 15.5, 15.7, 16.2, 16.4, 16.5_

- [x] 9. Implement provider layer (part 2)
  - [x] 9.1 Create QuestsProvider (`lib/providers/quests_provider.dart`)
    - Implement ChangeNotifier with `isLoading`, `error`, `quests`, `completionsToday` getters
    - Implement `fetchQuests()`, `completeQuest(questId)`, `fetchCompletionsToday()`
    - 5-minute cache for quests list
    - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5, 10.6, 15.1, 15.5, 15.7, 16.2, 16.4, 16.5_

  - [x] 9.2 Create SoundProvider (`lib/providers/sound_provider.dart`)
    - Implement ChangeNotifier with `isLoading`, `error`, `tracks`, `filteredTracks` getters
    - Implement `fetchTracks()`, `filterByCategory(category)`
    - 5-minute cache for tracks
    - _Requirements: 11.1, 11.2, 11.3, 11.4, 15.1, 15.5, 15.7, 16.2, 16.4, 16.5_

  - [x] 9.3 Create SelfHelpProvider (`lib/providers/selfhelp_provider.dart`)
    - Implement ChangeNotifier with `isLoading`, `error`, `gratitudeEntries`, `journalEntries`, `moodHistory` getters
    - Implement all CRUD methods delegating to SelfHelpService
    - 5-minute cache per data type
    - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5, 12.6, 12.7, 12.8, 12.9, 12.10, 12.11, 15.1, 15.5, 15.7, 16.2, 16.4, 16.5_

  - [x] 9.4 Create NotificationsProvider (`lib/providers/notifications_provider.dart`)
    - Implement ChangeNotifier with `isLoading`, `error`, `notifications`, `unreadCount` getters
    - Implement `fetchNotifications()`, `markAsRead(id)`, `markAllAsRead()`
    - Compute `unreadCount` from notifications where `is_read == false`
    - 5-minute cache for notifications list
    - _Requirements: 13.1, 13.2, 13.3, 13.4, 13.5, 13.6, 15.1, 15.5, 15.7, 16.2, 16.4, 16.5_

  - [x] 9.5 Create ProfilesProvider (`lib/providers/profiles_provider.dart`)
    - Implement ChangeNotifier with `isLoading`, `error`, `profile` getters
    - Implement `fetchProfile()`, `updateProfile(fields)`, `verifyStudentId()`, `updateEmergencyContact()`, `validateSpocQr()`
    - 5-minute cache for profile
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7, 15.1, 15.5, 15.7, 16.2, 16.4, 16.5_

  - [ ]* 9.6 Write property test for cache staleness triggers fetch
    - **Property 11: Cache Staleness Triggers Fetch**
    - For any Provider with a `_lastFetched` timestamp, verify elapsed > 5 minutes triggers network request; elapsed ≤ 5 minutes returns cached data
    - **Validates: Requirements 16.4**

- [x] 10. Wire providers into main.dart
  - [x] 10.1 Update `lib/main.dart` MultiProvider registration
    - Instantiate `TokenStorage` and `ApiClient` at app startup
    - Create all service instances with shared `ApiClient`
    - Register all new providers (Credits, Appointments, Peers, BlackBox, Quests, Sound, SelfHelp, Notifications, Profiles) in MultiProvider
    - Update `AuthProvider` instantiation to accept `AuthService` and `TokenStorage`
    - Wire `ApiClient.onSessionExpired` to navigate to login screen
    - Preserve existing `ThemeProvider` and `MyApp` widget unchanged
    - _Requirements: 16.1, 16.3, 16.6_

- [x] 11. Final checkpoint - Full integration complete
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties from the design document
- Unit tests validate specific examples and edge cases
- All existing UI screens remain unchanged — only providers and core/service layers are added or modified
- The `fast_check` Dart library is used for property-based testing (per design document)

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1", "1.6"] },
    { "id": 1, "tasks": ["1.2", "1.4"] },
    { "id": 2, "tasks": ["1.3", "1.5", "2.1"] },
    { "id": 3, "tasks": ["2.2", "2.6"] },
    { "id": 4, "tasks": ["2.3", "2.4", "2.7"] },
    { "id": 5, "tasks": ["2.5", "4.1"] },
    { "id": 6, "tasks": ["4.2", "5.1", "5.2", "5.3", "5.4"] },
    { "id": 7, "tasks": ["4.3", "6.1", "6.2", "6.4", "6.5", "6.8", "6.11"] },
    { "id": 8, "tasks": ["6.3", "6.6", "6.7", "6.9", "6.10"] },
    { "id": 9, "tasks": ["8.1", "8.2", "8.3", "8.4", "9.1", "9.2", "9.3", "9.4", "9.5"] },
    { "id": 10, "tasks": ["9.6"] },
    { "id": 11, "tasks": ["10.1"] }
  ]
}
```
