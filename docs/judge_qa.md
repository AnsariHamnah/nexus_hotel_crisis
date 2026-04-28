# Judge Q&A Preparation

**Q: How does this scale? Isn't deploying smart LEDs everywhere expensive?**
*A: "That is exactly why we built RESQNET as a software-first solution. Our MVP requires zero new hardware. We leverage the Smart TVs already in every guest room, and the smartphones staff already carry in their pockets. A 500-room hotel can deploy this in an afternoon just by signing up for the SaaS and uploading their floor plans. We are heavily optimizing for low-cost scalability."*

**Q: What happens if the internet goes down during a fire? Doesn't this rely on Firebase?**
*A: "We engineered a 3-Tier Fallback system. Tier 1 is Firebase and Google Gemini via the cloud. If the WAN dies, Tier 2 kicks in: we route packets over the hotel's local LAN intranet to a Raspberry Pi running Google's Gemma LLM locally. If the LAN dies, Tier 3 takes over: the Flutter app has hardcoded regex protocols baked into the binary. It works completely offline."*

**Q: Why use AI? Isn't AI prone to hallucinations in an emergency?**
*A: "We don't use AI to make final dispatch decisions; we use it for triage and orchestration. In a panic, human dispatchers get overwhelmed. Gemini parses raw sensor data and panicked text, filtering noise to present a clean, tactical summary. Furthermore, the AI never talks directly to 911. A human manager always reviews the AI's triage on the Dashboard and must physically press 'Approve & Dispatch'."*

**Q: How do emergency responders access this?**
*A: "We use a zero-trust model. First responders do not have accounts on our system. When a manager approves an escalation, RESQNET generates a secure, mathematically random 6-digit PIN with a 4-hour time-to-live (TTL). This link is sent to dispatch. Responders open it on their existing iPads and get instant, read-only access to the live floor map and room clearance statuses."*

**Q: How do you handle privacy with staff location tracking?**
*A: "Location tracking is strictly operational and role-based. It only activates when a staff member 'Clocks In' (is marked `isActive: true` in Firestore), and locations are only visible to authorized roles like Managers or Security. Furthermore, we don't store historical path data; we only update `lastKnownLocation`, preserving privacy while ensuring safety."*

**Q: What is the revenue model?**
*A: "B2B SaaS. We charge hotels a monthly subscription based on total square footage and room count. The barrier to entry is virtually zero since there are no physical installation costs. We offer the physical LED guidance strips as a premium physical hardware upsell down the road."*
