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
