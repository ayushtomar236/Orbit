-- Auth hardening and safe profile recovery for Orbit.
-- The Supabase Auth trigger remains the normal profile initialization path. This
-- migration additionally permits an authenticated user to repair only their own
-- missing profile, and never grants mobile clients access to the role column.

alter table public.profiles enable row level security;
alter table public.events enable row level security;
alter table public.event_registrations enable row level security;
alter table public.saved_events enable row level security;

revoke all on table public.profiles from anon, authenticated;
revoke all on table public.events from anon, authenticated;
revoke all on table public.event_registrations from anon, authenticated;
revoke all on table public.saved_events from anon, authenticated;

grant select on table public.profiles to authenticated;
grant insert (id, full_name, campus) on table public.profiles to authenticated;
grant update (full_name, campus) on table public.profiles to authenticated;

grant select, insert, update on table public.events to authenticated;
grant select, insert, delete on table public.event_registrations to authenticated;
grant select, insert, delete on table public.saved_events to authenticated;

drop policy if exists profiles_select on public.profiles;
create policy profiles_select on public.profiles
  for select to authenticated
  using (true);

drop policy if exists profiles_insert_self_student on public.profiles;
create policy profiles_insert_self_student on public.profiles
  for insert to authenticated
  with check (id = auth.uid() and role = 'student');

drop policy if exists profiles_update_self on public.profiles;
create policy profiles_update_self on public.profiles
  for update to authenticated
  using (id = auth.uid())
  with check (id = auth.uid());

drop policy if exists events_select on public.events;
create policy events_select on public.events
  for select to authenticated
  using (
    status = 'approved'
    or organizer_id = auth.uid()
    or public.is_admin()
  );

drop policy if exists events_insert on public.events;
create policy events_insert on public.events
  for insert to authenticated
  with check (
    organizer_id = auth.uid()
    and status = 'pending'
    and public.is_organizer_or_admin()
  );

drop policy if exists events_update_organizer_pending on public.events;
create policy events_update_organizer_pending on public.events
  for update to authenticated
  using (organizer_id = auth.uid() and status = 'pending')
  with check (organizer_id = auth.uid() and status = 'pending');

drop policy if exists events_update_admin on public.events;
create policy events_update_admin on public.events
  for update to authenticated
  using (public.is_admin())
  with check (public.is_admin());

drop policy if exists registrations_select_own on public.event_registrations;
create policy registrations_select_own on public.event_registrations
  for select to authenticated
  using (user_id = auth.uid());

drop policy if exists registrations_insert_own on public.event_registrations;
create policy registrations_insert_own on public.event_registrations
  for insert to authenticated
  with check (
    user_id = auth.uid()
    and exists (
      select 1 from public.events e
      where e.id = event_id and e.status = 'approved'
    )
  );

drop policy if exists registrations_delete_own on public.event_registrations;
create policy registrations_delete_own on public.event_registrations
  for delete to authenticated
  using (user_id = auth.uid());

drop policy if exists saved_select_own on public.saved_events;
create policy saved_select_own on public.saved_events
  for select to authenticated
  using (user_id = auth.uid());

drop policy if exists saved_insert_own on public.saved_events;
create policy saved_insert_own on public.saved_events
  for insert to authenticated
  with check (user_id = auth.uid());

drop policy if exists saved_delete_own on public.saved_events;
create policy saved_delete_own on public.saved_events
  for delete to authenticated
  using (user_id = auth.uid());

revoke all on function public.is_admin() from public, anon;
revoke all on function public.is_organizer_or_admin() from public, anon;
grant execute on function public.is_admin() to authenticated;
grant execute on function public.is_organizer_or_admin() to authenticated;
