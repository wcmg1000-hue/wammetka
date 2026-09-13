-- jwt_role() leía public.profiles desde una política de profiles → recursión infinita (HTTP 500).
create or replace function private.jwt_role()
returns public.app_role
language sql
stable
security definer
set search_path = public
set row_security = off
as $$
  select rol from public.profiles where id = auth.uid();
$$;

create or replace function private.is_staff()
returns boolean
language sql
stable
security definer
set search_path = public
set row_security = off
as $$
  select private.jwt_role() in ('admin', 'operacion', 'finanzas');
$$;

grant execute on function private.jwt_role() to anon, authenticated;
grant execute on function private.is_staff() to anon, authenticated;

drop policy if exists profiles_select_own on public.profiles;
create policy profiles_select_own on public.profiles
  for select using (id = auth.uid());
