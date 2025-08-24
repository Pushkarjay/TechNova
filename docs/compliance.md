# Compliance, Privacy & Ethics

This section explains how the prototype addresses privacy and ethical considerations.

- Data minimization: the app stores only required metadata (image URL, approximate location, timestamp, reported violation, AI suggestion, status). Avoid collecting PII unless necessary.
- Consent: the app UI should display a short consent notice before capturing location and uploading images (prototype includes runtime permission prompts; production should show a consent screen).
- Retention & access: prototype does not implement retention policies; production should add automated retention and strict access controls for sensitive images.
- Moderation & false positives: AI suggestions are only advisory; human confirmation is required at submission. The dashboard includes moderator controls to mark status.
- Legal/regulatory: check local laws for photographing public property and data retention rules. For campus/hackathon demo, use demo data or obtain consent.
