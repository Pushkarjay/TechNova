"""
Seed Firestore with demo 'reports' documents for the TechNova project.

Usage:
  1. Create a Firebase service account JSON for your project (Firebase Console -> Project Settings -> Service accounts -> Generate new private key).
  2. Save the JSON somewhere local, e.g. C:\keys\technova-service-account.json
  3. Run the script:
       python tools/seed_firestore.py --service-account C:\keys\technova-service-account.json --count 10

This will upload `count` demo documents to the `reports` collection.

Requirements:
  pip install firebase-admin

Be careful: this writes to your Firestore project. Use a test project if needed.
"""

import argparse
import random
import time
from datetime import datetime

import firebase_admin
from firebase_admin import credentials, firestore


# Use a neutral placeholder image for demo seeding. Replace with your own
# uploaded image URL or configure the seeder to accept an --image-url argument.
SAMPLE_IMAGE = (
    "https://example.com/placeholder-image.jpg"
)


def random_location(center_lat=28.6139, center_lng=77.2090, radius_km=5):
    # Simple random point in box around center (not perfect circle)
    lat = center_lat + (random.random() - 0.5) * (radius_km / 111)
    lng = center_lng + (random.random() - 0.5) * (radius_km / (111 * abs(math.cos(math.radians(center_lat)))))
    return lat, lng


def make_demo_doc(i):
    labels = ["billboard", "not_billboard"]
    ai = random.choice(labels)
    violation = random.choice(["Size", "Placement", "Hazard", "Content"])
    lat = 28.61 + random.uniform(-0.05, 0.05)
    lng = 77.20 + random.uniform(-0.05, 0.05)
    return {
        "imageUrl": SAMPLE_IMAGE,
        "violationType": violation,
        "aiSuggestion": ai,
        "location": firestore.GeoPoint(lat, lng),
        "timestamp": firestore.SERVER_TIMESTAMP,
        "status": random.choice(["unauthorized", "authorized"]),
        "userId": f"demo-user-{i}",
    }


def main():
    parser = argparse.ArgumentParser(description="Seed Firestore with demo reports")
    parser.add_argument("--service-account", required=True, help="Path to Firebase service account JSON")
    parser.add_argument("--count", type=int, default=10, help="Number of demo documents to create")
    args = parser.parse_args()

    cred = credentials.Certificate(args.service_account)
    firebase_admin.initialize_app(cred)
    db = firestore.client()

    print(f"Seeding {args.count} demo documents to Firestore (collection: reports)")
    for i in range(args.count):
        doc = make_demo_doc(i)
        res = db.collection("reports").add(doc)
        print(f"Inserted report {i+1}/{args.count}: {res[1].id}")
        time.sleep(0.1)

    print("Done.")


if __name__ == "__main__":
    import math

    main()
