# WTF Flutter Engineer Assessment
## Guru & Trainer Chat + Video Call System (100ms)

A real-time chat and video calling system built with two Flutter apps —
**Guru App** (member-facing, for DK) and **Trainer App** (for Aarav) —
integrated with **100ms** for live video calls.

---

## 🎥 Demo Video

**[▶ Watch the full walkthrough (Google Drive)](https://drive.google.com/file/d/1BQA207lPMS7bC-3yBYYPiREPsfzf0yxA/view?usp=sharing)**

The video covers: 100ms video calling (host/guest roles), real-time chat with
read receipts & typing indicators, call scheduling & approval flow, and
session logs.

---

## ✨ Key Highlights

- **100ms Video Calling** — Integrated via the official Flutter SDK using a
  local Node.js token server. Each call runs on a unique `roomId`, with
  participants joining as `host` (trainer) or `guest` (member), enforcing
  role-based permissions (mute, end call, etc.)
- **Real-time Chat** — Bubble UI with role-based colors, read receipts
  (single/double ticks), simulated typing indicator, and quick-reply chips
- **Call Scheduling** — Member requests a slot → trainer approves/declines
  with conflict checking → system message + Join Call button auto-appear
- **Session Logs** — Auto-generated on call end with duration, post-call
  ratings (member) and notes (trainer)
- **AI-Native Workflow** — Built collaboratively with AI throughout; full
  prompt history in [`AI_LEDGER.md`](./AI_LEDGER.md)

---

## 🚀 Quick Start — Run Everything

### 1. Token Server
```bash
cd token_server
cp .env.example .env        # fill in your 100ms credentials
npm install
node index.js               # runs on http://localhost:3000
```

### 2. Guru App (Member — DK)
```bash
cd guru_app
flutter pub get
flutter run                 # select your Android device/emulator
```

### 3. Trainer App
```bash
cd trainer_app
flutter pub get
flutter run -d <second_device_id>   # run on a second device/emulator
```

> **Tip:** Run `flutter devices` to list connected devices. This project was
> tested on two physical devices (Android + iOS) simultaneously.

---

## 📁 Project Structure

```
wtf_flutter_test/
├── README.md
├── AI_LEDGER.md            # All AI prompts + outputs used
├── ARCHITECTURE.md         # System design decisions
├── DECISIONS.md            # ADRs: state mgmt, storage, RTC
│
├── token_server/           # Node.js 100ms token server
│   ├── index.js
│   ├── .env.example
│   └── package.json
│
├── shared/                 # Shared models, services, widgets
│   ├── models/
│   ├── services/
│   ├── widgets/
│   └── utils/
│
├── guru_app/               # Member-facing Flutter app (DK)
│   ├── lib/
│   ├── test/
│   └── pubspec.yaml
│
└── trainer_app/            # Trainer-facing Flutter app (Aarav)
    ├── lib/
    ├── test/
    └── pubspec.yaml
```

---

## 🏗 Architecture & Decisions

- See [`ARCHITECTURE.md`](./ARCHITECTURE.md) for the system design and data flow
- See [`DECISIONS.md`](./DECISIONS.md) for ADRs on state management (Riverpod),
  local storage (Hive), and the 100ms RTC integration strategy

---

## ✅ Submission Checklist

- [x] Repo builds both apps with commands above
- [x] Token server runs locally with `.env` filled
- [x] 100ms video call join works on both apps (host/guest roles, unique room ID)
- [x] Chat works both ways with read receipts + typing indicator
- [x] Scheduler approve/decline with conflict check
- [x] Session logs populate after call ends
- [x] AI_LEDGER.md with ≥10 meaningful entries
- [x] 3-min demo video (linked above)

---

## 🔑 Environment Variables

See `token_server/.env.example` for required 100ms credentials.
Never commit your `.env` file — it is in `.gitignore`.

> **Note:** For multi-device testing (Android + iPhone on the same hotspot),
> the token server was deployed to **Render** for a stable public URL instead
> of relying on local network IPs. Update `TOKEN_SERVER_URL` in each app's
> `.env` to point to the Render URL, e.g.:
> ```
> TOKEN_SERVER_URL=https://your-app-name.onrender.com
> ```

---

## 👤 Test Personas

| Role    | Name  | Pre-seeded     | 100ms Role |
|---------|-------|----------------|------------|
| Member  | DK    | ✅ Guru App     | guest      |
| Trainer | Aarav | ✅ Trainer App  | host       |
