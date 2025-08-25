# System Architecture

```mermaid
flowchart LR
  MobileApp[Mobile App (Flutter)] -->|Save report locally| LocalDB[Local SQLite]
  MobileApp -->|Capture image| Camera[Camera]
  LocalDB -->|SyncService uploads images| Cloudinary[Cloudinary]
  Cloudinary -->|Returns image URL| Firestore[Firestore]
  LocalDB -->|SyncService writes metadata| Firestore
  Firestore -->|Public read| Dashboard[Dashboard (Static HTML + Firebase JS)]
  Dashboard -->|Maps| GoogleMaps[Google Maps API]
```

Description:

- Mobile App: captures images, runs optional on-device TFLite inference to suggest labels, and saves reports locally (`sqflite`). The user confirms violation type and triggers sync.
- SyncService: iterates unsynced reports, uploads images to Cloudinary, writes a `reports` document to Firestore with image URL, geolocation, timestamp, status, and user metadata; then marks the local row as synced.
- Cloudinary: used for image hosting. The prototype uses an unsigned preset; avoid committing production credentials.
- Firestore: stores reports metadata and supports the dashboard which reads reports and displays them on Google Maps.
- Dashboard: static files served locally or hosted; reads Firestore `reports` collection and renders markers and moderator controls.

Security notes:
- Firestore rules in this prototype allow anonymous create for demo convenience. For production, enforce authentication, validation and restrict updates/deletes.

## Expanded architecture notes

- Mobile client (Flutter): offline-first app that captures photos, runs on-device TF Lite inference (suggests violation type), stores reports locally, and uses a background SyncService to upload images and write report metadata to Firestore. Key locations: `mobile/flutter_app/lib/main.dart`, `mobile/flutter_app/lib/screens/*`, `mobile/flutter_app/lib/services/*`, `mobile/flutter_app/assets/tflite_model.tflite`.
- Cloud services: Cloudinary stores uploaded images and returns image URLs; Firebase Firestore stores each report (imageUrl, location, timestamp, aiSuggestion, status, reporter metadata). See `mobile/flutter_app/firebase.json` and `backend/firebase_rules.txt` for prototype rules.
- Dashboard: static single-page app that uses Firestore realtime listeners when configured, otherwise falls back to `dashboard/sample_data/reports.json`. Key files: `dashboard/index.html`, `dashboard/src/main.js`, `dashboard/src/config.example.js`.
- Tools & data: `mobile/flutter_app/tools/seed_firestore.py` seeds Firestore for demos; `backend/mock_db/authorized_billboards.json` is the reference dataset for authorized billboards.

## Compact ASCII diagram

Mobile App (Flutter)
  [Camera UI / Screens] -> [On-device ML (TFLite)] -> [Local Queue / Storage]
                                               |
                                               v
                                         [Sync Service]
                                           /      \
                                          v        v
                                  [Cloudinary]     [Firestore]
                                       |               |
                                       v               v
                                   imageUrl         Dashboard (map)

## High-quality image-generation prompt (copy/paste)

Use this prompt in an image generator or diagram tool (diagrams.net, Midjourney, DALL·E, Stable Diffusion). It is tuned for a clean, vector-style architecture diagram suitable for slides or a README.

"Create a clean, modern vector-style architecture diagram for a mobile-first 'Unauthorized Billboards' system on a white background. Layout left-to-right: Left column = Mobile App; Center = Cloud Services; Right column = Dashboard & Tools. Use flat rounded boxes, minimal icons (smartphone, camera, ML brain, cloud storage, database, map), and a teal/blue accent palette. Draw directional arrows with short captions for data flows. Include these labeled components (with file-path subtext in monospace):\n\n+1) Mobile App (left)\n+   - 'Flutter Mobile App — Offline-first'\n+   - Camera UI — `mobile/flutter_app/lib/screens/*.dart`\n+   - On-device ML (TFLite) — `assets/tflite_model.tflite`, `lib/services/tfservice.dart`\n+   - Local queue / storage — `lib/services/local_storage.dart`\n+   - Sync Service — `lib/services/sync_service.dart`\n+\n+2) Cloud Services (center)\n+   - Cloudinary (images) — show storage icon\n+   - Firebase Firestore (reports) — show DB icon\n+   - Arrows: 'Upload image → Cloudinary (returns imageUrl)', 'Write report → Firestore (report doc with imageUrl, location, aiSuggestion)'\n+\n+3) Dashboard & Tools (right)\n+   - Dashboard (map) — `dashboard/index.html`, `dashboard/src/main.js` (label: 'uses Firestore or sample JSON fallback')\n+   - Tools: `mobile/flutter_app/tools/seed_firestore.py`, `backend/mock_db/authorized_billboards.json`, `backend/firebase_rules.txt`\n+\n+Styling notes: use Roboto/Inter-like sans-serif, teal (#00BFA6) for primary flows, deep-blue headers, neutral greys for boxes. Export as SVG or PNG at 3840x2160. Add a bottom-left legend mapping icons and a small timestamp. Keep spacing generous and ensure arrows are labeled and non-overlapping."

### Quick generator flags
- Midjourney: append `--ar 16:9 --v 6 --q 2` and try small prompt variations such as "vector diagram" or "isometric diagram".\n- DALL·E / Stable Diffusion: request "high detail, vector flat style, 3840x2160, transparent background".

## Next steps
- If you want an editable diagram I can produce a Mermaid diagram (text) you can paste into Mermaid Live Editor or export as SVG/PNG — say "generate Mermaid" and I'll add it here.

