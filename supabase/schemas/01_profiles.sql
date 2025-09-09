create table
  public.profiles (
    id uuid not null default gen_random_uuid(),
    discord_id text not null,
    name text null,
    created_at timestamp with time zone not null default now(),
    updated_at timestamp with time zone not null default now(),
    constraint profiles_pkey primary key (id),
    constraint profiles_discord_id_key unique (discord_id)
  ) tablespace pg_default;

create trigger on_profiles_updated
before update on public.profiles
for each row execute function public.handle_updated_at();

