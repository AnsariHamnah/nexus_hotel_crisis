# RESQNET - LAN-Based Smart Hotel Emergency Response System

**Winner - Google Solution Challenge 2026 Submission**

RESQNET (formerly NEXUS) is an AI-powered, enterprise-grade emergency orchestration platform designed for hotels and massive commercial complexes. We replace disjointed walkie-talkies and panic with a highly coordinated, software-driven crisis management architecture.

## 🚀 The Core Problem
During a hotel fire or active threat, seconds matter. Current systems rely on static printed floor plans, chaotic radio chatter, and blind evacuations. Staff and responders often lack real-time situational awareness.

## 💡 The RESQNET Solution
RESQNET transforms standard hotel networking into an intelligent survival grid:
1. **Gemini AI Triage:** Instantly classifies emergencies, filtering noise and generating exact evacuation protocols.
2. **Dynamic Evacuation Engine:** Calculates the safest—not nearest—routes around smoke, fire, and blocked corridors.
3. **Smart TV Overlays:** Pushes real-time, room-specific evacuation routes directly to guest IPTVs.
4. **Live Staff Tracking:** Plots staff locations against live danger zones on an operational dashboard.
5. **Responder Command Center:** Generates secure, short-lived web links for Fire/Police to view live clearance sweeps and building blueprints before they even arrive on the scene.

## 🏗️ Architecture
- **Frontend:** Flutter (iOS/Android/Web) - Single codebase for Staff App and Responder Dashboard.
- **Backend:** Firebase Cloud Firestore (Real-time sync & RBAC).
- **Intelligence:** Google Gemini API (Cloud Functions) & Local Gemma Fallback (Raspberry Pi).
- **Push:** Firebase Cloud Messaging (Silent operational payloads).
- **Routing:** Custom modified Dijkstra engine penalizing active hazard zones.

## 🛠️ Setup Instructions (Judges / Reviewers)
1. Clone the repository.
2. Run `flutter pub get`.
3. The project is pre-configured with `firebase_options.dart` pointing to the live staging environment. 
4. Run on an iOS/Android simulator or Web: `flutter run -d chrome`.
5. **Demo Accounts:**
   - Security: `security@resqnet.dev` / `demo123`
   - Manager: `manager@resqnet.dev` / `demo123`

## 🛡️ Enterprise Security & RBAC
Zero public API exposure. Direct REST dispatch calls are handled server-side via Firebase Cloud Functions only after Manager approval. Strict Firestore Security Rules isolate Housekeeping from Managerial incident logs.

## 🌍 Offline Resilience
RESQNET operates on a 3-Tier Fallback System:
1. **Cloud (Primary):** Firebase + Gemini via WAN.
2. **Edge (Secondary):** Local Raspberry Pi + Gemma LLM via Hotel LAN Intranet.
3. **Device (Fail-Safe):** Regex keyword rules baked directly into the Flutter binary requiring zero connectivity.