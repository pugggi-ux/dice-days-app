-- Dice Days Database Schema for Supabase
-- Based on SPEC.md data model requirements

create table events (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  code text not null unique,
  start_date date not null,
  end_date date not null,
  location text,
  created_at timestamptz not null default now()
);

create index idx_events_code on events(code);

create table participants (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references events(id) on delete cascade,
  nickname text not null,
  device_token text,
  joined_at timestamptz not null default now(),
  unique(event_id, nickname)
);

create table games (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references events(id) on delete cascade,
  name text not null,
  bgg_id text,
  image_url text,
  min_players int,
  max_players int,
  playing_time_minutes int,
  weight numeric(3,2),
  description text,
  status text not null default 'unplanned' check (status in ('unplanned', 'planned', 'played')),
  pack_status text not null default 'to_pack' check (pack_status in ('to_pack', 'give_get', 'done')),
  created_at timestamptz not null default now()
);

-- n:m relation tables for roles (multiple persons per role per game)

create table game_interests (
  game_id uuid not null references games(id) on delete cascade,
  participant_id uuid not null references participants(id) on delete cascade,
  needs_explanation boolean not null default false,
  created_at timestamptz not null default now(),
  primary key (game_id, participant_id)
);

create table game_explainers (
  game_id uuid not null references games(id) on delete cascade,
  participant_id uuid not null references participants(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (game_id, participant_id)
);

create table game_suppliers (
  game_id uuid not null references games(id) on delete cascade,
  participant_id uuid not null references participants(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (game_id, participant_id)
);

create table game_hidden (
  game_id uuid not null references games(id) on delete cascade,
  participant_id uuid not null references participants(id) on delete cascade,
  primary key (game_id, participant_id)
);

-- Trade exchange module
create table trade_items (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references events(id) on delete cascade,
  name text not null,
  offered_by uuid not null references participants(id) on delete cascade,
  claimed_by uuid references participants(id),
  completed boolean not null default false,
  created_at timestamptz not null default now()
);

-- Packing list module (3-tier)
create table packlist_items (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references events(id) on delete cascade,
  participant_id uuid references participants(id) on delete cascade,
  name text not null,
  tier text not null check (tier in ('event', 'personal', 'auto')),
  checked boolean not null default false,
  source_type text,
  source_id uuid
);

-- Enable Realtime for live updates
alter publication supabase_realtime add table game_interests;
alter publication supabase_realtime add table game_explainers;
alter publication supabase_realtime add table game_suppliers;
alter publication supabase_realtime add table games;
