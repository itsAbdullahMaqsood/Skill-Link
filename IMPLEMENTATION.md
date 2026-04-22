# Skill Chain – Implementation Documentation

This document describes how the Skill Chain Flutter app is implemented: architecture, authentication, API layer, screens, and features.

---

## 1. Project Overview

- **Package name:** `skillchain`
- **SDK:** Dart ^3.9.1
- **Backend base URL:** `http://13.50.109.48:3001`
- **Main dependencies:** Flutter, Dio, flutter_secure_storage, flutter_svg, dropdown_search, image_picker, geolocator, path_provider, file_picker, intl, shared_preferences

The app is a skill-exchange platform: users sign up, log in, browse recommendations, manage offers, use an in-app "timecoin" balance, and chat. Authentication uses access + refresh tokens with silent refresh and secure storage.

### 1.1 Architecture: The project follows Clean Architecture principles, with clear separation between Presentation (UI), Domain (models & core logic), and Data (services, network, storage) layers.

---

## 2. Application Entry & Navigation

### 2.1 `lib/main.dart`

- **`navigatorKey`:** A global `GlobalKey<NavigatorState>` is defined so the auth layer can navigate to the login screen from anywhere (e.g. after refresh fails).
- **`main()`:**
  - Creates an `AuthService` instance.
  - Calls `ApiService.configureAuth(...)` with:
    - **`getAccessToken`:** `AuthService().getAccessToken` (reads from secure storage).
    - **`refreshToken`:** `AuthService().refreshAccessToken` (POST `/users/refresh`, then updates storage and API header).
    - **`onLogoutRequired`:** Calls `AuthService().logout()` then uses `navigatorKey` to `pushAndRemoveUntil` the `LoginScreen` and clear the stack.
  - Runs `runApp(const MyApp())`.
- **`MyApp`:**
  - `MaterialApp` with `navigatorKey`, `home: SplashScreen()`, and a **named route** `'/login'` → `LoginScreen`. The `/login` route is used after password reset so the reset screen does not import the login page (avoids circular imports).

---

## 3. Core Network Layer

### 3.1 `lib/services/api_service.dart`

- **Single shared Dio:** A static `_sharedDio` is lazily created on first use. Every `ApiService()` instance uses this same Dio, so all HTTP traffic goes through one client and one interceptor chain.
- **Base configuration:**
  - `baseUrl`: `http://13.50.109.48:3001`
  - Timeouts: 30s connect/receive.
  - Default headers: `Content-Type: application/json`, `Accept: application/json`.
- **Interceptor:** One `AuthInterceptor(dio: dio)` is added to the shared Dio (see below).
- **SSL:** In development, `badCertificateCallback` accepts all certificates (must be removed or tightened in production).
- **Methods:** `get`, `post`, `put`, `delete` (and `postMultipart` for file uploads). They all rethrow errors.
- **`setAuthToken(String? token)`:** Sets or removes the `Authorization: Bearer <token>` header on the shared Dio. Used after login/refresh and on logout.

### 3.2 `lib/core/network/auth_interceptor.dart`

- **Role:** Add the access token to outgoing requests and, on 401, try to refresh once and retry; on refresh failure, trigger logout and redirect to login.
- **`AuthInterceptorCallbacks`:**
  - `getAccessToken`: returns current access token (from storage).
  - `refreshToken`: performs refresh and returns new access token (or throws).
  - `onLogoutRequired`: clear session and redirect to login (invoked when refresh fails).
- **Request handling (`onRequest`):**
  - If callbacks are not configured, the request is sent as-is.
  - **Public endpoints** (no `Authorization` header): any path containing one of:
    - `/users/refresh`, `/users/login`, `/users/signup`, `/users/verify-email`, `/users/verify-otp-signup`, `/users/forgot-password`, `/users/verify-otp`, `/users/reset-password`
  - For all other paths, the interceptor calls `getAccessToken()` and, if non-empty, sets `Authorization: Bearer <token>`.
