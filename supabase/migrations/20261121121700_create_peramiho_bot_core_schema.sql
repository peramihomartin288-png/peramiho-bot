-- Peramiho Bot core schema
-- Mirrors database/models/{User,Session,Setting,Ban}.js.
-- WhatsApp Baileys creds/keys are intentionally NOT stored in Postgres;
-- keep them on encrypted persistent VPS storage and back them up separately.

create extension if not exists pgcrypto with schema extensions;

create table if not exists public.users (
  id text primary key default encode(extensions.gen_random_bytes(12), 'hex'),
  username text not null unique check (char_length(username) between 3 and 32),
  email text not null default '',
  password_hash text not null,
  display_name text not null default '',
  avatar text not null default '',
  role text not null default 'user' check (role in ('user','premium','admin','owner')),
  is_active boolean not null default true,
  is_verified boolean not null default false,
  max_sessions integer not null default 0 check (max_sessions >= 0),
  last_login_at timestamptz,
  last_login_ip text not null default '',
  api_token_hash text,
  reset_token_hash text,
  reset_token_expires timestamptz,
  total_sessions bigint not null default 0 check (total_sessions >= 0),
  total_commands bigint not null default 0 check (total_commands >= 0),
  metadata jsonb not null default '{}'::jsonb check (jsonb_typeof(metadata) = 'object'),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create unique index if not exists users_email_unique_nonempty on public.users (lower(email)) where email <> '';
create unique index if not exists users_api_token_hash_unique on public.users (api_token_hash) where api_token_hash is not null;
create index if not exists users_created_at_idx on public.users (created_at desc);
create index if not exists users_role_active_idx on public.users (role, is_active);

create table if not exists public.sessions (
  id text primary key default encode(extensions.gen_random_bytes(12), 'hex'),
  session_id text not null unique,
  user_id text not null references public.users(id) on delete cascade,
  owner_tag text not null default '',
  phone_number text not null default '',
  jid text not null default '',
  lid text not null default '',
  push_name text not null default '',
  status text not null default 'disconnected' check (status in ('pairing','connecting','connected','disconnected','logged_out','error')),
  last_error text not null default '',
  last_connected_at timestamptz,
  last_seen_at timestamptz,
  is_active boolean not null default true,
  is_primary boolean not null default false,
  messages_sent bigint not null default 0 check (messages_sent >= 0),
  messages_received bigint not null default 0 check (messages_received >= 0),
  commands_used bigint not null default 0 check (commands_used >= 0),
  device_info jsonb not null default '{}'::jsonb check (jsonb_typeof(device_info) = 'object'),
  metadata jsonb not null default '{}'::jsonb check (jsonb_typeof(metadata) = 'object'),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists sessions_user_active_idx on public.sessions (user_id, is_active);
create index if not exists sessions_phone_active_idx on public.sessions (phone_number, is_active);
create index if not exists sessions_status_active_idx on public.sessions (status, is_active);
create index if not exists sessions_created_at_idx on public.sessions (created_at desc);

create table if not exists public.settings (
  id text primary key default encode(extensions.gen_random_bytes(12), 'hex'),
  session_id text not null unique,
  user_id text references public.users(id) on delete cascade,
  prefix text not null default '.' check (char_length(prefix) <= 3),
  mode text not null default 'public' check (mode in ('public','private','group')),
  auto_read boolean not null default true,
  auto_typing boolean not null default false,
  auto_recording boolean not null default false,
  auto_online boolean not null default true,
  auto_reject_call boolean not null default false,
  self_mode boolean not null default false,
  welcome jsonb not null default '{"enabled":false,"message":"Welcome to the group, @user! 👋"}'::jsonb,
  goodbye jsonb not null default '{"enabled":false,"message":"Goodbye @user, we will miss you! 👋"}'::jsonb,
  antilink jsonb not null default '{"enabled":false,"action":"delete"}'::jsonb,
  antispam jsonb not null default '{"enabled":false,"maxMessages":5,"windowSeconds":10}'::jsonb,
  antibadword jsonb not null default '{"enabled":false,"words":[]}'::jsonb,
  footer text not null default 'Powered by Peramiho Bot',
  public_commands boolean not null default true,
  muted_users text[] not null default '{}',
  banned_users text[] not null default '{}',
  blocked_users text[] not null default '{}',
  metadata jsonb not null default '{}'::jsonb check (jsonb_typeof(metadata) = 'object'),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists settings_user_id_idx on public.settings (user_id);
create index if not exists settings_mode_idx on public.settings (mode);

create table if not exists public.bans (
  id text primary key default encode(extensions.gen_random_bytes(12), 'hex'),
  session_id text not null,
  user_id text references public.users(id) on delete set null,
  jid text not null,
  phone_number text not null default '',
  push_name text not null default '',
  reason text not null default 'No reason provided' check (char_length(reason) <= 500),
  banned_by text not null default '',
  type text not null default 'ban' check (type in ('ban','mute','block')),
  is_active boolean not null default true,
  expires_at timestamptz,
  violation_count integer not null default 1 check (violation_count >= 1),
  metadata jsonb not null default '{}'::jsonb check (jsonb_typeof(metadata) = 'object'),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint bans_session_jid_type_unique unique (session_id, jid, type)
);
create index if not exists bans_session_active_idx on public.bans (session_id, is_active);
create index if not exists bans_user_id_idx on public.bans (user_id);
create index if not exists bans_phone_active_idx on public.bans (phone_number, is_active);
create index if not exists bans_expiry_idx on public.bans (expires_at) where expires_at is not null;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = pg_catalog
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists users_set_updated_at on public.users;
create trigger users_set_updated_at before update on public.users for each row execute function public.set_updated_at();
drop trigger if exists sessions_set_updated_at on public.sessions;
create trigger sessions_set_updated_at before update on public.sessions for each row execute function public.set_updated_at();
drop trigger if exists settings_set_updated_at on public.settings;
create trigger settings_set_updated_at before update on public.settings for each row execute function public.set_updated_at();
drop trigger if exists bans_set_updated_at on public.bans;
create trigger bans_set_updated_at before update on public.bans for each row execute function public.set_updated_at();

alter table public.users enable row level security;
alter table public.sessions enable row level security;
alter table public.settings enable row level security;
alter table public.bans enable row level security;

-- Backend-only access. No anon/authenticated policies or grants are created.
revoke all on table public.users, public.sessions, public.settings, public.bans from anon, authenticated;
grant all on table public.users, public.sessions, public.settings, public.bans to service_role;

revoke all on function public.set_updated_at() from public, anon, authenticated;
grant execute on function public.set_updated_at() to service_role;

-- This event-trigger helper is not a public RPC endpoint.
revoke all on function public.rls_auto_enable() from public, anon, authenticated;
