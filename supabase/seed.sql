-- Hosted Supabase: create these users in Authentication > Users, then run the role updates.
-- Local supabase db reset: this file cannot insert auth.users on hosted projects.
--
-- Seed accounts (password: OrbitDemo1!):
--   student@orbit.app    role student
--   organizer@orbit.app  role organizer
--   admin@orbit.app      role admin
--
-- After the three users exist (sign-up or dashboard), promote organizer/admin:

update public.profiles
set role = 'organizer', full_name = 'Riley Organizer'
where id = (select id from auth.users where email = 'organizer@orbit.app');

update public.profiles
set role = 'admin', full_name = 'Avery Admin'
where id = (select id from auth.users where email = 'admin@orbit.app');

update public.profiles
set full_name = 'Alex Student'
where id = (select id from auth.users where email = 'student@orbit.app');
