create table
  public.conversation_logs (
    id uuid not null default gen_random_uuid(),
    user_id uuid not null,
    cog_name text not null,
    user_input text null,
    bot_output text null,
    context jsonb null,
    created_at timestamp with time zone not null default now(),
    updated_at timestamp with time zone not null default now(),
    constraint conversation_logs_pkey primary key (id),
    constraint conversation_logs_user_id_fkey foreign key (user_id) references public.profiles (id) on update cascade on delete cascade
  ) tablespace pg_default;

create trigger on_conversation_logs_updated
before update on public.conversation_logs
for each row execute function public.handle_updated_at();

create index idx_conversation_logs_context_gin on public.conversation_logs using gin (context);

-- Index for searching by meal_log_id in context
create index idx_conversation_logs_context_meal on public.conversation_logs using btree ((context ->> 'meal_log_id'));

