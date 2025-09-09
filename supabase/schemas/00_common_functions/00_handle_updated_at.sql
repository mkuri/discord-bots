create or replace function public.handle_updated_at()
returns trigger as $$
begin
    new.updated_at = pg_catalog.now();
    return new;
end;
$$ language plpgsql set search_path = '';

