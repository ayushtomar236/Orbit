# Orbit setup

Orbit is an iPhone-only SwiftUI app using Supabase Auth, Postgres, and Storage. Auth sessions use the Supabase Swift SDK's Apple Keychain storage. No service-role credential belongs in the app.

## 1. Configure the app

1. Open `Orbit.xcodeproj` with full Xcode and select an iPhone simulator or device.
2. Copy `Secrets.example.xcconfig` to `Secrets.xcconfig` in the repository root.
3. In Supabase **Project Settings → API**, set `SUPABASE_URL` to the complete `https://<project-ref>.supabase.co` Project URL and `SUPABASE_ANON_KEY` to the anon JWT or publishable client key.
4. Build and run Orbit. `Secrets.xcconfig` is gitignored. Never put a `service_role` JWT or `sb_secret_` key in the app, examples, or source control. The app rejects those privileged key formats.

The app shows a configuration screen when either value is missing or invalid. `.env.example` is documentation only; the iOS app reads `Secrets.xcconfig` through `Config/Base.xcconfig`.

## 2. Configure Supabase Auth

1. In **Authentication → Providers → Email**, enable email/password sign-in.
2. Choose whether **Confirm email** is enabled. Orbit supports both: confirmation-enabled signup asks the user to follow the email link and then sign in; confirmation-disabled signup signs them in immediately.
3. Set the Supabase **Site URL** and any allowed redirect URLs to the destinations you use for confirmation links. If you later add app deep links, register the app redirect URL in Supabase and handle that URL in the iOS app.
4. Set the minimum password length to at least 8 characters to match Orbit's client validation.

## 3. Apply database migrations

Run these files in order in the Supabase SQL Editor or through the Supabase CLI:

1. `supabase/migrations/20241021000000_init.sql` creates profiles, events, registrations, saved events, the profile-on-signup trigger, and the initial RLS policies/storage bucket.
2. `supabase/migrations/20261022000000_auth_profile_bootstrap.sql` reapplies the authorization grants and policies and enables safe recovery of a missing student's own profile.

RLS stays enabled. New profiles are created by a database trigger with the `student` role. The mobile client can insert only its own profile and update only `full_name` and `campus`; it cannot write the role column. Organizer event inserts must belong to the organizer and start `pending`. Organizer updates are limited to their own pending events. Only a database-authorized admin may approve or reject events. Students may register and save only as themselves.

Existing Supabase projects must apply both migrations. Do not fix permission errors by disabling RLS or granting the app broader table access.

## 4. Bootstrap roles safely

There is no first-admin account in the app, and signup never accepts a role. Create the account normally, then promote the verified account from the Supabase SQL Editor using trusted project-owner access. Check the user UUID and email in **Authentication → Users** first, replace both placeholders below, and run the block only in the intended project:

```sql
do $bootstrap_admin$
declare
  target_user_id constant uuid := 'REPLACE-WITH-VERIFIED-AUTH-USER-UUID';
  target_email constant text := 'REPLACE-WITH-VERIFIED-EMAIL';
begin
  if not exists (
    select 1 from auth.users
    where id = target_user_id
      and lower(email) = lower(target_email)
      and email_confirmed_at is not null
  ) then
    raise exception 'Auth user ID/email verification failed';
  end if;

  update public.profiles
  set role = 'admin'
  where id = target_user_id;

  if not found then
    raise exception 'Profile does not exist; resolve profile initialization before promotion';
  end if;
end
$bootstrap_admin$;
```

This operation requires trusted database-owner access and is intentionally unavailable to the mobile client. Review the target project, UUID, and email before executing. To create demo students or organizers, use accounts you control; `supabase/seed.sql` may promote the named demo organizer only. It does not create or assign an admin.

## 5. Verify

```sh
make check
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild \
  -project Orbit.xcodeproj -scheme Orbit \
  -destination 'generic/platform=iOS Simulator' build
```

The foundation check validates required files and policy markers. A successful simulator build checks Swift compilation, but auth against the hosted project must still be exercised with test accounts: signup, confirmation (if enabled), sign-in, force-quit/relaunch session restore, and sign-out. Test authorization with separate student, organizer, and admin accounts; UI role hiding is not the security boundary, database RLS is.

## 6. Authorization expectations

| Role | Read events | Create event | Edit event | Approve/reject | Register/save |
|---|---|---|---|---|---|
| Student | Approved events | No | No | No | Own rows |
| Organizer | Approved events and own events | Own, pending only | Own pending only | No | Own rows |
| Admin | All events | Own, pending only | Any event | Yes | Own rows |

The project does not include an automated hosted-Supabase integration test because that would require test accounts and mutate project data. Never test these permissions with a production account or production project.
