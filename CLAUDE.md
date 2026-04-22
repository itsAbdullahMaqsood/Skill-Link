# CLAUDE.md — SkillChain + SkillLink FYP Documentation Brief

> **Purpose of this file.** This document is the single source of truth for Claude when drafting the official Final Year Project (FYP) documentation (OBE-based, Lahore Garrison University format) for the **SkillChain + SkillLink** merged Flutter application. It contains:
>
> 1. An exhaustive description of the project (domain, actors, features, architecture, data model, tech stack).
> 2. A chapter-by-chapter guide mapped to the official FYP template so Claude can fill each section with project-specific content.
> 3. **Detailed, diagram-by-diagram construction instructions** for every diagram the university format requires (Methodology, Gantt, Use-Case, ER, Architecture, Activity, Sequence, Data Flow, Class, Database, Entity). For each diagram Claude is told *which actors/classes/entities/flows to include*, *how to lay it out*, and *which project features to base it on*.
>
> When Claude is asked to generate any chapter, figure, or table of the documentation, it must ground every claim in this file — not in generic FYP boilerplate.

---

## 0. Document Conventions for Claude

- **Institution / template:** Department of Computer Science, Lahore Garrison University — "FYP Final Documentation (OBE Based)".
- **Chapter order (fixed):** Introduction → Literature Review → Problem Definition → SRS → Methodology → Detailed Design & Architecture → Implementation & Testing → Results & Discussion → Conclusion & Future Work → References.
- **Diagrams Claude must produce (mandated by the template):** Use Case, ER, Architectural, Activity, Sequence, Component, State Machine, Class, Data Flow, Database. This file adds Methodology and Gantt (typically in Ch. 5) and explicit Entity diagram guidance.
- **Diagramming notation:** Use UML 2.x for behavioural diagrams, Crow's-foot notation for ER/Database, C4-style layered boxes for Architecture, and Gantt bars with week granularity.
- **Style:** Formal academic tone, third person, Times New Roman body (template default). Figures captioned as `Figure X.Y: …`, tables as `Table X.Y: …`. Every figure must be referenced in body text at least once.
- **Do not invent features.** If a capability is not listed below, Claude must omit it or explicitly flag it as "future work".

---

## 1. Project Identity

| Field | Value |
|---|---|
| **Official title** | **SkillLink — A Unified Platform for Skill Exchange and Labour Services** (internal Flutter package: `skilllink`; historical names *SkillChain* (digital) + *SkillLink* (labour) merged into one app) |
| **Tagline** | *Seamless Skill Exchange* (digital side) / *Book trusted workers, on demand* (labour side) |
| **Platform** | Cross-platform mobile app — Android & iOS (also web, macOS, Linux, Windows targets present in the repo) |
| **Primary language** | Dart `^3.10.4` on Flutter |
| **Package name** | `skilllink` |
| **Version** | `1.0.0+1` |
| **Backend (digital side)** | REST API at `http://13.50.109.48:3001` (Node.js, not in this repo) |
| **Backend (labour side)** | Separate labour REST API consumed via `skillink_api_service.dart` |
| **Realtime** | `socket_io_client` for SkillChain chat; Firebase Cloud Messaging (FCM) + local notifications for push |
| **AI** | Gemini (via env-loaded API key) powering the homeowner "Home Assistant" chat |
| **Maps / Location** | Google Maps Flutter + `geolocator` + `permission_handler` + custom `directions_service` and `maps_distance_service` |

### 1.1 What the app actually does (one-paragraph abstract)

SkillLink is a unified Flutter application that fuses two complementary marketplaces into a single installable binary. The **digital side (SkillChain)** lets registered users barter professional skills with each other — a graphic designer can exchange logo work for Python tuition, for instance — with an internal virtual currency called *TimeCoin* acting as a neutral unit of value when skills are asymmetric. The **labour side (SkillLink)** is a location-aware marketplace where homeowners can post physical service jobs (plumbing, electrical, appliance repair, etc.), discover nearby verified workers, book them directly or broadcast open posts that workers bid on, then track the job, chat in real time, and settle a post-completion honesty-prompt that cross-checks what the homeowner paid against what the worker received. The labour side is further extended with an **IoT monitoring subsystem** that ingests live voltage/current/wattage readings from smart-home appliances and raises anomaly alerts that deep-link into the marketplace ("Book a technician"), and an **AI assistant** that diagnoses those anomalies in natural language and recommends a specific worker. Authentication, secure token storage, routing, push delivery, and a single shared Dio HTTP client are reused across both sides.

### 1.2 Target users

| Role | Side | Main goals |
|---|---|---|
| **Skill User** (both offerer and learner) | Digital (SkillChain) | Sign up, list offering/learning skills, browse personalised feed, send/receive offers, barter with TimeCoin, chat, build reputation |
| **Homeowner** | Labour (SkillLink) | Browse marketplace of workers, book directly **or** post an open job, negotiate via bids, chat, track live, rate, submit completion amount |
| **Skilled Worker** | Labour (SkillLink) | Get discovered, accept/counter bids, discover open jobs, navigate to job, update status, earn, submit completion amount, monitor earnings |
| **Guest / First-time visitor** | Both | Splash → Gateway ("What do you want to do?") → choose digital or labour, then Login/Signup |
| **Admin** | Out of scope for the app (platform-fee reconciliation, moderation etc. handled server-side) | — |

### 1.3 What makes the project an FYP-worthy contribution

1. **Two-sided marketplace design inside a single app** — a non-trivial routing problem solved with a `skill_type` + `labour_role` gateway backed by `go_router` redirects.
2. **Negotiation state machine** — structured ping-pong bidding (`worker` ↔ `customer`) with a terminal `bid_accepted` transition and a dual-amount honesty prompt post-completion.
3. **IoT anomaly → marketplace deep-link pipeline** — sensor data feeds an anomaly engine whose alerts propose the correct trade and open the right worker profile.
4. **AI-assisted triage** — a Gemini-powered chat takes a natural-language fault description ("my AC is tripping"), infers the trade, and recommends a scored worker.
5. **Clean Architecture** — strict presentation / domain / data split with Riverpod providers, Freezed immutable models, `go_router` declarative routing, and Dio + interceptor auth layer reused across both backends.

---

## 2. Technology Stack (authoritative list for Ch. 7 "Implementation & Testing")

Pulled verbatim from `pubspec.yaml`. Claude must not embellish.

**State management:** `flutter_riverpod ^2.6.1`, `riverpod_annotation ^2.6.1`, `riverpod_generator ^2.6.5`.
**Routing:** `go_router ^14.8.1`.
**Networking:** `dio ^5.7.0` + a custom `AuthInterceptor` + a single lazily-created shared Dio.
**Secure / local storage:** `flutter_secure_storage ^9.0.0` (tokens), `shared_preferences ^2.2.2` (skill_type, labour_role, feature flags).
**Models / serialisation:** `freezed ^3.0.0` + `freezed_annotation ^3.0.0`, `json_annotation ^4.9.0`, `json_serializable ^6.9.4`, `build_runner ^2.4.14`.
**UI assets:** `flutter_svg ^2.0.9`, `cached_network_image ^3.4.1`, `flutter_markdown ^0.7.6`, `google_fonts ^6.2.1`, `dropdown_search ^5.0.0`, `fl_chart ^0.70.2`.
**Media:** `image_picker ^1.1.2`, `flutter_image_compress ^2.3.0`, `file_picker ^8.0.0`, `record ^6.2.0` (voice notes), `audioplayers ^6.1.0`, `video_player ^2.11.1`, `path_provider ^2.1.5`.
**Location / maps:** `geolocator ^13.0.2`, `permission_handler ^11.4.0`, `google_maps_flutter ^2.12.1`.
**Auth providers:** `google_sign_in ^6.2.2`.
**Realtime + notifications:** `socket_io_client ^3.1.0`, `flutter_local_notifications ^18.0.1`, Firebase Cloud Messaging (via `fcm_service.dart`).
**Config:** `flutter_dotenv ^5.2.1` (Maps + Gemini keys).
**URL / deep-linking:** `url_launcher ^6.3.1`.
**Dev / tooling:** `flutter_lints ^6.0.0`, `flutter_launcher_icons ^0.14.4`, Dart code-gen (`build_runner`).

**Backend (not in repo):** Node.js + Express style REST API (judged from endpoint shape), Firebase Realtime Database for chat & completion reports, a separate labour service cluster, an image upload endpoint serving `/public/uploads/...`.

---

