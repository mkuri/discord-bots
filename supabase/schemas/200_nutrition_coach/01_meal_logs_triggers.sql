-- This function recalculates the daily nutrition summary for a given user and date
-- by summing up the calories and protein directly from meal_logs table.
create or replace function public.recalculate_daily_nutrition_summary(p_user_id uuid, p_date date)
returns void as $$
begin
    insert into public.nutrition_logs (user_id, date, total_calories, total_protein)
    select
        p_user_id,
        p_date,
        coalesce(sum(total_calories), 0),
        coalesce(sum(total_protein), 0)
    from public.meal_logs
    where
        user_id = p_user_id and meal_date = p_date
    on conflict (user_id, date) do update set
        total_calories = excluded.total_calories,
        total_protein = excluded.total_protein;
end;
$$ language plpgsql set search_path = '';

-- This trigger function is fired when a meal_log is changed.
create or replace function public.handle_meal_log_change()
returns trigger as $$
begin
    if (tg_op = 'DELETE') then
        -- When a meal_log is deleted, recalculate the summary for that day.
        perform public.recalculate_daily_nutrition_summary(old.user_id, old.meal_date);
    else -- INSERT or UPDATE
        -- When a meal_log is inserted or its date changes, recalculate the new date's summary.
        perform public.recalculate_daily_nutrition_summary(new.user_id, new.meal_date);
        -- If the date changed, the old date also needs recalculation.
        if (tg_op = 'UPDATE' and new.meal_date <> old.meal_date) then
            perform public.recalculate_daily_nutrition_summary(old.user_id, old.meal_date);
        end if;
    end if;
    return null;
end;
$$ language plpgsql set search_path = '';


-- Drop old trigger if it exists, then create the new ones.
drop trigger if exists on_meal_logs_change on public.meal_logs;

create trigger on_meal_logs_change_trigger
after insert or update or delete on public.meal_logs
for each row execute function public.handle_meal_log_change();

