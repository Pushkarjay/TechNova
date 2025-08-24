
# Billboard Reporter — Flutter App

This is the Flutter mobile prototype for the Flagging Unauthorized Billboards project.

## Quick start (dev)

1. Install Flutter (stable channel) and set up your device/emulator.
2. From the project root run:

```powershell
cd E:\Projects\Working\TechNova\mobile\flutter_app
flutter pub get
flutter run -d <device-id>
```

3. Optional: provide a `.env` file with Cloudinary or Firebase credentials for sync testing. The app is defensive and will still run without keys (it will save reports locally).

## Prototype notes

- The in-app dashboard and map features use open-source Leaflet/OpenStreetMap tiles in the prototype. Google Maps integration is listed as a production feature.
- Sign-in via Google or Email is shown in the UI but displays a "coming in production" dialog in this prototype.
- To seed demo data (15 sample reports), open the app and use the 'Seed Demo Reports' button in the Profile or Dashboard area.

## Project notes

- Offline-first: reports are saved locally in SQLite (or JSON) and synced to Firestore/Cloudinary when connectivity is available.
- Optional TF Lite model: put `tflite` model under `assets/` and declare it in `pubspec.yaml` if you want to test on-device inference.

## Useful commands

```powershell
flutter clean
flutter pub get
flutter analyze
flutter test
```