## 3. Repository Layout (`lib/` tree, simplified)

```
lib/
├── main.dart                         # Dotenv, ApiService auth wiring, Riverpod scope, MaterialApp.router
├── splash_screen.dart                # Brand splash + skill-type gateway (mosaic → whiteout → 2 cards)
├── router/
│   └── app_router.dart               # GoRouter config + redirect state machine (digital/labour/role gate)
├── config/
│   └── auth_config.dart
├── core/
│   ├── auth/                         # auth_change_notifier.dart
│   ├── network/                      # auth_interceptor.dart, api_exception.dart
│   └── storage/                      # token_storage.dart (FlutterSecureStorage wrapper)
├── services/                         # *Digital (SkillChain)* service layer
│   ├── api_service.dart              # Shared Dio, setAuthToken, postMultipart
│   ├── auth_service.dart             # Login/Signup/Refresh/Logout, secure storage
│   ├── login_api_service.dart
│   ├── signup_api_service.dart
│   ├── password_service.dart         # Forgot password → OTP → reset
│   ├── skill_post_service.dart       # /skill-posts CRUD + pagination
│   ├── timecoin_service.dart         # In-memory TimeCoin wallet (singleton)
│   ├── user_profile_service.dart
│   ├── google_sign_in_service.dart
│   ├── google_geocoding_service.dart
│   ├── skillink_api_service.dart     # Labour-side HTTP (bridges into skillink/)
│   ├── skillink_login_api_service.dart
│   └── chat/chat_service.dart        # Socket.IO realtime chat
├── models/                           # *Digital* domain + DTO models (hand-written)
│   ├── user.dart, login_models.dart, signup_models.dart
│   ├── skill_post.dart, skill_post_dto.dart (DTO + mapper + paginated wrapper)
│   ├── recommendation.dart, exchange_type.dart, myoffer.dart
│   ├── timecoin.dart, chat_models.dart
│   ├── post_bid.dart, sent_bid.dart, received_bid.dart
│   ├── ongoing_post.dart, create_post_models.dart
├── Pages/                            # *Digital* screens (imperative Navigator + some GoRouter)
│   ├── splash_screen.dart, home/, login/, signup/, forgot password/
│   ├── profile/, edit_profile_page.dart, settings/
│   ├── chat/ (inbox + thread), timecoin/
│   ├── offers/ (offer_card, received_bid_card, sent_bid_detail, accept_bid_dialog)
│   ├── post_detail/, my_posts/, bidding/, ongoing/
├── Widgets/                          # Shared digital widgets (drawer, profile, cards, user_avatar)
└── skillink/                         # *Labour* feature module — self-contained Clean-Architecture slice
    ├── routing/                      # routes.dart, notification_router.dart, fcm_binding.dart
    ├── domain/
    │   ├── models/                   # Freezed + JSON: AppUser, Worker, Job, PostedJob, PostedJobBid,
    │   │                             #   Bid, ServiceRequest (+ NegotiationOffer, AcceptedBid, Party),
    │   │                             #   OpenJobPost, Appliance, IotDevice, SensorReading, Anomaly,
    │   │                             #   ChatMessage, ChatSummary, AiMessage (+ AiSource), Review,
    │   │                             #   CompletionReport, InAppNotification, StructuredAddress,
    │   │                             #   PaymentMethod, UserRole, JobStatus/PostedJobStatus/...
    │   └── logic/                    # Pure business rules (no IO)
    ├── data/
    │   ├── repositories/             # Remote + in-memory repositories for every domain model
    │   ├── services/                 # api_service.dart (labour Dio), fcm_service, directions,
    │   │                             #   maps_distance, media_upload, local_notifications
    │   ├── mappers/                  # DTO ↔ domain
    │   ├── model/                    # Wire-level DTOs
    │   └── providers.dart            # Riverpod providers / overrides
    ├── ui/
    │   ├── core/                     # themes, shared widgets (storybook, buttons, text fields)
    │   ├── auth/                     # role_select_screen, auth_view_model
    │   ├── homeowner_home/           # dashboard + shell
    │   ├── worker_home/              # jobs, earnings, incoming, ongoing, marketplace, edit profile, shell
    │   ├── marketplace/              # marketplace_screen, worker_profile_screen
    │   ├── post_job/ + open_job_post/ (discover + detail + bid sheet + card)
    │   ├── booking/ (booking_screen, booking_success_screen)
    │   ├── service_requests/ (sent + received lists & details, negotiation offer card, bid-amount sheet)
    │   ├── worker_bids/ (my_bids_screen, bid_modal)
    │   ├── job_tracking/ (tracking_screen, live_worker_map, rate_worker, history)
    │   ├── completion_report/ (prompt_screen, VM)
    │   ├── iot_monitor/ (appliances list, appliance detail, alerts, alert detail, anomaly_visuals)
    │   ├── ai_chat/ (ai_chat_screen, VM)
    │   ├── chat/ (chat_list, chat_thread)
    │   ├── my_posts/, notifications/, profile/ (about, edit, help, profile), service_requests/
    │   └── testing/                  # storybook screen
    └── utils/                        # validators, text_format, trade_icon, result, etc.
```

**Source size (for Ch. 7 metrics):** ~286 hand-written Dart files, ~323 total including generated (`.g.dart`, `.freezed.dart`), ~69 000 LOC across all Dart files.

---

## 4. Authentication & Session Model (single-sign-on across both sides)

- Tokens (`access_token`, `refresh_token`) live only in `FlutterSecureStorage`. `user_data` JSON is cached alongside.
- `main.dart` wires `ApiService.configureAuth(AuthInterceptorCallbacks(...))` with three callbacks: `getAccessToken`, `refreshToken`, `onLogoutRequired`, plus an `attachAccessToken` predicate that skips the digital header on labour-backend calls.
- The `AuthInterceptor` (in `lib/core/network/auth_interceptor.dart`):
  - Attaches `Authorization: Bearer <token>` to every non-public request.
  - **Public paths** (explicitly un-authenticated): `/users/refresh`, `/users/login`, `/users/signup`, `/users/verify-email`, `/users/verify-otp-signup`, `/users/forgot-password`, `/users/verify-otp`, `/users/reset-password`.
  - On 401: shares a single in-flight refresh across all concurrent requests (`_refreshFuture`), retries once (`extra['_auth_retried'] = true`), and on refresh failure calls `onLogoutRequired()`.
- `go_router` `redirect` callback in `app_router.dart` is the **gatekeeper state machine**:
  1. Unauthenticated + not on an auth route → `/skill-type`.
  2. Authenticated but `skill_type` unset → `/skill-type`.
  3. `skill_type == 'digital'` → `HomeShell` (`/digital`), labour paths bounced back.
  4. `skill_type == 'labour'` + `labour_role` unset → `/role-select`.
  5. `skill_type == 'labour'` + role picked → `/homeowner/home` or `/worker/jobs` shell.
  6. Any pending completion report forces `/completion-prompt/:jobId`.
  7. Wrong-role paths are bounced to the correct role's landing.

---

## 5. Feature Catalogue (authoritative list Claude must draw all use-cases / activity flows from)

### 5.1 Digital (SkillChain) features

1. **Auth** — Email signup with OTP (`/users/verify-email` → `/users/verify-otp-signup` → multipart `/users/signup`), login, forgot-password (send OTP → verify → reset), silent-refresh, secure logout.
2. **Skill feed** — Infinite-scroll `GET /skill-posts?limit&offset` feed on `HomeShell` + `HomeBodyScreen`. Sorts `matchesMySkills == true` first, filters out expired/inactive, client-side search across name/title/offers/needs, pull-to-refresh, skeleton + empty + error states.
3. **Create offer** — Two-step `NewOfferScreen`: choose "I'm offering" × "I need" combination (SKILL↔SKILL, SKILL↔TIMECOIN, TIMECOIN↔SKILL; TIMECOIN↔TIMECOIN invalid) then fill conditional details (title, description, expiry, skill picks, timecoin cost).
4. **Offers lifecycle** — Sent / Received tabs, offer card, received-bid detail, accept-bid dialog, counter-offers, exchange type switching.
5. **My posts + post detail** — View own posts, accept an offer from another user, view incoming bids, close / expire posts.
6. **Ongoing** — Ongoing posts screen + detail screen track skills currently being exchanged (post-accept, pre-close).
7. **TimeCoin wallet** — Singleton `TimecoinService` (in-memory, 10 starter coins): earn / spend / purchase transactions, balance display, transaction list.
8. **Chat (SkillChain)** — `socket_io_client`-backed realtime chat: inbox, thread, typing indicators, unread counts.
9. **Profile** — View self + other users (`user_profile_detail_screen`), edit (avatar, bio, offering/learning skills, education, past experience, portfolio URL), ratings, reviews.
10. **Drawer + navigation** — Home, My Offers, TimeCoins, Messages, Profile, Logout, switch-to-labour.

