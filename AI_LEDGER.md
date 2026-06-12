# AI Ledger — WTF Flutter Engineer Assessment

> All AI tool usage documented here per assessment requirements.
> Format: Prompt # | Tool | Intent | Output Snippet | Commit

---

### Prompt #1
- **Tool:** Claude (Anthropic)
- **Intent:** Generate full project scaffold, folder structure, pubspec.yaml files, token server skeleton, and root documentation files
- **Prompt:** "Generate a Flutter monorepo scaffold for a WTF Gyms assessment with guru_app and trainer_app, shared models folder, and token_server in Node.js. Include pubspec.yaml with dependencies: flutter_riverpod, hive_flutter, hmssdk_flutter, go_router, freezed, json_annotation, intl. Also scaffold README.md, AI_LEDGER.md, ARCHITECTURE.md, and DECISIONS.md per the project spec."
- **Output snippet:** Full folder tree (`shared/`, `guru_app/`, `trainer_app/`, `token_server/`), both `pubspec.yaml` files with pinned dependencies, theme files (blue for Guru, red for Trainer), go_router stubs, and Hive init boilerplate
- **Used in:** Root scaffold, both pubspec.yaml files, theme + router setup | **Commit:** [`faf050f`](https://github.com/PranjalG/WTF-gyms-test/commit/faf050f3f57c417531bfad291927637133f65a3d) — "initial project scaffold"

---

### Prompt #2
- **Tool:** Claude
- **Intent:** Generate all 5 core data models (User, Message, CallRequest, SessionLog, RoomMeta) with serialization for Hive storage
- **Prompt:** "Create Dart model classes for User, Message, CallRequest, SessionLog, and RoomMeta as per the spec — each with toMap/fromMap for Hive persistence. Keep them lightweight (no code generation) since I'm time-boxed."
- **Output snippet:** 5 model classes with typed fields matching the spec exactly (e.g. `Message { id, chatId, senderId, receiverId, text, createdAt, status }`), plus a `SeedService` to pre-populate DK and Aarav profiles on first launch
- **Used in:** `shared/models/`, `lib/services/seed_service.dart` in both apps | **Commit:** [`8d0b3b4`](https://github.com/PranjalG/WTF-gyms-test/commit/8d0b3b4bc6299a6f381664830e8dc9a1155d61a7) — "feat: scaffolding proceeds"

---

### Prompt #3
- **Tool:** Claude
- **Intent:** Build the real-time chat system — chat list, conversation screen, and ChatService
- **Prompt:** "Build a ChatService using Firestore for cross-device real-time sync, plus a ChatListScreen (unread badges, last message preview, timestamps) and a ConversationScreen with bubble UI — blue for member, red for trainer, read receipts (single/double tick), simulated typing indicator with 400-800ms delay, and quick-reply chips."
- **Output snippet:** `ChatService` with `sendMessage`, `messagesStream`, `markRead`, and `setTyping`/`typingStream` methods; `ConversationScreen` with animated message bubbles, typing indicator widget, and sticky input bar with quick replies
- **Used in:** `lib/features/chat/chat_list_screen.dart`, `lib/features/chat/conversation_screen.dart`, `lib/services/chat_service.dart` | **Commit:** [`f6724427`](https://github.com/PranjalG/WTF-gyms-test/commit/f6724427dc9043f8002bdc30793bc5c6f01f46f7) — "improved capabilities, tested chat functionality" (built on top of [`f3a33ac`](https://github.com/PranjalG/WTF-gyms-test/commit/f3a33ac5183ca67c0b8e814ea9fef0c227de43ba) — "added firebase firestore capabilities")

---

### Prompt #4
- **Tool:** Claude
- **Intent:** Integrate 100ms Flutter SDK for video calling — token server, CallService, pre-join and in-call screens
- **Prompt:** "Write a Node.js token server with a GET /token endpoint that signs a 100ms JWT for a given userId and role (member/trainer), using jsonwebtoken. Then write a Flutter CallService wrapping hmssdk_flutter that fetches this token, joins a room by roomId with the correct role, and exposes mute/video toggle, camera flip, and end call. Also build a PreJoinScreen (mic/cam preview toggles) and a CallScreen (2-tile grid, control bar, auto-write SessionLog on end)."
- **Output snippet:** `index.js` Express server signing JWTs with `access_key`, `room_id`, `user_id`, `role`; `CallService` implementing `HMSUpdateListener`/`HMSActionResultListener` with `joinRoom`, `toggleMute`, `toggleVideo`, `switchCamera`, `endCall`; `PreJoinScreen` and `CallScreen` with full control bar UI
- **Used in:** `token_server/index.js`, `lib/services/call_service.dart`, `lib/features/calls/prejoin_screen.dart`, `lib/features/calls/call_screen.dart` | **Commit:** [`4996d86`](https://github.com/PranjalG/WTF-gyms-test/commit/4996d86fea71bf562c08d4cb17ad2ee36ce5a2a5) — "adding 100ms video calling"

---

### Prompt #5
- **Tool:** Claude
- **Intent:** Build the call scheduling and approval workflow between member and trainer
- **Prompt:** "Build a scheduling flow: member picks a date (next 3 days) and 30-min time slot with a note (max 140 chars), creating a CallRequest.pending. On the trainer side, show pending requests with approve/decline actions — on approve, create RoomMeta with a generated 100ms roomId and post a system message into the chat ('Call approved for {time}'). Add conflict checking so two approved calls can't share the same slot."
- **Output snippet:** Scheduler screen with calendar + time-slot chips and 140-char note field; Requests tab with inline Approve/Decline + decline-reason modal; conflict check querying existing approved `CallRequest`s for the same `scheduledFor` before allowing approval
- **Used in:** `lib/features/schedule/`, `lib/features/requests/` | **Commit:** [`8d0b3b4`](https://github.com/PranjalG/WTF-gyms-test/commit/8d0b3b4bc6299a6f381664830e8dc9a1155d61a7) — "feat: scaffolding proceeds"

---

### Prompt #6
- **Tool:** Claude
- **Intent:** Build session logs screen with filters and post-call rating/notes sheets
- **Prompt:** "Build a SessionsScreen reading from a Hive 'sessionLogs' box, with filter chips for All / Last 7 days / This Month, sorted by latest, with a detail modal on tap. Also build the post-call bottom sheets: a 5-star rating + note for the member, and a notes + 'Mark as complete' for the trainer."
- **Output snippet:** `SessionsScreen` with `ValueListenableBuilder` on the Hive box, date-range filtering logic, empty state ('Schedule your first call'), and detail bottom sheet showing both member and trainer notes; post-call rating sheet with star selector
- **Used in:** `lib/features/sessions/sessions_screen.dart`, post-call sheets in `call_screen.dart` | **Commit:** [`4996d86`](https://github.com/PranjalG/WTF-gyms-test/commit/4996d86fea71bf562c08d4cb17ad2ee36ce5a2a5) — "adding 100ms video calling"

---

### Prompt #7
- **Tool:** Claude
- **Intent:** Build the observability layer — DevPanel overlay and structured logging
- **Prompt:** "Create a DevPanel widget that wraps the app, shown via a floating '⋮' button, displaying the last 20 structured logs tagged [CHAT]/[RTC]/[SCHEDULE]/[AUTH]. Provide a static DevPanel.log(tag, message) API I can call from anywhere in the app. Also add Snackbar error surfacing with a 'Copy error' action."
- **Output snippet:** `DevPanel` StatefulWidget with a static `log()` method and singleton instance pattern, floating overlay showing a scrollable monospace log feed; reusable error snackbar pattern with `SnackBarAction(label: 'Copy error', onPressed: ...)`
- **Used in:** `lib/shared/widgets/dev_panel.dart`, wrapped around `MaterialApp.router` in both `main.dart` files | **Commit:** [`c893e54`](https://github.com/PranjalG/WTF-gyms-test/commit/c893e54280dc79440116ee5e8838199dd20745ea) — "perfect logging for both apps done - ios and android emulator testing complete"

---

## Debugging with AI

### Debug #1
- **Tool:** Claude
- **Error pasted to AI:** `AndroidManifest.xml could not be found. ... No application found for TargetPlatform.android_arm64. Is your project missing an android/AndroidManifest.xml?`
- **AI suggested fix:** Since the project was scaffolded manually (Dart files only, no native folders), run `flutter create . --org com.wtfgyms --project-name <app_name>` inside each app directory — this generates the missing `android/`, `ios/`, etc. folders without overwriting existing `lib/` files.
- **Resolution:** Ran `flutter create .` in both `guru_app/` and `trainer_app/`, which generated the native scaffolding. Apps then built and launched successfully on both the Android device and iPhone.
- **Commit:** [`8d0b3b4`](https://github.com/PranjalG/WTF-gyms-test/commit/8d0b3b4bc6299a6f381664830e8dc9a1155d61a7) — "feat: scaffolding proceeds"

---

### Debug #2
- **Tool:** Claude
- **Error pasted to AI:** Mac on iPhone personal hotspot returning self-assigned IP `192.0.0.2` (netmask `0xffffffff`) on both `en0` and `en1` — token server unreachable from physical devices over `http://<local-ip>:3000`
- **AI suggested fix:** Initial suggestions were to toggle hotspot/WiFi reconnects to force a proper DHCP lease. When that didn't resolve it reliably, the recommended fallback was to deploy the token server to a public host (Render) so both physical devices could reach it over HTTPS regardless of local network quirks.
- **Resolution:** Deployed `token_server/` to Render and updated `TOKEN_SERVER_URL` in both apps' `.env` to the Render URL. This unblocked multi-device testing entirely and is documented as ADR #4 in `DECISIONS.md`.
- **Commit:** [`c37616c`](https://github.com/PranjalG/WTF-gyms-test/commit/c37616c6f48eb9fc9fae16161f4627bd9ada9d81) — "Update DECISIONS.md"

---

## Refactor with AI

### Refactor #1
- **Tool:** Claude
- **Intent:** Refactor `CallService` role handling from generic "member/trainer" naming to 100ms's "guest/host" role convention to match the 100ms template roles used in the dashboard project
- **Before summary:** `CallService.joinRoom` accepted `role: 'member' | 'trainer'` directly, passed straight through to the token server, which mapped them 1:1 to 100ms roles
- **After summary:** Token server and `CallService` now map `member → guest` and `trainer → host` before signing the JWT, aligning with the 100ms dashboard's default role template and making permission checks (host can end call for all; guest can only leave) work correctly out of the box
- **Commit:** [`4996d86`](https://github.com/PranjalG/WTF-gyms-test/commit/4996d86fea71bf562c08d4cb17ad2ee36ce5a2a5) — "adding 100ms video calling"

---

## Repo Proof — Commit History

All 10 commits on `main`, each developed with AI assistance as detailed above:

| Commit | Message |
|--------|---------|
| [`faf050f`](https://github.com/PranjalG/WTF-gyms-test/commit/faf050f3f57c417531bfad291927637133f65a3d) | initial project scaffold |
| [`8d0b3b4`](https://github.com/PranjalG/WTF-gyms-test/commit/8d0b3b4bc6299a6f381664830e8dc9a1155d61a7) | feat: scaffolding proceeds |
| [`4a4d9dfd`](https://github.com/PranjalG/WTF-gyms-test/commit/4a4d9dfdc7e32e03f0888d3cd58e32da32bcdaf4) | added app icons for both android and ios |
| [`c893e54`](https://github.com/PranjalG/WTF-gyms-test/commit/c893e54280dc79440116ee5e8838199dd20745ea) | perfect logging for both apps done - ios and android emulator testing complete |
| [`f3a33ac`](https://github.com/PranjalG/WTF-gyms-test/commit/f3a33ac5183ca67c0b8e814ea9fef0c227de43ba) | added firebase firestore capabilities |
| [`f6724427`](https://github.com/PranjalG/WTF-gyms-test/commit/f6724427dc9043f8002bdc30793bc5c6f01f46f7) | improved capabilities, tested chat functionality |
| [`4996d86`](https://github.com/PranjalG/WTF-gyms-test/commit/4996d86fea71bf562c08d4cb17ad2ee36ce5a2a5) | adding 100ms video calling |
| [`393b99f`](https://github.com/PranjalG/WTF-gyms-test/commit/393b99f1b537d7841661299b0e2fbec2f0e33785) | Update README.md |
| [`f7ce5ff`](https://github.com/PranjalG/WTF-gyms-test/commit/f7ce5ffcb430a13d160654360181bcd2a27e6ef6) | Update ARCHITECTURE.md |
| [`3ef07c5`](https://github.com/PranjalG/WTF-gyms-test/commit/3ef07c554a22331f5fa087eb3d8430b89995cac9) | Update DECISIONS.md |

> **Note:** Commit messages above are concise per Conventional Commits style.
> Detailed AI prompts, intents, and outputs for each are cross-referenced in
> this ledger above and in `DECISIONS.md` (ADR #4) / `ARCHITECTURE.md`.
