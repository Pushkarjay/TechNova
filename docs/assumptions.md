# Assumptions

1. The prototype will be demonstrated on a controlled test dataset or live demo account, not on production systems.
2. Users consent to share photos and geolocation for the purpose of reporting public signage.
3. On-device TFLite model is optional for the hackathon demonstration; the app handles missing model gracefully and still allows manual reporting.
4. Cloudinary is used as a simple image host for the prototype; production would use signed uploads or a secured storage bucket.
5. Firestore rules are relaxed for prototype speed; a production deployment would require stricter auth and validation.
