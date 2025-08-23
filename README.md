# Flagging Unauthorized Billboards

This project is a mobile application to detect and report unauthorized billboards. It uses a hybrid approach of AI-based detection and manual user input.

## Features

- **Hybrid Detection:** Uses TensorFlow Lite for AI-powered suggestions and allows users to provide manual input.
- **Photo-based Reporting:** Users can report billboards by taking pictures.
- **Offline Support:** Reports can be saved locally and synced to the backend when an internet connection is available.
- **Privacy-focused:** Anonymous reporting by default, with an option for users to identify themselves for rewards.
- **Public Dashboard:** A web-based dashboard to visualize flagged billboards on a map.

## Project Structure

```
flagging-billboards/
├── README.md
├── mobile/
│   ├── flutter_app/
│   │   ├── lib/
│   │   │   ├── main.dart
│   │   │   ├── screens/
│   │   │   │   ├── camera_screen.dart
│   │   │   │   ├── review_screen.dart
│   │   │   │   └── settings_screen.dart
│   │   │   ├── models/
│   │   │   ├── services/
│   │   │   │   ├── tfservice.dart
│   │   │   │   ├── local_storage.dart
│   │   │   │   └── firebase_sync.dart
│   │   ├── assets/
│   │   │   └── tflite_model.tflite
│   │   └── pubspec.yaml
│   └── README.md
├── backend/
│   ├── firebase_rules.txt
│   └── mock_db/
│       └── authorized_billboards.json
├── dashboard/
│   ├── index.html
│   ├── src/
│   └── package.json
├── docs/
│   ├── SRS_and_QA.md
│   └── architecture.png
└── demo_video/
    └── walkthrough.mp4
```

## Tech Stack

- **Mobile App:** Flutter
- **Backend:** Firebase (Firestore, Storage)
- **AI Model:** TensorFlow Lite
- **Dashboard:** HTML/JS with Google Maps API

## Getting Started

1.  Clone the repository.
2.  Set up a Firebase project and add the configuration files.
3.  Build and run the Flutter application.
4.  Launch the dashboard to view reports.
