# Pitch Deck — TechNova (7–10 slides)

Slide 1 — Title
- Project: TechNova — Flagged Billboards
- Team name, members, contact
- One‑line tagline: "Detect, report, and moderate unauthorized billboards — citizen-first prototype"

Slide 2 — Problem Statement
- Short bullets describing the problem: unregulated billboards, safety/visual pollution, need for community reporting and evidence.

Slide 3 — Solution Overview
- Mobile app for quick photo + AI suggestion
- Offline-first local save + sync to cloud
- Public dashboard for moderators and heatmap visualization

Slide 4 — Key Features
- On-device AI suggestion (TFLite) with human confirmation
- Offline-first reports (sqflite) + SyncService (Cloudinary + Firestore)
- Dashboard with map, moderator controls, and seeded demo data

Slide 5 — Architecture (high-level)
- Include simplified system diagram (see `docs/architecture.md`)
- Data flow: capture → local save → upload → firestore → dashboard

Slide 6 — Demo & UX
- Quick walkthrough: capture photo, confirm violation, submit, sync, view on dashboard
- Mention usability choices (consent, manual confirmation, fallback if model missing)

Slide 7 — Technical Feasibility
- Libraries and infra used (Flutter, TFLite, Firestore, Cloudinary)
- Offline-first and sync strategy; seeder for demo data

Slide 8 — Ethics & Privacy
- Data minimization, consent, moderation workflow, retention notes

Slide 9 — Roadmap & Next Steps
- Replace unsigned image uploads with signed flows; hardened rules; background sync; ML model improvement

Slide 10 — Ask & Closing
- What we need (feedback, test accounts, infra help) and thank you contact info

Notes:
- This markdown is slide text that can be copy/pasted into PowerPoint/Google Slides. Keep it short and visual.
