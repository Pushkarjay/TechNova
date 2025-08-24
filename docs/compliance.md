# Compliance, Privacy & Ethics

This section explains how the prototype addresses privacy and ethical considerations.

- Data minimization: the app stores only required metadata (image URL, approximate location, timestamp, reported violation, AI suggestion, status). Avoid collecting PII unless necessary.
- Consent: the app UI should display a short consent notice before capturing location and uploading images (prototype includes runtime permission prompts; production should show a consent screen).
- Retention & access: prototype does not implement retention policies; production should add automated retention and strict access controls for sensitive images.
- Moderation & false positives: AI suggestions are only advisory; human confirmation is required at submission. The dashboard includes moderator controls to mark status.
- Legal/regulatory: check local laws for photographing public property and data retention rules. For campus/hackathon demo, use demo data or obtain consent.

## Recommendations (production)

- Implement a retention policy for images (e.g., auto-delete after X days unless flagged for investigation).
- Use signed, time-limited URLs for image uploads in production (avoid unsigned presets).
- Enforce Firestore rules and require authentication for moderation actions.
- Provide an audit log for moderator actions and data exports.
- Add an in-app privacy center where users can view what data is stored and request data deletion (if applicable under local law).

## User-Facing Consent Flow

1. Before first use, show a short consent screen explaining:
	- What is collected (photo, approximate location, timestamp)
	- How it's used (public dashboard, moderation)
	- Anonymity by default and opt-in flow for rewards
2. On each capture, show a short reminder that photos may be uploaded to the cloud when connected.

## Moderation & False Positives

- Flag every AI-suggested violation as "advisory" and require user confirmation.
- In the dashboard, allow moderators to mark reports as `validated`, `rejected`, or `needs_followup`.
- Keep moderation metadata (moderator_id, timestamp, notes) in Firestore with restricted write access.
