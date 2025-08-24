
Flagged Billboards Dashboard

Quick start (local prototype):

1. Copy `src/config.example.js` to `src/config.js` and fill the placeholders:

```js
// src/config.example.js
// Replace with your Firebase config and Google Maps API key
export const FIREBASE_CONFIG = {
	apiKey: "YOUR_KEY",
	authDomain: "YOUR_PROJECT.firebaseapp.com",
	projectId: "YOUR_PROJECT_ID",
	storageBucket: "YOUR_PROJECT.appspot.com",
	messagingSenderId: "...",
	appId: "..."
}

export const GOOGLE_MAPS_API_KEY = "YOUR_GOOGLE_MAPS_API_KEY"
```

2. Serve the folder locally:

```powershell
cd E:\Projects\Working\TechNova\dashboard
python -m http.server 8000
```

3. Open http://localhost:8000 in your browser. Map markers represent `reports` documents in your Firestore project.

Notes:
- The dashboard uses the Firebase client SDK for read access to the `reports` collection. For local testing consider using the Firebase Emulator Suite.
- Protect moderator actions behind authentication in production. Use Firestore rules to restrict updates.
