# Architecture Decision Records (ADRs)

---

## ADR #1 — State Management: Riverpod

**Decision:** Use `flutter_riverpod` (v2) with `AsyncNotifier` and `StateNotifier`.

**Rationale:**
- Compile-safe providers — no string keys, no context dependency for reading state
- `AsyncNotifierProvider` handles loading/error/data states cleanly for chat and call flows
- Better testability than BLoC for a 6-hour assessment (less boilerplate)
- Code generation via `riverpod_generator` reduces manual provider wiring
- Team at WTF likely familiar with Riverpod given modern Flutter stack

**Alternatives considered:**
- BLoC: More verbose, better for large teams — overkill for this scope
- Provider: Deprecated direction, less type-safe
- GetX: Opinionated, mixes concerns

**Trade-off:** Riverpod's code generation requires a build_runner step; documented in README.

---

## ADR #2 — Local Storage: Hive

**Decision:** Use `hive_flutter` for all local persistence (messages, users, call requests, session logs).

**Rationale:**
- Pure Dart, no native dependencies — works identically on both emulators
- `ValueListenable<Box>` provides reactive updates without a separate stream layer
- Significantly faster setup than SQLite/Drift for a time-boxed assessment
- Type adapters generated via `hive_generator` keep models type-safe

**Real-time simulation:**
- Both apps write to their own Hive boxes
- For cross-device sync (two emulators), Firebase Firestore is used as the sync layer
  with Hive as a local cache. If running on a single device, Hive alone suffices.

**Alternatives considered:**
- SQLite/Drift: Excellent for relational data, but more setup time
- SharedPreferences: Not suitable for complex models
- Firebase only: Requires internet; Hive ensures offline-first per spec

---

## ADR #3 — RTC Strategy: 100ms Flutter SDK

**Decision:** Use `hmssdk_flutter` (official 100ms Flutter SDK) with a local Node.js token server.

**Rationale:**
- Assessment explicitly mandates 100ms — no alternative considered
- Dev/dummy project approach used (no production keys needed for assessment)
- Token server is a minimal Express endpoint to keep credentials off the client
- Room creation on call approval via 100ms Management API (REST)
- Roles: `trainer` (can mute self, end call) and `member` (mute self only)

**Token flow:**
```
App → GET /token?userId=DK&role=member
Token server → signs JWT with APP_ACCESS_KEY + APP_SECRET
→ returns { token: "..." }
App → HMSSDK.join(HMSConfig(authToken: token, userName: userId))
```

**Edge cases handled:**
- Token expiry: refresh by re-calling token server before join
- Network loss: `HMSUpdateListenerActions.onReconnecting` shows loader
- App backgrounded: iOS/Android background audio handled by 100ms SDK natively
