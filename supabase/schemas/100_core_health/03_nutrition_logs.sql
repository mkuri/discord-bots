create table
  public.nutrition_logs (
    id uuid not null default gen_random_uuid(),
    user_id uuid not null,
    date date not null,
    total_calories integer null,
    total_protein real null,
    created_at timestamp with time zone not null default now(),
    updated_at timestamp with time zone not null default now(),
    constraint nutrition_logs_pkey primary key (id),
    constraint nutrition_logs_user_id_fkey foreign key (user_id) references public.profiles (id) on update cascade on delete cascade,
    constraint nutrition_logs_user_id_date_key unique (user_id, date)
  ) tablespace pg_default;

-- Validation constraints
alter table public.nutrition_logs
add constraint nutrition_logs_calories_positive check (total_calories is null or total_calories >= 0),
add constraint nutrition_logs_protein_positive check (total_protein is null or total_protein >= 0);

create trigger on_nutrition_logs_updated
before update on public.nutrition_logs
for each row execute function public.handle_updated_at();

