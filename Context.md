# NEXUS — Hotel Crisis Intelligence Network
### Google Solution Challenge 2026 | Hospitality Crisis Management

---

## The Problem

Hotels are fundamentally unprepared for crises. When a fire breaks out, an intruder enters, or a medical emergency occurs:

- Staff rely on radios that jam under load
- Guests have no silent way to call for help
- There is no single source of truth for who is where
- Evacuation routes are communicated through shouting or public PA — alerting the threat too
- Management has zero real-time situational awareness

**The result:** Every crisis becomes chaos. Hotels are reactive, not intelligent.

---

## The Core Insight

> **Hotels already own the infrastructure. Nobody uses it for safety.**

Every mid-to-large hotel has:

| Existing Asset | Current Use | NEXUS Use |
|---|---|---|
| Landline phones | Guest calls | Dial `00` twice = silent SOS |
| Room TVs (IPTV) | Entertainment | Emergency broadcast + evacuation maps |
| Electronic key card readers | Room access | Tap 3× = silent SOS from inside room |
| Fire alarm panels | Fire detection | Real-time signal feed into NEXUS |
| Elevator panels | Floor navigation | Emergency signal integration |
| Hotel WiFi | Guest internet | IoT backbone (staff-side VLAN) |

**Zero construction. Zero permits. Deployable overnight.**

---

## The Solution: NEXUS

NEXUS is a **crisis intelligence platform** that sits on top of existing hotel infrastructure and adds a thin IoT layer only where gaps exist (staircases, service corridors).

### The Three Layers

```
┌─────────────────────────────────────────────────┐
│  LAYER 3 — INTELLIGENCE (Cloud + AI)            │
│  Firebase · Gemini AI · Google Maps Platform    │
├─────────────────────────────────────────────────┤
│  LAYER 2 — COMMAND (Software)                   │
│  Staff App (Flutter) · Control Room (React)     │
│  IPTV Broadcast Engine                          │
├─────────────────────────────────────────────────┤
│  LAYER 1 — DETECTION (Hardware Integration)     │
│  Landlines · Keycards · Fire Panels · Elevators │
│  + Corridor Panic Buttons (only new hardware)   │
└─────────────────────────────────────────────────┘
```

### How It Works in 60 Seconds

1. **Guest dials `00` twice on room phone** → SOS registered in NEXUS, room number identified, no sound made
2. **Gemini AI classifies the signal** → fire, medical, security, flood? Pulls weather data, building floor plan, guest count
3. **Staff app vibrates silently** → nearest staff pinged with role-specific instruction ("proceed to Room 412, do NOT announce on PA")
4. **If escalation needed** → IPTV in affected zone shows calm evacuation overlay with route
5. **Control room sees live map** → every alert, every staff position, every open/closed fire door in real time
6. **Works offline** → local Raspberry Pi gateway ensures function even if internet drops

---

## Why NEXUS Wins

### Vs. Pure Software Solutions
- Every other team builds an app. NEXUS integrates into iron.
- Demo shows a physical keycard tap triggering a live alert. Judges see real hardware.

### Vs. New Hardware Solutions
- Judges immediately ask: "How do you install this?"
- NEXUS answer: "We don't install anything new except one panic button per staircase."

### Vs. Existing Hotel Systems
- PMS (Property Management Systems) have no crisis module
- NEXUS plugs into PMS via API — doesn't replace it, enhances it

---

## Target Users

| User | Pain Point | NEXUS Solution |
|---|---|---|
| Hotel Guest | No way to silently call for help | Keycard tap / phone dial SOS |
| Front Desk Staff | Overwhelmed during crisis, no info | Silent alert with AI triage instructions |
| Security Team | No floor-by-floor situational awareness | Live map with real-time positions |
| Hotel GM | Liability, reputational damage | Audit log, response times, compliance report |
| Fire Department | Arrive blind to building state | NEXUS public API for emergency services |

---

## Impact Metrics (For Demo)

- **₹12,000** — total new hardware cost for a 200-room hotel (30 corridor buttons × ₹400)
- **< 4 hours** — deployment time (software config, no construction)
- **0 seconds** — response delay for AI triage after SOS trigger
- **Works offline** — local edge node ensures function without internet
- **Google ecosystem native** — Firebase, Gemini, Maps, Flutter, all first-party

---

## One-Line Pitch

> *"NEXUS turns infrastructure hotels already paid for into a crisis intelligence network — no new construction, deployable overnight, works even when the internet is down."*
