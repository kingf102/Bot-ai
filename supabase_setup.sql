-- Run this ONCE in Supabase: Dashboard -> SQL Editor -> New query -> paste -> Run.

create table if not exists public.kv (
  key   text primary key,
  value jsonb not null
);

create table if not exists public.sales (
  inv       bigint primary key,
  sale_date text   not null,
  status    text   not null default 'ISSUED',
  data      jsonb  not null,
  created   timestamptz not null default now()
);
create index if not exists sales_date_idx on public.sales (sale_date);

-- Lock the tables: nobody can read them with the public (anon) key.
-- The bot uses the SECRET key, which bypasses these rules.
alter table public.kv    enable row level security;
alter table public.sales enable row level security;
