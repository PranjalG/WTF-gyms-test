# WTF Flutter Engineer Assessment
## Guru & Trainer Chat + Video Call System (100ms)

---

## 🚀 Quick Start — Run Everything

### 1. Token Server
```bash
cd token_server
cp .env .env        # fill in your 100ms credentials
npm install
node index.js               # runs on http://localhost:3000
```

### 2. Guru App (Member — DK)
```bash
cd guru_app
flutter pub get
flutter run                 # select your Android emulator/device
```

### 3. Trainer App
```bash
cd trainer_app
flutter pub get
flutter run -d <second_device_id>   # run on a second emulator/device
```

> **Tip:** Run `flutter devices` to list available emulators. Use two Android emulators simultaneously.

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

## ✅ Submission Checklist

- [ ] Repo builds both apps with commands above
- [ ] Token server runs locally with .env filled
- [ ] 100ms video call join works on both apps
- [ ] Chat works both ways with read receipts + typing indicator
- [ ] Scheduler approve/decline with conflict check
- [ ] Session logs populate after call ends
- [ ] AI_LEDGER.md with ≥10 meaningful entries
- [ ] 3-min demo video (link below)

**Demo Video:** _[link to be added]_

---

## 🔑 Environment Variables

See `token_server/.env.example` for required 100ms credentials.
Never commit your `.env` file — it is in `.gitignore`.

---

## 👤 Test Personas

| Role    | Name  | Pre-seeded    |
|---------|-------|---------------|
| Member  | DK    | ✅ Guru App    |
| Trainer | Aarav | ✅ Trainer App |
# WTF-gyms-test
