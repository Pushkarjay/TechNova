# Assumptions (updated)

This file lists the assumptions the team made while designing and building the prototype. These help set expectations for reviewers or future developers.

1. Users have smartphones with working cameras and will install the Flutter app.
2. Internet availability may be intermittent; the app must work offline and sync later.
3. Users will opt-in to location sharing when prompted; geotags are recorded only with consent.
4. Municipal authorities or third parties may later provide **official billboard databases** for integration; the system must support importing such databases (CSV/JSON/Firestore imports).
5. The demo uses mock or seeded data for authorized billboards in select cities; production integration will require data validation and matching heuristics.
6. On-device TFLite inference is optional for the demo. If missing, the app still allows manual reporting and local saving.
7. Prototype Firestore security rules are relaxed for speed during development. Production must lock down writes, require authentication for sensitive actions, and provide moderation roles.

Notes:
- These assumptions are intentionally conservative to make the prototype robust and easy to demo.
- If you want, I can add a small import script to demonstrate how to load a municipal billboard database into Firestore.
