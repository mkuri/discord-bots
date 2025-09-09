create table
  public.body_goals (
    id uuid not null default gen_random_uuid(),
    user_id uuid not null,
    target_weight real null,
    target_muscle_mass real null,
    target_body_fat_percentage real null,
    start_date timestamp with time zone not null,
    target_date timestamp with time zone null,
    is_active boolean not null default true,
    created_at timestamp with time zone not null default now(),
    updated_at timestamp with time zone not null default now(),
    constraint body_goals_pkey primary key (id),
    constraint body_goals_user_id_fkey foreign key (user_id) references public.profiles (id) on update cascade on delete cascade
  ) tablespace pg_default;

-- Validation constraints
alter table public.body_goals
add constraint body_goals_target_weight_positive check (target_weight is null or target_weight > 0),
add constraint body_goals_target_muscle_mass_positive check (target_muscle_mass is null or target_muscle_mass > 0),
add constraint body_goals_target_body_fat_percentage_range check (target_body_fat_percentage is null or (target_body_fat_percentage >= 0 and target_body_fat_percentage <= 100)),
add constraint body_goals_valid_date_range check (target_date is null or target_date > start_date);

-- Partial unique constraint for active goals (requires CREATE UNIQUE INDEX)
create unique index body_goals_single_active_idx on public.body_goals (user_id) where (is_active = true);

create trigger on_body_goals_updated
before update on public.body_goals
for each row execute function public.handle_updated_at();

