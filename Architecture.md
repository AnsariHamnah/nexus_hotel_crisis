# NEXUS — System Architecture
### Clean Architecture Reference Document

---

## Architecture Philosophy

NEXUS follows a **layered + event-driven** architecture.

- Every crisis event is a **message** flowing through the system
- Each layer is independent and testable in isolation
- The system **degrades gracefully** — loses cloud first, then falls back to LAN, then to standalone edge node
- Google-first stack: Firebase, Gemini, Maps, Flutter, GCP

---

## High-Level System Diagram

```
                        ┌──────────────────────────────┐
                        │     GOOGLE CLOUD PLATFORM     │
                        │                              │
  ┌──────────┐          │  ┌──────────┐ ┌───────────┐ │
  │  HOTEL   │  HTTPS   │  │ Firebase │ │ Gemini AI │ │
  │  EDGE    │◄────────►│  │Firestore │ │  (Crisis  │ │
  │  NODE    │  + WSS   │  │ Auth     │ │  Triage)  │ │
  │(RPi/LAN) │          │  │ FCM      │ │           │ │
  └────┬─────┘          │  │ Functions│ └───────────┘ │
       │                │  └──────────┘               │
       │ MQTT           │  ┌──────────────────────┐   │
       │                │  │  Google Maps Platform │   │
  ┌────▼──────────────┐ │  │  (Evacuation Routes) │   │
  │   HOTEL HARDWARE  │ │  └──────────────────────┘   │
  │                   │ └──────────────────────────────┘
  │  Landlines        │
  │  IPTV System      │         ┌────────────────────┐
  │  Keycard Readers  │         │   STAFF FLUTTER APP│
  │  Fire Panel API   │         │   (iOS + Android)  │
  │  Panic Buttons    │         └────────────────────┘
  └───────────────────┘
                                ┌────────────────────┐
                                │  CONTROL ROOM DASH │
                                │  React Web App     │
                                └────────────────────┘
```

---

## Layer Breakdown

### Layer 1 — Detection (Hardware Integration)

**Purpose:** Capture SOS signals from existing hotel hardware.

| Hardware | Integration Method | Signal Type |
|---|---|---|
| Landline phones | PBX API hook (Asterisk/SIP) | `00`+`00` dial pattern → SOS event |
| Keycard readers | OSDP protocol listener | 3x rapid tap → SOS event |
| Fire alarm panel | Dry contact relay → GPIO on RPi | Contact close → FIRE event |
| Corridor panic button | WiFi/ESP32 button → MQTT | Button press → SOS event |
| Elevator panel | RS-485 tap (read-only) | Emergency press → ALERT event |

**Edge Node:** Raspberry Pi 4 running:
- `nexus-edge` (Node.js service) listening to all hardware feeds
- Local MQTT broker (Mosquitto)
- Local SQLite fallback cache (works offline)
- Pushes events to Firebase when online

---

### Layer 2 — Command (Software Platform)

#### 2A. Backend — Firebase

```
Firebase Project: nexus-hotel-[id]
│
├── Firestore Collections
│   ├── /hotels/{hotelId}               ← Hotel config, floor plans
│   ├── /alerts/{alertId}               ← Every SOS event
│   ├── /staff/{staffId}                ← Staff roles, positions
│   ├── /rooms/{roomId}                 ← Room state, occupancy
│   └── /audit_log/{logId}              ← Full audit trail
│
├── Firebase Auth
│   └── Role-based: guest | staff | security | manager | admin
│
├── Cloud Functions
│   ├── onAlertCreated()                ← Triggers Gemini triage
│   ├── onAlertEscalated()              ← Triggers IPTV broadcast
│   ├── notifyNearestStaff()            ← FCM push to staff app
│   └── generateIncidentReport()        ← Post-crisis PDF export
│
└── Firebase Cloud Messaging (FCM)
    └── Silent push → Staff Flutter app
```

#### 2B. AI Triage — Gemini API

Called by `onAlertCreated()` Cloud Function.

**Input to Gemini:**
```json
{
  "alert_type": "SOS",
  "source": "keycard_reader",
  "room": "412",
  "floor": 4,
  "guest_count_floor": 23,
  "time": "02:14",
  "recent_alerts_nearby": [],
  "weather": "clear",
  "building_context": "Wing B, near stairwell 2"
}
```

**Gemini Output:**
```json
{
  "crisis_class": "medical_emergency",
  "severity": "high",
  "recommended_action": "Send security + first aid to Room 412 silently",
  "evacuate_floor": false,
  "notify_emergency_services": true,
  "iptv_broadcast": false,
  "instructions_for_staff": "Do NOT announce on PA. Approach from east corridor."
}
```

#### 2C. IPTV Broadcast Engine

- Connects to hotel's existing IPTV head-end via HDMI/IP injection
- Pushes an **overlay** (not full-screen takeover) with:
  - Calm colour-coded alert banner
  - Floor-specific evacuation route (pulled from Google Maps floorplan API)
  - "Please proceed to nearest exit" in 3 languages
- Triggered only when Gemini recommends escalation

---

### Layer 3 — Interfaces (Client Apps)

#### Staff Flutter App

```
lib/
├── main.dart
├── core/
│   ├── firebase_service.dart
│   ├── gemini_service.dart
│   └── maps_service.dart
├── features/
│   ├── auth/                    ← Login, role assignment
│   ├── alerts/                  ← Incoming SOS list + details
│   ├── map/                     ← Live floor map with positions
│   ├── broadcast/               ← Trigger IPTV from app
│   └── incident_log/            ← Post-crisis report viewer
└── models/
    ├── alert.dart
    ├── staff.dart
    └── room.dart
```

