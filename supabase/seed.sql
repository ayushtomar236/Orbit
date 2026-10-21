-- Run only after you have created the three demo users in the Supabase dashboard
-- (Authentication → Users). Choose passwords locally; do not put them in git.
--
-- Expected emails (roles applied below):
--   student@orbit.app    → student
--   organizer@orbit.app  → organizer
--   admin@orbit.app      → admin

update public.profiles
set role = 'organizer', full_name = 'Riley Organizer'
where id = (select id from auth.users where email = 'organizer@orbit.app');

update public.profiles
set role = 'admin', full_name = 'Avery Admin'
where id = (select id from auth.users where email = 'admin@orbit.app');

update public.profiles
set full_name = 'Alex Student'
where id = (select id from auth.users where email = 'student@orbit.app');
