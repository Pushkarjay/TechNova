# Tech Stack (detailed)

This file lists the technologies and packages used in the prototype and recommended optional additions for a production-ready build.

## Mobile (Flutter)

- Flutter (stable channel)
- Dart (>=2.18)
- Core packages:
  - `camera` or `image_picker` — capture images from the device
  - `geolocator` — obtain geolocation (GPS)
  - `permission_handler` — request runtime permissions
  - `tflite_flutter` or `tflite` — run TensorFlow Lite models on-device
  - `path_provider` & `sqflite` (or `hive`) — local persistence for offline reports
  - `firebase_core`, `cloud_firestore`, `firebase_storage`, `firebase_auth` — Firebase integration (optional for anonymous or authenticated flows)

## Helpful Mobile Packages (recommended)

- `connectivity_plus` — detect network connectivity and trigger syncs
- `provider` or `riverpod` — state management
- `flutter_local_notifications` — notify users about sync status or review requests
- `intl` — date/time and localization utilities

## Backend & Hosting

- Firebase Firestore — metadata store for reports
- Firebase Storage — photo hosting (production should use signed URLs)
- Cloudinary — alternate image host used for demo flows (unsigned preset)
- Firebase Admin SDK / Node.js — optional admin scripts (seeding, moderation workflows)

## Dashboard / Frontend

- Google Maps JavaScript API — primary map + markers + heatmap
- Leaflet.js — open-source fallback for the map
- Firebase JS SDK — client-side read access to `reports` collection
- Chart.js or D3.js — optional analytics and charts for moderation dashboard

## AI / ML

- TensorFlow (training)
- TensorFlow Lite (mobile inference)
- Preferred detection models: MobileNet-SSD, EfficientDet, or small YOLO variants converted to TFLite
- OCR: Google ML Kit or Tesseract (optional, for extracting text from billboards)

## Utilities & Tooling

- Python — seeder and scripting tools (`tools/seed_firestore.py`)
- Firebase CLI — local emulators and rules deployment
- dotenv — local environment configuration for the Flutter app during development

Notes:

- The prototype is built as offline-first: the app persists reports locally and the `SyncService` uploads images and metadata when connectivity is available.
- Secrets and API keys are intentionally excluded from the repo. Use `dashboard/src/config.example.js` and local `.env` files as templates.
