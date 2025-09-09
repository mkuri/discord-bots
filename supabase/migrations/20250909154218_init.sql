create table "public"."body_compositions" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null,
    "height" real,
    "weight" real,
    "muscle_mass" real,
    "body_fat_percentage" real,
    "measured_at" timestamp with time zone not null,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
);


create table "public"."body_goals" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null,
    "target_weight" real,
    "target_muscle_mass" real,
    "target_body_fat_percentage" real,
    "start_date" timestamp with time zone not null,
    "target_date" timestamp with time zone,
    "is_active" boolean not null default true,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
);


create table "public"."conversation_logs" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null,
    "cog_name" text not null,
    "user_input" text,
    "bot_output" text,
    "context" jsonb,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
);


create table "public"."meal_logs" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null,
    "meal_date" date not null,
    "meal_type" text,
    "description" text not null,
    "total_calories" integer,
    "total_protein" real,
    "image_urls" text[],
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
);


create table "public"."nutrition_goals" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null,
    "target_daily_calories" integer,
    "target_daily_protein" real,
    "start_date" timestamp with time zone not null,
    "target_date" timestamp with time zone,
    "is_active" boolean not null default true,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
);


create table "public"."nutrition_logs" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null,
    "date" date not null,
    "total_calories" integer,
    "total_protein" real,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
);


create table "public"."profiles" (
    "id" uuid not null default gen_random_uuid(),
    "discord_id" text not null,
    "name" text,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
);


CREATE UNIQUE INDEX body_compositions_pkey ON public.body_compositions USING btree (id);

CREATE UNIQUE INDEX body_goals_pkey ON public.body_goals USING btree (id);

CREATE UNIQUE INDEX body_goals_single_active_idx ON public.body_goals USING btree (user_id) WHERE (is_active = true);

CREATE UNIQUE INDEX conversation_logs_pkey ON public.conversation_logs USING btree (id);

CREATE INDEX idx_conversation_logs_context_gin ON public.conversation_logs USING gin (context);

CREATE INDEX idx_conversation_logs_context_meal ON public.conversation_logs USING btree (((context ->> 'meal_log_id'::text)));

CREATE INDEX idx_meal_logs_user_meal_date ON public.meal_logs USING btree (user_id, meal_date);

CREATE UNIQUE INDEX meal_logs_pkey ON public.meal_logs USING btree (id);

CREATE UNIQUE INDEX nutrition_goals_pkey ON public.nutrition_goals USING btree (id);

CREATE UNIQUE INDEX nutrition_goals_single_active_idx ON public.nutrition_goals USING btree (user_id) WHERE (is_active = true);

CREATE UNIQUE INDEX nutrition_logs_pkey ON public.nutrition_logs USING btree (id);

CREATE UNIQUE INDEX nutrition_logs_user_id_date_key ON public.nutrition_logs USING btree (user_id, date);

CREATE UNIQUE INDEX profiles_discord_id_key ON public.profiles USING btree (discord_id);

CREATE UNIQUE INDEX profiles_pkey ON public.profiles USING btree (id);

alter table "public"."body_compositions" add constraint "body_compositions_pkey" PRIMARY KEY using index "body_compositions_pkey";

alter table "public"."body_goals" add constraint "body_goals_pkey" PRIMARY KEY using index "body_goals_pkey";

alter table "public"."conversation_logs" add constraint "conversation_logs_pkey" PRIMARY KEY using index "conversation_logs_pkey";

alter table "public"."meal_logs" add constraint "meal_logs_pkey" PRIMARY KEY using index "meal_logs_pkey";

alter table "public"."nutrition_goals" add constraint "nutrition_goals_pkey" PRIMARY KEY using index "nutrition_goals_pkey";

alter table "public"."nutrition_logs" add constraint "nutrition_logs_pkey" PRIMARY KEY using index "nutrition_logs_pkey";

alter table "public"."profiles" add constraint "profiles_pkey" PRIMARY KEY using index "profiles_pkey";

