# Tech Stack

This prototype uses the following technologies and libraries:

- Mobile app: Flutter (Dart)
  - Camera & image capture: camera package
  - Local DB: sqflite
  - Permissions: permission_handler, geolocator
  - TensorFlow Lite: tflite_flutter (on-device inference scaffold)
- Cloud & Backend:
  - Firebase Firestore (reports metadata)
  - Cloudinary (image hosting via unsigned preset)
  - Firebase Admin (tools/seed_firestore.py for demo seeding)
- Dashboard: Static HTML + JS
  - Firebase JS SDK (client reads reports)
  - Google Maps JavaScript API for map/markers
- Utilities & tooling:
  - Python for seeder script (`tools/seed_firestore.py`)
  - Firebase CLI for rules deploy
  - dotenv for local env handling in Flutter (defensive load)

Notes:
- The app is an offline-first prototype: reports are saved locally and synced to Cloudinary + Firestore by `SyncService`.
- Sensitive keys are intentionally excluded from the repo; `dashboard/src/config.example.js` is included as a template.
