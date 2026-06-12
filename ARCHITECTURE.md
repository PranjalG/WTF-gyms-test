# Architecture — WTF Flutter Assessment

## System Overview

Two Flutter apps (Guru + Trainer) communicate via a shared local Hive database,
with 100ms SDK handling real-time video calls and a local Node.js token server.

```
┌─────────────────┐         ┌──────────────────┐
│   Guru App      │         │   Trainer App     │
│   (DK - Member) │         │   (Aarav)         │
│                 │         │                   │
│  Riverpod       │         │  Riverpod         │
│  go_router      │         │  go_router        │
│  Hive (local)   │◄───────►│  Hive (local)     │
│  100ms SDK      │         │  100ms SDK        │
└────────┬────────┘         └────────┬──────────┘
         │                           │
         └──────────┬────────────────┘
                    │
         ┌──────────▼──────────┐
         │   Token Server        │
         │   Hosted on Render     │
         │   GET /token            │
         │   (100ms JWT)           │
         └──────────┬──────────┘
                    │
         ┌──────────▼──────────┐
         │   100ms Platform     │
         │   (Video/Audio RTC)  │
         └─────────────────────┘
```

> **Note:** The token server is deployed to Render (public HTTPS) rather than
> run locally, to support testing across two physical devices (Android +
> iPhone) on a shared hotspot. See ADR #4 in `DECISIONS.md`.

## Layer Structure (each app)

```
lib/
├── core/
│   ├── di/          # Riverpod providers (dependency injection)
│   ├── router/      # go_router configuration
│   └── theme/       # ThemeData, colors, typography
├── features/
│   ├── auth/        # Login, onboarding
│   ├── chat/        # Chat list + conversation screens
│   ├── schedule/    # Call scheduling (member) / Requests (trainer)
│   ├── calls/       # 100ms pre-join + in-call screens
│   └── sessions/    # Session logs
└── main.dart
```

## Real-time Chat Strategy

- Both apps share a **Hive box** at the same path on the device.
- On emulators: use a shared path or Firebase Firestore for cross-device sync.
- Messages are written to Hive and exposed via `ValueListenable` streams.
- Typing indicator is simulated via a 400–800ms debounce timer.

## 100ms RTC Flow

1. Trainer approves CallRequest → backend creates 100ms room via Management API
2. `hmsRoomId` stored in `RoomMeta` Hive box
3. 10 min before call: both apps show "Join Call" button
4. App calls token server `GET /token?userId=DK&role=member`
5. Token server returns signed 100ms JWT
6. App joins room with `HMSSDK.join(config)`
7. On call end: `SessionLog` auto-written with duration

## Observability

- Structured log tags: `[CHAT]` `[RTC]` `[SCHEDULE]` `[AUTH]`
- DevPanel: floating `⋮` button → last 20 logs
- Snackbars with human copy + "Copy error" action
