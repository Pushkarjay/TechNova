
# Flagging Unauthorized Billboards — TechNova

This repository contains a hackathon prototype for detecting and reporting unauthorized billboards using a hybrid of on-device AI and human verification. It includes:

- A Flutter mobile app (offline-first) that captures photos, suggests violations using TF Lite, and queues reports for sync.
- A lightweight static dashboard to visualize reports on a map (Google Maps or Leaflet fallback).
 - A Flutter mobile app (offline-first) that captures photos, suggests violations using TF Lite, and queues reports for sync.
 - A lightweight static dashboard to visualize reports on a map (prototype uses Leaflet/OpenStreetMap tiles; Google Maps integration is marked "coming in production").
- Demo tooling and docs (seeder, SRS, pitch deck, deployment notes).

## Quick links

- `mobile/flutter_app` — Flutter app source
- `dashboard` — static dashboard frontend
- `backend/mock_db` — sample authorized billboard dataset
- `docs/` — SRS, tech stack, compliance, assumptions, and demo scripts

## Getting started (developer)

1. Install Flutter and set up your device/emulator.
2. Run the mobile app (see `mobile/flutter_app/README.md`).
3. Serve the dashboard locally (see `dashboard/README.md`).