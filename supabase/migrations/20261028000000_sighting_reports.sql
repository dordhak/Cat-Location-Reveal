create table if not exists public.sighting_reports (
  id uuid primary key default gen_random_uuid(),
  sighting_id uuid not null references public.cat_sightings(id) on delete cascade,
  reporter_id uuid not null references auth.users(id) on delete cascade,
  reason text not null check (reason in ('inappropriate', 'harassment', 'bullying')),
  details text,
  created_at timestamptz not null default timezone('utc', now())
);

alter table public.sighting_reports enable row level security;

drop policy if exists "Signed-in users can submit sighting reports"
  on public.sighting_reports;
create policy "Signed-in users can submit sighting reports"
  on public.sighting_reports
  for insert to authenticated
  with check (auth.uid() = reporter_id);

drop policy if exists "Users can view their own sighting reports"
  on public.sighting_reports;
create policy "Users can view their own sighting reports"
  on public.sighting_reports
  for select to authenticated
  using (auth.uid() = reporter_id);