**Key Features:**
- Silent vibration alert (no sound in crisis zones)
- Role-based view: Security sees different info than Housekeeping
- One-tap "I'm on scene" acknowledgement
- Offline mode via local cache

#### Control Room React Dashboard

```
src/
├── App.tsx
├── components/
│   ├── LiveMap/                 ← Google Maps + floor overlay
│   ├── AlertFeed/               ← Real-time Firestore stream
│   ├── StaffTracker/            ← Who is where
│   ├── GeminiPanel/             ← AI triage output + override
│   └── IncidentTimeline/        ← Full audit of crisis
├── hooks/
│   ├── useFirestore.ts
│   ├── useAlerts.ts
│   └── useStaffPositions.ts
└── services/
    ├── firebase.ts
    ├── gemini.ts
    └── maps.ts
```

---

## Data Flow — Full Crisis Event

```
[Guest taps keycard 3×]
        │
        ▼
[Edge Node detects OSDP signal]
        │
        ▼
[MQTT broker receives event]
        │
        ▼
[nexus-edge publishes to Firebase Firestore]
  → /alerts/{new_alert_id}
        │
        ▼
[Cloud Function: onAlertCreated() fires]
        │
   ┌────┴────────────────────┐
   ▼                         ▼
[Gemini API called]    [FCM: notify nearest staff]
   │
   ▼
[Gemini returns crisis_class + instructions]
        │
        ▼
[Alert updated with AI triage in Firestore]
        │
   ┌────┴──────────────────────────────┐
   ▼                                   ▼
[Staff app receives                [Control room
 silent push +                      sees live alert
 Gemini instructions]               on map + timeline]
        │
        ▼
[If escalation = true]
        │
        ▼
[IPTV broadcast triggered]
[Floor-specific evacuation overlay pushed]
        │
        ▼
[Staff taps "On Scene" in app]
        │
        ▼
[Alert status → RESPONDING → RESOLVED]
[Audit log entry written]
[Incident report auto-generated]
```

---

## Offline / Resilience Strategy

| Failure Mode | NEXUS Behaviour |
|---|---|
| Internet drops | Edge node caches events in SQLite, syncs when reconnected |
| Firebase outage | Local fallback webhook to hotel's own server |
| Power outage | Panic buttons on UPS backup, keycard readers on battery |
| Staff app offline | FCM falls back to SMS via Twilio fallback |

---

## Tech Stack Summary

| Layer | Technology | Why |
|---|---|---|
| Mobile App | Flutter | Cross-platform, Google-native, offline support |
| Web Dashboard | React + TypeScript | Fast, componentised, real-time capable |
| Backend | Firebase (Firestore, Functions, FCM, Auth, Hosting) | Realtime, serverless, Google-native |
| AI Triage | Gemini 1.5 Pro API | On-premise crisis classification, structured output |
| Maps | Google Maps Platform + Indoor Maps | Evacuation routing, floor plans |
| IoT Edge | Raspberry Pi 4 + Node.js + MQTT (Mosquitto) | Handles hardware signals, works offline |
| Panic Buttons | ESP32 WiFi button | ₹400/unit, no wiring, MQTT over WiFi |
| PBX Integration | Asterisk SIP / FreePBX webhook | Hooks into existing hotel phone system |
| IPTV Integration | HTTP API to IPTV head-end or HDMI encoder | Pushes overlay to existing TVs |
| Auth | Firebase Auth + custom claims (RBAC) | Role: guest/staff/security/manager/admin |
| Hosting | Firebase Hosting + Cloud Run | Dashboard + API endpoints |
| Repo | GitHub (monorepo) | Version control, CI/CD via GitHub Actions |
| CI/CD | GitHub Actions → Firebase Deploy | Auto-deploy on push to main |

---

## Repository Structure

```
nexus/
├── README.md
├── Context.md
├── Architecture.md
├── TEAM_GUIDE.md
│
├── edge/                        ← Raspberry Pi edge node
│   ├── index.js                 ← Main service
│   ├── mqtt/                    ← MQTT broker config
│   ├── hardware/
│   │   ├── pbx.js               ← Landline SOS detection
│   │   ├── keycard.js           ← OSDP reader listener
│   │   ├── fire_panel.js        ← GPIO fire alarm reader
│   │   └── panic_button.js      ← ESP32 MQTT subscriber
│   └── sync/
│       └── firebase_sync.js     ← Offline cache + sync
│
├── functions/                   ← Firebase Cloud Functions
│   ├── index.js
│   ├── onAlertCreated.js
│   ├── notifyStaff.js
│   ├── geminiTriage.js
│   └── generateReport.js
│
├── app/                         ← Flutter staff app
│   ├── lib/
│   └── pubspec.yaml
│
├── dashboard/                   ← React control room
│   ├── src/
│   └── package.json
│
└── .github/
    └── workflows/
        ├── deploy-functions.yml
        └── deploy-dashboard.yml
```

---

## Security Considerations

- All hardware signals validated against known room/device IDs before processing
- Firebase security rules: staff can only read alerts in their zone
- Gemini API calls made server-side only (Cloud Functions), never from client
- Audit log is append-only (no delete permission for any role)
- IPTV injection authenticated via hotel-side API key
- Edge node communicates over hotel staff VLAN, isolated from guest WiFi
