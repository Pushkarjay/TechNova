# Deployment & Runbook (prototype)

Local run (mobile app)

1. Ensure Flutter SDK is installed and device connected.
2. From `mobile/flutter_app` run:

```powershell
flutter pub get
flutter run -d <device-id>
```

3. Provide a local `.env` file with Cloudinary variables for sync testing, or leave empty to skip uploads (SyncService handles missing configuration).

Local run (dashboard)

1. Copy `dashboard/src/config.example.js` to `dashboard/src/config.js` and fill placeholders with test Firebase + Maps keys.
2. From `dashboard` serve files:

```powershell
cd E:\Projects\Working\TechNova\dashboard
python -m http.server 8000
```

Seeder

1. Install dependencies: `pip install -r mobile/flutter_app/tools/requirements.txt`.
2. Run the seeder with a Firebase service account for a test project (do not use production credentials):

```powershell
python mobile/flutter_app/tools/seed_firestore.py --service-account C:\keys\technova-service-account.json --count 10
```

Notes:
- Before production deploy, rotate and secure all keys, enforce Firebase rules, and move image uploads to signed/safe paths.
