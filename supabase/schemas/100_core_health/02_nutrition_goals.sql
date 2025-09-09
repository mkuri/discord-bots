create table
  public.nutrition_goals (
    id uuid not null default gen_random_uuid(),
    user_id uuid not null,
    target_daily_calories integer null,
    target_daily_protein real null,
    start_date timestamp with time zone not null,
    target_date timestamp with time zone null,
    is_active boolean not null default true,
    created_at timestamp with time zone not null default now(),
    updated_at timestamp with time zone not null default now(),
    constraint nutrition_goals_pkey primary key (id),
    constraint nutrition_goals_user_id_fkey foreign key (user_id) references public.profiles (id) on update cascade on delete cascade
  ) tablespace pg_default;

-- Validation constraints
alter table public.nutrition_goals
add constraint nutrition_goals_calories_positive check (target_daily_calories is null or target_daily_calories > 0),
add constraint nutrition_goals_protein_positive check (target_daily_protein is null or target_daily_protein > 0),
add constraint nutrition_goals_valid_date_range check (target_date is null or target_date > start_date);

-- Partial unique constraint for active goals (requires CREATE UNIQUE INDEX)
create unique index nutrition_goals_single_active_idx on public.nutrition_goals (user_id) where (is_active = true);

create trigger on_nutrition_goals_updated
before update on public.nutrition_goals
for each row execute function public.handle_updated_at();