### 5.2 Labour (SkillLink) features

1. **Role select** — After picking `labour` at the gateway, the user picks `homeowner` or `worker`.
2. **Homeowner shell** (5 bottom-nav branches) — Dashboard, Marketplace, Post Job (+), AI Assistant, Profile.
3. **Homeowner dashboard** — IoT alerts banner, quick-book by trade, discover open jobs section, sent-requests strip.
4. **Marketplace** — `MarketplaceScreen` filters by trade chip + proximity; `WorkerProfileScreen` shows bio, hourly rate, services, portfolio, reviews, verification badge, "Book Now" button.
5. **Direct booking** — `BookingScreen` (date, time-slot, address, photos, payment method, description) → `POST /request-services` → `BookingSuccessScreen`. Creates a **ServiceRequest** in state `posted`.
6. **Negotiation** — On a ServiceRequest, worker can `bid` (visiting + estimate + ETA + note) or accept; homeowner can `counter-offer` or `accept-bid`. `NegotiationOffer` entries alternate `worker` ↔ `customer`; backend enforces "accept only when latest offer is from other party".
7. **Timeline** — `ServiceRequestStatus`: `posted → worker_accepted | bid_received → bid_accepted → on_the_way → arrived → in_progress → completed | cancelled`. UI shows a stepper driven by server-returned `timeline[]`.
8. **Open job posts (broadcast)** — Homeowner posts `/open-job-posts`; any matching worker discovers it via `/open-job-posts/discover` and places a `PostedJobBid` (visiting charges, estimate, note, ETA). Homeowner picks a bid which creates a sibling `ServiceRequest` referenced by `serviceRequestId`.
9. **Live job tracking** — `JobTrackingScreen` renders `LiveWorkerMap` (Google Maps + directions polyline + live worker location). `JobHistoryScreen` lists past jobs. `RateWorkerScreen` submits a `Review`.
10. **Completion honesty prompt (Phase 14)** — `CompletionReport` at `/completion_reports/{jobId}`: both parties independently enter the final amount; the repo flags the report if the discrepancy exceeds `completionAmountDiscrepancyThreshold`. Router force-pushes this screen for any pending report.
11. **Worker shell** (5 bottom-nav branches) — Jobs, Marketplace (worker's own view), Chat, Incoming Requests, Profile (edit). Additional pushed routes: Earnings (`fl_chart`), Ongoing, Job Detail, Worker Profile Edit (skills, hourly rate, service radius, portfolio uploads, CNIC KYC).
12. **Worker earnings dashboard** — charts of recent payouts (`fl_chart`), breakdown by service type.
13. **IoT monitoring** — `Appliance` + `IotDevice` + `SensorReading` (voltage, current, wattage, timestamp). `Anomaly` objects surface in `AlertsScreen` and `AlertDetailScreen`. Each anomaly has `suggestedTrade` → one-tap "Book Technician" into Marketplace pre-filtered by that trade. `ApplianceDetailScreen` shows live gauges + historical chart + "Simulate Anomaly" button (demo hook into `remote_anomaly_repository`).
14. **AI Assistant (homeowner)** — `AiChatScreen` calls Gemini with the user's message, renders `AiMessage` (text + optional markdown + `AiSource[]` citations + a `recommendedWorker` card + `suggestedTrade`). Tapping the card opens `WorkerProfileScreen`.
15. **Realtime chat (labour)** — Firebase Realtime Database-backed thread list + thread; sockets aren't required on this side. Deep-linkable via `/chat/:chatId`. Deterministic chat id per user-pair.
16. **Notifications** — FCM push (`fcm_service`) + `flutter_local_notifications` with a single `onTap` router that inspects a `prefix:id` payload to deep-link into `postedJobDetail`, `chatThread`, or `alertDetail`.
17. **Profile + KYC** — Upload CNIC front/back for workers; admin-side verification flips `verificationStatus`. `AppUser` + `Worker` + `ServiceRequestParty` carry the full profile.

### 5.3 Cross-cutting features

- Brand splash mosaic → skill-type gateway.
- Shared Dio / auth interceptor across both backends.
- Single `ProviderScope` hosting both sides via overrides.
- Global `AuthChangeNotifier` plus Riverpod `refreshListenable` bridges auth → router redirects.
- Dev-only Storybook screen (`/dev/storybook`) for UI components.

---

## 6. Domain Model (use this for Class / ER / Database / Entity diagrams)

Grouped by side. Names and fields are the Freezed/JSON shapes actually present in `lib/skillink/domain/models/*.dart` and `lib/models/*.dart`. Claude must use these exact names in diagrams.

### 6.1 Identity & Auth
- **UserModel** (digital) — `id, fullName, email, password, age, gender, location, phoneNumber, portfolioLink, verified, bio, profilePic, education, offeringSkills[], learningSkills[], pastExperience, timeCoins, subscriptionPackage, ratings, status, reviews[]`.
- **AppUser** (labour) — `id, name, email, phone, address: StructuredAddress, role: UserRole{homeowner, worker}, avatarUrl, cnicNumber, cnicFrontUrl, cnicBackUrl, profileComplete`.
- **StructuredAddress** — `line1, line2, city, province, country, postalCode, lat, lng` (derived — see `structured_address.dart`).
- **UserRole** enum — `homeowner, worker`.

### 6.2 Digital (SkillChain) entities
- **SkillPost** — `id, userId, title, description, offers[], needs[], exchangeType, timecoinCost?, matchesMySkills, createdAt, expiryDate, status`.
- **SkillPostDto / RequirementDto / SkillRefDto / SkillPostUserDto / PaginatedSkillPostsDto** — wire-level DTOs.
- **Recommendation** — parent class of `SkillPost` used in feed card: `id, name, profileImage, isVerified, rating, status, matchPercentage, isTopRated, offers[], needs[], exchangeType, timecoinCost?`.
- **ExchangeType** enum — `skillExchange, timecoinExchange`.
- **Offer / MyOffer** — `id, userId, userName, userProfilePhoto, title, description, expiryDate, timeline, exchangeType, coverImage, skillsOffering[], rewardTimeCoins, skillsNeeded[], status, matchPercentage, offerDetails`.
- **PostBid / SentBid / ReceivedBid** — bid rows on a skill post; offered skills, timecoin amount, message, status, timestamp.
- **OngoingPost** — accepted post with both parties, progress, expected completion.
- **TimecoinTransaction** — `id, type: {earned, spent, purchased}, amount, description, timestamp, relatedUserId?`.
- **Review** (digital) — `id, reviewerId, reviewerName, reviewerProfilePic, rating, comment, timestamp`.
- **ChatConversation / ChatMessage** (digital) — inbox row + realtime message (SkillChain socket model).

### 6.3 Labour (SkillLink) entities
- **Worker** — `id, name, email, phone, skillTypes[], rating, reviewCount, verificationStatus, latitude?, longitude?, hourlyRate?, avatarUrl?, bio?, distanceKm?, portfolioUrls[], experienceYears?, serviceRadiusKm?, role, accountStatus, experienceNote?`.
- **Job** — `jobId, userId, workerId?, serviceType, status: JobStatus, scheduledDate, finalPrice?, bidHistory[]: Bid, description, photoUrls[], address: StructuredAddress, paymentMethod: PaymentMethod, paid, paidAt?, createdAt`.
- **Bid** (direct-booking negotiation row used by `Job`) — `bidId?, bidderId, amount, submittedAt, accepted`.
- **PostedJob** — `jobId, homeownerId, title, tag: JobPostTag, descriptionText?, descriptionVoiceUrl?, media[]: JobMedia{url, type: photo|voice|video, thumbnailUrl?}, location, locationLat, locationLng, status: PostedJobStatus{open, accepted, in_progress, completed, cancelled}, acceptedBidId?, acceptedWorkerId?, trackingJobId?, createdAt, acceptedAt?, homeownerDisplayName?`.
- **PostedJobBid** — `bidId, jobId, workerId?, offeredBy: PostedBidOfferedBy{worker, homeowner}, visitingCharges, jobChargesEstimate, note?, etaMinutes, submittedAt, status: PostedBidStatus{pending, accepted, rejected, counter_offered, withdrawn}`.
- **ServiceRequest** — `id, requestingUserId, requestedWorkerId, description, photos[], scheduledServiceDate (YYYY-MM-DD), timeSlot: {startTime, endTime}, serviceAddress, paymentMethod: ServiceRequestPaymentMethod, status: ServiceRequestStatus{posted, worker_accepted, bid_received, bid_accepted, on_the_way, arrived, in_progress, completed, cancelled}, cancelled, timeline[]: ServiceRequestTimelineEntry{status,label,reachedAt,isCurrent,isCompleted,isPending}, negotiationOffers[]: NegotiationOffer{sequence,actorRole,actorUserId,amount,currency,createdAt}, acceptedBid?: AcceptedBid{amount, currency, acceptedAt}, createdAt, updatedAt, assignedWorker?: ServiceRequestParty, requestingCustomer?: ServiceRequestParty`.
- **ServiceRequestParty** — embedded snapshot `{id, fullName, email, phoneNumber, profilePic, ratings, reviews, role: worker|user, services[]: {id,name}}`.
- **OpenJobPost** — `id, requestingUserId, description, photos[], scheduledServiceDate, timeSlot, serviceAddress, paymentMethod, status: OpenJobPostStatus{open_for_bids, worker_selected, awarded, cancelled, closed}, serviceRequestId?, awardedWorkerId?, awardedBidId?, bidCount?, createdAt, updatedAt`.
- **Appliance** — `id, userId, type, brand, model, iotDeviceId?`.
- **IotDevice** — `id, applianceId, status, lastSeen?`.
- **SensorReading** — `voltage, current, wattage, timestamp`.
- **Anomaly** — `id, applianceId, type, severity, detectedAt, read, message?, applianceName?, suggestedTrade?`.
- **ChatSummary / ChatMessage** (labour) — RTDB-backed chat. `ChatMessage{ messageId, chatId, senderId, type: text|image|audio, text?, imageUrl?, audioUrl?, audioDurationMs?, sentAt }`.
- **InAppNotification** — `id, userId, type, title, body, payload, read, createdAt`.
- **AiMessage** — `id, role: user|ai, content, createdAt, sources[]: AiSource{title,url}, recommendedWorker?: Worker, suggestedTrade?`.
- **Review** (labour) — `id, jobId, rating, comment?, createdAt, reviewerName?`.
- **CompletionReport** — `jobId, createdAt, homeownerAmount?, homeownerSubmittedAt?, workerAmount?, workerSubmittedAt?, flagged, flaggedReason?`.
- **PaymentMethod** enum (domain) — `cash, card, bankTransfer, digitalWallet, online`.
- **JobPostTag** enum — maintained server-side (electrical, plumbing, hvac, etc.).
- Enums: `JobStatus`, `PostedJobStatus`, `PostedBidStatus`, `PostedBidOfferedBy`, `ServiceRequestStatus`, `ServiceRequestPaymentMethod`, `OpenJobPostStatus`, `NegotiationActor`, `JobMediaType`.

### 6.4 Key relationships (Claude must preserve these cardinalities in ER / Database / Class diagrams)

- `AppUser 1 ──< 0..* PostedJob` (as homeowner), `AppUser 1 ──< 0..* PostedJobBid` (as worker), `PostedJob 1 ──< 0..* PostedJobBid`, `PostedJob 1 ──< 0..1 ServiceRequest` (when awarded).
- `AppUser 1 ──< 0..* Appliance 1 ──< 0..1 IotDevice 1 ──< 0..* SensorReading` and `Appliance 1 ──< 0..* Anomaly`.
- `ServiceRequest 1 ──< 0..* NegotiationOffer`; `ServiceRequest 1 ──< 0..1 AcceptedBid`; `ServiceRequest 1 ──< 1 CompletionReport` (created once status=completed).
- `OpenJobPost 1 ──< 0..* PostedJobBid` (bids on an open post reuse the same shape).
- `Worker 1 ──< 0..* Review`; `Job 1 ──< 0..1 Review`.
- `User 1 ──< 0..* SkillPost`; `SkillPost 1 ──< 0..* PostBid`; `SkillPost 1 ──< 0..1 OngoingPost`.
- `UserModel 1 ──< 0..* TimecoinTransaction` (wallet ledger).
- `AppUser 1 ──< 0..* ChatSummary 1 ──< 0..* ChatMessage` (Firebase RTDB path `/chats/{chatId}/messages/{messageId}`).
- `AppUser 1 ──< 0..* AiMessage` (Gemini conversation log).

---

## 7. Mapping to the FYP Template (chapter-by-chapter brief for Claude)

For every chapter below, Claude writes 400–900 words of prose unless indicated otherwise, cites sources where relevant, and inserts the figures specified.

### Ch. 1 — Introduction
- Hook with the dual problem: ordinary people waste skills they could barter; finding a trusted labourer is still word-of-mouth.
- Introduce SkillLink as the unified solution; name both sides; state the chosen platform (Flutter mobile, iOS+Android) and target audience (urban Pakistani users, starting with Lahore).
- End with report organisation paragraph summarising each subsequent chapter.

### Ch. 2 — Literature Review
Compare against: TaskRabbit, Thumbtack, Fiverr (digital), Urdubazar/OLX, ServiceMarket (labour), Uber/Bykea (location + live tracking), smart-home anomaly platforms (Sense, Neurio). Produce a **Comparison Table** with columns: *Platform, Scope, Skill Barter, TimeCoin-style Currency, Live Tracking, IoT Integration, AI Assistant, Open/Direct Booking Duality, Country Availability*. Show that no single competitor combines all four pillars (skill barter, labour market, IoT, AI).

### Ch. 3 — Problem Definition
State the 4 sub-problems:
1. Informal skill-for-skill barter has no trust, matching, or currency.
2. Labour hiring is unverified and non-transparent — no pre-visit pricing.
3. Smart-home anomalies go unnoticed until failure, and homeowners don't know which trade to call.
4. Matching a natural-language fault description to a specific verified worker is manual.
Each with a paragraph of evidence and a one-sentence thesis ("This FYP addresses …").

### Ch. 4 — Software Requirement Specification
Follow IEEE 830 style. Extract from §5 of this file:
- **Functional requirements** — one table, FR-1..FR-40, grouped by module (Auth, Digital Feed, Offers, TimeCoin, Labour Booking, Negotiation, Open Posts, Tracking, Completion, IoT, AI, Chat, Notifications, Profile/KYC).
- **Non-functional requirements** — Performance (<2s feed load on 4G, <200ms chat round-trip), Security (secure storage, silent refresh, public-path whitelist, CNIC KYC), Availability (offline splash + cached data via `cached_network_image`), Scalability (shared Dio, paginated endpoints), Usability (Material 3 theme, dark-mode-ready, accessibility via `TextScale`), Portability (iOS ≥ 13, Android min SDK 23).
- **Hardware & software** constraints.
- **Use-case descriptions** — one numbered sub-section per use case (see §8.3 below) with Primary Actor / Precondition / Trigger / Main Flow / Alternate Flow / Postcondition.

### Ch. 5 — Methodology
- Development process: **Incremental + Iterative Agile (Scrum-Lite)** — 14 tracked phases (Phase 1 Auth & Splash, P2 Digital Feed, P3 Offers, P4 Marketplace, P5 AI, P6 IoT, … P14 Completion Prompt). The codebase itself is commented with "Phase X" markers — cite them.
- Tools: Figma (design), VS Code + Cursor (IDE), Flutter SDK 3.10.4, GitHub (VCS), Postman (API probe), Firebase console, Google Cloud console (Maps + OAuth), Gemini console.
- Architecture approach: **Clean Architecture** (domain ⟂ data ⟂ presentation) + MVVM on the Riverpod side.
- **Insert Figure 5.1 — Methodology Diagram** (see §8.1).
- **Insert Figure 5.2 — Gantt Chart** (see §8.2).

### Ch. 6 — Detailed Design and Architecture
- **6.1 System Architecture** — 3-tier: Flutter Client ↔ REST Backend(s) + Firebase RTDB + Gemini + FCM + Google Maps. Explain the dual-backend reality (digital + labour) reconciled by the interceptor's `attachAccessToken` predicate.
- **6.1.1 Architecture Design Approach** — Clean Architecture, Repository pattern, Provider/DI via Riverpod, declarative routing via `go_router`, immutable models via Freezed.
- **6.1.2 Architecture Design** — **Insert Figure 6.1 — System Architecture Diagram** (§8.5). Walk through the six layers.
- **6.1.3 Subsystem Architecture** — Decompose into: Auth subsystem, Digital Feed subsystem, Labour Marketplace subsystem, Negotiation subsystem, Tracking subsystem, IoT subsystem, AI Assistant subsystem, Chat subsystem, Notifications subsystem. For each, describe components and insert component-level callouts.
- **6.2 Detailed System Design** — For each major component (e.g. `AuthInterceptor`, `SkillPostService`, `ServiceRequestRepository`, `RemoteAnomalyRepository`, `AiRepository`, `SocketioChatRepository`, `FcmBinding`, `AppRouter redirect`), fill the 10-point template (Classification, Definition, Responsibilities, Constraints, Composition, Uses/Interactions, Resources, Processing, Interface/Exports, Detailed Subsystem Design).
- **Insert every diagram from §8.3–§8.11** in this chapter.

### Ch. 7 — Implementation and Testing
- Tools & libs from §2.
- Coding conventions — `flutter_lints`, null-safety strict, Freezed immutability, repository-per-entity, feature-folder modularisation inside `lib/skillink/`.
- Build pipeline — `build_runner watch` for code-gen, `flutter_launcher_icons` for icons, `.env` for secrets.
- Testing — widget tests under `test/`, Storybook screen at `/dev/storybook`, manual E2E with Postman + Firebase Emulator for RTDB, dev-only SSL bypass flagged for removal.
- Core functionality walkthrough — pick 4 flows (Signup OTP, Direct Booking + Negotiation, Open Job Post + Bidding, IoT Anomaly → Book Technician) and narrate each with code references.

### Ch. 8 — Results and Discussion
- Per-use-case test case table (TC-1..TC-N): *ID, Use Case, Precondition, Steps, Expected, Actual, Pass/Fail*.
- Performance observations: feed pagination, silent refresh latency, map rendering FPS, FCM delivery latency.
- Screenshots of every major screen (18+ screens — see §10 below).
- Discussion of scalability (paginated endpoints, Riverpod caching), security (secure storage, refresh interceptor), and accuracy (AI trade inference, anomaly classification).

### Ch. 9 — Conclusion and Future Work
- Recap: problem → solution → evidence.
- Future work: payments escrow, in-app platform-fee ledger (currently admin-side), multi-city expansion, worker background checks API, anomaly model on-device TFLite, video-call consultation, Urdu localisation.

### References
- IEEE style, numbered, max ~20 entries. Cite Flutter docs, Riverpod docs, Dio docs, Google Maps SDK, Gemini API, Firebase RTDB, papers on two-sided marketplaces, IoT anomaly detection, and any reports cited in the Literature Review.

---

## 8. Diagram-by-Diagram Construction Manual (the core of this brief)

For each diagram Claude must: (a) pick the notation stated, (b) include **every** element listed, (c) caption with the figure number from the chapter it sits in, (d) place it in the chapter named, and (e) reference it from the body text. If diagrams are produced as code, prefer **Mermaid** or **PlantUML** syntax; if produced as images, describe them exhaustively with labelled nodes and edges.

### 8.1 Methodology Diagram (Figure 5.1, Chapter 5)

- **Notation:** Horizontal pipeline with back-edges + overlay SDLC cycle.
- **Process:** Incremental+Iterative (Agile Scrum-Lite).
- **Phases (nodes, left to right):** Requirement Gathering → Analysis → Design → Implementation → Testing → Deployment → **Feedback** (arrow curving back to Analysis).
- **Overlay lanes:** mark which FYP deliverable milestones ship in each iteration:
  - Iteration 1: Auth + Splash + Gateway.
  - Iteration 2: Digital Feed + Offers + TimeCoin.
  - Iteration 3: Labour Marketplace + Booking + Negotiation.
  - Iteration 4: Open Job Posts + Bidding + Tracking.
  - Iteration 5: IoT + Anomalies + Alerts.
  - Iteration 6: AI Assistant + Chat + Completion Prompt + Polishing.
- **Annotations:** For each phase list the artefacts produced (SRS, Class diagram, Sprint backlog, APK/IPA, Test report).
- Claude should render as Mermaid `flowchart LR` with a curved feedback edge.

### 8.2 Gantt Chart (Figure 5.2, Chapter 5)

- **Granularity:** Weeks 1–28 (a typical two-semester FYP).
- **Swim-lanes (rows):**
  1. Proposal & Literature Review — Weeks 1–3
  2. SRS & Use-Case Modelling — Weeks 3–5
  3. System Design (Arch + ER + Class) — Weeks 5–7
  4. UI/UX in Figma — Weeks 5–8
  5. Sprint 1 – Auth + Splash + Gateway — Weeks 6–9
  6. Sprint 2 – Digital Feed + Offers + TimeCoin — Weeks 9–12
  7. Sprint 3 – Labour Marketplace + Direct Booking + Negotiation — Weeks 12–16
  8. Sprint 4 – Open Job Posts + Bidding + Live Tracking — Weeks 16–19
  9. Sprint 5 – IoT Monitoring + Anomaly Pipeline — Weeks 19–22
  10. Sprint 6 – AI Assistant + Chat + Completion Prompt — Weeks 22–25
  11. Integration Testing + Bug Bash — Weeks 24–26
  12. Documentation + Viva Prep — Weeks 25–28
- **Milestones (diamonds):** Proposal Defence (W3), Mid-Evaluation (W14), Alpha Build (W19), Beta Build (W24), Final Viva (W28).
- Render as Mermaid `gantt` with `dateFormat  YYYY-MM-DD` mapped against actual academic dates; overlap sprints where they genuinely overlap.

### 8.3 Use-Case Diagram (Figure 6.2, Chapter 6)

- **Notation:** UML use-case with stick-figure actors, ovals for use cases, rectangle system boundary labelled "SkillLink (Unified App)".
- **Actors (stick figures):**
  - **Skill User** (digital side — both offerer & learner)
  - **Homeowner** (labour)
  - **Skilled Worker** (labour)
  - **Guest** (unauthenticated)
  - **System** (IoT Sensor / Gemini / FCM — drawn as secondary actors on the right)
- **Include / extend relationships:** use `«include»` for OTP verification inside Signup; use `«extend»` for "Submit Completion Amount" extending "Mark Job Completed"; use `«include»` for "Authenticate Request" inside every protected call.
- **Use cases (minimum list — Claude must include all):**
  - *Guest:* Browse Splash & Gateway, Select Skill Type, Sign Up (→ Verify OTP), Log In, Recover Password (→ Verify OTP → Reset).
  - *Skill User:* Browse Feed, Search/Filter Posts, Create Skill Post, Send Bid/Offer, Accept Offer, Manage My Posts, Manage Ongoing Exchange, Chat, View/Edit Profile, View TimeCoin Wallet, Earn/Spend/Purchase TimeCoin, View Notifications, Log Out.
  - *Homeowner:* Browse Marketplace, Filter by Trade, View Worker Profile, Book Worker Directly, Post Open Job, View/Accept Bids, Counter-Offer, Cancel Request, Track Job Live, Chat with Worker, Rate Worker, Submit Completion Amount, Manage Appliances, View Anomaly Alerts, Tap Alert → Book Technician, Ask AI Assistant, View My Posts / Sent Requests, Edit Profile, Log Out.
  - *Skilled Worker:* View Incoming Requests, Accept/Reject Request, Place Bid, Counter-Offer, Discover Open Jobs, Bid on Open Job, Start Navigation, Update Status (on_the_way/arrived/in_progress/completed), Chat, Submit Completion Amount, View Earnings, Edit Profile (incl. CNIC upload), View My Bids / Received Requests, Log Out.
  - *System (IoT Sensor):* Push Sensor Reading, Raise Anomaly.
  - *System (Gemini):* Answer AI Query, Recommend Worker.
  - *System (FCM):* Deliver Push Notification → tap routes to Job/Chat/Alert.
- Group digital use cases in one coloured cluster, labour in another, cross-cutting (auth, chat, notifications) in a third.

### 8.4 ER Diagram (Figure 6.3, Chapter 6)

- **Notation:** Chen or Crow's-foot (pick Crow's-foot, more standard for databases).
- **Entities (ovals in Chen, rectangles in Crow's-foot):** use the full list from §6.
- **Primary keys (underlined):** `UserModel.id`, `AppUser.id`, `SkillPost.id`, `Offer.id`, `PostBid.id`, `TimecoinTransaction.id`, `PostedJob.jobId`, `PostedJobBid.bidId`, `ServiceRequest.id`, `NegotiationOffer.(requestId, sequence)` composite, `OpenJobPost.id`, `Worker.id`, `Appliance.id`, `IotDevice.id`, `SensorReading.(deviceId, timestamp)` composite, `Anomaly.id`, `Review.id`, `CompletionReport.jobId`, `AiMessage.id`, `ChatMessage.messageId`.
- **Foreign keys / relationships with cardinalities:** reproduce exactly the list in §6.4. Show them as lines with crow's-foot "many" on the correct side. Mandatory/optional with `|` and `O`.
- **Weak entities:** `NegotiationOffer` (depends on `ServiceRequest`), `SensorReading` (depends on `IotDevice`), `JobMedia` (depends on `PostedJob`), `ServiceRequestTimelineEntry` (depends on `ServiceRequest`).
- **Multi-valued attributes:** `Worker.skillTypes`, `Worker.portfolioUrls`, `UserModel.offeringSkills`, `UserModel.learningSkills`, `SkillPost.offers`, `SkillPost.needs`.
- Separate the diagram into three cluster rectangles: *Digital*, *Labour*, *Shared Identity* — join them with a dotted association between `UserModel` and `AppUser` labelled `linked_by_email`.

### 8.5 Architecture Diagram (Figure 6.1, Chapter 6)

- **Notation:** C4-style layered diagram (Containers view), left-to-right.
- **Layers / nodes:**
  1. **Client (Flutter App)** rectangle containing three sub-boxes:
     - *Presentation* — `Pages/**`, `skillink/ui/**`, widgets, `splash_screen.dart`, routes.
     - *Domain* — Freezed models in `models/**` and `skillink/domain/models/**`, enums, logic helpers.
     - *Data* — `services/**` (digital) + `skillink/data/services/**` (labour) + `skillink/data/repositories/**` + `core/storage/token_storage.dart`.
     - Cross-cutting: `core/network/auth_interceptor.dart`, Riverpod `ProviderScope`, `go_router`.
  2. **SkillChain Backend (REST API, 13.50.109.48:3001)** — endpoints: `/users/*`, `/skill-posts`, `/offers`, `/skills`.
  3. **SkillLink Labour Backend (separate REST cluster)** — `/workers`, `/services`, `/request-services/**`, `/open-job-posts/**`, `/jobs/**`, `/reviews`, `/appliances`, `/iot/**`.
  4. **Firebase Realtime Database** — `/chats/**`, `/completion_reports/**`, `/notifications/**`.
  5. **Firebase Cloud Messaging (FCM)**.
  6. **Google Gemini API** (AI chat).
  7. **Google Maps Platform** (Maps SDK, Directions, Geocoding).
  8. **IoT Gateway** (simulated) pushing sensor readings + anomaly events.
- **Arrows (label each with protocol):**
  - Client ↔ SkillChain Backend: **HTTPS/JSON** via shared Dio + AuthInterceptor.
  - Client ↔ Labour Backend: **HTTPS/Multipart** (for uploads) via same Dio with `attachAccessToken` predicate.
  - Client ↔ Firebase RTDB: **WebSocket**.
  - Client ↔ FCM: **XMPP push** (one-way: FCM → Client).
  - Client ↔ Gemini: **HTTPS**.
  - Client ↔ Google Maps: **HTTPS tile + REST**.
  - Client ↔ SkillChain chat (socket): **Socket.IO** over WebSocket.
  - IoT Gateway → Labour Backend: **MQTT/HTTPS** (simulated).
- Add a small "Deployment" footnote: Android ≥ API 23, iOS ≥ 13, macOS/Web/Linux/Windows targets compiled but not primary.

### 8.6 Activity Diagram (Figure 6.4, Chapter 6 — one per key flow; produce at least three)

Claude produces **three activity diagrams**, each with swimlanes:

1. **Figure 6.4a — Signup + OTP + Login flow**
   - Lanes: *User*, *Client App*, *Backend*, *Email Service*.
   - Start → User enters email → Client calls `POST /users/verify-email` → Backend sends OTP → User enters OTP → Client calls `POST /users/verify-otp-signup` → Backend returns temp token → User fills profile (decision: photo? skills? education?) → Client multipart `POST /users/signup` → Backend returns access + refresh → Client stores tokens + user JSON → Navigates to `HomeShell` / Role Select → End. Include error branches (OTP expired, email exists, network timeout).

2. **Figure 6.4b — Homeowner direct booking + negotiation + completion**
   - Lanes: *Homeowner*, *Worker*, *Labour Backend*, *FCM*.
   - Start → Homeowner opens Marketplace → Picks Worker → Fills booking form → Client `POST /request-services` → backend state `posted` → FCM push to Worker → Worker sees Incoming → (branch) Accept / Bid.
   - Accept branch → state `worker_accepted` → on_the_way → arrived → in_progress → completed.
   - Bid branch → Worker `POST /request-services/:id/worker/bid` → Homeowner gets `bid_received` → (branch) Accept / Counter. Counter → Worker decides → loop until `bid_accepted`.
   - Post-completion: both actors triggered into `completion-prompt/:jobId` → each `POST /completion_reports/:jobId` → backend flags if discrepancy > threshold → End.

3. **Figure 6.4c — IoT Anomaly → Book Technician**
   - Lanes: *IoT Device*, *Backend*, *Client*, *Homeowner*.
   - Sensor reading published → Backend anomaly engine detects → writes `Anomaly` → FCM push → Client local-notification → Homeowner taps → Router deep-links to `/iot/alerts/:id` → Homeowner reviews → taps "Book Technician" → Marketplace pre-filtered by `suggestedTrade` → resumes booking flow → End.

Also include: **Figure 6.4d — Open Job Post lifecycle** (Homeowner posts → Workers discover → Place bids → Homeowner selects → backend creates sibling `ServiceRequest` → flow converges with 6.4b).

### 8.7 Sequence Diagram (Figure 6.5, Chapter 6 — one per critical interaction, produce at least four)

Use UML sequence with lifelines and synchronous / asynchronous arrows. Include activation bars.

1. **Figure 6.5a — Login + Silent Refresh on 401**
   - Lifelines: `LoginScreen`, `LoginApiService`, `SharedDio`, `AuthInterceptor`, `AuthService`, `SkillChainBackend`.
   - Login call (success path, then illustrate: later authenticated call → 401 → interceptor waits on single `_refreshFuture` → `POST /users/refresh` → retries original request with `_auth_retried=true`).

2. **Figure 6.5b — Post a Skill Offer (Digital side)**
   - Lifelines: `NewOfferScreen`, `SignupApiService.getSkills()`, `SkillPostService`, `SharedDio`, `SkillChainBackend`, `HomeShell`.
   - Two-step form → multipart `POST /skill-posts` → backend returns post DTO → mapper → `HomeShell` prepends to feed.

3. **Figure 6.5c — Worker Places a Bid on ServiceRequest**
   - Lifelines: `ServiceRequestRepository`, `SharedDio`, `LabourBackend`, `FCMService`, `HomeownerClient`.
   - Worker bids → backend appends `NegotiationOffer` → FCM push to homeowner → homeowner receives → reopens detail → `GET /request-services/:id` returns updated `negotiationOffers[]`.

4. **Figure 6.5d — AI Assistant recommends a Worker**
   - Lifelines: `AiChatScreen`, `RemoteAiRepository`, `GeminiAPI`, `RemoteWorkerRepository`, `LabourBackend`, `WorkerProfileScreen`.
   - User message → repository builds prompt + function schema → Gemini returns `{ answer, suggestedTrade }` → repo fetches best worker by trade + proximity → returns `AiMessage` with `recommendedWorker` → user taps card → navigate.

5. **Figure 6.5e — IoT Anomaly Deep-link** (optional fifth).

### 8.8 Data Flow Diagram (Figure 6.6, Chapter 6)

Produce **Level 0 + Level 1** DFDs (Gane-Sarson notation: rounded-rectangle processes, open-ended rectangles for data stores, stick-square external entities).

- **Level 0 — Context diagram:**
  - External entities: *User*, *Homeowner*, *Worker*, *IoT Sensor*, *Gemini*, *FCM*.
  - Single process: **0.0 SkillLink System**.
  - Data stores: *D1 Users*, *D2 Skill Posts*, *D3 Offers & Bids*, *D4 Service Requests*, *D5 Open Job Posts*, *D6 Appliances & Readings*, *D7 Anomalies*, *D8 Chats*, *D9 AI Conversations*, *D10 Completion Reports*, *D11 Reviews*, *D12 TimeCoin Ledger*.
  - Data flows labelled, e.g. `Login credentials`, `Skill post`, `Bid`, `Sensor reading`, `Anomaly alert`, `AI prompt`, `Push token`.

- **Level 1 — decompose into processes:**
  - 1.0 Authentication & Session
  - 2.0 Skill Post Feed
  - 3.0 Offer & Bid Management
  - 4.0 TimeCoin Wallet
  - 5.0 Marketplace & Worker Discovery
  - 6.0 Direct Booking & Negotiation
  - 7.0 Open Job Posting & Bidding
  - 8.0 Job Tracking & Status
  - 9.0 Completion Report
  - 10.0 IoT Ingestion & Anomaly Detection
  - 11.0 AI Assistant
  - 12.0 Realtime Chat
  - 13.0 Notifications
  - Wire each to the appropriate data stores above.

### 8.9 Class Diagram (Figure 6.7, Chapter 6)

- **Notation:** UML class diagram with attributes + methods + visibility (+public, -private, #protected).
- **Scope:** Claude produces **two** class diagrams so the figure stays legible:
  1. **Figure 6.7a — Digital domain & services** — classes: `UserModel`, `LoginRequest`, `LoginSuccessResponse`, `SignupRequest`, `SkillPost`, `SkillPostDto`, `SkillPostMapper`, `Recommendation`, `ExchangeType` (enum), `Offer`, `PostBid`, `SentBid`, `ReceivedBid`, `OngoingPost`, `TimecoinTransaction`, `TimecoinService`, `AuthService`, `LoginApiService`, `SignupApiService`, `PasswordService`, `SkillPostService`, `UserProfileService`, `ChatService`, `ApiService`, `AuthInterceptor`, `TokenStorage`. Show dependencies with arrows; inheritance `SkillPost` → `Recommendation`.
  2. **Figure 6.7b — Labour domain & repositories** — `AppUser`, `UserRole`, `StructuredAddress`, `Worker`, `PostedJob`, `JobMedia`, `PostedJobBid`, `PostedBidStatus`, `PostedBidOfferedBy`, `ServiceRequest`, `NegotiationOffer`, `AcceptedBid`, `ServiceRequestParty`, `ServiceRequestStatus`, `OpenJobPost`, `OpenJobPostStatus`, `Appliance`, `IotDevice`, `SensorReading`, `Anomaly`, `ChatMessage`, `ChatSummary`, `AiMessage`, `AiSource`, `Review`, `CompletionReport`, `InAppNotification`. Repository interfaces: `AuthRepository`, `JobRepository`, `PostedJobRepository`, `PostedJobBidRepository`, `ServiceRequestRepository`, `OpenJobPostRepository`, `WorkerRepository`, `IotRepository`, `AnomalyRepository`, `AiRepository`, `ChatRepository`, `CompletionReportRepository`. Concrete implementations: `Remote*Repository` and in-memory siblings. Show the `Worker.fromAppUser(...)` factory as a dependency arrow from `Worker` to `AppUser`.
- Methods to surface (not exhaustive — just the defining ones): on `AuthService` → `login/signup/refreshAccessToken/logout/isLoggedIn`; on `SkillPostService` → `fetchFeed/createPost`; on `ServiceRequestRepository` → `create/bid/counterOffer/acceptBid/updateStatus/cancel`; on `PostedJobBidRepository` → `place/update/withdraw/accept`; on `IotRepository` → `streamReadings/listAppliances`; on `AnomalyRepository` → `watchAnomalies/simulate/markRead`; on `AiRepository` → `sendMessage/watchHistory`.

### 8.10 Component Diagram (Figure 6.8, Chapter 6)

- **Notation:** UML component diagram with lollipops (provided interfaces) and sockets (required interfaces).
- **Components (rectangles):**
  - `AppShell` (MaterialApp.router)
  - `Router` (`GoRouter`) requires `AuthService`, `CompletionReportRepository`, `SkillPrefs`.
  - `AuthModule` (AuthService + Interceptor + TokenStorage).
  - `DigitalFeedModule` (SkillPostService + HomeShell + RecommendationCard).
  - `OfferModule` (offer_card, bid screens, TimecoinService).
  - `MarketplaceModule` (MarketplaceScreen + WorkerRepository + WorkerProfileScreen).
  - `BookingModule` (BookingScreen + ServiceRequestRepository + BookingSuccessScreen).
  - `NegotiationModule` (NegotiationOfferCard + BidAmountSheet).
  - `OpenJobPostModule` (OpenJobPostScreen + PostedJobBidRepository + DiscoverScreen).
  - `TrackingModule` (JobTrackingScreen + LiveWorkerMap + RateWorkerScreen).
  - `CompletionModule` (CompletionPromptScreen + CompletionReportRepository).
  - `IotModule` (AppliancesListScreen + AnomalyRepository + AlertsScreen).
  - `AiModule` (AiChatScreen + AiRepository).
  - `ChatModule` (ChatListScreen + ChatRepository socket + Firebase RTDB adapter + SkillChain `ChatService`).
  - `NotificationsModule` (FcmService + LocalNotificationsService + NotificationRouter).
- **Buses / shared services:** `SharedDio`, `Riverpod ProviderScope`, `EnvConfig`.
- Show lollipops like `AuthModule` provides `IAuthCallbacks` consumed by `AuthInterceptor`.

### 8.11 State Machine Diagram (Figure 6.9, Chapter 6 — produce two)

1. **Figure 6.9a — ServiceRequest lifecycle**
   - States: `posted → worker_accepted`, `posted → bid_received`, `worker_accepted → on_the_way`, `bid_received ↔ bid_received` (via counter-offer), `bid_received → bid_accepted`, `bid_accepted → on_the_way → arrived → in_progress → completed`, `* → cancelled`. Mark `completed` and `cancelled` as final states with double-circle border.
   - Transitions labelled with the triggering action: `worker.accept()`, `worker.bid(amount)`, `customer.counter(amount)`, `customer.acceptBid(bidId)`, `worker.onTheWay()`, `worker.arrived()`, `worker.start()`, `worker.complete()`, `any.cancel()`.

2. **Figure 6.9b — OpenJobPost lifecycle**
   - States: `open_for_bids → worker_selected (awarded)`, `open_for_bids → cancelled`, `worker_selected → closed`. Include guards: `[bids.isNotEmpty]` on the award transition.

Optional 6.9c: `AuthSession` states `{Guest, AwaitingOtp, AwaitingProfile, Authenticated, RefreshingToken, LoggedOut}` with transitions matching the auth flows.

### 8.12 Database Diagram (Figure 6.10, Chapter 6)

- **Notation:** Physical schema, Crow's-foot. This is the ER of §8.4 translated to tables with column types.
- **Tables (must include):**
  - `users(id PK, full_name, email UK, password_hash, phone, age, gender, location, portfolio_link, verified BOOL, bio, profile_pic, time_coins INT, subscription_package, ratings FLOAT, created_at)`
  - `user_skills(user_id FK → users.id, skill_id FK → skills.id, kind ENUM('offering','learning'))` — many-to-many.
  - `skills(id PK, name UK)`.
  - `skill_posts(id PK, user_id FK, title, description, exchange_type ENUM, timecoin_cost INT NULL, created_at, expiry_date, status)`.
  - `skill_post_requirements(post_id FK, skill_id FK, role ENUM('offers','needs'))`.
  - `offers(id PK, post_id FK, user_id FK, status, message, skills_offering JSON, reward_time_coins INT, created_at)`.
  - `post_bids(id PK, post_id FK, bidder_id FK, amount INT, message, status, created_at)`.
  - `ongoing_posts(id PK, post_id FK, accepted_offer_id FK, accepted_at)`.
  - `timecoin_transactions(id PK, user_id FK, type ENUM, amount INT, description, related_user_id FK NULL, ts)`.
  - `app_users(id PK, name, email UK, phone, role ENUM('homeowner','worker'), avatar_url, cnic_number, cnic_front_url, cnic_back_url, profile_complete BOOL, created_at)`.
  - `addresses(id PK, user_id FK, line1, line2, city, province, country, postal_code, lat, lng)`.
  - `workers(app_user_id PK FK, hourly_rate DECIMAL, rating FLOAT, review_count INT, verification_status BOOL, bio, service_radius_km FLOAT, experience_years INT, experience_note, account_status)`.
  - `worker_skills(worker_id FK, service_id FK)` — many-to-many against `services(id PK, name UK)`.
  - `worker_portfolio_urls(worker_id FK, url, position INT)`.
  - `posted_jobs(job_id PK, homeowner_id FK, title, tag, description_text, description_voice_url, location_lat, location_lng, address_id FK, status, accepted_bid_id FK NULL, accepted_worker_id FK NULL, tracking_job_id FK NULL, created_at, accepted_at)`.
  - `posted_job_media(job_id FK, url, type ENUM, thumbnail_url)`.
  - `posted_job_bids(bid_id PK, job_id FK, worker_id FK NULL, offered_by ENUM, visiting_charges DECIMAL, job_charges_estimate DECIMAL, note, eta_minutes INT, status, submitted_at)`.
  - `service_requests(id PK, requesting_user_id FK, requested_worker_id FK, description, scheduled_service_date DATE, slot_start TIME, slot_end TIME, service_address, payment_method ENUM, status, cancelled BOOL, created_at, updated_at)`.
  - `service_request_photos(request_id FK, url, position INT)`.
  - `service_request_timeline(request_id FK, status, label, reached_at, is_current BOOL, is_completed BOOL, is_pending BOOL)`.
  - `negotiation_offers(request_id FK, sequence INT, actor_role ENUM, actor_user_id FK, amount DECIMAL, currency, created_at, PK(request_id,sequence))`.
  - `accepted_bids(request_id PK FK, amount DECIMAL, currency, accepted_at)`.
  - `open_job_posts(id PK, requesting_user_id FK, description, scheduled_service_date, slot_start, slot_end, service_address, payment_method, status, service_request_id FK NULL, awarded_worker_id FK NULL, awarded_bid_id FK NULL, created_at, updated_at)`.
  - `open_job_post_photos(post_id FK, url, position)`.
  - `appliances(id PK, user_id FK, type, brand, model, iot_device_id FK NULL)`.
  - `iot_devices(id PK, appliance_id FK, status, last_seen)`.
  - `sensor_readings(device_id FK, voltage DECIMAL, current DECIMAL, wattage DECIMAL, ts TIMESTAMP, PK(device_id,ts))`.
  - `anomalies(id PK, appliance_id FK, type, severity, detected_at, read BOOL, message, appliance_name, suggested_trade)`.
  - `reviews(id PK, job_id FK, rating FLOAT, comment, created_at, reviewer_name)`.
  - `completion_reports(job_id PK, created_at, homeowner_amount DECIMAL NULL, homeowner_submitted_at NULL, worker_amount DECIMAL NULL, worker_submitted_at NULL, flagged BOOL, flagged_reason)`.
  - `chats(chat_id PK, user_a FK, user_b FK, last_message_id FK NULL, updated_at)`.
  - `chat_messages(message_id PK, chat_id FK, sender_id FK, type ENUM, text, image_url, audio_url, audio_duration_ms INT, sent_at)`.
  - `ai_messages(id PK, user_id FK, role ENUM('user','ai'), content, suggested_trade, recommended_worker_id FK NULL, created_at)`.
  - `ai_sources(ai_message_id FK, title, url, position)`.
  - `in_app_notifications(id PK, user_id FK, type, title, body, payload JSON, read BOOL, created_at)`.
- Mark indexes on hot paths: `skill_posts(user_id,status,expiry_date)`, `service_requests(requesting_user_id,status)`, `service_requests(requested_worker_id,status)`, `sensor_readings(device_id,ts DESC)`, `chat_messages(chat_id,sent_at DESC)`.
- Note which tables map to Firebase RTDB instead of SQL: `chats`, `chat_messages`, `completion_reports` — annotate them with a dotted border and the label "Firebase RTDB".

### 8.13 Entity Diagram (Figure 6.11, Chapter 6)

The template lists "Entity diagram" separately from ER. Treat it as a **conceptual domain model** (entities only, no cardinality detail, no attributes) used to orient the reader before they read the ER.

- **Top cluster — Identity:** `User`, `Homeowner`, `Worker`.
- **Digital cluster:** `SkillPost`, `Offer`, `Bid`, `OngoingPost`, `TimecoinWallet`, `TimecoinTransaction`.
- **Labour cluster:** `ServiceRequest`, `NegotiationOffer`, `AcceptedBid`, `OpenJobPost`, `PostedJobBid`, `Review`, `CompletionReport`.
- **IoT cluster:** `Appliance`, `IotDevice`, `SensorReading`, `Anomaly`.
- **Communication cluster:** `Chat`, `ChatMessage`, `AiMessage`, `Notification`.
- Connect clusters with high-level labelled bands (e.g. "Users ⟶ post ⟶ Digital Content", "Homeowners ⟶ book ⟶ Labour Flow", "Appliances ⟶ raise ⟶ Labour Flow", "AI ⟶ recommends ⟶ Workers").
- Style as a mind-map with 5 coloured rings so examiners can see the modular story at a glance.

---

## 9. Expected Screens (for Ch. 8 "Results & Discussion" screenshots)

Claude lists at least the following screenshots, each captioned with the use-case number:
1. Brand splash mosaic.
2. Skill-type gateway (digital vs labour cards).
3. Login / Signup (email → OTP → profile).
4. Forgot password → reset.
5. Digital home feed (HomeShell + HomeBodyScreen).
6. New offer creation (step 1 asset select + step 2 details).
7. My Offers — Received / Sent tabs.
8. Offer / bid detail + accept dialog.
9. TimeCoin wallet screen.
10. SkillChain chat inbox + thread.
11. Profile view + edit.
12. Role select (homeowner / worker).
13. Homeowner dashboard with IoT banner.
14. Marketplace + worker profile.
15. Booking screen + success screen.
16. ServiceRequest detail with negotiation ping-pong.
17. Open job post form + discover feed + detail + bid sheet.
18. Worker jobs shell (jobs / marketplace / chat / incoming / profile).
19. Incoming requests + accept/bid modal.
20. Live job tracking with LiveWorkerMap.
21. Rate worker screen.
22. Completion prompt screen.
23. Appliances list + appliance detail (gauges + chart + simulate anomaly).
24. Alerts list + alert detail → Book technician.
25. AI chat with recommended worker card.
26. Notifications screen.
27. Worker earnings dashboard.
28. Worker profile edit incl. CNIC upload.

---

## 10. Writing Style Cheatsheet for Claude

- Prefer active voice ("The system validates the token") over passive in prose chapters; passive is fine for SRS / test cases.
- Every acronym expanded on first use (OTP = One-Time Password, FCM = Firebase Cloud Messaging, RTDB = Realtime Database, DTO = Data Transfer Object, SRS = Software Requirements Specification, OBE = Outcome-Based Education, ETA = Estimated Time of Arrival, KYC = Know Your Customer, CNIC = Computerized National Identity Card).
- Do **not** copy-paste code into chapters 1–6. Code excerpts belong in Ch. 7 only, and should be short (≤15 lines) with a caption.
- Every figure and table introduced with "as shown in Figure X.Y" at least once.
- References in IEEE style, numbered in order of appearance, matched to in-text `[1]` citations.
- Page numbers: front-matter Roman, body Arabic starting from Chapter 1.

---

## 11. What Claude must NOT do

- Do not invent pricing tiers, premium plans, or features not in §5.
- Do not describe on-device ML models — AI is cloud-hosted Gemini. Only anomaly *detection* is (conceptually) server-side; the app does not run TFLite.
- Do not claim end-to-end encryption of chat — MVP uses Firebase RTDB security rules, not E2E.
- Do not claim blockchain — the name *SkillChain* is a product brand, not a blockchain.
- Do not describe payments as "processed by Stripe/PayPal" — the app exposes payment *methods* (cash, card, bank_transfer, digital_wallet, online) but does not actually integrate a gateway in the MVP. Flag this as future work.
- Do not treat `build/`, generated `*.g.dart` / `*.freezed.dart`, or platform folders (`android/`, `ios/`, `web/`, etc.) as hand-written source in LOC metrics.

---

## 12. Final checklist before Claude submits a chapter

- [ ] Chapter heading matches the template exactly.
- [ ] Every required figure is referenced in body text.
- [ ] Every claim maps back to a feature listed in §5 or a model listed in §6.
- [ ] Acronyms expanded on first use, included in the **List of Abbreviations** page.
- [ ] Figures/tables added to **List of Figures / List of Tables**.
- [ ] References added in IEEE order.
- [ ] No invented features, no blockchain, no real payment gateway, no on-device ML.
- [ ] Documentation tone is formal, third person, OBE-aligned.

— End of CLAUDE.md —
