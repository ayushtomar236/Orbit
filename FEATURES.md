# Orbit feature map

## Built

- Supabase configuration loading and a setup screen when credentials are missing.
- Session restoration, sign-out, and role-based navigation for students, organizers, and admins.
- Typed profile and event models with repository interfaces and live Supabase implementations.
- Initial database schema, profile creation on signup, row-level security, poster storage policies, and seed data.
- Shared SwiftUI colors, spacing, buttons, cards, and placeholder components.
- Sign-in and student signup forms with field validation, progress feedback, auth errors, and email-confirmation messaging.

## Partially built

- Profile shows account name, role, and campus and can sign out. Editing profile and listing registrations are absent.
- Auth plumbing is connected to Supabase, but the new forms still need an end-to-end run against a configured Supabase project, including both email-confirmation settings.

## Not built yet

- Campus event feed and event detail.
- Event creation, poster upload, organizer status, and admin moderation.
- Saving events and registering for an event.
- Saved-events and registration lists.
- Profile editing and account recovery.

## Recommended next features

1. **Event feed and detail** — load approved events, show useful event cards, support refresh/empty/error states, and open a detail page. This unlocks the primary student experience.
2. **Registration and saved events** — add register/save actions to event detail, show each user's registrations and saved events, and handle duplicate or failed writes cleanly.
3. **Organizer event creation** — create a pending event with date/time validation, venue and description, plus poster upload to the existing storage bucket.
4. **Admin review** — list pending events and approve or reject them with clear status feedback.
5. **Profile completion** — edit name/campus and replace the current registered-events placeholder with the user's registrations.
6. **Account recovery** — add forgot-password and password-reset handling, including the redirect/deep-link setup required by Supabase.
7. **Polish and release readiness** — accessibility labels, loading/empty/error states across screens, and a test pass on a configured Supabase project and supported iPhone sizes.

The event feed is the best next implementation slice because it makes the signed-in app useful immediately and provides the destination for registration and saving.