- **Error handling (`onError`):**
  - If status is not 401, or callbacks are null, or the request is to a public endpoint above → forward the error.
  - If the request was already retried (`requestOptions.extra['_auth_retried'] == true`) → forward the error (prevents infinite retry).
  - Otherwise:
    - A single in-flight refresh is shared: `_refreshFuture ??= refreshToken()`; all concurrent 401s wait on the same future.
    - On refresh success: set `_auth_retried` on the request, get the new token, and retry the **same** request with `dio.fetch(options)`; then resolve the handler with the new response.
    - On refresh failure: clear the future, call `onLogoutRequired()`, then forward the original error.
  - Tokens are never logged; only one refresh runs at a time.

### 3.3 `lib/core/network/api_exception.dart`

- **`ApiException`:** Holds `message`, optional `statusCode`, and optional `error`. Used by `LoginApiService` and `SignupApiService` so the UI can show a single, consistent error message (e.g. from backend `message`).

---

## 4. Authentication & Token Storage

### 4.1 `lib/services/auth_service.dart`

- Uses the shared `ApiService()` and `FlutterSecureStorage` for tokens and user data.
- **Storage keys:** `access_token`, `refresh_token`, `user_data`.
- **Signup:** Builds a signup payload (fullName, email, password, bio, age, gender, location, phoneNumber, education, offeringSkills, learningSkills, pastExperience, portfolioLink, etc.) and POSTs to `/users/signup`. Returns a map with `success` and `user` or `message`; handles timeouts, connection errors, 409, 400, and other Dio errors with user-facing messages.
- **Login:** POSTs to `/users/login` with email and password. On 200, writes access token, refresh token, and user JSON to secure storage and calls `_apiService.setAuthToken(accessToken)`. Returns success map or error message; handles 401 as "Invalid email or password" and other errors similarly.
- **Logout:** Deletes all three keys from storage and calls `setAuthToken(null)`.
- **`isLoggedIn()`:** True if `access_token` exists and is non-empty.
- **`getAccessToken()` / `getRefreshToken()`:** Read from secure storage.
- **`persistAuthTokens` / `persistAuthFromLogin`:** Write tokens (and optionally user JSON) and set the API auth header. Used after login or signup completion.
- **`initializeAuth()`:** On app start, reads the stored access token and calls `setAuthToken(token)` so the shared Dio is ready for authenticated requests.
- **`getStoredUserData()`:** Reads and decodes the stored `user_data` JSON.
- **`refreshAccessToken()`:** Reads refresh token from storage; if missing, calls `logout()` and throws. POSTs to `/users/refresh` with `{ "refreshToken": refresh }`. On success, writes the new access token, calls `setAuthToken(newAccess)`, and returns it. On any failure (DioException or invalid response), calls `logout()` and rethrows. Used by the auth interceptor when a 401 is received.

### 4.2 `lib/core/storage/token_storage.dart`

- **`TokenStorage`:** Wraps `FlutterSecureStorage` for auth and signup tokens.
- Methods: `saveAuthTokens`, `getAccessToken`, `getRefreshToken`, `saveTempSignupToken`, `getTempSignupToken`, `clearTempSignupToken`, `clearAll`. Used by the signup flow to hold the temporary token between OTP verification and the final profile signup; it is **not** used for the password-reset `resetToken` (that is passed in memory only).

---

## 5. Login Flow

### 5.1 `lib/services/login_api_service.dart`

- Uses the shared `ApiService` (or an injected instance).
- **`login(email, password)`:** POST `/users/login` with `LoginRequest` JSON. On success, parses response with `LoginSuccessResponse.fromJson` (user, accessToken, refreshToken). On `DioException`, converts to `ApiException` using backend `message` and throws.

### 5.2 `lib/models/login_models.dart`

- **`LoginRequest`:** email, password; `toJson()` for the request body.
- **`LoginSuccessResponse`:** user (Map), accessToken, refreshToken; `fromJson()` from the login response.

### 5.3 `lib/Pages/login/login_page.dart`

- **UI:** Email and password fields, "Forgot password? Reset it here" button, "Remember me" checkbox, Sign In button. Uses the same visual style as the rest of the app (blue header, white card).
- **Behavior:**
  - On Sign In: validates form, calls `LoginApiService().login()`, then `AuthService().persistAuthFromLogin(response)`, then `Navigator.pushReplacement` to `HomeShell`. Errors are caught as `ApiException` and shown as `_errorMessage` (or a generic message).
  - "Forgot password?" → `Navigator.push` to `ForgotPasswordScreen` (no replacement, so back from forgot-password returns to login).