alter table "public"."body_compositions" add constraint "body_compositions_body_fat_percentage_range" CHECK (((body_fat_percentage IS NULL) OR ((body_fat_percentage >= (0)::double precision) AND (body_fat_percentage <= (100)::double precision)))) not valid;

alter table "public"."body_compositions" validate constraint "body_compositions_body_fat_percentage_range";

alter table "public"."body_compositions" add constraint "body_compositions_height_positive" CHECK (((height IS NULL) OR (height > (0)::double precision))) not valid;

alter table "public"."body_compositions" validate constraint "body_compositions_height_positive";

alter table "public"."body_compositions" add constraint "body_compositions_muscle_mass_positive" CHECK (((muscle_mass IS NULL) OR (muscle_mass > (0)::double precision))) not valid;

alter table "public"."body_compositions" validate constraint "body_compositions_muscle_mass_positive";

alter table "public"."body_compositions" add constraint "body_compositions_user_id_fkey" FOREIGN KEY (user_id) REFERENCES profiles(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."body_compositions" validate constraint "body_compositions_user_id_fkey";

alter table "public"."body_compositions" add constraint "body_compositions_weight_positive" CHECK (((weight IS NULL) OR (weight > (0)::double precision))) not valid;

alter table "public"."body_compositions" validate constraint "body_compositions_weight_positive";

alter table "public"."body_goals" add constraint "body_goals_target_body_fat_percentage_range" CHECK (((target_body_fat_percentage IS NULL) OR ((target_body_fat_percentage >= (0)::double precision) AND (target_body_fat_percentage <= (100)::double precision)))) not valid;

alter table "public"."body_goals" validate constraint "body_goals_target_body_fat_percentage_range";

alter table "public"."body_goals" add constraint "body_goals_target_muscle_mass_positive" CHECK (((target_muscle_mass IS NULL) OR (target_muscle_mass > (0)::double precision))) not valid;

alter table "public"."body_goals" validate constraint "body_goals_target_muscle_mass_positive";

alter table "public"."body_goals" add constraint "body_goals_target_weight_positive" CHECK (((target_weight IS NULL) OR (target_weight > (0)::double precision))) not valid;

alter table "public"."body_goals" validate constraint "body_goals_target_weight_positive";

alter table "public"."body_goals" add constraint "body_goals_user_id_fkey" FOREIGN KEY (user_id) REFERENCES profiles(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."body_goals" validate constraint "body_goals_user_id_fkey";

alter table "public"."body_goals" add constraint "body_goals_valid_date_range" CHECK (((target_date IS NULL) OR (target_date > start_date))) not valid;

alter table "public"."body_goals" validate constraint "body_goals_valid_date_range";

alter table "public"."conversation_logs" add constraint "conversation_logs_user_id_fkey" FOREIGN KEY (user_id) REFERENCES profiles(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."conversation_logs" validate constraint "conversation_logs_user_id_fkey";

alter table "public"."meal_logs" add constraint "meal_logs_calories_positive" CHECK (((total_calories IS NULL) OR (total_calories >= 0))) not valid;

alter table "public"."meal_logs" validate constraint "meal_logs_calories_positive";

alter table "public"."meal_logs" add constraint "meal_logs_protein_positive" CHECK (((total_protein IS NULL) OR (total_protein >= (0)::double precision))) not valid;

alter table "public"."meal_logs" validate constraint "meal_logs_protein_positive";

alter table "public"."meal_logs" add constraint "meal_logs_user_id_fkey" FOREIGN KEY (user_id) REFERENCES profiles(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."meal_logs" validate constraint "meal_logs_user_id_fkey";

alter table "public"."nutrition_goals" add constraint "nutrition_goals_calories_positive" CHECK (((target_daily_calories IS NULL) OR (target_daily_calories > 0))) not valid;

alter table "public"."nutrition_goals" validate constraint "nutrition_goals_calories_positive";

alter table "public"."nutrition_goals" add constraint "nutrition_goals_protein_positive" CHECK (((target_daily_protein IS NULL) OR (target_daily_protein > (0)::double precision))) not valid;

alter table "public"."nutrition_goals" validate constraint "nutrition_goals_protein_positive";

alter table "public"."nutrition_goals" add constraint "nutrition_goals_user_id_fkey" FOREIGN KEY (user_id) REFERENCES profiles(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."nutrition_goals" validate constraint "nutrition_goals_user_id_fkey";

alter table "public"."nutrition_goals" add constraint "nutrition_goals_valid_date_range" CHECK (((target_date IS NULL) OR (target_date > start_date))) not valid;

alter table "public"."nutrition_goals" validate constraint "nutrition_goals_valid_date_range";

alter table "public"."nutrition_logs" add constraint "nutrition_logs_calories_positive" CHECK (((total_calories IS NULL) OR (total_calories >= 0))) not valid;

alter table "public"."nutrition_logs" validate constraint "nutrition_logs_calories_positive";

alter table "public"."nutrition_logs" add constraint "nutrition_logs_protein_positive" CHECK (((total_protein IS NULL) OR (total_protein >= (0)::double precision))) not valid;

alter table "public"."nutrition_logs" validate constraint "nutrition_logs_protein_positive";

alter table "public"."nutrition_logs" add constraint "nutrition_logs_user_id_date_key" UNIQUE using index "nutrition_logs_user_id_date_key";

alter table "public"."nutrition_logs" add constraint "nutrition_logs_user_id_fkey" FOREIGN KEY (user_id) REFERENCES profiles(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."nutrition_logs" validate constraint "nutrition_logs_user_id_fkey";

alter table "public"."profiles" add constraint "profiles_discord_id_key" UNIQUE using index "profiles_discord_id_key";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.handle_meal_log_change()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.handle_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
begin
    new.updated_at = pg_catalog.now();
    return new;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.recalculate_daily_nutrition_summary(p_user_id uuid, p_date date)
 RETURNS void
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
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
$function$
;

grant delete on table "public"."body_compositions" to "anon";

grant insert on table "public"."body_compositions" to "anon";

grant references on table "public"."body_compositions" to "anon";

grant select on table "public"."body_compositions" to "anon";

grant trigger on table "public"."body_compositions" to "anon";

grant truncate on table "public"."body_compositions" to "anon";

grant update on table "public"."body_compositions" to "anon";

grant delete on table "public"."body_compositions" to "authenticated";

grant insert on table "public"."body_compositions" to "authenticated";

grant references on table "public"."body_compositions" to "authenticated";

grant select on table "public"."body_compositions" to "authenticated";

grant trigger on table "public"."body_compositions" to "authenticated";

grant truncate on table "public"."body_compositions" to "authenticated";

grant update on table "public"."body_compositions" to "authenticated";

grant delete on table "public"."body_compositions" to "service_role";

grant insert on table "public"."body_compositions" to "service_role";

grant references on table "public"."body_compositions" to "service_role";

grant select on table "public"."body_compositions" to "service_role";

grant trigger on table "public"."body_compositions" to "service_role";

grant truncate on table "public"."body_compositions" to "service_role";

grant update on table "public"."body_compositions" to "service_role";

grant delete on table "public"."body_goals" to "anon";

grant insert on table "public"."body_goals" to "anon";

grant references on table "public"."body_goals" to "anon";

grant select on table "public"."body_goals" to "anon";

grant trigger on table "public"."body_goals" to "anon";

grant truncate on table "public"."body_goals" to "anon";

grant update on table "public"."body_goals" to "anon";

grant delete on table "public"."body_goals" to "authenticated";

grant insert on table "public"."body_goals" to "authenticated";

grant references on table "public"."body_goals" to "authenticated";

grant select on table "public"."body_goals" to "authenticated";

grant trigger on table "public"."body_goals" to "authenticated";

grant truncate on table "public"."body_goals" to "authenticated";

grant update on table "public"."body_goals" to "authenticated";

grant delete on table "public"."body_goals" to "service_role";

grant insert on table "public"."body_goals" to "service_role";

grant references on table "public"."body_goals" to "service_role";

grant select on table "public"."body_goals" to "service_role";

grant trigger on table "public"."body_goals" to "service_role";

grant truncate on table "public"."body_goals" to "service_role";

grant update on table "public"."body_goals" to "service_role";

grant delete on table "public"."conversation_logs" to "anon";

grant insert on table "public"."conversation_logs" to "anon";

grant references on table "public"."conversation_logs" to "anon";

grant select on table "public"."conversation_logs" to "anon";

grant trigger on table "public"."conversation_logs" to "anon";

grant truncate on table "public"."conversation_logs" to "anon";

grant update on table "public"."conversation_logs" to "anon";

grant delete on table "public"."conversation_logs" to "authenticated";

grant insert on table "public"."conversation_logs" to "authenticated";

grant references on table "public"."conversation_logs" to "authenticated";

grant select on table "public"."conversation_logs" to "authenticated";

grant trigger on table "public"."conversation_logs" to "authenticated";

grant truncate on table "public"."conversation_logs" to "authenticated";

grant update on table "public"."conversation_logs" to "authenticated";

grant delete on table "public"."conversation_logs" to "service_role";

grant insert on table "public"."conversation_logs" to "service_role";

grant references on table "public"."conversation_logs" to "service_role";

grant select on table "public"."conversation_logs" to "service_role";

grant trigger on table "public"."conversation_logs" to "service_role";

grant truncate on table "public"."conversation_logs" to "service_role";

grant update on table "public"."conversation_logs" to "service_role";

grant delete on table "public"."meal_logs" to "anon";

grant insert on table "public"."meal_logs" to "anon";

grant references on table "public"."meal_logs" to "anon";

grant select on table "public"."meal_logs" to "anon";

grant trigger on table "public"."meal_logs" to "anon";

grant truncate on table "public"."meal_logs" to "anon";

grant update on table "public"."meal_logs" to "anon";

grant delete on table "public"."meal_logs" to "authenticated";

grant insert on table "public"."meal_logs" to "authenticated";

grant references on table "public"."meal_logs" to "authenticated";

grant select on table "public"."meal_logs" to "authenticated";

grant trigger on table "public"."meal_logs" to "authenticated";

grant truncate on table "public"."meal_logs" to "authenticated";

grant update on table "public"."meal_logs" to "authenticated";

grant delete on table "public"."meal_logs" to "service_role";

grant insert on table "public"."meal_logs" to "service_role";

grant references on table "public"."meal_logs" to "service_role";

grant select on table "public"."meal_logs" to "service_role";

grant trigger on table "public"."meal_logs" to "service_role";

grant truncate on table "public"."meal_logs" to "service_role";

grant update on table "public"."meal_logs" to "service_role";

grant delete on table "public"."nutrition_goals" to "anon";

grant insert on table "public"."nutrition_goals" to "anon";

grant references on table "public"."nutrition_goals" to "anon";

grant select on table "public"."nutrition_goals" to "anon";

grant trigger on table "public"."nutrition_goals" to "anon";

grant truncate on table "public"."nutrition_goals" to "anon";

grant update on table "public"."nutrition_goals" to "anon";

grant delete on table "public"."nutrition_goals" to "authenticated";

grant insert on table "public"."nutrition_goals" to "authenticated";

grant references on table "public"."nutrition_goals" to "authenticated";

grant select on table "public"."nutrition_goals" to "authenticated";

grant trigger on table "public"."nutrition_goals" to "authenticated";

grant truncate on table "public"."nutrition_goals" to "authenticated";

grant update on table "public"."nutrition_goals" to "authenticated";

grant delete on table "public"."nutrition_goals" to "service_role";

grant insert on table "public"."nutrition_goals" to "service_role";

grant references on table "public"."nutrition_goals" to "service_role";

grant select on table "public"."nutrition_goals" to "service_role";

grant trigger on table "public"."nutrition_goals" to "service_role";

grant truncate on table "public"."nutrition_goals" to "service_role";

grant update on table "public"."nutrition_goals" to "service_role";

grant delete on table "public"."nutrition_logs" to "anon";

grant insert on table "public"."nutrition_logs" to "anon";

grant references on table "public"."nutrition_logs" to "anon";

grant select on table "public"."nutrition_logs" to "anon";

grant trigger on table "public"."nutrition_logs" to "anon";

grant truncate on table "public"."nutrition_logs" to "anon";

grant update on table "public"."nutrition_logs" to "anon";

grant delete on table "public"."nutrition_logs" to "authenticated";

grant insert on table "public"."nutrition_logs" to "authenticated";

grant references on table "public"."nutrition_logs" to "authenticated";

grant select on table "public"."nutrition_logs" to "authenticated";

grant trigger on table "public"."nutrition_logs" to "authenticated";

grant truncate on table "public"."nutrition_logs" to "authenticated";

grant update on table "public"."nutrition_logs" to "authenticated";

grant delete on table "public"."nutrition_logs" to "service_role";

grant insert on table "public"."nutrition_logs" to "service_role";

grant references on table "public"."nutrition_logs" to "service_role";

grant select on table "public"."nutrition_logs" to "service_role";

grant trigger on table "public"."nutrition_logs" to "service_role";

grant truncate on table "public"."nutrition_logs" to "service_role";

grant update on table "public"."nutrition_logs" to "service_role";

grant delete on table "public"."profiles" to "anon";

grant insert on table "public"."profiles" to "anon";

grant references on table "public"."profiles" to "anon";

grant select on table "public"."profiles" to "anon";

grant trigger on table "public"."profiles" to "anon";

grant truncate on table "public"."profiles" to "anon";

grant update on table "public"."profiles" to "anon";

grant delete on table "public"."profiles" to "authenticated";

grant insert on table "public"."profiles" to "authenticated";

grant references on table "public"."profiles" to "authenticated";

grant select on table "public"."profiles" to "authenticated";

grant trigger on table "public"."profiles" to "authenticated";

grant truncate on table "public"."profiles" to "authenticated";

grant update on table "public"."profiles" to "authenticated";

grant delete on table "public"."profiles" to "service_role";

grant insert on table "public"."profiles" to "service_role";

grant references on table "public"."profiles" to "service_role";

grant select on table "public"."profiles" to "service_role";

grant trigger on table "public"."profiles" to "service_role";

grant truncate on table "public"."profiles" to "service_role";

grant update on table "public"."profiles" to "service_role";

CREATE TRIGGER on_body_compositions_updated BEFORE UPDATE ON public.body_compositions FOR EACH ROW EXECUTE FUNCTION handle_updated_at();

CREATE TRIGGER on_body_goals_updated BEFORE UPDATE ON public.body_goals FOR EACH ROW EXECUTE FUNCTION handle_updated_at();

CREATE TRIGGER on_conversation_logs_updated BEFORE UPDATE ON public.conversation_logs FOR EACH ROW EXECUTE FUNCTION handle_updated_at();

CREATE TRIGGER on_meal_logs_change_trigger AFTER INSERT OR DELETE OR UPDATE ON public.meal_logs FOR EACH ROW EXECUTE FUNCTION handle_meal_log_change();

CREATE TRIGGER on_meal_logs_updated BEFORE UPDATE ON public.meal_logs FOR EACH ROW EXECUTE FUNCTION handle_updated_at();

CREATE TRIGGER on_nutrition_goals_updated BEFORE UPDATE ON public.nutrition_goals FOR EACH ROW EXECUTE FUNCTION handle_updated_at();

CREATE TRIGGER on_nutrition_logs_updated BEFORE UPDATE ON public.nutrition_logs FOR EACH ROW EXECUTE FUNCTION handle_updated_at();

CREATE TRIGGER on_profiles_updated BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION handle_updated_at();


