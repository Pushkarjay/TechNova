# Demo Script (3–5 minutes)

Overview:
- Total time: 3–5 minutes. Keep each section short and focused.

0:00–0:20 — Intro (voice + title slide)
- "Hi, we're Team TechNova. This is a prototype to detect and report unauthorized billboards."

0:20–1:10 — Mobile app capture flow (screen recording)
- Show app home screen.
- Tap "Report a Billboard" → open camera
- Capture a photo; show AI suggestion if present (overlay text). Mention: "AI suggestion is advisory — user confirms."
- Confirm violation type and submit (show local save UI). Point out offline save behavior.

1:10–1:40 — Sync and result
- Tap "Sync Now" in the app (or show automatic sync if available).
- Show spinner/upload indicator and a success message.

1:40–2:40 — Dashboard (screen recording in browser)
- Open dashboard (http://localhost:8000) and refresh.
- Show the newly submitted report as a marker on the map.
- Click marker → show details (image, violation, timestamp).
- Demonstrate moderator action (mark authorized/unauthorized) if implemented.

2:40–3:00 — Closing remarks
- Reiterate key value: offline-first, quick capture, human-in-the-loop AI.
- Mention next steps (improve ML model, harden security, add background sync).

Recording tips
- Record in landscape, hide sensitive info (don’t show service account JSON or private keys). Use the `dashboard/src/config.example.js` for the demo.
- Keep the audio clear and narrate each action; show short pauses when toggling screens.
