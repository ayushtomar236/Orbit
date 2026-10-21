# Orbit setup

iPhone-only SwiftUI app. Backend is hosted Supabase (Auth, Postgres, Storage). Feature screens are placeholders until the next workstream.

## 1. Xcode

1. Install full Xcode (Command Line Tools alone cannot build this app).
2. Open `Orbit.xcodeproj`.
3. Copy `Secrets.example.xcconfig` to `Secrets.xcconfig` in the repo root.
4. In **Supabase → Project Settings → API**, copy **Project URL** into `SUPABASE_URL` and the **anon public** key into `SUPABASE_ANON_KEY`.
5. Select an iPhone simulator and Run.

`Secrets.xcconfig` is gitignored. Do not paste keys into `Secrets.example.xcconfig` or `.env.example`.

Without keys the app still launches and shows **Add Supabase keys**. It does not talk to a fake backend.

## 2. Database

1. Open the Supabase SQL Editor.
2. Paste and run `supabase/migrations/20241021000000_init.sql` once. That creates tables, RLS, and the `posters` bucket.
3. **Authentication → Providers → Email**: turn off **Confirm email** for the hackathon demo.
4. **Authentication → Users**: create three users with emails `student@orbit.app`, `organizer@orbit.app`, and `admin@orbit.app`. Pick passwords yourself; do not store them in the repo.
5. Paste and run `supabase/seed.sql` to set organizer/admin roles.

## 3. Permissions (database, not only UI)

| Role | Feed of approved events | Create pending event | Approve / reject | Register / save |
|---|---|---|---|---|
| student | yes | no | no | own rows |
| organizer | yes | yes (own, status pending) | no | own rows |
| admin | yes (also sees pending) | yes | yes | own rows |

Tabs: student sees Feed, Saved, Profile. Organizer adds Create. Admin adds Create and Review.

## 4. Checks

```sh
chmod +x scripts/check-foundation.sh
make check
```

This verifies files, RLS coverage, example env names, and that examples do not contain key material. It cannot prove your hosted project is configured.

## 5. Team folders

See `OWNERSHIP.txt`. Do not edit lead-owned files without the tech lead.
