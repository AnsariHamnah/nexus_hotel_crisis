# NEXUS — Team Guide
### Who Does What | Timeline | GitHub Setup | Tools

---

## Team Roles (4-Person Team)

> Adapt to your team size. These are the 4 core ownership areas.

| Role | Owner | Owns |
|---|---|---|
| **Team Lead + AI/Backend** | Person 1 | Firebase setup, Cloud Functions, Gemini integration, system design decisions |
| **IoT / Edge Engineer** | Person 2 | Raspberry Pi edge node, MQTT, hardware signal simulation, ESP32 panic button |
| **Flutter App Developer** | Person 3 | Staff mobile app, FCM integration, offline mode, UI/UX |
| **Frontend / Presenter** | Person 4 | React control room dashboard, Google Maps integration, demo prep, slide deck |

---

## 8-Week Build Roadmap

### Week 1 — Foundation
- [ ] GitHub repo created (monorepo, see structure below)
- [ ] Firebase project created and connected
- [ ] Flutter app scaffolded (`flutter create app`)
- [ ] React dashboard bootstrapped (`npx create-react-app dashboard --template typescript`)
- [ ] Edge node folder created, Node.js initialized
- [ ] All teammates added as collaborators on GitHub
- [ ] Roles assigned and documented in this file
- [ ] README.md written with one-line pitch

### Week 2 — SOS Detection (Core Feature)
- [ ] Landline `00`+`00` SOS: PBX webhook or simulated via REST call
- [ ] Keycard 3× tap: OSDP simulation (or hardware if available)
- [ ] Panic button: ESP32 + MQTT publish → edge node subscribes
- [ ] All signals write to Firestore `/alerts` collection
- [ ] Basic alert appears in Firebase console

### Week 3 — AI Triage (Gemini)
- [ ] Gemini API key obtained (Google AI Studio)
- [ ] Cloud Function `onAlertCreated` calls Gemini with alert context
- [ ] Gemini returns structured `crisis_class` + `recommended_action`
- [ ] Triage result written back to alert document in Firestore
- [ ] Test: keycard tap → Firestore → Gemini → response logged

### Week 4 — Staff App (Flutter)
- [ ] Firebase Auth login (email/password, role-based)
- [ ] Real-time alert list from Firestore
- [ ] FCM push notification on new alert (silent vibration)
- [ ] Alert detail screen: Gemini instructions shown
- [ ] "I'm on scene" button → updates alert status in Firestore
- [ ] Basic offline cache implemented

### Week 5 — Control Room Dashboard (React)
- [ ] Firebase Auth login for manager role
- [ ] Real-time alert feed (Firestore listener)
- [ ] Google Maps integration with floor overlay
- [ ] Staff position markers on map (manual update for demo)
- [ ] Gemini triage output panel (show AI reasoning)
- [ ] Alert timeline / audit log view

### Week 6 — IPTV + Advanced Features
- [ ] IPTV broadcast simulation: full-screen web page pushed to TV via Chromecast or HDMI encoder
- [ ] Evacuation route overlay using Google Maps Directions API
- [ ] Offline mode fully tested (kill internet, SOS still works via LAN)
- [ ] Incident report auto-generation (Cloud Function → PDF via pdfkit)

### Week 7 — Polish + Demo Prep
- [ ] End-to-end demo rehearsed (physical keycard tap → live app alert)
- [ ] All edge cases handled (offline, multiple simultaneous alerts)
- [ ] UI polished on both app and dashboard
- [ ] Slide deck finalized (see Pitch Structure below)
- [ ] 2-minute demo video recorded as backup

### Week 8 — Submission
- [ ] README updated with demo video link
- [ ] All code pushed, clean commit history
- [ ] Solution Challenge submission form filled
- [ ] Live demo endpoint deployed (Firebase Hosting)

---

## GitHub Setup (Step by Step)

### 1. Create the Repository

1. Go to **github.com** → click **"New repository"**
2. Name it: `nexus-hotel-crisis`
3. Set to **Public** (required for judging)
4. Check **"Add a README file"**
5. Click **Create repository**

### 2. Clone and Set Up Locally

```bash
git clone https://github.com/YOUR_USERNAME/nexus-hotel-crisis.git
cd nexus-hotel-crisis

# Create folder structure
mkdir -p edge/hardware edge/sync functions app dashboard .github/workflows

# Initialize Node.js for edge and functions
cd edge && npm init -y && cd ..
cd functions && npm init -y && cd ..

# Flutter app
cd app && flutter create . && cd ..

# React dashboard
cd dashboard && npx create-react-app . --template typescript && cd ..
```

### 3. Branch Strategy

```
main          ← Production / demo-ready only. Never commit directly.
develop       ← Integration branch. Merge features here first.
feature/xxx   ← Each feature in its own branch.
```

