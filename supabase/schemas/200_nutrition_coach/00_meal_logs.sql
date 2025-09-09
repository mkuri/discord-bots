create table
  public.meal_logs (
    id uuid not null default gen_random_uuid(),
    user_id uuid not null,
    meal_date date not null,
    meal_type text null,
    description text not null,
    total_calories integer null,
    total_protein real null,
    image_urls text[] null,
    created_at timestamp with time zone not null default now(),
    updated_at timestamp with time zone not null default now(),
    constraint meal_logs_pkey primary key (id),
    constraint meal_logs_user_id_fkey foreign key (user_id) references public.profiles (id) on update cascade on delete cascade
  ) tablespace pg_default;

-- Validation constraints for meal_logs
alter table public.meal_logs
add constraint meal_logs_calories_positive check (total_calories is null or total_calories >= 0),
add constraint meal_logs_protein_positive check (total_protein is null or total_protein >= 0);

create index idx_meal_logs_user_meal_date on public.meal_logs using btree (user_id, meal_date);

-- Trigger for timestamp updates
create trigger on_meal_logs_updated
before update on public.meal_logs
for each row execute function public.handle_updated_at();

