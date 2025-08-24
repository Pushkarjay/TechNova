Flagged Billboards Dashboard

Quick start (local prototype):

1. Copy `src/config.example.js` to `src/config.js` or use the auto-generated `src/config.js` already in the repo for prototype.
2. Serve the folder locally:

```powershell
cd E:\Projects\Working\TechNova\dashboard
python -m http.server 8000
```

3. Open http://localhost:8000 in your browser. Map markers represent `reports` documents in your Firestore project.

Notes:
- The dashboard uses Firebase client SDK and requires valid `FIREBASE_CONFIG` and `GOOGLE_MAPS_API_KEY` in `src/config.js`.
- This is a prototype. For production add authentication and protect moderator actions.
