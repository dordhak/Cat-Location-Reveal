-- Keep profile data separate from auth.users and make this safe to rerun.
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique,
  avatar_url text,
  updated_at timestamptz not null default timezone('utc', now())
);

alter table public.profiles add column if not exists username text;
alter table public.profiles add column if not exists avatar_url text;
alter table public.profiles add column if not exists updated_at timestamptz;
-- Older projects may still have display_name as a required legacy column.
-- The current app uses username, so preserve the column but allow it to be empty.
alter table public.profiles add column if not exists display_name text;
alter table public.profiles alter column display_name drop not null;
alter table public.profiles alter column updated_at set default timezone('utc', now());
update public.profiles set updated_at = timezone('utc', now()) where updated_at is null;
alter table public.profiles alter column updated_at set not null;

create unique index if not exists profiles_username_unique
  on public.profiles (username) where username is not null;

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, username)
  values (new.id, nullif(trim(new.raw_user_meta_data ->> 'username'), ''))
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

insert into public.profiles (id, username)
select id, nullif(trim(raw_user_meta_data ->> 'username'), '')
from auth.users
on conflict (id) do nothing;

alter table public.profiles enable row level security;

drop policy if exists "Public profiles are readable" on public.profiles;
create policy "Public profiles are readable" on public.profiles
  for select using (true);

drop policy if exists "Users can update their own profile" on public.profiles;
create policy "Users can update their own profile" on public.profiles
  for update to authenticated
  using (auth.uid() = id)
  with check (auth.uid() = id);

insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do update set public = true;

drop policy if exists "Avatar uploads are owned by the user" on storage.objects;
create policy "Avatar uploads are owned by the user" on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists "Avatar files are readable by their owner" on storage.objects;
create policy "Avatar files are readable by their owner" on storage.objects
  for select to authenticated
  using (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists "Avatar updates are owned by the user" on storage.objects;
create policy "Avatar updates are owned by the user" on storage.objects
  for update to authenticated
  using (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = auth.uid()::text
  )
  with check (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

-- A public bucket still needs object policies for writes and upserts.
do $$
begin
  if to_regclass('public.cat_sightings') is not null then
    execute 'alter table public.cat_sightings drop constraint if exists cat_sightings_user_id_fkey';
    execute 'alter table public.cat_sightings add constraint cat_sightings_user_id_fkey foreign key (user_id) references public.profiles(id) on delete cascade';
    execute 'alter table public.cat_sightings enable row level security';
    execute 'drop policy if exists "Anyone can read cat sightings" on public.cat_sightings';
    execute 'create policy "Anyone can read cat sightings" on public.cat_sightings for select using (true)';
    execute 'drop policy if exists "Users can create their own cat sightings" on public.cat_sightings';
    execute 'create policy "Users can create their own cat sightings" on public.cat_sightings for insert to authenticated with check (auth.uid() = user_id)';
    execute 'drop policy if exists "Users can delete their own cat sightings" on public.cat_sightings';
    execute 'create policy "Users can delete their own cat sightings" on public.cat_sightings for delete to authenticated using (auth.uid() = user_id)';
  end if;
end;
$$;

-- The API schema cache must see username and the explicitly named FK.
notify pgrst, 'reload schema';