---

## 6. Forgot Password Flow

### 6.1 `lib/services/password_service.dart`

- Uses the shared `ApiService`. All three endpoints are public (no auth header; see auth interceptor).
- **`forgotPassword(email)`:** POST `/users/forgot-password` with `{ "email": email }`. Throws `Exception(backend message)` on `DioException`.
- **`verifyOtp(email, otp)`:** POST `/users/verify-otp` with email and otp. Expects response to contain `resetToken`; returns that string. Does **not** store it. Throws on error or missing token.
- **`resetPassword(token, password)`:** POST `/users/reset-password` with `{ "token": token, "password": password }`. Throws on `DioException`. The token is the one-time token from verify OTP, passed only in memory.

### 6.2 Screens (under `lib/Pages/forgot password/`)

- **ForgotPasswordScreen:** Email field, "Send OTP" button. On success: SnackBar "OTP sent to … Check your inbox and spam folder.", then `Navigator.push` to `VerifyOtpScreen(email)`. On error: SnackBar with backend message. Loading state disables the button and shows a progress indicator.
- **VerifyOtpScreen(email):** 6-digit OTP field, "Verify OTP" and "Resend OTP". Verify calls `PasswordService.verifyOtp`, then `Navigator.push` to `ResetPasswordScreen(resetToken)`. Resend calls `forgotPassword(widget.email)` and shows a SnackBar. No token is stored.
- **ResetPasswordScreen(resetToken):** New password and confirm password (min 6 chars, must match). On success: SnackBar "Password reset successfully", then `Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false)` so the stack is cleared and only the login screen remains. The named route avoids importing the login page from the reset screen and prevents circular imports.

**Flow:** Login → Forgot Password? → Enter email → Send OTP → Enter OTP → Enter new password → Redirect to Login → User can log in with the new password.

---

## 7. Signup Flow

### 7.1 `lib/services/signup_api_service.dart`

- Uses shared `ApiService`. All methods throw `ApiException` with backend `message`.
- **`verifyEmail(email)`:** POST `/users/verify-email` with `VerifyEmailRequest`. Returns `VerifyEmailResponse` (e.g. message).
- **`verifyOtpSignup(email, otp)`:** POST `/users/verify-otp-signup` with email and otp. Returns `VerifyOtpSignupResponse` (message, token, expiresIn). The token is a temporary signup token.
- **`signup(...)`:** POST `/users/signup` as **multipart/form-data** with token, email, password, fullName, phoneNumber, age, gender, location, offeringSkills, learningSkills, and optional education, pastExperience, profilePic, portfolio. Uses `ApiService().postMultipart`. Returns `SignupSuccessResponse` (user, accessToken, refreshToken).

### 7.2 `lib/models/signup_models.dart`

- **VerifyEmailRequest/Response**, **VerifyOtpSignupRequest/Response**, **SignupSuccessResponse** for the three steps.
- **SkillItem:** id, name (e.g. for skills dropdown from backend).

### 7.3 Screens (under `lib/Pages/signup/`)

- **SignupEmailPage:** Enter email → `verifyEmail` → on success, `pushReplacement` to **SignupOtpPage(email)**.
- **SignupOtpPage(email):** Enter OTP → `verifyOtpSignup` → save token with `TokenStorage.saveTempSignupToken(res.token)` → `pushReplacement` to **SignupProfilePage(email, tempToken)**.
- **SignupProfilePage(email, tempToken):** Full profile form (name, password, phone, age, gender, location, skills, education, experience, profile pic, portfolio, etc.). Uses `TokenStorage` for the temp token; loads skills via API. On submit, calls `SignupApiService().signup(...)` with the temp token and files. On success, saves tokens with `AuthService().persistAuthFromLogin(...)` (or equivalent), clears temp token, then navigates to **HomeShell**.

---

## 8. Splash & Initial Routing

### 8.1 `lib/Pages/splash_screen.dart`

