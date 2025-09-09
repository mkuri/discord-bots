create table
  public.body_compositions (
    id uuid not null default gen_random_uuid(),
    user_id uuid not null,
    height real null,
    weight real null,
    muscle_mass real null,
    body_fat_percentage real null,
    measured_at timestamp with time zone not null,
    created_at timestamp with time zone not null default now(),
    updated_at timestamp with time zone not null default now(),
    constraint body_compositions_pkey primary key (id),
    constraint body_compositions_user_id_fkey foreign key (user_id) references public.profiles (id) on update cascade on delete cascade
  ) tablespace pg_default;

-- Validation constraints
alter table public.body_compositions
add constraint body_compositions_height_positive check (height is null or height > 0),
add constraint body_compositions_weight_positive check (weight is null or weight > 0),
add constraint body_compositions_muscle_mass_positive check (muscle_mass is null or muscle_mass > 0),
add constraint body_compositions_body_fat_percentage_range check (body_fat_percentage is null or (body_fat_percentage >= 0 and body_fat_percentage <= 100));

create trigger on_body_compositions_updated
before update on public.body_compositions
for each row execute function public.handle_updated_at();

