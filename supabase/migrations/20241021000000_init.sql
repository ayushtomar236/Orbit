-- Orbit MVP schema, RLS, storage. Tech lead only.
--
-- Permissions (enforced here, not only in the iOS UI):
-- student    read approved events; register/save own rows; update own name/campus; cannot change role
-- organizer  student + insert pending events as self; update own pending events; upload posters under {uid}/
-- admin      all of the above + read pending/rejected; approve/reject any event; delete posters

create type public.user_role as enum ('student', 'organizer', 'admin');
create type public.event_status as enum ('pending', 'approved', 'rejected');

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  full_name text not null,
  campus text not null default 'Main Campus',
  role public.user_role not null default 'student',
  created_at timestamptz not null default now()
);

create table public.events (
  id uuid primary key default gen_random_uuid(),
  organizer_id uuid not null references public.profiles (id) on delete cascade,
  title text not null,
  description text not null default '',
  venue text not null,
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  poster_path text,
  status public.event_status not null default 'pending',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.event_registrations (
  event_id uuid not null references public.events (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (event_id, user_id)
);

create table public.saved_events (
  event_id uuid not null references public.events (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (event_id, user_id)
);

create index events_status_starts_at_idx on public.events (status, starts_at);
create index events_organizer_id_idx on public.events (organizer_id);
create index event_registrations_user_id_idx on public.event_registrations (user_id);
create index saved_events_user_id_idx on public.saved_events (user_id);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger events_set_updated_at
  before update on public.events
  for each row
  execute procedure public.set_updated_at();

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, full_name, role)
  values (
    new.id,
    coalesce(nullif(new.raw_user_meta_data->>'full_name', ''), 'Student'),
    'student'
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row
  execute procedure public.handle_new_user();

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles p
    where p.id = auth.uid() and p.role = 'admin'
  );
$$;

create or replace function public.is_organizer_or_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles p
    where p.id = auth.uid() and p.role in ('organizer', 'admin')
  );
$$;

alter table public.profiles enable row level security;
alter table public.events enable row level security;
alter table public.event_registrations enable row level security;
alter table public.saved_events enable row level security;

revoke all on table public.profiles from anon, authenticated;
revoke all on table public.events from anon, authenticated;
revoke all on table public.event_registrations from anon, authenticated;
revoke all on table public.saved_events from anon, authenticated;

grant select on table public.profiles to authenticated;
grant update (full_name, campus) on table public.profiles to authenticated;
grant select, insert, update on table public.events to authenticated;
grant select, insert, delete on table public.event_registrations to authenticated;
grant select, insert, delete on table public.saved_events to authenticated;
grant execute on function public.is_admin() to authenticated;
grant execute on function public.is_organizer_or_admin() to authenticated;

create policy profiles_select on public.profiles
  for select to authenticated
  using (true);

create policy profiles_update_self on public.profiles
  for update to authenticated
  using (id = auth.uid())
  with check (id = auth.uid());

create policy events_select on public.events
  for select to authenticated
  using (
    status = 'approved'
    or organizer_id = auth.uid()
    or public.is_admin()
  );

create policy events_insert on public.events
  for insert to authenticated
  with check (
    organizer_id = auth.uid()
    and status = 'pending'
    and public.is_organizer_or_admin()
  );

create policy events_update_organizer_pending on public.events
  for update to authenticated
  using (organizer_id = auth.uid() and status = 'pending')
  with check (organizer_id = auth.uid() and status = 'pending');

create policy events_update_admin on public.events
  for update to authenticated
  using (public.is_admin())
  with check (public.is_admin());

create policy registrations_select_own on public.event_registrations
  for select to authenticated
  using (user_id = auth.uid());

create policy registrations_insert_own on public.event_registrations
  for insert to authenticated
  with check (
    user_id = auth.uid()
    and exists (
      select 1 from public.events e
      where e.id = event_id and e.status = 'approved'
    )
  );

create policy registrations_delete_own on public.event_registrations
  for delete to authenticated
  using (user_id = auth.uid());

create policy saved_select_own on public.saved_events
  for select to authenticated
  using (user_id = auth.uid());

create policy saved_insert_own on public.saved_events
  for insert to authenticated
  with check (user_id = auth.uid());

create policy saved_delete_own on public.saved_events
  for delete to authenticated
  using (user_id = auth.uid());

insert into storage.buckets (id, name, public)
values ('posters', 'posters', true)
on conflict (id) do nothing;

create policy posters_public_read on storage.objects
  for select
  using (bucket_id = 'posters');

create policy posters_owner_insert on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'posters'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy posters_owner_update on storage.objects
  for update to authenticated
  using (
    bucket_id = 'posters'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy posters_owner_delete on storage.objects
  for delete to authenticated
  using (
    bucket_id = 'posters'
    and (
      (storage.foldername(name))[1] = auth.uid()::text
      or public.is_admin()
    )
  );
