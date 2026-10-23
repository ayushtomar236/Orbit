-- Optional local/demo data only. Create accounts through Supabase Auth first
-- and choose passwords locally; do not put credentials in git.
-- This script does not create or promote an administrator. See SETUP.md for
-- trusted admin bootstrap using a verified auth user UUID and email.
--
-- Expected demo accounts:
--   student@orbit.app    → student
--   organizer@orbit.app → organizer

update public.profiles
set role = 'organizer', full_name = 'Riley Organizer'
where id = (select id from auth.users where email = 'organizer@orbit.app');

update public.profiles
set full_name = 'Alex Student'
where id = (select id from auth.users where email = 'student@orbit.app');
