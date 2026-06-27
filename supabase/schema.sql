create table if not exists public.trainer_scheduler_states (
  user_id uuid primary key references auth.users(id) on delete cascade,
  app_state jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.trainer_scheduler_states enable row level security;

drop policy if exists "trainer state select own row" on public.trainer_scheduler_states;
create policy "trainer state select own row"
on public.trainer_scheduler_states
for select
to authenticated
using (auth.uid() = user_id);

drop policy if exists "trainer state insert own row" on public.trainer_scheduler_states;
create policy "trainer state insert own row"
on public.trainer_scheduler_states
for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists "trainer state update own row" on public.trainer_scheduler_states;
create policy "trainer state update own row"
on public.trainer_scheduler_states
for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);