**Git workflow:**
```bash
# Start a new feature
git checkout develop
git pull origin develop
git checkout -b feature/gemini-triage

# Work, commit often
git add .
git commit -m "feat: add Gemini crisis classification function"

# Push and open Pull Request to develop
git push origin feature/gemini-triage
# → Go to GitHub → Open PR → Team reviews → Merge
```

### 4. Recommended YouTube Tutorial

**"GitHub for Beginners — Full Course" by freeCodeCamp**
Search: `freeCodeCamp GitHub tutorial 2024` on YouTube
Link pattern: `youtube.com/watch?v=RGOj5yH7evk`
(~1 hour — covers clone, branch, PR, merge — everything you need)

**"Git and GitHub Crash Course" by Traversy Media** (30 min version)
Search: `Traversy Media Git crash course`

---

## Tools to Use

### Development

| Tool | Use | Get It |
|---|---|---|
| **VS Code** | Primary IDE for all code | code.visualstudio.com |
| **Flutter SDK** | Mobile app development | flutter.dev |
| **Node.js 20 LTS** | Edge node + Cloud Functions | nodejs.org |
| **Firebase CLI** | Deploy functions and hosting | `npm install -g firebase-tools` |
| **Android Studio** | Flutter emulator | developer.android.com |
| **Postman** | Test REST APIs and webhooks | postman.com |
| **MQTT Explorer** | Debug MQTT messages from edge | mqtt-explorer.com |
| **TablePlus** | Browse Firestore data visually | tableplus.com |

### Google Services (All Free Tier)

| Service | Purpose | Setup |
|---|---|---|
| **Firebase** | Backend — Firestore, Auth, Functions, FCM, Hosting | console.firebase.google.com |
| **Google AI Studio** | Get Gemini API key | aistudio.google.com |
| **Google Maps Platform** | Maps, Indoor Maps, Directions | console.cloud.google.com |
| **Google Cloud Console** | Manage Firebase + APIs + billing | console.cloud.google.com |

### Design & Presentation

| Tool | Use |
|---|---|
| **Figma** | UI mockups before coding |
| **Google Slides** | Pitch deck (use Google branding!) |
| **Canva** | Architecture diagrams if Figma is too heavy |
| **draw.io** | System architecture diagrams |
| **Loom** | Record demo video |

### Project Management

| Tool | Use |
|---|---|
| **GitHub Projects** | Kanban board for tasks (built into GitHub) |
| **WhatsApp / Discord** | Team communication |
| **Google Meet** | Weekly sync calls |

---

## Pitch Structure (3 Minutes)

| Minute | Content |
|---|---|
| **0:00 – 0:30** | The Problem: "Every hotel has a landline. None of them use it for safety." |
| **0:30 – 1:00** | The Insight: "Hotels already own the infrastructure. We connect it." |
| **1:00 – 2:00** | **LIVE DEMO**: Tap keycard 3× → alert appears in staff app → Gemini triage shown → IPTV broadcast triggered |
| **2:00 – 2:30** | Google Tech Stack: Firebase + Gemini + Maps + Flutter — all first-party |
| **2:30 – 3:00** | Impact: ₹12,000 total new hardware, 4-hour deployment, works offline |

**Judges' likely questions and your answers:**

| Question | Answer |
|---|---|
| "How do you install this?" | "We don't. The hotel already has landlines and IPTV. We add software. The only hardware is ₹400 corridor buttons." |
| "What if the internet goes down?" | "Our edge node runs locally. Alerts still work. We sync to cloud when back online." |
| "How is this different from existing hotel systems?" | "PMS systems have no crisis module. We plug into them via API. NEXUS adds intelligence they don't have." |
| "How do you make money?" | "SaaS: ₹15,000/month per hotel. Or one-time license for hotel chains." |
| "Is it secure?" | "Hardware signals run on hotel staff VLAN, isolated from guest WiFi. Audit log is append-only. Gemini runs server-side only." |

---

## Definition of Done (Per Feature)

A feature is done when:
- [ ] Code is on a feature branch
- [ ] Pull Request opened and reviewed by at least 1 teammate
- [ ] Merged to `develop`
- [ ] Tested end-to-end on a device (not just locally)
- [ ] README updated if the feature changes setup steps

---

## Emergency Contacts / Key Links

| Resource | Link |
|---|---|
| Firebase Console | console.firebase.google.com |
| Gemini API Docs | ai.google.dev/docs |
| Google Maps Platform | developers.google.com/maps |
| Flutter Docs | docs.flutter.dev |
| Firebase Flutter Setup | firebase.flutter.dev |
| Solution Challenge Portal | developers.google.com/community/gdsc-solution-challenge |
| NEXUS GitHub Repo | github.com/YOUR_USERNAME/nexus-hotel-crisis |