- Shows logo (SVG), "Skill Chain", "Seamless Skill Exchange", and a loading indicator. Uses a short scale animation.
- After a 3-second delay: calls `AuthService().initializeAuth()` (restore access token on the shared Dio), then `AuthService().isLoggedIn()`. If logged in → `Navigator.pushReplacement` to **HomeShell**; otherwise → **LoginScreen**. So returning users with valid tokens skip login.

---

## 9. Home & Main Features

### 9.1 `lib/Pages/home/` (Home Shell, Home Body, New Offer)

- **HomeShell** (`home_shell.dart`): Main scaffold with bottom navigation (Home, Chat, New Offer, Offers, Profile), app bar with search, drawer. Hosts **HomeBodyScreen**, **ChatInboxScreen**, **NewOfferScreen**, **MyOffersScreen**, **ProfileScreen**. Fetches skill posts from `GET /skill-posts` via **SkillPostService** with infinite-scroll pagination (`limit=10`, `offset`). Maintains feed state: `_posts`, `_isLoadingInitial`, `_isFetchingMore`, `_hasMore`, `_offset`, `_feedError`. Sorts posts: `matchesMySkills == true` first, then by `createdAt DESC`. Filters out non-active and expired posts. Supports pull-to-refresh. Search filters posts client-side by name, title, offers, needs.
- **HomeBodyScreen** (`home_body_screen.dart`): Instagram-style infinite feed. Receives `List<SkillPost>` and feed state from **HomeShell**. Uses `ScrollController` to detect near-bottom and trigger `onFetchMore`. Supports: skeleton loading, bottom loader, error state with retry, empty state, search-no-results state, pull-to-refresh via `RefreshIndicator`. Uses **RecommendationCard** widget (SkillPost extends Recommendation).
- **SkillPost** (`lib/models/skill_post.dart`): Domain entity extending **Recommendation** with additional post fields (`title`, `description`, `matchesMySkills`, `createdAt`, `expiryDate`, etc.). **SkillPostMapper** converts DTOs → domain. **PaginatedSkillPosts** wraps paginated results.
- **SkillPostDto** (`lib/models/skill_post_dto.dart`): DTO models for API response parsing: **SkillPostDto**, **RequirementDto**, **SkillRefDto**, **SkillPostUserDto**, **PaginatedSkillPostsDto**. Fully null-safe with fallback defaults.
- **NewOfferScreen** (`lib/offers/new_offer_screen.dart`): Two-step create post flow. Step 1: Asset selection (I'm offering: SKILL/TIMECOIN, I need: SKILL/TIMECOIN; TIMECOIN→TIMECOIN invalid). Step 2: Post details (title, description, expiry, conditional fields by combination). POST `/skill-posts` via **SkillPostService**. Uses **SignupApiService.getSkills()** for skill multi-select. **CreatePostState** holds persisted form state.
- **HomeDrawer** (`lib/Widgets/home_drawer.dart`): Drawer with header, stats, menu items (Home, My Offers, Timecoins, Messages, etc.), logout.
- **RecommendationCard** (`lib/Widgets/recommendation_card.dart`): Card for each recommendation (profile, offers, needs, exchange type, action buttons).

### 9.2 `lib/models/user.dart`

- **UserModel:** Rich user model (id, fullName, email, password, age, gender, location, phoneNumber, portfolioLink, verified, bio, profilePic, education, offeringSkills, pastExperience, timeCoins, subscriptionPackage, ratings, status, reviews, etc.). Includes legacy fields (username, posts, donations, connections, linkedin, github, twitter) and helpers like `displayUsername`.
- **Review:** id, reviewerId, reviewerName, reviewerProfilePic, rating, comment, timestamp.

### 9.3 `lib/models/recommendation.dart`

- **Recommendation:** id, name, profileImage, isVerified, rating, status, matchPercentage, isTopRated, offers, needs, exchangeType (skillExchange / timecoinExchange), optional timecoinCost.

### 9.4 `lib/models/exchange_type.dart`

- **ExchangeType** enum: `skillExchange`, `timecoinExchange`.

### 9.5 `lib/models/myoffer.dart`

- **Offer:** id, userId, userName, userProfilePhoto, title, description, expiryDate, timeline, exchangeType, coverImage, skillsOffering, rewardTimeCoins, skillsNeeded, status, matchPercentage, offerDetails. Used for "My Offers" and similar UIs.

### 9.6 `lib/models/timecoin.dart`

- **TimecoinTransaction:** id, type ('earned' | 'spent' | 'purchased'), amount, description, timestamp, optional relatedUserId.

### 9.7 `lib/services/timecoin_service.dart`

- **TimecoinService:** Singleton. Delegates to an internal **TimecoinServiceModel** that holds balance and a list of transactions. Methods: `getBalance()`, `getTransactions()`, `earnTimecoins`, `spendTimecoins`, `purchaseTimecoins`, `reset()`. Default balance 10; transactions are stored in memory (no backend in this implementation).

### 9.8 `lib/Pages/my_offers.dart`

- **MyOffersScreen:** Tabbed UI (e.g. "Received" / "Sent") with lists of **Offer** objects. Uses **TimecoinService** and **ExchangeType**. Sample data for received and sent offers; full UI for viewing and managing offers.

### 9.9 `lib/Pages/timecoin/timecoin_screen.dart`

- **TimecoinScreen:** Displays balance from **TimecoinService**, list of transactions, and info dialog. Stateless; reads from `TimecoinService.instance`.

### 9.10 `lib/Pages/chat/chat_inbox.dart` & `lib/Pages/chat/chat_page.dart`

- **ChatInboxScreen:** List of **ChatConversation** (id, userId, userName, userAvatar, lastMessage, lastMessageTime, isOnline, unreadCount, isMeLastSender). Sample data; navigates to a chat detail (e.g. **ChatPage**) for a conversation.

### 9.11 `lib/Pages/profile_page.dart` & `lib/Pages/edit_profile_page.dart`

- **ProfileScreen:** Shows a user profile using **UserModel** and **ProfileHeader** / other widgets from **profile_widgets.dart**. Can open edit profile. **EditProfilePage** allows updating profile fields.

### 9.12 `lib/Widgets/profile_widgets.dart`

- Reusable profile UI (e.g. **ProfileHeader**) and any shared profile components; uses **UserModel** and may navigate to **LoginScreen** (e.g. for logout or guest state).

---

## 10. Security & Conventions

- **Tokens:** Access and refresh tokens are stored only in **FlutterSecureStorage**. The password-reset one-time token is never stored; it is passed from Verify OTP to Reset Password via route arguments.
- **Auth header:** Attached only by the interceptor for non-public paths; public paths (login, signup, verify-email, verify-otp-signup, forgot-password, verify-otp, reset-password, refresh) are explicitly skipped.
- **401 handling:** Only one refresh runs at a time; failed refresh triggers logout and redirect to login. No infinite retry (single retry per request via `_auth_retried`).
- **Errors:** Backend `message` is surfaced to the user where possible; tokens and sensitive data are not logged.
- **SSL:** Development-only certificate bypass in **ApiService**; must be removed or restricted in production.

---

## 11. File & Folder Structure Summary

- **`lib/main.dart`** – Entry, auth callbacks, MaterialApp, `/login` route. Splash and login navigate to **HomeShell**.
- **`lib/core/network/`** – auth_interceptor.dart, api_exception.dart.
- **`lib/core/storage/`** – token_storage.dart.
- **`lib/services/`** – api_service.dart, auth_service.dart, login_api_service.dart, signup_api_service.dart, password_service.dart, timecoin_service.dart, skill_post_service.dart.
- **`lib/models/`** – login_models.dart, signup_models.dart, create_post_models.dart, skill_post.dart (domain entity + mapper), skill_post_dto.dart (DTOs), user.dart, recommendation.dart, myoffer.dart, timecoin.dart, exchange_type.dart.
- **`lib/Pages/`** – splash_screen.dart, home/ (home_shell.dart, home_body_screen.dart), settings/ (settings_screen.dart), login/, signup/, forgot password/, profile_page.dart, edit_profile_page.dart, timecoin/, chat/.
- **`lib/offers/`** – new_offer_screen.dart, open_offers.dart.
- **`lib/Widgets/`** – profile_widgets.dart, home_drawer.dart, recommendation_card.dart.
- **`assets/images/`** – e.g. Vector.svg (logo).
